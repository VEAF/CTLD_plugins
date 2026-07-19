---@diagnostic disable
-- CTLD_templateScene.lua — REFERENCE plugin scene.
--
-- Copy this file to start a new plugin. It exercises EVERY extension point a scene can use, so
-- whatever your scene needs, there is an example here. It is load-position-independent: the exact
-- same source works whether merged into CTLD.lua or loaded as a plugin after CTLD.
--
-- A plugin scene is loaded from a MISSION START trigger, AFTER CTLD. Structure (by convention):
--   BLOCK 1  i18n            — the 4 mandatory languages for every user-facing string
--   BLOCK 2  ObjectRegistry  — declare every DCS type the scene spawns
--   BLOCK 3  scene model     — metadata, crate, steps
--   BLOCK 4  menu section    — optional F10 radio submenu
--   BLOCK 5  self-registration (always last)
--
-- Dependencies (all provided by the CTLD runtime): ctld, CTLDObjectRegistry, CTLDSceneManager,
-- CTLDPlayerManager, ctld.MenuManager, ctld.tr, ctld.utils.
-- ====================================================================================================

-- ====================================================================================================
-- BLOCK 1 : i18n — every user-facing string, in en / fr / es / ko.
-- ====================================================================================================
ctld.i18n["en"]["Template Crate"]  = "Template Crate"
ctld.i18n["fr"]["Template Crate"]  = "Caisse Template"
ctld.i18n["es"]["Template Crate"]  = "Caja Plantilla"
ctld.i18n["ko"]["Template Crate"]  = "템플릿 화물"

ctld.i18n["en"]["Deploy Template"] = "Deploy Template"
ctld.i18n["fr"]["Deploy Template"] = "Déployer le Template"
ctld.i18n["es"]["Deploy Template"] = "Desplegar Plantilla"
ctld.i18n["ko"]["Deploy Template"] = "템플릿 배치"

ctld.i18n["en"]["Template"]        = "Template"
ctld.i18n["fr"]["Template"]        = "Template"
ctld.i18n["es"]["Template"]        = "Plantilla"
ctld.i18n["ko"]["Template"]        = "템플릿"

ctld.i18n["en"]["Template: say hello"] = "Template: say hello"
ctld.i18n["fr"]["Template: say hello"] = "Template : dire bonjour"
ctld.i18n["es"]["Template: say hello"] = "Plantilla: saludar"
ctld.i18n["ko"]["Template: say hello"] = "템플릿: 인사하기"

ctld.i18n["en"]["Hello from %1!"]  = "Hello from %1!"
ctld.i18n["fr"]["Hello from %1!"]  = "Bonjour de la part de %1 !"
ctld.i18n["es"]["Hello from %1!"]  = "¡Hola de parte de %1!"
ctld.i18n["ko"]["Hello from %1!"]  = "%1이(가) 인사합니다!"

ctld.i18n["en"]["--- Template deployed by %1 ---"] = "--- Template deployed by %1 ---"
ctld.i18n["fr"]["--- Template deployed by %1 ---"] = "--- Template déployé par %1 ---"
ctld.i18n["es"]["--- Template deployed by %1 ---"] = "--- Plantilla desplegada por %1 ---"
ctld.i18n["ko"]["--- Template deployed by %1 ---"] = "--- %1이(가) 템플릿을 배치했습니다 ---"

-- ====================================================================================================
-- BLOCK 2 : ObjectRegistry — declare every DCS type the scene spawns.
-- registerIfAbsent is a no-op if the key already exists (CTLD pre-registers many common ones).
-- Use only STOCK types, OR declare mod types in model.modTypes (BLOCK 3) so the asset gate accepts
-- them while still validating every other type.
-- ====================================================================================================
CTLDObjectRegistry.registerIfAbsent("Windsock", {
    groupType = "STATIC", namePrefix = "Windsock", type = "Windsock", category = "Fortifications",
})
CTLDObjectRegistry.registerIfAbsent("FARP_Tent", {
    groupType = "STATIC", namePrefix = "Tent", type = "FARP Tent", category = "Fortifications",
})

-- ====================================================================================================
-- BLOCK 3 : scene model — metadata + crate + steps.
-- ====================================================================================================
local templateScene = {}
templateScene.name = "Template"

-- Minimum CTLD version providing the plugin machinery; CTLD warns at load if it is older.
templateScene.requiresCtld = "2.0.0"

-- Non-stock (mod) DCS types this scene spawns. Empty here (all stock). If your scene uses a mod
-- static/unit, list its exact type name(s): the asset gate then accepts them while still catching
-- typos in every stock type. Also set requiresMod = "<human label>" for the catalogue.
templateScene.modTypes = {}

-- Crate: auto-injected into the CTLD "Request Equipment" menu (weight is the 1001.xx handle).
templateScene.crate = {
    weight         = 1001.50,
    i18nKey        = "Template Crate",
    deployKey      = "Deploy Template",
    cratesRequired = 1,
    side           = nil,
    showSets       = false,
}

templateScene.steps = {
    -- polar step: deterministic position relative to the trigger unit snapshot.
    {
        registryKey              = "Windsock",
        polar                    = { distance = 15, angle = 0 },
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        delayAfterPreviousStep   = 0,
    },
    {
        registryKey              = "FARP_Tent",
        polar                    = { distance = 20, angle = 90 },
        relativeHeadingInDegrees = 0,
        relativeAltitudeInMeters = 0,
        delayAfterPreviousStep   = 1,
    },
    -- func step: no spawn, a post-spawn hook. ctx.scene / ctx.unit / ctx.spawnedObj are available.
    {
        delayAfterPreviousStep = 0,
        func = function(ctx)
            if trigger and trigger.action and trigger.action.outText then
                trigger.action.outText(
                    ctld.tr("--- Template deployed by %1 ---", ctx.unit:getName()), 10)
            end
        end,
    },
}

-- ====================================================================================================
-- BLOCK 4 : F10 radio submenu (optional).
-- deferMenuSection works whether the scene loads before or after CTLD init (load-position-
-- independent). buildTemplateSection creates the container once per player; refreshTemplateSection
-- (re)fills it — called on menu build and on land.
-- ====================================================================================================
function templateScene:refreshTemplateSection(playerObj)
    local mm   = ctld.MenuManager:getInstance()
    local menu = mm:getMenuByGroupId(playerObj.groupId)
    if not menu then return end

    local root = ctld.tr("CTLD")
    local sub  = ctld.tr("Template")
    menu:clearBranch({ root, sub })

    menu:addCommand({ root, sub }, ctld.tr("Template: say hello"),
        function(arg)
            local u = Unit.getByName(arg.unitName)
            local who = (u and u:isExist()) and u:getName() or arg.unitName
            trigger.action.outText(ctld.tr("Hello from %1!", who), 10)
        end,
        { unitName = playerObj.unitName })
end

function templateScene:buildTemplateSection(playerObj, menu)
    local root = ctld.tr("CTLD")
    local sub  = ctld.tr("Template")
    menu:addSubMenu({ root }, sub, { order = 80 })
    self:refreshTemplateSection(playerObj)
end

-- ====================================================================================================
-- BLOCK 5 : self-registration (always last).
-- ====================================================================================================
CTLDSceneManager.getInstance():registerSceneModel(templateScene)

CTLDPlayerManager.deferMenuSection({
    key           = "template_section",
    manager       = templateScene,
    method        = "buildTemplateSection",
    refreshMethod = "refreshTemplateSection",
    order         = 80,
})
