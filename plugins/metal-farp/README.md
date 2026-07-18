---
# Métadonnées documentaires du plugin.
# Ce fichier est la source de vérité pour la génération des pages docs/plugins/.
# Les fichiers docs/plugins/{nom}.md et {nom}.fr.md sont générés à partir d'ici
# via le skill generate-plugin-doc — ne pas les éditer à la main.

# Mods DCS requis pour ce plugin.
# Supprimer la section modUrls entière si le plugin n'utilise aucun mod.
# Chaque entrée : nom du type DCS tel que déclaré dans modTypes du .lua, + URL de téléchargement.
modUrls:
  - mod: FG_small_Helipad
    url: https://github.com/FullGas1/DCS-mods/tree/main/FG_small_Helipad
---

# Metal FARP

Ce plugin permet via CTLD de faire apparaitre un héliport métallique de façon progressive pour simuler sa construction, en y ajoutant des objets pour obtenir un héliport "décoré" plus réaliste.

## Prérequis

- **CTLD** ≥ 2.0.0 chargé en premier.
- Le mod DCS **`FG_small_Helipad`** installé sur **tous** les clients.
  Sans lui, l'héliport ne peut pas apparaître.

## Installation

1. Téléchargez le fichier `.lua` du plugin (bouton ci-dessus).
2. Dans l'éditeur de mission, ajoutez un déclencheur `DO SCRIPT FILE` au **démarrage de la
   mission**, **après** le déclencheur qui charge `CTLD.lua`.
3. La scène ajoute une caisse dans le menu
   *Request Equipment* de CTLD ; déployez-la comme n'importe quelle caisse de scène FARP.

## Remarques
