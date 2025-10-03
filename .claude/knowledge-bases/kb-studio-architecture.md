# Knowledge Base : Axelor Studio - Architecture Technique

**Type** : Knowledge Base Technique
**Domaine** : Axelor Studio Low-Code Platform
**Version Axelor** : 8.3.15 / AOP 7.4
**Dernière mise à jour** : 3 Octobre 2025

---

## 1. Architecture MetaJsonField - Stockage Custom Fields

### Principe Fondamental

Axelor Studio utilise **PostgreSQL JSON** pour stocker les custom fields de manière dynamique sans modifier le schéma de base de données.

### Schéma Technique

```
┌────────────────────────────────────────────┐
│  Table Métier : crm_lead                   │
├────────────────────────────────────────────┤
│  id              BIGINT                    │
│  name            VARCHAR                   │
│  first_name      VARCHAR                   │
│  mobile_phone    VARCHAR                   │
│  ...            (colonnes standards)       │
│  attrs           JSON      ← Custom Fields │
└────────────────────────────────────────────┘
                    ↓
        attrs = {
          "niveauMaturiteIA": "Avancé",
          "budgetIA": 50000.00,
          "stackTechnique": "Python, TensorFlow",
          "secteurIA": "Computer Vision"
        }
```

### Table meta_json_field (47 colonnes)

**Colonnes principales** :

| Colonne | Type | Description |
|---------|------|-------------|
| `id` | BIGINT | ID unique custom field |
| `name` | VARCHAR | Nom technique (camelCase) |
| `title` | VARCHAR | Libellé affiché UI |
| `type` | VARCHAR | Type champ (string, integer, decimal, boolean, date, many-to-one, etc.) |
| `model` | VARCHAR | Modèle cible (com.axelor.apps.crm.db.Lead) |
| `model_field` | VARCHAR | Champ JSON (attrs) |
| `selection` | VARCHAR | Référence sélection (pour type Selection) |
| `target_model` | VARCHAR | Modèle cible (pour relations Many-to-One) |
| `target_name` | VARCHAR | Champ à afficher (pour relations) |
| `sequence` | INTEGER | Ordre affichage (10, 20, 30...) |
| `required` | BOOLEAN | Champ obligatoire |
| `readonly` | BOOLEAN | Champ lecture seule |
| `hidden` | BOOLEAN | Champ caché |
| `show_if` | TEXT | Expression condition affichage |
| `hide_if` | TEXT | Expression condition masquage |
| `required_if` | TEXT | Expression condition obligation |
| `min_size` | INTEGER | Taille minimale |
| `max_size` | INTEGER | Taille maximale |
| `precision` | INTEGER | Précision (Decimal) |
| `scale` | INTEGER | Échelle (Decimal) |
| `regex` | VARCHAR | Expression régulière validation |
| `help` | TEXT | Texte d'aide |
| `default_value` | VARCHAR | Valeur par défaut |
| `widget` | VARCHAR | Widget UI spécifique |

---

## 2. Types de Custom Fields

### 2.1 Champs Simples

#### String
```
Type:        string
Description: Texte court
Max size:    Configurable (défaut 255)
Validation:  regex, min_size, max_size
Options:     uppercase, translatable
```

**Exemple SQL** :
```sql
SELECT attrs->>'stackTechnique' AS stack
FROM crm_lead
WHERE attrs ? 'stackTechnique';
```

#### Integer
```
Type:        integer
Description: Nombre entier
Validation:  min, max
```

**Exemple SQL** :
```sql
SELECT CAST(attrs->>'scoreIA' AS INTEGER) AS score
FROM crm_lead
WHERE CAST(attrs->>'scoreIA' AS INTEGER) > 70;
```

#### Decimal
```
Type:        decimal
Description: Nombre décimal
Config:      precision (total digits), scale (digits après virgule)
Exemple:     precision=10, scale=2 → 99999999.99
Validation:  min, max
```

