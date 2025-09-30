# Commande `/git-commit-push` - Commit, Push et Mise à Jour Contexte

Cette commande automatise le workflow Git complet : commit des modifications, push vers GitHub, et mise à jour du contexte si nécessaire.

## 🎯 Objectif

Simplifier le workflow Git en automatisant :
- Staging des fichiers modifiés
- Commit avec message conventionnel
- Push vers branche courante
- Mise à jour `claude.md` et documentation si pertinent

## 📝 Usage

```
/git-commit-push
```

La commande demandera interactivement :
- Type de commit (feat/fix/docs/refactor/test/style/chore)
- Message commit
- Fichiers à inclure (ou tous par défaut)

## 🔧 Actions Effectuées

1. **Vérification état Git** :
   - ✅ Vérifier branche courante
   - ✅ Lister fichiers modifiés
   - ✅ Vérifier pas de conflits

2. **Staging fichiers** :
   - 📦 `git add` fichiers sélectionnés
   - ⚠️ Exclure fichiers sensibles (.env, credentials)

3. **Commit** :
   - 📝 Créer commit avec convention
   - 📝 Format : `<type>: <message>`

4. **Push** :
   - 📤 Push vers branche courante
   - 📤 Créer branche distante si nécessaire

5. **Mise à jour contexte** (si pertinent) :
   - 📋 Mettre à jour `claude.md`
   - 📋 Mettre à jour documentation modules/agents

## 🎨 Convention de Commits

### Types de Commits

| Type | Usage | Exemple |
|------|-------|---------|
| `feat` | Nouvelle fonctionnalité | `feat: Ajouter module CRM custom` |
| `fix` | Correction de bug | `fix: Corriger erreur connexion DB` |
| `docs` | Documentation uniquement | `docs: Mettre à jour PRD avec modules Phase 2` |
| `refactor` | Refactoring code (pas de nouvelle feature) | `refactor: Simplifier service AIProject` |
| `test` | Ajout/modification tests | `test: Ajouter tests unitaires CRM` |
| `style` | Formatage, typos (pas de logique) | `style: Formater code selon checkstyle` |
| `chore` | Maintenance (deps, config, build) | `chore: Mettre à jour dépendances Gradle` |

### Format Commit Message

```
<type>: <description courte (< 50 chars)>

[Corps optionnel : explication détaillée si nécessaire]

[Footer optionnel : références issues, breaking changes]
```

**Exemples** :

```bash
feat: Ajouter scoring maturité IA dans CRM

Implémentation du calcul automatique du score de maturité IA
basé sur les critères : infrastructure, équipe data, budget.

Closes #12
```

```bash
fix: Corriger erreur 500 lors création projet

Le champ 'budget' n'était pas correctement validé.
Ajout validation @NotNull et gestion exception.
```

## 🚀 Workflow Détaillé

### Étape 1 : Analyse État Git

```bash
# Vérifier branche courante
git branch --show-current

# Lister fichiers modifiés
git status --short

# Vérifier conflits
git diff --check
```

### Étape 2 : Sélection Fichiers

```bash
# Option 1 : Tous les fichiers
git add .

# Option 2 : Sélectif (interactif)
git add -p

# Option 3 : Fichiers spécifiques
git add src/main/java/com/axelor/apps/customai/service/AIProjectServiceImpl.java
```

### Étape 3 : Commit

```bash
# Commit avec message conventionnel
git commit -m "feat: Ajouter module custom IA

Module custom pour gestion projets IA spécifiques :
- Entité AIProject
- Service calcul score maturité
- Vues formulaires et grids
"
```

### Étape 4 : Push

```bash
# Push vers branche courante
git push origin $(git branch --show-current)

# Ou créer branche distante si première fois
git push -u origin feature/crm-custom
```

### Étape 5 : Mise à Jour Contexte

Si modifications impactent contexte :

