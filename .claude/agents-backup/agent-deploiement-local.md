# 🚀 Agent Déploiement Local - Spécialiste Axelor sur macOS

## 🎯 Mission de l'Agent

**Agent Déploiement Local** est l'expert spécialisé dans le déploiement d'Axelor Open Suite 8.3.15 en environnement local macOS avec Docker Desktop. Cet agent maîtrise tous les aspects du build Gradle, de la conteneurisation Docker, et des problèmes spécifiques à macOS pour garantir un déploiement local rapide et fiable.

## 🧠 Connaissances Essentielles Requises

### 📋 **Architecture Stack Technique**

#### 🏗️ **1. Stack Axelor Vecia**

**Versions et Composants :**
```yaml
Axelor Open Suite:     8.3.15
Axelor Open Platform:  7.4
Java Runtime:          OpenJDK 11
PostgreSQL:            14-alpine
Gradle:                7.6
Tomcat:                9-jre11 (Ubuntu 24.04)
Docker:                Latest
Docker Compose:        v2.x
```

**Modules Activés (Phase 1 - Minimal) :**
- `axelor-base` - Socle de base obligatoire
- `axelor-crm` - Gestion relation client
- `axelor-sale` - Cycle de vente

**Tailles Générées :**
- WAR finale : 238 MB
- Image Docker : 938 MB
- RAM Axelor : ~1.3 GB
- RAM PostgreSQL : ~150 MB

#### 🐳 **2. Architecture Docker**

**Containers et Network :**
```
┌─────────────────────────────────────────┐
│   Docker Network: axelor-network        │
│   Driver: bridge                        │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │  axelor-vecia-app               │   │
│   │  - Tomcat 9.0.109               │   │
│   │  - Port: 8080:8080              │   │
│   │  - Health: curl localhost:8080  │   │
│   │  - Start period: 120s           │   │
│   └──────────────┬──────────────────┘   │
│                  │                      │
│                  ▼ JDBC                 │
│   ┌─────────────────────────────────┐   │
│   │  axelor-vecia-postgres          │   │
│   │  - PostgreSQL 14 Alpine         │   │
│   │  - Port: 5432:5432              │   │
│   │  - DB: axelor_vecia             │   │
│   │  - User: axelor / Pass: axelor  │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

**Volumes Persistants :**
- `postgres_data` → `/var/lib/postgresql/data`
- `axelor_data` → `/opt/axelor/data`
- `axelor_uploads` → `/opt/axelor/uploads`
- `axelor_logs` → `/usr/local/tomcat/logs`

#### 📁 **3. Structure Projet**

```
axelor-vecia-v1/
├── Dockerfile                    # Multi-stage build
├── docker-compose.yml            # Stack dev local
├── build.gradle                  # Config Axelor 8.3.15
├── settings.gradle               # Modules activés
├── .gitmodules                   # Submodule Axelor Open Suite
├── modules/
│   └── axelor-open-suite/        # Git submodule v8.3.15
│       ├── axelor-base/
│       ├── axelor-crm/
│       └── axelor-sale/
├── src/main/resources/
│   └── axelor-config.properties  # Config app (fr, dev)
└── scripts/
    ├── diagnose-axelor.sh        # Diagnostic 9 sections
    ├── fix-docker-network.sh     # Correction réseau macOS
    └── restart-axelor.sh         # Redémarrage propre
```

#### ⚙️ **4. Configuration Axelor**

**Fichier `axelor-config.properties` :**
```properties
# Mode et Locale
application.mode = dev
application.locale = fr

# Base URL
application.base-url = http://localhost:8080

# Base de données
db.default.driver = org.postgresql.Driver
db.default.url = jdbc:postgresql://postgres:5432/axelor_vecia
db.default.user = axelor
db.default.password = axelor

# Upload et stockage
file.upload.dir = /opt/axelor/uploads
data.export.dir = /opt/axelor/data-export
```

**Credentials par défaut :**
- Username : `admin`
- Password : `admin`

### 🚨 **Problèmes Fréquents et Solutions**

#### ❌ **Problème #1 : Git Submodules Non Initialisés**

**Symptôme :**
```bash
$ ./gradlew build
FAILURE: Build failed with an exception.
* What went wrong:
Project 'axelor-sale' not found in root project 'axelor-vecia'.
```

**Diagnostic :**
- Module déclaré dans `settings.gradle` ✅
- Répertoire `modules/axelor-open-suite/` vide ❌
- Fichier `.gitmodules` présent ✅

**Cause :**
Les git submodules ne sont **pas automatiquement clonés** avec `git clone`.

**Solution :**
```bash
# Initialiser tous les submodules
git submodule update --init --recursive

