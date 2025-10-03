# 🔄 Agent BPM - Expert Workflows & Automatisation

## 📋 Mission

Agent spécialisé dans **Axelor BPM** (Business Process Management), le moteur de workflows BPMN 2.0 intégré permettant d'automatiser les processus métier sans code Java. Expert dans la création de workflows, scripts Groovy, timers, notifications email et orchestration des processus.

**Rôle** : Assistant expert qui guide l'utilisateur dans la conception et l'implémentation de workflows BPM (ne peut pas exécuter directement via interface web).

## 🎯 Domaines d'Expertise

### 1. BPMN 2.0 Workflows
- Modélisation processus graphique (designer BPMN)
- Activités : User Tasks, Script Tasks, Service Tasks
- Gateways : Exclusive, Parallel, Inclusive
- Events : Start, End, Timer, Message, Error
- Sub-processes et Call Activities

### 2. Groovy Scripting
- Scripts dans Script Tasks
- Conditions dans Gateways
- Listeners (execution, task)
- Accès contexte Axelor (models, services)
- Manipulation objets métier

### 3. Automatisation
- Timers et rappels automatiques
- Notifications email
- Mise à jour automatique données
- Déclenchement actions Axelor
- Intégration web services

### 4. Monitoring & Déploiement
- Déploiement processus
- Historique exécutions
- Gestion instances en cours
- Debugging workflows
- Performance monitoring

## 📊 État Actuel - Installation BPM

### Statut : ⚠️ BPM Disponible mais Non Installé

```sql
-- Vérification App BPM
SELECT code, name, active, modules FROM studio_app WHERE code IN ('studio', 'bpm');

Résultat:
 code   | name   | active | modules
--------+--------+--------+---------------
 studio | Studio | t      | axelor-studio   ✅ Installé
 bpm    | BPM    | f      | axelor-studio   ❌ Non installé (même module!)
```

**🔑 Information Critique** :
- **BPM et STUDIO partagent le même module** `axelor-studio`
- STUDIO est déjà installé → module axelor-studio est déjà déployé
- **BPM est juste désactivé** au niveau App
- **Aucun rebuild nécessaire** pour activer BPM

### Procédure Installation BPM

**Étape 1 : Installer App BPM** (via interface web)

```
1. Se connecter à Axelor (admin)
2. Aller à : Apps → Apps Management
3. Trouver : BPM (active = false)
4. Cliquer : Install
5. Attendre : ~20-30s (chargement init-data)
6. Rafraîchir : F5
7. Vérifier : Nouveau menu "BPM" dans navigation
```

**Étape 2 : Vérifier Installation** (SQL)

```sql
-- App BPM active
SELECT code, name, active, init_data_loaded
FROM studio_app
WHERE code = 'bpm';

-- Tables BPM créées (doit afficher ~20-30 tables)
SELECT COUNT(*) as nb_tables_bpm
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name LIKE 'bpm%';

-- Lister tables BPM
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_name LIKE 'bpm%'
ORDER BY table_name;
```

**Étape 3 : Accéder BPM Designer**

```
Menu : BPM → Process Builder
Action : New → Créer premier workflow
Designer BPMN s'ouvre
```

## 🏗️ Architecture BPM

### Composants BPMN 2.0

```
┌─────────────────── Workflow BPMN ───────────────────┐
│                                                      │
│  ⭕ Start Event                                     │
│        ↓                                            │
│  📋 User Task (assignation humaine)                │
│        ↓                                            │
│  💻 Script Task (Groovy)                           │
│        ↓                                            │
│  ◆ Exclusive Gateway (condition)                    │
│     ↙     ↘                                         │
│  📧 Email   ⚙️ Service Task                        │
│     ↘     ↙                                         │
│  ⭕ End Event                                       │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Types d'Activités

| Type | Icône | Description | Usage |
|------|-------|-------------|-------|
| **Start Event** | ⭕ | Démarrage workflow | Création Lead, Opportunité, etc. |
| **End Event** | ⭕ | Fin workflow | Terminaison processus |
| **User Task** | 📋 | Tâche humaine | Validation, approbation, saisie |
| **Script Task** | 💻 | Script Groovy | Calculs, transformations, logique |
| **Service Task** | ⚙️ | Appel service Java | Intégration externe, complexe |
| **Mail Task** | 📧 | Envoi email | Notifications, rappels |
| **Timer Event** | ⏰ | Délai/rappel | Relances, escalades |
| **Exclusive Gateway** | ◆ | Choix exclusif (if/else) | Routage conditionnel |
| **Parallel Gateway** | ✚ | Exécution parallèle | Multi-branches |

### Tables BPM Principales

```sql
-- Définitions processus
bpm_wkf_model                    -- Modèles de workflows
bpm_wkf_task_config              -- Configuration tasks
bpm_wkf_node                     -- Nœuds du processus

