# Configuration Registry - Axelor Vecia

**Source of Truth** for all Axelor low-code configurations (Studio, BPM, Integrations).

This document is the **central inventory** of all configurations created in Axelor. It is updated automatically after each configuration change and serves as a reference for avoiding duplicates, understanding the current state, and planning future modifications.

**Format**: Based on GitOps principles and Configuration as Code (CaC) best practices 2025.

---

## 📊 Overview

| Category | Count | Last Updated |
|----------|-------|--------------|
| **Custom Fields** | 1 | 2025-10-03 |
| **Selections** | 1 | 2025-10-03 |
| **Custom Menus** | 2 | 2025-10-05 |
| **BPM Workflows** | 0 | - |
| **API Integrations** | 0 | - |
| **Custom Models** | 0 | - |

---

## 1. Custom Fields

### 1.1 Partner (base_partner)

| Field Name | Type | Selection | Required | Description | Created | Status |
|------------|------|-----------|----------|-------------|---------|--------|
| `statutContact` | Selection | `selection-statut-contact` | No | Type de relation commerciale | 2025-10-03 | ✅ Active |

**Details: statutContact**

```yaml
object: Partner
table: base_partner
field_name: statutContact
type: Selection
selection_name: selection-statut-contact
storage: JSON (attrs column)
required: false
default: null
created_date: 2025-10-03
created_by: Tanguy
studio_id: TBD  # À compléter après vérification dans Studio
access_path: Configuration → Studio → Base → Partner → Custom Fields

purpose: |
  Segmenter les entreprises par type de relation commerciale.
  Permet filtrage ciblé pour campagnes, reporting, workflows CRM.

values:
  - client: Client actif
  - partenaire: Partenaire commercial
  - prospect: Lead/Prospect qualifié
  - ancien-client: Client inactif

sql_queries:
  retrieve_all: |
    SELECT id, full_name, attrs->>'statutContact' AS statut_contact
    FROM base_partner
    WHERE attrs ? 'statutContact';

  count_by_status: |
    SELECT
      attrs->>'statutContact' AS statut,
      COUNT(*) AS nombre
    FROM base_partner
    WHERE attrs ? 'statutContact'
    GROUP BY attrs->>'statutContact'
    ORDER BY nombre DESC;

  filter_clients: |
    SELECT *
    FROM base_partner
    WHERE attrs->>'statutContact' = 'client'
      AND is_customer = TRUE;

migration: None required (new optional field)
backward_compatible: true
changelog_ref: .claude/changelogs/studio-changelog.md#1.0.1
config_file: .claude/configs/partner-config.yaml
```

---

## 2. Selections (Listes de Valeurs)

### 2.1 Active Selections

| Selection Name | Used By | Values Count | Description | Created |
|----------------|---------|--------------|-------------|---------|
| `selection-statut-contact` | Partner.statutContact | 4 | Types de relation commerciale | 2025-10-03 |

**Details: selection-statut-contact**

```yaml
selection_name: selection-statut-contact
module: base
used_by:
  - object: Partner
    field: statutContact

values:
  - value: client
    label: Client
    sequence: 10
    description: Client actif avec contrats en cours

  - value: partenaire
    label: Partenaire
    sequence: 20
    description: Partenaire commercial ou technique

  - value: prospect
    label: Prospect
    sequence: 30
    description: Lead qualifié ou prospect en cours

  - value: ancien-client
    label: Ancien Client
    sequence: 40
    description: Client inactif ou churned

future_values:
  - value: autre
    label: Autre
    sequence: 50
    planned: true
    description: Catégorie générique pour cas non couverts

access_path: Configuration → Studio → Base → Partner → Custom Fields → statutContact → Selection
created_date: 2025-10-03
```

---

## 3. Custom Menus (Code-based)

### 3.1 CRM Menus

| Menu Name | Parent | Module | Model | Domain Filter | Created | Status |
|-----------|--------|--------|-------|---------------|---------|--------|
| `crm-all-partners` | crm-root | axelor-vecia-crm | Partner | `self.isContact = false` | 2025-10-05 | ✅ Active |
| `crm-all-contacts` | crm-root | axelor-vecia-crm | Partner | `self.isContact = true AND self.isEmployee = false` | 2025-10-05 | ✅ Active |

