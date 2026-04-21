---@class PopUp
---@field text string
---@field callback function?
---@field textObj Text2D
---@field buttonObj BasicButton
---@field container Image2D
---@field updateLayoutHook Hook
---@field clean fun(self: PopUp)
local p = {}

local basicButton = require("content.scripts.objects.basicButton")

---@param func function
function p:setCallback(func)
    self.callback = func
end

---@param visible boolean
function p:setButtonVisible(visible)
    self.buttonObj.visible = visible
end

---@param text string
---@param callback function?
---@param subtitle string?
function p:setButtonParams(text, callback, subtitle)
    self.buttonObj.title = text
    self.buttonObj.callback = callback
    self.buttonObj.subtitle = subtitle or ""
end

---@param text string
function p.new(text)
    local self = {}
    setmetatable(self, { __index = p })
    
    self.text = text
    self.callback = nil --[[@as function]]
    self.textObj = nil --[[@as Text2D]]
    self.buttonObj = nil --[[@as BasicButton]]
    self.container = nil --[[@as Image2D]]

    self.updateLayoutHook = nil --[[@as Hook]]

    self:init()

    return self
end

function p:init()
    local thisObj = self
    local function updateLayout()
        thisObj.container.position.x = Lime.Window.getSize().x / 2 - thisObj.container.size.x / 2
        thisObj.container.position.y = Lime.Window.getSize().y / 2 * 0.85 - thisObj.container.size.y / 2

        thisObj.buttonObj.container.position.x = thisObj.container.size.x / 2 - thisObj.buttonObj.container.size.x / 2
        thisObj.buttonObj.container.position.y = thisObj.container.size.y * 0.85 - thisObj.buttonObj.container.size.y
    end

    local w = 400
    local h = 250

    self.container = Image2D.new()
    self.container.size = Vec2.new(w, h)
    self.updateLayoutHook = Lime.Window.onResize:hook(updateLayout)

    self.textObj = Text2D.new(self.text)
    self.textObj.size = Vec2.new(w, h * 0.5)
    self.textObj:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Center)

    self.buttonObj = basicButton.new("", "")
    self.buttonObj.container.visible = false

    self.textObj:setFont(GameManager.fonts.futurespore.px32)

    self.textObj:parentTo(self.container)
    self.buttonObj.container:parentTo(self.container)

    updateLayout()
end

function p:clean()
    self.textObj:destroy()
    self.buttonObj:clean()
    self.container:destroy()
    self.updateLayoutHook:unhook()
end

return p