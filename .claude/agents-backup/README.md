# 🤖 Agents Spécialisés - Architecture Hybride

Ce dossier contient les **agents spécialisés** pour le projet Axelor Vecia. L'architecture suit un modèle **hybride modulaire** avec :
- **3 agents techniques transverses** : Expertise Studio, BPM, Intégrations (réutilisables)
- **Agents métier enrichis** : Vision 360° module (fonctionnel + low-code)

---

## 🏗️ Architecture Agents

### Modèle Hybride

```
🔧 Agents Techniques Transverses (3)
├── agent-studio.md           ← Expert Axelor Studio (custom fields, models, views)
├── agent-bpm.md               ← Expert workflows & automatisation BPMN 2.0
└── agent-integrations.md      ← Expert Axelor Connect, APIs, Webhooks

🏢 Agents Métier avec Section Low-Code (par module actif)
├── agent-crm.md               ← CRM complet (config + low-code + workflows + intégrations)
├── agent-data-management.md   ← Gestion données (import/export + migration)
├── agent-deploiement-local.md ← Déploiement local (build + docker + troubleshooting)
└── agent-connexion-serveur.md ← Connexion serveur distant (SSH + Tailscale)
```

**Avantages** :
- ✅ Agents techniques = expertise réutilisable (évite duplication)
- ✅ Agents métier = vision complète 360° du domaine
- ✅ Scalable : 1 agent métier par module activé
- ✅ Références croisées entre agents

---

## 📚 Agents Techniques Transverses

### 1. 🎨 Agent Studio

**Fichier** : `agent-studio.md`

**Mission** : Expert technique Axelor Studio - Plateforme low-code/no-code pour personnalisation Axelor

**Compétences** :
- Architecture MetaJsonField (JSON storage custom fields)
- 76 tables Studio + 37 tables Meta
- Custom fields (String, Integer, Decimal, Boolean, Date, Relations, Selection)
- Custom models (création nouveaux objets métier)
- Vues personnalisées (forms, grids, dashboards)
- Champs conditionnels (show_if, hide_if, required_if)

**Quand l'utiliser** :
- Ajouter custom fields dynamiquement
- Créer sélections (listes déroulantes)
- Personnaliser formulaires et vues
- Créer custom models
- Configuration web services
- Vérification configurations en base de données

**Points clés** :
```
Capabilities:
- ✅ Guider pas à pas dans Studio UI
- ✅ Vérifier configs en SQL
- ✅ Générer scripts SQL backup/export
- ❌ Ne peut pas exécuter directement (UI web requise)

Tables:
- meta_json_field (47 colonnes) : Définitions custom fields
- meta_json_model : Custom models
- studio_* : 76 tables configuration Studio
```

---

### 2. 🔄 Agent BPM

**Fichier** : `agent-bpm.md`

**Mission** : Expert workflows & automatisation BPMN 2.0 - Orchestration processus métier sans code

**Compétences** :
- BPMN 2.0 workflows (User Tasks, Script Tasks, Service Tasks)
- Groovy scripting (accès modèles Axelor, services)
- Gateways (Exclusive, Parallel, Inclusive)
- Events (Start, End, Timer, Message, Error)
- Notifications email et webhooks
- Monitoring et debugging workflows

**Quand l'utiliser** :
- Automatiser scoring leads CRM
- Workflows qualification/conversion
- Relances automatiques temporisées
- Orchestration processus projets IA
- Intégration actions automatiques
- Monitoring instances workflows

**Points clés** :
```
État BPM:
- App BPM disponible (active=false) ⚠️
- Module axelor-studio déjà déployé ✅
- Installation via Apps Management requise
- 0 tables BPM actuellement (post-installation: ~20-30 tables)

Workflows Pratiques Agence IA:
1. Qualification automatique Lead (scoring 0-100)
2. Relances temporisées (7j, 3j, lost)
3. Conversion Lead → Opportunity auto
4. Workflow projet IA (POC → MVP → Prod)
```

---

### 3. 🔌 Agent Integrations

**Fichier** : `agent-integrations.md`

**Mission** : Expert Axelor Connect, Web Services Studio, API REST, Webhooks - Connexion outils externes

**Compétences** :
- Axelor Connect (1500+ connecteurs préconfigurés)
- Web Services Studio (config APIs externes)
- API REST Axelor (/ws/rest, /ws/action)
- Authentification (OAuth2, API Key, Bearer Token)
- Webhooks entrants/sortants
- Transformation données (JSON, XML)

