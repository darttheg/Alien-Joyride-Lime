---@class LevelGraph : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as LevelGraph]]
setmetatable(sl, { __index = Sublevel })

---@type Text2D
local txt = nil --[[@as Text2D]]
---@type Hook
local h = nil --[[@as Hook]]

local function updateTree()
    if not GameManager or not txt then return end

    txt.text = ""

    local function addLine(t)
        if not txt then return end
        txt.text = txt.text .. t .. "\n<r>"
    end

    local tab = "    "

    addLine("<#CACACA>" .. "Level Tree")

    if GameManager.level then
        addLine("<#FF8138>" .. GameManager.level.id)

        local none = true
        for k, v in pairs(GameManager.level.sublevels) do
            local outColor = v._active and "<#FFD54C> " or "<#756223> "
            addLine(tab .. outColor .. v.id)
            none = false
        end

        if none then addLine( tab .. "<#947C2C> none") end
    end

    addLine("<#FF8138>dangling")

    local none = true
    for k, v in pairs(GameManager.sublevels) do
        local outColor = v._active and "<#FFD54C> " or "<#756223> "
        addLine(tab .. outColor .. v.id)
        none = false
    end

    if none then addLine("\t\t <#756223> none") end
end

function sl:init()
    if not Lime.Window.isCreated() then
        Lime.log("Could not create LevelGraph: prior to window init", Lime.Enum.PrintColor.Yellow)
        return
    end

    txt = Text2D.new()
    txt.position = Vec2.new(4)
    txt.size = Vec2.new(250, 480/1.2)
    txt.border = false
    -- txt:setFont(...)

    h = Lime.onUpdate:hook(updateTree)
end

function sl:clean()
    h:unhook()
    txt:destroy()
end

return sl