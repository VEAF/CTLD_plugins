---@diagnostic disable
-- plugins/metal-farp/tests/cleanup.lua
-- DCS injection script: destroys all objects spawned by a scene, leaving only
-- the reference helicopter group ("uh1") intact.
--
-- Generic: makes no assumptions about what the scene spawned (statics, ground
-- groups, airbases).  Safe to inject multiple times between dev iterations.
--
-- Usage: see plugins/metal-farp/tests/RECIPE.md
-- ============================================================

local KEEP_GROUP = "uh1"
local destroyed  = 0

local function destroyGroups(coa, cat)
    for _, grp in ipairs(coalition.getGroups(coa, cat) or {}) do
        if grp:getName() ~= KEEP_GROUP then
            grp:destroy()
            destroyed = destroyed + 1
        end
    end
end

for _, coa in ipairs({ coalition.side.BLUE, coalition.side.RED, coalition.side.NEUTRAL }) do
    -- Ground groups (trucks, vehicles)
    destroyGroups(coa, Group.Category.GROUND)
    -- Helicopter groups (excluding our reference slot)
    destroyGroups(coa, Group.Category.HELICOPTER)
    -- Airplane and ship groups (unlikely in this mission but safe to sweep)
    destroyGroups(coa, Group.Category.AIRPLANE)
    destroyGroups(coa, Group.Category.SHIP)

    -- Static objects (helipad, tent, crane, ammo, lights, windsock, seaman…)
    for _, obj in ipairs(coalition.getStaticObjects(coa) or {}) do
        obj:destroy()
        destroyed = destroyed + 1
    end
end

-- Spawned airbases (FARPs, helipads) persist as Airbase objects after their
-- static is destroyed. Destroy all non-airdrome airbases (cat ~= 0).
local abDestroyed = 0
for _, ab in ipairs(world.getAirbases() or {}) do
    local desc = ab:getDesc()
    local cat  = desc and desc.category or -1
    if cat ~= 0 then
        ab:destroy()
        abDestroyed = abDestroyed + 1
    end
end
destroyed = destroyed + abDestroyed

env.info("[cleanup] Done — " .. destroyed .. " object(s) destroyed, '" .. KEEP_GROUP .. "' preserved.", false)
trigger.action.outText("[cleanup] Scene cleared (" .. destroyed .. " objects). Ready for next injection.", 5)
