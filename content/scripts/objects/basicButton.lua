---@class BasicButton
---@field title string
---@field subtitle string
---@field container Image2D
---@field titleText Text2D
---@field subtitleText Text2D
---@field hoverHook Hook
---@field pressHook Hook
---@field callback function?
---@field clean fun(self: BasicButton)
local btn = {}

---@param func function
function btn:setCallback(func)
    self.callback = func
end

---@param title string
---@param subtitle string?
function btn.new(title, subtitle)
    local self = {}
    setmetatable(self, { __index = btn })

    self.title = title
    self.subtitle = subtitle or ""

    self.container = nil --[[@as Image2D]]
    self.titleText = nil --[[@as Text2D]]
    self.subtitleText = nil --[[@as Text2D]]

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
    self.titleText.size = Vec2.new(400, 32)
    self.titleText:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Center)

    self.subtitleText = Text2D.new(self.subtitle)
        self.subtitleText.size = Vec2.new(400, 16)
        self.subtitleText:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Bottom)

    self.titleText:setFont(GameManager.fonts.futurespore.px32)
    self.subtitleText:setFont(GameManager.fonts.verdana.px14)

    self.titleText:parentTo(self.container)
    self.subtitleText:parentTo(self.container)

    self.titleText.position.x = 0
    self.subtitleText.position.y = self.container.size.y - 16

    self.hoverHook = Lime.onUpdate:hook(function()
        if thisObj.container:isHovered() then
            local color = "<#CE67F7>"
            if Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Left) then
                color = "<#68357C>"
            end
            thisObj.titleText.text = color .. thisObj.title
        else
            thisObj.titleText.text = thisObj.title
        end

        thisObj.subtitleText.text = thisObj.subtitle or ""
    end)

    self.pressHook = self.container.onPressed:hook(function()
        if thisObj.callback then thisObj.callback() end
    end)
end

function btn:clean()
    self.titleText:destroy()
    self.subtitleText:destroy()
    self.container:destroy()

    self.hoverHook:unhook()
    self.pressHook:unhook()
end

return btn