**Exemple SQL** :
```sql
SELECT
  CAST(attrs->>'budgetIA' AS DECIMAL(10,2)) AS budget
FROM crm_lead
WHERE CAST(attrs->>'budgetIA' AS DECIMAL) >= 50000;
```

#### Boolean
```
Type:        boolean
Description: Case à cocher (true/false)
Default:     false
```

**Exemple SQL** :
```sql
SELECT
  CAST(attrs->>'equipeData' AS BOOLEAN) AS has_team
FROM crm_lead
WHERE attrs->>'equipeData' = 'true';
```

#### Date / DateTime
```
Type:        date, datetime
Description: Date seule ou Date + Heure
Format:      ISO 8601 (YYYY-MM-DD, YYYY-MM-DDTHH:mm:ss)
```

### 2.2 Champs Relationnels

#### Many-to-One
```
Type:         many-to-one
Description:  Référence simple vers un autre objet
Config:       target_model, target_name
Exemple:      Lead → Partner
```

**Configuration** :
- `target_model` : `com.axelor.apps.base.db.Partner`
- `target_name` : `name` (champ à afficher)

**Stockage JSON** :
```json
{
  "partnerTechnique": {
    "id": 123,
    "$version": 1
  }
}
```

#### One-to-Many
```
Type:         one-to-many
Description:  Liste d'objets enfants
Config:       target_model, mapped_by
Exemple:      Project → Tasks
```

#### Many-to-Many
```
Type:         many-to-many
Description:  Liste de références multiples
Config:       target_model
Exemple:      Project → Tags
```

### 2.3 Champs Sélection

#### Selection (Liste déroulante)
```
Type:         selection
Description:  Liste valeurs prédéfinies
Config:       selection (référence meta_select)
Exemple:      Niveau Maturité IA
```

**Création sélection** :
```sql
-- Table meta_select
INSERT INTO meta_select (name, module) VALUES ('ia.maturite.niveau', 'axelor-crm');

-- Table meta_select_item
INSERT INTO meta_select_item (select_id, title, value, sequence)
VALUES
  (1, 'Débutant - Découverte IA', 'debutant', 1),
  (1, 'Intermédiaire - Projets POC', 'intermediaire', 2),
  (1, 'Avancé - IA en Production', 'avance', 3),
  (1, 'Expert - Centre Compétence IA', 'expert', 4);
```

#### Enum
```
Type:         enum
Description:  Énumération statique (définie en code Java)
Config:       enum class reference
Exemple:      OpportunityStatus
```

### 2.4 Champs Avancés

#### Panel
```
Type:         panel
Description:  Regroupement visuel de champs
Config:       title, colspan, coloffset
Exemple:      Panel "Qualification IA"
```

#### Button
```
Type:         button
Description:  Bouton action personnalisé
Config:       onClick, title, icon
Exemple:      "Calculer Score IA"
```

#### Separator
```
Type:         separator
Description:  Ligne de séparation visuelle
Config:       title
```

---

## 3. Champs Conditionnels

### 3.1 Expressions Disponibles

**show_if** : Afficher si condition vraie
**hide_if** : Masquer si condition vraie
**required_if** : Requis si condition vraie
**readonly_if** : Lecture seule si condition vraie

### 3.2 Syntaxe Expressions

```javascript
// Égalité
niveauMaturiteIA == 'avance'

// Différent
niveauMaturiteIA != 'expert'

// Comparaison numérique
budgetIA >= 50000

// ET logique
niveauMaturiteIA == 'debutant' && budgetIA < 10000

// OU logique
urgenceProjet == 'haute' || budgetIA > 100000

// Null check
stackTechnique != null && stackTechnique != ''

// Champ standard (non JSON)
isConverted == true

// Combinaison complexe
(niveauMaturiteIA == 'expert' || budgetIA >= 100000) && equipeData == true
```

### 3.3 Exemples Pratiques

**Masquer "Formation Requise" si Expert** :
```
Field:   formationRequise
Type:    Boolean
hide_if: niveauMaturiteIA == 'expert'
```

