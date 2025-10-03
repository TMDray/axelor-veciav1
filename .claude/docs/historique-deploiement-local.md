# Historique Déploiement Local - Axelor Vecia 8.3.15

Documentation des déploiements locaux (macOS + Docker Desktop) avec problèmes rencontrés et solutions.

---

## Déploiement #2 - 2025-10-03 : Problème Port Forwarding macOS

**Contexte** : Redéploiement local après mise en place architecture agents

**Objectif** : Tester processus de déploiement avec agent-deploiement

### 📝 Ce qui s'est passé

1. **Build initial** :
   - Arrêt propre : `docker-compose down`
   - Build réussi : `docker-compose build --no-cache` (938MB)
   - Containers démarrés, status "healthy"

2. **Problème découvert** :
   - Browser s'ouvre mais page inaccessible
   - `curl http://localhost:8080/` → "Empty reply from server"
   - Connexion TCP établie mais immédiatement fermée

3. **Diagnostic** :
   - ✅ Test depuis container : HTTP 200 OK
   - ❌ Test depuis macOS : Empty reply
   - Conclusion : Problème réseau Docker ↔ macOS, pas Axelor

### 🔍 Solutions Appliquées

**Solution 1 - Tomcat Configuration** :
- Recherches web : Tomcat écoute sur 127.0.0.1 au lieu de 0.0.0.0
- Fix Dockerfile :
  ```dockerfile
  RUN sed -i 's/<Connector port="8080" protocol="HTTP\/1.1"/<Connector port="8080" protocol="HTTP\/1.1"\n               address="0.0.0.0"/' \
      /usr/local/tomcat/conf/server.xml
  ```
- Résultat : Tomcat sur 0.0.0.0 mais **problème persiste**

**Solution 2 - Restart Docker Desktop** (solution finale) :
- Hypothèse : Port forwarding Docker Desktop corrompu
- Procédure :
  ```bash
  osascript -e 'quit app "Docker"'
  sleep 10
  open -a Docker
  sleep 60
  docker-compose up -d
  ```
- Résultat : ✅ **HTTP 200 OK** - Résolu !

### ✅ Ce qui a résolu

**Combinaison** :
1. **Fix permanent** : Tomcat `address="0.0.0.0"` (prévention future)
2. **Fix immédiat** : Restart Docker Desktop (cure du problème actuel)

### 📖 Leçons Apprises

1. **Docker Desktop macOS** : Port forwarding peut se corrompre après builds multiples
2. **Diagnostic méthodique** : Tester depuis container d'abord isole le problème
3. **Fix préventif vs curatif** : Les deux sont nécessaires
4. **Documentation** : Fichier diagnostic temporaire + historique simplifié

### 🔗 Références

- Diagnostic complet : `/tmp/axelor-deployment-diagnostic.md`
- Troubleshooting agent : `agent-deploiement.md` Issue 5 (ligne 636)
- GitHub issue connu : docker/for-mac#3763

### ⏱️ Temps

- Diagnostic + recherches : ~30 min
- Solution 1 (Tomcat) : ~10 min
- Solution 2 (Docker restart) : ~3 min
- Documentation : ~15 min
- **Total** : ~1h

---

## Déploiement #1 - 2025-09-30 : Setup Initial

**Contexte** : Premier déploiement Axelor 8.3.15 sur environnement local

**Objectif** : Setup infrastructure complète Docker (PostgreSQL + Axelor)

### 📝 Problèmes Rencontrés

| # | Problème | Cause | Solution | Temps |
|---|----------|-------|----------|-------|
| 1 | Modules manquants | Git submodules non initialisés | `git submodule update --init --recursive` | 2 min |
| 2 | Build Gradle échoue | Dépendance sur #1 | Résoudre #1 puis rebuild | 23 sec |
| 3 | Build Docker échoue | Image Debian Stretch EOL | Changer vers `tomcat:9-jre11` | 20 min |
| 4 | App inaccessible | Port forwarding macOS | Redémarrer Docker Desktop | 2 min |

### ✅ Résultat Final

- ✅ Application accessible http://localhost:8080
- ✅ Login admin/admin fonctionnel
- ✅ Modules Phase 1 chargés (base, crm, sale, studio, bpm)
- ✅ Base de données initialisée (300+ tables)
- ✅ Containers healthy (Axelor 1.3GB, PostgreSQL 150MB)

