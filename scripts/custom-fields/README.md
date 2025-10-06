# Axelor Custom Fields Importer

Script Python pour créer des custom fields (MetaJsonField) sur Axelor via REST API.

## 🎯 Avantages

- ✅ **Externe** : Aucune modification du code Axelor
- ✅ **Aucun rebuild** : Pas de recompilation nécessaire
- ✅ **Versionné** : Configuration Git-tracked (config.json)
- ✅ **Idempotent** : Peut être exécuté plusieurs fois sans erreur
- ✅ **Réutilisable** : Template pour tous futurs custom fields

## 📋 Prérequis

1. **Python 3.7+**
2. **Axelor running** : http://localhost:8080 accessible
3. **Credentials admin** : username/password dans config.json

## 🚀 Installation

```bash
# Installer dépendances
pip install -r requirements.txt
```

## 🔧 Configuration

Éditer `config.json` :

```json
{
  "axelor_url": "http://localhost:8080",
  "username": "admin",
  "password": "admin",
  "custom_fields": [
    {
      "name": "nomDuField",
      "title": "Titre Affiché",
      "type": "string",
      "model": "com.axelor.apps.base.db.Partner",
      "modelField": "attrs",
      "sequence": 10
    }
  ]
}
```

### Attributs Field

| Attribut | Type | Requis | Description | Exemple |
|----------|------|--------|-------------|---------|
| **name** | string | ✅ | Nom technique (camelCase) | `emailSecondaire` |
| **title** | string | ✅ | Libellé affiché | `Email Secondaire` |
| **type** | string | ✅ | Type de données | `string`, `integer`, `decimal`, `boolean`, `date`, `datetime` |
| **model** | string | ✅ | Classe modèle cible | `com.axelor.apps.base.db.Partner` |
| **modelField** | string | ⚠️ | Field JSON sur modèle | `attrs` (défaut), `contactAttrs` (Partner contacts) |
| **selection** | string | ⚠️ | Nom selection (si type dropdown) | `contact-provenance-select` |
| **widget** | string | ⚠️ | Widget UI | `selection`, `text`, `checkbox` |
| **sequence** | integer | ⚠️ | Ordre affichage | `10` |
| **showIf** | string | ⚠️ | Condition affichage | `isContact == true` |
| **visibleInGrid** | boolean | ⚠️ | Visible dans grille | `true` |
| **required** | boolean | ⚠️ | Champ obligatoire | `false` |
| **readonly** | boolean | ⚠️ | Lecture seule | `false` |
| **hidden** | boolean | ⚠️ | Caché | `false` |
| **help** | string | ⚠️ | Texte d'aide | `Format: email@example.com` |

### Types Supportés

| Type User | Type Axelor | Widget | Notes |
|-----------|-------------|--------|-------|
| Texte simple | `string` | `text` | Input texte |
| Texte long | `string` | `text` + `multiline: true` | Textarea |
| Nombre entier | `integer` | `integer` | |
| Nombre décimal | `decimal` | `decimal` | Précision via `precision`/`scale` |
| Date | `date` | `date` | Format YYYY-MM-DD |
| Date+Heure | `datetime` | `datetime` | |
| Oui/Non | `boolean` | `checkbox` | |
| Dropdown | `string` | `selection` | Nécessite `selection` name |
| Relation | `many-to-one` | `many-to-one` | Nécessite `targetModel` |

## 📖 Usage

### Cas Simple : Text Field

```json
{
  "custom_fields": [
    {
      "name": "notesInternes",
      "title": "Notes Internes",
      "type": "string",
      "model": "com.axelor.apps.base.db.Product",
      "modelField": "attrs",
      "multiline": true,
      "large": true
    }
  ]
}
```

```bash
python import-custom-fields.py
```

### Cas Selection (Dropdown)

**1. Créer Selection dans modules/{module}/src/main/resources/views/Selections.xml** :

```xml
<selection name="product-category-select">
  <option value="hardware">Hardware</option>
  <option value="software">Software</option>
  <option value="service">Service</option>
</selection>
```

**2. Configurer field** :

```json
{
  "name": "category",
  "title": "Catégorie",
  "type": "string",
  "model": "com.axelor.apps.base.db.Product",
  "modelField": "attrs",
  "selection": "product-category-select",
  "widget": "selection"
}
```

**3. Run script + Rebuild** (pour charger Selections.xml) :

```bash
python import-custom-fields.py
./gradlew build && docker-compose restart axelor
```

### Cas Conditional Field

```json
{
  "name": "commentaireRefus",
  "title": "Commentaire Refus",
  "type": "string",
  "model": "com.axelor.apps.crm.db.Lead",
  "modelField": "attrs",
  "showIf": "leadStatus.code == 'LOST'",
  "multiline": true
}
```