**Afficher "Budget" seulement si Maturité ≥ Intermédiaire** :
```
Field:   budgetIA
Type:    Decimal
show_if: niveauMaturiteIA != 'debutant' && niveauMaturiteIA != null
```

**Requis si Urgence Haute** :
```
Field:       dataSources
Type:        Text
required_if: urgenceProjet == 'haute'
```

---

## 4. Custom Models

### 4.1 Principe

Créer des **nouveaux objets métier** complets via Studio (sans code Java).

### 4.2 Structure Custom Model

```
Custom Model: ServiceIA
├── Champs métier (code, name, description, unitPrice, etc.)
├── Relations vers autres modèles (Many-to-One Product, Partner, etc.)
├── Vues générées automatiquement (form, grid)
└── Menu généré automatiquement
```

### 4.3 Stockage

**Table** : `meta_json_model`
**Données** : `meta_json_record`

**Différence avec Custom Fields** :
- Custom Fields : Ajoutent colonnes JSON sur table existante
- Custom Models : Créent nouveau concept métier complet

---

## 5. Tables Studio & Meta - Référence Complète

### 5.1 Tables Studio (76)

#### Apps Management (5)
```sql
studio_app                          -- Apps disponibles (BASE, CRM, SALE, STUDIO, BPM)
studio_app_base                     -- Config App BASE
studio_app_crm                      -- Config App CRM
studio_app_sale                     -- Config App SALE
studio_app_studio                   -- Config App STUDIO
```

#### Custom Fields & Models (3)
```sql
meta_json_field                     -- Définitions custom fields (47 colonnes)
meta_json_model                     -- Définitions custom models
meta_json_record                    -- Données custom models
```

#### Actions (9)
```sql
studio_action
studio_action_email
studio_action_line
studio_action_record
studio_action_script
studio_action_view
studio_action_ws
```

#### Charts & Dashboards (4)
```sql
studio_chart
studio_chart_builder
studio_dashboard
studio_dashboard_builder
```

#### Menus (3)
```sql
studio_menu
studio_menu_builder
```

#### Sélections (2)
```sql
studio_selection
studio_selection_builder
```

#### Web Services (3)
```sql
studio_ws
studio_ws_authentication
studio_ws_request
```

*Liste complète : 76 tables studio_**

### 5.2 Tables Meta (37)

#### Modèles (3)
```sql
meta_model                          -- Tous modèles Axelor
meta_field                          -- Tous champs modèles
meta_permission                     -- Permissions
```

#### Vues (4)
```sql
meta_view                           -- Toutes vues (forms, grids, dashboards)
meta_view_custom                    -- Vues personnalisées
meta_view_dependency                -- Dépendances vues
```

#### Menus & Actions (5)
```sql
meta_menu                           -- Tous menus
meta_action                         -- Toutes actions
meta_action_menu                    -- Liens menus-actions
```

#### Sélections (2)
```sql
meta_select                         -- Sélections (listes déroulantes)
meta_select_item                    -- Items des sélections
```

#### JSON (3)
```sql
meta_json_field                     -- Custom fields
meta_json_model                     -- Custom models
meta_json_record                    -- Données custom models
```

#### Traductions (2)
```sql
meta_translation
meta_translation_message
```

#### Autres (18)
```sql
meta_chart, meta_chart_config, meta_chart_series
meta_dashboard, meta_filter, meta_help, meta_mapper
meta_schedule, meta_sequence, meta_attachment, meta_file
meta_module, ...
```

---

## 6. Requêtes SQL Pratiques

### 6.1 Lister Custom Fields

```sql
-- Custom fields d'un modèle
SELECT
  name,
  title,
  type,
  selection,
  target_model,
  required,
  sequence
FROM meta_json_field
WHERE model = 'com.axelor.apps.crm.db.Lead'
ORDER BY sequence;

-- Tous custom fields par module
SELECT
  model,
  COUNT(*) as nb_custom_fields
FROM meta_json_field
GROUP BY model
ORDER BY COUNT(*) DESC;
```

