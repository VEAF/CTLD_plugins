# CONTEXT.md — CTLD_plugins

Glossaire et décisions de domaine. Ne contient pas de détails d'implémentation.

---

## Glossaire

**Plugin**
Un fichier `.lua` unique qui s'auto-enregistre dans CTLD au chargement. Un plugin = une scène. Les plugins vivent dans `plugins/{nom}/src/`.

**Scène**
Ce qu'un plugin construit en jeu (ex : un FARP métallique). Terme runtime DCS/CTLD.

**Mission maker**
Utilisateur final du plugin : il télécharge le `.lua`, le charge dans l'éditeur de mission DCS, et installe les mods requis sur sa machine.

**Mod DCS**
Extension tierce pour DCS World fournissant des types d'objets non-stock. Un plugin qui utilise un mod le déclare dans `modTypes` (runtime) et dans `modUrls` (doc).

**modUrls**
Table de paires `{mod, url}` dans le front-matter YAML du `README.md` d'un plugin. Source de vérité documentaire pour les liens vers les mods requis. Distinct de `modTypes` (runtime Lua uniquement).

**README plugin**
Fichier `plugins/{nom}/README.md`. Source de vérité unique pour la documentation d'un plugin. Contient un front-matter YAML (métadonnées structurées dont `modUrls`) et une prose en français. Suit le template `plugins/_template/README.md`.

**Doc générée**
Les fichiers `docs/plugins/{nom}.md` (EN) et `docs/plugins/{nom}.fr.md` (FR) sont générés par un skill Claude interactif à partir du README plugin. Ils ne sont jamais édités à la main.

**Skill generate-plugin-doc**
Skill Claude (à créer) qui lit `plugins/{nom}/README.md` + le template de doc, assemble et traduit FR→EN, et produit les deux fichiers `docs/plugins/`.

**Catalogue**
Page d'index (`docs/index.md` / `docs/index.fr.md`) listant tous les plugins disponibles avec leur bouton de téléchargement.

**Bouton download**
Lien direct vers le fichier `.lua` brut sur GitHub :
`https://raw.githubusercontent.com/VEAF/CTLD_plugins/{branch}/plugins/{nom}/src/{fichier}.lua`
où `{branch}` est `master` pour la version stable, `develop` pour la version dev.
Présent dans le tableau du catalogue ET dans la page de description du plugin.

**{branch}**
Variable injectée à la génération des docs. Vaut `master` (site `latest`) ou `develop` (site `dev`). Détermine vers quelle version du fichier `.lua` pointent les boutons download.

**Site docs versionné**
Site MkDocs Material géré par **mike**. Deux versions coexistent sur GitHub Pages :
- `latest` → branch `master` (stable)
- `dev` → branch `develop` (recette)
Chaque version a ses propres liens download cohérents avec sa branche.
