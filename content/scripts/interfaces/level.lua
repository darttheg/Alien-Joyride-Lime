--- A root for objects and `Sublevels`. A `Level` is like the main menu controller, not the individual screens.
---@class Level
---@field id string
---@field sublevels table<string, Sublevel?>
local Level = {}

--- Creates a new `Level`.
---@return Level
function Level.new()
    ---@type Level
    local self = {}
    setmetatable(self, { __index = Level })

    self.id = "na_level"
    self.sublevels = {}

    return self
end

--- Adds a `Sublevel` to this `Level`. The `Sublevel:init` function will be called.
---@param sublevel Sublevel
---@param id string
---@param ... any
function Level:add(sublevel, id, ...)
    if self.sublevels[id] then
        Lime.log("Sublevel " .. id .. " already exists under Level " .. self.id .. "!", Lime.Enum.PrintColor.Yellow)
        self:remove(id)
    end

    self.sublevels[id] = sublevel
    sublevel.id = id
    sublevel.owner = self
    sublevel:init(...)
end

--- Removes a `Sublevel` by id after calling its clean method.
---@param id string
---@param ... any
function Level:remove(id, ...)
    if not self.sublevels[id] then return end
    self.sublevels[id]:clean(...)
    self.sublevels[id] = nil
end

--- Destroys the content of this `Level` and destroys all child `Sublevels`.
---@param ... any
function Level:destroy(...)
    for k, _ in pairs(self.sublevels) do
        self:remove(k, ...)
    end
    self.sublevels = {}
    setmetatable(self, nil)
end

--- Returns the `Sublevel` matching the provided `id`, nil if not found.
---@param id string
function Level:getSublevel(id)
    for k, v in pairs(self.sublevels) do
        if k == id then return v end
    end
    return nil
end

-- To Override

--- **Override!** Runs when this `Level` is first created.
---@params ... any
function Level:init(...)
    Lime.log("Level " .. self.id .. " does not override Level:init", Lime.Enum.PrintColor.Yellow)
end

--- **Override!** Cleans this `Level`. This function should be called before destroying this `Level`.
---@params ... any
function Level:clean(...)
    Lime.log("Level " .. self.id .. " does not override Level:clean", Lime.Enum.PrintColor.Yellow)
end

return Level