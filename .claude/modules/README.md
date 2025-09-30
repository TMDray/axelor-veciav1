# 📦 Modules Axelor - Documentation

Ce dossier contient la documentation détaillée de chaque module Axelor pour le projet Vecia ERP.

---

## ⚠️ IMPORTANT : Modules Standards vs Modules Custom

### 📦 Modules Standards Axelor

Les modules standards (CRM, Ventes, Projet, Comptabilité, etc.) sont **déjà inclus** dans Axelor Open Suite 8.3.15.

**Action requise** : **ACTIVER** via Menu → Apps dans l'interface Axelor
**PAS besoin de** : Installer, télécharger, ou créer ces modules

### 💡 Modules Custom

Modules développés spécifiquement pour nos besoins métier (ex: `axelor-custom-ai`).

**Action requise** : **CRÉER** via `/create-module`, puis **ACTIVER**

---

## 🎯 Objectif de ce Dossier

Documenter **progressivement** :

**Pour modules standards** :
- Configuration effectuée
- Champs personnalisés ajoutés via Studio
- Workflows BPM créés
- Personnalisations vues/formulaires
- Best practices d'utilisation

**Pour modules custom** :
- Architecture et conception
- Entités et domaines créés
- Services métier développés
- Intégrations externes
- API et extensions

---

## 📋 Modules Standards Axelor (À Activer)

### Phase 1 : CRM & Ventes (En cours)

#### 1. Module CRM (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `crm.md` (à créer après activation)

**Fonctionnalités standards** :
- Gestion prospects et opportunités
- Pipeline commercial
- Historique interactions clients
- Événements et rendez-vous

**Personnalisations prévues** :
- Scoring maturité IA (champs custom via Studio)
- Qualification technique client
- Templates emails spécifiques IA

**Statut** : ⏳ À activer → 🔄 À documenter après configuration

---

#### 2. Module Ventes / Sales (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `sales.md` (à créer après activation)

**Fonctionnalités standards** :
- Devis et propositions commerciales
- Commandes clients
- Catalogue produits/services
- Facturation

**Personnalisations prévues** :
- Catalogue services IA custom
- Templates devis agence IA
- Modèles tarification (forfait/régie/abonnement)

**Statut** : ⏳ À activer → 🔄 À documenter après configuration

---

#### 3. Module Base / Contacts (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus (obligatoire)
**Fichier doc** : `base-contacts.md` (à créer après configuration)

**Fonctionnalités standards** :
- Annuaire entreprises et personnes
- Qualification contacts
- Historique échanges
- Gestion adresses

**Personnalisations prévues** :
- Champs qualification technique (stack, infrastructure)
- Scoring maturité IA
- Volume données, équipe data

**Statut** : ✅ Toujours actif (module base) → 🔄 À documenter après configuration

---

### Phase 2 : Gestion de Projet

#### 4. Module Projet (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `project.md` (à créer après activation)

**Statut** : ⏳ Phase 2 (à activer)

---

#### 5. Module Gestion à l'Affaire (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `business-project.md` (à créer après activation)

**Statut** : ⏳ Phase 2 (à activer)

---

#### 6. Module Feuilles de Temps (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `timesheet.md` (à créer après activation)

**Statut** : ⏳ Phase 2 (à activer)

---

### Phase 3 : Gestion Financière

#### 7. Module Facturation (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `invoice.md` (à créer après activation)

**Statut** : ⏳ Phase 3 (à activer)

---

#### 8. Module Comptabilité (Standard Axelor)
**Type** : Module standard Axelor ✅ Déjà inclus
**Fichier doc** : `account.md` (à créer après activation)

**Statut** : ⏳ Phase 3 (à activer)

---

## 💡 Modules Custom (À Développer)

### Module Custom AI
**Type** : Module CUSTOM 🔧 À créer avec `/create-module`
**Fichier doc** : `custom-ai.md` (à créer après développement)

**Description** : Module développé spécifiquement pour les besoins agence IA

**Fonctionnalités prévues** :
- Entité AIProject (projets IA spécifiques)
- Service calcul scoring maturité IA clients
- Templates documents IA personnalisés
- Intégration APIs externes (GitHub, Slack, etc.)
- Dashboards analytics projets IA

