---@class DebugInfo : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as DebugInfo]]
setmetatable(sl, { __index = Sublevel })

---@type Text2D
local txt = nil --[[@as Text2D]]

---@type Hook
local h = nil --[[@as Hook]]
---@type Hook
local hu = nil --[[@as Hook]]

local function updatePos()
    if not txt then return end
    txt.position.x = Lime.Window.getSize().x - txt.size.x - 4
    txt.position.y = 4
end

local function updateTxt()
    txt.text = ""
    local first = true

    local function addLine(tx)
        local thing = "\n<r>"
        if first then thing = ""; first = false end
        txt.text = txt.text .. thing .. tx
    end

    addLine("<#CE67F7>Alien Joyride <r>" .. VERSION)
    addLine("<#ADF767>Lime <r>" .. Lime.getVersion())

    local m = Lime.getMemoryUsage()
    local mem = ""
    if m >= 600 then
        mem = "<#FF665C>" .. tostring(m)
    elseif m >= 400 then
        mem = "<#FFA162>" .. tostring(m)
    elseif m >= 250 then
        mem = "<#FFE489>" .. tostring(m)
    else
        mem = "<#FFFFFF>" .. tostring(m)
    end
    mem = mem .. "<r> mb"

    local d = Lime.getDriverType()
    local driver = ""
    if d == Lime.Enum.DriverType.Direct3D9 then
        driver = "Direct3D9"
    elseif d == Lime.Enum.DriverType.OpenGL then
        driver = "OpenGL"
    else
        driver = "Unknown"
    end

    local fps = Lime.getFrameRate() .. " fps"

    addLine(driver)
    addLine(fps)
    addLine(mem)
end

function sl:init()
    txt = Text2D.new()
    txt.size.x = Lime.Window.getSize().x * 0.5
    txt.size.y = Lime.Window.getSize().y * 0.5
    txt:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Top)
    h = Lime.Window.onResize:hook(updatePos)
    hu = Lime.onUpdate:hook(updateTxt)
    updatePos()
end

function sl:clean()
    h:unhook()
    hu:unhook()
    txt:destroy()
end

return sl