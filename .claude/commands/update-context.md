# Commande `/update-context` - Mise à Jour Contexte

Cette commande force la mise à jour de `claude.md` et de la documentation pour refléter l'état actuel du projet.

## 🎯 Objectif

Maintenir le contexte projet à jour après modifications importantes :
- Nouveaux modules activés
- Changements d'infrastructure
- Nouvelles intégrations
- Progression phases projet

## 📝 Usage

```
/update-context
```

Ou avec options :

```
/update-context --check
/update-context --file claude.md
```

## 🔧 Actions Effectuées

1. **Analyse état projet** :
   - 📊 Lister modules actifs
   - 📊 Vérifier version Axelor
   - 📊 Identifier phase actuelle
   - 📊 Détecter changements infrastructure

2. **Mise à jour `claude.md`** :
   - ✏️ Section "Phase Actuelle"
   - ✏️ Modules documentés
   - ✏️ Liens vers nouvelle documentation
   - ✏️ Date dernière mise à jour

3. **Mise à jour documentation associée** :
   - 📋 `.claude/modules/README.md` (progression modules)
   - 📋 `.claude/agents/README.md` (nouveaux agents)
   - 📋 `scripts/README.md` (nouveaux scripts)

4. **Validation** :
   - ✅ Vérifier tous liens fonctionnels
   - ✅ Vérifier cohérence entre docs
   - ✅ Générer rapport changements

## 🎯 Déclencheurs Mise à Jour

### Obligatoire

⚠️ Mettre à jour contexte après :

- **Nouveau module activé** : CRM, Ventes, Projet, etc.
- **Changement phase** : Phase 1 → Phase 2
- **Nouvelle infrastructure** : Serveur, Docker, BDD
- **Changement version** : Axelor 8.2 → 8.3
- **Nouveau workflow** : BPM, automatisation

### Recommandé

💡 Mettre à jour contexte après :

- **Personnalisation importante** : Champs custom, vues modifiées
- **Nouvelle intégration** : API externe, webhook
- **Nouveau script** : Déploiement, backup, migration
- **Résolution problème** : Solution à documenter

### Optionnel

✨ Mettre à jour contexte après :

- Corrections mineures
- Ajustements configuration
- Optimisations performance

## 📊 Sections `claude.md` à Maintenir

### 1. Phase Actuelle

```markdown
## 🎯 Phase Actuelle : Phase X - [Nom Phase]

### Objectif Immédiat
[Description objectif]

### Modules Phase X
1. Module A
2. Module B
...
```

**Quand mettre à jour** : Changement phase, nouveau module activé

### 2. Stack Technique

```markdown
## 📦 Version et Stack Technique

- **Axelor Open Suite** : vX.X.X
- **Axelor Open Platform** : vX.X
- **Java** : OpenJDK XX
...
```

**Quand mettre à jour** : Upgrade version, changement infrastructure

### 3. Navigation `.claude/`

```markdown
## 📂 Navigation dans `.claude/`

### Agents Spécialisés
- **agent-xxx.md** : [Description]
...

### Modules Axelor
- [Liste modules documentés]
...
```

**Quand mettre à jour** : Nouveau agent, nouveau module documenté

### 4. Date Dernière Mise à Jour

```markdown
---

**Dernière mise à jour** : YYYY-MM-DD
**Version Axelor** : X.X.X
**Phase** : Phase X - [Nom]
```

**Quand mettre à jour** : Toujours (automatique)

## 🔄 Workflow Mise à Jour

### Étape 1 : Détection Changements

```bash
# Vérifier fichiers modifiés depuis dernière update
git log --since="$(git log -1 --format=%cd claude.md)" --name-only --pretty=format:

# Identifier modules activés
ls -la modules/ | grep axelor

# Vérifier version Axelor
grep "version" build.gradle
```

### Étape 2 : Mise à Jour `claude.md`