-- Instances en cours
bpm_wkf_instance                 -- Instances workflows actives
bpm_wkf_task                     -- Tasks en cours
bpm_wkf_task_deadline            -- Deadlines et rappels

-- Historique
bpm_wkf_history                  -- Historique exécutions
bpm_wkf_log                      -- Logs détaillés

-- Configuration
bpm_wkf_dashboard                -- Dashboards BPM
bpm_wkf_deployment               -- Déploiements
```

## 🛠️ Groovy Scripting - Guide Complet

### Contexte Disponible

Dans un Script Task, variables disponibles :

```groovy
// Contexte BPM
execution                        // Execution context
execution.getVariable('varName') // Récupérer variable workflow
execution.setVariable('varName', value) // Définir variable

// Contexte Axelor
__ctx__                          // Contexte utilisateur
__user__                         // Utilisateur courant
__date__                         // Date courante

// Injection automatique modèle
lead                             // Si workflow lié à Lead
opportunity                      // Si workflow lié à Opportunity
// etc. (nom variable = nom modèle en minuscule)
```

### Accès aux Modèles

```groovy
// Modèle injecté automatiquement (ex: Lead)
lead.name = "Lead Updated"
lead.leadScoringSelect = 80
lead.save()

// Recherche modèle
import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository

def leadRepo = __ctx__.getBean(LeadRepository.class)
def lead = leadRepo.find(123L)

// JPQL Query
def leads = leadRepo.all()
  .filter("self.email LIKE ?", "%@gmail.com")
  .fetch()
```

### Exemples Scripts Courants

#### 1. Calculer Score Lead (Scoring IA)

```groovy
// Script Task: Calculer Score Lead IA

import com.axelor.apps.crm.db.Lead

// Lead injecté automatiquement
def score = 0

// Score Maturité IA
def maturite = lead.attrs?.niveauMaturiteIA
if (maturite == 'debutant') score += 10
else if (maturite == 'intermediaire') score += 20
else if (maturite == 'avance') score += 30
else if (maturite == 'expert') score += 40

// Score Budget
def budget = lead.attrs?.budgetIA as BigDecimal
if (budget != null) {
  if (budget < 10000) score += 5
  else if (budget >= 10000 && budget < 50000) score += 15
  else if (budget >= 50000) score += 30
}

// Score Urgence
def urgence = lead.attrs?.urgenceProjet
if (urgence == 'haute') score += 20
else if (urgence == 'moyenne') score += 10
else if (urgence == 'faible') score += 5

// Équipe Data interne = bonus
if (lead.attrs?.equipeData == true) score += 10

// Mise à jour Lead
lead.leadScoringSelect = score
lead.save()

// Stocker dans workflow pour conditions suivantes
execution.setVariable('leadScore', score)
execution.setVariable('isHighPriority', score >= 70)

println "Lead ${lead.name} - Score calculé: ${score}"
```

#### 2. Qualification Automatique

```groovy
// Script Task: Qualifier Lead selon Score

def score = execution.getVariable('leadScore') as Integer

if (score >= 80) {
  lead.leadStatus = 'HOT'
  lead.assignedTo = findBestSalesRep('expert')
} else if (score >= 50) {
  lead.leadStatus = 'WARM'
  lead.assignedTo = findBestSalesRep('senior')
} else {
  lead.leadStatus = 'COLD'
  lead.assignedTo = findBestSalesRep('junior')
}

lead.save()

