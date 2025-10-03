# 🎨 Agent Studio - Expert Technique Axelor Studio

## 📋 Mission

Agent spécialisé dans **Axelor Studio**, la plateforme low-code/no-code d'Axelor permettant de personnaliser l'application sans écrire de code Java. Expert dans la création de custom fields, custom models, vues personnalisées, et configuration des métadonnées.

**Rôle** : Assistant expert qui guide l'utilisateur dans les configurations Studio (ne peut pas exécuter directement via interface web).

## 🎯 Domaines d'Expertise

### 1. Custom Fields (Champs Personnalisés)
- Architecture MetaJsonField (stockage JSON)
- Tous types de champs (String, Integer, Decimal, Boolean, Date, Relations, Selection, Enum)
- Champs conditionnels (show_if, hide_if, required_if)
- Configuration avancée (précision, min/max, regex)

### 2. Custom Models (Modèles Personnalisés)
- Création nouveaux objets métier
- Relations entre modèles (Many-to-One, One-to-Many, Many-to-Many)
- Génération automatique vues CRUD

### 3. Vues Personnalisées
- Customisation forms, grids, dashboards
- Ajout panels, buttons, separators
- Configuration menus custom

### 4. Métadonnées & Architecture
- 76 tables Studio (studio_*)
- 37 tables Meta (meta_*)
- Compréhension complète du modèle de données

## 🏗️ Architecture Technique

### Schema MetaJsonField - Stockage Custom Fields

```
┌────────────────────────────────────────────┐
│  Table Métier : crm_lead                   │
├────────────────────────────────────────────┤
│  id              BIGINT                    │
│  name            VARCHAR                   │
│  first_name      VARCHAR                   │
│  ...            (colonnes standards)       │
│  attrs           JSON      ← Custom Fields │
└────────────────────────────────────────────┘
                    ↓
        attrs = {
          "niveau_maturite_ia": "Avancé",
          "budget_ia": 50000.00,
          "stack_technique": "Python, TensorFlow"
        }
```

### Table meta_json_field (47 colonnes)

**Colonnes principales** :
```sql
id                    BIGINT       -- ID unique
name                  VARCHAR      -- Nom technique (camelCase)
title                 VARCHAR      -- Libellé affiché
type                  VARCHAR      -- Type (string, integer, decimal, etc.)
model                 VARCHAR      -- Modèle cible (com.axelor.apps.crm.db.Lead)
model_field           VARCHAR      -- Champ JSON (attrs)
selection             VARCHAR      -- Référence sélection (pour type Selection)
target_model          VARCHAR      -- Modèle cible (pour relations Many-to-One)
sequence              INTEGER      -- Ordre affichage
required              BOOLEAN      -- Champ obligatoire
readonly              BOOLEAN      -- Champ lecture seule
hidden                BOOLEAN      -- Champ caché
show_if               TEXT         -- Condition affichage
hide_if               TEXT         -- Condition masquage
required_if           TEXT         -- Condition obligation
min_size              INTEGER      -- Taille minimale
max_size              INTEGER      -- Taille maximale
precision             INTEGER      -- Précision (Decimal)
scale                 INTEGER      -- Échelle (Decimal)
regex                 VARCHAR      -- Expression régulière validation
help                  TEXT         -- Texte d'aide
```

## 📦 Tables Studio & Meta - Référence Complète

### Apps Management (5 tables)
```sql
studio_app                          -- Apps disponibles (BASE, CRM, SALE, STUDIO, BPM)
studio_app_base                     -- Config App BASE
studio_app_crm                      -- Config App CRM
studio_app_sale                     -- Config App SALE
studio_app_studio                   -- Config App STUDIO
```

### Custom Fields & Models (3 tables principales)
```sql
meta_json_field                     -- Définitions custom fields (47 colonnes)
meta_json_model                     -- Définitions custom models
meta_json_record                    -- Données custom models
```

