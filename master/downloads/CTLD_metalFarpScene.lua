---@diagnostic disable
-- CTLD_metalFarpScene.lua
-- Metal FARP deployment scene — compact forward arming/refueling point using the
-- FG_small_Helipad mod (visible metallic helipad platform).
--
-- Requires the FG_small_Helipad mod to be installed on all clients.
-- probeSkip=true is set on the registry entries for mod types — DCS getDesc().life == 0
-- whether the mod is installed or not.
--
-- Layout (all offsets from trigger unit position):
--   NOTE: delayAfterPreviousStep on step N = time before step N+1 starts.
--   Fuel truck              —  0.0 s
--   Repair truck            —  0.0 s
--   Tent                    —  0.0 s  (delay=0.5 -> crane at 0.5 s)
--   Tower Crane             —  0.5 s  (~59 m / 20°, ~20 m right of pad, delay=5 -> UC at 5.5 s)
--   FG_small_Helipad_Under_Construction — 5.5 s  (58 m / 0°, delay=20 -> destroy at 25.5 s)
--   [destroy Under_Construction]        — 25.5 s (delay=0 -> helipad immediately)
--   FG_small_Helipad heliport           — 25.5 s (58 m / 0°, delay=5 -> crane gone at 30.5 s)
--   [destroy Tower Crane]               — 30.5 s (delay=0 -> ammo immediately)
--   Ammo cargo              — 30.5 s
--   M92 light panel         — 35.0 s  alt+4 m
--   Windsock                — 35.0 s
--   Carrier Seaman          — 35.0 s
--   Warehouse stocking      — 40.0 s  10 000 L x 4 fuel types
--
-- Dependencies: CTLDObjectRegistry, CTLDSceneManager, CTLDUtils
-- ====================================================================================================

-- ====================================================================================================
-- BLOCK 1 : i18n -- 4 mandatory languages
-- ====================================================================================================

ctld.i18n["en"]["Metal FARP Crate"]                                = "Metal FARP Crate"
ctld.i18n["fr"]["Metal FARP Crate"]                                = "Caisse FARP Métal"
ctld.i18n["es"]["Metal FARP Crate"]                                = "Caja FARP Metal"
ctld.i18n["ko"]["Metal FARP Crate"]                                = "메탈 FARP 화물"

ctld.i18n["en"]["Deploy Metal FARP"]                               = "Deploy Metal FARP"
ctld.i18n["fr"]["Deploy Metal FARP"]                               = "Déployer FARP Métal"
ctld.i18n["es"]["Deploy Metal FARP"]                               = "Desplegar FARP Metal"
ctld.i18n["ko"]["Deploy Metal FARP"]                               = "메탈 FARP 배치"

ctld.i18n["en"]["--- Metal FARP Deployment by %1 : Complete! ---"] = "--- Metal FARP Deployment by %1 : Complete! ---"
ctld.i18n["fr"]["--- Metal FARP Deployment by %1 : Complete! ---"] = "--- Déploiement FARP Métal par %1 : Terminé ! ---"
ctld.i18n["es"]["--- Metal FARP Deployment by %1 : Complete! ---"] = "--- Despliegue FARP Metal por %1 : ¡Completo! ---"
ctld.i18n["ko"]["--- Metal FARP Deployment by %1 : Complete! ---"] = "--- %1에 의한 메탈 FARP 배치 완료! ---"

-- ====================================================================================================
-- BLOCK 2 : Registry entries required by this scene.
-- registerIfAbsent() is a no-op when the key already exists.
-- ====================================================================================================

CTLDObjectRegistry.registerIfAbsent("FG_small_Helipad", {
    groupType            = "STATIC",
    namePrefix           = "FARP_Helipad",
    type                 = "FG_small_Helipad",
    category             = "Heliports",
    shape_name           = "FG_small_Helipad.edm",
    heliport_frequency   = "127.5",
    heliport_callsign_id = 1,
    heliport_modulation  = 0,
    -- DCS scripting API limitation: getDesc().life == 0 whether the mod is installed or not.
    -- probeSkip suppresses the false NOT FOUND alarm from CTLDModValidator.
    probeSkip            = true,
})

-- Visual-only under-construction variant of FG_small_Helipad, used during the animation phase.
-- Ships in the same mod zip as FG_small_Helipad — no additional modUrls entry needed.
-- category = "Fortifications": coalition.addStaticObject returns a proper handle (unlike "Heliports"
-- which creates a ghost Airbase in DCS memory). probeSkip suppresses the CTLDModValidator alarm.
CTLDObjectRegistry.registerIfAbsent("FG_small_Helipad_Under_Construction", {
    groupType  = "STATIC",
    namePrefix = "FARP_Helipad_UC",
    type       = "FG_small_Helipad_Under_Construction",
    category   = "Fortifications",
    probeSkip  = true,
})

-- Stock DCS infrastructure object used as a construction prop during the animation.
CTLDObjectRegistry.registerIfAbsent("Tower Crane", {
    groupType  = "STATIC",
    namePrefix = "TowerCrane",
    type       = "Tower Crane",
    category   = "Structures",
    shape_name = "TowerCrane_01",
})

