# Template (pour les auteurs de plugins)

`plugins/_template/` est une **scène de référence**, pas un plugin déployable. Copiez-la pour
démarrer un nouveau plugin — elle exerce tous les points d'extension d'une scène, abondamment
commentée :

- **i18n** dans les quatre langues obligatoires (en / fr / es / ko) ;
- les déclarations **ObjectRegistry** de chaque type DCS spawné ;
- un **modèle de scène** avec des steps `polar` et `func` ;
- une **caisse** injectée dans le menu *Request Equipment* de CTLD ;
- un **sous-menu radio F10** câblé via `deferMenuSection` (fonctionne que la scène soit chargée
  avant ou après l'init de CTLD — le contrat d'indépendance à la position de chargement) ;
- les métadonnées `requiresCtld` (version CTLD minimale) et `modTypes` (types hors-stock déclarés).

## Checklist de création

1. Copiez `plugins/_template/` vers `plugins/<votre-plugin>/`, renommez le fichier et le `name` du
   modèle.
2. Déclarez chaque type spawné dans le BLOCK 2. Si l'un est un type **mod**, ajoutez-le à
   `model.modTypes` (et renseignez `requiresMod` pour le catalogue). Tous les autres types doivent
   être stock.
3. `busted tests/ plugins/` — le gate d'assets échoue sur tout type inconnu/non déclaré.
4. `tools/build/merge_plugin.ps1 -Plugin <votre-plugin>` → `dist/<votre-plugin>.lua`.
5. Copiez `plugins/_template/README.md` vers `plugins/<votre-plugin>/README.md`. Renseignez le
   front-matter (`modUrls` pour chaque mod requis) et rédigez la prose de description en **français**.
   La section `modUrls` peut être supprimée entièrement si le plugin n'utilise aucun mod.
6. Demandez à Claude d'exécuter le skill `generate-plugin-doc` pour générer
   `docs/plugins/<votre-plugin>.md` et `docs/plugins/<votre-plugin>.fr.md` depuis votre README.
   Committez les fichiers générés.
7. Ajoutez le plugin dans le tableau du catalogue dans `docs/index.md` et `docs/index.fr.md`.
