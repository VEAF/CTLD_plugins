# Versioning du site docs avec mike (latest / dev)

Le site MkDocs Material est géré par **mike**, avec deux versions coexistant sur GitHub Pages : `latest` (branch `master`) et `dev` (branch `develop`). Chaque version injecte sa propre valeur de `{branch}` dans les boutons download, garantissant qu'un testeur sur `dev` télécharge bien le `.lua` de `develop` et non de `master`.

## Alternatives considérées

- **Un seul site (master uniquement)** : impossible de tester la doc et les liens download en recette sans bricolage — le testeur aurait cliqué "télécharger" et obtenu la version stable, pas celle en cours de test.
- **Deux sites séparés (`/` et `/dev/`)** : fonctionne mais perd le sélecteur de version intégré, déjà validé dans l'orga VEAF (`veaf.github.io/documentation/`).

## URLs du site

| Version | URL | Déclencheur |
|---------|-----|-------------|
| Production (`latest`) | <https://veaf.github.io/CTLD_plugins/latest/> | push `master` |
| Recette (`dev`) | <https://veaf.github.io/CTLD_plugins/dev/> | push `develop` |
| Racine | <https://veaf.github.io/CTLD_plugins/> | redirige vers `latest` |

## Conséquences

- Le workflow `docs.yml` appelle `mike deploy dev` sur push `develop` et `mike deploy latest` sur push `master`.
- `{branch}` est une variable injectée à la génération des docs (skill Claude) — valeur `develop` ou `master`.
- Le `versions.json` géré par mike doit rester en `gh-pages`, ne pas être commité dans `develop`/`master`.
