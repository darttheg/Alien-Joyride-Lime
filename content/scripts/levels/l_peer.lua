---@class PeerInstance : Level

local Level = require("content.scripts.interfaces.level")
local l = Level.new() --[[@as PeerInstance]]
setmetatable(l, { __index = Level })

local planet = nil --[[@as PlanetMap]]

function l:init()
    planet = require(req.Sublevels.Planet)
    self:add(planet, "planet")
end

function l:clean()
    planet = nil --[[@as PlanetMap]]
end

return l