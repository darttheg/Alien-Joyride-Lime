---@class SliderButton
---@field init fun(self: SliderButton)
---@field value number
---@field title string
---@field range Vec2
---@field subtitle string
---@field titleText Text2D
---@field subtitleText Text2D
---@field valueText Text2D
---@field container Image2D
---@field meterOutline Image2D
---@field meterGreen Image2D
---@field callback function?
---@field hoverHook Hook
---@field index integer
---@field decimal boolean
---@field clean fun(self: SliderButton)
local btn = {}

---@param range Vec2
---@param val number
local function normalize(range, val)
    return (val - range.x) / (range.y - range.x)
end

---@param val number
function btn:setVal(val)
    self.value = normalize(self.range, val)
    self.value = math.max(0.0, math.min(1.0, self.value))
end

---@return number
function btn:getVal()
    return self.value
end

---@param func function
function btn:setCallback(func)
    self.callback = func
end

---@param title string
---@param range Vec2
---@param decimal boolean?
---@param subtitle string?
function btn.new(title, range, decimal, subtitle)
    local self = {}
    setmetatable(self, { __index = btn })

    self.value = 0.0

    self.decimal = decimal and decimal or false
    self.title = title
    self.subtitle = subtitle and subtitle or ""
    self.subtitleText = nil --[[@as Text2D]]
    self.titleText = nil --[[@as Text2D]]
    self.container = nil --[[@as Image2D]]
    self.range = range

    self.index = 0

    self.callback = nil --[[@as function]]

    self.valueText = nil --[[@as Text2D]]

    self.meterOutline = nil --[[@as Image2D]]
    self.meterGreen = nil --[[@as Image2D]]

    self.hoverHook = nil --[[@as Hook]]

    self:init()

    return self
end

local texOutline = nil --[[@as Texture]]
local texMeter = nil --[[@as Texture]]

---@param range Vec2
---@param a number
---@param decimal boolean?
local function valToRange(range, a, decimal)
    if not decimal then return math.floor(math.tween.lerp(range.x, range.y, a)) else return math.floor(math.tween.lerp(range.x, range.y, a) * 10.0) / 10.0 end
end

function btn:init()
    local thisObj = self

    self.container = Image2D.new()
    self.container.size = Vec2.new(400, 48)

    self.titleText = Text2D.new(self.title)
    self.titleText.size = Vec2.new(200, 32)
    self.titleText:setAlignment(Lime.Enum.TextAlign.Left, Lime.Enum.TextAlign.Center)

    self.subtitleText = Text2D.new(self.subtitle)
    self.subtitleText.size = Vec2.new(400, 16)
    self.subtitleText:setAlignment(Lime.Enum.TextAlign.Left, Lime.Enum.TextAlign.Bottom)
    self.subtitleText.position.y = self.container.size.y - 16

    self.valueText = Text2D.new(tostring(0))
    self.valueText.size = Vec2.new(64, 32)
    self.valueText.position.x = self.container.size.x - self.valueText.size.x
    self.valueText:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Center)

    texMeter = Texture.new("./content/assets/graphics/meter_green.png")
    self.meterGreen = Image2D.new(texMeter)
    self.meterGreen.position.x = self.container.size.x - self.meterGreen.size.x - self.valueText.size.x + 8
    self.meterGreen.position.y = 9

    texOutline = Texture.new("./content/assets/graphics/meter_outline.png")
    self.meterOutline = Image2D.new(texOutline)
    self.meterOutline.position.x = self.container.size.x - self.meterOutline.size.x - self.valueText.size.x + 8
    self.meterOutline.position.y = 9

    self.titleText:setFont(GameManager.fonts.futurespore.px32)
    self.valueText:setFont(GameManager.fonts.futurespore.px32)
    self.subtitleText:setFont(GameManager.fonts.verdana.px14)

    self.titleText:parentTo(self.container)
    self.subtitleText:parentTo(self.container)
    self.valueText:parentTo(self.container)
    self.meterGreen:parentTo(self.container)
    self.meterOutline:parentTo(self.container)

    self.hoverHook = Lime.onUpdate:hook(function()
        if thisObj.container:isHovered() then
            if Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Left) then
                local pos = thisObj.meterOutline:getAbsolutePosition()
                local x = Lime.Input.getMousePosition().x
                if x >= pos.x - 10 and x <= pos.x + thisObj.meterOutline.size.x + 10 then
                    local out = (x - pos.x) / (pos.x + thisObj.meterOutline.size.x - pos.x)
                    thisObj.value = math.max(0.0, math.min(1.0, out))

                    if thisObj.callback then thisObj.callback(valToRange(thisObj.range, thisObj.value, thisObj.decimal)) end
                end
            end

            thisObj.titleText.text = "<#CE67F7>" .. thisObj.title
            thisObj.valueText.text = "<#CE67F7>" .. tostring(valToRange(thisObj.range, thisObj.value, thisObj.decimal))
        else
            thisObj.titleText.text = thisObj.title
            thisObj.valueText.text = tostring(valToRange(thisObj.range, thisObj.value, thisObj.decimal))
        end

        thisObj.meterGreen.size.x = thisObj.meterOutline.size.x * thisObj.value
    end)
end

function btn:clean()
    self.titleText:destroy()
    self.subtitleText:destroy()
    self.valueText:destroy()
    self.meterOutline:destroy()
    self.meterGreen:destroy()
    self.container:destroy()

    self.hoverHook:unhook()
end

return btn