# Agent Template : Custom Fields Axelor via API REST

**Type** : Agent spécialisé création custom fields
**Usage** : Automatisation ajout champs customs sur modèles Axelor
**Méthode** : Script Python + API REST
**Temps** : ~5 min par field (après setup initial)

---

## 🎯 Objectif Agent

Cet agent permet de créer des custom fields (MetaJsonField) sur n'importe quel modèle Axelor de manière :
- ✅ **Automatisée** : Script Python réutilisable
- ✅ **Versionnée** : Configuration Git-tracked
- ✅ **Reproductible** : Même résultat à chaque exécution
- ✅ **Sans rebuild** : Aucune recompilation nécessaire

---

## 📋 Prérequis

### 1. Structure Projet
```
axelor-project/
├── scripts/
│   └── custom-fields/
│       ├── import-custom-fields.py    # Script principal
│       ├── config.json                # Configuration fields
│       ├── requirements.txt           # Python deps
│       └── README.md
│
└── modules/
    └── {custom-module}/
        └── src/main/resources/
            └── views/
                └── Selections.xml     # Si field type=selection
```

### 2. Dépendances
```bash
pip install requests
```

### 3. Axelor Running
App doit être accessible sur http://localhost:8080 (ou config custom)

---

## 🔄 Workflow Agent

### Étape 1 : Définir Field Requirements

**Input utilisateur** :
```
Je veux ajouter un champ "priorite" sur les Leads CRM avec valeurs : Haute, Moyenne, Basse
```

**Agent parse** :
- **Model** : Lead → `com.axelor.apps.crm.db.Lead`
- **Field name** : `priorite`
- **Type** : Selection (dropdown)
- **Selection values** : Haute, Moyenne, Basse
- **Model field** : `attrs` (pour custom JSON field)

---

### Étape 2 : Créer Selection (si type=selection)

**Fichier** : `modules/{module}/src/main/resources/views/Selections.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<object-views xmlns="http://axelor.com/xml/ns/object-views">
  <selection name="lead-priorite-select">
    <option value="haute">Haute</option>
    <option value="moyenne">Moyenne</option>
    <option value="basse">Basse</option>
  </selection>
</object-views>
```

**Action Agent** :
- Check si fichier Selections.xml existe
- Si non : Créer fichier
- Si oui : Ajouter `<selection>` dans fichier existant

---

### Étape 3 : Configurer Field dans config.json

**Fichier** : `scripts/custom-fields/config.json`

```json
{
  "axelor_url": "http://localhost:8080",
  "username": "admin",
  "password": "admin",
  "custom_fields": [
    {
      "name": "priorite",
      "title": "Priorité",
      "type": "string",
      "model": "com.axelor.apps.crm.db.Lead",
      "modelField": "attrs",
      "selection": "lead-priorite-select",
      "widget": "selection",
      "sequence": 10,
      "showIf": null,
      "visibleInGrid": true,
      "required": false,
      "readonly": false,
      "hidden": false,
      "help": "Niveau de priorité du lead"
    }
  ]
}
```

**Mapping Types** :

| Type User | Type Axelor | Widget | Notes |
|-----------|-------------|--------|-------|
| Text | string | text | Input texte simple |
| Number | integer | integer | Nombre entier |
| Decimal | decimal | decimal | Nombre décimal |
| Date | date | date | Date seule |
| DateTime | datetime | datetime | Date + heure |
| Boolean | boolean | checkbox | True/False |
| Selection | string | selection | Dropdown (nécessite selection name) |
| ManyToOne | many-to-one | many-to-one | Relation vers autre modèle |

---

### Étape 4 : Exécuter Script Python

```bash
python scripts/custom-fields/import-custom-fields.py
```

**Output attendu** :
```
[INFO] Connexion à Axelor...
[INFO] Authentification réussie
[INFO] Traitement field 'priorite' sur Lead...
[INFO] Field créé avec succès (ID: 42)
[SUCCESS] 1 field(s) créé(s), 0 erreur(s)
```

---

### Étape 5 : Vérifier Résultat

