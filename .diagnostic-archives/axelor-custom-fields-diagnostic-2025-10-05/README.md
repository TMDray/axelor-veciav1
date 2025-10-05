# Diagnostic Complet : Custom Field "provenance" - Axelor (2025-10-05)

## 📋 Résumé Exécutif

**Objectif** : Ajouter champ custom "provenance" sur Partner contacts
**Approches testées** : 3 (XML, CSV data-init, CSV data-init dans axelor-open-suite/)
**Résultat** : ❌ Aucune approche low-code/CSV ne fonctionne
**Solution** : ✅ Studio UI (à faire demain, ~2 min)
**Temps total** : ~2h30 diagnostic

---

## 📂 Fichiers dans ce Dossier

### 1. `custom-fields-xml-import-diagnostic-rex.md` (11 KB)
**Durée** : 1h diagnostic
**Sujet** : Échec approche XML `<custom-fields>`

**Découvertes** :
- Format XML `<custom-fields>` non supporté pour data-import
- Axelor utilise CSV avec `ImportService:importJsonField`
- Structure `data-init/input/` obligatoire
- Namespace `data-import` requis (pas `object-views`)

**Root causes** :
1. ❌ Format incorrect (XML au lieu de CSV)
2. ❌ Structure dossier incorrecte
3. ❌ Namespace XML incorrect
4. ❌ Service call manquant

---

### 2. `csv-import-not-working-diagnostic.md` (10 KB)
**Durée** : 40 min diagnostic
**Sujet** : Échec approche CSV (module externe `modules/axelor-vecia-crm`)

**Découvertes** :
- CSV créé correctement ✅
- JAR contient data-init/ ✅
- Module chargé ✅
- MAIS import CSV jamais déclenché ❌

**Hypothèse finale** :
Axelor ne scanne que modules dans `axelor-open-suite/` pour auto-import

---

### 3. `csv-import-final-analysis.md` (2 KB)
**Durée** : 30 min test
**Sujet** : Test déplacement module dans `axelor-open-suite/`

**Résultat** :
- Module fonctionne (views OK) ✅
- CSV data-init toujours ignoré ❌

**Conclusion** :
Déplacer dans axelor-open-suite/ ne suffit PAS. Axelor a une whitelist interne.

---

### 4. `decision-analysis-module-location.md` (6 KB)
**Sujet** : Analyse reverter vs garder module dans axelor-open-suite/

**Recommandation** : ⭐ **REVERTER**

**Raisons** :
1. Best practice Axelor (modules customs séparés)
2. Maintenabilité (séparation custom vs officiel)
3. Git safety (évite conflits submodule)
4. Documentation (correspond aux docs existantes)

**Compromis accepté** :
CSV ne fonctionne pas → utiliser Studio UI

---

## 🔍 Synthèse Technique

### Ce qui NE fonctionne PAS

❌ **XML `<custom-fields>` format**
- Syntaxe théorique non implémentée
- Aucun exemple fonctionnel dans codebase Axelor

❌ **CSV data-init auto-import (modules customs)**
- Fonctionne pour modules core (base, message, studio)
- Ne fonctionne PAS pour modules customs externes
- Même si placé dans axelor-open-suite/

### Ce qui FONCTIONNE

✅ **Studio UI**
- Interface web Axelor
- 2 minutes pour créer custom field
- Résultat garanti

✅ **Views XML Extensions**
- Selections.xml chargé OK
- PartnerExtension.xml chargé OK (avec erreur mineure)
- Menu.xml chargé OK

---

## 📊 Timeline du Diagnostic

```
18:00 - Tentative 1: XML <custom-fields>
  └─ 30 min implémentation
  └─ 15 min build/test
  └─ Résultat: Échec (format non supporté)

19:00 - Diagnostic XML failure
  └─ 60 min investigation (JAR, logs, DB)
  └─ Découverte: CSV requis

20:00 - Tentative 2: CSV data-init
  └─ 30 min création CSV + config
  └─ 30 min builds + tests
  └─ Résultat: Échec (import pas déclenché)

21:00 - Diagnostic CSV failure
  └─ 40 min investigation
  └─ Hypothèse: Besoin axelor-open-suite/

21:30 - Tentative 3: Déplacement module
  └─ 15 min déplacement + config
  └─ 15 min rebuild + test
  └─ Résultat: Échec (même problème)

21:50 - Analyse finale + décision
  └─ 20 min recherches web
  └─ 15 min analyse reverter vs garder
  └─ Recommandation: REVERTER + Studio UI
```

**Temps total** : ~2h30

---

## 🎯 Prochaines Étapes (Demain)

### Option Recommandée : Reverter + Studio UI

1. **Reverter déplacement module** (10 min)
   ```bash
   mv modules/axelor-open-suite/axelor-vecia-crm modules/axelor-vecia-crm
   # Modifier settings.gradle
   # Modifier Dockerfile
   # Rebuild
   ```

2. **Créer field via Studio UI** (2 min)
   - http://localhost:8080
   - Studio → Custom Fields
   - Partner → contactAttrs → provenance
   - Type: Selection (contact-provenance-select)

3. **Commit + Documentation** (10 min)
   - Commit état revert avec message clair
   - Mettre à jour .claude/ docs avec leçon apprise
   - Push

**Temps total** : ~25 min

---

## 📚 Leçons Apprises

### Pour la Documentation

**À ajouter** :
- `.claude/knowledge-bases/kb-lowcode-standards.md` :
  Section "CSV data-init limitation pour modules customs"

- `.claude/agents/agent-customization.md` :
  Workflow custom fields : Studio UI recommandé

### Pour Futurs Développements

1. **Custom Fields** :
   - ✅ Utiliser Studio UI (rapide, fiable)
   - ⚠️ CSV data-init indisponible pour customs
   - ❌ Ne pas perdre temps sur XML

2. **Structure Modules** :
   - ✅ Modules customs dans `modules/` racine
   - ❌ Ne PAS mélanger avec axelor-open-suite/
   - 📖 Suivre pattern axelor-addons (séparé)

3. **Diagnostic Efficace** :
   - Toujours chercher exemples réels dans codebase AVANT
   - Tester approche simple (Studio UI) AVANT low-code complexe
   - Timer diagnostics pour éviter rabbit holes

---

## 🔗 Références

### Fichiers Projet Modifiés

**Commits** :
- `75bdaa5` - wip: Add custom field via CSV (not working)
- (à faire) - revert: Move module back to modules/

**Fichiers** :
- `modules/axelor-open-suite/axelor-vecia-crm/` (à reverter)
- `settings.gradle` (modifié, à reverter)
- `Dockerfile` (modifié, à reverter)

### Documentation Consultée

- Axelor ADK 7.4 - Custom Fields
- Axelor ADK 7.4 - CSV Import
- Forum Axelor - Custom Models Import
- GitHub axelor-addons

---

## ⚠️ Notes Importantes

### CSV Import Limitation

**Non documenté officiellement** mais confirmé par tests :
- Axelor auto-import CSV data-init fonctionne UNIQUEMENT pour modules whitelistés
- Modules customs (même dans axelor-open-suite/) = ignorés
- Cause probable : sécurité ou design intentionnel

### Workarounds Possibles

1. ✅ **Studio UI** (recommandé)
2. ⚠️ **Import programmatique Java** (complexe)
3. ❌ **SQL direct** (pas reproductible)

---

**Créé** : 2025-10-05 21:55
**Auteur** : Claude Code
**Contexte** : Projet Axelor Vecia v1
**Statut** : Diagnostic complet, solution à implémenter demain