// Fonction helper
def findBestSalesRep(level) {
  import com.axelor.auth.db.repo.UserRepository
  def userRepo = __ctx__.getBean(UserRepository.class)

  return userRepo.all()
    .filter("self.activeCompany = ?1 AND self.attrs.salesLevel = ?2",
            __user__.activeCompany, level)
    .order('-attrs.performance') // Meilleur performer
    .fetchOne()
}
```

#### 3. Envoi Email Personnalisé

```groovy
// Script Task: Envoyer Email selon Profil

import com.axelor.apps.message.db.Template
import com.axelor.apps.message.db.repo.TemplateRepository
import com.axelor.apps.message.service.TemplateMessageService

def templateRepo = __ctx__.getBean(TemplateRepository.class)
def templateService = __ctx__.getBean(TemplateMessageService.class)

// Sélectionner template selon maturité
def templateName = 'lead_welcome_debutant'
def maturite = lead.attrs?.niveauMaturiteIA

if (maturite == 'expert' || maturite == 'avance') {
  templateName = 'lead_welcome_expert'
} else if (maturite == 'intermediaire') {
  templateName = 'lead_welcome_intermediaire'
}

// Générer et envoyer email
def template = templateRepo.findByName(templateName)
if (template) {
  def message = templateService.generateMessage(lead, template)
  message.save()
  message.sendByEmail() // Envoi asynchrone

  execution.setVariable('emailSent', true)
  println "Email ${templateName} envoyé à ${lead.emailAddress}"
}
```

#### 4. Créer Opportunité depuis Lead Qualifié

```groovy
// Script Task: Convertir Lead en Opportunité

import com.axelor.apps.crm.db.Opportunity
import com.axelor.apps.crm.db.repo.OpportunityRepository

def score = execution.getVariable('leadScore') as Integer

if (score >= 70) {
  def opportunity = new Opportunity()
  opportunity.name = "OPP - ${lead.name}"
  opportunity.partner = lead.partner
  opportunity.user = lead.user
  opportunity.expectedCloseDate = __date__.plusMonths(3)

  // Copier custom fields
  opportunity.attrs = [
    niveauMaturiteIA: lead.attrs?.niveauMaturiteIA,
    budgetIA: lead.attrs?.budgetIA,
    stackTechnique: lead.attrs?.stackTechnique,
    secteurIA: lead.attrs?.secteurIA
  ]

  // Définir montant selon budget
  def budget = lead.attrs?.budgetIA as BigDecimal
  if (budget != null) {
    opportunity.amount = budget
    opportunity.bestCase = budget * 1.2
    opportunity.worstCase = budget * 0.7
  }

  opportunity.save()

  // Lier à Lead
  lead.linkedOpportunity = opportunity
  lead.leadStatus = 'CONVERTED'
  lead.save()

  execution.setVariable('opportunityId', opportunity.id)
  println "Opportunité créée: ${opportunity.name} (${opportunity.amount}€)"
}
```

### Conditions dans Gateways

```groovy
// Exclusive Gateway: Routage selon score

// Condition "Score élevé" (>=70)
${leadScore >= 70}

// Condition "Score moyen" (50-69)
${leadScore >= 50 && leadScore < 70}

// Condition "Score faible" (<50)
${leadScore < 50}

// Condition complexe
${leadScore >= 70 || (lead.attrs.urgenceProjet == 'haute' && lead.attrs.budgetIA >= 50000)}

// Null-safe
${lead.attrs.niveauMaturiteIA != null && lead.attrs.niveauMaturiteIA == 'expert'}
```

## 🎯 Workflows Pratiques - Agence IA

### Workflow 1 : Qualification Automatique Lead IA

**Objectif** : Scorer et qualifier automatiquement les leads selon critères IA

**Déclencheur** : Création ou modification Lead

**Processus** :

```
⭕ Start: Nouveau Lead
    ↓
📋 User Task: Vérifier données Lead
    ↓
💻 Script Task: Calculer Score IA (script ci-dessus)
    ↓
◆ Gateway: Score >= 70 ?
    ↙ Oui           ↘ Non
📧 Email Hot Lead    💻 Script: Assigner Junior
    ↓                   ↓
💻 Créer Opportunité  ◆ Gateway: Score >= 50 ?
    ↓                 ↙ Oui      ↘ Non