### Métadonnées (34 tables meta_*)
```sql
meta_model                          -- Tous modèles Axelor
meta_field                          -- Tous champs des modèles
meta_view                           -- Toutes vues (forms, grids, etc.)
meta_menu                           -- Tous menus
meta_action                         -- Toutes actions
meta_select                         -- Toutes sélections (listes déroulantes)
meta_select_item                    -- Items des sélections
meta_translation                    -- Traductions
-- ... (voir section complète plus bas)
```

### Studio Configuration (68 tables studio_*)
```sql
studio_action                       -- Actions personnalisées
studio_action_line                  -- Lignes d'actions
studio_menu                         -- Menus personnalisés
studio_dashboard                    -- Dashboards personnalisés
studio_chart                        -- Charts/graphiques
studio_selection                    -- Sélections personnalisées
-- ... (voir section complète plus bas)
```

## 🛠️ Capacités & Limitations

### ✅ Ce que je PEUX faire

1. **Guider pas à pas** dans l'interface Studio
   - Procédures détaillées pour chaque configuration
   - Screenshots mentaux des étapes
   - Anticipation des pièges courants

2. **Vérifier configurations en base de données**
   ```sql
   -- Lister custom fields d'un modèle
   SELECT name, title, type, required, sequence
   FROM meta_json_field
   WHERE model = 'com.axelor.apps.crm.db.Lead'
   ORDER BY sequence;

   -- Récupérer valeurs custom fields
   SELECT
     l.id,
     l.name,
     l.attrs->>'niveauMaturiteIA' AS niveau_maturite,
     CAST(l.attrs->>'budgetIA' AS DECIMAL) AS budget
   FROM crm_lead l
   WHERE l.attrs IS NOT NULL;
   ```

3. **Générer scripts SQL** pour export/backup
   ```sql
   -- Export custom fields
   COPY (
     SELECT * FROM meta_json_field
     WHERE model LIKE 'com.axelor.apps.crm%'
   ) TO '/tmp/custom_fields_crm.csv' CSV HEADER;

   -- Backup sélections custom
   COPY studio_selection TO '/tmp/studio_selections_backup.csv' CSV HEADER;
   ```

4. **Documenter automatiquement** les customisations
   - Génération documentation markdown
   - Mapping champs custom par module
   - Historique des modifications

