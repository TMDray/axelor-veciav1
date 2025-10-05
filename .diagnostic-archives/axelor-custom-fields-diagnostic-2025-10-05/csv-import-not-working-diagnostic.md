# Diagnostic : Import CSV meta_metaJsonField Non Fonctionnel (2025-10-05)

## 🔴 Problème Actuel

**Symptôme** : Fichiers CSV présents dans JAR mais **JAMAIS importés** par Axelor

### État Actuel
- ✅ JAR construit avec `data-init/input/meta_metaJsonField.csv`
- ✅ JAR construit avec `data-init/input-config.xml`
- ✅ Module `axelor-vecia-crm` chargé (logs confirment "Loading package axelor-vecia-crm")
- ❌ **AUCUNE trace d'import CSV** dans les logs
- ❌ **Champ provenance ABSENT** en DB (0 rows)
- ❌ **Selection contact-provenance-select ABSENTE** en DB (0 rows)

---

## 🔍 Hypothèses Testées

### Hypothèse 1 : JAR ne contient pas les fichiers ❌ FAUSSE
**Test** : `jar tf axelor-vecia-crm-8.3.15.jar | grep data-init`
**Résultat** :
```
data-init/
data-init/input/
data-init/input/meta_metaJsonField.csv
data-init/input-config.xml
```
✅ Fichiers présents dans JAR local

### Hypothèse 2 : Docker utilise ancien JAR ❌ FAUSSE (après rebuild)
**Test** : `docker-compose build --no-cache`
**Résultat** : Build réussi, nouveau JAR utilisé
**Vérification** : Module chargé dans logs : "Loading package axelor-vecia-crm"

### Hypothèse 3 : Clean install nécessaire ❌ TESTÉE SANS SUCCÈS
**Test** : `docker-compose down -v && docker-compose up -d`
**Résultat** : DB recréée, mais toujours aucun import

### Hypothèse 4 : JAR dans container diffère du JAR local ⚠️ À VÉRIFIER
**Problème** : `docker exec jar tf` ne retourne rien pour data-init
**À faire** : Vérifier si JAR dans WAR contient bien data-init/

---

## 📊 Comparaison avec Modules Axelor Standards

### Modules Axelor Officiels (qui FONCTIONNENT)
**Exemple : axelor-message**

**Logs observés** :
```
INFO com.axelor.data.csv.CSVImporter : Importing com.axelor.auth.db.Permission from auth_permission.csv
INFO com.axelor.data.csv.CSVImporter : Importing com.axelor.meta.db.MetaMenu from meta_metaMenu.csv
```

**Emplacement fichiers** :
```
axelor-message.jar:
  data-init/
    input-config.xml
    input/
      auth_permission.csv
      meta_metaMenu.csv
```

### Notre Module (qui NE FONCTIONNE PAS)
**Structure** :
```
axelor-vecia-crm.jar:
  data-init/
    input-config.xml
    input/
      meta_metaJsonField.csv
```

**Logs observés** :
```
(rien - aucune trace d'import)
```

---

## 🚨 Différence Critique Découverte

### Axelor Message : Module DANS axelor-open-suite
```
modules/axelor-open-suite/axelor-message/
  src/main/resources/data-init/
```

### Notre module : Module CUSTOM hors axelor-open-suite
```
modules/axelor-vecia-crm/
  src/main/resources/data-init/
```

**Hypothèse critique** : Axelor n'importe les CSV que depuis modules **axelor-open-suite** ?

---

## 🔬 Recherche Documentation Axelor

### Data Import Documentation
**Source** : https://docs.axelor.com/adk/7.4/dev-guide/data/import.html

**Points clés** :
1. **CSV Import Config** : `data-init/input-config.xml`
2. **CSV Files** : `data-init/input/*.csv`
3. **Auto-loading** : Axelor charge automatiquement au premier démarrage

**⚠️ CE QUI MANQUE DANS LA DOC** :
- Aucune mention si modules customs hors axelor-open-suite sont supportés
- Aucun exemple de module custom avec data-init
- Pas de troubleshooting si import ne se déclenche pas

---

## 🔍 Analyse Logs Complets

