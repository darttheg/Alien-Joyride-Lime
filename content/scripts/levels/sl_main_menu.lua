---@class MainMenuButtons : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as MainMenuButtons]]
setmetatable(sl, { __index = Sublevel })

local container = nil --[[@as Image2D]]
local buttons = {} --[[ @as Text2D[] ]]
local buttonText = { "Play", "Settings", "Quit" }

---@param text string
local function createButton(text)
    local btn = Text2D.new(text)
    btn:setAlignment(Lime.Enum.TextAlign.Center)
    btn.size = Vec2.new(256, 64)
    btn:setFont(GameManager.fonts.futurespore.px48)
    return btn
end

local function updateLayout()
    container.position.x = Lime.Window.getSize().x / 2 - container.size.x / 2
    container.position.y = Lime.Window.getSize().y / 2 + Lime.Window.getSize().y / 15.0
end

local function updateButtons()
    for i = 1, #buttons do
        local out = buttons[i] --[[@as Text2D]]
        if out:isHovered() then
            local color = "<#CE67F7>"
            if Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Left) then
                color = "<#68357C>"
            end
            out.text = color .. buttonText[i]
        else
            out.text = buttonText[i]
        end
    end
end

local function setButtonFunctionality()
    local play = buttons[1] --[[@as Text2D]]
    local settings = buttons[2] --[[@as Text2D]]
    local quit = buttons[3] --[[@as Text2D]]

    play.onPressed:hook(function()
        local mainMenu = GameManager.level --[[@as Menu?]]
        if mainMenu then
            mainMenu:toSubMenu(MenuSubScreen.Connect)
        end
    end)

    settings.onPressed:hook(function()
        local mainMenu = GameManager.level --[[@as Menu?]]
        if mainMenu then
            mainMenu:toSubMenu(MenuSubScreen.Settings)
        end
    end)
    
    quit.onPressed:hook(function()
        Lime.close()
    end)
end

-- Hooks
local updateLayoutHook = nil --[[@as Hook]]
local statusChangedHook = nil --[[@as Hook]]
local updateButtonsHook = nil --[[@as Hook]]

function sl:init()
    container = Image2D.new()
    container.size = Vec2.new(256, 350)

    for i = 1, #buttonText do
        local out = createButton(buttonText[i]) --[[@as Text2D]]
        out:parentTo(container)
        out.position.y = (i - 1) * out.size.y * 1.35
        buttons[i] = out
    end

    updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
    statusChangedHook = self.onStatusChanged:hook(function(active)
        container.visible = active
        if not active then updateButtonsHook:unhook() else updateButtonsHook = Lime.onUpdate:hook(updateButtons) end
    end)
    
    updateButtonsHook = Lime.onUpdate:hook(updateButtons)

    updateLayout()
    setButtonFunctionality()
end

function sl:clean()
    for i = 1, #buttons do
        local out = buttons[i] --[[@as Text2D]]
        out.onPressed:clear()
        out:destroy()
    end
    container:destroy()

    updateLayoutHook:unhook()
    statusChangedHook:unhook()
    updateButtonsHook:unhook()
end

return sl