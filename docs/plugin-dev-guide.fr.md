# Guide de développement et de test de plugin

Ce guide couvre le cycle de vie complet d'un plugin CTLD : création, tests
unitaires, test visuel DCS, et intégration continue.

---

## 1. Créer un plugin

### Structure des dossiers

```
plugins/
└── mon-plugin/
    ├── README.md          ← source de vérité pour la doc (prose FR + front-matter YAML)
    └── src/
        └── CTLD_monPlugin.lua
```

### Étape 1 — Copier le template

```
plugins/_template/
```

Renommer le dossier et remplacer toutes les occurrences de `template` / `Template`
dans le fichier `.lua` et le `README.md`.

### Étape 2 — Remplir le front-matter du README

```yaml
---
modUrls:
  - mod: MonTypeDCS       # typename DCS déclaré dans modTypes
    url: https://...      # page de téléchargement du mod
---
```

Supprimer entièrement le bloc `modUrls` si le plugin n'utilise aucun mod DCS.

### Étape 3 — Écrire la scène Lua

Règles essentielles :

- Enregistrer chaque type DCS spawné via `CTLDObjectRegistry.registerIfAbsent`.
- Lister chaque type non-stock (mod) dans `metalFarpScene.modTypes`.
- Les types DCS stock **ne vont pas** dans `modTypes`.
- Mettre `probeSkip = true` sur les types mod — `getDesc().life` vaut toujours 0
  pour les mods à l'exécution ; sauter la sonde évite une fausse alarme "NOT FOUND".
- Les objets détruits dans une étape ultérieure doivent avoir leur référence sauvegardée
  dans `scene._params` lors du callback `func` de l'étape de spawn.

### Étape 4 — Générer les pages de documentation

Utiliser le skill `generate-plugin-doc` pour produire `docs/plugins/mon-plugin.md`
(EN) et `docs/plugins/mon-plugin.fr.md` (FR) à partir du `README.md`.
Ne jamais éditer ces fichiers générés à la main.

---

## 2. Tests unitaires (Busted)

### Emplacement

```
plugins/mon-plugin/tests/mon_plugin_spec.lua
```

### Quoi tester

Tester les **propriétés observables du modèle de scène**, pas l'ordre interne des steps :

| Assertion | Pourquoi |
|-----------|----------|
| `isSceneEnabled("Mon Plugin")` | La scène est bien enregistrée |
| `model.crate` non nil | La caisse est déclarée pour le menu |
| `model.requiresCtld` égal à la version attendue | Garde de version CTLD en place |
| Tous les types mod présents dans `model.modTypes` | L'asset gate les détectera |
| Types stock absents de `model.modTypes` | Évite les faux positifs |
| Nombre de steps égal à la valeur attendue | La séquence est complète |
| `critical = true` sur les steps de spawn dépendant d'un mod | La scène s'arrête si le mod est absent |

### Exemples

Voir `plugins/_template/tests/template_spec.lua` et
`plugins/metal-farp/tests/metal_farp_spec.lua`.

### Exécution en local

Busted est installé par la CI. Pour l'exécuter localement, l'installer avec LuaRocks
et lancer `busted tests/ plugins/` depuis la racine du repo.

---

## 3. Test visuel DCS

Le test visuel nécessite une instance DCS active et dcs-bridge en fonctionnement.

### Prérequis

- Les deux repos doivent être clonés **côte à côte** :
  ```
  Documents/GitHub/
  ├── CTLD/          ← repo voisin, fournit le runtime CTLD
  └── CTLD_plugins/  ← ce repo
  ```
- Charger `mission/Test_CTLD-plugins.miz` dans DCS.
- Prendre le slot pilote **`uh1-1`** (UH-1H) — les scènes se déploient 100 m devant cette unité.

### Boucle dev / test

Chaque plugin fournit trois fichiers dans `plugins/{nom}/tests/` :

| Fichier | Rôle |
|---------|------|
| `inject_scene.lua` | Joue la scène 100 m devant `uh1-1` via `playSceneAtPos` |
| `cleanup.lua` | Détruit tous les objets spawnés ; laisse `uh1-1` intact |
| `RECIPE.md` | Checkpoints de timing et procédure complète |

**Injection initiale (Étape 1 — une fois par session) :**

```
../CTLD/CTLD.lua
plugins/{nom}/src/CTLD_{nom}.lua
```

**Jouer la scène (Étape 2 — répétée) :**

```
plugins/{nom}/tests/inject_scene.lua
```

**En cas de problème (Étape 3) :**

1. Injecter `plugins/{nom}/tests/cleanup.lua`.
2. Corriger le lua du plugin.
3. Reprendre depuis l'Étape 1.

### Méthodes d'injection

Utiliser l'interface disponible :

- **MCP (Claude Code) :** demander à Claude d'injecter le fichier via l'outil MCP dcs-bridge.
- **TUI :** `dcs-client tui` → coller le contenu du fichier dans le panneau exec.
- **API REST :** `POST /api/exec` avec `{"lua": "<contenu>"}` et l'en-tête
  `X-Api-Key` issu de `../CTLD/dcs-client.yaml`.

### Le contrat de `cleanup.lua`

`cleanup.lua` balaie **toutes** les coalitions et toutes les catégories d'objets
(groupes sol, objets statiques, groupes hélico, etc.) et détruit tout sauf le groupe `uh1`.
Il est volontairement générique — le même fichier fonctionne pour n'importe quel plugin,
quels que soient les types que la scène a spawnés.

---

## 4. Intégration continue (CI)

Chaque pull request déclenche automatiquement les vérifications suivantes :

| Vérification | Ce qu'elle contrôle |
|--------------|---------------------|
| `lua-lint` | Syntaxe Lua 5.1 (`luac5.1 -p`) sur tous les fichiers `.lua` |
| `luacheck` | Analyse statique selon `.luacheckrc` |
| `busted` | Tous les fichiers `*_spec.lua` sous `tests/` et `plugins/` |
| `validate-docs` | Cohérence du front-matter README avec les pages doc générées |
| `build` | Le `.lua` du plugin produit un artefact non vide dans `dist/` |

La qualité visuelle de l'animation **n'est pas** vérifiée par la CI — c'est la porte d'acceptation
de la recipe d'injection DCS, validée par observation humaine.
