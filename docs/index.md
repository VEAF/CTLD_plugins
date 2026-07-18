# CTLD Plugins catalogue

Optional, pluggable **scenes** for [CTLD](https://github.com/VEAF/CTLD). Each plugin is a single
`.lua` file you load from a **mission-start trigger, after CTLD**; it self-registers. One plugin =
one scene.

Scenes live here (rather than built into `CTLD.lua`) when they depend on a DCS **mod**, so a mission
only pays for them if it opts in.

## How to use a plugin

1. Download the plugin `.lua` (see its page below, or the releases).
2. Add a `DO SCRIPT FILE` trigger at **MISSION START**, **after** the `CTLD.lua` trigger.
3. Install any required DCS mod on every client — each plugin's page lists its prerequisites.

## Available plugins

| Plugin | What it builds | Requires | Download |
|--------|----------------|----------|----------|
| [Metal FARP](plugins/metal-farp.md) | A metal-helipad FARP | DCS mod `Farp_FG_Petit_Helipad` | [⬇ metal-farp.lua](https://raw.githubusercontent.com/VEAF/CTLD_plugins/master/plugins/metal-farp/src/CTLD_metalFarpScene.lua){ .md-button } |
