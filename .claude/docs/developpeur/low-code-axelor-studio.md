# Low-Code Axelor Studio - Guide Complet
## Personnalisation CRM sans Code

> **📅 Date** : 3 Octobre 2025
> **🎯 Public** : Développeurs, Administrateurs Techniques, Business Analysts
> **📝 Contexte** : Axelor Open Suite 8.3.15 / Open Platform 7.4
> **🔧 Focus** : Custom Fields, BPM, Dashboards pour CRM Agence IA

---

## 📋 Table des Matières

1. [Introduction - Axelor Studio](#1-introduction---axelor-studio)
2. [Custom Fields (Champs Personnalisés)](#2-custom-fields-champs-personnalisés)
3. [Custom Models (Modèles Personnalisés)](#3-custom-models-modèles-personnalisés)
4. [BPM (Business Process Management)](#4-bpm-business-process-management)
5. [Dashboards et Charts](#5-dashboards-et-charts)
6. [Actions et Menus Custom](#6-actions-et-menus-custom)
7. [Web Services (API)](#7-web-services-api)
8. [Cas Pratique : CRM Agence IA](#8-cas-pratique--crm-agence-ia)
9. [Tables Studio - Référence Technique](#9-tables-studio---référence-technique)
10. [Best Practices](#10-best-practices)
11. [Troubleshooting](#11-troubleshooting)
12. [Références](#12-références)

---

## 1. Introduction - Axelor Studio

### 1.1 Qu'est-ce qu'Axelor Studio ?

**Axelor Studio** est la plateforme low-code/no-code intégrée à Axelor Open Suite qui permet de **personnaliser et étendre** les applications métier **sans écrire de code Java**.

**Philosophie** :
- 🎯 **Empowerment** : Permettre aux utilisateurs métier de personnaliser l'ERP
- ⚡ **Rapidité** : Changements en temps réel sans recompilation
- 🔄 **Flexibilité** : Modifications réversibles et traçables
- 🏗️ **Architecture** : Stockage JSON pour extensions dynamiques

### 1.2 Capacités Low-Code Studio

```
┌─────────────────────────────────────────────────────┐
│              AXELOR STUDIO LOW-CODE                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📝 Custom Fields      🎨 Custom Models            │
│  - Ajout champs         - Nouveaux objets métier   │
│  - Types variés         - Relations personnalisées │
│  - Conditionnels        - Tables auto-générées     │
│                                                     │
│  🔄 BPM Workflows      📊 Dashboards & Charts      │
│  - BPMN 2.0             - KPIs visuels             │
│  - Automatisation       - Widgets configurables    │
│  - Event-driven         - Graphiques NVD3          │
│                                                     │
│  🔗 Web Services       🎬 Actions Custom           │
│  - Connecteurs API      - Scripts Groovy           │
│  - Webhooks             - Boutons personnalisés    │
│  - Authentification     - Menus dynamiques         │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### 1.3 Quand Utiliser Studio vs Code ?

| Critère | **Studio (Low-Code)** ✅ | **Code Java** 💻 |
|---------|-------------------------|-------------------|
| **Complexité** | Simple à modérée | Complexe |
| **Rapidité** | Immédiate (runtime) | Nécessite recompilation |
| **Compétences** | Business analyst | Développeur Java |
| **Réversibilité** | Facile (UI) | Nécessite rollback code |
| **Performance** | Légèrement inférieure | Optimale |
| **Exemples** | Champ "Budget IA"<br/>Scoring automatique<br/>Dashboard KPIs | Algorithme ML complexe<br/>Intégration système<br/>Performance critique |

**Règle d'or** : Commencer par Studio, passer au code si nécessaire.

---

## 2. Custom Fields (Champs Personnalisés)

### 2.1 Architecture MetaJsonField

**Concept** : Les custom fields sont stockés en **JSON** dans une colonne dédiée, permettant l'ajout de champs **sans modifier le schéma de base de données**.

#### Schéma Technique

```
┌────────────────────────────────────────────┐
│  Table : crm_lead                          │
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
          "niveau_maturite_ia": "Avancé",
          "budget_ia": 50000.00,
          "stack_technique": "Python, TensorFlow",
          "secteur_ia": "Computer Vision"
        }
```

#### Table meta_json_field

**Enregistrement des définitions** :

```sql
-- Structure table meta_json_field (47 colonnes)
CREATE TABLE meta_json_field (
  id                  BIGINT PRIMARY KEY,
  model_name          VARCHAR NOT NULL,  -- Ex: "com.axelor.apps.crm.db.Lead"
  model_field         VARCHAR NOT NULL,  -- Ex: "attrs"
  name                VARCHAR NOT NULL,  -- Ex: "niveauMaturiteIA"
  title               VARCHAR,           -- Ex: "Niveau Maturité IA"

  -- Type de champ (inféré depuis d'autres colonnes)
  target_model        VARCHAR,           -- Pour Many-to-One
  selection           VARCHAR,           -- Pour Selection
  enum_type           VARCHAR,           -- Pour Enum

  -- Contraintes
  is_required         BOOLEAN,
  is_readonly         BOOLEAN,
  is_hidden           BOOLEAN,
  default_value       VARCHAR,
  min_size            INTEGER,
  max_size            INTEGER,
  decimal_precision   INTEGER,
  decimal_scale       INTEGER,

  -- Conditionnalité
  show_if             VARCHAR,           -- Expression condition affichage
  hide_if             VARCHAR,           -- Expression condition masquage
  readonly_if         VARCHAR,           -- Expression condition lecture seule
  required_if         VARCHAR,           -- Expression condition obligatoire

  -- Contexte
  context_field       VARCHAR,
  context_field_value VARCHAR,

  -- Actions
  on_change           VARCHAR,           -- Action au changement
  on_click            VARCHAR,           -- Action au clic

  -- Affichage
  sequence            INTEGER,           -- Ordre d'affichage
  column_sequence     INTEGER,
  help                VARCHAR,           -- Bulle d'aide

  -- Vues
  form_view           VARCHAR,
  grid_view           VARCHAR,

  -- Audit
  created_on          TIMESTAMP,
  updated_on          TIMESTAMP,
  created_by          BIGINT,
  updated_by          BIGINT
);
```

### 2.2 Types de Champs Disponibles

#### Champs Simples

| Type | Description | Exemple CRM Agence IA |
|------|-------------|------------------------|
| **String** | Texte court | Stack Technique, Secteur IA |
| **Text** | Texte long | Description Besoin IA |
| **Integer** | Nombre entier | Nombre Employés Data |
| **Decimal** | Nombre décimal | Budget IA, Score Maturité |
| **Boolean** | Oui/Non | A une Équipe Data |
| **Date** | Date seule | Date Début Projet IA |
| **DateTime** | Date + Heure | Dernière Consultation IA |
| **Time** | Heure seule | Horaire Démo Préférée |

#### Champs Relationnels

| Type | Description | Exemple CRM Agence IA |
|------|-------------|------------------------|
| **Many-to-One** | Relation N-1 | Lead → Type Projet IA |
| **One-to-Many** | Relation 1-N | Opportunity → Livrables IA |
| **Many-to-Many** | Relation N-N | Lead → Technologies IA Intéressées |

#### Champs Avancés

| Type | Description | Exemple CRM Agence IA |
|------|-------------|------------------------|
| **Selection** | Liste choix | Niveau Maturité (Débutant/Intermédiaire/Avancé/Expert) |
| **Enum** | Énumération prédéfinie | Secteur IA (CV/NLP/ML/DL/RL) |
| **Panel** | Regroupement visuel | Section "Qualification IA" |
| **Button** | Bouton action | "Calculer Score Maturité IA" |
| **Separator** | Séparateur visuel | --- |

### 2.3 Ajouter un Custom Field via Interface

#### Méthode 1 : Via Model Management

**Étape 1** : Accès
```
Administration → Model Management → All models
→ Rechercher "Lead" ou "Opportunity"
→ Cliquer sur le modèle
```

**Étape 2** : Ajout Custom Field
```
Onglet "Custom fields" → Bouton "New"
```

**Étape 3** : Configuration

**Champ "Niveau Maturité IA"** :
```
Name:        niveauMaturiteIA
Title:       Niveau Maturité IA
Type:        Selection
Selection:   ia.maturite.niveau
Values:
  - Débutant (label: "Débutant - Découverte IA", value: "debutant")
  - Intermédiaire (label: "Intermédiaire - Projets POC", value: "intermediaire")
  - Avancé (label: "Avancé - IA en Production", value: "avance")
  - Expert (label: "Expert - Centre Compétence IA", value: "expert")
Sequence:    10
Required:    No
Help:        Niveau de maturité du client en Intelligence Artificielle
```

**Champ "Budget IA"** :
```
Name:        budgetIA
Title:       Budget IA Estimé
Type:        Decimal
Precision:   10
Scale:       2
Default:     0.00
Min:         0
Help:        Budget estimé pour le projet IA (€)
Required:    No
Sequence:    20
```

**Champ "Stack Technique"** :
```
Name:        stackTechnique
Title:       Stack Technique Actuel
Type:        String
Max Length:  255
Help:        Technologies actuellement utilisées (ex: Python, TensorFlow, AWS)
Sequence:    30
```

#### Méthode 2 : Via Studio (Drag & Drop)

```
Studio → Forms → Select Model "Lead"
→ Drag field from palette to form
→ Configure properties in right panel
→ Save
```

### 2.4 Champs Conditionnels (Context-Aware)

**Afficher "Type Projet IA" seulement si Budget > 10000€** :

```
Field: typeProjetIA
Show if: budgetIA > 10000
```

**Rendre "Stack Technique" obligatoire si Maturité ≥ Avancé** :

```
Field: stackTechnique
Required if: niveauMaturiteIA IN ('avance', 'expert')
```

**Masquer "Formation Requise" si Maturité = Expert** :

```
Field: formationRequise
Hide if: niveauMaturiteIA == 'expert'
```

### 2.5 Requêtes SQL Custom Fields

#### Lister tous les custom fields d'un modèle

```sql
SELECT
  name,
  title,
  sequence,
  is_required,
  is_readonly,
  target_model,
  selection
FROM meta_json_field
WHERE model_name = 'com.axelor.apps.crm.db.Lead'
ORDER BY sequence;
```

#### Récupérer valeurs custom fields d'un Lead

```sql
SELECT
  l.id,
  l.name,
  l.first_name,
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite_ia,
  CAST(l.attrs->>'budgetIA' AS DECIMAL) AS budget_ia,
  l.attrs->>'stackTechnique' AS stack_technique
FROM crm_lead l
WHERE l.attrs IS NOT NULL
LIMIT 10;
```

#### Statistiques sur Niveau Maturité IA

```sql
SELECT
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen
FROM crm_lead l
WHERE l.attrs->>'niveauMaturiteIA' IS NOT NULL
GROUP BY l.attrs->>'niveauMaturiteIA'
ORDER BY COUNT(*) DESC;
```

---

## 3. Custom Models (Modèles Personnalisés)

### 3.1 Quand Créer un Custom Model ?

**Custom Field** : Ajouter des propriétés à un modèle existant (Lead, Opportunity)
**Custom Model** : Créer un **nouvel objet métier** entier

**Exemples Agence IA** :
- ✅ Custom Model : `AIProjectType` (Type de Projet IA)
- ✅ Custom Model : `AITechnology` (Technologie IA)
- ✅ Custom Model : `AIDeliverable` (Livrable IA)
- ❌ Custom Field suffisant : "Niveau Maturité IA" (ajout simple sur Lead)

### 3.2 Créer un Custom Model

**Accès** :
```
Administration → Model Management → Custom Models → New
```

**Exemple : Modèle "Type Projet IA"**

```
Name:           AIProjectType
Package:        com.axelor.apps.custom.db
Table Name:     custom_ai_project_type

Fields:
  - name (String, required)      : "POC IA", "MVP", "Production"
  - description (Text)           : Description détaillée
  - duration (Integer)           : Durée estimée (jours)
  - complexity (Selection)       : Simple/Moyen/Complexe
  - technologies (Many-to-Many)  : Relation vers AITechnology
```

### 3.3 Architecture Custom Model

```
Studio → Nouveau Custom Model
    ↓
Génération automatique :
    ↓
1. Table PostgreSQL
   └── custom_ai_project_type (avec colonnes définies)
    ↓
2. Classe Java (runtime)
   └── com.axelor.apps.custom.db.AIProjectType
    ↓
3. Enregistrement meta_model
   └── Métadonnées du modèle
    ↓
4. Vues par défaut (optionnel)
   └── Form view, Grid view
```

### 3.4 Tables Générées

```sql
-- Exemple : Custom Model "AIProjectType"
CREATE TABLE custom_ai_project_type (
  id                  BIGINT PRIMARY KEY,
  name                VARCHAR(255) NOT NULL,
  description         TEXT,
  duration            INTEGER,
  complexity          VARCHAR(50),

  -- Colonnes audit Axelor (auto)
  archived            BOOLEAN,
  version             INTEGER,
  created_on          TIMESTAMP,
  updated_on          TIMESTAMP,
  created_by          BIGINT,
  updated_by          BIGINT
);

-- Table de liaison Many-to-Many
CREATE TABLE custom_ai_project_type_technologies (
  ai_project_type_id  BIGINT,
  ai_technology_id    BIGINT,
  PRIMARY KEY (ai_project_type_id, ai_technology_id)
);
```

---

## 4. BPM (Business Process Management)

### 4.1 Axelor BPM - Présentation

**Axelor BPM** permet de concevoir et automatiser des workflows métier conformes à la **norme BPMN 2.0**.

**Capacités** :
- 🎨 **Éditeur visuel** : Drag & drop conforme BPMN 2.0
- ⚙️ **Automatisation** : Déclenchement automatique selon événements
- 🔄 **Intégration** : Accès aux données Axelor en temps réel
- 📊 **Reporting** : Suivi instances workflow

### 4.2 Composants BPMN

| Élément | Description | Exemple Agence IA |
|---------|-------------|-------------------|
| **Start Event** | Démarrage workflow | Création nouveau Lead |
| **Task** | Tâche humaine/auto | "Qualifier Maturité IA" |
| **Gateway** | Branchement conditionnel | Si Budget > 50k€ → Commercial Senior |
| **End Event** | Fin workflow | Lead converti en Opportunity |
| **Timer** | Déclenchement temporel | Relance après 7 jours sans réponse |
| **Script Task** | Exécution Groovy | Calcul score maturité automatique |
| **Service Task** | Appel service Java | Envoi email via MailService |

### 4.3 Cas d'Usage : Workflow Scoring Lead IA

#### Objectif

Automatiser le scoring d'un Lead selon :
- Niveau maturité IA
- Budget estimé
- Secteur IA
- Urgence projet

#### Processus BPMN

```
┌─────────────────────────────────────────────────────────┐
│          WORKFLOW : SCORING AUTOMATIQUE LEAD IA         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Start]                                                │
│     │                                                   │
│     ▼                                                   │
│  [Task: Calculer Score Base]                            │
│     │  Script: score = 0                                │
│     │  - Maturité Débutant: +10                         │
│     │  - Maturité Intermédiaire: +20                    │
│     │  - Maturité Avancé: +30                           │
│     │  - Maturité Expert: +40                           │
│     │  - Budget < 10k: +5                               │
│     │  - Budget 10-50k: +15                             │
│     │  - Budget > 50k: +30                              │
│     ▼                                                   │
│  [Gateway: Score > 50 ?]                                │
│     │                                                   │
│     ├─ OUI ───> [Task: Assigner Commercial Senior]     │
│     │              │                                    │
│     │              ▼                                    │
│     │           [Task: Créer Alerte Priority]          │
│     │                                                   │
│     └─ NON ───> [Task: Assigner Commercial Junior]     │
│                    │                                    │
│                    ▼                                    │
│  [Task: Planifier Relance J+7]                          │
│     │                                                   │
│     ▼                                                   │
│  [End]                                                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### Script Groovy Calcul Score

```groovy
// Script Task: Calculer Score Base
def score = 0

// Score Maturité IA
def maturite = lead.attrs?.niveauMaturiteIA
if (maturite == 'debutant') score += 10
else if (maturite == 'intermediaire') score += 20
else if (maturite == 'avance') score += 30
else if (maturite == 'expert') score += 40

// Score Budget
def budget = lead.attrs?.budgetIA as BigDecimal
if (budget < 10000) score += 5
else if (budget >= 10000 && budget < 50000) score += 15
else if (budget >= 50000) score += 30

// Score Secteur IA (certains secteurs plus matures)
def secteur = lead.attrs?.secteurIA
if (secteur == 'computer_vision' || secteur == 'nlp') score += 10

// Score Urgence
if (lead.urgent == true) score += 15

// Mise à jour Lead
lead.leadScoringSelect = score
lead.save()

execution.setVariable('leadScore', score)
```

### 4.4 Tables BPM

**Tables principales** :

```sql
-- Modèles de workflow
studio_wkf_model                    -- Définitions workflows BPMN

-- Instances en cours
studio_wkf_instance                 -- Instances workflow actives

-- Configuration processus
studio_wkf_process_config           -- Config par modèle Axelor

-- Historique
studio_wkf_instance_migration_history  -- Historique migrations

-- DMN (Decision Model Notation)
studio_wkf_dmn_model                -- Règles décision
studio_dmn_table                    -- Tables décision
```

---

## 5. Dashboards et Charts

### 5.1 Architecture Dashboards

**Dashboard** = Ensemble de **Dashlets** (widgets)

**Dashlet** = Vue embarquée (grid, chart, KPI)

```
┌───────────────────────────────────────────────────┐
│           Dashboard CRM Agence IA                 │
├───────────────────────────────────────────────────┤
│                                                   │
│  ┌─────────────────┐  ┌──────────────────────┐   │
│  │ Dashlet 1       │  │ Dashlet 2            │   │
│  │ Leads par       │  │ Pipeline Opportunités│   │
│  │ Maturité IA     │  │ (Chart)              │   │
│  │ (Chart Pie)     │  │                      │   │
│  └─────────────────┘  └──────────────────────┘   │
│                                                   │
│  ┌──────────────────────────────────────────┐    │
│  │ Dashlet 3                                │    │
│  │ Top 10 Leads Score (Grid)                │    │
│  └──────────────────────────────────────────┘    │
│                                                   │
│  ┌────────────┐  ┌────────────┐  ┌──────────┐   │
│  │ KPI 1      │  │ KPI 2      │  │ KPI 3    │   │
│  │ Budget     │  │ Nb Leads   │  │ Taux     │   │
│  │ Total      │  │ Hot        │  │ Convert. │   │
│  └────────────┘  └────────────┘  └──────────┘   │
│                                                   │
└───────────────────────────────────────────────────┘
```

### 5.2 Types de Charts Supportés

| Type Chart | Usage | Exemple Agence IA |
|------------|-------|-------------------|
| **Pie** | Répartition | Leads par Niveau Maturité IA |
| **Bar** | Comparaison | Opportunités par Type Projet IA |
| **Line** | Évolution temporelle | Budget moyen par trimestre |
| **Gauge** | Indicateur | Taux conversion Lead → Oppo |
| **Radar** | Multi-critères | Scoring multi-dimensionnel |

### 5.3 Créer un Chart

**Exemple : Leads par Niveau Maturité IA**

**Accès** :
```
Studio → Charts → New
```

**Configuration** :

```yaml
Name: leads-by-maturity-ia
Title: Leads par Niveau Maturité IA
Type: pie

Category Key: niveauMaturiteIA
Category Title: Niveau Maturité

Dataset:
  Type: JPQL
  Query: |
    SELECT
      l.attrs.niveauMaturiteIA AS maturite,
      COUNT(l.id) AS nb_leads
    FROM Lead l
    WHERE l.attrs.niveauMaturiteIA IS NOT NULL
    GROUP BY l.attrs.niveauMaturiteIA

Series:
  - key: nb_leads
    title: Nombre Leads
    groupBy: maturite
```

**Résultat** :
```
Chart Pie affichant :
- Débutant: 15 leads (25%)
- Intermédiaire: 28 leads (47%)
- Avancé: 12 leads (20%)
- Expert: 5 leads (8%)
```

### 5.4 Créer un Dashboard

**Accès** :
```
Studio → Dashboards → New
```

**Configuration Dashboard CRM Agence IA** :

```xml
<dashboard name="dashboard-crm-agence-ia" title="CRM Agence IA">

  <!-- Dashlet 1 : Chart Pie Maturité -->
  <dashlet name="leads-maturity" colSpan="6" rowSpan="4">
    <chart ref="leads-by-maturity-ia"/>
  </dashlet>

  <!-- Dashlet 2 : Chart Bar Pipeline -->
  <dashlet name="pipeline-oppo" colSpan="6" rowSpan="4">
    <chart ref="opportunities-pipeline-ia"/>
  </dashlet>

  <!-- Dashlet 3 : Grid Top Leads -->
  <dashlet name="top-leads" colSpan="12" rowSpan="3">
    <action-view name="action-lead-top-scoring">
      <view type="grid" name="lead-grid-top"/>
      <domain>self.leadScoringSelect &gt;= 50</domain>
    </action-view>
  </dashlet>

  <!-- KPIs -->
  <dashlet name="kpi-budget" colSpan="4" rowSpan="2">
    <label>Budget Total IA</label>
    <sql>SELECT SUM(CAST(attrs->>'budgetIA' AS DECIMAL)) FROM crm_lead</sql>
  </dashlet>

  <dashlet name="kpi-leads-hot" colSpan="4" rowSpan="2">
    <label>Leads Hot (Score ≥ 60)</label>
    <sql>SELECT COUNT(*) FROM crm_lead WHERE lead_scoring_select >= 60</sql>
  </dashlet>

  <dashlet name="kpi-conversion" colSpan="4" rowSpan="2">
    <label>Taux Conversion (%)</label>
    <sql>
      SELECT ROUND(
        100.0 * COUNT(CASE WHEN is_converted THEN 1 END) / COUNT(*), 2
      ) FROM crm_lead
    </sql>
  </dashlet>

</dashboard>
```

### 5.5 Tables Dashboards

```sql
-- Dashboards
studio_studio_dashboard             -- Définition dashboards

-- Dashlets (widgets)
studio_studio_dashlet               -- Widgets individuels

-- Charts
studio_studio_chart                 -- Graphiques configurés
```

---

## 6. Actions et Menus Custom

### 6.1 Actions Custom

**Action** = Comportement déclenché (bouton, menu, event)

**Types d'actions** :
- **action-view** : Ouvrir une vue (grid, form)
- **action-method** : Appeler une méthode Java
- **action-record** : Modifier des champs
- **action-script** : Exécuter script Groovy
- **action-ws** : Appeler web service

### 6.2 Exemple : Bouton "Calculer Score IA"

**Objectif** : Ajouter bouton sur formulaire Lead pour recalculer score

**Action Script Groovy** :

```xml
<action-script name="action-lead-calculate-score-ia"
               model="com.axelor.apps.crm.db.Lead">
  <script><![CDATA[
    import com.axelor.apps.crm.db.Lead

    // Calcul score
    def score = 0

    // Maturité IA
    def maturite = lead.attrs?.niveauMaturiteIA
    if (maturite == 'expert') score += 40
    else if (maturite == 'avance') score += 30
    else if (maturite == 'intermediaire') score += 20
    else if (maturite == 'debutant') score += 10

    // Budget
    def budget = lead.attrs?.budgetIA as BigDecimal
    if (budget >= 50000) score += 30
    else if (budget >= 10000) score += 15
    else score += 5

    // Secteur porteur
    def secteur = lead.attrs?.secteurIA
    if (secteur in ['computer_vision', 'nlp', 'deep_learning']) score += 10

    // Update
    lead.leadScoringSelect = score
    lead.save()

    response.setFlash("Score calculé : " + score)
  ]]></script>
</action-script>
```

**Ajout bouton sur form** :

```xml
<form name="lead-form" model="com.axelor.apps.crm.db.Lead">
  <panel name="iaPanel" title="Qualification IA">
    <field name="attrs.niveauMaturiteIA"/>
    <field name="attrs.budgetIA"/>
    <field name="attrs.secteurIA"/>
    <field name="leadScoringSelect" readonly="true"/>

    <button name="btnCalculateScore"
            title="Calculer Score IA"
            onClick="action-lead-calculate-score-ia"/>
  </panel>
</form>
```

### 6.3 Menus Custom

**Créer menu "Projets IA"** :

```
Studio → Menus → New

Name:        menu-projets-ia
Title:       Projets IA
Parent:      crm-root
Action:      action-view-projets-ia
Icon:        fa-robot
Sequence:    50
Roles:       Commercial, Manager
```

### 6.4 Tables Actions et Menus

```sql
-- Actions
studio_studio_action                -- Actions custom
studio_studio_action_line           -- Lignes action
studio_studio_action_view           -- Vues liées

-- Menus
studio_studio_menu                  -- Menus personnalisés
studio_studio_menu_groups           -- Groupes autorisés
studio_studio_menu_roles            -- Rôles autorisés
```

---

## 7. Web Services (API)

### 7.1 Web Services Studio

**Studio Web Services** permet de configurer des **connecteurs vers APIs externes** sans code.

**Cas d'usage Agence IA** :
- 🔗 Enrichissement données Lead via API externe
- 📧 Envoi notifications Slack/Teams
- 🌐 Intégration CRM externe
- 📊 Export données vers BI

### 7.2 Configuration Connecteur

**Exemple : Enrichir Lead avec API LinkedIn**

```yaml
Name: ws-linkedin-enrich
Type: REST
Base URL: https://api.linkedin.com/v2/

Authentication:
  Type: OAuth 2.0
  Client ID: ${linkedin.client.id}
  Client Secret: ${linkedin.client.secret}

Endpoints:
  - Name: getCompanyInfo
    Path: /organizations/{organizationId}
    Method: GET
    Parameters:
      - organizationId (path)
    Response Mapping:
      - company.name → lead.enterpriseName
      - company.industry → lead.industrySector
      - company.size → lead.numberOfEmployees
```

### 7.3 Déclenchement Automatique

**Workflow BPM avec Web Service** :

```
Lead créé
    ↓
[Service Task: Enrichir via LinkedIn]
    ↓
API Call: ws-linkedin-enrich.getCompanyInfo
    ↓
Mise à jour Lead automatique
    ↓
Notification commercial
```

### 7.4 Tables Web Services

```sql
-- Connecteurs
studio_ws_connector                 -- Définition connecteurs

-- Requêtes
studio_ws_request                   -- Requêtes configurées

-- Authentification
studio_ws_authenticator             -- Config auth

-- Paramètres
studio_ws_key_value                 -- Paramètres key-value
```

---

## 8. Cas Pratique : CRM Agence IA

### 8.1 Objectif

Personnaliser le CRM Axelor pour une **agence IA** avec :

1. ✅ Custom Fields CRM adaptés IA
2. ✅ Workflow scoring automatique
3. ✅ Dashboard KPIs agence IA
4. ✅ Actions métier spécifiques

### 8.2 Étape 1 : Custom Fields Lead

**Accès** :
```
Administration → Model Management → Lead → Custom Fields
```

**Champs à créer** :

| Nom | Type | Sélection/Config | Séquence |
|-----|------|------------------|----------|
| `niveauMaturiteIA` | Selection | Débutant/Intermédiaire/Avancé/Expert | 10 |
| `budgetIA` | Decimal(10,2) | Min: 0 | 20 |
| `stackTechnique` | String(255) | - | 30 |
| `secteurIA` | Selection | CV/NLP/ML/DL/RL/Autre | 40 |
| `equipeData` | Boolean | - | 50 |
| `dataSources` | Text | - | 60 |
| `urgenceProjet` | Selection | Faible/Moyenne/Haute | 70 |
| `formationRequise` | Boolean | Hide if: niveauMaturiteIA='expert' | 80 |

### 8.3 Étape 2 : Custom Fields Opportunity

**Accès** :
```
Administration → Model Management → Opportunity → Custom Fields
```

**Champs à créer** :

| Nom | Type | Config | Séquence |
|-----|------|--------|----------|
| `typeProjetIA` | Many-to-One | Target: AIProjectType | 10 |
| `technologiesIA` | Many-to-Many | Target: AITechnology | 20 |
| `complexiteProjet` | Selection | Simple/Moyen/Complexe | 30 |
| `dureeEstimee` | Integer | Jours | 40 |
| `livrablesIA` | One-to-Many | Target: AIDeliverable | 50 |
| `kpiSuccess` | Text | - | 60 |

### 8.4 Étape 3 : Workflow Scoring Lead IA

**Créer workflow** :
```
Studio → BPM → New Workflow

Name:        wkf-lead-scoring-ia
Model:       Lead
Trigger:     On Create, On Update (fields: attrs.niveauMaturiteIA, attrs.budgetIA)
```

**Processus** :

```
[Start Event: Lead Created/Updated]
    ↓
[Script Task: Calculate Score]
    Script: (voir section 4.3)
    ↓
[Exclusive Gateway: Score >= 60 ?]
    ├─ YES → [User Task: Assign Commercial Senior]
    │           ↓
    │        [Service Task: Send Slack Notification "Lead Hot"]
    │
    └─ NO  → [User Task: Assign Commercial Junior]
                ↓
             [Timer: Wait 7 days]
                ↓
             [Service Task: Send Reminder Email]
    ↓
[End Event]
```

### 8.5 Étape 4 : Dashboard Agence IA

**Créer dashboard** :
```
Studio → Dashboards → New

Name:  dashboard-crm-agence-ia
Title: CRM Agence IA - Vue d'Ensemble
```

**Dashlets** :

**1. Chart Pie : Leads par Maturité IA**
```yaml
Type: pie
Query:
  SELECT l.attrs.niveauMaturiteIA, COUNT(l)
  FROM Lead l
  GROUP BY l.attrs.niveauMaturiteIA
```

**2. Chart Bar : Budget Moyen par Secteur IA**
```yaml
Type: bar
Query:
  SELECT l.attrs.secteurIA, AVG(CAST(l.attrs.budgetIA AS decimal))
  FROM Lead l
  WHERE l.attrs.budgetIA IS NOT NULL
  GROUP BY l.attrs.secteurIA
```

**3. Chart Line : Évolution Leads IA**
```yaml
Type: line
Query:
  SELECT
    DATE_TRUNC('month', l.contactDate) AS mois,
    COUNT(l.id) AS nb_leads
  FROM Lead l
  WHERE l.contactDate >= CURRENT_DATE - INTERVAL '12 months'
  GROUP BY mois
  ORDER BY mois
```

**4. Grid : Top 10 Leads Score**
```yaml
Type: grid
View: lead-grid-scoring
Domain: self.leadScoringSelect >= 50
Limit: 10
Order: leadScoringSelect DESC
```

**5. KPI : Budget Total Pipeline IA**
```sql
SELECT SUM(CAST(attrs->>'budgetIA' AS DECIMAL))
FROM crm_lead
WHERE lead_status IN (SELECT id FROM crm_lead_status WHERE is_open = true)
```

**6. KPI : Taux Conversion Lead → Opportunity**
```sql
SELECT ROUND(
  100.0 * COUNT(CASE WHEN is_converted THEN 1 END) / NULLIF(COUNT(*), 0), 2
)
FROM crm_lead
```

### 8.6 Étape 5 : Actions Métier

**Action 1 : "Proposer Formation IA"**

```xml
<action-script name="action-lead-proposer-formation-ia">
  <script><![CDATA[
    // Vérifier si formation pertinente
    def maturite = lead.attrs?.niveauMaturiteIA

    if (maturite in ['debutant', 'intermediaire']) {
      // Créer événement "Démo Formation IA"
      def event = new Event()
      event.subject = "Démo Formation IA - " + lead.simpleFullName
      event.typeSelect = 3 // Meeting
      event.lead = lead
      event.startDateTime = LocalDateTime.now().plusDays(7)
      event.duration = 60
      event.description = "Proposer formation IA adaptée au niveau " + maturite
      event.save()

      response.setFlash("Événement Formation IA créé")
    } else {
      response.setFlash("Formation non pertinente pour niveau " + maturite)
    }
  ]]></script>
</action-script>
```

**Action 2 : "Générer Devis Type IA"**

```xml
<action-script name="action-opportunity-generate-devis-ia">
  <script><![CDATA[
    def typeProjet = opportunity.attrs?.typeProjetIA
    def complexite = opportunity.attrs?.complexiteProjet

    // Calcul prix selon type et complexité
    def prixBase = 0
    switch(typeProjet) {
      case 'poc_ia': prixBase = 15000; break
      case 'mvp_ia': prixBase = 50000; break
      case 'production_ia': prixBase = 100000; break
    }

    // Facteur complexité
    def facteur = 1.0
    if (complexite == 'complexe') facteur = 1.5
    else if (complexite == 'moyen') facteur = 1.2

    def prixFinal = prixBase * facteur

    // Créer devis
    def saleOrder = new SaleOrder()
    saleOrder.opportunity = opportunity
    saleOrder.partner = opportunity.partner
    saleOrder.exTaxTotal = prixFinal
    saleOrder.description = "Projet IA ${typeProjet} - Complexité ${complexite}"
    saleOrder.save()

    response.setView("sale-order-form", "form", saleOrder.id)
    response.setFlash("Devis généré : ${prixFinal}€")
  ]]></script>
</action-script>
```

### 8.7 Résultat Final

**CRM Agence IA Personnalisé** :

✅ **Leads** avec qualification IA complète (maturité, budget, stack, secteur)
✅ **Scoring automatique** selon critères IA
✅ **Assignation intelligente** des commerciaux
✅ **Dashboard** KPIs agence IA en temps réel
✅ **Workflows** automatisés (relances, formations, devis)
✅ **Actions métier** adaptées (formation, devis type)

---

## 9. Tables Studio - Référence Technique

### 9.1 Groupes de Tables Studio (76 tables)

#### Apps Management
```sql
studio_app                          -- Apps disponibles
studio_app_base                     -- Config App BASE
studio_app_crm                      -- Config App CRM
studio_app_sale                     -- Config App SALE
studio_app_bpm                      -- Config App BPM
studio_app_studio                   -- Config App STUDIO
studio_app_depends_on_set           -- Dépendances Apps
```

#### Custom Fields & Models
```sql
meta_json_field                     -- Définitions custom fields
meta_json_model                     -- Définitions custom models
meta_json_record                    -- Données custom models
meta_model                          -- Tous modèles Axelor
```

#### BPM Workflows
```sql
studio_wkf_model                    -- Modèles workflow BPMN
studio_wkf_instance                 -- Instances workflow actives
studio_wkf_process_config           -- Config processus
studio_wkf_process                  -- Processus BPMN
studio_wkf_task_config              -- Config tâches
studio_wkf_task_menu                -- Menus tâches
studio_wkf_migration                -- Migrations workflow
```

#### DMN (Decision Model Notation)
```sql
studio_wkf_dmn_model                -- Modèles décision
studio_dmn_table                    -- Tables décision
studio_dmn_field                    -- Champs décision
```

#### Dashboards & Charts
```sql
studio_studio_dashboard             -- Dashboards
studio_studio_dashlet               -- Dashlets (widgets)
studio_studio_chart                 -- Charts configurés
```

#### Actions & Menus
```sql
studio_studio_action                -- Actions personnalisées
studio_studio_action_line           -- Lignes action
studio_studio_action_view           -- Vues action
studio_studio_menu                  -- Menus custom
studio_studio_menu_groups           -- Groupes accès menu
studio_studio_menu_roles            -- Rôles accès menu
```

#### Web Services
```sql
studio_ws_connector                 -- Connecteurs API
studio_ws_request                   -- Requêtes API
studio_ws_authenticator             -- Authentification
studio_ws_key_value                 -- Paramètres
```

#### Autres
```sql
studio_filter                       -- Filtres custom
studio_studio_selection             -- Sélections custom
studio_parameter                    -- Paramètres globaux
studio_operation                    -- Opérations
studio_library                      -- Bibliothèque ressources
```

### 9.2 Requêtes Utiles

#### Lister tous les custom fields par modèle

```sql
SELECT
  m.name AS model,
  COUNT(jf.id) AS nb_custom_fields
FROM meta_model m
LEFT JOIN meta_json_field jf ON jf.model_name = m.package_name || '.' || m.name
GROUP BY m.name
HAVING COUNT(jf.id) > 0
ORDER BY COUNT(jf.id) DESC;
```

#### Voir workflows actifs

```sql
SELECT
  wm.name AS workflow,
  wm.description,
  COUNT(wi.id) AS nb_instances_actives
FROM studio_wkf_model wm
LEFT JOIN studio_wkf_instance wi ON wi.wkf_model = wm.id
WHERE wm.is_active = true
GROUP BY wm.id, wm.name, wm.description;
```

#### Dashboards par utilisateur

```sql
SELECT
  u.name AS user,
  sd.name AS dashboard,
  sd.title
FROM studio_studio_dashboard sd
JOIN auth_user u ON u.id = sd.created_by
ORDER BY u.name, sd.name;
```

---

## 10. Best Practices

### 10.1 Studio vs Code

**✅ Utiliser Studio pour** :
- Ajout champs simples (String, Integer, Selection)
- Workflows métier standards
- Dashboards KPIs visuels
- Actions métier simples (Groovy)
- Prototypage rapide

**💻 Utiliser Code Java pour** :
- Logique métier complexe
- Algorithmes performance-critiques
- Intégrations systèmes complexes
- Migration données volumineuses
- Tests unitaires

### 10.2 Naming Conventions

**Custom Fields** :
```
✅ niveauMaturiteIA    (camelCase, suffixe IA clair)
✅ budgetIA
❌ maturity_level      (snake_case non standard)
❌ b                   (trop court, pas clair)
```

**Custom Models** :
```
✅ AIProjectType       (PascalCase, préfixe AI)
✅ AITechnology
❌ ai_project_type     (snake_case)
❌ ProjectType         (manque contexte IA)
```

**Workflows** :
```
✅ wkf-lead-scoring-ia     (kebab-case, préfixe wkf)
✅ wkf-opportunity-convert
❌ leadScoring             (manque contexte)
❌ WKF_LEAD_SCORING        (UPPER_CASE non standard)
```

### 10.3 Performance

**Custom Fields** :
- ✅ Limiter à 10-15 custom fields par modèle
- ✅ Utiliser index JSON si requêtes fréquentes
- ❌ Éviter custom fields dans boucles

**Requêtes JSON** :
```sql
-- ✅ BON : Index GIN sur colonne attrs
CREATE INDEX idx_lead_attrs_gin ON crm_lead USING gin (attrs);

SELECT * FROM crm_lead
WHERE attrs @> '{"niveauMaturiteIA": "expert"}';

-- ❌ LENT : Sans index
SELECT * FROM crm_lead
WHERE attrs->>'niveauMaturiteIA' = 'expert';
```

**Workflows** :
- ✅ Éviter workflows lourds sur événements fréquents (OnChange champ texte)
- ✅ Préférer déclenchement batch asynchrone
- ❌ Éviter appels API synchrones dans workflows

### 10.4 Maintenance

**Documentation** :
- ✅ Documenter tous custom fields (champ "help")
- ✅ Commenter scripts Groovy complexes
- ✅ Tenir changelog des modifications Studio

**Versioning** :
- ✅ Exporter configurations Studio avant upgrade Axelor
- ✅ Tester modifications en environnement dev/test
- ❌ Ne jamais modifier directement en production

**Upgrades Axelor** :
- ⚠️ Custom fields survivent aux upgrades
- ⚠️ Workflows peuvent nécessiter adaptation
- ⚠️ Tester dashboards après upgrade (changements vues)

### 10.5 Sécurité

**Permissions Custom Fields** :
```
Administration → Model Management → Lead → Custom Fields
→ Onglet "Roles" sur chaque field
→ Limiter accès fields sensibles (ex: budgetIA → Commercial+)
```

**Workflows** :
- ✅ Définir rôles autorisés à lancer workflows
- ✅ Valider données avant exécution scripts
- ❌ Ne pas stocker secrets dans scripts (utiliser variables env)

---

## 11. Troubleshooting

### 11.1 Custom Fields Non Visibles

**Problème** : Custom field créé mais invisible sur formulaire

**Solutions** :

1. **Vérifier modèle activé pour JSON** :
```sql
-- Lead doit avoir attrs column
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'crm_lead' AND column_name = 'attrs';
-- Si vide, modèle Lead n'a pas jsonAttr="true"
```

2. **Rafraîchir cache** :
```
Ctrl+F5 (navigateur)
ou
Administration → Clear Cache
```

3. **Vérifier permissions** :
```
Custom Field → Onglet Roles
→ S'assurer que rôle utilisateur a accès
```

4. **Vérifier séquence** :
```
Custom Field → Sequence : valeur > 0
→ Ordre d'affichage sur form
```

### 11.2 Workflows Non Déclenchés

**Problème** : Workflow créé mais jamais exécuté

**Solutions** :

1. **Vérifier workflow activé** :
```sql
SELECT name, is_active FROM studio_wkf_model WHERE name = 'wkf-lead-scoring-ia';
-- is_active doit être true
```

2. **Vérifier événement déclencheur** :
```
Studio → BPM → Workflow → Onglet "Trigger"
→ Event Type: OnCreate / OnUpdate
→ Conditions: Vérifier expression condition
```

3. **Vérifier logs** :
```bash
docker exec axelor-vecia-app tail -f /usr/local/tomcat/logs/axelor.log | grep -i "workflow\|bpm"
```

4. **Tester manuellement** :
```
Formulaire Lead → Bouton "Actions" → "Start Workflow" → Sélectionner workflow
```

### 11.3 Dashboards Vides

**Problème** : Dashboard créé mais aucune donnée affichée

**Solutions** :

1. **Tester requête SQL** :
```sql
-- Copier requête du chart
SELECT l.attrs->>'niveauMaturiteIA', COUNT(*)
FROM crm_lead l
GROUP BY l.attrs->>'niveauMaturiteIA';
-- Vérifier résultat en base
```

2. **Vérifier permissions** :
```
Dashboard → Roles autorisés
Chart → Requête : vérifier pas de filtre trop restrictif
```

3. **Données existent** :
```sql
SELECT COUNT(*) FROM crm_lead WHERE attrs IS NOT NULL;
-- Si 0, créer leads de test
```

4. **Rafraîchir dashboard** :
```
Dashboard → Bouton "Refresh" (icône ⟳)
```

### 11.4 Erreurs Groovy Scripts

**Problème** : Script action retourne erreur

**Solutions** :

1. **Consulter logs** :
```bash
docker logs axelor-vecia-app | grep -i "groovy\|script"
```

2. **Syntax Groovy** :
```groovy
// ✅ BON
def budget = lead.attrs?.budgetIA as BigDecimal

// ❌ ERREUR (NullPointerException)
def budget = lead.attrs.budgetIA
```

3. **Tester en console Groovy** :
```
Studio → Groovy Console
→ Tester fragments de code isolément
```

---

## 12. Références

### 12.1 Documentation Officielle

**Axelor Open Platform 7.4** :
- Custom Fields : <https://docs.axelor.com/adk/7.4/dev-guide/models/custom-fields.html>
- Dashboards : <https://docs.axelor.com/adk/7.4/dev-guide/views/dashboard.html>
- Charts : <https://docs.axelor.com/adk/7.4/dev-guide/views/charts.html>
- Widgets : <https://docs.axelor.com/adk/7.4/dev-guide/web-client/widgets.html>

**Axelor Open Suite** :
- Model Management : <https://docs.axelor.com/aos/en/aos/admin/manage_view/>
- Studio Guide : <https://axelor.com/studio/>

**BPM** :
- BPMN 2.0 : <https://www.bpmn.org/>
- Axelor BPM : <https://axelor.com/no-code-bpm/>

### 12.2 GitHub

**Exemples** :
- Axelor Open Suite : <https://github.com/axelor/axelor-open-suite>
  - `axelor-crm/src/main/resources/views/Dashboard.xml` : Exemples dashboards CRM
  - `axelor-crm/src/main/resources/views/Charts.xml` : Charts CRM
- Axelor Studio : <https://github.com/axelor/axelor-studio>

### 12.3 Forum Axelor

**Topics utiles** :
- Custom Fields : <https://forum.axelor.com/t/how-can-i-add-custom-fields/4132>
- Custom Models : <https://forum.axelor.com/t/what-are-custom-models-and-custom-fields-for/2303>
- BPM Examples : <https://forum.axelor.com/t/example-for-bpm/6255>
- Dashboards : <https://forum.axelor.com/t/custom-reports-dashboards/3635>

### 12.4 Documentation Projet Axelor Vecia

**Documents connexes** :
- `cycle-vie-apps.md` : Cycle de vie Apps Axelor (Module vs App)
- `agent-configuration-crm.md` : Agent spécialisé configuration CRM
- `agent-data-management.md` : Gestion données et import/export
- `guide-administration-axelor.md` : Guide utilisateur Apps Management

### 12.5 Outils Tiers

**NVD3 Charts** (utilisé par Axelor) :
- Documentation : <https://nvd3.org/>
- Exemples : <https://nvd3.org/examples/index.html>

**BPMN.io** (éditeur BPMN visuel) :
- Site : <https://bpmn.io/>
- Playground : <https://demo.bpmn.io/>

---

## 📊 Annexe : Checklist Configuration CRM Agence IA

### Phase 1 : Custom Fields ✅

- [ ] Lead : niveauMaturiteIA (Selection)
- [ ] Lead : budgetIA (Decimal)
- [ ] Lead : stackTechnique (String)
- [ ] Lead : secteurIA (Selection)
- [ ] Lead : equipeData (Boolean)
- [ ] Lead : urgenceProjet (Selection)
- [ ] Opportunity : typeProjetIA (Many-to-One)
- [ ] Opportunity : technologiesIA (Many-to-Many)
- [ ] Opportunity : complexiteProjet (Selection)

### Phase 2 : Workflows ✅

- [ ] Workflow : Scoring automatique Lead
- [ ] Workflow : Assignation commerciaux
- [ ] Workflow : Relance automatique J+7
- [ ] Workflow : Notification Slack Lead Hot
- [ ] Workflow : Proposition formation IA

### Phase 3 : Dashboards ✅

- [ ] Dashboard : CRM Agence IA Vue d'Ensemble
- [ ] Chart : Leads par Maturité IA (Pie)
- [ ] Chart : Budget Moyen par Secteur (Bar)
- [ ] Chart : Évolution Leads IA (Line)
- [ ] Grid : Top 10 Leads Score
- [ ] KPI : Budget Total Pipeline
- [ ] KPI : Taux Conversion
- [ ] KPI : Nb Leads Hot

### Phase 4 : Actions Métier ✅

- [ ] Action : Calculer Score IA (bouton Lead)
- [ ] Action : Proposer Formation IA
- [ ] Action : Générer Devis Type IA
- [ ] Menu : Projets IA

### Phase 5 : Custom Models ✅ (Optionnel)

- [ ] AIProjectType (Types projets IA)
- [ ] AITechnology (Technologies IA)
- [ ] AIDeliverable (Livrables IA)
- [ ] AITraining (Formations IA proposées)

---

**Document créé le** : 3 Octobre 2025
**Version Axelor** : 8.3.15 (Open Platform 7.4)
**Auteur** : Documentation Développeur Axelor Vecia
**Dernière mise à jour** : 3 Octobre 2025