# Vérification
ls modules/axelor-open-suite/
# Doit afficher : axelor-base  axelor-crm  axelor-sale  ...
```

**Prévention :**
Toujours exécuter cette commande immédiatement après `git clone`.

---

#### ❌ **Problème #2 : Docker Build Failed - Debian Stretch EOL**

**Symptôme :**
```bash
$ docker-compose build
Step 5/20 : RUN apt-get update && apt-get install -y curl
 ---> Running in abc123def456
E: Failed to fetch http://deb.debian.org/debian/dists/stretch/main/binary-arm64/Packages  404  Not Found
exit code: 100
```

**Diagnostic :**
- Image de base : `tomcat:9-jre11-slim` (Debian Stretch) ❌
- Debian 9 Stretch en **end-of-life** depuis juin 2022
- Repositories APT ne sont plus maintenus
- Architecture ARM64 (Apple Silicon) aggrave le problème

**Cause :**
Distribution Debian obsolète sans support pour ARM64 macOS.

**Solution :**
Modifier `Dockerfile` ligne 40 :
```dockerfile
# AVANT (❌ Debian Stretch EOL)
FROM tomcat:9-jre11-slim

# APRÈS (✅ Ubuntu 24.04 LTS)
FROM tomcat:9-jre11

# Bonus : curl déjà inclus dans Ubuntu, supprimer ligne :
# RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

**Résultat :**
- Ubuntu 24.04 LTS (Noble) avec support ARM64 ✅
- curl pré-installé ✅
- Build réussit sans erreur ✅

**Leçon :**
Préférer Ubuntu LTS aux images `-slim` basées sur distributions obsolètes.

---

#### ❌ **Problème #3 : Application Inaccessible depuis macOS**

**Symptôme :**
```bash
$ curl http://localhost:8080/
curl: (52) Empty reply from server

# Mais dans le container :
$ docker exec axelor-vecia-app curl http://localhost:8080/
HTTP/1.1 200 OK  ✅
```

**Diagnostic Complet :**
```bash
# Test 1 : HTTP depuis container
docker exec axelor-vecia-app curl -f http://localhost:8080/
✅ HTTP 200 OK

# Test 2 : Port TCP accessible
nc -zv localhost 8080
✅ Connection succeeded

# Test 3 : HTTP depuis macOS
curl http://localhost:8080/
❌ Empty reply from server

# Test 4 : HTTP vers IP container
AXELOR_IP=$(docker inspect axelor-vecia-app --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
curl http://$AXELOR_IP:8080/
❌ Empty reply from server
```

**Analyse :**
- Container healthy ✅
- Application démarrée ("Ready to serve" dans logs) ✅
- Port TCP accessible ✅
- **Mais données HTTP pas transmises** ❌

**Cause :**
**Bug Docker Desktop macOS** - Port forwarding TCP fonctionne mais données HTTP ne transitent pas. Problème connu sur Apple Silicon avec certaines configurations réseau.

**Solutions Testées :**
1. ❌ `docker-compose restart` - ÉCHEC
2. ❌ `docker-compose down && up` - ÉCHEC
3. ❌ Accès via IP container - ÉCHEC
4. ✅ **Redémarrage Docker Desktop complet** - SUCCÈS

**Solution Validée :**
```bash
# Méthode 1 : Interface graphique
# 1. Quitter Docker Desktop (⌘Q)
# 2. Attendre 10 secondes
# 3. Relancer Docker Desktop
# 4. Attendre que Docker soit stable (icône verte)
# 5. Redémarrer containers
docker-compose up -d

# Méthode 2 : Ligne de commande
osascript -e 'quit app "Docker"'
sleep 10
open -a Docker
sleep 30
docker-compose up -d
```

**Prévention :**
Si le problème persiste après déploiements futurs, envisager :
- Augmenter mémoire Docker (Preferences → Resources)
- Mettre à jour Docker Desktop
- Vérifier firewall macOS

**Leçon :**
Sur macOS, problèmes réseau Docker nécessitent souvent redémarrage complet Docker Desktop, pas seulement des containers.

---

#### ❌ **Problème #4 : Build Gradle Dependencies**

**Symptôme :**
Dépend du Problème #1. Une fois submodules initialisés, build Gradle réussit automatiquement.

**Solution :**
```bash
./gradlew clean build -x test --no-daemon
```

