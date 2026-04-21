---@class PlanetMap : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as PlanetMap]]
setmetatable(sl, { __index = Sublevel })

function sl:init()
    
end

function sl:clean()

end

return sl