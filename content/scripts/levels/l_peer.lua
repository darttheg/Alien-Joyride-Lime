---@class PeerInstance : Level

local Level = require("content.scripts.interfaces.level")
local l = Level.new() --[[@as PeerInstance]]
setmetatable(l, { __index = Level })

function l:init()
    
end

function l:clean()
    
end

return l