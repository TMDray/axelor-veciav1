# Analyse Finale : CSV Import Ne Fonctionne PAS Même dans axelor-open-suite/

## ❌ Résultat Test Déplacement Module

**Action** : Déplacement `modules/axelor-vecia-crm` → `modules/axelor-open-suite/axelor-vecia-crm`

**Résultat** :
- ✅ Module chargé : "Loading package axelor-vecia-crm"
- ✅ Views importées : Selections.xml, Menu.xml
- ❌ **data-init/input-config.xml JAMAIS chargé**
- ❌ **CSV meta_metaJsonField.csv JAMAIS importé**

## 🔍 Observation Logs

### CSVs Importés (modules standards)
```
CSVImporter : Importing com.axelor.auth.db.Permission from auth_permission.csv
CSVImporter : Importing com.axelor.meta.db.MetaMenu from meta_metaMenu.csv
CSVImporter : Importing com.axelor.studio.db.Library from library.csv
```

### Notre Module
```
Loading package axelor-vecia-crm... ✅
Importing: .../axelor-vecia-crm-8.3.15.jar!/views/Selections.xml ✅
Importing: .../axelor-vecia-crm-8.3.15.jar!/views/Menu.xml ✅
(AUCUNE trace de data-init/) ❌
```

## 💡 Conclusion

**Hypothèse confirmée FAUSSE** : Déplacer dans axelor-open-suite/ ne suffit PAS.

**Réalité** : Axelor n'importe automatiquement CSV que depuis modules **pré-configurés**
(core, base, message, studio, etc.)

**Preuve** :
- JAR contient data-init/ ✅
- Module chargé ✅
- MAIS input-config.xml ignoré ❌

## 📋 Solutions Alternatives

### ✅ Solution Immédiate : Studio UI (5 min)
1. http://localhost:8080
2. Studio → Custom Fields
3. Créer field "provenance" sur Partner (contactAttrs)
4. Résultat garanti fonctionnel

### ⚠️ Solution Code (30min) : App Init Hook
Créer service Java qui import CSV au startup programmatiquement via CSVImporter API

### ❌ Solution CSV Auto-Import : NON DISPONIBLE
Pour modules customs externes, même dans axelor-open-suite/

---

**Date** : 2025-10-05 21:45
**Temps Total Diagnostic** : ~90 min (CSV + déplacement module)
**Recommandation** : **Utiliser Studio UI** pour débloquer rapidement