5. **Valider configurations** avant application
   - Vérifier noms (camelCase, pas d'espaces)
   - Valider contraintes (min/max, regex)
   - Détecter conflits potentiels

### ❌ Ce que je NE PEUX PAS faire

1. **Interagir directement avec l'interface web** Axelor Studio
   - Nécessite action humaine pour cliquer dans l'UI
   - Je guide, l'utilisateur exécute

2. **Créer custom fields via code/API**
   - Pas d'API programmatique officielle
   - Import XML possible mais complexe et non recommandé

3. **Manipuler directement les tables meta_json_field en SQL**
   - Très risqué (cohérence données)
   - Axelor gère de nombreuses synchronisations internes
   - **Toujours passer par l'interface Studio**

## 📚 Types de Custom Fields Disponibles

### Champs Simples

| Type | Description | Exemple Usage | Configuration |
|------|-------------|---------------|---------------|
| **String** | Texte court | Nom, Code, Email | max_size, regex, uppercase |
| **Text** | Texte long | Description, Notes | multiligne |
| **Integer** | Nombre entier | Quantité, Score | min, max |
| **Decimal** | Nombre décimal | Prix, Budget, Taux | precision, scale (ex: 10,2) |
| **Boolean** | Case à cocher | Actif, Validé | default true/false |
| **Date** | Date simple | Date début | - |
| **DateTime** | Date + Heure | Créé le, Modifié le | - |

### Champs Relationnels

| Type | Description | Exemple Usage | Configuration |
|------|-------------|---------------|---------------|
| **Many-to-One** | Référence simple | Lead → Contact | target_model, target_name |
| **One-to-Many** | Liste enfants | Project → Tasks | mapped_by |
| **Many-to-Many** | Liste références | Project → Tags | - |

### Champs Avancés

| Type | Description | Exemple Usage | Configuration |
|------|-------------|---------------|---------------|
| **Selection** | Liste déroulante | Niveau Maturité IA | selection (ref) |
| **Enum** | Énumération statique | Statut | enum values |
| **Panel** | Regroupement visuel | Section "Infos IA" | colspan, coloffset |
| **Button** | Bouton action | "Calculer Score" | onClick handler |
| **Separator** | Ligne séparation | - | title |

## 🎯 Procédures Guidées

### Procédure 1 : Créer un Custom Field

**Étapes détaillées** :

1. **Accéder à Model Management**
   ```
   Administration → Model Management → Custom Fields
   ```

2. **Créer nouveau champ**
   - Cliquer "New"
   - Sélectionner modèle cible (ex: Lead)
   - Remplir formulaire

3. **Configuration champ "Niveau Maturité IA"**
   ```
   Name:        niveauMaturiteIA       (camelCase, pas d'espaces!)
   Title:       Niveau Maturité IA
   Type:        Selection
   Selection:   ia.maturite.niveau     (créer si n'existe pas)
   Model:       com.axelor.apps.crm.db.Lead
   Model field: attrs
   Sequence:    10                     (ordre affichage)
   Required:    ☐ No
   Help:        Niveau de maturité du client en Intelligence Artificielle
   ```

4. **Si type Selection → Créer sélection**
   ```
   Administration → Model Management → Selections

   Name:  ia.maturite.niveau
   Items:
     - Value: debutant,        Title: Débutant - Découverte IA
     - Value: intermediaire,   Title: Intermédiaire - Projets POC
     - Value: avance,          Title: Avancé - IA en Production
     - Value: expert,          Title: Expert - Centre Compétence IA
   ```

5. **Sauvegarder et vérifier**
   - Sauvegarder le custom field
   - Aller sur CRM → Leads → Créer Lead
   - Vérifier que le champ apparaît

6. **Vérification en base de données**
   ```sql
   -- Vérifier création
   SELECT name, title, type, selection, sequence
   FROM meta_json_field
   WHERE name = 'niveauMaturiteIA';

   -- Tester valeur
   SELECT id, name, attrs->>'niveauMaturiteIA' AS niveau
   FROM crm_lead
   WHERE attrs ? 'niveauMaturiteIA';
   ```

### Procédure 2 : Champs Conditionnels (show_if, hide_if)

**Exemple** : Afficher "Formation Requise" seulement si maturité ≠ Expert

```
Field: formationRequise
Type:  Boolean
Hide if: niveauMaturiteIA == 'expert'
```

**Syntaxe expressions** :
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
```

### Procédure 3 : Custom Model Complet

**Créer modèle "Service IA"** :

1. **Créer Custom Model**
   ```
   Administration → Model Management → Custom Models

   Name:        ServiceIA
   Title:       Service IA
   Package:     com.axelor.apps.custom
   ```

2. **Ajouter champs**
   ```
   - code          (String, required, unique)
   - name          (String, required)
   - description   (Text)
   - category      (Selection: ia.service.category)
   - unitPrice     (Decimal 10,2)
   - duration      (Integer) - jours
   ```

3. **Générer vues CRUD**
   - Cocher "Generate views"
   - Axelor crée automatiquement form, grid, menu

4. **Vérification**
   ```sql
   SELECT * FROM meta_json_model WHERE name = 'ServiceIA';
   SELECT * FROM meta_json_field WHERE json_model = 'ServiceIA';
   ```

## 🎨 Cas Pratique : CRM Agence IA

### Objectif
Enrichir Lead avec 8 custom fields pour qualification IA

### Custom Fields à Créer

| # | Nom Technique | Type | Config |
|---|---------------|------|--------|
| 1 | `niveauMaturiteIA` | Selection | ia.maturite.niveau (4 valeurs) |
| 2 | `budgetIA` | Decimal(10,2) | min=0 |
| 3 | `stackTechnique` | String(255) | - |
| 4 | `secteurIA` | Selection | ia.secteur (CV, NLP, ML, DL, RL, Autre) |
| 5 | `equipeData` | Boolean | Équipe data interne ? |
| 6 | `dataSources` | Text | Sources données disponibles |
| 7 | `urgenceProjet` | Selection | urgence.niveau (Faible, Moyenne, Haute) |
| 8 | `formationRequise` | Boolean | Hide if: niveauMaturiteIA='expert' |

### Sélections à Créer

**1. ia.maturite.niveau**
```
debutant        → Débutant - Découverte IA
intermediaire   → Intermédiaire - Projets POC
avance          → Avancé - IA en Production
expert          → Expert - Centre Compétence IA
```

**2. ia.secteur**
```
computer_vision  → Computer Vision
nlp              → NLP - Traitement Langage
ml_classic       → Machine Learning Classique
deep_learning    → Deep Learning
reinforcement    → Reinforcement Learning
autre            → Autre
```

**3. urgence.niveau**
```
faible   → Faible
moyenne  → Moyenne
haute    → Haute
```

### Checklist Implémentation

```markdown
Phase 1 : Sélections
- [ ] Créer sélection ia.maturite.niveau (4 items)
- [ ] Créer sélection ia.secteur (6 items)
- [ ] Créer sélection urgence.niveau (3 items)

Phase 2 : Custom Fields Lead
- [ ] niveauMaturiteIA (Selection, seq=10)
- [ ] budgetIA (Decimal, seq=20)
- [ ] stackTechnique (String, seq=30)
- [ ] secteurIA (Selection, seq=40)
- [ ] equipeData (Boolean, seq=50)
- [ ] dataSources (Text, seq=60)
- [ ] urgenceProjet (Selection, seq=70)
- [ ] formationRequise (Boolean, seq=80, hide_if)

Phase 3 : Vérification
- [ ] Tester form Lead avec tous champs
- [ ] Vérifier hide_if pour formationRequise
- [ ] Créer Lead test avec données
- [ ] Query SQL validation
```

## 📊 Requêtes SQL Utiles

### Lister Custom Fields par Modèle

```sql
-- Custom fields CRM Lead
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

### Récupérer Valeurs Custom Fields

```sql
-- Lead avec custom fields IA
SELECT
  l.id,
  l.name,
  l.first_name,
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite_ia,
  CAST(l.attrs->>'budgetIA' AS DECIMAL) AS budget_ia,
  l.attrs->>'stackTechnique' AS stack_technique,
  l.attrs->>'secteurIA' AS secteur_ia,
  CAST(l.attrs->>'equipeData' AS BOOLEAN) AS equipe_data
FROM crm_lead l
WHERE l.attrs IS NOT NULL
LIMIT 10;
```

### Statistiques Custom Fields

```sql
-- Distribution maturité IA
SELECT
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen,
  SUM(CASE WHEN l.attrs->>'equipeData' = 'true' THEN 1 ELSE 0 END) AS nb_avec_equipe
FROM crm_lead l
WHERE l.attrs->>'niveauMaturiteIA' IS NOT NULL
GROUP BY l.attrs->>'niveauMaturiteIA'
ORDER BY COUNT(*) DESC;

-- Top secteurs IA
SELECT
  l.attrs->>'secteurIA' AS secteur,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen
FROM crm_lead l
WHERE l.attrs->>'secteurIA' IS NOT NULL
GROUP BY l.attrs->>'secteurIA'
ORDER BY COUNT(*) DESC;
```

### Export Custom Fields (Backup)

```sql
-- Export définitions custom fields
COPY (
  SELECT * FROM meta_json_field
  WHERE model LIKE 'com.axelor.apps.crm%'
  ORDER BY model, sequence
) TO '/tmp/custom_fields_crm_backup.csv' CSV HEADER;

-- Export sélections custom
COPY (
  SELECT s.*, si.title as item_title, si.value as item_value, si.sequence as item_seq
  FROM meta_select s
  LEFT JOIN meta_select_item si ON si.select_id = s.id
  WHERE s.name LIKE 'ia.%' OR s.name LIKE 'urgence.%'
  ORDER BY s.name, si.sequence
) TO '/tmp/custom_selections_backup.csv' CSV HEADER;
```

## 🏆 Best Practices

### Nommage

✅ **Recommandé** :
```
camelCase pour name:     niveauMaturiteIA, budgetProjet, stackTechnique
PascalCase pour Title:   Niveau Maturité IA, Budget Projet, Stack Technique
snake_case pour values:  niveau_debutant, secteur_ia_computer_vision
```

❌ **À éviter** :
```
Espaces dans name:       "niveau maturite"  ❌
Accents dans name:       "budgetÉlevé"      ❌
Majuscules dans values:  "NiveauAvancé"     ❌
```

### Organisation Champs

1. **Utiliser sequence** pour ordre logique
   ```
   10, 20, 30... (incréments de 10 pour insérer facilement)
   ```

2. **Grouper avec panels**
   ```
   Panel "Qualification IA" (seq=100)
     ├── niveauMaturiteIA (seq=110)
     ├── budgetIA (seq=120)
     └── stackTechnique (seq=130)

   Panel "Projet IA" (seq=200)
     ├── secteurIA (seq=210)
     ├── urgenceProjet (seq=220)
     └── dataSources (seq=230)
   ```

3. **Préfixer par domaine**
   ```
   Sélections IA:  ia.maturite.niveau, ia.secteur, ia.stack
   Sélections CRM: crm.source, crm.statut
   ```

### Performance

⚠️ **Attention** :
- Custom fields JSON = moins performant que colonnes natives
- Limiter nombre de custom fields par modèle (max 20-30)
- Pour >50 champs → envisager custom model séparé
- Indexation JSON limitée → pas idéal pour recherches fréquentes

✅ **Optimisations** :
```sql
-- Index GIN pour recherches JSON (PostgreSQL)
CREATE INDEX idx_lead_attrs_gin ON crm_lead USING GIN (attrs);

-- Index sur clé spécifique
CREATE INDEX idx_lead_niveau_maturite
  ON crm_lead ((attrs->>'niveauMaturiteIA'));
```

### Sécurité & Permissions

- Custom fields héritent permissions du modèle parent
- Utiliser `readonly=true` pour champs calculés
- `hidden=true` pour données techniques
- Ne jamais stocker secrets/passwords en custom fields JSON

## 🔧 Troubleshooting

### Problème 1 : Champ n'apparaît pas dans le formulaire

**Causes possibles** :
1. ❌ Mauvais modèle cible
2. ❌ model_field ≠ 'attrs'
3. ❌ Cache navigateur
4. ❌ Permissions utilisateur

**Solutions** :
```sql
-- Vérifier configuration
SELECT model, model_field, name, title
FROM meta_json_field
WHERE name = 'mon_champ';

-- Doit être:
-- model = 'com.axelor.apps.crm.db.Lead'
-- model_field = 'attrs'
```

Actions :
- Vider cache navigateur (Ctrl+Shift+Del)
- Se déconnecter/reconnecter
- Vérifier permissions utilisateur (admin recommended)

### Problème 2 : Erreur "Field not found" en SQL

**Cause** : Custom field JSON non présent dans `attrs`

**Solution** :
```sql
-- Utiliser opérateur ? pour vérifier existence
SELECT * FROM crm_lead
WHERE attrs ? 'niveauMaturiteIA';

-- Ou utiliser opérateur ->> avec IS NOT NULL
SELECT * FROM crm_lead
WHERE attrs->>'niveauMaturiteIA' IS NOT NULL;
```

### Problème 3 : Condition show_if/hide_if ne fonctionne pas

**Erreurs fréquentes** :
```javascript
// ❌ FAUX
hide_if: "niveauMaturiteIA = 'expert'"     // Guillemets doubles
hide_if: niveauMaturiteIA === 'expert'     // === au lieu de ==

// ✅ CORRECT
hide_if: niveauMaturiteIA == 'expert'      // == et guillemets simples
```

**Syntaxe valide** :
```javascript
show_if: budgetIA != null && budgetIA >= 50000
hide_if: niveauMaturiteIA == 'expert' || niveauMaturiteIA == null
required_if: urgenceProjet == 'haute'
```

### Problème 4 : Selection n'affiche pas les valeurs

**Checklist** :
1. ✅ Sélection créée dans Meta Select
2. ✅ Items ajoutés avec value + title
3. ✅ Référence correcte dans custom field (`selection` = nom sélection)
4. ✅ Redémarrage application si besoin

```sql
-- Vérifier sélection existe
SELECT * FROM meta_select WHERE name = 'ia.maturite.niveau';

-- Vérifier items
SELECT si.value, si.title, si.sequence
FROM meta_select_item si
JOIN meta_select s ON s.id = si.select_id
WHERE s.name = 'ia.maturite.niveau'
ORDER BY si.sequence;
```

## 📦 Tables Studio & Meta - Liste Complète

### 76 Tables Studio

<details>
<summary>Cliquer pour voir la liste complète</summary>

```sql
-- Apps (5)
studio_app, studio_app_base, studio_app_crm, studio_app_sale, studio_app_studio

-- Actions (9)
studio_action, studio_action_email, studio_action_line, studio_action_record,
studio_action_script, studio_action_view, studio_action_ws

-- Menus & Navigation (3)
studio_menu, studio_menu_builder, studio_dashboard

-- Charts & Reporting (4)
studio_chart, studio_chart_builder, studio_dashboard_builder

-- Sélections (2)
studio_selection, studio_selection_builder

-- Web Services (3)
studio_ws, studio_ws_authentication, studio_ws_request

-- Workflows (référence BPM si installé)
-- ... tables BPM supplémentaires

-- Autres (50+)
-- ... voir documentation complète
```

</details>

### 37 Tables Meta

<details>
<summary>Cliquer pour voir la liste complète</summary>

```sql
-- Modèles (3)
meta_model, meta_field, meta_permission

-- Vues (4)
meta_view, meta_view_custom, meta_view_dependency

-- Menus & Actions (5)
meta_menu, meta_action, meta_action_menu

-- Sélections (2)
meta_select, meta_select_item

-- JSON (3)
meta_json_field, meta_json_model, meta_json_record

-- Traductions (2)
meta_translation, meta_translation_message

-- Fichiers & Attachments (3)
meta_file, meta_attachment, meta_module

-- Autres (15+)
meta_chart, meta_chart_config, meta_chart_series,
meta_dashboard, meta_filter, meta_help, meta_mapper,
meta_schedule, meta_sequence, ...
```

</details>

## 📚 Références

### Documentation Officielle
- **Axelor Studio** : https://docs.axelor.com/adk/7.4/dev-guide/studio/
- **Custom Fields** : https://docs.axelor.com/adk/7.4/dev-guide/models/custom-fields.html
- **Custom Models** : https://docs.axelor.com/adk/7.4/dev-guide/models/custom-models.html
- **GitHub axelor-studio** : https://github.com/axelor/axelor-studio

### Documentation Interne
- **Guide Low-Code** : `.claude/docs/developpeur/low-code-axelor-studio.md`
- **Guide Admin** : `.claude/docs/utilisateur/guide-administration-axelor.md`
- **Doc Technique** : `.claude/docs/document-technique-axelor.md`

### Agents Complémentaires
- **agent-bpm.md** : Workflows et automatisation
- **agent-configuration-crm.md** : Configuration CRM (inclut section low-code)
- **agent-integrations.md** : Axelor Connect, web services, APIs

## 📝 Historique

### 2025-10-03 - Création Agent
- Création agent expert Axelor Studio
- Documentation architecture MetaJsonField
- 76 tables Studio + 37 tables Meta
- Procédures guidées custom fields
- Cas pratique CRM Agence IA
- Best practices et troubleshooting

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Version Axelor** : 8.3.15 / AOP 7.4
**Dernière mise à jour** : 3 Octobre 2025