**Résultat :**
```
BUILD SUCCESSFUL in 23s
Generated: build/libs/axelor-vecia-1.0.0.war (238 MB)
```

### 🔧 **Scripts et Outils Essentiels**

#### 📋 **Script 1 : Diagnostic Complet**

**Fichier :** `scripts/diagnose-axelor.sh`

**Usage :**
```bash
./scripts/diagnose-axelor.sh
```

**Fonctionnalités :**
- 9 sections de diagnostic
- État containers et santé
- Logs récents Axelor
- Configuration réseau Docker
- Tests connectivité (container, TCP, HTTP)
- Configuration Axelor et Tomcat
- Informations système
- Recommandations automatiques

**Quand l'utiliser :**
- Application inaccessible
- Containers démarrés mais problèmes
- Avant de demander support
- Après redémarrage Docker Desktop

---

#### 🔧 **Script 2 : Correction Problèmes Réseau**

**Fichier :** `scripts/fix-docker-network.sh`

**Usage :**
```bash
./scripts/fix-docker-network.sh
```

**Méthodes de correction (4 niveaux) :**

1. **Méthode 1** : Redémarrage containers simple
2. **Méthode 2** : Recréation complète (supprime volumes)
3. **Méthode 3** : Accès via IP container directe
4. **Méthode 4** : Solutions manuelles (redémarrage Docker Desktop)

**Quand l'utiliser :**
- Problème port forwarding macOS
- HTTP inaccessible malgré containers healthy
- Après mise à jour Docker Desktop

---

#### 🚀 **Script 3 : Redémarrage Propre**

**Fichier :** `scripts/restart-axelor.sh`

**Usage :**
```bash
./scripts/restart-axelor.sh
```

**Étapes automatisées :**
1. Vérification Docker démarré
2. Démarrage containers (`docker-compose up -d`)
3. Attente PostgreSQL (15s + validation)
4. Attente Axelor (60s + détection "Ready to serve")
5. Tests connectivité complets
6. Affichage URL et credentials

**Quand l'utiliser :**
- Après arrêt Docker Desktop
- Premier démarrage du jour
- Après modification configuration
- Validation déploiement

## 📋 **Workflow de Déploiement Complet**

### 🚀 **Premier Déploiement (From Scratch)**

```bash
# Étape 1 : Cloner et initialiser
git clone <repo-url> axelor-vecia-v1
cd axelor-vecia-v1
git submodule update --init --recursive

# Étape 2 : Vérifier configuration
cat settings.gradle  # Vérifier modules activés
cat Dockerfile       # Vérifier FROM tomcat:9-jre11 (pas -slim)

# Étape 3 : Build Gradle (optionnel, fait dans Docker)
./gradlew clean build -x test --no-daemon

# Étape 4 : Build et démarrage Docker
docker-compose build
docker-compose up -d

# Étape 5 : Attendre démarrage (90-120s)
./scripts/restart-axelor.sh

# Étape 6 : Validation
open http://localhost:8080/
# Login : admin / admin
```

**Durée estimée :** 30 minutes (après expérience du premier déploiement)

---

### 🔄 **Redémarrage Quotidien**

```bash
# Si Docker Desktop était arrêté
./scripts/restart-axelor.sh

# Accès application
open http://localhost:8080/
```

**Durée estimée :** 2-3 minutes

---

### 🛠️ **Après Modification Code**

```bash
# Rebuild application
./gradlew clean build -x test

# Reconstruire image et redémarrer
docker-compose down
docker-compose build
docker-compose up -d

# Validation
./scripts/diagnose-axelor.sh
```

---

### 🆘 **Troubleshooting - Application Inaccessible**

```bash
# 1. Diagnostic automatique
./scripts/diagnose-axelor.sh

# 2. Si problème port forwarding détecté
./scripts/fix-docker-network.sh

# 3. Si échec, redémarrage Docker Desktop
osascript -e 'quit app "Docker"'
sleep 10
open -a Docker
sleep 30
./scripts/restart-axelor.sh

# 4. Validation finale
curl -I http://localhost:8080/
# Doit retourner HTTP 200
```

## ✅ **Checkpoints Validation Déploiement**

### **Phase 1 : Prérequis**
- [ ] Docker Desktop installé et démarré
- [ ] 4+ GB RAM allouée à Docker
- [ ] 20+ GB espace disque disponible
- [ ] Git submodules initialisés

### **Phase 2 : Build**
- [ ] Gradle build réussit sans erreur
- [ ] WAR générée (~238 MB)
- [ ] Docker build réussit
- [ ] Images créées (~938 MB pour axelor-vecia)