📧 Notif Sales       📧 Warm      📧 Cold
    ↓                   ↓           ↓
⭕ End                ⭕ End       ⭕ End
```

**Variables Workflow** :
- `leadScore` (Integer) : Score calculé
- `isHighPriority` (Boolean) : Score >= 70
- `emailSent` (Boolean) : Email envoyé
- `opportunityId` (Long) : ID opportunité créée

### Workflow 2 : Relances Automatiques Lead

**Objectif** : Relancer leads sans réponse après délais

**Déclencheur** : Lead créé depuis >7 jours sans contact

**Processus** :

```
⭕ Start: Lead dormant
    ↓
⏰ Timer: 7 jours
    ↓
💻 Script: Vérifier statut Lead
    ↓
◆ Gateway: Toujours sans réponse ?
    ↙ Oui                ↘ Non
📧 Email Relance 1        ⭕ End
    ↓
⏰ Timer: 3 jours
    ↓
◆ Gateway: Toujours sans réponse ?
    ↙ Oui                ↘ Non
📧 Email Relance 2        ⭕ End
    ↓
⏰ Timer: 7 jours
    ↓
◆ Gateway: Toujours sans réponse ?
    ↙ Oui                ↘ Non
💻 Marquer Lead "Lost"    ⭕ End
    ↓
⭕ End
```

**Script: Vérifier Statut Lead**
```groovy
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

def lastContact = lead.lastContactDate
def daysSinceContact = lastContact ?
  ChronoUnit.DAYS.between(lastContact, LocalDateTime.now()) : 999

def hasResponse = lead.leadStatus in ['WARM', 'HOT', 'CONVERTED']

execution.setVariable('daysSinceContact', daysSinceContact)
execution.setVariable('hasResponse', hasResponse)
```

### Workflow 3 : Workflow Projet IA

**Objectif** : Orchestrer cycle de vie projet IA (POC → Production)

**Déclencheur** : Opportunité gagnée

**Processus** :

```
⭕ Start: Opportunité Won
    ↓
💻 Script: Créer Projet IA
    ↓
📋 User Task: Kickoff Meeting
    ↓
◆ Gateway: Type Projet ?
    ↙ POC         ↓ MVP        ↘ Production
💻 Setup POC    💻 Setup MVP   💻 Setup Production
    ↓               ↓               ↓
⏰ 2 semaines    ⏰ 1 mois       ⏰ 3 mois
    ↓               ↓               ↓
📋 Review POC   📋 Review MVP   📋 Review Prod
    ↓               ↓               ↓
◆ Succès ?      ◆ Succès ?      💻 Clore Projet
 ↙ Oui ↘ Non   ↙ Oui ↘ Non         ↓
MVP   Lost     Prod   Lost        📧 Feedback Client
                                    ↓
                                  ⭕ End
```

**Script: Créer Projet IA**
```groovy
import com.axelor.apps.project.db.Project
import com.axelor.apps.project.db.ProjectTask

def project = new Project()
project.name = "Projet IA - ${opportunity.partner.name}"
project.clientPartner = opportunity.partner
project.assignedTo = opportunity.user
project.fromDate = __date__
project.projectStatus = 'STARTED'

// Budget et planning selon type
def typeProjet = opportunity.attrs?.typeProjetIA ?: 'POC'
switch(typeProjet) {
  case 'POC':
    project.toDate = __date__.plusWeeks(2)
    project.budgetedAmount = opportunity.amount
    break
  case 'MVP':
    project.toDate = __date__.plusMonths(1)
    project.budgetedAmount = opportunity.amount
    break
  case 'PRODUCTION':
    project.toDate = __date__.plusMonths(3)
    project.budgetedAmount = opportunity.amount
    break
}

project.save()

// Créer tâches initiales
createTask(project, "Setup Environnement", 1, 3)
createTask(project, "Collecte Données", 2, 5)
createTask(project, "Développement Modèle", 3, 10)
createTask(project, "Tests & Validation", 4, 3)

execution.setVariable('projectId', project.id)
execution.setVariable('typeProjet', typeProjet)

