# Catalogue des plugins CTLD

**Scènes** optionnelles et enfichables pour [CTLD](https://github.com/VEAF/CTLD). Chaque plugin est
un unique fichier `.lua` que vous chargez depuis un déclencheur au **démarrage de la mission, après
CTLD** ; il s'enregistre tout seul. Un plugin = une scène.

Ces scènes vivent ici (plutôt que dans `CTLD.lua`) lorsqu'elles dépendent d'un **mod** DCS : une
mission ne les embarque que si elle le décide.

## Utiliser un plugin

1. Téléchargez le `.lua` du plugin (voir sa page ci-dessous, ou les *releases*).
2. Ajoutez un déclencheur `DO SCRIPT FILE` au **démarrage de la mission**, **après** le déclencheur
   qui charge `CTLD.lua`.
3. Installez le mod DCS requis sur tous les clients — la page de chaque plugin liste ses prérequis.

## Plugins disponibles

| Plugin | Ce qu'il construit | Requiert | Télécharger |
|--------|--------------------|----------|-------------|
| [Metal FARP](plugins/metal-farp.md) | Un FARP à hélisurface métallique | Mod DCS `FG_small_Helipad` | [⬇ metal-farp.lua](downloads/CTLD_metalFarpScene.lua){ download="metal-farp.lua" .md-button } |