### 6.2 Récupérer Valeurs Custom Fields

```sql
-- Lead avec custom fields
SELECT
  l.id,
  l.name,
  l.first_name,
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite_ia,
  CAST(l.attrs->>'budgetIA' AS DECIMAL) AS budget_ia,
  l.attrs->>'stackTechnique' AS stack_technique,
  l.attrs->>'secteurIA' AS secteur_ia
FROM crm_lead l
WHERE l.attrs IS NOT NULL
LIMIT 10;

-- Avec filtres
SELECT *
FROM crm_lead l
WHERE l.attrs->>'niveauMaturiteIA' = 'expert'
  AND CAST(l.attrs->>'budgetIA' AS DECIMAL) >= 50000;
```

### 6.3 Statistiques Custom Fields

```sql
-- Distribution maturité IA
SELECT
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen
FROM crm_lead l
WHERE l.attrs->>'niveauMaturiteIA' IS NOT NULL
GROUP BY l.attrs->>'niveauMaturiteIA'
ORDER BY COUNT(*) DESC;

-- Top secteurs IA
SELECT
  l.attrs->>'secteurIA' AS secteur,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen,
  MAX(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_max
FROM crm_lead l
WHERE l.attrs->>'secteurIA' IS NOT NULL
GROUP BY l.attrs->>'secteurIA'
ORDER BY COUNT(*) DESC;
```

### 6.4 Export/Import Custom Fields

```sql
-- Export définitions custom fields
COPY (
  SELECT * FROM meta_json_field
  WHERE model LIKE 'com.axelor.apps.crm%'
  ORDER BY model, sequence
) TO '/tmp/custom_fields_crm_backup.csv' CSV HEADER;

-- Export sélections custom
COPY (
  SELECT s.*, si.title, si.value, si.sequence
  FROM meta_select s
  LEFT JOIN meta_select_item si ON si.select_id = s.id
  WHERE s.name LIKE 'ia.%'
  ORDER BY s.name, si.sequence
) TO '/tmp/selections_ia_backup.csv' CSV HEADER;
```

### 6.5 Index JSON (Performance)

```sql
-- Index GIN pour recherches JSON (PostgreSQL)
CREATE INDEX idx_lead_attrs_gin ON crm_lead USING GIN (attrs);

-- Index sur clé JSON spécifique
CREATE INDEX idx_lead_niveau_maturite
  ON crm_lead ((attrs->>'niveauMaturiteIA'));

-- Index sur valeur numérique JSON
CREATE INDEX idx_lead_budget
  ON crm_lead ((CAST(attrs->>'budgetIA' AS DECIMAL)));
```

---

## 7. Best Practices Techniques

### 7.1 Nommage

**Recommandé** :
- name (technique) : `camelCase` → `niveauMaturiteIA`, `budgetIA`
- title (UI) : `PascalCase` → "Niveau Maturité IA", "Budget IA"
- selection values : `snake_case` → `niveau_expert`, `secteur_computer_vision`

**À éviter** :
- ❌ Espaces dans name : `"niveau maturite"`
- ❌ Accents dans name : `"budgetÉlevé"`
- ❌ Majuscules dans values : `"NiveauAvancé"`

### 7.2 Séquences

**Incréments de 10** pour insérer facilement :
```
10, 20, 30, 40, 50...
```

Si besoin d'insérer entre 20 et 30 :
```
10, 20, 25, 30, 40...
```

### 7.3 Organisation avec Panels

```xml
<panel name="qualificationIA" title="Qualification IA" colSpan="12">
  <field name="niveauMaturiteIA" colSpan="6"/>
  <field name="budgetIA" colSpan="6"/>
  <field name="secteurIA" colSpan="6"/>
  <field name="urgenceProjet" colSpan="6"/>
</panel>

<panel name="technicalDetails" title="Détails Techniques" colSpan="12">
  <field name="stackTechnique" colSpan="12"/>
  <field name="dataSources" colSpan="12"/>
  <field name="equipeData" colSpan="6"/>
</panel>
```

