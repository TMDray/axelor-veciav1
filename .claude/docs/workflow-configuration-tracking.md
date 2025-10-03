# Workflow : Configuration Tracking System

**Guide complet** pour créer, documenter et tracker les configurations Axelor (Studio, BPM, APIs).

**Standard** : GitOps 2025, Keep a Changelog, Semantic Versioning, Conventional Commits

**Version** : 1.0.0

---

## 🎯 Objectif

Ce workflow garantit que **toutes les modifications** de configuration Axelor sont:
- ✅ **Documentées** automatiquement dans Git
- ✅ **Traçables** via changelogs structurés
- ✅ **Versionnées** avec Semantic Versioning
- ✅ **Auditables** avec historique complet
- ✅ **Reproductibles** via Configuration as Code

---

## 📋 Vue d'Ensemble du Workflow

```
┌─────────────────────────────────────────────────────┐
│  USER: "Je veux créer un custom field"              │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 1: Consultation agent-configuration          │
│  - Validation fonctionnelle                         │
│  - Check duplication (configuration-registry.md)    │
│  - Validation naming (kb-lowcode-standards.md)      │
│  - Choix type optimal (Selection vs Boolean, etc.)  │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 2: Documentation Pre-Creation                │
│  - agent-configuration met à jour:                  │
│    • configuration-registry.md                      │
│    • studio-changelog.md ([Unreleased])             │
│    • Génère {object}-config.yaml                    │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 3: Implémentation Technique                  │
│  - agent-lowcode fournit:                           │
│    • Studio UI steps détaillées                     │
│    • XML configuration (alternative)                │
│    • SQL queries exemples                           │
│    • Groovy scripts (si BPM)                        │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 4: Création dans Axelor Studio (USER)        │
│  - Suivre steps agent-lowcode                       │
│  - Créer custom field/selection                     │
│  - Tester dans l'interface                          │
│  - Noter Studio ID généré                           │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 5: Post-Creation Tracking                    │
│  - agent-lowcode rappelle de:                       │
│    • Compléter Studio ID dans changelog             │
│    • Vérifier documentation complète                │
│    • Tester SQL queries                             │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 6: Validation et Commit                      │
│  - Exécuter: ./scripts/validate-configs.sh          │
│  - Commit avec Conventional Commits:                │
│    feat(studio): add Partner status classification  │
│  - Push vers Git                                    │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────┐
│  ÉTAPE 7: Synchronisation Optionnelle               │
│  - Exécuter: ./scripts/sync-studio-to-git.sh        │
│  - Vérifier cohérence DB ↔ Git                      │
│  - Identifier éventuels drifts                      │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Workflow Détaillé

### ÉTAPE 1 : Consultation agent-configuration

**Objectif** : Valider le besoin et la conception avant création

**Actions User** :
```
Claude, je veux créer un custom field pour tracker le statut des entreprises
(prospect, client actif, client inactif, ancien client, partenaire).
```

**Actions agent-configuration** :
1. ✅ Pose questions de clarification (sur quel objet, requis ou non, etc.)
2. ✅ Consulte `configuration-registry.md` pour vérifier duplication
3. ✅ Valide naming selon `kb-lowcode-standards.md`
4. ✅ Suggère type optimal (Selection dans ce cas)
5. ✅ Propose naming conforme :
   - Field: `statutContact` (camelCase)
   - Selection: `selection-statut-contact` (kebab-case)
   - Values: `client`, `partenaire`, `prospect`, `ancien-client`

**Résultat** : Specs validées prêtes pour implémentation

---

### ÉTAPE 2 : Documentation Pre-Creation

**Objectif** : Documenter AVANT de créer dans Studio

**Actions agent-configuration** :

#### 2.1 Mise à jour configuration-registry.md

Ajoute dans `.claude/configuration-registry.md` :

```markdown
### 1.1 Partner (base_partner)

| Field Name | Type | Selection | Required | Description | Created | Status |
|------------|------|-----------|----------|-------------|---------|--------|
| `statutContact` | Selection | `selection-statut-contact` | No | Type relation commerciale | 2025-10-03 | ✅ Active |
```

#### 2.2 Mise à jour studio-changelog.md

Ajoute dans `.claude/changelogs/studio-changelog.md` section `[Unreleased]` :

```markdown
### Added

#### Partner.statutContact (Selection Field)

**Business Context:**
- Purpose: Segmenter entreprises par type de relation commerciale
- Use case: Filtrage ciblé pour campagnes, reporting, workflows CRM

**Technical Details:**
- Object: Partner (base_partner)
- Field name: statutContact
- Type: Selection
- Selection name: selection-statut-contact
- Values: client, partenaire, prospect, ancien-client
- Storage: JSON (attrs column)
- Required: No
- Created: 2025-10-03
```

#### 2.3 Génération Config YAML

Crée `.claude/configs/partner-config.yaml` avec métadonnées complètes.

**Résultat** : Configuration documentée avant création physique

---

### ÉTAPE 3 : Implémentation Technique

**Objectif** : Obtenir instructions précises pour créer dans Studio

**Actions agent-lowcode** :

Fournit guide complet:

```markdown
## Studio Configuration (UI)

