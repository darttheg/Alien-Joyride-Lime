---@class HostInstance : Level

local Level = require("content.scripts.interfaces.level")
local l = Level.new() --[[@as HostInstance]]
setmetatable(l, { __index = Level })

function l:init()
    self:add(require(req.Sublevels.Planet), "planet")
end

function l:clean()
    
end

return l