# CTLD_plugins

Optional, pluggable **scenes** for [CTLD](https://github.com/VEAF/CTLD) (Combined Transport and
Logistics Dispatcher for DCS World).

A **scene** is a pre-defined multi-step build (a FARP, a minefield…). Most scenes ship built into
`CTLD.lua`. This repository hosts scenes that are kept **out** of the core deliverable — typically
because they depend on a DCS **mod** — so a mission only pays for them if it opts in.

A plugin scene is a single loadable `.lua` file. Load it from a **mission-start trigger, after
CTLD**, and it self-registers. One plugin = one scene.

## For mission makers

1. Download the plugin's `.lua` from the [catalogue](https://veaf.github.io/CTLD_plugins/) (or a
   release).
2. In the DCS Mission Editor, add a `DO SCRIPT FILE` (or `DO SCRIPT`) trigger at **MISSION START**,
   **after** the trigger that loads `CTLD.lua`.
3. If the plugin requires a DCS mod, ensure every client has that mod installed (the plugin's page
   lists it). The plugin warns in-game if your CTLD is older than it requires.

## Repository layout

```
plugins/<plugin>/
  src/    the scene source (+ optional Lua deps; built into dist/<plugin>.lua)
  tests/  plugin-specific tests (optional)
  docs/   authored notes (optional)
tests/
  helpers/init.lua       DCS stubs + vendored CTLD runtime (busted helper)
  helpers/dcs_stubs.lua  copied from CTLD
  data/dcs_types.lua     vendored datamine stock-type set (design-time asset gate)
  scene_asset_gate_spec.lua  strict gate: every spawned type is stock or declared modTypes
vendor/CTLD.lua          pinned CTLD build used as the test runtime (= requiresCtld baseline)
tools/build/merge_plugin.ps1   builds plugins/<plugin>/src → dist/<plugin>.lua (UTF-8, no BOM)
docs/                    mkdocs bilingual (EN + FR) catalogue
```

## For plugin developers

- **Build:** `powershell -ExecutionPolicy Bypass -File tools/build/merge_plugin.ps1 -All`
  (or `-Plugin <name>`) → `dist/<name>.lua`.
- **Test:** `busted tests/` — the design-time asset hard-gate loads the vendored CTLD runtime,
  loads each plugin scene, and fails if it spawns a DCS type that is neither a known stock type
  (`tests/data/dcs_types.lua`) nor declared in the scene's `modTypes`.
- **Declare a mod:** set `model.modTypes = { "Your_Mod_Type" }` (machine-readable, keeps the gate
  strict on every *other* type) and `model.requiresMod = "<human label>"` (docs).
- **Declare compatibility:** set `model.requiresCtld = "X.Y.Z"`; CTLD warns at load if older.

The vendored `vendor/CTLD.lua` and `tests/data/dcs_types.lua` are pinned to a CTLD baseline; refresh
them together when bumping the supported CTLD version.

- **Document a plugin:** create `plugins/<name>/README.md` (use `plugins/_template/README.md` as
  model), then run the `generate-plugin-doc` skill in Claude to produce `docs/plugins/<name>.md`
  and `docs/plugins/<name>.fr.md`. Finally add the plugin row to `docs/index.md` and
  `docs/index.fr.md`.

### CI gate — `validate-docs`

The `validate-docs` job runs `tools/ci/validate_docs.py` on every push and PR. It:

- **Warns** (exit 0) when a plugin has no `README.md` (docs will have no prose, but the build is not blocked).
- **Errors** (exit 1) when:
  - `README.md` is present but its YAML front-matter is absent or malformed.
  - `modUrls` exists but is not a list of `{mod, url}` pairs.
  - `docs/plugins/<name>.md` or `docs/plugins/<name>.fr.md` is absent.

Run it locally before pushing: `python tools/ci/validate_docs.py` (requires `pyyaml`).
