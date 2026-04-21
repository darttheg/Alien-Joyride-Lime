local shuttleNaming = require("content.scripts.tools.shuttleNaming")
---@class EditBoxButton
---@field title string
---@field defaultText string
---@field container Image2D
---@field titleText Text2D
---@field editText Text2D
---@field typeBox EditBox
---@field hoverHook Hook
---@field unfocusOnClickHook Hook
---@field pressHook Hook
---@field isFocused boolean
---@field maxLen integer
---@field callback function?
---@field clean fun(self: BasicButton)
local btn = {}

---@param val string
function btn:setVal(val)
    self.typeBox.text = val
end

---@return string
function btn:getVal()
    return self.typeBox.text
end

---@param func function
function btn:setCallback(func)
    self.callback = func
end

---@param title string
---@param defaultText string
---@param maxLen integer?
function btn.new(title, defaultText, maxLen)
    local self = {}
    setmetatable(self, { __index = btn })

    self.title = title
    self.defaultText = defaultText

    self.maxLen = maxLen or 99

    self.container = nil --[[@as Image2D]]
    self.titleText = nil --[[@as Text2D]]
    self.editText = nil --[[@as Text2D]]
    self.typeBox = nil --[[@as EditBox]]
    
    self.isFocused = false

    self.callback = nil --[[@as function?]]

    self.hoverHook = nil --[[@as Hook]]
    self.pressHook = nil --[[@as Hook]]
    self.unfocusOnClickHook = nil --[[@as Hook]]

    self:init()

    return self
end

function btn:init()
    local thisObj = self

    self.container = Image2D.new()
    self.container.size = Vec2.new(400, 55)

    self.titleText = Text2D.new(self.title)
    self.titleText.size = Vec2.new(400, 32)
    self.titleText:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Center)

    self.editText = Text2D.new(self.defaultText)
    self.editText.size = Vec2.new(400, 32)
    self.editText:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Center)

    self.typeBox = EditBox.new(self.defaultText)
    self.typeBox.size = Vec2.new(400, 32)
    self.typeBox:setAlignment(Lime.Enum.TextAlign.Center, Lime.Enum.TextAlign.Center)

    self.titleText:setFont(GameManager.fonts.futurespore.px32)
    self.editText:setFont(GameManager.fonts.verdana.px14)

    self.titleText:parentTo(self.container)
    self.editText:parentTo(self.container)

    self.titleText.position.x = 0
    self.typeBox.position.y = -self.typeBox.size.y
    self.editText.position.y = self.container.size.y - self.typeBox.size.y

    self.typeBox.multiLine = false
    self.typeBox.wordWrap = false
    self.typeBox.maxChars = self.maxLen
    self.typeBox.cursorPosition = self.maxLen + 1

    ---@param txt string
    ---@param pos integer
    local function addSplitter(txt, pos)
        -- local doAdd = math.floor(Lime.getElapsedTime() / 500) % 2 == 0
        -- if not doAdd then return txt end

        return txt:sub(1, pos) .. "|" .. txt:sub(pos + 1)
    end

    self.unfocusOnClickHook = Lime.Input.onMouseButtonPressed:hook(function(button)
        if button == Lime.Enum.Mouse.Left and thisObj.isFocused and not thisObj.container:isHovered() then
            thisObj.isFocused = false
        end
    end)

    self.hoverHook = Lime.onUpdate:hook(function()
        -- if not thisObj.container:isHovered() then thisObj.isFocused = false end

        local stripped = shuttleNaming.stripColors(thisObj.typeBox.text)
        if stripped ~= thisObj.typeBox.text then
            thisObj.typeBox.cursorPosition = thisObj.typeBox.cursorPosition - (#thisObj.typeBox.text - #stripped)
            thisObj.typeBox.text = stripped
        end

        if thisObj.isFocused then
            thisObj.titleText.text = "<#CE67F7>" .. thisObj.title
            thisObj.editText.text = "<#FFFFFF>" .. addSplitter(thisObj.typeBox.text, thisObj.typeBox.cursorPosition)

            if thisObj.callback then thisObj.callback(thisObj:getVal()) end
            return
        end

        if thisObj.container:isHovered() then
            local color = "<#CE67F7>"
            if not thisObj.typeBox.focused and Lime.Input.isMouseButtonDown(Lime.Enum.Mouse.Left) then
                color = "<#68357C>"
            end
            thisObj.titleText.text = color .. thisObj.title
            thisObj.editText.text = color .. thisObj.typeBox.text
        else
            thisObj.titleText.text = thisObj.title
            thisObj.editText.text = thisObj.typeBox.text
        end
    end)

    self.pressHook = self.container.onPressed:hook(function()
        -- Focus hidden editbox for typing
        if thisObj.isFocused then thisObj.typeBox.focused = true return end
        if not thisObj.typeBox.focused then
            thisObj.typeBox.focused = true
            thisObj.isFocused = true
        end
    end)
end

function btn:clean()
    self.titleText:destroy()
    self.typeBox:destroy()
    self.editText:destroy()
    self.container:destroy()

    self.unfocusOnClickHook:unhook()
    self.hoverHook:unhook()
    self.pressHook:unhook()
end

return btn