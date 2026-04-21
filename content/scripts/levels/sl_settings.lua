---@class SettingsMenu : Sublevel
---@field setListening fun(self: SettingsMenu, listening: boolean, index: integer)
---@field canListen boolean
---@field getListening fun(self: SettingsMenu)

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as SettingsMenu]]
setmetatable(sl, { __index = Sublevel })

local enumeratorButton = require("content.scripts.objects.enumeratorButton")
local sliderButton = require("content.scripts.objects.sliderButton")
local inputButton = require("content.scripts.objects.inputButton")
local basicbutton = require("content.scripts.objects.basicButton")

local SubMenus = {
    Graphics = 0,
    Audio = 1,
    Input = 2
}

local subMenu = -1
local headerContainer = nil --[[@as Image2D]]
local backButton = nil --[[@as Text2D]]
local applyButton = nil --[[@as Text2D]]
local headerButtons = {} --[[ @as Text2D[] ]]
local currentSettings = {}
local updateLayoutCurrentSettings = nil --[[@as function?]]
local listening = false -- Listening for inputs?
local tempConfig = {} --[[@as Config]]

-- Hooks
local statChangeHook = nil --[[@as Hook]]
local updateLayoutHook = nil --[[@as Hook]]
local updateButtonsHook = nil --[[@as Hook]]

local function updateLayout()
    headerContainer.position.x = Lime.Window.getSize().x / 2 - headerContainer.size.x / 2
    headerContainer.position.y = Lime.Window.getSize().y / 2 - headerContainer.size.y / 2

    backButton.position.x = headerContainer.position.x - backButton.size.x
    backButton.position.y = headerContainer.position.y - backButton.size.y

    applyButton.position.x = headerContainer.position.x + headerContainer.size.x - applyButton.size.x + 60
    applyButton.position.y = headerContainer.position.y - applyButton.size.y

    if updateLayoutCurrentSettings then updateLayoutCurrentSettings() end
end

---@param text string
---@param small boolean?
local function createButton(text, small)
    local btn = Text2D.new(text)
    btn:setAlignment(Lime.Enum.TextAlign.Center)
    local x = 200
    local y = 48
    if small then x = 100; y = 32 end
    btn.size = Vec2.new(x, y)

    local font = GameManager.fonts.futurespore.px48
    if small then
        font = GameManager.fonts.futurespore.px32
    end

    btn:setFont(font)
    return btn
end

local function updateButtons()
    local hbNames = { "Visuals", "Audio", "Input" }

    backButton.text = "Back"
    if backButton:isHovered() then backButton.text = "<#CE67F7>" .. "Back" end

    applyButton.text = "Apply"
    if applyButton:isHovered() then applyButton.text = "<#CE67F7>" .. "Apply" end

    for i = 1, #headerButtons do
        local out = headerButtons[i] --[[@as Text2D]]
        if out:isHovered() and i - 1 ~= subMenu then
            local color = "<#CE67F7>"
            if Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Left) then
                color = "<#68357C>"
            end
            out.text = color .. hbNames[i]
        elseif i - 1 == subMenu then
            out.text = "<#68357C>" .. hbNames[i]
        else
            out.text = hbNames[i]
        end
    end
end

local function clearSettingsObjects()
    for i = 1, #currentSettings do
        if currentSettings[i].clean then
            currentSettings[i]:clean()
        end
    end
    currentSettings = {}
end

