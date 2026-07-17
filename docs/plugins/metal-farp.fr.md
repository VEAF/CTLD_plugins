# Metal FARP

Construit un FARP autour d'une hélisurface métallique du mod DCS **`Farp_FG_Petit_Helipad`**, avec
le mobilier FARP habituel (camion carburant, camion de réparation, tente, munitions, éclairage,
manche à air).

## Prérequis

- **CTLD** ≥ 2.0.0 chargé en premier (le plugin prévient en jeu si CTLD est plus ancien).
- Le mod DCS fournissant le type statique **`Farp_FG_Petit_Helipad`**, installé sur **tous** les
  clients. Sans lui, l'hélisurface ne peut pas apparaître.

## Installation

1. Téléchargez `metal-farp.lua`.
2. Dans l'éditeur de mission, ajoutez un déclencheur `DO SCRIPT FILE` au **démarrage de la
   mission**, **après** le déclencheur qui charge `CTLD.lua`.
3. La scène ajoute une caisse dans le menu *Request Equipment* de CTLD ; déployez-la comme n'importe
   quelle caisse de scène FARP.

## Remarques

La validation au design-time ne peut pas vérifier que le client a réellement le mod installé —
seulement que le nom de type est un mod déclaré. S'assurer que le mod est présent sur tous les
clients relève de la responsabilité du créateur de mission.
