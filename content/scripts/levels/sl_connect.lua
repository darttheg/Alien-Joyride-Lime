---@class ConnectMenu : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as ConnectMenu]]
setmetatable(sl, { __index = Sublevel })

local enumeratorButton = require("content.scripts.objects.enumeratorButton")
local sliderButton = require("content.scripts.objects.sliderButton")
local inputButton = require("content.scripts.objects.inputButton")
local basicbutton = require("content.scripts.objects.basicButton")
local typeButton = require("content.scripts.objects.editBoxButton")

local shuttleNaming = require("content.scripts.tools.shuttleNaming")

---@enum SubMenus
local SubMenus = {
    Connect = 0,
    Host = 1
}

local subMenu = -1
local headerContainer = nil --[[@as Image2D]]
local backButton = nil --[[@as Text2D]]
local headerButtons = {} --[[ @as Text2D[] ]]
local currentSettings = {}
local updateLayoutCurrentSettings = nil --[[@as function?]]

local updateLayoutHook = nil --[[@as Hook]]
local updateButtonsHook = nil --[[@as Hook]]
local statChangeHook = nil --[[@as Hook]]

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

local function updateLayout()
    headerContainer.position.x = Lime.Window.getSize().x / 2 - headerContainer.size.x / 2
    headerContainer.position.y = Lime.Window.getSize().y / 2 - headerContainer.size.y / 2

    backButton.position.x = headerContainer.position.x - backButton.size.x
    backButton.position.y = headerContainer.position.y - backButton.size.y

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
    local hbNames = { "Connect", "Host" }

    backButton.text = "Back"
    if backButton:isHovered() then backButton.text = "<#CE67F7>" .. "Back" end

    for i = 1, #headerButtons do
        local out = headerButtons[i] --[[@as Text2D]]
        if out:isHovered() and i - 1 ~= subMenu then
            out.text = "<#CE67F7>" .. hbNames[i]
        elseif i - 1 == subMenu then
            out.text = "<#68357C>" .. hbNames[i]
        else
            out.text = hbNames[i]
        end
    end
end

---@param menu SubMenus
local function selectSubmenu(menu)
    if subMenu == menu then return end
    subMenu = menu
    clearSettingsObjects()

    local spacing = 20
    local btn = nil
    if menu == SubMenus.Connect then
        local addy = nil
        local namer = nil
        local connector = nil
        
        if #GameManager.mpConfig.defaultAddress == 0 then GameManager.mpConfig.defaultAddress = "127.0.0.1:25565" end
        btn = typeButton.new("Server Address", GameManager.mpConfig.defaultAddress, 40) --[[@as EditBoxButton]]
        btn:setCallback(function(out)
            GameManager.mpConfig.defaultAddress = out
        end)
        addToSettingsObjects(btn)
        addy = btn

        if #GameManager.mpConfig.username == 0 then GameManager.mpConfig.username = shuttleNaming.generate() end
        btn = typeButton.new("Alien Name", GameManager.mpConfig.username, 25) --[[@as EditBoxButton]]
        btn:setCallback(function(out)
            GameManager.mpConfig.username = out
        end)
        addToSettingsObjects(btn)
        namer = btn

        btn = basicbutton.new("Connect") --[[@as BasicButton]]
        connector = btn
        btn:setCallback(function()
            if not shuttleNaming.isValidAddress(addy.editText.text) then
                connector.subtitle = "<#E75050>Server address is not valid!"
                return
            else
                connector.subtitle = ""
            end

            if not shuttleNaming.isAllowed(namer.editText.text) then
                connector.subtitle = "<#E75050>Name contains illegal characters!"
                return
            else
                connector.subtitle = ""
            end
        end)
        addToSettingsObjects(btn)

    elseif menu == SubMenus.Host then

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

    clearSettingsObjects()
    subMenu = -1
    
    if status then
        selectSubmenu(SubMenus.Connect)
        updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
        updateButtonsHook = Lime.onUpdate:hook(updateButtons)
    else
        updateLayoutHook:unhook()
        updateButtonsHook:unhook()
    end
end

function sl:init()
    headerContainer = Image2D.new()
    headerContainer.size.x = 640
    headerContainer.size.y = 550
    -- headerContainer.border = true

    backButton = createButton("Back",  true)

    updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
    updateButtonsHook = Lime.onUpdate:hook(updateButtons)
    statChangeHook = self.onStatusChanged:hook(onChangedStatus)

    local hbNames = { "Connect", "Host" }
    local gap = (headerContainer.size.x - #hbNames * 200) / (#hbNames + 1)
    for i = 1, #hbNames do
        local btn = createButton(hbNames[i])
        btn:parentTo(headerContainer)
        btn.position.x = gap + (i - 1) * (200 + gap)
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

    updateLayout()
end

function sl:clean()
    backButton:destroy()

    for i = 1, #headerButtons do
        local cur = headerButtons[i] --[[@as Text2D]]
        cur:destroy()
    end

    headerContainer:destroy()

    updateLayoutHook:unhook()
    updateButtonsHook:unhook()
    statChangeHook:unhook()
end

return sl