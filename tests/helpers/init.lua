---@diagnostic disable
-- tests/helpers/init.lua
-- Loaded by busted before every spec (.busted `helper` field).
-- Bootstraps a CTLD runtime for plugin tests: DCS API stubs + a pinned, vendored CTLD.lua
-- (vendor/CTLD.lua). Loading the built CTLD.lua populates every global a plugin scene needs
-- (CTLDObjectRegistry, CTLDSceneManager, ctld.utils, ctld.i18n, ctld.VERSION).
--
-- The vendored CTLD.lua is a release build pinned to a known CTLD version — the same version a
-- plugin declares via model.requiresCtld. Refresh it (and tests/data/dcs_types.lua) when bumping
-- the supported CTLD baseline.
-- ============================================================

local _root = debug.getinfo(1, "S").source:match("^@(.+)tests[\\/]helpers[\\/]init%.lua$")
if not _root then _root = "" end

dofile(_root .. "tests/helpers/dcs_stubs.lua")
dofile(_root .. "vendor/CTLD.lua")

-- CTLD.lua bundles all four i18n language tables; ensure they exist defensively so plugin scene
-- i18n assignments never index a nil table.
ctld.i18n = ctld.i18n or {}
for _, lang in ipairs({ "en", "fr", "es", "ko" }) do
    ctld.i18n[lang] = ctld.i18n[lang] or {}
end