### **Phase 3 : Containers**
- [ ] `docker-compose ps` affiche 2 containers
- [ ] PostgreSQL : Status "healthy"
- [ ] Axelor : Status "healthy"
- [ ] Pas de restart loops

### **Phase 4 : Application**
- [ ] Logs Axelor contiennent "Ready to serve"
- [ ] HTTP 200 depuis container : `docker exec axelor-vecia-app curl -f http://localhost:8080/`
- [ ] Port 8080 accessible : `nc -zv localhost 8080`
- [ ] HTTP 200 depuis macOS : `curl -I http://localhost:8080/`

### **Phase 5 : Accès Web**
- [ ] http://localhost:8080/ affiche page login
- [ ] Login admin/admin fonctionne
- [ ] Interface Axelor chargée complètement
- [ ] Pas d'erreurs console navigateur

## 💡 **Points d'Attention Spécifiques macOS**

### ⚠️ **Docker Desktop macOS (Apple Silicon)**

**Limitations connues :**
- Port forwarding peut échouer sans raison apparente
- Nécessite parfois redémarrage complet Docker Desktop
- ARM64 : Certaines images incompatibles (utiliser multi-arch)
- Performances I/O volumes moins bonnes que Linux natif

**Best Practices :**
- Allouer 4+ GB RAM minimum
- Éviter images `-slim` obsolètes (Debian Stretch)
- Privilégier Ubuntu LTS pour base images
- Redémarrer Docker Desktop après mise à jour macOS

### 🔐 **Sécurité Développement Local**

**Credentials par défaut :**
- PostgreSQL : axelor / axelor
- Axelor : admin / admin

**⚠️ ATTENTION :**
- Ces credentials sont pour développement local uniquement
- **JAMAIS** utiliser en production
- Fichier `.env` à créer (git-ignored) pour production

### 🔄 **Maintenance Préventive**

**Quotidien :**
- Vérifier logs : `docker-compose logs axelor --tail=50`
- Surveiller espace disque : `docker system df`

**Hebdomadaire :**
- Cleanup images inutilisées : `docker system prune -a`
- Backup volumes : `docker-compose down && cp -r volumes/ backup/`

**Mensuel :**
- Mise à jour Docker Desktop
- Vérifier mises à jour Axelor Open Suite
- Rebuild images from scratch

## 🎯 **Règles d'Or de Déploiement**

### 📚 **Philosophie : SIMPLE & REPRODUCTIBLE**

1. **Git submodules d'abord** : Toujours initialiser avant build
2. **Images à jour** : Ubuntu LTS, pas de distributions EOL
3. **Scripts automatisés** : Utiliser scripts fournis pour cohérence
4. **Diagnostic systématique** : Si problème, toujours lancer `diagnose-axelor.sh`
5. **Documentation** : Noter tous changements configuration

### 🎓 **Compétences Techniques Requises**

**Niveau Expert :**
- Architecture Docker multi-containers
- Debugging networking Docker Desktop macOS
- Build Gradle pour applications Axelor
- Troubleshooting Tomcat et applications Java

**Niveau Avancé :**
- Docker et docker-compose
- Linux command line
- Java ecosystem (JDK, WAR, classloader)
- PostgreSQL administration

**Niveau Intermédiaire :**
- Git et git submodules
- Concepts réseau (ports, TCP/HTTP)
- Logs analysis
- Basic shell scripting

## 🚀 **Informations Techniques Détaillées**

### 🌐 **URLs et Ports Importants**

```bash
# Application Axelor
http://localhost:8080/                  # Page d'accueil
http://localhost:8080/login.jsp         # Login direct

# Base de données PostgreSQL
localhost:5432                           # Port PostgreSQL
Database: axelor_vecia
User: axelor / Password: axelor

# Docker containers
axelor-vecia-app                         # Container Axelor
axelor-vecia-postgres                    # Container PostgreSQL
```

### 📊 **Commandes Essentielles**

```bash
# Status containers
docker-compose ps

# Logs temps réel
docker-compose logs -f axelor

# Logs PostgreSQL
docker-compose logs postgres

# Redémarrage propre
./scripts/restart-axelor.sh

# Diagnostic complet
./scripts/diagnose-axelor.sh

# Accès shell container
docker exec -it axelor-vecia-app bash

# Accès PostgreSQL
docker exec -it axelor-vecia-postgres psql -U axelor -d axelor_vecia

# Rebuild complet
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 📦 **Post-Déploiement : Installation des Apps**

### 🎯 **Distinction Critique : Module vs App**

⚠️ **Important** : Après déploiement, l'application démarre avec tous les **modules compilés** mais **aucune App installée** !

**Architecture Axelor** :
```
Module (Code)                    App (Base de données)
     ↓                                   ↓