```bash
# Mettre à jour claude.md
# Ajouter section "Dernières modifications" ou mettre à jour "Phase actuelle"

# Mettre à jour documentation pertinente
# Ex: .claude/modules/crm.md si modifs CRM
```

## 🎛️ Options

| Option | Description | Exemple |
|--------|-------------|---------|
| `--type <type>` | Spécifier type commit directement | `/git-commit-push --type feat` |
| `--message <msg>` | Message commit direct | `/git-commit-push --message "Ajouter CRM"` |
| `--files <files>` | Fichiers spécifiques à commit | `/git-commit-push --files "src/*.java"` |
| `--no-push` | Commit sans push | `/git-commit-push --no-push` |
| `--amend` | Amend dernier commit | `/git-commit-push --amend` |

## 📊 Checklist Pré-Commit

Avant de commit et push :

- [ ] Code compile sans erreurs
- [ ] Tests passent (si configurés)
- [ ] Pas de fichiers sensibles staged (.env, secrets)
- [ ] Message commit clair et descriptif
- [ ] Documentation mise à jour si nécessaire
- [ ] Pas de code commenté inutile
- [ ] Pas de console.log / System.out.println debug

## ⚠️ Points d'Attention

### Fichiers Sensibles

⚠️ **NE JAMAIS COMMITER** :
- `.env` et fichiers environnement
- `application-local.properties`
- Credentials, tokens, API keys
- Données clients réelles
- Backups base de données

Vérifier `.gitignore` est à jour !

### Taille Commits

✅ **Bonnes pratiques** :
- Commits atomiques (1 feature/fix = 1 commit)
- Messages descriptifs
- Push réguliers (plusieurs fois par jour)

❌ **À éviter** :
- Commits énormes ("WIP: 50 fichiers modifiés")
- Messages vagues ("update" / "fix" / "changes")
- Garder modifs locales plusieurs jours sans push

### Branches

**Stratégie branching projet** :

```
main (production)
  ↑
test (serveur test)
  ↑
dev (développement)
  ↑
feature/xxx (features)
```

Toujours commiter sur branche feature ou dev, **jamais directement sur main**.

## 🔍 Troubleshooting

### Push Rejeté (Divergence)

```bash
# Récupérer changements distants
git pull --rebase origin $(git branch --show-current)

# Résoudre conflits si nécessaire
git status
# ... éditer fichiers conflits ...
git add .
git rebase --continue

# Re-push
git push
```

### Commit Mal Formé

```bash
# Amend dernier commit
git commit --amend

# Ou reset et recommencer
git reset HEAD~1
git add ...
git commit -m "Nouveau message correct"
```

### Fichier Sensible Committé par Erreur

```bash
# ⚠️ SI PAS ENCORE PUSH :
git reset HEAD~1
git rm --cached fichier-sensible.env
# Ajouter à .gitignore
echo "fichier-sensible.env" >> .gitignore
git add .gitignore
git commit -m "chore: Ajouter fichier sensible au gitignore"

# ⚠️ SI DÉJÀ PUSH : Contacter équipe, rewrite history nécessaire
```

## 🔄 Mise à Jour Contexte Automatique

La commande détecte automatiquement si contexte doit être mis à jour :

### Déclencheurs Mise à Jour `claude.md`

- ✅ Ajout/suppression modules
- ✅ Changement phase projet
- ✅ Nouvelle infrastructure
- ✅ Changement version Axelor

### Déclencheurs Mise à Jour Documentation

- ✅ Nouveau module activé → `.claude/modules/<module>.md`
- ✅ Nouveau script → `scripts/README.md`
- ✅ Nouveau agent → `.claude/agents/README.md`
- ✅ Changement architecture → `.claude/docs/PRD.md`

## 📚 Références

- **Convention Commits** : https://www.conventionalcommits.org/
- **Git Best Practices** : `.claude/docs/git-workflow.md` (à créer)
- **Contexte général** : `claude.md`

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025