**Quand l'utiliser** :
- Sync emails Gmail → Leads Axelor
- Enrichissement Lead avec OpenAI/GPT
- Notifications Slack/Teams temps réel
- Intégration Google Calendar
- Webhooks GitHub → Projets Axelor
- APIs externes (scoring, data enrichment)

**Points clés** :
```
Axelor Connect:
- Gmail, Outlook, Slack, Teams, Trello
- Google Calendar, Drive, Dropbox
- OpenAI, Hugging Face (IA/ML)
- Stripe, PayPal (paiements)
- 1500+ connecteurs no-code

Web Services Studio:
- Configuration via interface graphique
- Auth: OAuth2, Bearer Token, API Key
- Mapping JSON/XML automatique
- Appel depuis BPM workflows
```

---

## 🏢 Agents Métier

### 1. 🎯 Agent Configuration CRM

**Fichier** : `agent-configuration-crm.md`

**Mission** : Expert configuration CRM Axelor pour agence IA - Vision 360° (fonctionnel + low-code + workflows + intégrations)

**Compétences** :
- Installation Apps CRM et Sales
- Configuration paramètres CRM via interface
- **Section Low-Code** : Custom fields agence IA (8 champs Lead)
- **Section BPM** : Workflows scoring, relances, conversion
- **Section Intégrations** : Gmail, OpenAI, Slack
- Pipeline commercial IA personnalisé
- Dashboards et KPIs agence IA

**Quand l'utiliser** :
- Installer et configurer CRM/Sales
- Ajouter custom fields (Niveau Maturité IA, Budget, Stack Technique, etc.)
- Créer workflows BPM (scoring automatique leads)
- Intégrer Gmail → Leads automatiques
- Enrichir leads avec OpenAI GPT
- Notifications Slack Hot Leads
- Configuration catalogue services IA

**Points clés** :
```
Custom Fields Lead IA (8):
1. niveauMaturiteIA (Selection: débutant/intermédiaire/avancé/expert)
2. budgetIA (Decimal)
3. stackTechnique (String)
4. secteurIA (Selection: CV/NLP/ML/DL)
5. equipeData (Boolean)
6. dataSources (Text)
7. urgenceProjet (Selection)
8. formationRequise (Boolean, hide_if expert)

Workflows BPM:
1. Scoring auto (0-100pts selon maturité, budget, urgence)
2. Relances temporisées (7j → 3j → lost)
3. Conversion Lead → Opportunity auto

Intégrations:
- Gmail → Lead (Axelor Connect)
- OpenAI enrichissement (Web Service Studio)
- Slack notifications (Webhook)
```

---

### 2. 📊 Agent Data Management

**Fichier** : `agent-data-management.md`

**Mission** : Expert spécialisé dans la gestion des données Axelor (import/export, init-data, migration, backup)

**Compétences** :
- Structure init-data, demo-data, data-init
- Import/Export CSV format Axelor
- Configuration input-config.xml
- Migration données legacy
- Backup et restore PostgreSQL
- Nettoyage et dédoublonnage
- Fixtures et seed data

**Quand l'utiliser** :
- Importer prospects depuis fichier Excel/CSV
- Exporter données CRM pour reporting
- Migrer données ancien CRM vers Axelor
- Créer données de test/démonstration
- Sauvegarder base de données
- Comprendre structure données Axelor
- Créer fichiers init-data custom

**Points clés** :
```
Import CSV :
- CRM → Leads → Import
- Format: CSV séparateur ";"
- Encodage: UTF-8

Export :
- CRM → Leads → Sélectionner → Export
- Format: CSV, Excel, PDF

Backup :
docker exec axelor-vecia-postgres pg_dump \
  -U axelor axelor_vecia > backup.sql
```

---

### 3. 🚀 Agent Déploiement Local

**Fichier** : `agent-deploiement-local.md`

**Mission** : Expert déploiement Axelor 8.3.15 en environnement local macOS avec Docker Desktop

**Compétences** :
- Build Gradle pour Axelor 8.3.15
- Configuration Docker multi-stage
- Troubleshooting macOS Docker Desktop
- Git submodules Axelor Open Suite
- Diagnostic et correction problèmes réseau
- Scripts automatisation déploiement

**Quand l'utiliser** :
- Premier déploiement local Axelor
- Problèmes build Gradle ou Docker
- Application inaccessible (port forwarding)
- Après redémarrage Docker Desktop
- Validation déploiement local
- Troubleshooting containers

**Commandes clés** :
```bash
# Redémarrage propre avec validation
./scripts/restart-axelor.sh

# Diagnostic complet (9 sections)
./scripts/diagnose-axelor.sh

# Correction problèmes réseau macOS
./scripts/fix-docker-network.sh

# Build complet
git submodule update --init --recursive
./gradlew clean build -x test
docker-compose build && docker-compose up -d
```

