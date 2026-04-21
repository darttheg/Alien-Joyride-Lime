local out = {}
local root = "content.scripts.levels."

out.Levels = {
    -- The main menu. This level not only handles jumping into games, but connecting, settings, skin swapping, and more.
    Menu = root .. "l_menu"
}

out.Sublevels = {
    -- Visualizes level/sublevel layout
    LevelGraph = root .. "sl_leveltree",
    -- Displays debug info
    DebugInfo = root .. "sl_debug",
    -- Main menu buttons
    MainMenuButtons = root .. "sl_main_menu",
    -- Settings menu
    SettingsMenu = root .. "sl_settings",
    -- Connect menu
    ConnectMenu = root .."sl_connect"
}

return out