---@class Menu : Level
---@field showSettings fun(self: Game, visible: boolean) -- Use to change settings menu visibility in the main menu.

local Level = require("content.scripts.interfaces.level")
local l = Level.new() --[[@as Menu]]
setmetatable(l, { __index = Level })

local src = "./content/assets/graphics/"
local logoTex = Texture.new(src .. "logo.png")
local skyTex = Texture.new(src .. "bg.png")
local logo = nil --[[@as Image2D]]
local cred = nil --[[@as Text2D]]
local skydome = nil --[[@as Skydome]]
local camera = nil --[[@as Camera]]
local menuSong = nil --[[@as Sound]]

-- Functionality
local logoTimer = 0.0

-- Hooks
local updateLayoutHook = nil --[[@as Hook]]
local updateLogoYHook = nil --[[@as Hook]]
local onConfigChangedHook = nil --[[@as Hook]]

local function updateLayout()
    logo.position.x = Lime.Window.getSize().x / 2 - logo.size.x / 2

    cred.position.x = Lime.Window.getSize().x - 4 - cred.size.x
    cred.position.y = Lime.Window.getSize().y - 4 - cred.size.y
end

local logoTween = 0.0

---@param dt number
local function updateLogoY(dt)
    local out = Lime.Window.getSize().y / 3.5 - logo.size.y / 2
    logoTimer = logoTimer + dt
    out = out + math.cos(logoTimer / 0.25) * 3.5
    logoTween = math.min(logoTween + dt * 0.3, 1.0)

    local tweened = math.tween.lerp(logo.size.y, out, math.tween.easeOutElastic(logoTween))

    logo.position.y = tweened

    camera.rotation.y = camera.rotation.y + dt * 3.0
end

function l:init()
    logo = Image2D.new(logoTex)

    updateLogoYHook = Lime.onUpdate:hook(updateLogoY)

    cred = Text2D.new()
    cred:setAlignment(Lime.Enum.TextAlign.Right, Lime.Enum.TextAlign.Bottom)
    cred.text = VERSION .. "\nBy DaRydenW and Mechlus\nMusic by ROXYY\nMade in <#77E955>Lime Engine"
    cred.size = Vec2.new(400, 84)
    cred:setFont(GameManager.fonts.futurespore.px24)

    skydome = Skydome.new(Material.new(skyTex))
    camera = Camera.new()
    camera.fieldOfView = GameManager.config.gfx.fov

    updateLayoutHook = Lime.Window.onResize:hook(updateLayout)
    updateLayout()

    menuSong = Sound.new("./content/assets/sound/menu.mp3", Lime.Enum.SoundType.Stream)
    menuSong.looping = true
    menuSong.volume = GameManager.config.audio.music
    menuSong:play()

    onConfigChangedHook = GameManager.onConfigChanged:hook(function(cfg)
        ---@type Config
        local cfg = cfg
        menuSong.volume = cfg.audio.music

        camera.fieldOfView = cfg.gfx.fov
    end)

    GameManager.onConfigChanged:hook(function()
        menuSong.volume = GameManager.config.audio.music
    end)

    self:add(require(req.Sublevels.MainMenuButtons), "main_buttons")
end

function l:showSettings(show)
    local settings = GameManager:getSublevel("settings") --[[@as SettingsMenu]]
    local menuButtons = self:getSublevel("main_buttons") --[[@as MainMenuButtons]]
    if settings and settings._active ~= show then
        settings:setActive(show)
        menuButtons:setActive(not show)
        logo.visible = not show
        cred.visible = not show
    end
end

function l:clean()
    logo:destroy()
    cred:destroy()
    camera:destroy()
    skydome:destroy()

    updateLogoYHook:unhook()
    updateLayoutHook:unhook()
    onConfigChangedHook:unhook()

    skyTex:purge()
    logoTex:purge()
end

return l