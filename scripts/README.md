# 🛠️ Scripts Utilitaires - Axelor Vecia

Ce dossier contient les scripts d'automatisation pour le projet Axelor Vecia.

---

## 🎯 Objectif

Centraliser tous les scripts bash/shell utilitaires pour :
- Déploiement
- Backup et restauration
- Migration données
- Health checks et monitoring
- Maintenance

---

## 📋 Scripts Disponibles

### Déploiement

#### `deploy-to-test.sh`
**Statut** : À créer

**Description** : Déploie l'application sur le serveur de test HPE ProLiant

**Usage** :
```bash
./scripts/deploy-to-test.sh
```

**Actions** :
- Build local (`./gradlew build`)
- Transfert via SCP vers serveur
- Déploiement Docker distant
- Validation post-déploiement

---

### Backup et Restauration

#### `backup-database.sh`
**Statut** : À créer

**Description** : Sauvegarde la base de données PostgreSQL

**Usage** :
```bash
./scripts/backup-database.sh [env]
# env = local | test | prod
```

**Actions** :
- Dump PostgreSQL
- Compression (gzip)
- Stockage avec timestamp
- Optionnel : Upload vers storage distant

---

#### `restore-database.sh`
**Statut** : À créer

**Description** : Restaure une sauvegarde de base de données

**Usage** :
```bash
./scripts/restore-database.sh <backup-file> [env]
```

**Actions** :
- Arrêt application
- Drop/Create database
- Restore dump
- Redémarrage application

---

### Health Checks

#### `health-check.sh`
**Statut** : À créer

**Description** : Vérifie l'état de santé de l'application

**Usage** :
```bash
./scripts/health-check.sh [env]
```

**Checks** :
- Application HTTP accessible
- Base de données connectée
- Services Docker actifs
- Espace disque disponible
- Mémoire disponible

---

### Maintenance

#### `cleanup-docker.sh`
**Statut** : À créer

**Description** : Nettoie les images et containers Docker inutilisés

**Usage** :
```bash
./scripts/cleanup-docker.sh
```

**Actions** :
- Remove stopped containers
- Remove unused images
- Remove unused volumes
- Afficher espace récupéré

---

#### `update-modules.sh`
**Statut** : À créer

**Description** : Met à jour les modules Axelor (pull dernières versions)

**Usage** :
```bash
./scripts/update-modules.sh
```

**Actions** :
- Git pull latest
- Gradle refresh dependencies
- Rebuild application
- Tests de validation

---

### Migration Données

#### `import-demo-data.sh`
**Statut** : À créer

**Description** : Importe des données de démonstration

**Usage** :
```bash
./scripts/import-demo-data.sh
```

**Actions** :
- Lecture fichiers CSV/XML
- Import via API Axelor
- Validation données importées

---

#### `export-data.sh`
**Statut** : À créer

**Description** : Exporte des données Axelor

**Usage** :
```bash
./scripts/export-data.sh <entity> [format]
# format = csv | xml | json
```

---

### Connexion Serveur

#### `connect-server.sh`
**Statut** : À créer (basé sur agent-connexion-serveur)

**Description** : Connexion rapide au serveur de test

**Usage** :
```bash
./scripts/connect-server.sh
```

**Actions** :
- Vérification Tailscale
- Test ping serveur
- Connexion SSH
- Display status services

---

## 🔧 Conventions Scripts

### Nommage

✅ **Bonnes pratiques** :
- `kebab-case.sh`
- Verbe d'action au début : `backup-`, `deploy-`, `check-`
- Extension `.sh` obligatoire

### Structure Script Type

```bash
#!/bin/bash
# Description : [Description courte]
# Usage : ./script-name.sh [args]
# Auteur : Équipe Dev Axelor Vecia

set -e  # Exit on error
set -u  # Exit on undefined variable

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Couleurs output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonctions
error() {
    echo -e "${RED}❌ Erreur: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Main
main() {
    echo "🚀 [Nom Script]"

    # ... logique script ...

    success "Terminé !"
}

main "$@"
```

### Gestion Erreurs

✅ **Toujours** :
- `set -e` (stop on error)
- Vérifier prérequis (commandes, fichiers)
- Messages erreur clairs
- Exit codes appropriés (0 = succès, > 0 = erreur)

### Documentation Inline

```bash
# ============================================
# Section : Backup Database
# ============================================

# Vérifier PostgreSQL accessible
if ! pg_isready -h localhost -p 5432; then
    error "PostgreSQL non accessible"
fi

# Créer backup avec timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${TIMESTAMP}.sql.gz"
```

---

## 🎛️ Variables Environnement

Créer `.env` à la racine (ignoré par Git) :

```bash
# Serveur Test
TEST_SERVER_IP=100.124.143.6
TEST_SERVER_USER=axelor
TEST_SERVER_PATH=/home/axelor/axelor-vecia

# Base de données
DB_HOST=localhost
DB_PORT=5432
DB_NAME=axelor_vecia
DB_USER=axelor
DB_PASSWORD=

# Backup
BACKUP_DIR=/path/to/backups
BACKUP_RETENTION_DAYS=30

# Monitoring
HEALTH_CHECK_URL=http://localhost:8080/health
HEALTH_CHECK_TIMEOUT=10
```

Charger dans scripts :

```bash
# Charger variables environnement
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
else
    warning "Fichier .env non trouvé, utilisation valeurs par défaut"
fi
```

---

## 📋 Checklist Création Script

Avant de créer un nouveau script :

- [ ] Nom clair et descriptif
- [ ] Commentaire header (description, usage, auteur)
- [ ] `set -e` et `set -u`
- [ ] Fonctions helper (error, success, warning)
- [ ] Vérification prérequis
- [ ] Documentation inline
- [ ] Gestion erreurs robuste
- [ ] Messages utilisateur clairs
- [ ] Test sur environnement dev
- [ ] Rendre exécutable : `chmod +x script.sh`
- [ ] Documenter dans ce README

---

## 🚀 Utilisation Scripts

### Rendre Exécutable

```bash
chmod +x scripts/deploy-to-test.sh
```

### Exécuter

```bash
# Depuis racine projet
./scripts/deploy-to-test.sh

# Ou directement
bash scripts/deploy-to-test.sh
```

### Debugger

```bash
# Mode verbose
bash -x scripts/deploy-to-test.sh

# Mode trace
set -x  # dans le script
```

---

## 📚 Références

- **Agent Connexion Serveur** : `.claude/agents/agent-connexion-serveur.md` (scripts SSH/Tailscale)
- **Commande /deploy** : `.claude/commands/deploy.md`
- **Bash Best Practices** : https://google.github.io/styleguide/shellguide.html

---

## 💡 Bonnes Pratiques

### Sécurité

- ⚠️ **Ne jamais** hardcoder credentials
- ✅ Utiliser variables environnement
- ✅ Fichier `.env` dans `.gitignore`
- ✅ Valider inputs utilisateur
- ✅ Échapper variables dans commandes

### Performance

- ✅ Paralléliser tâches indépendantes
- ✅ Éviter boucles inutiles
- ✅ Cacher résultats commandes coûteuses
- ✅ Afficher progression pour tâches longues

### Maintenance

- ✅ Commenter code non évident
- ✅ Versionner scripts avec Git
- ✅ Tester après modifications
- ✅ Logger actions importantes
- ✅ Garder scripts simples et focalisés

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025