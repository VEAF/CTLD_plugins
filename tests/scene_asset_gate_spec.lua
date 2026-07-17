---@diagnostic disable
-- tests/scene_asset_gate_spec.lua
-- Design-time hard-gate for plugin scene assets (mirror of CTLD's own gate — see CTLD ADR 0007).
--
-- Every DCS type a plugin scene spawns must be a known stock type (tests/data/dcs_types.lua) OR a
-- declared non-stock type (scene model `modTypes`). Unknown → FAIL. modTypes is ADDITIVE to the
-- known set, so a typo in a stock type is still caught even in a descriptor that also uses a
-- whitelisted mod type.
--
-- The CTLD runtime is provided by tests/helpers/init.lua (DCS stubs + vendored CTLD.lua). We
-- capture — via spies during plugin load — exactly the descriptors and models each plugin scene
-- contributes, from two sources: what the scene registers itself (registerIfAbsent) and the
-- registry keys it references from its steps. This is immune to whatever the vendored CTLD.lua
-- already has in its shared registry.
--
-- To add a plugin: append its built-in scene file to PLUGIN_SCENES.
-- ============================================================

local ROOT = debug.getinfo(1, "S").source:match("^@(.+)tests[\\/][^\\/]+_spec%.lua$") or ""

local PLUGIN_SCENES = {
    "plugins/metal-farp/src/CTLD_metalFarpScene.lua",
    "plugins/_template/src/CTLD_templateScene.lua",
}

-- STATIC → desc.type; GROUND → desc.units[i].unitType(coalitionId) (a per-coalition function),
-- with a static desc.units[i].type fallback. Kept self-contained so this gate stays copyable;
-- CTLD ships the same logic as CTLDTypeCollector.typesOfDescriptor.
local function spawnedTypesOf(desc)
    local out, seen = {}, {}
    if type(desc) ~= "table" then return out end
    local function push(tn)
        if type(tn) == "string" and tn ~= "" and not seen[tn] then
            seen[tn] = true
            out[#out + 1] = tn
        end
    end
    if desc.groupType == "STATIC" then
        push(desc.type)
    elseif desc.groupType == "GROUND" and type(desc.units) == "table" then
        for _, u in ipairs(desc.units) do
            if type(u) == "table" then
                if type(u.unitType) == "function" then
                    for _, cid in ipairs({ 1, 2 }) do
                        local ok, tn = pcall(u.unitType, cid)
                        if ok then push(tn) end
                    end
                else
                    push(u.type)
                end
            end
        end
    end
    return out
end

local function unknownTypes(descsByLabel, known)
    local bad = {}
    for label, desc in pairs(descsByLabel) do
        for _, ty in ipairs(spawnedTypesOf(desc)) do
            if not known[ty] then bad[#bad + 1] = tostring(label) .. ": " .. tostring(ty) end
        end
    end
    return bad
end

describe("plugin scene asset hard-gate", function()

    local myModels, sceneDescs, known, modUnion

    setup(function()
        local reg = CTLDObjectRegistry
        local sm  = CTLDSceneManager.getInstance()

        local origReg = reg.registerIfAbsent
        local origMdl = sm.registerSceneModel
        local capturedDescs = {}
        myModels = {}
        reg.registerIfAbsent = function(key, desc)
            capturedDescs[tostring(key)] = desc
            return origReg(key, desc)
        end
        sm.registerSceneModel = function(self, model)
            if type(model) == "table" then myModels[#myModels + 1] = model end
            return origMdl(self, model)
        end

        local ok, err = pcall(function()
            for _, rel in ipairs(PLUGIN_SCENES) do dofile(ROOT .. rel) end
        end)

        reg.registerIfAbsent  = origReg
        sm.registerSceneModel = origMdl
        assert(ok, "plugin scene load failed: " .. tostring(err))

        sceneDescs = {}
        for label, desc in pairs(capturedDescs) do sceneDescs["reg:" .. label] = desc end
        for _, model in ipairs(myModels) do
            for i, step in ipairs(model.steps or {}) do
                if step.registryKey then
                    local d = reg._db[step.registryKey]
                    if d then sceneDescs["step:" .. tostring(model.name) .. "#" .. i] = d end
                end
            end
        end

        known, modUnion = {}, {}
        local stock = dofile(ROOT .. "tests/data/dcs_types.lua")
        for t in pairs(stock) do known[t] = true end
        for _, model in ipairs(myModels) do
            if type(model.modTypes) == "table" then
                for _, t in ipairs(model.modTypes) do known[t] = true; modUnion[t] = true end
            end
        end
    end)

    it("every plugin scene file registers a model", function()
        assert.equals(#PLUGIN_SCENES, #myModels)
    end)

    it("every type a plugin scene spawns is stock or declared (no unknowns)", function()
        local bad = unknownTypes(sceneDescs, known)
        assert.equals(0, #bad,
            "unknown DCS type(s) — add to datamine or the scene's modTypes:\n  " ..
            table.concat(bad, "\n  "))
    end)

    it("the gate bites: an undeclared bogus type fails", function()
        assert.equals(1, #unknownTypes({ bogus = { groupType = "STATIC", type = "NOT_A_REAL_DCS_TYPE_XYZ" } }, known))
    end)

    it("metalFarp's mod type is declared via modTypes", function()
        assert.is_true(modUnion["Farp_FG_Petit_Helipad"] == true)
    end)

end)