**Base de données** :
```sql
SELECT id, name, title, type, model, selection
FROM meta_json_field
WHERE name = 'priorite' AND model = 'com.axelor.apps.crm.db.Lead';
```

**Interface Axelor** :
1. Ouvrir CRM → Leads
2. Créer/éditer un Lead
3. Vérifier présence dropdown "Priorité"

**Si non visible** → Rebuild nécessaire (pour charger Selections.xml si nouveau) :
```bash
./gradlew build
docker-compose restart axelor
```

---

## 🤖 Prompts Agent

### Prompt Création Field

```
Tu es un agent spécialisé dans la création de custom fields Axelor.

CONTEXTE :
- Projet Axelor version {version}
- Module custom : {module_name}
- Script Python disponible : scripts/custom-fields/import-custom-fields.py

TÂCHE :
L'utilisateur souhaite ajouter un custom field avec ces spécifications :
{user_input}

WORKFLOW :
1. Parser les requirements utilisateur :
   - Identifier modèle cible (Partner, Lead, Product, etc.)
   - Déterminer type field (string, integer, selection, etc.)
   - Extraire contraintes (required, visible in grid, etc.)

2. Si type=selection :
   - Créer/modifier modules/{module}/src/main/resources/views/Selections.xml
   - Ajouter <selection name="{model}-{field}-select">
   - Lister <option> pour chaque valeur

3. Configurer config.json :
   - Ajouter objet field dans custom_fields[]
   - Mapper type utilisateur → type Axelor
   - Remplir tous attributs requis

4. Exécuter script :
   python scripts/custom-fields/import-custom-fields.py

5. Vérifier :
   - Check logs script
   - Query DB meta_json_field
   - Test UI si app running

6. Si besoin rebuild (nouveau Selections.xml) :
   ./gradlew build && docker-compose restart axelor

CONTRAINTES :
- NE PAS modifier code source Axelor
- NE PAS créer code Java intégré
- TOUJOURS vérifier idempotence (field peut déjà exister)
- TOUJOURS logger actions

OUTPUT :
- Fichiers créés/modifiés
- Commandes exécutées
- Résultat vérification
- Instructions pour utilisateur si actions manuelles requises
```

---

### Prompt Debugging Field

```
Tu es un agent de debugging pour custom fields Axelor.

PROBLÈME RAPPORTÉ :
{user_issue}

DIAGNOSTIC CHECKLIST :

1. Vérifier field en DB :
   SELECT * FROM meta_json_field WHERE name = '{field_name}' AND model = '{model}';

   Si absent → Script API échoué, check logs
   Si présent → Problème affichage UI

2. Vérifier Selection (si applicable) :
   SELECT * FROM meta_select WHERE name = '{selection_name}';

   Si absent → Rebuild nécessaire pour charger Selections.xml
   Si présent → OK

3. Vérifier View Extension :
   Fichier modules/{module}/src/main/resources/views/{Model}Extension.xml doit exister

   Si absent → Créer extension pour afficher field dans form

4. Check logs Axelor :
   docker-compose logs axelor | grep -i "error\|exception"

5. Check version cache :
   Vider cache browser (Ctrl+Shift+R)
   Restart Axelor : docker-compose restart axelor

SOLUTIONS COMMUNES :

Problème : Field non visible dans form
→ Solution : Créer ViewExtension.xml ou vérifier showIf condition

Problème : Selection dropdown vide
→ Solution : Rebuild app pour charger Selections.xml

Problème : "Field already exists" error
→ Solution : Normal (idempotent), field déjà créé

Problème : 401 Unauthorized dans logs script
→ Solution : Vérifier credentials dans config.json

OUTPUT :
- Diagnostic étape par étape
- Root cause identifié
- Solution proposée avec commandes
- Prevention future
```

---

## 📚 Exemples Use Cases

### Use Case 1 : Simple Text Field

**Demande** : Ajouter champ "Notes internes" sur Product

