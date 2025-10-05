# Contexte Complet Session 2025-10-05

## 📋 État du Projet

### Git Status Actuel
```
Branch: main
Commits ahead of origin: 4

Derniers commits:
- e562110 (HEAD) - test: Move axelor-vecia-crm to axelor-open-suite (CSV import still not working)
- 75bdaa5 - wip: Add custom field 'provenance' via CSV data-init (not working yet)
- 67815ca - fix(crm): correct view names in All Contacts menu + knowledge base improvements
- d82470d - docs: Add Docker custom modules deployment system
```

### Structure Actuelle (⚠️ TEMPORAIRE)

```
/Users/tanguy/dev/projets/axelor-vecia-v1/
├── modules/
│   ├── axelor-open-suite/          # Submodule Git
│   │   ├── axelor-base/
│   │   ├── axelor-crm/
│   │   ├── ...
│   │   └── axelor-vecia-crm/       # ⚠️ NOTRE MODULE (à reverter)
│   │       ├── build.gradle
│   │       ├── README.md
│   │       └── src/main/resources/
│   │           ├── data-init/
│   │           │   ├── input-config.xml
│   │           │   └── input/
│   │           │       └── meta_metaJsonField.csv
│   │           ├── module.properties
│   │           └── views/
│   │               ├── Menu.xml
│   │               ├── Selections.xml
│   │               └── PartnerExtension.xml
│   │
│   └── (axelor-vecia-crm devrait être ICI, pas dans axelor-open-suite/)
│
├── settings.gradle                  # Modifié (path vers axelor-open-suite/axelor-vecia-crm)
├── Dockerfile                       # Modifié (COPY simplifié)
└── .diagnostic-archives/            # ✅ NOUVEAU (documentation sauvegardée)
```

---

## 🔄 Modifications Faites (Détail)

### 1. Fichiers CSV + Views (Commit 75bdaa5)

**Créés** :
- `modules/axelor-vecia-crm/src/main/resources/data-init/input-config.xml`
- `modules/axelor-vecia-crm/src/main/resources/data-init/input/meta_metaJsonField.csv`
- `modules/axelor-vecia-crm/src/main/resources/views/Selections.xml`
- `modules/axelor-vecia-crm/src/main/resources/views/PartnerExtension.xml`

**Contenu** :
- CSV : Custom field "provenance" pour Partner contacts
- Selections.xml : Values pour dropdown (LinkedIn, Site Web, etc.)
- PartnerExtension.xml : Ajout field dans forms/grids Partner

**Résultat** : ❌ CSV jamais importé (Axelor ignore)

---

### 2. Déplacement Module (Commit e562110)

**Action** : `mv modules/axelor-vecia-crm → modules/axelor-open-suite/axelor-vecia-crm`

**Fichiers modifiés** :

#### settings.gradle (ligne 68)
```gradle
# AVANT
def customModuleDir = file("modules/axelor-vecia-crm")

# APRÈS
def customModuleDir = file("modules/axelor-open-suite/axelor-vecia-crm")
```

#### Dockerfile (lignes 21-25)
```dockerfile
# AVANT
COPY modules/axelor-open-suite/ ./modules/axelor-open-suite/
COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/

# APRÈS
COPY modules/axelor-open-suite/ ./modules/axelor-open-suite/
# (inclut maintenant axelor-vecia-crm)
```

**Résultat** : ❌ CSV toujours pas importé (hypothèse fausse)

---

## 🎯 Ce Qui Doit Être Fait Demain

### Objectif : REVERTER à structure propre + créer field via Studio UI

### Étape 1 : Reverter Déplacement Module

**Commandes** :
```bash
# 1. Déplacer module
mv modules/axelor-open-suite/axelor-vecia-crm modules/axelor-vecia-crm

# 2. Modifier settings.gradle (ligne 68)
# Remplacer:
#   def customModuleDir = file("modules/axelor-open-suite/axelor-vecia-crm")
# Par:
#   def customModuleDir = file("modules/axelor-vecia-crm")

# 3. Modifier Dockerfile (ligne 22)
# Ajouter après "COPY modules/axelor-open-suite/":
#   COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/

# 4. Rebuild
./gradlew clean build
docker-compose build --no-cache axelor
docker-compose down -v && docker-compose up -d
```

