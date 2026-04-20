--- `Managers` are the top-most level in applications, controlling not just `Levels` and their `Sublevels`, but everything in the application.
---@class Manager
---@field level Level?
---@field sublevels table<string, Sublevel?>
---@field init fun(self: Manager) -- Initializes this `Manager`.
---@field clean fun(self: Manager) -- Cleans this `Manager`.
---@field onLevelsChanged Event -- Fires when a `Level` or dangling `Sublevel` is added or removed from this `Manager`.
local Manager = {}

--- Creates a new `Manager`.
---@return Manager
function Manager.new()
    ---@type Manager
    local self = {} --[[@as Manager]]
    setmetatable(self, { __index = Manager })

    self.level = nil
    self.sublevels = {}
    self.onLevelsChanged = Event.new()

    return self
end

--- Transitions to a new `Level`.
---@param level Level
---@param id string
---@param ... any
function Manager:visit(level, id, ...)
    if self.level then
        Lime.log("Manager should not be cleaning the current level. (" .. self.level.id .. ")", Lime.Enum.PrintColor.Yellow)
        self.level:clean() -- Manager should NOT have to account for cleaning the current level, but it does so anyway just in case.
    end

    self.level = level
    self.level.id = id
    self.level:init(...)
    self.onLevelsChanged:run()
end

--- Adds a dangling `Sublevel` to this `Manager`. The `Sublevel:init` function will be called.
---@param sublevel Sublevel
---@param id string
---@param ... any
function Manager:add(sublevel, id, ...)
    if self.sublevels[id] then
        Lime.log("Dangling Sublevel " .. id .. " already exists!", Lime.Enum.PrintColor.Yellow)
        self:remove(id)
    end

    self.sublevels[id] = sublevel
    sublevel.id = id
    sublevel.owner = nil
    sublevel:init(...)
    self.onLevelsChanged:run()
end

--- Removes a `Sublevel` by id after calling its clean method.
---@param id string
---@param ... any
function Manager:remove(id, ...)
    if not self.sublevels[id] then return end
    self.sublevels[id]:clean(...)
    self.sublevels[id] = nil
    self.onLevelsChanged:run()
end

--- Returns the `Sublevel` matching the provided `id`, nil if not found.
---@param id string
function Manager:getSublevel(id)
    for k, v in pairs(self.sublevels) do
        if k == id then return v end
    end
    return nil
end

--- **Override!** Initializes this `Manager`.
function Manager:init()
end

--- **Override!** Cleans up this `Manager`, typically marking the end of the application's life.
function Manager:clean()
end

return Manager