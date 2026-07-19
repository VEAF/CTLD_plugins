---@diagnostic disable
-- plugins/metal-farp/tests/metal_farp_spec.lua
-- Smoke tests for the Metal FARP scene: verifies registration, crate declaration,
-- modTypes contents, step count, and critical flag on the helipad spawn step.
-- ============================================================

local ROOT = debug.getinfo(1, "S").source:match("^@(.+)plugins[\\/]") or ""

describe("metal-farp plugin scene", function()

    setup(function()
        dofile(ROOT .. "plugins/metal-farp/src/CTLD_metalFarpScene.lua")
    end)

    it("registers the Metal FARP scene model", function()
        assert.is_true(CTLDSceneManager.getInstance():isSceneEnabled("Metal FARP"))
    end)

    it("declares a crate for the Request Equipment menu", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        assert.is_not_nil(model.crate)
        assert.is_not_nil(model.crate.weight)
    end)

    it("declares requiresCtld", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        assert.equals("2.0.0", model.requiresCtld)
    end)

    it("lists both mod types including the under-construction variant", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        local modTypeSet = {}
        for _, t in ipairs(model.modTypes) do modTypeSet[t] = true end
        assert.is_true(modTypeSet["FG_small_Helipad"],
            "modTypes must contain FG_small_Helipad")
        assert.is_true(modTypeSet["FG_small_Helipad_Under_Construction"],
            "modTypes must contain FG_small_Helipad_Under_Construction")
    end)

    it("has exactly 13 steps", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        assert.equals(13, #model.steps)
    end)

    it("marks the FG_small_Helipad spawn step as critical", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        local found = false
        for _, step in ipairs(model.steps) do
            if step.registryKey == "FG_small_Helipad" then
                assert.is_true(step.critical,
                    "FG_small_Helipad step must have critical=true")
                found = true
            end
        end
        assert.is_true(found, "A step with registryKey FG_small_Helipad must exist")
    end)

    it("Tower Crane is NOT in modTypes (it is a stock DCS object)", function()
        local model = CTLDSceneManager.getInstance():getModel("Metal FARP")
        for _, t in ipairs(model.modTypes) do
            assert.is_not_equal("Tower Crane", t)
        end
    end)

end)