1. Navigate to: **Configuration → Studio → Base → Partner**
2. Click: **Add Custom Field**
3. Configure:
   - Name: `statutContact`
   - Type: **Selection**
   - Title: "Statut Contact"
   - Required: ☐ No
   - Help: "Type de relation commerciale avec l'entreprise"

4. Create Selection: **selection-statut-contact**
   - Module: Base
   - Values:
     - client (Client) - Sequence: 10
     - partenaire (Partenaire) - Sequence: 20
     - prospect (Prospect) - Sequence: 30
     - ancien-client (Ancien Client) - Sequence: 40

5. Save and Test
```

**Résultat** : Instructions claires pour création UI

---

### ÉTAPE 4 : Création dans Axelor Studio

**Objectif** : Créer physiquement la configuration dans Axelor

**Actions User** :
1. Se connecter à Axelor
2. Suivre les étapes de agent-lowcode
3. Créer le custom field
4. Créer la selection
5. Tester dans l'interface
6. Noter le Studio ID généré (visible dans Studio)

**Résultat** : Custom field créé et fonctionnel dans Axelor

---

### ÉTAPE 5 : Post-Creation Tracking

**Objectif** : Compléter la documentation avec infos post-création

**Actions agent-lowcode (rappelle)** :

```markdown
⚠️ MANDATORY: Compléter la documentation

1. Ajouter Studio ID dans changelog:
   - Studio ID: custom_12345 (remplacer TO_BE_FILLED)

2. Tester les SQL queries fournies:
   - Vérifier que les queries fonctionnent
   - Ajuster si nécessaire

3. Vérifier configuration-registry.md:
   - Toutes les métadonnées complètes
   - Compteur Overview incrémenté
```

**Résultat** : Documentation complète et à jour

---

### ÉTAPE 6 : Validation et Commit

**Objectif** : Valider cohérence et commiter dans Git

**Actions User** :

#### 6.1 Validation Automatique

```bash
./scripts/validate-configs.sh
```

**Output attendu** :
```
╔══════════════════════════════════════════╗
║  ✅ Validation Configuration            ║
╚══════════════════════════════════════════╝

## Vérification Fichiers Requis
[1] CHANGELOG.md exists... ✅ OK
[2] configuration-registry.md exists... ✅ OK
[3] studio-changelog.md exists... ✅ OK

...

══════════════════════════════════════════
✅ 🎉 VALIDATION RÉUSSIE !
══════════════════════════════════════════

Toutes les configurations sont valides et cohérentes.
```

#### 6.2 Git Commit (Conventional Commits)

```bash
git add .
git commit -m "feat(studio): add Partner status classification

- Created selection field statutContact on Partner (base_partner)
- Values: client, partenaire, prospect, ancien-client
- Storage: JSON attrs column (backward compatible)
- Updated configuration-registry.md and studio-changelog.md
- Generated partner-config.yaml

See .claude/changelogs/studio-changelog.md for details

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
```

#### 6.3 Git Push

```bash
git push origin main
```

**Résultat** : Configuration versionnée dans Git

---

### ÉTAPE 7 : Synchronisation Optionnelle

**Objectif** : Vérifier que DB et Git sont synchronisés

**Actions User** :

```bash
./scripts/sync-studio-to-git.sh
```

**Output attendu** :
```
╔══════════════════════════════════════════╗
║  🔄 Sync Studio Config DB → Git         ║
╚══════════════════════════════════════════╝

ℹ️  Vérification container PostgreSQL...
✅ Container PostgreSQL opérationnel

ℹ️  Extraction custom fields depuis meta_json_field...
✅ 1 custom fields extraits
→ Fichier: .claude/configs/extracted/custom_fields.csv

ℹ️  Extraction selections depuis meta_select...
✅ 1 selections extraites
→ Fichier: .claude/configs/extracted/selections.csv

ℹ️  Comparaison avec configuration-registry.md...

📊 Statistiques:
   Custom fields DB      : 1
   Custom fields Registry: 1
✅ Configuration synchronisée

