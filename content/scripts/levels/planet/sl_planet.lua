---@class PlanetMap : Sublevel

local Sublevel = require("content.scripts.interfaces.sublevel")
local sl = Sublevel.new() --[[@as PlanetMap]]
setmetatable(sl, { __index = Sublevel })

local objs = {}

local function pushToObjs(obj, col)
    objs[#objs + 1] = obj
    if col then obj.collision = true end
end

local sky = nil --[[@as Skydome]]
local planetBase = nil --[[@as Mesh]]
local planetWalls = nil --[[@as Mesh]]
local planetObstacles = nil --[[@as Mesh]]
local planetWallDecor = nil --[[@as Mesh]]
local planetArcades = nil --[[@as Mesh]]
local spinnyPlanet = nil --[[@as Mesh]]
local spinnyRings = nil --[[@as Mesh]]
local ufos = nil --[[@as Mesh]]
local sun = nil --[[@as Light]]
local rocket = nil --[[@as Empty]] --(Empty + Rocket)

local song = nil --[[@as Sound]]
local songHook = nil --[[@as Hook]]

local movementHook = nil --[[@as Hook]]

local dir = "./content/assets/planet/"

---@param mesh Mesh
---@param srcMat Material
---@param txPaths string[]
local function applyMaterials(mesh, srcMat, txPaths)
    for i = 1, #txPaths do
        srcMat:loadTexture(Texture.new(dir .. "textures/" .. txPaths[i] .. ".png"))
        Lime.log(dir .. "textures/" .. txPaths[i] .. ".png")
        mesh:loadMaterial(srcMat, i - 1)
    end
end

local function createPlanet()
    local baseMat = Material.new()
    baseMat.fog = false
    baseMat.lighting = true
    baseMat.type = Lime.Enum.MaterialType.Solid

    planetBase = Mesh.new(dir .. "planet_base.obj")
    applyMaterials(planetBase, baseMat, {"comb", "center", "brick", "metal"})
    pushToObjs(planetBase, true)

    planetWalls = Mesh.new(dir .. "planet_walls.obj")
    applyMaterials(planetWalls, baseMat, {"metal"})
    pushToObjs(planetWalls, true)

    planetObstacles = Mesh.new(dir .. "planet_obby.obj")
    applyMaterials(planetObstacles, baseMat, {"obstacle", "halfpipe", "container"})
    pushToObjs(planetObstacles, true)

    baseMat.type = Lime.Enum.MaterialType.ReflectMap
    baseMat:loadTexture(Texture.new(dir .. "textures/weirdwarp.png"))
    baseMat:loadTexture(Texture.new(dir .. "textures/weirdwarp.png"), 1)
    planetWallDecor = Mesh.new(dir .. "wall_decor.obj")
    planetWallDecor:loadMaterial(baseMat)
    pushToObjs(planetWallDecor, true)

    spinnyRings = Mesh.new(dir .. "rings.obj")
    baseMat:loadTexture(Texture.new(dir .. "textures/metal.png"))
    baseMat:loadTexture(Texture.new(dir .. "textures/metal.png"), 1)
    spinnyRings:loadMaterial(baseMat)
    spinnyRings:addRotateAnimator(Vec3.new(0,3.5,0))
    pushToObjs(spinnyRings, true)

    planetArcades = Mesh.new(dir .. "arcades.obj")
    baseMat:loadTexture(Texture.new(dir .. "textures/goldwarp.png"))
    baseMat:loadTexture(Texture.new(dir .. "textures/goldwarp.png"), 1)
    planetArcades:loadMaterial(baseMat)
    pushToObjs(planetArcades, true)

    spinnyPlanet = Mesh.new(dir .. "planetoid.obj")
    spinnyPlanet:loadMaterial(baseMat)
    spinnyPlanet.position.y = 28.82
    spinnyPlanet:addRotateAnimator(Vec3.new(0,10,0))
    pushToObjs(spinnyPlanet, true)

    ufos = Mesh.new(dir .. "ufos.obj")
    ufos:loadMaterial(baseMat)
    ufos:addRotateAnimator(Vec3.new(0,-18.5,0))
    pushToObjs(ufos, true)

    local m_rocket = Mesh.new(dir .. "rocket.obj")
    m_rocket:loadMaterial(baseMat)
    m_rocket.position.x = -32
    rocket = Empty.new()
    m_rocket:parentTo(rocket)
    m_rocket:addRotateAnimator(Vec3.new(0,0,9))
    rocket:addRotateAnimator(Vec3.new(0,-6,0))
    pushToObjs(m_rocket, true)
    pushToObjs(rocket)

    movementHook = Lime.onUpdate:hook(function(dt)
        ufos.position.y = math.sin(Lime.getElapsedTime() / 300) * 0.3
        spinnyRings.position.y = math.cos(Lime.getElapsedTime() / 2500) * 0.3 + 11.0
        rocket.position.y = math.sin(Lime.getElapsedTime() / 2500) * 0.5 + 17.0
    end)
end

function sl:init()
    local mat = Material.new(Texture.new(dir .. "textures/sky_warp.png"))
    sky = Skydome.new(mat)

    local c = require("content.scripts.objects.FreeCamera")
    c:setActive()
    c.camera.position = Vec3.new(0,10,-50)
    c.camera.rotation.x = 10

    Lime.Scene.setAmbientColor(Vec4.new(255 * 0.5, 255 * 0.9, 240 * 0.9, 255))
    sun = Light.new(Lime.Enum.LightType.Directional)
    sun.ambientColor = Vec4.new(255,0,0,255)
    sun.position = Vec3.new(0,25,0)

    createPlanet()

    song = Sound.new("./content/assets/sound/planet_theme.mp3", Lime.Enum.SoundType.Stream)
    song.looping = true
    song.volume = GameManager.config.audio.music
    song:play()

    songHook = GameManager.onConfigChanged:hook(function()
        song.volume = GameManager.config.audio.music
    end)
end

function sl:clean()
    songHook:unhook()
    movementHook:unhook()

    song:destroy()
    sun:destroy()
    sky:destroy()

    for i = 1, #objs do
        objs[i]:destroy()
    end
end

return sl