def createTask(project, name, seq, duration) {
  def task = new ProjectTask()
  task.name = name
  task.project = project
  task.sequence = seq
  task.plannedDuration = duration
  task.taskStatus = 'PLANNED'
  task.save()
}
```

## 🔧 Configuration BPM

### Lier Workflow à Modèle

**Étape 1 : Créer processus dans BPM Designer**

**Étape 2 : Configurer "Process Config"**
```
Process Name:       lead_qualification_ia
Model:              com.axelor.apps.crm.db.Lead
Is Active:          ✅ Yes
Is Direct Creation: ✅ Yes (démarre à création)
Status Selection:   crm.lead.status (optionnel)
```

**Étape 3 : Définir User Tasks**
```
User Task: Vérifier Lead
  ├── Assigned To:    ${lead.user}          (assignation dynamique)
  ├── Deadline:       ${__date__.plusDays(1)}
  ├── Email Template: task_lead_verification
  └── Form View:      lead-form
```

**Étape 4 : Déployer processus**
```
BPM → Process Builder → [Votre Processus] → Deploy
Status: Deployed ✅
```

### Timer Events Configuration

```
Timer Type: Duration
Duration:   PT7D  (7 jours)
            PT3H  (3 heures)
            P1M   (1 mois)

Timer Type: Date
Date:       ${lead.expectedCloseDate.minusDays(7)}

Timer Type: Cycle
Cycle:      R3/PT1H  (3 fois toutes les heures)
            R/P1D    (tous les jours, infini)
```

### Email Tasks Configuration

```
Email Template:     lead_welcome_expert
To:                 ${lead.emailAddress}
CC:                 ${lead.user.email}
From Template:      ✅ Yes
Language:           ${lead.language ?: 'fr'}
```

## 🏆 Best Practices

### Conception Workflows

✅ **Recommandé** :
1. **Un processus = un objectif clair** (ex: qualification Lead)
2. **Nommer explicitement** : `lead_qualification_ia`, `opportunity_follow_up`
3. **Documenter** : Ajouter commentaires BPMN pour chaque tâche importante
4. **Versionner** : Incrémenter version à chaque modification majeure
5. **Tester en dev** avant déploiement production

❌ **À éviter** :
1. Workflows trop complexes (>20 tâches → découper en sous-processus)
2. Boucles infinies sans condition de sortie
3. Scripts trop longs dans Script Tasks (>50 lignes → service Java)
4. Accès direct base de données en SQL (utiliser repositories)
5. Hardcoder IDs, emails, dates (utiliser variables/config)

### Performance Scripts Groovy

⚡ **Optimisations** :
```groovy
// ✅ BON: Repository avec filtre
def leads = leadRepo.all()
  .filter("self.createdOn > ?", __date__.minusDays(7))
  .fetch(10) // Limiter résultats

// ❌ MAUVAIS: Fetch all puis filter
def leads = leadRepo.all().fetch()
  .findAll { it.createdOn > __date__.minusDays(7) }

// ✅ BON: Batch updates
leads.each { lead ->
  lead.leadStatus = 'QUALIFIED'
}
leadRepo.save(leads) // Save batch

// ❌ MAUVAIS: Save dans loop
leads.each { lead ->
  lead.leadStatus = 'QUALIFIED'
  lead.save() // N requêtes SQL
}
```

### Gestion Erreurs

```groovy
// ✅ BON: Try-catch avec logging
try {
  def opportunity = createOpportunity(lead)
  execution.setVariable('opportunityId', opportunity.id)
} catch(Exception e) {
  println "ERREUR création opportunité: ${e.message}"
  execution.setVariable('error', e.message)
  execution.setVariable('opportunityId', null)
  // Workflow peut router vers branche erreur
}

// ❌ MAUVAIS: Pas de gestion erreur
def opportunity = createOpportunity(lead) // Peut crash workflow
```

## 🔍 Monitoring & Debugging

### Consulter Instances Actives

```sql
-- Workflows en cours
SELECT
  wi.id,
  wi.name,
  wi.instance_id,
  wi.wkf_status,
  wi.created_on,
  wm.name as process_name
FROM bpm_wkf_instance wi
JOIN bpm_wkf_model wm ON wi.wkf_model = wm.id
WHERE wi.wkf_status = 'RUNNING'
ORDER BY wi.created_on DESC;