### 7.4 Performance

**Limitations Custom Fields JSON** :
- ⚠️ Moins performant que colonnes natives SQL
- ⚠️ Indexation limitée (index GIN possible mais moins efficace)
- ⚠️ Tri et filtres plus lents

**Recommandations** :
- Limiter à **20-30 custom fields max** par entité
- Au-delà de 50 champs → Custom Model séparé
- Pour champs très recherchés/triés → Colonnes natives SQL (code Java)

### 7.5 Sécurité

- Custom fields héritent permissions modèle parent
- Ne jamais stocker **secrets, passwords, tokens** en custom fields
- Champs sensibles : `readonly=true` ou masqués (UI custom)
- Validation input : `regex`, `min`, `max`

---

## 8. Troubleshooting

### 8.1 Champ n'apparaît pas dans formulaire

**Causes** :
- ❌ Mauvais `model` (vérifier nom complet classe)
- ❌ `model_field` ≠ `attrs`
- ❌ Cache navigateur
- ❌ Permissions utilisateur

**Solutions** :
```sql
-- Vérifier configuration
SELECT model, model_field, name, title
FROM meta_json_field
WHERE name = 'monChamp';
```

Actions :
1. Vider cache navigateur (Ctrl+Shift+Del)
2. Déconnexion/reconnexion
3. Vérifier user = admin ou permissions OK

### 8.2 Erreur SQL "column not found"

**Cause** : Custom field JSON non présent

**Solution** :
```sql
-- ✅ BON: Vérifier existence avant
SELECT * FROM crm_lead
WHERE attrs ? 'niveauMaturiteIA';

-- ❌ MAUVAIS: Assume existence
SELECT attrs->>'niveauMaturiteIA' FROM crm_lead;
```

### 8.3 Condition show_if/hide_if ne fonctionne pas

**Erreurs fréquentes** :
```javascript
// ❌ FAUX
hide_if: "niveauMaturiteIA = 'expert'"     // Guillemets doubles
hide_if: niveauMaturiteIA === 'expert'     // === au lieu de ==

// ✅ CORRECT
hide_if: niveauMaturiteIA == 'expert'      // == et guillemets simples
show_if: budgetIA >= 50000 && niveauMaturiteIA != null
```

### 8.4 Selection n'affiche pas valeurs

**Checklist** :
1. ✅ Sélection créée dans `meta_select`
2. ✅ Items ajoutés dans `meta_select_item`
3. ✅ Référence correcte dans `meta_json_field.selection`
4. ✅ Clear cache application si nécessaire

```sql
-- Vérifier sélection
SELECT * FROM meta_select WHERE name = 'ia.maturite.niveau';

-- Vérifier items
SELECT si.value, si.title, si.sequence
FROM meta_select_item si
JOIN meta_select s ON s.id = si.select_id
WHERE s.name = 'ia.maturite.niveau'
ORDER BY si.sequence;
```

---

## 9. Références Techniques

### Documentation Officielle
- **Axelor Studio** : https://docs.axelor.com/adk/7.4/dev-guide/studio/
- **Custom Fields** : https://docs.axelor.com/adk/7.4/dev-guide/models/custom-fields.html
- **Custom Models** : https://docs.axelor.com/adk/7.4/dev-guide/models/custom-models.html

### GitHub
- **Axelor Studio** : https://github.com/axelor/axelor-studio

### Spécifications
- **JSON PostgreSQL** : https://www.postgresql.org/docs/current/datatype-json.html
- **JSON operators** : https://www.postgresql.org/docs/current/functions-json.html

---

**Knowledge Base maintenue par** : Équipe Dev Axelor Vecia
**Version** : 1.0
**Dernière mise à jour** : 3 Octobre 2025