---

### 4. 🖥️ Agent Connexion Serveur

**Fichier** : `agent-connexion-serveur.md`

**Mission** : Expert connexion serveur HPE ProLiant ML30 Gen11 via Tailscale VPN

**Compétences** :
- Connexion SSH sécurisée via Tailscale VPN
- Diagnostic et résolution problèmes réseau
- Gestion Docker distant (PostgreSQL, Redis)
- Monitoring services et performance
- Troubleshooting WSL2/Ubuntu

**Quand l'utiliser** :
- Connexion au serveur de test (100.124.143.6)
- Déploiement application sur serveur distant
- Diagnostic problèmes connexion/réseau
- Monitoring services Docker
- Redémarrage services à distance

**Commandes clés** :
```bash
# Connexion SSH
ssh axelor@100.124.143.6

# Status services
ssh axelor@100.124.143.6 "docker ps"

# Diagnostic complet
# Voir scripts dans agent-connexion-serveur.md
```

---

## 🎯 Comment Utiliser un Agent

### Méthode 1 : Via Claude Code

```
@agent-connexion-serveur Je dois déployer Axelor sur le serveur de test,
peux-tu m'aider à me connecter et vérifier que tous les services sont OK ?
```

### Méthode 2 : Lecture Directe

1. Ouvrir le fichier markdown de l'agent
2. Consulter la section pertinente
3. Copier/exécuter les commandes nécessaires

### Méthode 3 : Scripts

Certains agents fournissent des scripts réutilisables :
- Copier dans `scripts/`
- Rendre exécutable : `chmod +x script.sh`
- Exécuter : `./script.sh`

---

## 📝 Structure d'un Agent

Chaque fichier agent contient généralement :

1. **Mission** : Objectif principal de l'agent
2. **Connaissances Essentielles** : Informations techniques nécessaires
3. **Architecture** : Schémas et configurations
4. **Problèmes Fréquents** : Troubleshooting
5. **Outils et Scripts** : Commandes et scripts utiles
6. **Best Practices** : Bonnes pratiques
7. **Historique** : Actions passées et résultats

---

## 🚀 Agents Futurs (Modules Prochaines Phases)

### 1. 📦 Agent Sales

**Mission** : Expert module Sales Axelor (Devis, Commandes, Produits)

**Compétences** :
- Configuration module Sales
- Templates devis personnalisés agence IA
- Catalogue produits/services IA
- Workflow devis → commande → facture
- Custom fields Sales (type projet, complexité, etc.)

**Statut** : À créer (Phase 1 active)

---

### 2. 📦 Agent Module Custom

**Mission** : Expert création modules Axelor custom (code Java)

**Compétences** :
- Structure modules Gradle
- Domaines XML et génération code
- Services métier Java
- Vues et formulaires custom
- Tests unitaires et intégration

**Statut** : À créer (Phase 2+)

---

### 3. 🚀 Agent CI/CD

**Mission** : Expert intégration continue et déploiement

**Compétences** :
- GitHub Actions / GitLab CI
- Tests automatisés (JUnit, Selenium)
- Build et packaging WAR
- Déploiement automatique (dev → test → prod)
- Rollback et versioning

**Statut** : À créer (Phase 2+)

---

## 💡 Bonnes Pratiques Agents

### Création d'un Nouvel Agent

1. **Identifier le domaine d'expertise** : Un agent = une mission claire
2. **Documenter exhaustivement** : Toutes connaissances nécessaires
3. **Inclure exemples concrets** : Commandes, scripts, configurations
4. **Prévoir troubleshooting** : Problèmes courants et solutions
5. **Maintenir à jour** : Mettre à jour après chaque intervention

### Utilisation Optimale

- ✅ **Consulter agent AVANT** de faire action complexe
- ✅ **Mettre à jour agent APRÈS** résolution nouveau problème
- ✅ **Documenter changements** dans section Historique
- ✅ **Partager connaissances** : Si solution trouvée, l'ajouter
- ✅ **Référencer agents** dans autres docs (claude.md, PRD, etc.)

---

## 🔗 Liens Utiles

- **Contexte général** : `../../claude.md`
- **Documentation technique** : `../docs/document-technique-axelor.md`
- **PRD** : `../docs/PRD.md`
- **Commandes personnalisées** : `../commands/`
- **Scripts** : `../../scripts/`

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Dernière mise à jour** : 3 Octobre 2025