**config.json** :
```json
{
  "name": "notesInternes",
  "title": "Notes Internes",
  "type": "string",
  "model": "com.axelor.apps.base.db.Product",
  "modelField": "attrs",
  "widget": "text",
  "large": true,
  "multiline": true
}
```

**Temps** : 3 min

---

### Use Case 2 : Selection Field

**Demande** : Ajouter champ "Statut Qualification" sur Lead avec valeurs : Nouveau, Qualifié, Non Qualifié

**Étapes** :
1. Créer Selections.xml avec `lead-statut-qualification-select`
2. Config field avec `"selection": "lead-statut-qualification-select"`
3. Run script
4. Rebuild (nouveau Selections.xml)

**Temps** : 8 min (5 min + 3 min rebuild)

---

### Use Case 3 : Conditional Field

**Demande** : Ajouter "Email secondaire" sur Partner, visible seulement si isContact = true

**config.json** :
```json
{
  "name": "emailSecondaire",
  "title": "Email Secondaire",
  "type": "string",
  "model": "com.axelor.apps.base.db.Partner",
  "modelField": "contactAttrs",
  "showIf": "isContact == true",
  "visibleInGrid": false
}
```

**Note** : `modelField: "contactAttrs"` au lieu de "attrs" pour fields contact-specific

**Temps** : 4 min

---

### Use Case 4 : Required Field

**Demande** : Ajouter "Budget" (decimal) sur Opportunity, champ obligatoire

**config.json** :
```json
{
  "name": "budget",
  "title": "Budget",
  "type": "decimal",
  "model": "com.axelor.apps.crm.db.Opportunity",
  "modelField": "attrs",
  "required": true,
  "precision": 10,
  "scale": 2
}
```

**Temps** : 4 min

---

## ⚠️ Limitations & Edge Cases

### Limitation 1 : Many-to-One Complex

**Problème** : Field type "many-to-one" (relation) nécessite `targetModel` et `targetName`

**Solution** :
```json
{
  "name": "responsable",
  "type": "many-to-one",
  "targetModel": "com.axelor.auth.db.User",
  "targetName": "fullName"
}
```

**Temps supplémentaire** : +2 min (comprendre target model)

---

### Limitation 2 : Grid Column Order

**Problème** : `visibleInGrid` affiche field, mais position dans grid non contrôlable via API

**Workaround** : Créer GridView extension XML pour contrôler ordre colonnes

**Temps supplémentaire** : +10 min (create GridView.xml)

---

### Limitation 3 : Field Computation

**Problème** : Champ calculé (ex: montant TTC = HT * TVA) nécessite code Java

**Workaround** : Utiliser Studio UI pour créer computed field via Groovy script

**Alternative** : Pas de workaround via API pure (limitation Axelor)

---

## 🔧 Maintenance Template

### Mise à Jour Field Existant

**Scenario** : Changer title "Priorité" → "Niveau Priorité"

**Approche 1 : Via Script** (update config + re-run)
```json
{
  "name": "priorite",
  "title": "Niveau Priorité",  // ← Modifié
  // ... autres attributes inchangés
}
```

Run script → API détecte field existe (via search) → UPDATE title

**Approche 2 : Via SQL** (plus rapide, non versionné)
```sql
UPDATE meta_json_field
SET title = 'Niveau Priorité'
WHERE name = 'priorite' AND model = 'com.axelor.apps.crm.db.Lead';
```

---

### Suppression Field

**⚠️ DANGER** : Supprimer MetaJsonField ne supprime PAS données dans colonnes JSON

**Étapes sécurisées** :
1. Backup DB :
   ```bash
   docker-compose exec postgres pg_dump -U axelor axelor > backup.sql
   ```

2. Supprimer via API :
   ```python
   response = session.delete(
       f'http://localhost:8080/ws/rest/com.axelor.meta.db.MetaJsonField/{field_id}'
   )
   ```

3. Nettoyer données JSON (si nécessaire) :
   ```sql
   UPDATE {table}
   SET attrs = attrs - 'field_name'
   WHERE attrs ? 'field_name';
   ```

**Temps** : 10 min (prudence requise)