CTLDObjectRegistry.registerIfAbsent("Fuel_Truck", {
    groupType  = "GROUND",
    namePrefix = "Fuel_Truck_Grp",
    task       = "Ground Nothing",
    category   = Unit.Category.GROUND_UNIT,
    units      = {
        {
            namePrefix = "Fuel_Truck_Unit",
            unitType = function(cid)
                return cid == coalition.side.RED and "ATZ-10" or "M978 HEMTT Tanker"
            end,
            playerCanDrive = false,
            dx = 0,
            dz = 0,
            dh = 0,
        },
    },
})

CTLDObjectRegistry.registerIfAbsent("repare_Truck", {
    groupType  = "GROUND",
    namePrefix = "repare_Truck_Grp",
    task       = "Ground Nothing",
    category   = Unit.Category.GROUND_UNIT,
    units      = {
        {
            namePrefix = "repare_Truck_Unit",
            unitType = function(cid)
                return cid == coalition.side.RED and "Ural-375" or "M 818"
            end,
            playerCanDrive = false,
            dx = 0,
            dz = 0,
            dh = 0,
        },
    },
})

CTLDObjectRegistry.registerIfAbsent("FARP_Tent", {
    groupType  = "STATIC",
    namePrefix = "FARP_Tent",
    type       = "FARP Tent",
    category   = "Fortifications",
})

CTLDObjectRegistry.registerIfAbsent("ammo_cargo", {
    groupType  = "STATIC",
    namePrefix = "ammo_box_cargo",
    type       = "ammo_cargo",
    category   = "Cargos",
    shape_name = "ammo_box_cargo",
    rate       = 1,
})

CTLDObjectRegistry.registerIfAbsent("NF-2_LightOn", {
    groupType  = "STATIC",
    namePrefix = "LightOn",
    type       = "NF-2_LightOn",
    category   = "Fortifications",
    shape_name = "M92_NF-2_LightOn",
    rate       = 100,
})

CTLDObjectRegistry.registerIfAbsent("Windsock", {
    groupType  = "STATIC",
    namePrefix = "Windsock",
    type       = "Windsock",
    category   = "Fortifications",
    shape_name = "H-Windsock_RW",
    rate       = 3,
})

-- "us carrier shooter" is already registered in the global CTLDObjectRegistry default entries.

-- ====================================================================================================
-- BLOCK 3 : scene model + crate descriptor
-- ====================================================================================================

local metalFarpScene        = {}
metalFarpScene.name         = "Metal FARP"
metalFarpScene.requiresMod  = "FG_small_Helipad" -- human-readable required-mod label (docs/catalogue)
-- Non-stock (mod) DCS types this scene spawns. Added to the known set by the design-time
-- asset hard-gate (datamine ∪ modTypes) so validation still catches typos in every stock type.
-- FG_small_Helipad_Under_Construction ships in the same zip as FG_small_Helipad.
metalFarpScene.modTypes     = { "FG_small_Helipad", "FG_small_Helipad_Under_Construction" }
-- Minimum CTLD version providing the plugin-scene machinery (load-position-independent menus,
-- requiresCtld check). CTLD warns at load if it is older.
metalFarpScene.requiresCtld = "2.0.0"

metalFarpScene.crate        = {
    weight         = 1001.26,
    i18nKey        = "Metal FARP Crate",
    deployKey      = "Deploy Metal FARP",
    groundKey      = "You must be on the ground to deploy a FARP.",
    cratesRequired = 1,
    side           = nil,
    showSets       = false,
}