**Details: crm-all-partners**

```yaml
menu_name: crm-all-partners
parent: crm-root
title: "All Partners"
action: action-vecia-crm-view-all-partners
module: axelor-vecia-crm
model: com.axelor.apps.base.db.Partner
domain: "self.isContact = false"
order: 5
conditional: "__config__.app.isApp('crm')"

views:
  - type: grid
    name: partner-grid
  - type: form
    name: partner-form

purpose: |
  Provide quick access to ALL companies directly from CRM main menu.
  Replaces unintuitive "Application Config → Referential → Partners" navigation.

business_impact: Improved UX for CRM users
approach: code_based_xml
file: /modules/axelor-vecia-crm/src/main/resources/views/Menu.xml
created_date: 2025-10-05
agent: agent-customization
```

**Details: crm-all-contacts**

```yaml
menu_name: crm-all-contacts
parent: crm-root
title: "All Contacts"
action: action-vecia-crm-view-all-contacts
module: axelor-vecia-crm
model: com.axelor.apps.base.db.Partner
domain: "self.isContact = true AND self.isEmployee = false"
order: 6
conditional: "__config__.app.isApp('crm')"

views:
  - type: grid
    name: contact-grid
  - type: form
    name: contact-form

purpose: |
  Provide quick access to ALL contacts (persons) directly from CRM main menu.
  Excludes employees for cleaner contact list.

business_impact: Improved UX for CRM users
approach: code_based_xml
file: /modules/axelor-vecia-crm/src/main/resources/views/Menu.xml
created_date: 2025-10-05
agent: agent-customization
```

**Module Configuration**

```yaml
module_name: axelor-vecia-crm
version: 1.0.0
type: custom_module
dependencies:
  - axelor-base (Partner model)
  - axelor-crm (CRM app)

files:
  menu_xml: /modules/axelor-vecia-crm/src/main/resources/views/Menu.xml
  module_properties: /modules/axelor-vecia-crm/src/main/resources/module.properties
  build_gradle: /modules/axelor-vecia-crm/build.gradle
  readme: /modules/axelor-vecia-crm/README.md

installation:
  settings_gradle: "include ':modules:axelor-vecia-crm'"
  build_command: "./gradlew clean build"
  deploy_command: "docker-compose up -d --build"

advantages:
  - Versioned in Git (reproductible)
  - Survives Axelor upgrades (not lost on update)
  - Multi-environment deployment (dev, test, prod)
  - CI/CD compatible
  - Code review friendly

config_file: .claude/configs/crm-menus-config.yaml
changelog_ref: .claude/changelogs/studio-changelog.md#unreleased
```

---

## 4. BPM Workflows

_Aucun workflow créé pour le moment._

### Planned Workflows

- **Lead Scoring Automation**: Calcul automatique du score lead basé sur custom fields (maturité IA, budget, urgence)
- **Opportunity Follow-up**: Relances automatiques selon statut opportunité
- **Partner Status Change Notifications**: Alertes lors changement de statut

---

## 4. API Integrations

_Aucune intégration créée pour le moment._

### Planned Integrations

- **LinkedIn Lead Import**: Webhook pour import automatique leads LinkedIn
- **Email Campaign API**: Intégration Mailchimp ou SendGrid
- **Analytics Export**: Export vers Google Analytics ou Mixpanel

---

## 5. Custom Models (Objets Métier Personnalisés)

_Aucun modèle custom créé pour le moment._

### Planned Custom Models

- **AI Service Catalog**: Catalogue des services IA proposés (ML, NLP, Computer Vision, etc.)
- **Project Milestones**: Jalons de projets IA avec suivi avancement
- **AI Maturity Assessment**: Questionnaire et scoring maturité IA client

---

## 6. Views & Forms Customization

_Aucune personnalisation de vue pour le moment._

### Planned View Customizations

- **Partner Form**: Ajout section dédiée "Classification" avec statutContact
- **Lead Form**: Section "AI Context" avec custom fields maturité
- **Opportunity Dashboard**: Widgets affichant répartition par statut client

