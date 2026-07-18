# README plugin comme source de vérité documentaire

Chaque plugin possède un `plugins/{nom}/README.md` (front-matter YAML + prose FR) qui est l'unique source de vérité pour sa documentation. Les fichiers `docs/plugins/{nom}.md` et `{nom}.fr.md` sont **générés** par un skill Claude interactif — jamais édités à la main.

## Alternatives considérées

- **`meta.yaml` séparé + prose dans `docs/`** : deux fichiers à maintenir en sync, risque de désynchronisation.
- **Métadonnées dans le `.lua`** : le `.lua` tourne dans DCS — y coller des URLs GitHub pollue le code runtime avec de la pure métadonnée documentaire sans valeur à l'exécution.

## Conséquences

- Les `docs/plugins/` doivent être régénérés après chaque modification du `README.md` d'un plugin.
- Le `plugins/_template/README.md` fait loi comme template de référence pour les auteurs.
- La traduction FR→EN est produite par Claude à la demande du concepteur (interactif), pas par la CI.
