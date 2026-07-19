---@diagnostic disable
-- plugins/_template/tests/template_spec.lua
-- Smoke test for the reference template scene: it registers its model, injects a crate, and wires a
-- radio submenu — proving the full extension surface (and CTLD's load-position-independent
-- deferMenuSection) works for a plugin loaded after CTLD.
--
-- For the full plugin development and test guide (unit tests + DCS visual testing loop):
-- docs/plugin-dev-guide.md  (rendered at https://veaf.github.io/CTLD_plugins/)
-- ============================================================

local ROOT = debug.getinfo(1, "S").source:match("^@(.+)plugins[\\/]") or ""

describe("template plugin scene", function()

    setup(function()
        dofile(ROOT .. "plugins/_template/src/CTLD_templateScene.lua")
    end)

    -- Sections live on the instance (_instance._menuSections) once CTLD is initialised, or in the
    -- class-level pre-init queue (_deferredSections) if not. deferMenuSection routes to whichever
    -- applies (the load-position-independent fix), so accept either.
    local function menuSectionWired(key)
        local inst = CTLDPlayerManager._instance
        if inst and inst._menuSections then
            for _, s in ipairs(inst._menuSections) do if s.key == key then return true end end
        end
        for _, s in ipairs(CTLDPlayerManager._deferredSections or {}) do
            if s.key == key then return true end
        end
        return false
    end

    it("registers the Template scene model", function()
        assert.is_true(CTLDSceneManager.getInstance():isSceneEnabled("Template"))
    end)

    it("declares a crate for the Request Equipment menu", function()
        local model = CTLDSceneManager.getInstance():getModel("Template")
        assert.is_not_nil(model.crate)
        assert.is_not_nil(model.crate.weight)
    end)

    it("declares requiresCtld and an (empty) modTypes list", function()
        local model = CTLDSceneManager.getInstance():getModel("Template")
        assert.equals("2.0.0", model.requiresCtld)
        assert.equals(0, #model.modTypes)
    end)

    it("wires the F10 radio submenu via deferMenuSection", function()
        assert.is_true(menuSectionWired("template_section"))
    end)

end)
