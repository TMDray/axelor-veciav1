# 🔄 Cycle de Vie des Applications Axelor
## Documentation Technique - Lien Application ↔ Code

> **📅 Date** : 3 Octobre 2025
> **🎯 Public** : Développeurs, Architectes
> **📝 Contexte** : Axelor Open Suite 8.3.15 / Open Platform 7.4

---

## 📋 Table des Matières

1. [Introduction - Module vs App](#1-introduction---module-vs-app)
2. [Architecture Système Apps](#2-architecture-système-apps)
3. [Cycle de Vie d'une App](#3-cycle-de-vie-dune-app)
4. [Processus Installation](#4-processus-installation)
5. [Analyse Technique : BASE + STUDIO](#5-analyse-technique--base--studio)
6. [Analyse Technique : CRM + SALE](#6-analyse-technique--crm--sale)
7. [Tables et Données Créées](#7-tables-et-données-créées)
8. [Bonnes Pratiques](#8-bonnes-pratiques)
9. [Troubleshooting](#9-troubleshooting)
10. [Références](#10-références)

---

## 1. Introduction - Module vs App

### 🎯 Concept Fondamental

**Axelor fait une distinction critique entre deux concepts** :

| Aspect | **Module** | **App** |
|--------|-----------|---------|
| **Définition** | Code compilé Gradle | Application installée et activée |
| **Localisation** | `modules/axelor-open-suite/axelor-{name}/` | Table `studio_app` en base de données |
| **Configuration** | `settings.gradle` | Apps Management (interface) |
| **État initial** | Présent après build | **Non installée** par défaut |
| **Visibilité** | Fichiers sur disque | Menus actifs dans l'application |

### ⚠️ Erreur Courante

**Symptôme** : "J'ai compilé le module CRM mais il n'apparaît pas dans l'interface !"

**Explication** :
```
Module présent dans settings.gradle ✅
          ↓
Build Gradle réussi ✅
          ↓
WAR contient le code CRM ✅
          ↓
Application démarre ✅
          ↓
App CRM en base (active=false) ✅
          ↓
❌ MAIS : Menus CRM invisibles car App non installée
```

**Solution** : Installer l'App via Apps Management dans l'interface.

### 🔍 Vérification État

**Module présent (Code)** :
```bash
# Vérifier settings.gradle
cat settings.gradle | grep "axelor-crm"
# ✅ Affiche : 'axelor-crm'

# Vérifier répertoire
ls modules/axelor-open-suite/ | grep crm
# ✅ Affiche : axelor-crm/
```

**App installée (Base de données)** :
```sql
SELECT code, name, active FROM studio_app WHERE code = 'crm';
-- ❌ active = false → App non installée
-- ✅ active = true  → App installée et active
```

---

## 2. Architecture Système Apps

### 🏗️ Schéma Global

```
┌─────────────────────────────────────────────────────────┐
│                    NIVEAU CODE                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  settings.gradle                                        │
│  ├── axelor-base    ──┐                                 │
│  ├── axelor-crm     ──┤ Modules Gradle                  │
│  └── axelor-sale    ──┘                                 │
│                                                         │
│  modules/axelor-open-suite/                             │
│  ├── axelor-base/                                       │
│  │   ├── src/main/java/        (Code métier)            │
│  │   ├── src/main/resources/                            │
│  │   │   ├── domains/          (Entités XML)            │
│  │   │   ├── views/            (Vues XML)               │
│  │   │   └── apps/                                      │
│  │   │       └── init-data/    (Données initialisation) │
│  │   └── build.gradle                                   │
│  ├── axelor-crm/                                        │
│  └── axelor-sale/                                       │
│                                                         │
│         ↓ gradlew build                                 │
│         ↓                                               │
│  build/libs/axelor-vecia-1.0.0.war (238 MB)             │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ↓ docker-compose build
         ↓
┌─────────────────────────────────────────────────────────┐
│              NIVEAU RUNTIME (DOCKER)                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Container: axelor-vecia-app                            │
│  ├── Tomcat 9                                           │
│  ├── axelor-vecia-1.0.0.war (déployée)                  │
│  └── /opt/axelor/axelor-config.properties               │
│                                                         │
│         ↓ Démarrage application                         │
│         ↓                                               │
│  1. Scan classes (@Entity)                              │
│  2. Création schéma BDD si nécessaire                   │
│  3. Chargement data-init/ (automatique)                 │
│  4. Enregistrement Apps disponibles                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────┐
│          NIVEAU BASE DE DONNÉES                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  PostgreSQL Database: axelor_vecia                      │
│                                                         │
│  studio_app (Table Apps)                                │
│  ├── id | code | name | active | description            │
│  ├──  1 | base | Base | false  | ...                    │
│  ├──  2 | crm  | CRM  | false  | ...                    │
│  └──  3 | sale | Sale | false  | ...                    │
│                                                         │
│         ↓ Installation via Apps Management              │
│         ↓                                               │
│  studio_app (Après installation)                        │
│  ├──  1 | base | Base | ✅ true | ...                   │
│  ├──  2 | crm  | CRM  | ✅ true | ...                   │
│  └──  3 | sale | Sale | false   | ...                   │
│                                                         │
│  + Chargement apps/init-data/                           │
│  + Activation menus                                     │
│  + Chargement permissions                               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 🔑 Tables Clés

**Table `studio_app`** : Enregistrement de toutes les Apps disponibles
```sql
CREATE TABLE studio_app (
    id BIGINT PRIMARY KEY,
    code VARCHAR(255),      -- Identifiant unique App
    name VARCHAR(255),      -- Nom affiché
    active BOOLEAN,         -- ✅ true = installée, ❌ false = disponible
    description TEXT,
    ...
);
```

**Table `meta_menu`** : Tous les menus de l'application
```sql
CREATE TABLE meta_menu (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255),      -- Identifiant technique
    title VARCHAR(255),     -- Titre affiché
    parent BIGINT,          -- Menu parent
    priority INTEGER,       -- Ordre affichage
    module VARCHAR(255),    -- Module propriétaire
    ...
);
```

---

## 3. Cycle de Vie d'une App

### 📊 Diagramme de Flux

```
┌─────────────────┐
│ Module dans     │
│ settings.gradle │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Build Gradle    │  ./gradlew build
│ génère WAR      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Docker build    │  docker-compose build
│ crée image      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Démarrage       │  docker-compose up -d
│ application     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 1. Scan @Entity classes                 │
│ 2. Création/mise à jour schéma BDD      │
│ 3. Chargement data-init/ (auto)         │
│    - Permissions                         │
│    - Menus (mais inactifs)               │
│    - Templates                           │
│ 4. Enregistrement Apps (active=false)   │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ App en BDD      │  active = false
│ Menus invisibles│  → App disponible mais non installée
└────────┬────────┘
         │
         │ INSTALLATION MANUELLE VIA INTERFACE
         │ (Apps Management → Install)
         ▼
┌─────────────────────────────────────────┐
│ Installation App :                      │
│ 1. studio_app.active = true             │
│ 2. Chargement apps/init-data/           │
│    - Statuts (LeadStatus, etc.)         │
│    - Séquences                           │
│    - Configuration App                   │
│ 3. Création tables métier                │
│    - crm_lead, crm_opportunity, etc.    │
│ 4. Activation menus                      │
│ 5. Chargement permissions                │
│ 6. (Optionnel) apps/demo-data/          │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ App Installée   │  active = true
│ ✅ Menus visibles│  → App pleinement fonctionnelle
│ ✅ Données init  │
└─────────────────┘
```

### ⏱️ Timeline Installation

```
T+0s    : Clic "Install" sur App CRM
T+1s    : Mise à jour studio_app.active = true
T+2s    : Chargement CSV init-data/fr/
          - studio_appCrm.csv
          - crm_leadStatus.csv
          - crm_opportunityStatus.csv
          - base_sequence.csv
T+5s    : Création tables CRM si nécessaire
T+10s   : Activation menus CRM
T+15s   : Chargement permissions CRM
T+20s   : ✅ Installation terminée
          → Rafraîchir page pour voir menus
```

---

## 4. Processus Installation

### 🔍 Détail Étape par Étape

#### Étape 1 : État Initial (Avant Installation)

**Code** : Module présent dans `settings.gradle`
```groovy
def enabledModules = [
  'axelor-crm'  // ✅ Module présent
]
```

**Base de données** :
```sql
SELECT code, name, active FROM studio_app WHERE code = 'crm';
--  code | name | active
-- ------+------+--------
--  crm  | CRM  | false   ← App enregistrée mais NON installée
```

**Interface** : Menu "CRM" absent de la barre latérale

#### Étape 2 : Déclenchement Installation

**Action utilisateur** :
```
Application Config → Apps Management → CRM → Clic "Install"
```

**Requête SQL générée** :
```sql
UPDATE studio_app SET active = true WHERE code = 'crm';
```

#### Étape 3 : Chargement Init-Data

**Localisation données** :
```
modules/axelor-open-suite/axelor-crm/src/main/resources/apps/init-data/fr/
├── studio_appCrm.csv           (Configuration App)
├── crm_leadStatus.csv          (Statuts Leads)
├── crm_opportunityStatus.csv   (Statuts Opportunités)
├── crm_partnerStatus.csv       (Statuts Partenaires)
└── base_sequence.csv           (Séquences numérotation)
```

**Import automatique** :
```sql
-- Exemple : Insertion statuts Leads
INSERT INTO crm_lead_status (id, import_id, name, sequence, is_open)
VALUES
  (1, 1, 'À traiter', 1, true),
  (2, 2, 'Qualification marketing', 2, true),
  (3, 3, 'Qualification commerciale', 3, true),
  (4, 4, 'Nurturing', 4, true),
  (5, 5, 'Converti', 5, false),
  (6, 6, 'Perdu', 6, false);
```

#### Étape 4 : Création Tables Métier

**Tables CRM créées** :
```sql
-- Tables principales
CREATE TABLE crm_lead (...);
CREATE TABLE crm_opportunity (...);
CREATE TABLE crm_event (...);
CREATE TABLE crm_lead_status (...);
CREATE TABLE crm_opportunity_status (...);
CREATE TABLE crm_partner_status (...);

-- Tables de liaison (many-to-many)
CREATE TABLE crm_opportunity_tags (...);
-- etc.
```

#### Étape 5 : Activation Menus

**Requête update** :
```sql
UPDATE meta_menu
SET active = true,
    hidden = false
WHERE name IN ('crm-root', 'crm-lead', 'crm-opportunity', ...);
```

**Résultat** :
- Menu "CRM" apparaît dans barre latérale
- Sous-menus : Leads, Opportunités, Partenaires, Événements

#### Étape 6 : Chargement Permissions

**Permissions CRM chargées** :
```sql
INSERT INTO auth_permission (name, object, can_read, can_write, ...)
VALUES
  ('crm.lead.read', 'com.axelor.apps.crm.db.Lead', true, false, ...),
  ('crm.lead.write', 'com.axelor.apps.crm.db.Lead', true, true, ...),
  ...
```

#### Étape 7 : Finalisation

**État final** :
```sql
SELECT code, name, active FROM studio_app WHERE code = 'crm';
--  code | name | active
-- ------+------+--------
--  crm  | CRM  | true    ← App INSTALLÉE et ACTIVE
```

**Interface** :
- ✅ Menu "CRM" visible
- ✅ Leads accessibles
- ✅ Opportunités accessibles
- ✅ Statuts chargés

---

## 5. Analyse Technique : BASE + STUDIO

### 📊 État Actuel Système (Après Installation BASE + STUDIO)

#### Tables Créées

**Total tables** : **466 tables** dans la base `axelor_vecia`

**Répartition par type** :

| Type | Nombre | Exemples |
|------|--------|----------|
| **Studio** | 76 | `studio_app`, `studio_wkf_model`, `studio_ws_connector` |
| **Meta** | ~50 | `meta_menu`, `meta_action`, `meta_json_field` |
| **Auth** | ~20 | `auth_user`, `auth_group`, `auth_permission` |
| **Base** | ~200 | `base_partner`, `base_address`, `base_product` |
| **Message** | ~30 | `message_message`, `message_email_address` |
| **Autres** | ~90 | `team_team`, `dms_file`, etc. |

#### Apps Enregistrées

```sql
SELECT id, code, name, active, description FROM studio_app ORDER BY code;
```

**Résultat** :
```
 id | code   | name   | active | description
----+--------+--------+--------+---------------------------
  3 | base   | Base   | ✅ t   | Basic configuration
  2 | bpm    | BPM    | ❌ f   | Business Process Modeling
  4 | crm    | CRM    | ❌ f   | CRM configuration
  5 | sale   | Sale   | ❌ f   | Sales configuration
  1 | studio | Studio | ✅ t   | App Management
```

**Analyse** :
- ✅ **BASE** installée (active=true)
- ✅ **STUDIO** installée (active=true)
- ❌ **BPM, CRM, SALE** disponibles mais non installées

#### Menus Disponibles

```sql
SELECT COUNT(*) FROM meta_menu;
-- Résultat : 333 menus
```

**Menus racine actifs** :
```sql
SELECT name, title FROM meta_menu WHERE parent IS NULL ORDER BY priority;
```

**Résultat** :
```
name                | title
--------------------+--------------------
menu-admin          | Administration
mail-conf           | Message
menu-team           | Teamwork
menu-dms            | Documents
studio-app-root     | App               ← Studio
menu-calendar       | Calendar
admin-root          | Application Config
crm-root            | CRM               ← Présent mais inactif !
sc-root-sale        | Sales             ← Présent mais inactif !
```

**Observation** :
- Menus CRM et Sales **présents** en base
- **MAIS** inactifs tant que Apps non installées
- Installation App → activation automatique des menus

#### Permissions

```sql
SELECT COUNT(*) FROM auth_permission;
-- Résultat : 11 permissions de base
```

**Permissions chargées** :
- Permissions système (admin, user)
- Permissions BASE
- Permissions STUDIO

**Permissions CRM/SALE** : Seront chargées à l'installation des Apps

#### Tables Studio Importantes

**76 tables Studio** créées, dont :

**Configuration Apps** :
```
studio_app                 - Apps disponibles/installées
studio_app_base           - Configuration App BASE
studio_app_studio         - Configuration App STUDIO
studio_app_crm            - Configuration App CRM (prête mais vide)
studio_app_sale           - Configuration App SALE (prête mais vide)
```

**Custom Fields (Low-Code)** :
```
meta_json_model           - Modèles custom
meta_json_field           - Champs custom créés via Studio
```

**Workflows (BPM)** :
```
studio_wkf_model          - Modèles de workflow
studio_wkf_instance       - Instances de workflow
studio_wkf_process        - Processus BPM
```

**Web Services** :
```
studio_ws_connector       - Connecteurs web services
studio_ws_request         - Requêtes WS
studio_ws_authenticator   - Authentification WS
```

---

## 6. Analyse Technique : CRM + SALE

### 📊 État Après Installation (Résultats Réels)

> **Note** : Cette section documente ce qui s'est réellement passé lors de l'installation de CRM et SALE le 3 octobre 2025

#### Apps Activées

```sql
SELECT id, code, name, active FROM studio_app ORDER BY code;
```

**Résultat** :
```
 id | code   | name   | active
----+--------+--------+--------
  3 | base   | Base   | ✅ t
  2 | bpm    | BPM    | ❌ f
  4 | crm    | CRM    | ✅ t    ← INSTALLÉE
  5 | sale   | Sale   | ✅ t    ← INSTALLÉE
  1 | studio | Studio | ✅ t
```

#### 🔍 Découverte Importante : Tables Préexistantes

**Observation critique** : Le nombre total de tables n'a **pas changé** après installation CRM + SALE !

```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
-- Résultat : 466 tables (identique à BASE + STUDIO)
```

**Explication** :
- ✅ Les tables CRM et SALE **existaient déjà** depuis l'installation de BASE
- ✅ L'installation de BASE crée **toutes** les tables Axelor Open Suite
- ✅ L'installation d'une App **active** seulement l'usage de tables existantes

**Architecture réelle confirmée** :
```
Installation BASE → Crée TOUTES les tables (466)
    ├── Tables BASE
    ├── Tables STUDIO
    ├── Tables CRM      ← Créées mais inutilisables
    ├── Tables SALE     ← Créées mais inutilisables
    └── Tables autres modules

Installation CRM → N'ajoute PAS de tables
    ├── Active App (active=true)
    ├── Charge init-data (statuts)
    └── Active menus CRM

Installation SALE → N'ajoute PAS de tables
    ├── Active App (active=true)
    ├── Charge init-data (séquences)
    └── Active menus SALE
```

#### Tables CRM Disponibles

**31 tables CRM** (existaient déjà, maintenant utilisables) :
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE 'crm_%'
ORDER BY table_name;
```

**Liste complète** :
```
crm_agency                              - Agences commerciales
crm_agency_member_set                   - Membres agences
crm_catalog                             - Catalogues produits/services
crm_catalog_type                        - Types catalogues
crm_corporate_partner_domain            - Domaines partenaires
crm_crm_batch                           - Traitements batch CRM
crm_crm_config                          - Configuration CRM
crm_crm_reporting                       - Rapports CRM
crm_crm_reporting_*_set                 - Filtres reporting (7 tables)
crm_event_attendee                      - Participants événements
crm_event_category                      - Catégories événements
crm_event_reminder                      - Rappels événements
crm_event_reminder_batch_set            - Batch rappels
crm_fidelity                            - Programmes fidélité
crm_lead                                - Prospects
crm_lead_status                         - Statuts Leads
crm_lead_tag_set                        - Tags Leads
crm_lost_reason                         - Raisons perte
crm_opportunity                         - Opportunités
crm_opportunity_status                  - Statuts Opportunités
crm_opportunity_type                    - Types opportunités
crm_participant                         - Participants
crm_partner_status                      - Statuts partenaires
crm_recurrence_configuration            - Config récurrence
crm_tour                                - Tournées commerciales
crm_tour_line                           - Lignes tournées
```

#### Init-Data CRM Chargées

**Statuts Lead** (6 statuts) :
```sql
SELECT id, name, sequence, is_open FROM crm_lead_status ORDER BY sequence;
```

```
 id | name                      | sequence | is_open
----+---------------------------+----------+---------
  1 | À traiter                 |        1 | ✅ t
  2 | Qualification marketing   |        2 | ✅ t
  3 | Qualification commerciale |        3 | ✅ t
  4 | Nurturing                 |        4 | ✅ t
  5 | Converti                  |        5 | ❌ f
  6 | Perdu                     |        6 | ❌ f
```

**Statuts Opportunity** (6 statuts) :
```sql
SELECT id, name, sequence, is_open FROM crm_opportunity_status ORDER BY sequence;
```

```
 id | name          | sequence | is_open
----+---------------+----------+---------
  1 | Nouveau       |        1 | ✅ t
  2 | Qualification |        2 | ✅ t
  3 | Proposition   |        3 | ✅ t
  4 | Négociation   |        4 | ✅ t
  5 | Fermée gagnée |        5 | ❌ f
  6 | Fermée perdue |        6 | ❌ f
```

**Données métier** :
```sql
SELECT COUNT(*) FROM crm_lead;           -- 0 (aucun prospect)
SELECT COUNT(*) FROM crm_opportunity;    -- 0 (aucune opportunité)
SELECT COUNT(*) FROM crm_catalog;        -- 0 (aucun catalogue)
```

**Configuration** :
```sql
SELECT COUNT(*) FROM crm_crm_config;     -- 0 (config non créée auto)
```

#### Menus CRM Activés

**Menus racine visibles** :
```sql
SELECT name, title FROM meta_menu
WHERE title LIKE '%CRM%' OR title LIKE '%Lead%' OR title LIKE '%Opportun%'
LIMIT 10;
```

**Résultat** :
```
name                        | title
----------------------------+----------------------
crm-root                    | CRM                  ← Menu racine
crm-root-lead               | Leads                ← Gestion prospects
crm-root-opportunity        | Opportunities        ← Gestion opportunités
crm-root-meeting-my-calendar| My CRM events        ← Événements
crm-conf-lead-status        | Lead status          ← Config statuts
crm-conf-opportunity-type   | Opportunity types    ← Config types
crm-conf-lead-source        | Leads Source         ← Sources
crm-root-crm-reporting      | Sales pipeline...    ← Reporting
admin-root-batch-crm        | CRM batches          ← Traitements batch
menu-lead-dashboard         | Lead                 ← Dashboard
```

#### Tables SALE Disponibles

**24 tables SALE** (existaient déjà, maintenant utilisables) :
```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE 'sale_%'
ORDER BY table_name;
```

**Liste complète** :
```
sale_advance_payment                    - Acomptes
sale_cart                               - Paniers
sale_cart_line                          - Lignes panier
sale_complementary_product              - Produits complémentaires
sale_complementary_product_selected     - Produits sélectionnés
sale_configurator                       - Configurateur
sale_configurator_creator               - Créateur configurateur
sale_configurator_creator_*             - Config créateur (4 tables)
sale_configurator_creator_indicators    - Indicateurs
sale_configurator_formula               - Formules
sale_configurator_product_formula       - Formules produit
sale_configurator_so_line_formula       - Formules ligne commande
sale_customer_catalog                   - Catalogues clients
sale_pack                               - Packs produits
sale_pack_line                          - Lignes pack
sale_sale_batch                         - Traitements batch ventes
sale_sale_config                        - Configuration ventes
sale_sale_order                         - Commandes/Devis
sale_sale_order_batch_set               - Batch commandes
sale_sale_order_line                    - Lignes commande
sale_sale_order_line_tax                - Taxes lignes
sale_sale_order_line_tax_line_set       - Détail taxes
```

#### Tables PRODUCT Disponibles

**25 tables PRODUCT** (de BASE, maintenant utilisables par SALE) :
```
base_product                            - Produits
base_product_category                   - Catégories
base_product_family                     - Familles
base_product_variant                    - Variants
base_product_variant_attr               - Attributs variants
base_product_variant_config             - Config variants
base_product_variant_value              - Valeurs variants
...
```

#### Menus SALE Activés

**Menus visibles** :
```sql
SELECT name, title FROM meta_menu
WHERE title LIKE '%Vente%' OR title LIKE '%Sale%' OR title LIKE '%Devis%'
LIMIT 10;
```

**Résultat** :
```
name                        | title
----------------------------+----------------------
sc-root-sale                | Sales                ← Menu racine
sc-root-sale-quotations     | Sale quotations      ← Devis
sc-crm-root-sale-quotations | Sale quotations      ← Devis CRM
sc-root-sale-orders         | Sale orders          ← Commandes
admin-root-batch-sale       | Sale batches         ← Batch
```

#### Synthèse Installation

**État final système** :
- ✅ **466 tables** (inchangé depuis BASE)
- ✅ **4 Apps actives** : BASE, STUDIO, CRM, SALE
- ✅ **333 menus** chargés (dont CRM et SALE maintenant visibles)
- ✅ **Init-data chargées** : 12 statuts (6 Lead + 6 Opportunity)
- ✅ **0 données démo** : Base vierge prête pour utilisation
- ✅ **Configurations** : À créer manuellement via interface

---

## 7. Tables et Données Créées

### 📋 Récapitulatif Complet

#### Vue d'Ensemble (Résultats Réels)

```
Avant premier démarrage
└── 0 tables (base PostgreSQL vide)

Après démarrage application (AVANT installation Apps)
└── 466 tables (BASE crée TOUTES les tables Axelor Open Suite)
    ├── Tables système Axelor (~100)
    ├── Tables BASE (~200) incluant base_product, base_partner, etc.
    ├── Tables STUDIO (~76) pour low-code
    ├── Tables META (~50) pour menus, actions, vues
    ├── Tables AUTH (~20) pour utilisateurs, permissions
    ├── Tables CRM (~31) ⚠️ Créées mais inutilisables
    ├── Tables SALE (~24) ⚠️ Créées mais inutilisables
    └── Tables PRODUCT (~25) ⚠️ Créées mais inutilisables

    État Apps : studio_app
    - base   : active=false
    - studio : active=false
    - crm    : active=false
    - sale   : active=false

Après installation BASE + STUDIO
└── 466 tables (INCHANGÉ)
    ✅ Apps BASE et STUDIO activées (active=true)
    ✅ Menus BASE et STUDIO visibles
    ✅ Tables CRM/SALE toujours présentes mais inutilisables
    ❌ Menus CRM/SALE présents mais inactifs

Après installation CRM
└── 466 tables (INCHANGÉ - tables existaient déjà)
    ✅ App CRM activée (active=true)
    ✅ Init-data chargées : 6 statuts Lead, 6 statuts Opportunity
    ✅ Menus CRM activés et visibles
    ✅ Tables CRM maintenant utilisables
    ❌ 0 données (leads, opportunities) : base vierge

Après installation SALE
└── 466 tables (INCHANGÉ - tables existaient déjà)
    ✅ App SALE activée (active=true)
    ✅ Init-data chargées : séquences, config
    ✅ Menus SALE activés et visibles
    ✅ Tables SALE et PRODUCT maintenant utilisables
    ❌ 0 données : catalogues à créer manuellement
```

**🔍 Découverte Architecturale Importante** :

L'installation de BASE crée **toutes** les tables d'Axelor Open Suite, y compris celles des modules non installés (CRM, SALE, etc.). L'installation d'une App :
1. ❌ **N'ajoute PAS** de nouvelles tables
2. ✅ **Active** l'App en base (`active=true`)
3. ✅ **Charge** les init-data (statuts, config)
4. ✅ **Active** les menus correspondants

Cette architecture explique pourquoi le build compile tous les modules (settings.gradle) mais les fonctionnalités ne sont accessibles qu'après installation des Apps.

#### Requêtes Utiles Inspection

**Compter tables par préfixe** :
```sql
SELECT
  SUBSTRING(table_name FROM '^[^_]+') AS prefix,
  COUNT(*) AS nb_tables
FROM information_schema.tables
WHERE table_schema = 'public'
GROUP BY prefix
ORDER BY nb_tables DESC;
```

**Lister Apps disponibles** :
```sql
SELECT
  code,
  name,
  active,
  CASE WHEN active THEN '✅ Installée' ELSE '❌ Disponible' END AS etat
FROM studio_app
ORDER BY active DESC, code;
```

**Vérifier menus d'une App** :
```sql
SELECT name, title, hidden, parent
FROM meta_menu
WHERE module = 'axelor-crm'
ORDER BY priority;
```

**Compter données init-data chargées** :
```sql
-- Statuts Leads
SELECT COUNT(*) FROM crm_lead_status;

-- Statuts Opportunités
SELECT COUNT(*) FROM crm_opportunity_status;

-- Séquences
SELECT code, prefixe, padding FROM base_sequence WHERE code LIKE '%lead%' OR code LIKE '%opportunity%';
```

---

## 8. Bonnes Pratiques

### ✅ Installation Apps

**Ordre recommandé** :
```
1. BASE      (obligatoire, fondation)
2. STUDIO    (outils low-code avant Apps métier)
3. CRM       (gestion clients/prospects)
4. SALE      (cycle commercial)
5. Autres... (selon besoins)
```

**Pourquoi cet ordre** :
- BASE : Requis pour toutes autres Apps
- STUDIO : Permet personnalisation immédiate des Apps suivantes
- CRM avant SALE : SALE dépend souvent de CRM (Partners)

**Checklist avant installation** :
- [ ] Backup base de données
- [ ] Environnement dev (tester avant prod)
- [ ] Documentation lue (PRD, agents)
- [ ] Espace disque suffisant
- [ ] Comprendre impact (tables, menus)

**Après installation** :
- [ ] Rafraîchir page navigateur (F5)
- [ ] Vérifier menus apparus
- [ ] Tester fonctionnalités de base
- [ ] Vérifier logs (pas d'erreurs)
- [ ] Documenter changements

### 🔍 Diagnostic

**App installée mais menu invisible** :

1. Vérifier active=true :
```sql
SELECT code, active FROM studio_app WHERE code = 'crm';
```

2. Rafraîchir page (Ctrl+Shift+R)

3. Vérifier rôle utilisateur :
```sql
SELECT r.name FROM auth_user u
JOIN auth_user_roles ur ON u.id = ur.user_id
JOIN auth_role r ON ur.role_id = r.id
WHERE u.code = 'admin';
```

4. Vérifier menu actif :
```sql
SELECT name, title, hidden FROM meta_menu WHERE name = 'crm-root';
```

**App ne s'installe pas** :

1. Vérifier logs :
```bash
docker-compose logs axelor --tail=100 | grep ERROR
```

2. Vérifier données init-data présentes :
```bash
ls modules/axelor-open-suite/axelor-crm/src/main/resources/apps/init-data/fr/
```

3. Vérifier espace disque :
```bash
docker exec axelor-vecia-postgres df -h
```

### 🚨 Éviter

❌ **NE PAS** :
- Installer Apps en production sans test dev
- Modifier `studio_app.active` manuellement en SQL
- Supprimer tables `studio_*` ou `meta_*`
- Désinstaller BASE (cassera tout)
- Installer trop d'Apps d'un coup (difficile à débugger)

---

## 9. Troubleshooting

### 🔧 Problèmes Courants

#### Problème 1 : Module compilé mais App invisible

**Symptôme** :
- Module dans `settings.gradle` ✅
- Build réussi ✅
- Menu absent dans interface ❌

**Diagnostic** :
```sql
SELECT code, name, active FROM studio_app WHERE code = 'crm';
-- active = false
```

**Solution** :
```
Apps Management → CRM → Install
```

#### Problème 2 : App installée mais menu toujours invisible

**Symptôme** :
- Installation réussie ✅
- `studio_app.active = true` ✅
- Menu CRM absent ❌

**Solutions** :

1. **Rafraîchir** :
   - Ctrl+Shift+R (hard refresh)
   - Vider cache navigateur
   - Se déconnecter/reconnecter

2. **Vérifier menu** :
```sql
SELECT name, title, hidden, active FROM meta_menu WHERE name = 'crm-root';
```

3. **Vérifier permissions utilisateur** :
```sql
SELECT p.name FROM auth_user u
JOIN auth_user_roles ur ON u.id = ur.user_id
JOIN auth_role r ON ur.role_id = r.id
JOIN auth_role_permissions rp ON r.id = rp.role_id
JOIN auth_permission p ON rp.permission_id = p.id
WHERE u.code = 'admin' AND p.object LIKE '%Lead%';
```

#### Problème 3 : Erreur lors installation App

**Symptôme** :
- Clic "Install"
- Message erreur
- App reste `active=false`

**Diagnostic** :
```bash
docker-compose logs axelor --tail=200 | grep -i "error\|exception"
```

**Causes possibles** :
- Données init-data corrompues
- Dépendances App manquantes
- Erreur SQL (contraintes, types)
- Espace disque insuffisant

**Solution** :
1. Lire logs complets
2. Corriger erreur spécifique
3. Réessayer installation

---

## 10. Références

### Documentation Projet

**Agents** :
- `.claude/agents/agent-configuration-crm.md` - Configuration CRM
- `.claude/agents/agent-data-management.md` - Gestion données

**Guides** :
- `.claude/docs/utilisateur/guide-administration-axelor.md` - Guide admin
- `.claude/docs/premier-deploiement-local.md` - Premier déploiement

**Contexte** :
- `CLAUDE.md` - Vue d'ensemble projet
- `.claude/docs/PRD.md` - Vision produit

### Documentation Officielle

**Axelor Open Platform** :
- https://docs.axelor.com/adk/7.4/
- https://docs.axelor.com/adk/7.4/dev-guide/data-import/

**Source Code** :
- https://github.com/axelor/axelor-open-platform
- https://github.com/axelor/axelor-open-suite

---

## 🎯 Conclusion

Ce document a expliqué en profondeur le cycle de vie des Applications Axelor, faisant le lien critique entre :
- ✅ **Code** (Modules Gradle)
- ✅ **Runtime** (WAR déployée)
- ✅ **Base de données** (Apps, Tables, Menus)
- ✅ **Interface** (Menus actifs)

**Points clés à retenir** :
1. **Module ≠ App** : Code compilé vs Application installée
2. **Installation manuelle requise** : Via Apps Management
3. **Apps pré-enregistrées** : Présentes en BDD (active=false)
4. **Init-data chargées** : À l'installation de l'App
5. **Menus activés** : Automatiquement après installation

**Prêt pour le développement Axelor ! 👨‍💻🚀**

---

*Cycle de Vie Apps Axelor - Documentation Développeur v1.0*
*Axelor Open Suite 8.3.15 / Open Platform 7.4*
*Dernière mise à jour : 3 Octobre 2025*