## 🔍 Vérification

### Via DB

```sql
SELECT id, name, title, type, model, selection
FROM meta_json_field
WHERE name = 'votreField' AND model = 'com.axelor.apps.base.db.Partner';
```

### Via UI

1. Ouvrir modèle dans Axelor (ex: Partner)
2. Créer/éditer record
3. Vérifier présence du custom field

**Note** : Si field type `selection` pas visible → Rebuild nécessaire pour charger Selections.xml

## ⚠️ Troubleshooting

### Field non visible dans form

**Cause** : `showIf` condition non remplie ou rebuild nécessaire

**Solution** :
```bash
./gradlew build
docker-compose restart axelor
```

### Selection dropdown vide

**Cause** : Selections.xml pas chargé

**Solution** :
```bash
# Vérifier Selections.xml existe dans modules/{module}/src/main/resources/views/
./gradlew build
docker-compose restart axelor
```

### "401 Unauthorized"

**Cause** : Credentials incorrects dans config.json

**Solution** : Vérifier username/password

### "Field already exists"

**C'est normal** : Le script est idempotent, il update le field existant

## 🔄 Update Field Existant

Modifier `config.json` et re-run script :

```json
{
  "name": "provenance",
  "title": "Source Acquisition",  // ← Modifié
  // ... autres attributes
}
```

```bash
python import-custom-fields.py
# Field sera mis à jour automatiquement
```

## 🗑️ Suppression Field

⚠️ **DANGER** : Supprimer MetaJsonField ne supprime PAS données JSON

### Méthode Sécurisée

```bash
# 1. Backup DB
docker-compose exec postgres pg_dump -U axelor axelor > backup.sql

# 2. Noter l'ID du field
python -c "
import requests
s = requests.Session()
s.post('http://localhost:8080/callback', json={'username':'admin','password':'admin'})
r = s.post('http://localhost:8080/ws/rest/com.axelor.meta.db.MetaJsonField/search',
          json={'data': {'_domain': \"self.name = 'provenance'\"}})
print(r.json())
"

# 3. Supprimer via API
curl -X DELETE \
  -H "Cookie: JSESSIONID=..." \
  http://localhost:8080/ws/rest/com.axelor.meta.db.MetaJsonField/{ID}
```

## 📚 Exemples Complets

### Partner - Email Secondaire

```json
{
  "name": "emailSecondaire",
  "title": "Email Secondaire",
  "type": "string",
  "model": "com.axelor.apps.base.db.Partner",
  "modelField": "contactAttrs",
  "showIf": "isContact == true",
  "help": "Email de contact alternatif"
}
```

### Lead - Budget (avec validation)

```json
{
  "name": "budget",
  "title": "Budget Estimé",
  "type": "decimal",
  "model": "com.axelor.apps.crm.db.Lead",
  "modelField": "attrs",
  "precision": 10,
  "scale": 2,
  "required": true,
  "help": "Budget en euros"
}
```

### Opportunity - Responsable (Many-to-One)

```json
{
  "name": "responsableTechnique",
  "title": "Responsable Technique",
  "type": "many-to-one",
  "model": "com.axelor.apps.crm.db.Opportunity",
  "modelField": "attrs",
  "targetModel": "com.axelor.auth.db.User",
  "targetName": "fullName"
}
```

## 🎓 Best Practices

1. ✅ **Naming** : camelCase pour field names
2. ✅ **Selections** : Pattern `{model}-{field}-select`
3. ✅ **Documentation** : Toujours remplir `help` attribute
4. ✅ **Idempotence** : Tester run 2× pour vérifier
5. ✅ **Versioning** : Commit config.json après chaque modif

## 🔗 Ressources

- [Investigation complète](.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/investigation-complete-solution-python-api.md)
- [Agent template](.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/agent-custom-fields-template.md)
- [Axelor Docs - Custom Fields](https://docs.axelor.com/adk/7.2/dev-guide/models/custom-fields.html)
- [Axelor Docs - REST API](https://docs.axelor.com/adk/7.2/dev-guide/web-services/rest.html)

## 📊 Performance

| Action | Temps Moyen |
|--------|-------------|
| Simple field (string/integer) | 3 sec |
| Selection field (nouveau) | 3 sec + rebuild (5 min) |
| Selection field (existant) | 3 sec |
| Batch 10 fields | 30 sec |

## 🤝 Support

Pour questions ou bugs :
- Consulter `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/`
- Vérifier logs script (`--verbose` flag)
- Checker logs Axelor : `docker-compose logs axelor`

---

**Version** : 1.0
**Auteur** : Claude Code (AI) + Tanguy
**Date** : 2025-10-06
