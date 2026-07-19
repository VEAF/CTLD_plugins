---@diagnostic disable
-- plugins/metal-farp/tests/inject_scene.lua
-- DCS injection script: plays the Metal FARP construction scene 100 m ahead
-- of the reference helicopter ("uh1-1") in mission/Test_CTLD-plugins.miz.
--
-- Prerequisites (inject in order before this file):
--   1. ../CTLD/CTLD.lua         (CTLD runtime — neighbour-repo convention)
--   2. plugins/metal-farp/src/CTLD_metalFarpScene.lua
--
-- Usage: see plugins/metal-farp/tests/RECIPE.md
-- ============================================================

local REF_UNIT = "uh1-1"

local unit = Unit.getByName(REF_UNIT)
if not unit then
    env.error("[inject_scene] Unit '" .. REF_UNIT .. "' not found. "
        .. "Is mission/Test_CTLD-plugins.miz loaded and the slot taken?", false)
    return
end

local pos = unit:getPoint()
local hdg = unit:getHeading()   -- radians, 0 = North

-- Spawn 100 m directly ahead of the helicopter (in the direction it faces).
local spawnPos = {
    x = pos.x + 100 * math.sin(hdg),
    y = pos.y,
    z = pos.z + 100 * math.cos(hdg),
}

local coa     = unit:getCoalition()
local country = unit:getCountry()

env.info("[inject_scene] Spawning Metal FARP at 100 m ahead of " .. REF_UNIT
    .. " (hdg=" .. math.floor(math.deg(hdg) + 0.5) .. " deg)", false)

CTLDSceneManager.getInstance():playSceneAtPos("Metal FARP", spawnPos, coa, country, {})
