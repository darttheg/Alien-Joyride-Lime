---@class EnumeratorButton
---@field selected integer
---@field options table<integer, string>
---@field title string
---@field subtitle string
---@field container Image2D
---@field titleText Text2D
---@field subtitleText Text2D
---@field optionText Text2D
---@field hoverHook Hook
---@field pressHook Hook
---@field index integer
---@field callback function?
---@field clean fun(self: EnumeratorButton)
local btn = {}

---@param val integer
function btn:setVal(val)
    self.selected = val + 1
end

---@return integer
function btn:getVal()
    return self.selected - 1
end

---@param func function
function btn:setCallback(func)
    self.callback = func
end

---@param title string
---@param options string[]
---@param subtitle string?
function btn.new(title, options, subtitle)
    local self = {}
    setmetatable(self, { __index = btn })

    self.selected = 1
    self.options = options
    self.title = title
    self.subtitle = subtitle and subtitle or ""

    self.container = nil --[[@as Image2D]]
    self.titleText = nil --[[@as Text2D]]
    self.subtitleText = nil --[[@as Text2D]]
    self.optionText = nil --[[@as Text2D]]

    self.index = 0

    self.callback = nil --[[@as function]]

    self.hoverHook = nil --[[@as Hook]]
    self.pressHook = nil --[[@as Hook]]

    self:init()

    return self
end

function btn:init()
    local thisObj = self

    self.container = Image2D.new()
    self.container.size = Vec2.new(400, 48)

    self.titleText = Text2D.new(self.title)
    self.titleText.size = Vec2.new(300, 32)
    self.titleText:setAlignment(Lime.Enum.TextAlign.Left, Lime.Enum.TextAlign.Center)

    self.subtitleText = Text2D.new(self.subtitle)
    self.subtitleText.size = Vec2.new(400, 16)
    self.subtitleText:setAlignment(Lime.Enum.TextAlign.Left, Lime.Enum.TextAlign.Bottom)

    self.optionText = Text2D.new(self.options[self.selected])
    self.optionText.size = Vec2.new(200, 32)
    self.optionText:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Center)

    self.titleText:setFont(GameManager.fonts.futurespore.px32)
    self.subtitleText:setFont(GameManager.fonts.verdana.px14)
    self.optionText:setFont(GameManager.fonts.futurespore.px32)

    self.titleText:parentTo(self.container)
    self.subtitleText:parentTo(self.container)
    self.optionText:parentTo(self.container)

    self.titleText.position.x = 0
    self.optionText.position.x = self.container.size.x - self.optionText.size.x
    self.subtitleText.position.y = self.container.size.y - 16

    self.hoverHook = Lime.onUpdate:hook(function()
        if thisObj.container:isHovered() then
            thisObj.optionText.text = "<#CE67F7>" .. thisObj.options[thisObj.selected]
            thisObj.titleText.text = "<#CE67F7>" .. thisObj.title
        else
            thisObj.optionText.text = thisObj.options[thisObj.selected]
            thisObj.titleText.text = thisObj.title
        end
    end)

    self.pressHook = self.container.onPressed:hook(function()
        thisObj.selected = thisObj.selected + 1
        if thisObj.selected > #thisObj.options then thisObj.selected = 1 end

        if thisObj.callback then thisObj.callback(thisObj.selected - 1) end
    end)
end

function btn:clean()
    self.titleText:destroy()
    self.subtitleText:destroy()
    self.optionText:destroy()
    self.container:destroy()

    self.hoverHook:unhook()
    self.pressHook:unhook()
end

return btn