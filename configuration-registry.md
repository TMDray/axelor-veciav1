# Configuration Registry - Axelor Low-Code

**Version** : 1.0
**Dernière mise à jour** : 2025-10-03
**Responsable** : Tanguy
**Version Axelor** : 8.3.15 / AOP 7.4

---

## 📋 Table des Matières

- [Introduction](#introduction)
- [Custom Fields - Partner](#custom-fields---partner)
- [Custom Fields - Lead](#custom-fields---lead)
- [Custom Fields - Opportunity](#custom-fields---opportunity)
- [Custom Fields - Sale Order](#custom-fields---sale-order)
- [Selections](#selections)
- [Custom Models](#custom-models)
- [Workflows](#workflows)
- [Décisions Architecturales](#décisions-architecturales)
- [Changelog](#changelog)

---

## Introduction

### Objectif

Ce registre est la **source de vérité unique** pour toutes les configurations low-code du projet Axelor.

### Utilisation

**Avant toute création** :
1. Consulter ce registre → La configuration existe-t-elle déjà ?
2. Vérifier [kb-lowcode-standards.md](/.claude/knowledge-bases/kb-lowcode-standards.md) → Naming correct ?
3. Créer configuration via Studio
4. **Documenter ici** avec ID technique et requêtes SQL

**Agents** :
- `agent-configuration` consulte et met à jour ce registre automatiquement
- `agent-lowcode` utilise ce registre pour vérifier cohérence

---

## Custom Fields - Partner

**Table** : `base_partner`
**Module** : Base / CRM
**Colonne JSON** : `attrs`

### (Exemple) statutContact

> ⚠️ **Ceci est un exemple** - Pas encore créé
>
> Voir [Décisions Architecturales](#da-001--gestion-cycle-de-vie-contact) pour contexte

- **ID Technique** : *(À générer après création Studio)*
- **Type** : Selection
- **Selection** : `crm-partner-statut-select`
- **Titre** : Statut Contact
- **Requis** : Oui
- **Date création** : *(À renseigner)*
- **Créé par** : *(À renseigner)*
- **Objectif** : Gérer le cycle de vie du contact (prospect → client actif → client inactif → ancien client → partenaire)
- **Valeurs** : Voir [crm-partner-statut-select](#crm-partner-statut-select)
- **Conditions** : Aucune (toujours visible)
- **Utilisé dans** :
  - Vue form Partner (panel "Classification")
  - Dashboard CRM (KPI répartition statuts)
  - Workflow "Synchronisation Booléens" *(si Option C choisie)*
- **Relations** :
  - Peut synchroniser `isProspect`, `isCustomer` via workflow *(selon DA-001)*
- **Requêtes SQL** :
  ```sql
  -- Compter clients actifs
  SELECT COUNT(*)
  FROM base_partner
  WHERE attrs->>'statutContact' = 'client-actif';

  -- Répartition par statut
  SELECT
    attrs->>'statutContact' AS statut,
    COUNT(*) AS nb_partners
  FROM base_partner
  WHERE attrs ? 'statutContact'
  GROUP BY attrs->>'statutContact'
  ORDER BY nb_partners DESC;

  -- Clients inactifs depuis > 6 mois
  SELECT
    id,
    full_name,
    attrs->>'dateDebutRelation' AS debut_relation
  FROM base_partner
  WHERE attrs->>'statutContact' = 'client-inactif'
    AND (attrs->>'dateDebutRelation')::date < CURRENT_DATE - INTERVAL '6 months';
  ```

---

### (Template) [Nom Champ]

> Copier ce template pour ajouter nouveau custom field

- **ID Technique** : *(ID généré après création Studio)*
- **Type** : *(String, Integer, Decimal, Boolean, Date, DateTime, Selection, Many-to-One, Text)*
- **Selection** : *(Si type Selection)*
- **Titre** : *(Libellé affiché UI)*
- **Requis** : *(Oui/Non)*
- **Date création** : *(YYYY-MM-DD)*
- **Créé par** : *(Nom)*
- **Objectif** : *(Description métier du champ)*
- **Valeurs** : *(Valeurs possibles si Selection, ou Min/Max si Decimal)*
- **Conditions** : *(show_if, hide_if, required_if si applicable)*
- **Utilisé dans** :
  - *(Vue X)*
  - *(Dashboard Y)*
  - *(Workflow Z)*
- **Relations** : *(Autres champs liés, dépendances)*
- **Requêtes SQL** :
  ```sql
  -- Exemple requête
  SELECT ...
  ```

---

## Custom Fields - Lead

**Table** : `crm_lead`
**Module** : CRM
**Colonne JSON** : `attrs`

### (Existants - Référence KB)

Les custom fields Lead pour l'agence IA sont documentés dans :
**[kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md)** Section 1

**Résumé** :
- `niveauMaturiteIA` (Selection) - Niveau maturité IA
- `budgetIA` (Decimal) - Budget IA estimé
- `stackTechnique` (Text) - Stack technique client
- `infrastructureType` (Selection) - Type infrastructure
- `casUsageIA` (Text) - Cas d'usage IA souhaités
- `urgenceProjet` (Selection) - Urgence projet
- `dateLancement` (Date) - Date lancement souhaitée
- `leadScoringIA` (Integer, readonly) - Score lead IA (0-100)
- `sourceProspection` (Selection) - Source prospection

---

## Custom Fields - Opportunity

**Table** : `crm_opportunity`
**Module** : CRM
**Colonne JSON** : `attrs`

### (Existants - Référence KB)

Les custom fields Opportunity pour l'agence IA sont documentés dans :
**[kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md)** Section 2

**Résumé** :
- `typeServiceIA` (Selection) - Type service IA
- `complexiteProjet` (Selection) - Complexité projet
- `dureeEstimee` (Integer) - Durée estimée (jours)
- `modaliteTarification` (Selection) - Modalité tarification
- `techStack` (String) - Technologies proposées
- `ressourcesInternes` (Integer) - Nb ressources internes
- `partnersExterne` (Boolean) - Partenaires externes requis
- `milestones` (Text) - Milestones projet
- `risquesIdentifies` (Text) - Risques identifiés
- `kpis` (Text) - KPIs mesure succès

---

## Custom Fields - Sale Order

**Table** : `sale_sale_order`
**Module** : Sales
**Colonne JSON** : `attrs`

### (Existants - Référence KB)

Les custom fields Sale Order pour l'agence IA sont documentés dans :
**[kb-sales-customization.md](/.claude/knowledge-bases/kb-sales-customization.md)** Section 1

**Résumé** :
- `modeFacturation` (Selection) - Mode facturation
- `prixJourHomme` (Decimal) - Prix jour/homme (€)
- `tjmMoyen` (Decimal, readonly) - TJM moyen (€)
- `nbJoursEstimes` (Integer) - Nb jours estimés
- `contractType` (Selection) - Type contrat
- `ndaSigned` (Boolean) - NDA signé
- `ndaDate` (Date) - Date signature NDA
- `proprieteIntellectuelle` (Selection) - Propriété intellectuelle
- `slaType` (Selection) - SLA / Support
- `garantieResultats` (Boolean) - Garantie résultats
- `penaliteRetard` (Boolean) - Pénalités de retard
- `clauseReversibilite` (Boolean) - Clause réversibilité
- `maintenanceInclude` (Boolean) - Maintenance incluse
- `dureeMaintenance` (Integer) - Durée maintenance (mois)

---

## Selections

### (Exemple) crm-partner-statut-select

> ⚠️ **Ceci est un exemple** - Pas encore créé

- **Nom technique** : `crm-partner-statut-select`
- **Titre** : Statut Contact
- **Module** : axelor-crm (ou axelor-custom)
- **Table** : `meta_select`
- **Date création** : *(À renseigner)*
- **Créé par** : *(À renseigner)*

**Valeurs** :

| Valeur | Libellé | Séquence | Description | Actif |
|--------|---------|----------|-------------|-------|
| `prospect` | Prospect | 10 | Contact qualifié, opportunité potentielle non concrétisée | ✅ |
| `client-actif` | Client Actif | 20 | Client avec contrats en cours ou < 6 mois d'inactivité | ✅ |
| `client-inactif` | Client Inactif | 30 | Client sans activité depuis > 6 mois | ✅ |
| `ancien-client` | Ancien Client | 40 | Relation commerciale volontairement terminée | ✅ |
| `partenaire` | Partenaire | 50 | Partenaire commercial (co-marketing, revendeur, apporteur d'affaires) | ✅ |
| `fournisseur` | Fournisseur | 60 | Fournisseur de services ou produits | ✅ |

**Transitions autorisées** (workflow métier) :
```
prospect → client-actif (conversion lead)
client-actif → client-inactif (inactivité > 6 mois)
client-actif → ancien-client (fin relation volontaire)
client-inactif → client-actif (réactivation)
client-inactif → ancien-client (abandon définitif)
```

**Anti-pattern évité** : Duplication avec booléens natifs `isProspect`, `isCustomer` (voir [DA-001](#da-001--gestion-cycle-de-vie-contact))

**Solution** : *(Selon DA-001)*
- Option B : Selection custom uniquement
- Option C : Workflow BPM synchronise booléens automatiquement

**Requêtes SQL** :
```sql
-- Lister toutes les valeurs de la sélection
SELECT
  msi.value,
  msi.title,
  msi.sequence
FROM meta_select ms
JOIN meta_select_item msi ON msi.select_id = ms.id
WHERE ms.name = 'crm-partner-statut-select'
ORDER BY msi.sequence;

-- Statistiques d'utilisation
SELECT
  attrs->>'statutContact' AS statut,
  COUNT(*) AS nb_partners,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pourcentage
FROM base_partner
WHERE attrs ? 'statutContact'
GROUP BY attrs->>'statutContact'
ORDER BY nb_partners DESC;
```

---

### (Existantes - Référence KB)

**Selections CRM/Sales** documentées dans KBs :
- [kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md) : Selections Lead et Opportunity
- [kb-sales-customization.md](/.claude/knowledge-bases/kb-sales-customization.md) : Selections Sale Order

**Résumé** :
- `selection-maturite-ia` : Débutant, Intermédiaire, Avancé, Expert
- `selection-infrastructure` : On-Premise, Cloud AWS/Azure/GCP, Hybrid
- `selection-urgence` : Faible, Moyenne, Haute, Critique
- `selection-source` : LinkedIn, Référence Client, Site Web, Événement, Cold Email, Partenaire
- `selection-service-ia` : ML Custom, POC, Chatbot, Computer Vision, NLP, Intégration, Conseil
- `selection-complexite` : Simple, Moyenne, Complexe, Stratégique
- `selection-tarification` : Forfait, Régie, Abonnement, Success Fee, Hybride
- `selection-facturation` : Forfait, Régie, Abonnement, Success Fee
- `selection-contract-type` : Service Contract, License, SaaS, Framework, R&D
- `selection-ip-ownership` : Client, Agency, Shared, License Exclusive/Non-Exclusive
- `selection-sla` : None, Standard, Business Critical, 24/7

---

### (Template) [nom-selection]

> Copier ce template pour ajouter nouvelle sélection

- **Nom technique** : `[module]-[entity]-[concept]-select`
- **Titre** : *(Libellé)*
- **Module** : *(axelor-crm, axelor-custom, etc.)*
- **Table** : `meta_select`
- **Date création** : *(YYYY-MM-DD)*
- **Créé par** : *(Nom)*

**Valeurs** :

| Valeur | Libellé | Séquence | Description | Actif |
|--------|---------|----------|-------------|-------|
| `val1` | Label 1 | 10 | Description courte | ✅ |
| `val2` | Label 2 | 20 | Description courte | ✅ |

**Transitions autorisées** : *(Si workflow cycle de vie)*

**Anti-pattern évité** : *(Référence DA si applicable)*

**Requêtes SQL** :
```sql
-- Exemple requête
SELECT ...
```

---

## Custom Models

> Section pour documenter custom models créés via Studio (nouveau concept métier complet)

**Aucun custom model créé pour l'instant.**

### (Template) [CustomModelName]

- **Nom** : *(PascalCase)*
- **Module** : *(axelor-custom, etc.)*
- **Table** : `meta_json_model`
- **Date création** : *(YYYY-MM-DD)*
- **Créé par** : *(Nom)*
- **Objectif** : *(Description métier)*
- **Champs** :
  - `field1` (Type) : Description
  - `field2` (Type) : Description
- **Relations** :
  - Many-to-One vers `Partner`
  - One-to-Many vers `CustomModel2`
- **Vues générées** : Form, Grid
- **Menu** : *(Chemin menu)*

---

## Workflows

> Section pour documenter workflows BPM créés

### (Exemple) Workflow Lead Scoring IA

- **Nom** : `lead-scoring-ia`
- **Module** : CRM
- **Date création** : *(À renseigner)*
- **Créé par** : *(À renseigner)*
- **Déclencheur** : onCreate ou onChange sur Lead
- **Objectif** : Calculer automatiquement score Lead IA (0-100)
- **Logique** :
  - Maturité IA (0-40 pts)
  - Budget (0-30 pts)
  - Urgence (0-20 pts)
  - Source (0-10 pts)
- **Actions** :
  - Mettre à jour `leadScoringIA` (readonly)
  - Si score ≥ 70 → Assigner commercial (hot lead)
  - Si score < 40 → Campagne nurturing (cold lead)
- **Détails** : Voir [kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md) Section 3

---

### (Template) [workflow-name]

- **Nom** : `[workflow-name]`
- **Module** : *(Module)*
- **Date création** : *(YYYY-MM-DD)*
- **Créé par** : *(Nom)*
- **Déclencheur** : *(onCreate, onChange, Timer, etc.)*
- **Objectif** : *(Description)*
- **Logique** : *(Résumé logique métier)*
- **Actions** : *(Liste actions)*
- **Détails** : *(Référence KB ou documentation)*

---

## Décisions Architecturales

### DA-001 : Gestion Cycle de Vie Contact

- **Date** : 2025-10-03
- **Contexte** : Besoin de gérer différents types de contacts (prospect, client actif, client inactif, ancien client, partenaire) au-delà des booléens natifs Axelor (`isProspect`, `isCustomer`).

- **Options évaluées** :
  - **Option A** : Booléens natifs uniquement (`isProspect`, `isCustomer`, `isSupplier`)
    - ✅ Compatible modules Axelor natifs
    - ❌ Pas de notion "client inactif", "ancien client"
    - ❌ Statuts multiples possibles (client + prospect en même temps)

  - **Option B** : Custom field Selection `statutContact` uniquement
    - ✅ Statut unique clair (un contact = un statut)
    - ✅ Cycle de vie explicite
    - ✅ Segmentation facile (rapports, dashboards)
    - ✅ 100% low-code (via Studio)
    - ✅ Évolutif (facile d'ajouter nouveaux statuts)
    - ❌ Coexistence avec booléens natifs (possible confusion)

  - **Option C** : Hybride (Selection + Workflow synchronisation booléens)
    - ✅ Compatible modules natifs (booléens utilisés par Axelor)
    - ✅ Cycle de vie explicite (selection)
    - ✅ Automatisation (workflow synchronise)
    - ❌ Plus complexe à mettre en place
    - ❌ Nécessite workflow BPM
    - ❌ Redondance partielle

- **Décision** : **À PRENDRE** (en attente création effective)

  **Recommandation** : Option B (Selection custom uniquement) si simplicité prioritaire, ou Option C (Hybride) si compatibilité modules natifs requise.

- **Raisons** :
  - Besoin explicite de "client inactif" et "ancien client" (pas gérables avec booléens)
  - Cycle de vie métier clair (prospect → client → ancien client)
  - Segmentation marketing/CRM facilitée

- **Conséquences** :
  - Formation utilisateurs requise (ne pas dupliquer info booléens + selection)
  - Discipline requise pour maintenir cohérence
  - Si Option C : Workflow BPM à maintenir

- **Alternatives futures** :
  - Si confusion booléens/selection → Migrer Option B vers Option C
  - Si besoin historique détaillé → Ajouter table audit dédiée

---

### DA-002 : Naming Convention Selections

- **Date** : 2025-10-03
- **Décision** : **kebab-case** pour toutes les valeurs de sélection (values)
- **Raison** :
  - Lisibilité SQL : `WHERE attrs->>'statut' = 'client-actif'` (propre)
  - Compatibilité API REST (pas d'échappement espaces)
  - Cohérence avec conventions web (URL-friendly)
  - Évite bugs encodage/trim
- **Exemple** :
  - ✅ `client-actif` (kebab-case)
  - ❌ `"Client Actif"` (espaces)
  - ❌ `CLIENT_ACTIF` (underscores + majuscules)
- **Impact** : Tous les custom fields Selection doivent suivre cette convention
- **Exceptions** : Aucune

---

### (Template) DA-XXX : [Titre Décision]

- **Date** : *(YYYY-MM-DD)*
- **Contexte** : *(Problème à résoudre, besoin métier)*
- **Options évaluées** :
  - Option A : *(Description)*
  - Option B : *(Description)*
  - Option C : *(Description)* ✅ CHOISI

- **Décision** : *(Option choisie)*
- **Raisons** :
  - *(Raison 1)*
  - *(Raison 2)*

- **Conséquences** :
  - *(Conséquence positive 1)*
  - *(Conséquence négative 1 avec mitigation)*

- **Alternatives futures** : *(Si besoin évolution)*

---

## Changelog

### 2025-10-03

**Création registre** :
- ✅ Initialisation `configuration-registry.md`
- ✅ Template custom fields (Partner, Lead, Opportunity, Sale Order)
- ✅ Template selections
- ✅ Exemple `statutContact` (Partner) - non créé, juste exemple
- ✅ Exemple selection `crm-partner-statut-select` - non créé, juste exemple
- ✅ DA-001 : Décision gestion cycle de vie contact (en attente validation)
- ✅ DA-002 : Naming convention selections (kebab-case)

**Configurations existantes référencées** :
- Custom fields Lead (agence IA) → [kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md)
- Custom fields Opportunity (agence IA) → [kb-crm-customization.md](/.claude/knowledge-bases/kb-crm-customization.md)
- Custom fields Sale Order (agence IA) → [kb-sales-customization.md](/.claude/knowledge-bases/kb-sales-customization.md)
- Selections CRM/Sales → KBs correspondants

---

### (Template) YYYY-MM-DD

**Modifications** :
- ✅ Ajout custom field `[nomChamp]` (Partner)
- ✅ Ajout selection `[nom-selection]`
- ✅ Modification valeur selection `[ancienne]` → `[nouvelle]` (migration SQL)
- ✅ Suppression custom field obsolète `[nomChamp]` (cleanup)
- ✅ DA-XXX : Nouvelle décision architecturale

---

## Notes d'Utilisation

### Workflow Idéal

1. **Avant création** :
   - ✅ Je consulte ce registre → Existe déjà ?
   - ✅ Je consulte [kb-lowcode-standards.md](/.claude/knowledge-bases/kb-lowcode-standards.md) → Naming OK ?
   - ✅ Je demande validation à `agent-configuration`

2. **Création via Studio** :
   - ✅ Je crée dans Axelor Studio UI
   - ✅ Je note l'ID technique généré

3. **Documentation** :
   - ✅ Je complète ce registre avec :
     - ID technique
     - Date création
     - Requêtes SQL exemples
   - ✅ Je mets à jour Changelog (date du jour)

4. **Git** :
   - ✅ Je commit : `git add configuration-registry.md`
   - ✅ Message : `"docs: Add custom field statutContact (Partner)"`

### Maintenance

**Mensuel** :
- Review nouveaux champs créés (changelog)
- Vérifier utilisation réelle (SQL queries)
- Identifier champs orphelins (jamais renseignés)

**Trimestriel** :
- Audit cohérence naming conventions
- Mise à jour décisions architecturales si évolution
- Cleanup champs obsolètes

---

**Version** : 1.0
**Dernière mise à jour** : 2025-10-03
**Maintenu par** : Équipe Projet
**Source de vérité** : Ce fichier est la référence unique pour toutes configurations low-code