**Fichiers à modifier** :
- `settings.gradle` (1 ligne)
- `Dockerfile` (1 ligne à ajouter)

---

### Étape 2 : Créer Custom Field via Studio UI

**Interface** : http://localhost:8080

**Navigation** :
1. Login → Studio
2. Models → Partner (ou Custom Fields)
3. JSON Field → contactAttrs
4. Add Field:
   - Name: `provenance`
   - Type: `String`
   - Widget: `Selection`
   - Selection: `contact-provenance-select`
   - Show if: `isContact == true`
   - Visible in grid: `true`

**Temps** : ~2 minutes

---

### Étape 3 : Documentation

**Fichiers à mettre à jour** :
1. `.claude/knowledge-bases/kb-lowcode-standards.md`
   - Ajouter section limitation CSV data-init
2. `.claude/agents/agent-customization.md`
   - Update workflow custom fields (Studio UI recommandé)

---

## 📊 Fichiers du Projet Impactés

### Fichiers Modifiés (à reverter)
- ✏️ `settings.gradle`
- ✏️ `Dockerfile`

### Fichiers Ajoutés (à garder après revert)
- ✅ `modules/axelor-vecia-crm/src/main/resources/data-init/input-config.xml`
- ✅ `modules/axelor-vecia-crm/src/main/resources/data-init/input/meta_metaJsonField.csv`
- ✅ `modules/axelor-vecia-crm/src/main/resources/views/Selections.xml`
- ✅ `modules/axelor-vecia-crm/src/main/resources/views/PartnerExtension.xml`

**Note** : Ces fichiers ne servent pas pour CSV import, mais :
- Selections.xml est UTILISÉ (chargé par Axelor) ✅
- PartnerExtension.xml est UTILISÉ (affiche field) ✅
- CSV files = documentation de ce qu'on voulait (à garder ou supprimer)

---

## 🔍 Pourquoi Ça N'a Pas Marché

### Hypothèses Testées

1. ❌ **Format XML** → Pas supporté pour data-import
2. ❌ **CSV externe** → Ignoré par Axelor
3. ❌ **CSV dans axelor-open-suite/** → Toujours ignoré

### Conclusion

**Axelor whitelist** : Seuls modules core (base, message, studio) ont CSV auto-import

**Non documenté** : Aucune doc officielle ne mentionne cette limitation

**Solution** : Studio UI (interface web, fonctionne garantie)

---

## 📦 Contenu .diagnostic-archives/

Ce dossier contient :
- ✅ README.md (index complet)
- ✅ TODO-DEMAIN.md (checklist actions)
- ✅ decision-analysis-module-location.md (analyse reverter vs garder)
- ✅ custom-fields-xml-import-diagnostic-rex.md (échec XML, 1h)
- ✅ csv-import-not-working-diagnostic.md (échec CSV, 40min)
- ✅ csv-import-final-analysis.md (échec déplacement, 30min)
- ✅ CONTEXTE-COMPLET.md (ce fichier)

**Total documentation** : ~45 KB, 7 fichiers

---

## 🚀 Résumé Exécutif

**Ce qui a été tenté** :
- 3 approches low-code (XML, CSV, CSV+déplacement)
- 2h30 diagnostic méthodique
- Tests exhaustifs (JAR, logs, DB, structure)

**Ce qui a été appris** :
- CSV auto-import = whitelist Axelor modules uniquement
- Studio UI = seule solution fiable pour customs
- Structure modules : customs SÉPARÉS de axelor-open-suite/

**Ce qui doit être fait** :
- Reverter module (10 min)
- Studio UI field (2 min)
- Doc .claude/ (10 min)
- Push (3 min)

**Total demain** : ~25 minutes

---

## 📞 Contact Points

**Commits clés** :
- Baseline stable : `67815ca`
- CSV attempt : `75bdaa5`
- Move test : `e562110` ← **CURRENT**

**Fichiers référence** :
- Guide demain : `TODO-DEMAIN.md`
- Analyse décision : `decision-analysis-module-location.md`

**Backup** :
- Dossier : `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/`
- Safe : ✅ Dans projet (pas /tmp/)
- Git ignored : ⚠️ À vérifier (.gitignore)

---

**Créé** : 2025-10-05 22:05
**Validité** : Jusqu'à revert (demain)
**Priorité** : Haute (structure temporaire à corriger)
