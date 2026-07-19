# Metal FARP — DCS Visual Test Recipe

Step-by-step procedure to play and iterate on the Metal FARP construction
animation using dcs-bridge, without reloading the mission between iterations.

---

## Prerequisites

- DCS World running with `mission/Test_CTLD-plugins.miz` loaded.
- Take the **`uh1-1`** (UH-1H) pilot slot — the scene spawns 100 m ahead of
  this unit.
- dcs-bridge active (see [CTLD repo setup](../../../CTLD/tools/dcs-bridge/install.ps1)).
- Both repos cloned side-by-side:
  ```
  Documents/GitHub/
  ├── CTLD/            ← CTLD runtime
  └── CTLD_plugins/    ← this repo
  ```
  All paths below are relative to the `CTLD_plugins/` root.

---

## Injection method

Use whichever dcs-bridge interface you prefer to send each `.lua` file to DCS:

- **MCP (Claude Code):** ask Claude to inject the file via the dcs-bridge MCP tool.
- **TUI:** `dcs-client tui` → paste the file content in the exec panel.
- **REST API directly:**
  ```powershell
  $cfg  = Get-Content ../CTLD/dcs-client.yaml | ConvertFrom-Yaml
  $body = @{ lua = Get-Content <file.lua> -Raw } | ConvertTo-Json
  Invoke-RestMethod -Uri "http://$($cfg.host):$($cfg.port)/api/exec" `
      -Method Post -Headers @{"X-Api-Key"=$cfg.api_key} `
      -ContentType "application/json" -Body $body
  ```

---

## Dev / test loop

### Step 1 — Initial setup (once per mission session)

Inject the two files below **in order**. This loads the CTLD runtime and
registers the Metal FARP scene model. Only needed once; skip on subsequent
iterations unless you changed the plugin lua.

```
../CTLD/CTLD.lua
plugins/metal-farp/src/CTLD_metalFarpScene.lua
```

### Step 2 — Play the scene

```
plugins/metal-farp/tests/inject_scene.lua
```

The scene starts immediately. Watch the animation in-game using the timing
checkpoints below.

### Step 3 — If a problem is found: cleanup → fix → replay

1. Inject **`plugins/metal-farp/tests/cleanup.lua`** — destroys all spawned
   objects, leaves `uh1-1` intact. An on-screen message confirms the count.
2. Fix `plugins/metal-farp/src/CTLD_metalFarpScene.lua`.
3. Re-inject **both** setup files (Step 1) to reload the updated scene model.
4. Re-inject the scene script (Step 2).

Repeat until satisfied.

---

## Visual checkpoints

| t (approx.) | What you should see |
|-------------|---------------------|
| t+0 s       | Fuel truck + repair truck appear near the tent area |
| t+0.5 s     | FARP Tent covers the trucks |
| t+5.5 s     | Tower Crane appears ~10 m to the right of the pad zone |
| t+10.5 s    | FG_small_Helipad_Under_Construction materialises under the crane |
| t+30.5 s    | Under-construction helipad disappears; finished FG_small_Helipad revealed |
| t+35.5 s    | Tower Crane disappears; ammo cargo spawns |
| t+40 s      | M92 light panel, windsock, and carrier seaman appear |
| t+45 s      | On-screen message "Metal FARP Deployment … Complete!" — FARP is now operational |

---

## Notes

- Positions (crane at 59 m / 10°, pads at 58 m / 0°) are tuned visually.
  Adjust `polar` values in `CTLD_metalFarpScene.lua` and iterate.
- `cleanup.lua` sweeps **all** coalitions and object categories — it is safe
  to use for any plugin, not just Metal FARP.
- The warehouse is stocked at t+45 s; until then the helipad exists but
  carries no fuel.