### Logs Import CSV Standards (axelor-message)
```
INFO com.axelor.data.xml.XMLImporter : Importing: auth.xml
INFO com.axelor.data.xml.XMLImporter : Importing: jobs.xml
INFO com.axelor.data.csv.CSVImporter : Importing com.axelor.auth.db.Permission from auth_permission.csv
```

**Pattern** :
1. XMLImporter charge config XML
2. CSVImporter importe les CSV

### Logs Notre Module (axelor-vecia-crm)
```
INFO com.axelor.meta.loader.ModuleManager : Loading package axelor-vecia-crm...
(puis plus rien sur data-init)
```

**Pattern manquant** :
- ❌ Aucun XMLImporter pour input-config.xml
- ❌ Aucun CSVImporter pour meta_metaJsonField.csv

**Conclusion** : Axelor **ne détecte PAS** notre `input-config.xml`

---

## 💡 Hypothèse Finale : Chemin de Découverte des Modules

### Théorie
Axelor scanne uniquement certains emplacements pour `data-init/` :
1. Modules core (axelor-core)
2. Modules axelor-open-suite
3. **PEUT-ÊTRE PAS** les modules customs externes

### Test à Faire
Vérifier le code source Axelor pour voir comment il découvre les `data-init/input-config.xml`

**Recherche dans codebase Axelor** :
```
Chercher : DataImportService, CSVImporter initialization, module scanning
```

---

## 🎯 Solutions Potentielles

### Solution 1 : Vérifier Module Declaration
**Fichier** : `module.properties`
**Vérifier** :
```properties
name = axelor-vecia-crm
version = 8.3.15
title = Axelor Vecia CRM
description = Custom CRM module for Vecia AI Agency
# Est-ce qu'il manque une propriété pour activer data-init ?
```

**Comparer avec** : `axelor-message/module.properties`

---

### Solution 2 : Déplacer Module dans axelor-open-suite
**Test** : Déplacer `axelor-vecia-crm` dans `modules/axelor-open-suite/`

**Avantage** : Si Axelor scanne uniquement ce dossier, ça fonctionnerait
**Inconvénient** : Mélange code custom et code officiel

---

### Solution 3 : Import Programmatique via Service
**Alternative** : Au lieu de CSV auto-import, créer un service Java qui importe au démarrage

**Code** :
```java
@Module
public class VeciaCrmModule extends AxelorModule {
  @Override
  protected void configure() {
    bind(StartupListener.class).to(CustomFieldsImporter.class);
  }
}

public class CustomFieldsImporter implements StartupListener {
  @Override
  public void onStartup() {
    // Importer meta_metaJsonField.csv programmatiquement
  }
}
```

**Avantage** : Contrôle total
**Inconvénient** : Plus complexe, pas low-code

---

### Solution 4 : Utiliser Demo Data au lieu de data-init
**Hypothèse** : Peut-être que `data-demo/` fonctionne mieux que `data-init/`

**Test** : Renommer `data-init/` en `data-demo/`

**Documentation Axelor** :
- `data-init/` : Données essentielles (toujours importées)
- `data-demo/` : Données de démo (optionnelles)

---

### Solution 5 : Vérifier Application Properties
**Fichier** : `application.properties` ou `axelor-config.properties`

**Propriétés à vérifier** :
```properties
# Est-ce qu'il faut activer explicitement l'import ?
data.import.enabled = true
data.export.dir = /path/to/export
```

---

## 🔧 Actions Immédiates Recommandées

### 1. Vérifier module.properties
Comparer avec un module Axelor standard

### 2. Chercher dans Code Source Axelor
**Fichier cible** : `com.axelor.data.csv.CSVImporter`
**Recherche** : Comment il trouve les `input-config.xml`

### 3. Tester Déplacement dans axelor-open-suite
Si scan limité à ce dossier, ça confirmerait l'hypothèse

### 4. Vérifier Logs Startup Complets
Chercher messages d'erreur silencieux sur input-config.xml

---

## 📝 Notes de Boucle Détectée

### Pourquoi je boucle ?
1. ✅ Fichiers créés correctement
2. ✅ JAR construit avec fichiers
3. ✅ Docker rebuild OK
4. ✅ Module chargé
5. ❌ **Import ne se déclenche JAMAIS**