metalFarpScene.steps        = {

    -- ----------------------------------------------------------------
    -- Step 1: Fuel truck — right side under tent (t0 + 0 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 60, angle = 342.5 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 90,
        relativeAltitudeInMeters = 0,
        registryKey              = "Fuel_Truck",
    },

    -- ----------------------------------------------------------------
    -- Step 2: Repair truck — left side under tent (t0 + 0 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 61, angle = 340.5 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 90,
        relativeAltitudeInMeters = 0,
        registryKey              = "repare_Truck",
    },

    -- ----------------------------------------------------------------
    -- Step 3: Tent — over both trucks (t0 + 0.5 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 61, angle = 341 },
        delayAfterPreviousStep   = 0.5,
        relativeHeadingInDegrees = 90,
        relativeAltitudeInMeters = 0,
        registryKey              = "FARP_Tent",
    },

    -- ----------------------------------------------------------------
    -- Step 4: Tower Crane — construction prop, ~10 m right of pad
    -- as seen from the cockpit (t0 + 5.5 s).
    -- Reference saved in scene._params for later destruction.
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 59, angle = 20 },
        delayAfterPreviousStep   = 5,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        registryKey              = "Tower Crane",
        func                     = function(ctx)
            if ctx.spawnedObj then
                ctx.scene._params._craneObj = ctx.spawnedObj
            end
            return true
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 5: FG_small_Helipad_Under_Construction — visual construction
    -- phase, same footprint as the final pad (t0 + 10.5 s).
    -- Reference saved in scene._params for destruction in step 6.
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 58, angle = 0 },
        delayAfterPreviousStep   = 20,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        registryKey              = "FG_small_Helipad_Under_Construction",
        func                     = function(ctx)
            if ctx.spawnedObj then
                ctx.scene._params._underConstObj = ctx.spawnedObj
            end
            return true
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 6: Destroy FG_small_Helipad_Under_Construction — end of
    -- construction animation (t0 + 25.5 s). delay=0 → helipad spawns
    -- immediately after this step.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func                   = function(ctx)
            local obj = ctx.scene._params._underConstObj
            if obj and Object.isExist(obj) then
                obj:destroy()
            end
            ctx.scene._params._underConstObj = nil
            return true
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 7: FG_small_Helipad heliport — finished pad revealed immediately
    -- after UC destruction (t0 + 30.5 s).
    -- critical=true: if the mod is absent the helipad cannot spawn;
    -- abort the whole scene rather than deploying equipment with no pad.
    -- Saves the spawned airbase name for the warehouse-stocking step.
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 58, angle = 0 },
        delayAfterPreviousStep   = 5,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        registryKey              = "FG_small_Helipad",
        critical                 = true,
        func                     = function(ctx)
            if not ctx.spawnedObj then return false end
            ctx.scene._params.farpName = ctx.spawnedObj:getName()
            return true
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 8: Destroy Tower Crane — construction prop removed 5 s
    -- after the finished pad appears (t0 + 30.5 s). delay=0 here because
    -- the 5 s gap is carried by step 7's delayAfterPreviousStep.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 0,
        func                   = function(ctx)
            local obj = ctx.scene._params._craneObj
            if obj and Object.isExist(obj) then
                obj:destroy()
            end
            ctx.scene._params._craneObj = nil
            return true
        end,
    },

    -- ----------------------------------------------------------------
    -- Step 9: Ammo cargo (t0 + 35.5 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 75, angle = 346 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        registryKey              = "ammo_cargo",
    },

    -- ----------------------------------------------------------------
    -- Step 10: M92 light panel at tent height (t0 + 40 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 75, angle = 355 },
        delayAfterPreviousStep   = 4.5,
        relativeHeadingInDegrees = 310,
        relativeAltitudeInMeters = 4,
        registryKey              = "NF-2_LightOn",
    },

    -- ----------------------------------------------------------------
    -- Step 11: Windsock near the light, same timing (t0 + 40 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 73, angle = 346 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 220,
        relativeAltitudeInMeters = 0,
        registryKey              = "Windsock",
    },

    -- ----------------------------------------------------------------
    -- Step 12: Carrier Seaman on the helipad (t0 + 40 s).
    -- ----------------------------------------------------------------
    {
        polar                    = { distance = 67, angle = 2 },
        delayAfterPreviousStep   = 0,
        relativeHeadingInDegrees = 90,
        relativeAltitudeInMeters = 0,
        registryKey              = "us carrier shooter",
    },

    -- ----------------------------------------------------------------
    -- Step 13: Stock warehouse + completion message (t0 + 45 s).
    -- Fills all fuel types so aircraft can refuel/rearm at this point.
    -- ----------------------------------------------------------------
    {
        delayAfterPreviousStep = 5,
        func = function(ctx)
            local farpName = ctx.scene._params and ctx.scene._params.farpName
            if farpName then
                local ab = Airbase.getByName(farpName)
                if ab then
                    local w = ab:getWarehouse()
                    -- If this is a redeployed FARP, restore the snapshot; otherwise stock defaults.
                    local snap = ctx.scene._params.repackData
                        and ctx.scene._params.repackData.warehouseSnapshot
                    if snap and snap.liquid then
                        for fuelType = 0, 3 do
                            w:setLiquidAmount(fuelType, snap.liquid[fuelType] or 0)
                        end
                    else
                        w:addLiquid(0, 10000) -- jet fuel
                        w:addLiquid(1, 10000) -- aviation gasoline
                        w:addLiquid(2, 10000) -- MW50
                        w:addLiquid(3, 10000) -- diesel
                    end
                end
            end
            trigger.action.outText(
                ctld.tr("--- Metal FARP Deployment by %1 : Complete! ---", ctx.unit:getName()), 10)
            return true
        end,
    },
}

-- ====================================================================================================
-- BLOCK 4 : onRepack — called by CTLDSceneManager:packScene before objects are destroyed.
-- Captures the current warehouse fuel levels so they can be restored on next deployment.
-- ====================================================================================================

metalFarpScene.onRepack     = function(scene, repackData)
    local farpName = scene._params and scene._params.farpName
    if not farpName then return end
    local ab = Airbase.getByName(farpName)
    if not ab then return end
    local w = ab:getWarehouse()
    repackData.warehouseSnapshot = {
        liquid = {
            [0] = w:getLiquidAmount(0), -- jet fuel
            [1] = w:getLiquidAmount(1), -- aviation gasoline
            [2] = w:getLiquidAmount(2), -- MW50
            [3] = w:getLiquidAmount(3), -- diesel
        }
    }
end

-- ====================================================================================================
-- BLOCK 5 : self-registration
-- ====================================================================================================

CTLDSceneManager.getInstance():registerSceneModel(metalFarpScene)