### 📖 Leçons Apprises

1. **Git Submodules** : Toujours exécuter `git submodule update --init --recursive` après clone
2. **Images Docker** : Éviter `-slim` sur distributions EOL, préférer Ubuntu LTS
3. **Port Forwarding macOS** : Redémarrer Docker Desktop résout bugs intermittents
4. **Healthchecks** : `start_period: 120s` pour Axelor (démarrage ~60-90s)

### 📊 Métriques

**Infrastructure créée** :
- Image Docker : 938 MB
- WAR Gradle : 238 MB
- Base de données : ~50 MB
- Total disque : ~1.3 GB

**Temps** :
- Premier déploiement : ~2h (incluant debug)
- Déploiements futurs estimés : ~30 min (grâce aux leçons)

### 🛠️ Scripts Créés

Suite à ce déploiement, 3 scripts créés :
- `scripts/restart-axelor.sh` - Redémarrage avec validation complète
- `scripts/diagnose-axelor.sh` - Diagnostic en 9 sections
- `scripts/fix-docker-network.sh` - Correction problèmes réseau macOS

---

## Bonnes Pratiques Validées

### Checklist Pré-Déploiement

```bash
# 1. Clone + submodules
git clone <repo-url>
cd axelor-vecia-v1
git submodule update --init --recursive

# 2. Vérifier modules
ls modules/axelor-open-suite/

# 3. Vérifier Docker
docker info

# 4. Vérifier ports libres
lsof -i :8080
lsof -i :5432
```

### Procédure Déploiement Validée

```bash
# 1. Build
docker-compose build

# 2. Démarrage
docker-compose up -d

# 3. Attente (60-90s première fois)
sleep 60

# 4. Vérification
docker-compose ps
curl -I http://localhost:8080/

# 5. Si problème réseau
# → Redémarrer Docker Desktop
```

### Configuration Docker Optimale

**Image de base recommandée** :
```dockerfile
FROM tomcat:9-jre11  # Ubuntu 24.04 LTS (pas -slim)
```

**Healthcheck Axelor** :
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/"]
  interval: 30s
  timeout: 10s
  start_period: 120s  # Important pour Axelor
  retries: 3
```

---

## Diagnostic Rapide

### Problème : Application Inaccessible

```bash
# 1. Vérifier containers
docker-compose ps
# → Doivent être "healthy"

# 2. Vérifier logs
docker-compose logs axelor | grep "Ready to serve"
# → Doit afficher "Ready to serve..."

# 3. Test depuis container
docker exec axelor-vecia-app curl -I http://localhost:8080/
# → Doit retourner HTTP 200

# 4. Test depuis macOS
curl -I http://localhost:8080/
# → Si échec = problème port forwarding

# 5. Solution
# → Redémarrer Docker Desktop
```

### Arbre de Décision

```
App inaccessible ?
├─ Container unhealthy ?
│  ├─ Oui → Voir logs, redémarrer container
│  └─ Non → Container healthy
│           ├─ HTTP OK depuis container ?
│           │  ├─ Oui → Problème port forwarding
│           │  │        → Redémarrer Docker Desktop ✅
│           │  └─ Non → Problème application
│           │           → Voir logs Tomcat
│           └─ Port TCP accessible ?
│              └─ Vérifier docker-compose.yml
```

---

## Commandes Utiles

### État Système

```bash
# Containers
docker-compose ps

# Logs
docker-compose logs -f axelor

# Ressources
docker stats axelor-vecia-app
```

### Démarrage/Arrêt

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Redémarrer proprement
./scripts/restart-axelor.sh
```

### Diagnostic

```bash
# Diagnostic complet
./scripts/diagnose-axelor.sh

# Test HTTP interne
docker exec axelor-vecia-app curl -I http://localhost:8080/

# Test HTTP externe
curl -I http://localhost:8080/
```

### Correction Problèmes

```bash
# Correction automatique
./scripts/fix-docker-network.sh

# Rebuild complet
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

---

**Dernière mise à jour** : 2025-10-03
**Environnement** : macOS + Docker Desktop
**Version Axelor** : 8.3.15
