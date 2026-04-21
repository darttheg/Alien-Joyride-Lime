---@enum GameState
GameState = {
    Menu = 0,
    Play = 1
}

---@enum UIState
UIState = {
    MainMenu = 0,
    Settings = 1,
    ServerScreen = 2,
    Paused = 3,
    Chat = 4
}

---@class ConfigGFX
---@field driver integer
---@field fov number
---@field fps integer
---@field vsync integer
---@field perspective integer
---@field chatbox integer
---@field info integer

---@class ConfigAudio
---@field master integer
---@field music integer
---@field sfx integer
---@field hitmarkers integer

---@class ConfigInput
---@field lookSens number
---@field forward { [1]: integer, [2]: boolean }
---@field left { [1]: integer, [2]: boolean }
---@field backward { [1]: integer, [2]: boolean }
---@field right { [1]: integer, [2]: boolean }
---@field jump { [1]: integer, [2]: boolean }
---@field attack { [1]: integer, [2]: boolean }
---@field aim { [1]: integer, [2]: boolean }
---@field weapon_raygun { [1]: integer, [2]: boolean }
---@field weapon_rpg { [1]: integer, [2]: boolean }
---@field weapon_railgun { [1]: integer, [2]: boolean }
---@field perspective { [1]: integer, [2]: boolean }
---@field previousWeapon { [1]: integer, [2]: boolean }

---@class Config
---@field gfx ConfigGFX
---@field audio ConfigAudio
---@field input ConfigInput

---@class MPParams
---@field bots integer
---...

---@class MultiplayerConfig
---@field username string
---@field defaultAddress string
---@field params MPParams

return true