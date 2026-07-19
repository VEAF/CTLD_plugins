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

local p3  = unit:getPosition()  -- {p=point, x=fwd, y=up, z=right}
local pos = p3.p
local fwd = p3.x                 -- forward unit vector in DCS axes (x=North, z=East)

-- Spawn 100 m directly ahead of the helicopter (in the direction it faces).
local spawnPos = {
    x = pos.x + 100 * fwd.x,
    y = pos.y,
    z = pos.z + 100 * fwd.z,
}

local hdgDeg  = math.floor(math.deg(math.atan2(fwd.z, fwd.x)) + 0.5)
local coa     = unit:getCoalition()
local country = unit:getCountry()

env.info("[inject_scene] Spawning Metal FARP at 100 m ahead of " .. REF_UNIT
    .. " (hdg=" .. hdgDeg .. " deg)", false)

-- Build a mock unit at spawnPos with the helicopter's actual heading so that
-- the scene's polar offsets are oriented along the helicopter's axis.
-- (playSceneAtPos hardcodes North-facing — we bypass it here.)
local mockUnit = {
    isExist      = function(_) return true end,
    getName      = function(_) return "inject_test" end,
    getCoalition = function(_) return coa end,
    getCountry   = function(_) return country end,
    getPoint     = function(_) return spawnPos end,
    getPosition  = function(_) return { x = fwd, p = spawnPos } end,
}

CTLDSceneManager.getInstance():playScene(mockUnit, "Metal FARP", {}, nil)