══════════════════════════════════════════
✅ 🎉 SYNCHRONISATION TERMINÉE !
══════════════════════════════════════════
```

**Résultat** : Confirmation DB ↔ Git synchronisé

---

## 📝 Exemples Complets

### Exemple 1 : Créer Custom Field Selection

**Commande initiale** :
```
Claude, je veux créer un champ pour classifier les entreprises :
- Client actif
- Partenaire
- Prospect
- Ancien client
```

**Résultat final** :
- ✅ Custom field `statutContact` créé dans Studio
- ✅ Selection `selection-statut-contact` avec 4 valeurs
- ✅ Documenté dans `configuration-registry.md`
- ✅ Logged dans `studio-changelog.md`
- ✅ Config YAML généré `partner-config.yaml`
- ✅ Commit Git avec conventional commits
- ✅ Validation passée

---

### Exemple 2 : Créer BPM Workflow

**Commande initiale** :
```
Claude, je veux un workflow qui change automatiquement le statut
Partner de "prospect" à "client" quand une Sale Order est créée.
```

**Workflow** :
1. agent-configuration → Valide besoin et specs
2. Documentation pre-creation dans `bpm-changelog.md`
3. agent-lowcode → Fournit BPMN structure + Groovy script
4. User → Crée workflow dans Studio BPM
5. Post-creation tracking dans `bpm-changelog.md`
6. Git commit : `feat(bpm): add Partner status auto-update workflow`

---

## 🔧 Scripts Disponibles

### sync-studio-to-git.sh

**Usage** :
```bash
./scripts/sync-studio-to-git.sh
```

**But** : Extraire configs DB → Git pour vérifier synchronisation

**Output** :
- `.claude/configs/extracted/custom_fields.csv`
- `.claude/configs/extracted/selections.csv`
- `.claude/configs/extracted/selection_values.csv`
- `.claude/configs/extracted/SUMMARY.md`

---

### validate-configs.sh

**Usage** :
```bash
./scripts/validate-configs.sh
```

**But** : Valider cohérence entre CHANGELOG, Registry, YAML configs

**Checks** :
- ✅ Fichiers requis existent
- ✅ Format changelogs conforme Keep a Changelog
- ✅ Versions cohérentes entre fichiers
- ✅ Naming conventions respectées
- ✅ Références entre fichiers valides

---

## 📚 Fichiers Clés

| Fichier | Rôle | Quand le consulter |
|---------|------|-------------------|
| `CHANGELOG.md` | Vue d'ensemble globale | Avant commit, release |
| `.claude/configuration-registry.md` | Source of Truth centrale | Avant création (check duplication) |
| `.claude/changelogs/studio-changelog.md` | Détails Studio | Après chaque config Studio |
| `.claude/changelogs/bpm-changelog.md` | Détails BPM | Après chaque workflow |
| `.claude/changelogs/api-changelog.md` | Détails API | Après chaque intégration |
| `.claude/configs/{object}-config.yaml` | Config as Code | Référence technique |
| `.claude/configs/templates/` | Templates réutilisables | Lors création nouvelles configs |

---

## 🎓 Best Practices

### ✅ DO

- **Documenter AVANT de créer** : Pre-creation documentation évite oublis
- **Commit fréquemment** : Après chaque config complète
- **Utiliser Conventional Commits** : `feat(studio):`, `fix(bpm):`, etc.
- **Valider avec scripts** : `validate-configs.sh` avant commit
- **Tester SQL queries** : Vérifier que les queries fournies fonctionnent
- **Compléter Studio ID** : Après création, noter ID dans changelog
- **Sync périodiquement** : `sync-studio-to-git.sh` une fois/semaine

### ❌ DON'T

- **Ne pas créer sans valider** : Toujours passer par agent-configuration
- **Ne pas skipper documentation** : GitOps = tout doit être tracé
- **Ne pas commit sans validation** : Toujours run `validate-configs.sh`
- **Ne pas dupliquer** : Checker registry avant créer nouveau champ
- **Ne pas utiliser espaces/underscores** : Suivre naming conventions
- **Ne pas oublier [Unreleased]** : Toujours log dans section Unreleased d'abord

---

## 🔄 Lifecycle d'une Configuration

```
[Created] → [Unreleased] → [Versioned] → [Deployed] → [Deprecated] → [Removed]
    ↓           ↓              ↓             ↓              ↓            ↓
  Studio    Changelog      Release        Prod         Warning      Migration
   (UI)    ([Unreleased])  ([1.1.0])    (tagged)    (1 version)   (2.0.0)
```

**Exemple Timeline** :

- **v1.0.0** : Initial deployment
- **v1.0.1** : Add Partner.statutContact (custom field)
- **v1.1.0** : Add selection value "autre" (minor change)
- **v1.5.0** : Deprecate statutContact (warning added)
- **v1.9.0** : Transition period (both old and new field)
- **v2.0.0** : Remove statutContact, replace with typeRelation (BREAKING)

---

## 📞 Support

**Questions** :
- agent-configuration : Validation fonctionnelle, naming, duplication
- agent-lowcode : Implémentation technique, SQL queries, Groovy scripts
- Documentation : Ce fichier + changelogs

**Problèmes** :
- Validation échoue : Vérifier fichiers requis existent
- Sync détecte drift : Mettre à jour registry pour refléter DB
- Commit bloqué : Vérifier format Conventional Commits

---

**Dernière mise à jour** : 2025-10-03
**Version** : 1.0.0
**Standard** : GitOps 2025, Keep a Changelog, Semantic Versioning
