# Plugin development and test guide

This guide covers the full lifecycle of a CTLD plugin: creation, unit testing,
DCS visual testing, and CI.

---

## 1. Creating a plugin

### Directory layout

```
plugins/
└── my-plugin/
    ├── README.md          ← source of truth for docs (FR prose + YAML front-matter)
    └── src/
        └── CTLD_myPlugin.lua
```

### Step 1 — Copy the template

```
plugins/_template/
```

Rename the folder and update every `template` / `Template` occurrence in the
`.lua` file and the `README.md`.

### Step 2 — Fill in the README front-matter

```yaml
---
modUrls:
  - mod: MyModType          # DCS typename declared in modTypes
    url: https://...        # download page for the mod
---
```

Omit the `modUrls` block entirely if the plugin requires no DCS mod.

### Step 3 — Write the Lua scene

Key rules:

- Register every DCS type you spawn via `CTLDObjectRegistry.registerIfAbsent`.
- List every non-stock (mod) type in `metalFarpScene.modTypes`.
- Stock DCS types do **not** go in `modTypes`.
- Set `probeSkip = true` on mod types — `getDesc().life` is always 0 for mods
  at runtime; skipping avoids a false "NOT FOUND" alarm.
- Objects destroyed in a later step must have their reference saved into
  `scene._params` during their spawn step `func` callback.

### Step 4 — Generate the doc pages

Run the `generate-plugin-doc` skill to produce `docs/plugins/my-plugin.md`
(EN) and `docs/plugins/my-plugin.fr.md` (FR) from the `README.md`.
Never edit those generated files by hand.

---

## 2. Unit tests (Busted)

### Location

```
plugins/my-plugin/tests/my_plugin_spec.lua
```

### What to test

Test observable **scene model properties**, not internal step order:

| Assertion | Why |
|-----------|-----|
| `isSceneEnabled("My Plugin")` | Scene is registered |
| `model.crate` is not nil | Crate declared for the menu |
| `model.requiresCtld` equals expected version | CTLD version guard in place |
| All mod types present in `model.modTypes` | Asset gate will catch them |
| Stock types absent from `model.modTypes` | Prevents false positives |
| Step count equals expected value | Sequence is complete |
| `critical = true` on mod-dependent spawn steps | Scene aborts if mod missing |

### Prior art

See `plugins/_template/tests/template_spec.lua` and
`plugins/metal-farp/tests/metal_farp_spec.lua`.

### Running locally

Busted is installed by the CI. To run locally, install it with LuaRocks and
run `busted tests/ plugins/` from the repo root.

---

## 3. DCS visual testing

Visual testing requires a live DCS instance and dcs-bridge active.

### Setup

- Both repos must be cloned **side-by-side**:
  ```
  Documents/GitHub/
  ├── CTLD/          ← neighbour repo, provides the CTLD runtime
  └── CTLD_plugins/  ← this repo
  ```
- Load `mission/Test_CTLD-plugins.miz` in DCS.
- Take the **`uh1-1`** (UH-1H) pilot slot — scenes spawn 100 m ahead of this unit.

### Dev / test loop

Each plugin provides three files in `plugins/{name}/tests/`:

| File | Purpose |
|------|---------|
| `inject_scene.lua` | Plays the scene 100 m ahead of `uh1-1` via `playSceneAtPos` |
| `cleanup.lua` | Destroys all spawned objects; leaves `uh1-1` intact |
| `RECIPE.md` | Timing checkpoints and full loop procedure |

**Injection order (Step 1 — once per session):**

```
../CTLD/CTLD.lua
plugins/{name}/src/CTLD_{name}.lua
```

**Play (Step 2 — repeated):**

```
plugins/{name}/tests/inject_scene.lua
```

**On a problem (Step 3):**

1. Inject `plugins/{name}/tests/cleanup.lua`.
2. Fix the plugin lua.
3. Repeat from Step 1.

### Injection methods

Use whichever interface you have available:

- **MCP (Claude Code):** ask Claude to inject the file via the dcs-bridge MCP tool.
- **TUI:** `dcs-client tui` → paste the file content in the exec panel.
- **REST API:** `POST /api/exec` with `{"lua": "<file content>"}` and the
  `X-Api-Key` header from `../CTLD/dcs-client.yaml`.

### The `cleanup.lua` contract

`cleanup.lua` sweeps **all** coalitions and all object categories (ground
groups, static objects, helicopter groups, etc.) and destroys everything except
the `uh1` group. It is intentionally generic — the same file works for any
plugin, regardless of what types the scene spawns.

---

## 4. CI checks

Every pull request runs the following gates automatically:

| Gate | What it checks |
|------|----------------|
| `lua-lint` | Lua 5.1 syntax (`luac5.1 -p`) on all `.lua` files |
| `luacheck` | Static analysis against `.luacheckrc` |
| `busted` | All `*_spec.lua` files under `tests/` and `plugins/` |
| `validate-docs` | README front-matter coherent with generated doc pages |
| `build` | Plugin `.lua` produces a non-empty `dist/` artifact |

Visual animation quality is **not** checked by CI — it is the acceptance gate
for the DCS injection recipe, validated by human observation.
