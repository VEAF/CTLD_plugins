---
# Métadonnées documentaires du plugin.
# Ce fichier est la source de vérité pour la génération des pages docs/plugins/.
# Les fichiers docs/plugins/{nom}.md et {nom}.fr.md sont générés à partir d'ici
# via le skill generate-plugin-doc — ne pas les éditer à la main.

# Mods DCS requis pour ce plugin.
# Supprimer la section modUrls entière si le plugin n'utilise aucun mod.
# Chaque entrée : nom du type DCS tel que déclaré dans modTypes du .lua, + URL de téléchargement.
modUrls:
  - mod: NomDuTypeDCS
    url: https://github.com/auteur/repo/tree/main/dossier-du-mod
---

# Nom du plugin (titre affiché sur la page de description)

<!-- Prose en français uniquement. Le skill generate-plugin-doc traduit automatiquement en anglais. -->

Courte description de ce que construit le plugin (1-2 phrases). Par exemple : "Construit un FARP
autour d'une hélisurface métallique, avec le mobilier FARP habituel."

## Prérequis

- **CTLD** ≥ X.Y.Z chargé en premier.
- Le mod DCS **`NomDuTypeDCS`** installé sur **tous** les clients.
  Sans lui, [décrire l'effet visible : l'objet X ne peut pas apparaître].

<!-- Supprimer la section Prérequis > mod si le plugin n'utilise aucun mod. -->

## Installation

1. Téléchargez le fichier `.lua` du plugin (bouton ci-dessus).
2. Dans l'éditeur de mission, ajoutez un déclencheur `DO SCRIPT FILE` au **démarrage de la
   mission**, **après** le déclencheur qui charge `CTLD.lua`.
3. [Décrire comment l'utilisateur active la scène — ex : "La scène ajoute une caisse dans le menu
   *Request Equipment* de CTLD ; déployez-la comme n'importe quelle caisse de scène FARP."]

## Remarques

<!-- Section optionnelle. Supprimer si rien à signaler. -->

[Avertissements, limitations connues, comportements non évidents pour le mission maker.]
