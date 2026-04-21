---@class Game : Manager
---@field init fun(self: Game) -- Initializes the game.
---@field clean fun(self: Game) -- Cleans up the game state for closure.
---@field applyConfig fun(self: Game, cfg: Config) -- Apply temporary config. Fires `onConfigChanged` Event.
---@field onConfigChanged Event -- Fires when game config is changed.
---@field fonts table<string, table<string, string>> -- Fonts, can be fetched using .name.pxsize
---@field state GameState -- Game state
---@field uiState UIState -- UI state
---@field config Config -- Game configuration table
---@field mpConfig MultiplayerConfig -- Multiplayer config table

local Manager = require("content.scripts.interfaces.manager")
local game = Manager.new() --[[@as Game]]
setmetatable(game, { __index = Manager })

local shuttleNaming = require("content.scripts.tools.shuttleNaming")

---

local function createMPConfig()
    local out = {} --[[@as MultiplayerConfig]]
    local p = {} --[[@as MPParams]]

    out.defaultAddress = "127.0.0.1:25565"
    out.username = shuttleNaming.generate()

    out.params = p
    return out
end

local function createConfig()
    local out = {} --[[@as Config]]

    local gfx = {} --[[@as ConfigGFX]]
    gfx.driver = 0 -- DX9
    gfx.fov = 100
    gfx.fps = 60
    gfx.vsync = 0
    gfx.chatbox = 1
    gfx.info = 0
    gfx.perspective = 0 -- First person

    local input = {} --[[@as ConfigInput]]
    local k = Lime.Enum.Key
    local m = Lime.Enum.Mouse
    input.lookSens = 5
    input.forward = { k.W, false }
    input.left = { k.A, false }
    input.backward = { k.S, false }
    input.right = { k.D, false }
    input.jump = { k.Space, false }
    input.attack = { m.Left, true }
    input.weapon_raygun = { k.Num1, false }
    input.weapon_rpg = { k.Num2, false }
    input.weapon_railgun = { k.Num3, false }
    input.aim = { m.Right, true }
    input.perspective = { k.R, false }
    input.previousWeapon = { k.Q, false }

    local audio = {} --[[@as ConfigAudio]]
    audio.master = 100
    audio.music = 100
    audio.sfx = 100
    audio.hitmarkers = 1

    out.gfx = gfx
    out.audio = audio
    out.input = input

    return out
end

local function createFonts()
    local fontDir = "./content/assets/fonts/"

    --- Loads a font, AA and no AA
    ---@param name string
    ---@param size number
    local function loadFont(name, size)
        local ok = Lime.GUI.loadTTF(fontDir .. name .. ".ttf", size, name .. "_" .. tostring(size) .. "px", true)
        if ok == "" then return false end
        if not GameManager.fonts[name] then GameManager.fonts[name] = {} end 
        GameManager.fonts[name]["px" .. tostring(size)] = ok
        return true
    end

    loadFont("verdana", 14)
    loadFont("futurespore", 24)
    loadFont("futurespore", 32)
    loadFont("futurespore", 48)

    Lime.GUI.setDefaultFont(GameManager.fonts.verdana.px14)
end

function game:init()
    self.config = {} --[[@as Config]]
    self.fonts = {}
    self.state = GameState.Menu
    self.uiState = UIState.MainMenu
    self.onConfigChanged = Event.new()

    if true then
        Lime.setDebugConfig(true, true)
        Lime.onStart:hook(function()
            local lvltree = require('content.scripts.levels.sl_leveltree')
            GameManager:add(lvltree, "d_leveltree")
            local info = require(req.Sublevels.DebugInfo)
            GameManager:add(info, "d_info")
        end)
    end

    -- Check mp config
    if not Lime.File.isFile("./config/multiplayer.cfg") then
        self.mpConfig = createMPConfig()
    else
        local out = json:decode(Lime.File.readFile("./config/multiplayer.cfg")) --[[@as MultiplayerConfig]]
        if not out then
            Lime.log("Problem decoding multiplayer configuration file...")
            Lime.displayMessage("Alien Joyride", "There was trouble reading multiplayer.cfg. Get your alien hands off the config file!", Lime.Enum.PopUpIcon.Warning)
            self.mpConfig = createMPConfig()
        else self.mpConfig = out end
    end

    -- Check settings, and if they don't exist, then create!
    if not Lime.File.isFile("./config/config.cfg") then
        self.config = createConfig()
    else
        local out = json:decode(Lime.File.readFile("./config/config.cfg")) --[[@as Config]]
        if not out then
            Lime.log("Problem decoding configuration file...")
            Lime.displayMessage("Alien Joyride", "There was trouble reading config.cfg. Get your alien hands off the config file!", Lime.Enum.PopUpIcon.Warning)
            self.config = createConfig()
        else self.config = out end
    end
    
    -- Set init config for Lime
    local s = Vec2.new(1024, 768)
    local driv = self.config.gfx.driver == 0 and Lime.Enum.DriverType.Direct3D9 or Lime.Enum.DriverType.OpenGL
    Lime.setInitConfig(driv, s)

    Lime.onStart:hook(function()
        -- Set window params
        Lime.Window.setTitle("Alien Joyride")
        Lime.Audio.setMuteWhileUnfocused(true)
        createFonts()
        GameManager:visit(require(req.Levels.Menu), "menu")
        GameManager:add(require(req.Sublevels.SettingsMenu), "settings")
        local settings = GameManager:getSublevel("settings")
        if settings then settings:setActive(false) end
    end)

    Lime.onClose:hook(function()
        Lime.File.writeFile("./config/config.cfg", json:encode(GameManager.config))
        Lime.File.writeFile("./config/multiplayer.cfg", json:encode(GameManager.mpConfig))
    end)

    Lime.onStart:hook(function()
        Lime.setFrameRate(self.config.gfx.fps)
        Lime.Audio.setMainVolume(self.config.audio.master)
        Lime.setVSync(self.config.gfx.vsync == 1)
    end)
    self.onConfigChanged:hook(function(cfg)
        ---@type Config
        local cfg= cfg
        
        Lime.setFrameRate(cfg.gfx.fps)
        Lime.Audio.setMainVolume(cfg.audio.master)
        Lime.setVSync(cfg.gfx.vsync == 1)
    end)
end

function game:clean()
end

---

---@param cfg Config
function game:applyConfig(cfg) -- Should only run post window creation
    if not self.config or not Lime.Window.isCreated() then return end

    self.config = cfg
    self.onConfigChanged:run(self.config)
end

return game