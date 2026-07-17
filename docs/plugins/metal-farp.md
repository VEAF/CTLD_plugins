# Metal FARP

Builds a FARP around a metal helipad from the DCS mod **`Farp_FG_Petit_Helipad`**, plus the usual
FARP furniture (fuel truck, repair truck, tent, ammo, lighting, windsock).

## Prerequisites

- **CTLD** ≥ 2.0.0 loaded first (the plugin warns in-game if CTLD is older).
- The DCS mod providing the static type **`Farp_FG_Petit_Helipad`**, installed on **every** client.
  Without it the FARP helipad will not spawn.

## Install

1. Download `metal-farp.lua`.
2. In the Mission Editor, add a `DO SCRIPT FILE` trigger at **MISSION START**, **after** the trigger
   that loads `CTLD.lua`.
3. The scene registers a crate in the CTLD *Request Equipment* menu; deploy it like any other FARP
   scene crate.

## Notes

Design-time validation cannot check whether a client actually has the mod installed — only that the
type name is a declared mod. Ensuring the mod is present on all clients is the mission maker's
responsibility.