**Raison** : Je n'ai pas identifié **POURQUOI Axelor ne scanne pas notre input-config.xml**

### Ce que j'ai testé (sans succès)
- Rebuild JAR
- Rebuild Docker
- Clean install (down -v)
- Vérification structure fichiers
- Vérification contenu JAR

### Ce que je N'AI PAS testé
- ❌ Code source Axelor (comment il découvre les configs)
- ❌ Comparaison module.properties
- ❌ Déplacement dans axelor-open-suite
- ❌ Logs DEBUG complets du démarrage
- ❌ Vérification WAR final (est-ce que JAR est dedans ?)

---

## 🎯 Plan d'Action Structuré

### Phase 1 : Diagnostic Approfondi (10 min)
1. Lire module.properties axelor-message vs notre module
2. Vérifier si JAR est bien dans WAR final
3. Chercher logs DEBUG Axelor sur scanning modules
4. Chercher erreurs silencieuses XML parsing

### Phase 2 : Tests Rapides (15 min)
1. Test : Déplacer module dans axelor-open-suite/
2. Test : Renommer data-init en data-demo
3. Test : Ajouter propriété dans module.properties

### Phase 3 : Solution Alternative (20 min)
Si rien ne fonctionne :
- Utiliser Studio UI (rapide, fonctionne, mais pas versionné)
- OU : Import programmatique Java
- OU : Script SQL direct

---

## 🚀 Recommandation Immédiate

**Option A (Rapide - 2 min)** : Tester Studio UI
- Créer custom field via interface
- Valider que ça fonctionne
- Exporter config pour référence

**Option B (Diagnostic - 10 min)** :
1. Vérifier WAR contient JAR
2. Comparer module.properties
3. Chercher logs DEBUG

**Option C (Test hypothèse - 5 min)** :
Déplacer module dans axelor-open-suite/ et rebuild

---

---

## 🔬 Résultats Recherches Web

### Trouvaille Critique : data-init vs data-demo

**Documentation trouvée** :
- `data-init/` = Données **essentielles** (chargées TOUJOURS)
- `data-demo/` = Données **demo** (chargées SI `data.import.demo-data = true`)

**Notre config** : `data.import.demo-data = false` (ligne 241 axelor-config.properties)

**Conclusion** : Notre `data-init/` DEVRAIT être chargé automatiquement

---

## 🎯 HYPOTHÈSE FINALE (après recherches)

### Modules Axelor vs Modules Externes

**Observation** : Tous les exemples trouvés sont dans `axelor-open-suite/`

**Hypothèse critique** :
Axelor ne scanne peut-être QUE les modules dans le sous-projet `axelor-open-suite` pour auto-import `data-init/`

**Tests à faire** :
1. ✅ Comparer module.properties (FAIT - identique à axelor-message)
2. ❌ Tester déplacement module dans axelor-open-suite/
3. ❌ Chercher dans code source Axelor comment il découvre data-init/

---

## 📋 PLAN D'ACTION FINAL

### Option A : Déplacer Module (Test Rapide - 5 min)
1. Déplacer `modules/axelor-vecia-crm/` → `modules/axelor-open-suite/axelor-vecia-crm/`
2. Rebuild
3. Redémarrer
4. Valider import

**Avantage** : Test rapide de l'hypothèse
**Inconvénient** : Mélange code custom et officiel

### Option B : Solution Alternative Immédiate (2 min)
**Studio UI** : Créer custom field via interface web
- Rapide, fonctionne garantie
- Pas versionné Git
- Peut exporter config après

### Option C : Import Programmatique Java (30 min)
Créer service Java qui import CSV au démarrage
- Contrôle total
- Complexe
- Pas low-code

### Option D : Script SQL Direct (5 min)
Insérer manuellement dans `meta_json_field`
- Ultra-rapide
- Pas reproductible facilement
- Pas low-code

---

**Date** : 2025-10-05 21:10
**Durée Boucle** : ~40 min
**Raison Boucle** : Hypothèse fondamentale non testée (découverte des modules par Axelor)
**Découverte** : Possiblement besoin module dans axelor-open-suite/
**Prochaine Étape** : Présenter plan au user pour validation