local function addToSettingsObjects(option)
    currentSettings[#currentSettings + 1] = option
    option.index = #currentSettings
end

local function deepCopy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = type(v) == "table" and deepCopy(v) or v
    end
    return out
end

local listeningHookKey = nil --[[@as Hook]]
local listeningHookMouse = nil --[[@as Hook]]
local currentlyListeningIndex = 0

local inputToString = require("content.scripts.tools.inputToString")

---@param code integer
---@param mouse boolean
local function handleListeningInput(code, mouse)
    local out = nil
    local avoidDoubleLMB = false
    if mouse then -- Mouse pressed
        out = inputToString.MouseName[code]
        Lime.log("Mouse bound: " .. tostring(out))
        if code == Lime.Enum.Mouse.Left then
            for i = 2, #currentSettings do
                local c = currentSettings[i].container --[[@as Image2D]]
                if c:isHovered() then avoidDoubleLMB = true end 
            end
        end
    else -- Key pressed
        out = inputToString.KeyName[code]
        Lime.log("Key bound: " .. tostring(out))
    end

    if not out then
        Lime.log("Not valid input...")
    else
        currentSettings[currentlyListeningIndex].inputVal = out 
        local out = currentSettings[currentlyListeningIndex] --[[@as InputButton]]
        if out.callback then out.callback(code, mouse) end
    end

    Lime.GUI.unfocus()

    local settings = GameManager:getSublevel("settings") --[[@as SettingsMenu]]
    settings:setListening(false, currentlyListeningIndex)
    currentlyListeningIndex = 0
    settings.canListen = not avoidDoubleLMB
end

---@param l boolean
---@param index integer
function sl:setListening(l, index)
    if subMenu == SubMenus.Input and l ~= listening then
        listening = l

        backButton.visible = not listening
        applyButton.visible = not listening
        for i = 1, #headerButtons do
            headerButtons[i].visible = not listening
        end

        for i = 1, #currentSettings do
            if currentSettings[i].index ~= index then
                currentSettings[i].container.visible = not listening
            end
        end

        local thisObj = self
        if listening then
            currentlyListeningIndex = index

            listeningHookKey = Lime.Input.onKeyPressed:hook(function(key)
                if key == Lime.Enum.Key.Escape then
                    thisObj:setListening(false, index)
                    return
                end
                handleListeningInput(key, false)
            end)

            listeningHookMouse = Lime.Input.onMouseButtonPressed:hook(function(button)
                handleListeningInput(button, true)
            end)
        else
            listeningHookKey:unhook()
            listeningHookMouse:unhook()
        end
    end
end

---@return boolean
function sl:getListening()
    return listening
end

---@param menu integer
local function selectSubmenu(menu)
    if subMenu == menu then return end
    subMenu = menu
    clearSettingsObjects()

    local spacing = 20
    local btn = nil
    if menu == SubMenus.Graphics then
        btn = enumeratorButton.new("Video Driver", {"Direct3D9", "OpenGL"}, "<#E7E550>Must return to your world to take effect.") --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.gfx.driver)
        btn:setCallback(function(v) tempConfig.gfx.driver = v end)
        addToSettingsObjects(btn)

        btn = enumeratorButton.new("Perspective", {"First", "Third"}) --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.gfx.perspective)
        btn:setCallback(function(v) tempConfig.gfx.perspective = v end)
        addToSettingsObjects(btn)

        btn = sliderButton.new("Field of View", Vec2.new(75, 120), false) --[[@as SliderButton]]
        btn:setVal(tempConfig.gfx.fov)
        btn:setCallback(function(v) tempConfig.gfx.fov = v end)
        addToSettingsObjects(btn)

        btn = sliderButton.new("Frame Rate", Vec2.new(30, 144), false) --[[@as SliderButton]]
        btn:setVal(tempConfig.gfx.fps)
        btn:setCallback(function(v) tempConfig.gfx.fps = v end)
        addToSettingsObjects(btn)

        btn = enumeratorButton.new("VSync", {"Off", "On"}) --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.gfx.vsync)
        btn:setCallback(function(v) tempConfig.gfx.vsync = v end)
        addToSettingsObjects(btn)

        btn = enumeratorButton.new("Chatbox", {"Off", "On"}, "Shows messages from other spacecrafts.") --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.gfx.chatbox)
        btn:setCallback(function(v) tempConfig.gfx.chatbox = v end)
        addToSettingsObjects(btn)

        btn = enumeratorButton.new("Shuttle Info", {"Off", "On"}, "Shows ping, frame rate, and more.") --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.gfx.info)
        btn:setCallback(function(v) tempConfig.gfx.info = v end)
        addToSettingsObjects(btn)
        
    elseif menu == SubMenus.Audio then
        btn = sliderButton.new("Master", Vec2.new(0, 100), false) --[[@as SliderButton]]
        btn:setVal(tempConfig.audio.master)
        btn:setCallback(function(v) tempConfig.audio.master = v end)
        addToSettingsObjects(btn)

        btn = sliderButton.new("Music", Vec2.new(0, 100), false) --[[@as SliderButton]]
        btn:setVal(tempConfig.audio.music)
        btn:setCallback(function(v) tempConfig.audio.music = v end)
        addToSettingsObjects(btn)

        btn = sliderButton.new("Effects", Vec2.new(0, 100), false) --[[@as SliderButton]]
        btn:setVal(tempConfig.audio.sfx)
        btn:setCallback(function(v) tempConfig.audio.sfx = v end)
        addToSettingsObjects(btn)

        btn = enumeratorButton.new("Pitched Hitmarker", {"Off", "On"}, "Increases hitmarker pitch closer to death.") --[[@as EnumeratorButton]]
        btn:setVal(tempConfig.audio.hitmarkers)
        btn:setCallback(function(v) tempConfig.audio.hitmarkers = v end)
        addToSettingsObjects(btn)

    elseif menu == SubMenus.Input then
        local inp = nil

        btn = sliderButton.new("Sensitivity", Vec2.new(0, 10), true) --[[@as SliderButton]]
        btn:setVal(tempConfig.input.lookSens)
        btn:setCallback(function(v) tempConfig.input.lookSens = v end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Forward") --[[@as InputButton]]
        inp = tempConfig.input.forward
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.forward = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Left") --[[@as InputButton]]
        inp = tempConfig.input.left
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.left = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Backward") --[[@as InputButton]]
        inp = tempConfig.input.backward
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.backward = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Right") --[[@as InputButton]]
        inp = tempConfig.input.right
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.right = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Jump") --[[@as InputButton]]
        inp = tempConfig.input.jump
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.jump = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Attack") --[[@as InputButton]]
        inp = tempConfig.input.attack
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.attack = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Aim") --[[@as InputButton]]
        inp = tempConfig.input.aim
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.aim = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Swap to Raygun") --[[@as InputButton]]
        inp = tempConfig.input.weapon_raygun
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.weapon_raygun = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Swap to RPG") --[[@as InputButton]]
        inp = tempConfig.input.weapon_rpg
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.weapon_rpg = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Swap to Railgun") --[[@as InputButton]]
        inp = tempConfig.input.weapon_railgun
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.weapon_railgun = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Perspective") --[[@as InputButton]]
        inp = tempConfig.input.perspective
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.perspective = {code, mouse} end)
        addToSettingsObjects(btn)

        btn = inputButton.new("Previous Weapon") --[[@as InputButton]]
        inp = tempConfig.input.previousWeapon
        btn:setVal(inputToString.ToString(inp[1], inp[2]))
        btn:setCallback(function(code, mouse) tempConfig.input.previousWeapon = {code, mouse}; Lime.log(tostring(code)) end)
        addToSettingsObjects(btn)

        spacing = 5
    end

    updateLayoutCurrentSettings = function()
            local yOffset = 0
            for i = 1, #currentSettings do
                currentSettings[i].container:parentTo(headerContainer)
                local x = headerContainer.size.x / 2 - currentSettings[i].container.size.x / 2

                if i == 1 then yOffset = 64 else
                    local prev = currentSettings[i-1].container.size.y
                    yOffset = yOffset + prev + spacing
                end
                local y = yOffset

                currentSettings[i].container.position = Vec2.new(x, y)
            end 
        end
    updateLayout()
