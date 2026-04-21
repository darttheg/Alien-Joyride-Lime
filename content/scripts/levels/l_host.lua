---@class Host : Level

local Level = require("content.scripts.interfaces.level")
local l = Level.new() --[[@as Host]]
setmetatable(l, { __index = Level })

function l:init()
    
end

function l:clean()
    
end

return l