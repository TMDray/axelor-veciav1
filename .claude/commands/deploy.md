# Commande `/deploy` - Déploiement sur Serveur Test

Cette commande automatise le déploiement d'Axelor sur le serveur de test HPE ProLiant via Tailscale VPN.

## 🎯 Objectif

Déployer l'application Axelor compilée sur le serveur de test distant en passant par l'agent connexion serveur.

## 📝 Usage

```
/deploy
```

Ou avec options :

```
/deploy --env test --restart
```

## 🔧 Actions Effectuées

1. **Vérification pré-déploiement** :
   - ✅ Vérifier que build local est OK (`./gradlew build`)
   - ✅ Vérifier connectivité Tailscale
   - ✅ Tester connexion SSH serveur

2. **Build et packaging** :
   - 📦 Compiler application : `./gradlew clean build`
   - 📦 Générer WAR ou package Docker

3. **Transfert vers serveur** :
   - 📤 Copier artefacts via SCP
   - 📤 Transférer configurations si nécessaire

4. **Déploiement distant** :
   - 🐳 Arrêter containers existants (si Docker)
   - 🐳 Déployer nouvelle version
   - 🐳 Démarrer services
   - ⏳ Attendre démarrage (health checks)

5. **Validation post-déploiement** :
   - ✅ Vérifier services actifs
   - ✅ Tester accès application
   - ✅ Consulter logs pour erreurs

## 🚀 Workflow Détaillé

### Étape 1 : Build Local

```bash
# Nettoyer et compiler
./gradlew clean build

# Vérifier succès build
echo "Build status: $?"
```

### Étape 2 : Connexion Serveur

```bash
# Utiliser agent connexion serveur
# Vérifier Tailscale actif
tailscale status | grep 100.124.143.6

# Tester SSH
ssh axelor@100.124.143.6 "echo 'Connexion OK'"
```

### Étape 3 : Transfert Fichiers

```bash
# Copier WAR (si déploiement Tomcat)
scp build/libs/axelor-vecia-1.0.0.war axelor@100.124.143.6:/home/axelor/deploy/

# Ou copier docker-compose.yml (si Docker)
scp docker-compose.yml axelor@100.124.143.6:/home/axelor/axelor-vecia/
```

### Étape 4 : Déploiement Docker

```bash
# Se connecter et déployer
ssh axelor@100.124.143.6 << 'DEPLOY'

cd /home/axelor/axelor-vecia

# Arrêter ancienne version
docker-compose down

# Pull/build nouvelle image
docker-compose build

# Démarrer nouvelle version
docker-compose up -d

# Attendre démarrage (30s)
sleep 30

# Vérifier status
docker-compose ps
docker-compose logs --tail=50 axelor

DEPLOY
```

### Étape 5 : Validation

```bash
# Test HTTP
curl -f http://100.124.143.6:8080/axelor-erp/ || echo "❌ Application non accessible"

# Vérifier logs
ssh axelor@100.124.143.6 "docker-compose -f /home/axelor/axelor-vecia/docker-compose.yml logs --tail=100 axelor"
```

## 🎛️ Options

| Option | Description | Exemple |
|--------|-------------|---------|
| `--env` | Environnement cible (test/prod) | `/deploy --env test` |
| `--restart` | Redémarrer services après déploiement | `/deploy --restart` |
| `--no-build` | Skip build local, utiliser WAR existant | `/deploy --no-build` |
| `--rollback` | Rollback version précédente | `/deploy --rollback` |

## 📊 Checklist Pré-Déploiement

Avant de lancer `/deploy`, vérifier :

- [ ] Build local réussi sans erreurs
- [ ] Tests passés (si configurés)
- [ ] Modifications committées dans Git
- [ ] Backup base de données effectué (si prod)
- [ ] Tailscale VPN actif
- [ ] Serveur accessible via SSH
- [ ] Services Docker opérationnels sur serveur

## ⚠️ Points d'Attention

### Downtime

Le déploiement implique un **court downtime** (1-2 minutes) :
- Arrêt ancienne version
- Démarrage nouvelle version
- Warm-up application

### Backup

⚠️ **TOUJOURS** faire backup base de données avant déploiement production :

```bash
# Backup PostgreSQL distant
ssh axelor@100.124.143.6 "docker exec citeos-postgres pg_dump -U axelor axelor_vecia | gzip > /home/axelor/backups/axelor_vecia_$(date +%Y%m%d_%H%M%S).sql.gz"
```

### Rollback

En cas de problème, rollback rapide :

```bash
# Revenir version Docker précédente
ssh axelor@100.124.143.6 "cd /home/axelor/axelor-vecia && docker-compose down && git checkout HEAD~1 && docker-compose up -d"
```

## 🔍 Troubleshooting

### Build Échoue

```bash
# Nettoyer cache Gradle
./gradlew clean
rm -rf build/

# Re-build
./gradlew build --refresh-dependencies
```

### Connexion SSH Impossible

```bash
# Vérifier Tailscale
tailscale status

# Ping serveur
ping 100.124.143.6

# Voir agent-connexion-serveur.md pour diagnostic complet
```

### Application ne Démarre Pas

```bash
# Consulter logs Docker
ssh axelor@100.124.143.6 "docker-compose -f /home/axelor/axelor-vecia/docker-compose.yml logs -f axelor"

# Vérifier ressources serveur
ssh axelor@100.124.143.6 "free -h && df -h"
```

### Base de Données Inaccessible

```bash
# Vérifier container PostgreSQL
ssh axelor@100.124.143.6 "docker ps | grep postgres"

# Tester connexion DB
ssh axelor@100.124.143.6 "docker exec citeos-postgres psql -U axelor -d axelor_vecia -c 'SELECT 1'"
```

## 📚 Références

- **Agent Connexion Serveur** : `.claude/agents/agent-connexion-serveur.md`
- **Documentation Docker** : `.claude/docs/document-technique-axelor.md` (section 8)
- **Architecture Serveur** : `.claude/docs/PRD.md` (section 4)

## 🔄 Script Automatisé

Un script complet de déploiement sera disponible dans `scripts/deploy-to-test.sh`.

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 30 Septembre 2025