---

## 📊 Métriques Performance

| Action | Temps Moyen | Dépendances |
|--------|-------------|-------------|
| **Simple field (string/integer)** | 3 min | Script seul |
| **Selection field (nouveau)** | 8 min | Script + rebuild |
| **Selection field (existant)** | 4 min | Script seul |
| **Conditional field** | 4 min | Script seul |
| **Many-to-one** | 6 min | Script + doc target model |
| **Grid extension** | 13 min | Script + GridView.xml |
| **Debugging field non visible** | 5-15 min | Selon root cause |

**Moyenne** : ~5 min par field simple après setup initial

---

## 🎓 Best Practices Agent

### 1. Toujours Versionner Configuration

✅ **Bon** :
```json
// config.json versionné Git
{
  "custom_fields": [
    { "name": "priorite", ... },
    { "name": "budget", ... }
  ]
}
```

❌ **Mauvais** :
```python
# Hardcoded dans script
field_data = {
    "name": "priorite",
    "title": "Priorité"
}
```

**Raison** : Configuration Git = documentation + reproductibilité

---

### 2. Naming Conventions

**Fields** :
- ✅ camelCase : `emailSecondaire`, `dateRelance`
- ❌ snake_case : `email_secondaire`

**Selections** :
- ✅ Pattern : `{model}-{field}-select`
- ✅ Exemple : `lead-priorite-select`, `partner-category-select`

**Raison** : Cohérence avec conventions Axelor

---

### 3. Documenter showIf Conditions

```json
{
  "name": "commentaireRefus",
  "showIf": "statut == 'refuse'",
  "help": "Visible uniquement si statut = Refusé"  // ← Documenter logique
}
```

**Raison** : Conditions complexes difficiles à debug sans doc

---

### 4. Tester Idempotence

Toujours run script **2 fois** pour vérifier :
- 1ère fois : Crée field
- 2ème fois : Update field (aucune erreur, aucun doublon)

**Raison** : CI/CD peut re-run script → doit être safe

---

### 5. Logs Détaillés

```python
logger.info(f"Processing field '{field['name']}' on {field['model']}")
logger.info(f"Field created successfully (ID: {response_data['id']})")
logger.warning(f"Field already exists, updating...")
```

**Raison** : Debug rapide en cas d'erreur

---

## 🚀 Évolutions Futures Agent

### v2 : Support One-to-Many

Créer fields relationnels complexes (ex: Partner.commandes)

**Complexité** : +Haute (nécessite MetaJsonModel)

---

### v3 : Bulk Import

Importer 50+ fields d'un coup depuis CSV

**Template** :
```csv
name,title,type,model,modelField,selection
priorite,Priorité,string,Lead,attrs,lead-priorite-select
budget,Budget,decimal,Opportunity,attrs,
```

---

### v4 : Validation Rules

Ajouter contraintes validation (regex, min/max, etc.)

**Exemple** :
```json
{
  "name": "email",
  "regex": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
  "validationMessage": "Format email invalide"
}
```

---

## 📎 Ressources

### Documentation Axelor
- [Custom Fields Official Docs](https://docs.axelor.com/adk/7.2/dev-guide/models/custom-fields.html)
- [REST API Docs](https://docs.axelor.com/adk/7.2/dev-guide/web-services/rest.html)

### Code Source
- [DataLoader.java](https://github.com/axelor/axelor-open-platform/blob/master/axelor-core/src/main/java/com/axelor/meta/loader/DataLoader.java)
- [MetaJsonField.java](https://github.com/axelor/axelor-open-platform/blob/master/axelor-core/src/main/java/com/axelor/meta/db/MetaJsonField.java)

### Investigation
- `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/investigation-complete-solution-python-api.md`
- Temps total investigation : 4h15
- Approches testées : XML, CSV auto-import, Java intégré

---

**FIN TEMPLATE AGENT**

**Version** : 1.0
**Dernière MAJ** : 2025-10-06
**Statut** : Prod-ready
**Auteur** : Claude Code (AI) + Tanguy (validation)