---

## 📋 Naming Conventions

All configurations follow **kb-lowcode-standards.md** conventions:

### Field Names
- **Format**: camelCase
- **Examples**: `statutContact`, `niveauMaturiteIA`, `budgetIA`
- **Avoid**: snake_case, spaces, special characters

### Selection Names
- **Format**: kebab-case with `selection-` prefix
- **Examples**: `selection-statut-contact`, `selection-maturite-ia`
- **Pattern**: `selection-{domain}-{purpose}`

### Workflow Names
- **Format**: PascalCase with descriptive suffix
- **Examples**: `LeadScoringAutomation`, `OpportunityFollowupWorkflow`

### Custom Model Names
- **Format**: PascalCase (singular)
- **Examples**: `AIService`, `ProjectMilestone`, `AIMaturityAssessment`

---

## 🔍 Duplication Check Process

Before creating any new configuration:

1. **Search this registry** for similar field names, purposes, or objects
2. **Consult** `.claude/changelogs/studio-changelog.md` for recent changes
3. **Check Unreleased section** in changelogs for planned configurations
4. **Ask agent-configuration** for validation and naming check

If duplicate found:
- **Reuse existing** if purpose matches
- **Extend existing** if minor variation needed
- **Create new only** if fundamentally different purpose

---

## 📚 Documentation References

| Document | Purpose | Link |
|----------|---------|------|
| **Studio Changelog** | Detailed Studio modifications | [studio-changelog.md](changelogs/studio-changelog.md) |
| **BPM Changelog** | Detailed workflow modifications | [bpm-changelog.md](changelogs/bpm-changelog.md) |
| **API Changelog** | Detailed integration modifications | [api-changelog.md](changelogs/api-changelog.md) |
| **Global Changelog** | High-level project changes | [CHANGELOG.md](../CHANGELOG.md) |
| **KB Low-code Standards** | Naming conventions, best practices | [kb-lowcode-standards.md](knowledge-bases/kb-lowcode-standards.md) |
| **KB CRM Customization** | CRM custom field examples | [kb-crm-customization.md](knowledge-bases/kb-crm-customization.md) |
| **Partner Config (YAML)** | Partner configuration as code | [partner-config.yaml](configs/partner-config.yaml) |

---

## 🔄 Update Process

This registry is updated following this workflow:

1. **Before Creation**: Agent-configuration validates naming and checks duplication
2. **After Creation**: Agent-lowcode logs in appropriate changelog
3. **Registry Update**: Add entry to this file with complete metadata
4. **Config as Code**: Generate YAML file in `.claude/configs/`
5. **Git Commit**: Commit with conventional commit message

Example commit message:
```bash
feat(studio): add Partner status classification

- Created selection field statutContact on Partner
- Values: client, partenaire, prospect, ancien-client
- Updated configuration-registry.md
- Generated partner-config.yaml

See studio-changelog.md for details
```

---

## 📊 Statistics

### Configuration Growth Over Time

| Version | Custom Fields | Selections | Workflows | Integrations | Total |
|---------|---------------|------------|-----------|--------------|-------|
| 1.0.0 | 0 | 0 | 0 | 0 | 0 |
| 1.0.1 | 1 | 1 | 0 | 0 | 2 |

### Most Configured Objects

1. **Partner** (base_partner): 1 custom field
2. _Others to come_

---

## 🎯 Roadmap

### Phase 1 (Current - Q4 2025)
- [x] Partner type classification
- [ ] Lead AI context fields
- [ ] Lead scoring workflow
- [ ] LinkedIn integration

### Phase 2 (Q1 2026)
- [ ] Opportunity service catalog fields
- [ ] Project milestone tracking
- [ ] AI maturity assessment model
- [ ] Email campaign integration

### Phase 3 (Q2 2026)
- [ ] Advanced BPM workflows
- [ ] Analytics dashboards
- [ ] Custom reports
- [ ] External API exposures

---

**Last updated**: 2025-10-03
**Maintained by**: Configuration Team
**Version**: 1.0.1
**Format**: Keep a Changelog + Semantic Versioning
**Best Practices**: GitOps, Configuration as Code (2025)
