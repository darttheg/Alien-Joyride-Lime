---@class InputButton
---@field init fun(self: InputButton)
---@field title string
---@field titleText Text2D
---@field inputVal string
---@field isMouse boolean
---@field inputText Text2D
---@field container Image2D
---@field callback function?
---@field hoverHook Hook
---@field pressHook Hook
---@field index integer
---@field clean fun(self: InputButton)
local btn = {}

---@param val string
---@param mouse boolean?
function btn:setVal(val, mouse)
    self.inputVal = val
    self.isMouse = mouse and mouse or false
end

---@return table<integer, boolean>
function btn:getVal()
    return { self.inputVal, self.isMouse }
end

---@param func function
function btn:setCallback(func)
    self.callback = func
end

---@param title string
function btn.new(title)
    local self = {}
    setmetatable(self, { __index = btn })

    self.title = title
    self.titleText = nil --[[@as Text2D]]
    self.inputVal = "?"
    self.isMouse = false
    self.inputText = nil --[[@as Text2D]]
    self.container = nil --[[@as Image2D]]
    self.index = 0

    self.callback = nil --[[@as function]]

    self.pressHook = nil --[[@as Hook]]
    self.hoverHook = nil --[[@as Hook]]

    self:init()

    return self
end

function btn:init()
    local thisObj = self

    self.container = Image2D.new()
    self.container.size = Vec2.new(400, 32)

    self.titleText = Text2D.new(self.title)
    self.titleText.size = Vec2.new(350, 32)
    self.titleText:setAlignment(Lime.Enum.TextAlign.Left, Lime.Enum.TextAlign.Center)

    self.inputText = Text2D.new(self.inputVal)
    self.inputText.size = Vec2.new(200, 32)
    self.inputText:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Center)
    self.inputText.position.x = self.container.size.x - self.inputText.size.x

    self.titleText:setFont(GameManager.fonts.futurespore.px32)
    self.inputText:setFont(GameManager.fonts.futurespore.px32)

    self.titleText:parentTo(self.container)
    self.inputText:parentTo(self.container)

    self.hoverHook = Lime.onUpdate:hook(function()
        local settings = GameManager:getSublevel("settings") --[[@as SettingsMenu]]
        
        if settings:getListening() then
            thisObj.titleText.text = "<#CE67F7>" .. thisObj.title
            thisObj.inputText.text = "<#CE67F7>" .. "..."
            return
        end
            

        if thisObj.container:isHovered() then
            thisObj.titleText.text = "<#CE67F7>" .. thisObj.title
            thisObj.inputText.text = "<#CE67F7>" .. thisObj.inputVal
        else
            thisObj.titleText.text = thisObj.title
            thisObj.inputText.text = thisObj.inputVal
        end
    end)

    self.pressHook = thisObj.container.onPressed:hook(function()
        local settings = GameManager:getSublevel("settings") --[[@as SettingsMenu]]
        if not settings:getListening() and not settings.canListen then settings.canListen = true; return end
        if settings:getListening() then return end
        settings:setListening(true, thisObj.index)
    end)
end

function btn:clean()
    self.titleText:destroy()
    self.inputText:destroy()
    self.container:destroy()

    self.hoverHook:unhook()
    self.pressHook:unhook()
end

return btn