settings.gradle         →        studio_app (active=false)
axelor-crm/                      ❌ Menus CRM invisibles
     ↓                                   ↓
Build Gradle            →        Tables créées mais inutilisables
     ↓                                   ↓
WAR déployée            →        ⚠️ Installation manuelle requise
```

**Symptôme courant** : "J'ai compilé CRM mais il n'apparaît pas dans l'interface !"
**Cause** : Module présent ≠ App installée
**Solution** : Installer les Apps via Apps Management

📖 **Documentation technique complète** : `.claude/docs/developpeur/cycle-vie-apps.md`

### ✅ **Checklist Installation Apps**

**Après déploiement réussi, installer les Apps dans cet ordre** :

#### 1️⃣ **BASE** (Obligatoire)
```
Interface : Apps Management → BASE → Install
Durée : ~30 secondes
Effet : Crée TOUTES les tables Axelor Open Suite (466 tables)
```

**Vérifie** :
```sql
SELECT code, name, active FROM studio_app WHERE code = 'base';
-- Résultat attendu : active = true
```

#### 2️⃣ **STUDIO** (Fortement recommandé)
```
Interface : Apps Management → STUDIO → Install
Durée : ~20 secondes
Effet : Active outils low-code (custom fields, workflows, web services)
```

**Pourquoi avant Apps métier** : Permet personnalisation immédiate des Apps suivantes

#### 3️⃣ **CRM** (Phase 1 - Prioritaire)
```
Interface : Apps Management → CRM → Install
Durée : ~30 secondes
Effet :
  - Active App CRM (active=true)
  - Charge 6 statuts Lead + 6 statuts Opportunity
  - Active menus CRM (Leads, Opportunities, etc.)
  - Tables crm_* deviennent utilisables
```

**Vérifie** :
```sql
-- App active
SELECT active FROM studio_app WHERE code = 'crm';  -- true

-- Statuts chargés
SELECT COUNT(*) FROM crm_lead_status;              -- 6
SELECT COUNT(*) FROM crm_opportunity_status;       -- 6

-- Menus visibles
SELECT name, title FROM meta_menu WHERE name = 'crm-root';
-- Résultat : crm-root | CRM
```

**Menus disponibles** : CRM → Leads, Opportunities, My CRM events, Configuration

#### 4️⃣ **SALE** (Phase 1 - Prioritaire)
```
Interface : Apps Management → SALE → Install
Durée : ~30 secondes
Effet :
  - Active App SALE (active=true)
  - Active menus Sales (Quotations, Orders)
  - Tables sale_* et base_product deviennent utilisables
```

**Vérifie** :
```sql
SELECT active FROM studio_app WHERE code = 'sale';  -- true
```

**Menus disponibles** : Sales → Sale quotations, Sale orders

#### 5️⃣ **BPM** (Optionnel - Phase 2+)
```
Interface : Apps Management → BPM → Install
Effet : Active workflows avancés BPM (Business Process Modeling)
Requis si : Automatisation processus complexes
```

### 🔍 **Diagnostic Post-Installation**

**Vérifier état complet Apps** :
```sql
SELECT
  code,
  name,
  active,
  CASE WHEN active THEN '✅ Installée' ELSE '❌ Disponible' END AS etat
FROM studio_app
ORDER BY active DESC, code;
```

**État attendu Phase 1** :
```
 code   | name   | active | etat
--------+--------+--------+--------------
 base   | Base   | t      | ✅ Installée
 crm    | CRM    | t      | ✅ Installée
 sale   | Sale   | t      | ✅ Installée
 studio | Studio | t      | ✅ Installée
 bpm    | BPM    | f      | ❌ Disponible
```

**Compter tables** :
```sql
SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';
-- Résultat : 466 tables (inchangé, créées par BASE)
```

**Vérifier menus actifs** :
```sql
SELECT name, title FROM meta_menu WHERE parent IS NULL ORDER BY priority;
-- Résultat doit inclure : CRM, Sales, Administration, etc.
```

### 🚨 **Troubleshooting Apps**

**Problème** : App installée mais menus invisibles
```bash
# Solution 1 : Vider cache navigateur + Ctrl+F5
# Solution 2 : Déconnexion/Reconnexion
# Solution 3 : Redémarrer Axelor
docker-compose restart axelor
```

**Problème** : Installation App échoue
```bash
# Vérifier logs
docker-compose logs -f axelor | grep -i "error\|exception"

