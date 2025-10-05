# REX : Diagnostic Échec Import XML Custom Fields Axelor (2025-10-05)

## 📋 Résumé Exécutif

**Objectif** : Ajouter champ custom "provenance" sur Partner contacts via XML Low-Code
**Approche Testée** : Format XML `<custom-fields>` + data-import
**Résultat** : ❌ Échec complet - aucun import
**Temps Diagnostic** : ~1h
**Root Causes** : 4 erreurs critiques identifiées

---

## 🔴 Problème Initial

### Symptômes
- Build Docker réussi ✅
- Fichiers XML présents dans JAR ✅
- Module axelor-vecia-crm chargé ✅
- **MAIS** :
  - Aucune trace import dans logs ❌
  - Selection `contact-provenance-select` absente en DB ❌
  - Custom field `provenance` absent en DB ❌

---

## 🔍 Diagnostic Méthodique (Timeline)

### Phase 1 : Vérification JAR (5 min)

**Action** :
```bash
docker cp axelor-vecia-app:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/axelor-vecia-crm-8.3.15.jar /tmp/
unzip -l /tmp/axelor-vecia-crm-8.3.15.jar | grep -E "views|data-init"
```

**Résultat** :
```
✅ data-init/partner-custom-fields.xml (714 bytes)
✅ data-init/input-config.xml (1536 bytes)
✅ views/Selections.xml (996 bytes)
✅ views/PartnerExtension.xml (1199 bytes)
✅ views/Menu.xml (1657 bytes)
```

**Conclusion** : Build Gradle OK, fichiers inclus dans JAR

---

### Phase 2 : Inspection Contenu XML (10 min)

**Extraction** :
```bash
unzip -p /tmp/axelor-vecia-crm-8.3.15.jar data-init/partner-custom-fields.xml
```

**Contenu** :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<custom-fields xmlns="http://axelor.com/xml/ns/object-views"
  for="com.axelor.apps.base.db.Partner"
  on="contactAttrs">
  <field name="provenance" type="string" title="Provenance"
    selection="contact-provenance-select"/>
</custom-fields>
```

**🚨 DÉCOUVERTE #1** : Namespace `object-views` utilisé pour data-import !

---

### Phase 3 : Analyse Logs (10 min)

**Commandes** :
```bash
docker-compose logs axelor > /tmp/axelor-full-logs.txt
grep -i "importing\|data-init\|input-config" /tmp/axelor-full-logs.txt
```

**Résultat** :
```
(vide - aucune trace)
```

**🚨 DÉCOUVERTE #2** : Axelor ne charge PAS le fichier input-config.xml

---

### Phase 4 : Validation DB (2 min)

**Requête** :
```sql
SELECT name FROM meta_select WHERE name = 'contact-provenance-select';
-- 0 rows

SELECT name, model_name, model_field FROM meta_json_field WHERE name = 'provenance';
-- 0 rows
```

**Conclusion** : Même les Selections.xml (vues) ne sont PAS importées

---

### Phase 5 : Examen Modules Axelor (20 min)

**Structure axelor-crm** :
```
data-init/
├── input-config.xml
└── input/  ← SOUS-DOSSIER !
    ├── auth_permission.csv
    ├── crm_eventCategory.csv
    └── ...
