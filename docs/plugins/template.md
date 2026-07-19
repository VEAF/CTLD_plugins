# Template (for plugin authors)

`plugins/_template/` is a **reference scene**, not a deployable plugin. Copy it to start a new
plugin — it exercises every extension point a scene can use, heavily commented:

- **i18n** in the four mandatory languages (en / fr / es / ko);
- **ObjectRegistry** declarations for every spawned DCS type;
- a **scene model** with `polar` and `func` steps;
- a **crate** injected into the CTLD *Request Equipment* menu;
- an **F10 radio submenu** wired via `deferMenuSection` (works whether the scene is loaded before
  or after CTLD init — the load-position-independent contract);
- `requiresCtld` (minimum CTLD version) and `modTypes` (declared non-stock types) metadata.

## Authoring checklist

1. Copy `plugins/_template/` to `plugins/<your-plugin>/`, rename the file and the model `name`.
2. Declare every spawned type in BLOCK 2. If any is a **mod** type, add it to `model.modTypes`
   (and set `requiresMod` for the catalogue). All other types must be stock.
3. `busted tests/ plugins/` — the asset gate fails on any undeclared/unknown type.
4. `tools/build/merge_plugin.ps1 -Plugin <your-plugin>` → `dist/<your-plugin>.lua`.
5. Copy `plugins/_template/README.md` to `plugins/<your-plugin>/README.md`. Fill in the
   front-matter (`modUrls` for each required mod) and write the description prose in **French**.
   The `modUrls` section can be removed entirely if the plugin uses no mods.
6. Ask Claude to run the `generate-plugin-doc` skill to generate `docs/plugins/<your-plugin>.md`
   and `docs/plugins/<your-plugin>.fr.md` from your README. Commit the generated files.
7. Add the plugin to the catalogue table in `docs/index.md` and `docs/index.fr.md`.
