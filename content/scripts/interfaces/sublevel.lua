--- Unlike `Level` objects, `Sublevels` are meant to be more reusable.
--- For example, a `Sublevel` would be a settings menu, whereas the main menu scene and controls would be a `Level`.
---@class Sublevel
---@field id string
---@field owner Level?
---@field onStatusChanged Event -- Fired when the status of this `Sublevel` is changed.
---@field _active boolean
local Sublevel = {}

--- Creates a new `Sublevel`.
---@return Sublevel
function Sublevel.new()
    ---@type Sublevel
    local self = {} --[[@as Sublevel]]
    setmetatable(self, { __index = Sublevel })

    self.id = "na_sublevel"
    self.owner = nil
    self._active = true
    self.onStatusChanged = Event.new()

    return self
end

--- Toggles the status of this `Sublevel`. `Sublevel.onStatusChanged` is then fired.
---@params status boolean
function Sublevel:setActive(status)
    if self._active == status then return end
    self._active = status
    self.onStatusChanged:run(self, self._active)
end

--- **Override!** Should be run once a `Sublevel` is created. `Levels` call this when using `Level:add`.
---@params ... any
function Sublevel:init(...)
    Lime.log("Sublevel " .. self.id .. " does not override Sublevel:init", Lime.Enum.PrintColor.Yellow)
end

--- **Override!** Cleans the content of this `Sublevel`. `Levels` call this when using `Level:remove` and `Level:clean`.
---@params ... any
function Sublevel:clean(...)
    Lime.log("Sublevel " .. self.id .. " does not override Sublevel:clean", Lime.Enum.PrintColor.Yellow)
end

return Sublevel