-- Tasks en attente
SELECT
  wt.id,
  wt.name,
  wt.task_id,
  wt.due_date,
  u.name as assigned_to
FROM bpm_wkf_task wt
LEFT JOIN auth_user u ON wt.assigned_to = u.id
WHERE wt.is_completed = false
ORDER BY wt.due_date;
```

### Interface BPM - Monitoring

```
BPM → Dashboard
  ├── Running Instances     (instances actives)
  ├── Completed Instances   (terminées)
  ├── Failed Instances      (erreurs)
  └── My Tasks              (mes tâches)

BPM → History
  ├── Filtrer par processus
  ├── Filtrer par statut
  └── Voir détails exécution (logs, variables)
```

### Logs Debugging

```groovy
// Dans Script Task
println "DEBUG: Lead ID=${lead.id}, Score=${score}"
println "Variables workflow: ${execution.getVariables()}"

// Logs visibles dans:
// 1. Console serveur (stdout)
// 2. BPM → History → [Instance] → Logs
// 3. Table bpm_wkf_log
```

## 🐛 Troubleshooting

### Problème 1 : Workflow ne démarre pas

**Causes** :
- ❌ Process non déployé
- ❌ Is Active = false
- ❌ Mauvais modèle configuré
- ❌ Permissions utilisateur

**Solutions** :
```sql
-- Vérifier config processus
SELECT id, name, model, is_active, is_deployed
FROM bpm_wkf_model
WHERE code = 'lead_qualification_ia';

-- Doit être: is_active=true, is_deployed=true

-- Permissions : user doit avoir rôle "BPM Manager" ou "Admin"
```

### Problème 2 : Script Task en erreur

**Causes** :
- ❌ Erreur syntaxe Groovy
- ❌ Variable null non gérée
- ❌ Import manquant
- ❌ Service non trouvé

**Solutions** :
```groovy
// ✅ Vérifier nulls
def budget = lead.attrs?.budgetIA as BigDecimal
if (budget != null) {
  // Process budget
}

// ✅ Imports complets
import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository

// ✅ Vérifier bean existe
def leadRepo = __ctx__.getBean(LeadRepository.class)
if (leadRepo == null) {
  throw new Exception("LeadRepository not found")
}

// Voir logs erreur:
// BPM → History → [Instance Failed] → Error Message
```

### Problème 3 : Email non envoyé

**Causes** :
- ❌ Template email introuvable
- ❌ Email destinataire null
- ❌ SMTP non configuré
- ❌ Queue email saturée

**Solutions** :
```sql
-- Vérifier template existe
SELECT id, name FROM message_template WHERE name = 'lead_welcome_expert';

-- Vérifier config SMTP
-- axelor-config.properties:
mail.smtp.host = smtp.gmail.com
mail.smtp.port = 587
mail.smtp.user = your_email@gmail.com
mail.smtp.pass = your_password

-- Vérifier queue emails
SELECT id, status, subject, to_email_address
FROM message_email
WHERE status = 'FAILED'
ORDER BY created_on DESC
LIMIT 10;
```

### Problème 4 : Timer ne se déclenche pas

**Causes** :
- ❌ Format durée invalide (doit être ISO-8601)
- ❌ Scheduler Axelor désactivé
- ❌ Instance workflow en pause

**Solutions** :
```
Format ISO-8601 valide:
PT1H        → 1 heure
PT30M       → 30 minutes
P1D         → 1 jour
P7D         → 7 jours
P1M         → 1 mois
R3/PT1H     → 3 fois toutes les heures

// Activer scheduler (axelor-config.properties)
quartz.enable = true

// Vérifier scheduler running
SELECT * FROM qrtz_triggers WHERE trigger_state = 'WAITING';
```

## 📚 Cas d'Usage Avancés

### Pattern 1 : Escalade Hiérarchique

```
⭕ Start: Task créée
    ↓
📋 User Task: Manager Junior (2j deadline)
    ↓
⏰ Timer Boundary: 2 jours
    ↓
◆ Gateway: Complétée ?
    ↙ Non              ↘ Oui
📧 Escalade Senior      ⭕ End
    ↓
