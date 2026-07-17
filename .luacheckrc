-- .luacheckrc — CTLD_plugins
-- Plugin scenes run inside DCS (Lua 5.1) AFTER CTLD is loaded, so every CTLD symbol they use is
-- provided by the CTLD runtime (read-only from a plugin's perspective).
-- Run: luacheck plugins/ tests/

std = "lua51"

max_line_length = 200
unused_args     = false
self            = false

exclude_files = {
    "tools/**",
    "vendor/**",        -- vendored CTLD.lua build (not ours to lint)
    "tests/data/**",    -- generated datamine type set
}

read_globals = {
    -- DCS World API
    "env", "world", "coalition", "country", "timer", "trigger",
    "land", "atmosphere", "coord", "radio", "spot", "missionCommands",
    "Unit", "Group", "StaticObject", "Airbase", "Object", "Controller",
    "Weapon", "Runway", "Warehouse",
    "require", "dofile", "loadfile", "loadstring", "io", "os",
    -- CTLD runtime (provided by CTLD, consumed by plugins)
    "ctld",
    "CTLDObjectRegistry", "CTLDSceneManager", "CtldScene",
    "CTLDCrateManager", "CTLDCrateAssemblyManager",
    "CTLDPlayerManager", "CTLDPlayer",
    "CTLDTroopManager", "CTLDVehicleSpawner",
    "CTLDFOBManager", "CTLDBeaconManager", "CTLDJTACManager",
    "CTLDZoneManager", "CTLDCoreManager", "EventDispatcher",
}

files["tests/"] = {
    globals = { "describe", "it", "setup", "teardown",
                "before_each", "after_each",
                "assert", "spy", "mock", "stub" },
}