```bash
# Éditer claude.md
# - Mettre à jour phase si changement
# - Ajouter nouveaux modules dans navigation
# - Mettre à jour date
```

### Étape 3 : Mise à Jour Docs Associées

```bash
# Mettre à jour .claude/modules/README.md
# - Changer statut modules (⏳ → 🔄 → ✅)
# - Ajouter liens nouveaux modules documentés

# Mettre à jour .claude/agents/README.md si nouveaux agents

# Mettre à jour scripts/README.md si nouveaux scripts
```

### Étape 4 : Validation

```bash
# Vérifier tous liens fonctionnent
# Lire claude.md et vérifier cohérence
# Tester accès rapide documentation
```

## 🎛️ Options

| Option | Description | Exemple |
|--------|-------------|---------|
| `--check` | Vérifier seulement si mise à jour nécessaire | `/update-context --check` |
| `--file <file>` | Mettre à jour fichier spécifique | `/update-context --file PRD.md` |
| `--dry-run` | Simulation sans écriture | `/update-context --dry-run` |
| `--force` | Forcer mise à jour même si pas de changements | `/update-context --force` |

## 📋 Checklist Mise à Jour Contexte

### Avant Mise à Jour

- [ ] Identifier ce qui a changé depuis dernière update
- [ ] Vérifier phase actuelle du projet
- [ ] Lister nouveaux modules/agents/scripts
- [ ] Préparer description changements

### Pendant Mise à Jour

- [ ] Mettre à jour `claude.md`
  - [ ] Phase actuelle
  - [ ] Stack technique (si changement)
  - [ ] Navigation `.claude/`
  - [ ] Date mise à jour
- [ ] Mettre à jour `.claude/modules/README.md`
- [ ] Mettre à jour `.claude/agents/README.md` (si nécessaire)
- [ ] Mettre à jour `scripts/README.md` (si nécessaire)

### Après Mise à Jour

- [ ] Relire `claude.md` pour cohérence
- [ ] Vérifier tous liens fonctionnels
- [ ] Commit changements : `docs: Mise à jour contexte projet`
- [ ] Push vers GitHub

## ⚠️ Points d'Attention

### Cohérence Documentation

Assurer cohérence entre :
- `claude.md` (contexte général)
- `.claude/docs/PRD.md` (vision produit)
- `.claude/docs/document-technique-axelor.md` (technique)
- `.claude/modules/README.md` (modules)

### Concision `claude.md`

⚠️ **Garder `claude.md` concis** (< 200 lignes) :
- Détails → fichiers spécialisés
- Liens → documentation complète
- Synthèse → informations clés

### Historique Changements

Optionnel : Ajouter section "Historique" dans `claude.md` :

```markdown
## 📜 Historique Changements

- **2025-09-30** : Setup initial, Phase 1 CRM
- **2025-10-15** : Activation module CRM, configuration custom IA
- **2025-11-01** : Passage Phase 2, modules Projet activés
```

## 🔍 Vérification Automatique

La commande peut détecter automatiquement si mise à jour nécessaire :

### Indicateurs Mise à Jour Nécessaire

✅ Mettre à jour si :
- Dernière update > 7 jours
- Nouveaux fichiers dans `.claude/modules/`
- Nouveaux fichiers dans `.claude/agents/`
- Modification `build.gradle` (version)
- Modification `application.properties`

### Commande Check

```bash
# Vérifier si mise à jour nécessaire
/update-context --check

# Output exemple:
# ⚠️ Mise à jour recommandée:
#   - Nouveau module détecté: .claude/modules/crm.md
#   - Dernière update: 15 jours
#   - build.gradle modifié récemment
```

## 📚 Références

- **Contexte général** : `claude.md`
- **PRD** : `.claude/docs/PRD.md`
- **Documentation technique** : `.claude/docs/document-technique-axelor.md`
- **Best practices Claude Code** : https://docs.claude.com/claude-code/

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025