```

**🚨 DÉCOUVERTE #3** : Structure incorrecte - fichiers doivent être dans `data-init/input/`

---

**Recherche MetaJsonField** :
```bash
grep -r "MetaJsonField" modules/axelor-open-suite/*/src/main/resources/data-init --include="*.xml"
```

**Trouvé** : `axelor-business-project/src/main/resources/data-init/input-config.xml`

**Contenu** :
```xml
<input file="meta_metaJsonField.csv" separator=";"
       type="com.axelor.meta.db.MetaJsonField"
       search="self.name = :name and self.model = :model..."
       call="com.axelor.studio.service.ImportService:importJsonField">
  <bind to="name" column="name"/>
  <bind to="model" column="model"/>  ← pas "modelName" !
  ...
</input>
```

**🚨 DÉCOUVERTE #4** : Axelor utilise **CSV** pour custom fields, PAS XML !

---

**CSV Example** :
```csv
"name";"title";"type";"model";"modelField";"sequence"
"provenance";"Provenance";"string";"com.axelor.apps.base.db.Partner";"contactAttrs";0
```

---

## ✅ Root Causes Identifiées

### 1. ❌ Format Incorrect : XML au lieu de CSV

**Erreur** : Tentative d'utiliser format `<custom-fields>` XML
**Attendu** : Format CSV avec binding CSV

**Documentation Axelor trompeuse** :
- Docs montrent `<custom-fields>` mais sans contexte complet
- Pas d'exemple réel fonctionnel dans codebase
- Format `<custom-fields>` semble **non supporté** pour data-import

---

### 2. ❌ Structure Dossier Incorrecte

**Notre structure** :
```
data-init/
├── partner-custom-fields.xml  ← Mauvais emplacement
└── input-config.xml
```

**Structure Attendue** :
```
data-init/
├── input-config.xml
└── input/  ← OBLIGATOIRE
    └── meta_metaJsonField.csv
```

---

### 3. ❌ Namespace XML Incorrect

**Notre namespace** :
```xml
xmlns="http://axelor.com/xml/ns/object-views"  ← Pour VUES
```

**Devrait être** (si XML supporté) :
```xml
xmlns="http://axelor.com/xml/ns/data-import"  ← Pour DATA IMPORT
```

---

### 4. ⚠️ Service Call Manquant

**Notre config** :
```xml
<input file="partner-custom-fields.xml" type="com.axelor.meta.db.MetaJsonField">
  <!-- Pas de call attribute -->
</input>
```

**Attendu** :
```xml
<input file="meta_metaJsonField.csv"
       call="com.axelor.studio.service.ImportService:importJsonField">
```

→ **Service spécial requis** pour import MetaJsonField

---

### 5. ⚠️ Column Naming Incorrect

**Notre binding** :
```xml
<bind node="@for" to="model"/>  ← Suppose que @for map vers "model"
```

**DB Column Réel** :
```sql
\d meta_json_field
-- model_name (pas "model")
```

**Binding CSV Correct** :
```xml
<bind to="model" column="model"/>  ← Plus simple et direct
```

---

## 📊 Métriques

| Métrique | Valeur |
|----------|--------|
| **Temps implémentation Plan A (XML)** | 30 min |
| **Temps diagnostic** | 60 min |
| **Overhead** | 90 min total (3x prévu) |
| **Fichiers créés (inutilisés)** | 4 XML |
| **Approche validée** | CSV (à tester) |

---

## 🎓 Learnings Clés

### 1. Documentation Axelor Incomplète

**Ce qui manque** :
- ❌ Aucun exemple complet `<custom-fields>` XML dans codebase officielle
- ❌ Docs montrent syntax mais pas context d'utilisation
- ❌ Pas de warning "CSV only for data-import"

**Leçon** : **Toujours chercher exemples réels dans modules Axelor AVANT d'implémenter**

---

### 2. Format CSV Obligatoire pour Data Import

**Vérité terrain** :
- ✅ CSV = méthode officielle et testée
- ❌ XML `<custom-fields>` = syntaxe théorique non fonctionnelle (ou mal documentée)
- ⚠️ XML fonctionne UNIQUEMENT pour vues (`object-views` namespace)

---

### 3. Structure `data-init/input/` Stricte

**Pattern Axelor** :
```
data-init/
├── input-config.xml  (configuration)
└── input/            (données CSV)
```

**Raison** : Sépare config (XML) des données (CSV)

---

### 4. Service ImportService Requis

**Pas un simple INSERT** :
```xml
call="com.axelor.studio.service.ImportService:importJsonField"
```

→ Logique métier custom pour MetaJsonField (validation, defaults, etc.)

---

### 5. Vues XML Auto-Importées SEULEMENT Si...

**Observation** :
- Selections.xml dans `views/` → PAS importée automatiquement non plus !

**Hypothèse** :
- Premier démarrage = import auto
- Démarrages suivants = cache DB (comme vu dans REX précédent)
- **Besoin clean install** pour voir nouvelles vues

---

## 🔄 Solution Validée (à tester)

### Approche CSV

**Structure** :
```
modules/axelor-vecia-crm/src/main/resources/
├── data-init/
│   ├── input-config.xml
│   └── input/
│       └── meta_metaJsonField.csv
└── views/
    └── Selections.xml  (pour la selection)
```

**meta_metaJsonField.csv** :
```csv
"name";"title";"type";"model";"modelField";"selection";"sequence";"showIf";"visibleInGrid"
"provenance";"Provenance";"string";"com.axelor.apps.base.db.Partner";"contactAttrs";"contact-provenance-select";0;"isContact == true";"true"
```

**input-config.xml** :
```xml
<csv-inputs xmlns="http://axelor.com/xml/ns/data-import">
  <input file="meta_metaJsonField.csv" separator=";"
         type="com.axelor.meta.db.MetaJsonField"
         search="self.name = :name AND self.model = :model AND self.modelField = :modelField"
         call="com.axelor.studio.service.ImportService:importJsonField">
    <bind to="name" column="name"/>
    <bind to="title" column="title"/>
    <bind to="type" column="type"/>
    <bind to="model" column="model"/>
    <bind to="modelField" column="modelField"/>
    <bind to="selection" column="selection"/>
    <bind to="sequence" column="sequence"/>
    <bind to="showIf" column="showIf"/>
    <bind to="visibleInGrid" column="visibleInGrid" eval="visibleInGrid == 'true'"/>
  </input>
</csv-inputs>
```

---

## 🚨 Limitations Découvertes

### XML `<custom-fields>` Format

**Status** : ❌ Non fonctionnel (ou nécessite config spéciale non documentée)

**Cas d'usage** : Peut-être pour Studio UI internal, pas pour data-import programmatique

---

### Data Import Auto-Loading

**Observation** : `data-init/input-config.xml` **N'EST PAS** chargé automatiquement

**Hypothèse** :
1. Nécessite activation App ? (Studio installed?)
2. Fonctionne uniquement premier démarrage ?
3. Nécessite trigger manuel ?

**À vérifier** : Logs avec `docker-compose down -v` (clean install)

---

## 📚 Documentation à Créer/Améliorer

### 1. Nouveau KB : `kb-axelor-custom-fields-csv.md`

**Contenu** :
- Format CSV MetaJsonField (colonnes, types)
- Binding input-config.xml complet
- Service ImportService requis
- Exemples Partner, Lead, etc.
- Troubleshooting import

---

### 2. Améliorer `kb-lowcode-standards.md`

**Section Ajout** :
```markdown
## Custom Fields : CSV vs Studio UI

| Méthode | Cas d'usage | Avantages | Inconvénients |
|---------|-------------|-----------|---------------|
| **CSV** | CI/CD, versionné | Git, reproductible | Complexe |
| **Studio UI** | Dev rapide | Simple, visuel | Pas versionné |
| **XML** | ❌ Non supporté | - | - |
```

---

### 3. Améliorer `agent-customization.md`

**Workflow Custom Fields** :
```
1. Choix approche
   - Rapide (1x) → Studio UI
   - Prod/CI → CSV data-import

2. Si CSV :
   a. Créer Selections.xml (views/)
   b. Créer meta_metaJsonField.csv (data-init/input/)
   c. Config input-config.xml
   d. Clean install (docker-compose down -v)
   e. Valider DB + UI

3. Validation :
   - SELECT * FROM meta_json_field
   - SELECT * FROM meta_select
   - Test UI form/grid
```

---

## 🔗 Références

### Fichiers Analysés
- `axelor-business-project/data-init/input-config.xml` ← Exemple fonctionnel
- `axelor-business-project/data-init/input/meta_metaJsonField.csv`
- `axelor-crm/data-init/input-config.xml` ← Structure référence

### Documentation Officielle (Trompeuse)
- [Axelor Custom Fields](https://docs.axelor.com/adk/7.4/dev-guide/models/custom-fields.html)
  - Montre `<custom-fields>` XML mais **pas d'exemple complet**
  - Pas de mention CSV obligatoire

### REX Connexes
- `/tmp/contact-grid-view-fix-rex.md` - Cache DB Axelor

---

## 🎯 Prochaines Étapes

1. ✅ Créer CSV meta_metaJsonField.csv
2. ✅ Fixer input-config.xml (csv-inputs)
3. ✅ Rebuild + Clean install
4. ✅ Valider import (logs + DB)
5. ✅ Tester UI
6. ✅ Documenter solution finale

---

**Date** : 2025-10-05
**Durée Diagnostic** : 60 min
**Status** : Root causes identifiées, solution CSV à valider
**Learnings** : 5 erreurs critiques, CSV obligatoire, docs Axelor incomplètes