**Statut** : 💡 À développer Phase 2-3

---

## 📝 Template Module

Chaque fichier module devrait contenir :

```markdown
# Module [Nom du Module]

## Vue d'ensemble

- Version module
- Dépendances
- Objectif principal

## Configuration Standard

- Installation
- Configuration initiale
- Paramètres importants

## Personnalisations Vecia

### Champs Custom Ajoutés

- Liste champs avec type et usage

### Vues Modifiées

- Formulaires adaptés
- Grids personnalisées

### Workflows BPM

- Processus créés
- Diagrammes workflows

### Intégrations

- APIs externes
- Webhooks
- Connecteurs

## Utilisation

### Cas d'Usage Principaux

- Scénarios métier agence IA

### Exemples Concrets

- Captures d'écran
- Tutoriels pas-à-pas

## API et Développement

### Endpoints REST

- Principaux endpoints
- Exemples requêtes

### Code Métier

- Services Java importants
- Repositories
- Controllers

## Best Practices

- Bonnes pratiques d'utilisation
- Pièges à éviter
- Optimisations

## Références

- Documentation officielle
- Forum Axelor
- Issues GitHub
```

---

## 🚀 Workflow Documentation Module

### Quand Documenter

1. **Après activation module** : Configuration de base
2. **Après personnalisation** : Champs custom, vues
3. **Après intégration** : APIs, webhooks
4. **Résolution problème** : Ajouter section troubleshooting

### Comment Documenter

```bash
# 1. Créer fichier module
touch .claude/modules/crm.md

# 2. Utiliser template ci-dessus

# 3. Documenter au fil de l'eau
# - Screenshots dans .claude/docs/images/
# - Code exemples
# - Configurations

# 4. Mettre à jour README.md (ce fichier)
# Changer statut : ⏳ → 🔄 → ✅

# 5. Référencer dans claude.md si nécessaire
```

---

## 📊 Progression Modules

| Module | Phase | Statut | Documentation |
|--------|-------|--------|---------------|
| CRM | 1 | 🔄 À activer | ⏳ À créer |
| Ventes | 1 | 🔄 À activer | ⏳ À créer |
| Contacts | 1 | 🔄 À activer | ⏳ À créer |
| Projet | 2 | ⏳ Futur | ⏳ À créer |
| Gestion à l'affaire | 2 | ⏳ Futur | ⏳ À créer |
| Feuilles de temps | 2 | ⏳ Futur | ⏳ À créer |
| Documents (GED) | 2 | ⏳ Futur | ⏳ À créer |
| Facturation | 3 | ⏳ Futur | ⏳ À créer |
| Comptabilité | 3 | ⏳ Futur | ⏳ À créer |
| Budget | 3 | ⏳ Futur | ⏳ À créer |
| Contrats | 3 | ⏳ Futur | ⏳ À créer |
| Custom AI | 2-3 | 💡 À dev | ⏳ À créer |

**Légende** :
- ✅ Fait
- 🔄 En cours
- ⏳ À venir
- 💡 À développer

---

## 🔗 Liens Utiles

- **PRD (roadmap modules)** : `../docs/PRD.md`
- **Documentation technique Axelor** : `../docs/document-technique-axelor.md`
- **Contexte général** : `../../claude.md`
- **Documentation officielle Axelor** : https://docs.axelor.com/

---

## 💡 Bonnes Pratiques

### Documentation Progressive

✅ **Faire** :
- Documenter immédiatement après configuration
- Inclure screenshots et exemples
- Noter problèmes rencontrés et solutions
- Maintenir à jour régulièrement

❌ **Éviter** :
- Reporter documentation "pour plus tard"
- Documenter de mémoire (risque d'oublis)
- Garder info dans notes perso (partager !)

### Organisation

- **Un fichier = Un module** (sauf si petit module lié)
- **Sections claires** : Suivre template
- **Exemples concrets** : Code, configs, screenshots
- **Versioning** : Noter version module et date modif

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025
**Prochaine étape** : Activer et documenter modules Phase 1 (CRM, Ventes, Contacts)