📋 User Task: Senior (1j deadline)
    ↓
⏰ Timer: 1 jour
    ↓
◆ Gateway: Complétée ?
    ↙ Non              ↘ Oui
📧 Escalade Director    ⭕ End
```

### Pattern 2 : Approbation Multi-niveaux

```
⭕ Start: Demande approbation
    ↓
◆ Gateway: Montant ?
    ↙ <10K      ↓ 10-50K        ↘ >50K
📋 Manager    📋 Director        ✚ Parallel
    ↓             ↓           ↙      ↘
    ⭕         ⭕         📋 CFO   📋 CEO
                              ↘      ↙
                              ✚ Join
                                  ↓
                                ⭕ End
```

### Pattern 3 : Retry avec Limite

```groovy
// Script: Appel API externe avec retry
def maxRetries = 3
def retryCount = execution.getVariable('retryCount') ?: 0

try {
  def result = callExternalAPI(lead)
  execution.setVariable('apiSuccess', true)
  execution.setVariable('apiResult', result)
} catch(Exception e) {
  retryCount++
  execution.setVariable('retryCount', retryCount)
  execution.setVariable('apiSuccess', false)

  if (retryCount >= maxRetries) {
    execution.setVariable('apiMaxRetriesReached', true)
    println "Max retries atteint: ${e.message}"
  } else {
    println "Retry ${retryCount}/${maxRetries}: ${e.message}"
  }
}

// Gateway après: ${apiMaxRetriesReached == true} → Branche erreur
```

## 📚 Références

### Documentation Officielle
- **Axelor BPM** : https://docs.axelor.com/adk/7.4/modules/bpm.html
- **BPMN 2.0 Spec** : https://www.omg.org/spec/BPMN/2.0/
- **Groovy Language** : https://groovy-lang.org/documentation.html
- **GitHub axelor-studio** : https://github.com/axelor/axelor-studio (BPM inclus)

### Documentation Interne
- **Guide Low-Code** : `.claude/docs/developpeur/low-code-axelor-studio.md`
- **Doc Technique** : `.claude/docs/document-technique-axelor.md`
- **Agent Studio** : `.claude/agents/agent-studio.md` (custom fields utilisés en BPM)

### Agents Complémentaires
- **agent-studio.md** : Custom fields (utilisés dans workflows)
- **agent-configuration-crm.md** : Configuration CRM (workflows CRM)
- **agent-integrations.md** : Web services (appelés depuis BPM)

## 📝 Checklist Installation BPM

```markdown
Phase 1 : Installation
- [ ] Se connecter Axelor (admin)
- [ ] Apps → Apps Management
- [ ] BPM → Install (~20-30s)
- [ ] F5 rafraîchir
- [ ] Vérifier menu "BPM" visible

Phase 2 : Vérification Technique
- [ ] SQL: SELECT * FROM studio_app WHERE code='bpm' → active=true
- [ ] SQL: Compter tables bpm (>20 tables attendues)
- [ ] BPM → Process Builder accessible

Phase 3 : Premier Workflow
- [ ] BPM → Process Builder → New
- [ ] Nommer: test_workflow
- [ ] Ajouter Start Event → Script Task → End Event
- [ ] Script simple: println "Hello BPM"
- [ ] Save → Deploy
- [ ] Tester exécution
- [ ] Vérifier logs

Phase 4 : Intégration CRM
- [ ] Créer workflow lead_qualification
- [ ] Configurer Process Config (model=Lead)
- [ ] Ajouter Script Task scoring
- [ ] Tester sur Lead réel
- [ ] Monitorer BPM → Dashboard
```

## 📝 Historique

### 2025-10-03 - Création Agent
- Création agent expert Axelor BPM
- Documentation BPMN 2.0 complète
- Guide Groovy scripting (10+ exemples pratiques)
- 3 workflows agence IA (qualification, relances, projets)
- Configuration timers, emails, gateways
- Best practices et troubleshooting
- Checklist installation BPM

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Version Axelor** : 8.3.15 / AOP 7.4
**Status BPM** : ⚠️ Disponible (non installé) - Module axelor-studio déployé
**Dernière mise à jour** : 3 Octobre 2025
