---@class TestSublevel : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as TestSublevel]]
setmetatable(sl, { __index = Sublevel })

function sl:init()
end

function sl:clean()
end

return sl