end

---@param status boolean
local function onChangedStatus(status)
    headerContainer.visible = status
    backButton.visible = status
    applyButton.visible = status

    clearSettingsObjects()
    subMenu = -1
    
    if status then
        -- Shallow copy the GameManager config into a temp config.
        -- Options load from THAT table. Apply will set the GameManager config to the temp one.
        tempConfig = deepCopy(GameManager.config)
        selectSubmenu(SubMenus.Graphics)
        updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
        updateButtonsHook = Lime.onUpdate:hook(updateButtons)
    else
        tempConfig = {}
        updateLayoutHook:unhook()
        updateButtonsHook:unhook()
    end
end

function sl:init()
    -- Init header
    headerContainer = Image2D.new()
    headerContainer.size.x = 640
    headerContainer.size.y = 550
    -- headerContainer.border = true

    sl.canListen = true

    backButton = createButton("Back",  true)
    applyButton = createButton("Apply",  true)
    applyButton:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Center)

    Lime.Scene.preloadTexture("./content/assets/graphics/meter_outline.png")
    Lime.Scene.preloadTexture("./content/assets/graphics/meter_green.png")
    
    statChangeHook = self.onStatusChanged:hook(onChangedStatus)
    updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
    updateButtonsHook = Lime.onUpdate:hook(updateButtons)

    local hbNames = { "Visual", "Audio", "Input" }
    local gap = (headerContainer.size.x - #hbNames * 200) / (#hbNames + 1)
    for i = 1, #hbNames do
        local btn = createButton(hbNames[i])
        btn:parentTo(headerContainer)
        btn.position.x = (i - 1) * (200 + gap)
        headerButtons[i] = btn
        btn.onPressed:hook(function()
            selectSubmenu(i - 1)
        end)
    end

    backButton.onPressed:hook(function()
        if GameManager.state == GameState.Menu then
            local mainMenu = GameManager.level --[[@as Menu?]]
            if mainMenu then
                mainMenu:toSubMenu(MenuSubScreen.Main)
            end
        end
    end)

    applyButton.onPressed:hook(function()
        GameManager:applyConfig(tempConfig)
    end)

    updateLayout()
end

function sl:clean()
    headerContainer:destroy()
end

return sl