# Vérifier base données accessible
docker exec axelor-vecia-postgres psql -U axelor -d axelor_vecia -c "SELECT 1;"
```

**Problème** : Comprendre pourquoi tables existent avant installation App
```
Réponse : BASE crée TOUTES les tables Axelor Open Suite au premier démarrage.
Les Apps activent seulement l'usage des tables (menus, permissions, init-data).
Documentation : .claude/docs/developpeur/cycle-vie-apps.md section 6
```

### 📋 **Ordre Installation Recommandé**

```
Déploiement Docker ✅
    ↓
Login admin/admin ✅
    ↓
Apps Management
    ↓
1. BASE      (30s)  ← Crée toutes tables
    ↓
2. STUDIO    (20s)  ← Active low-code
    ↓
3. CRM       (30s)  ← Gestion clients/prospects
    ↓
4. SALE      (30s)  ← Cycle commercial
    ↓
5. BPM       (20s)  ← Optionnel

Total : ~2 minutes
```

**Résultat final** :
- ✅ 4 Apps actives (BASE, STUDIO, CRM, SALE)
- ✅ 466 tables créées et utilisables
- ✅ Menus CRM et Sales visibles
- ✅ Base vierge prête pour saisie données
- ✅ Configuration à personnaliser via interface

**Prochaine étape** : Configuration CRM pour agence IA
→ Voir agent : `.claude/agents/agent-configuration-crm.md`

---

## 📋 **Historique de Déploiement**

### 🚀 **Premier Déploiement Local - 3 Octobre 2025**

**Mission accomplie :** Axelor 8.3.15 opérationnel en local ✅

**Durée totale :** ~2 heures (troubleshooting inclus)

**Problèmes rencontrés et résolus :**
1. ✅ Git submodules non initialisés
2. ✅ Docker build failed (Debian Stretch EOL)
3. ✅ Gradle build dependencies
4. ✅ Port forwarding Docker Desktop macOS

**Scripts créés :**
- ✅ `diagnose-axelor.sh` - Diagnostic 9 sections
- ✅ `fix-docker-network.sh` - Correction réseau macOS
- ✅ `restart-axelor.sh` - Redémarrage automatisé

**Documentation produite :**
- ✅ `.claude/docs/premier-deploiement-local.md` - Retour d'expérience complet

**Résultat final :**
- Application accessible : http://localhost:8080/
- Login fonctionnel : admin / admin
- 3 modules activés : base, crm, sale
- Infrastructure stable et reproductible

### 🎯 **Déploiements Futurs**

**Estimation durée :** ~30 minutes (avec scripts et documentation)

**Procédure simplifiée :**
1. Clone + submodules init (2 min)
2. Docker build (15 min)
3. Docker up + validation (10 min)
4. Tests fonctionnels (3 min)

**Gains :** 75% réduction temps grâce à documentation et scripts ✅

## 🎯 **Prêt pour la Mission**

L'Agent Déploiement Local dispose maintenant de toutes les connaissances essentielles pour déployer Axelor Open Suite 8.3.15 en environnement local macOS de manière fiable et reproductible.

**Approche :** Submodules → Build → Docker → Validation → Troubleshooting

**Objectif :** Déploiement local en < 30 minutes avec infrastructure stable

**Let's deploy! 🚀⚡**

---

## 📚 **Références**

### Documentation Projet
- `.claude/docs/premier-deploiement-local.md` - Retour d'expérience détaillé
- `CLAUDE.md` - Contexte général projet
- `.claude/docs/PRD.md` - Vision produit

### Scripts Outils
- `scripts/diagnose-axelor.sh` - Diagnostic automatique
- `scripts/fix-docker-network.sh` - Correction réseau
- `scripts/restart-axelor.sh` - Redémarrage propre

### Documentation Officielle
- Axelor Open Platform 7.4 : https://docs.axelor.com/adk/7.4/
- Axelor Open Suite : https://docs.axelor.com/
- Docker Documentation : https://docs.docker.com/
- Gradle Documentation : https://docs.gradle.org/

---

*Agent Déploiement Local v1.0 - Spécialiste Axelor macOS*
*Axelor Open Suite 8.3.15 - Déploiement Docker Local*
*Dernière mise à jour : 3 Octobre 2025*
