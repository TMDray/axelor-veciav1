# Knowledge Base : Axelor BPM - Workflows & Automatisation

**Type** : Knowledge Base Technique
**Domaine** : BPM (Business Process Management) - BPMN 2.0
**Version Axelor** : 8.3.15 / AOP 7.4
**Dernière mise à jour** : 3 Octobre 2025

---

## 1. Architecture BPM Axelor

### 1.1 Principe Fondamental

Axelor BPM est un moteur de workflows **BPMN 2.0 compliant** permettant d'orchestrer des processus métier sans code Java.

### 1.2 État Installation

```sql
-- Vérifier App BPM
SELECT code, name, active, modules FROM studio_app WHERE code IN ('studio', 'bpm');

Résultat:
 code   | name   | active | modules
--------+--------+--------+---------------
 studio | Studio | t      | axelor-studio   ✅ Module déployé
 bpm    | BPM    | f/t    | axelor-studio   ⚠️ App à installer via Apps Management
```

**Installation** :
```
Apps Management → BPM → Install (~20-30s)
Effet : Crée ~20-30 tables bpm_*
```

### 1.3 Tables BPM Principales

```sql
-- Définitions processus
bpm_wkf_model                    -- Modèles workflows
bpm_wkf_task_config              -- Configuration tasks
bpm_wkf_node                     -- Nœuds processus

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

---

## 2. BPMN 2.0 - Composants

### 2.1 Events (Événements)

#### Start Event (⭕)
- **Rôle** : Démarrage workflow
- **Déclencheurs** : Création objet, modification objet, manuel, timer
- **Config** : Model, condition déclenchement

#### End Event (⭕)
- **Rôle** : Terminaison workflow
- **Types** : Normal, Error, Message

#### Timer Event (⏰)
- **Rôle** : Délai, rappel temporisé
- **Formats ISO-8601** :
  - `PT1H` : 1 heure
  - `PT30M` : 30 minutes
  - `P1D` : 1 jour
  - `P7D` : 7 jours
  - `R3/PT1H` : 3 fois toutes les heures
  - `R/P1D` : Tous les jours (infini)

#### Message Event
- **Rôle** : Envoi/réception messages

#### Error Event
- **Rôle** : Gestion erreurs, rollback

### 2.2 Activities (Activités)

#### User Task (📋)
- **Rôle** : Tâche humaine (validation, saisie, approbation)
- **Config** :
  - Assigned to : `${lead.user}` (dynamique)
  - Deadline : `${__date__.plusDays(1)}`
  - Form : lead-form
  - Email template : notification task

#### Script Task (💻)
- **Rôle** : Exécution script Groovy
- **Accès** : Modèles Axelor, services, contexte
- **Exemple** : Calcul scoring, transformation données

#### Service Task (⚙️)
- **Rôle** : Appel service Java
- **Usage** : Logique complexe, intégrations

#### Mail Task (📧)
- **Rôle** : Envoi email
- **Config** :
  - Email template
  - To : `${lead.emailAddress}`
  - Language : `${lead.language ?: 'fr'}`

### 2.3 Gateways (Routage)

#### Exclusive Gateway (◆)
- **Rôle** : Choix exclusif (if/else)
- **Conditions** : Expression sur 1 seule branche
- **Exemple** :
  ```
  ◆ Gateway: Score >= 70 ?
      ↙ true       ↘ false
  Branch A      Branch B
  ```

#### Parallel Gateway (✚)
- **Rôle** : Exécution parallèle
- **Usage** : Multi-branches simultanées
- **Join** : Attend toutes branches avant continuer

#### Inclusive Gateway
- **Rôle** : Plusieurs branches conditionnelles (non-exclusives)

### 2.4 Sub-Processes

#### Sub-Process
- **Rôle** : Workflow imbriqué
- **Réutilisabilité** : Appel depuis plusieurs workflows

#### Call Activity
- **Rôle** : Appel workflow externe

---

## 3. Groovy Scripting - Référence Complète

### 3.1 Contexte Disponible

```groovy
// Contexte BPM
execution                        // ExecutionContext
execution.getVariable('varName') // Récupérer variable workflow
execution.setVariable('varName', value) // Définir variable

// Contexte Axelor
__ctx__                          // AuthUser context
__user__                         // User courant
__date__                         // LocalDate.now()
__datetime__                     // LocalDateTime.now()

// Modèle injecté automatiquement (si workflow lié)
lead                             // Lead instance (si model=Lead)
opportunity                      // Opportunity instance (si model=Opportunity)
// Variable = nom modèle en minuscule
```

### 3.2 Accès Repositories

```groovy
import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository

// Récupérer repository via context
def leadRepo = __ctx__.getBean(LeadRepository.class)

// Find by ID
def lead = leadRepo.find(123L)

// JPQL Query
def leads = leadRepo.all()
  .filter("self.emailAddress.address LIKE ?", "%@gmail.com")
  .filter("self.leadScoringSelect >= ?", 70)
  .order("-leadScoringSelect")
  .fetch(10)

// Count
def count = leadRepo.all()
  .filter("self.isConverted = false")
  .count()
```

### 3.3 Manipulation Modèles

```groovy
// Créer
def lead = new Lead()
lead.name = "Nouveau Lead"
lead.emailAddress = new EmailAddress()
lead.emailAddress.address = "test@example.com"
lead.save()

// Modifier
lead.leadScoringSelect = 85
lead.leadStatus = LeadStatus.findByName('Qualified')
lead.save()

// Supprimer
leadRepo.remove(lead)
```

### 3.4 Accès Custom Fields JSON

```groovy
// Lire custom field
def maturite = lead.attrs?.niveauMaturiteIA
def budget = lead.attrs?.budgetIA as BigDecimal

// Null-safe
def stack = lead.attrs?.stackTechnique ?: "Non renseigné"

// Modifier custom field
if (lead.attrs == null) {
  lead.attrs = [:]
}
lead.attrs.niveauMaturiteIA = 'avance'
lead.attrs.budgetIA = 50000.00
lead.save()

// Map complète
lead.attrs = [
  niveauMaturiteIA: 'expert',
  budgetIA: 100000,
  secteurIA: 'computer_vision'
]
lead.save()
```

### 3.5 Exemples Scripts Courants

#### Calcul Scoring

```groovy
// Script Task: Calculer Score Lead IA
def score = 0

// Score Maturité IA (0-40 pts)
def maturite = lead.attrs?.niveauMaturiteIA
if (maturite == 'expert') score += 40
else if (maturite == 'avance') score += 30
else if (maturite == 'intermediaire') score += 20
else if (maturite == 'debutant') score += 10

// Score Budget (0-30 pts)
def budget = lead.attrs?.budgetIA as BigDecimal
if (budget != null) {
  if (budget >= 50000) score += 30
  else if (budget >= 10000) score += 15
  else score += 5
}

// Score Urgence (0-20 pts)
def urgence = lead.attrs?.urgenceProjet
if (urgence == 'haute') score += 20
else if (urgence == 'moyenne') score += 10
else score += 5

// Équipe Data (+10 pts)
if (lead.attrs?.equipeData == true) score += 10

// Mise à jour Lead
lead.leadScoringSelect = score
lead.save()

// Variables workflow pour conditions downstream
execution.setVariable('leadScore', score)
execution.setVariable('isHotLead', score >= 70)
execution.setVariable('isWarmLead', score >= 50 && score < 70)

println "Lead ${lead.name} - Score: ${score}"
```

#### Création Opportunité

```groovy
// Script Task: Créer Opportunity depuis Lead qualifié
import com.axelor.apps.crm.db.Opportunity
import com.axelor.apps.crm.db.OpportunityStatus

def score = execution.getVariable('leadScore') as Integer

if (score >= 70) {
  def opportunity = new Opportunity()
  opportunity.name = "OPP - ${lead.enterpriseName ?: lead.name}"
  opportunity.partner = lead.partner
  opportunity.user = lead.user
  opportunity.expectedCloseDate = __date__.plusMonths(3)

  // Copier custom fields
  opportunity.attrs = [
    niveauMaturiteIA: lead.attrs?.niveauMaturiteIA,
    budgetIA: lead.attrs?.budgetIA,
    secteurIA: lead.attrs?.secteurIA,
    stackTechnique: lead.attrs?.stackTechnique
  ]

  // Montant selon budget
  def budget = lead.attrs?.budgetIA as BigDecimal
  if (budget != null) {
    opportunity.amount = budget
    opportunity.bestCase = budget * 1.2
    opportunity.worstCase = budget * 0.7
  }

  // Statut et probabilité
  opportunity.opportunityStatus = OpportunityStatus.findByName('Nouveau')
  opportunity.probability = 50

  opportunity.save()

  // Lier Lead
  lead.isConverted = true
  lead.linkedOpportunity = opportunity
  lead.save()

  execution.setVariable('opportunityId', opportunity.id)
  println "Opportunité créée: ${opportunity.name} (${opportunity.amount}€)"
}
```

#### Vérification Dernier Contact

```groovy
// Script Task: Vérifier leads inactifs
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

def lastContact = lead.lastEventDateT
def daysSinceContact = lastContact ?
  ChronoUnit.DAYS.between(lastContact, LocalDateTime.now()) : 999

def hasResponse = lead.leadStatus?.name in ['Qualification commerciale', 'Converti']

// Variables pour gateway downstream
execution.setVariable('daysSinceContact', daysSinceContact)
execution.setVariable('hasResponse', hasResponse)
execution.setVariable('needsFollowUp', daysSinceContact > 7 && !hasResponse)

println "Lead ${lead.name}: ${daysSinceContact} jours sans contact, hasResponse=${hasResponse}"
```

#### Notification Slack (Webhook)

```groovy
// Script Task: Notifier Slack
def slackWebhookUrl = 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'

def payload = [
  channel: '#crm-hot-leads',
  username: 'Axelor Bot',
  icon_emoji: ':fire:',
  text: "🔥 *HOT LEAD - Score ${lead.leadScoringSelect}*",
  attachments: [
    [
      color: '#ff0000',
      fields: [
        [title: 'Lead', value: lead.name, short: true],
        [title: 'Score', value: "${lead.leadScoringSelect}/100", short: true],
        [title: 'Maturité IA', value: lead.attrs?.niveauMaturiteIA ?: 'N/A', short: true],
        [title: 'Budget', value: "${lead.attrs?.budgetIA ?: 0}€", short: true],
        [title: 'Email', value: lead.emailAddress?.address ?: 'N/A', short: false]
      ]
    ]
  ]
]

def connection = new URL(slackWebhookUrl).openConnection()
connection.setRequestMethod('POST')
connection.setDoOutput(true)
connection.setRequestProperty('Content-Type', 'application/json')

def writer = new OutputStreamWriter(connection.getOutputStream())
writer.write(groovy.json.JsonOutput.toJson(payload))
writer.flush()

def responseCode = connection.getResponseCode()
execution.setVariable('slackNotified', responseCode == 200)

println "Slack notification sent: ${responseCode}"
```

### 3.6 Gestion Erreurs

```groovy
// Pattern Try-Catch
try {
  def opportunity = createOpportunity(lead)
  execution.setVariable('opportunityId', opportunity.id)
  execution.setVariable('success', true)
} catch(Exception e) {
  println "ERREUR création opportunité: ${e.message}"
  execution.setVariable('error', e.message)
  execution.setVariable('success', false)

  // Notification admin si erreur
  sendAdminAlert("Workflow error pour Lead ${lead.id}: ${e.message}")
}
```

### 3.7 Retry avec Exponential Backoff

```groovy
// Pattern Retry (API call avec retry)
def maxRetries = 3
def retryCount = execution.getVariable('retryCount') ?: 0
def success = false

while (!success && retryCount < maxRetries) {
  try {
    def result = callExternalAPI(lead)
    success = true
    execution.setVariable('apiResult', result)
  } catch (Exception e) {
    retryCount++
    def waitTime = Math.pow(2, retryCount) * 1000  // 2s, 4s, 8s

    println "API Error (retry ${retryCount}/${maxRetries}): ${e.message}"

    if (retryCount < maxRetries) {
      Thread.sleep(waitTime as Long)
    } else {
      execution.setVariable('apiError', e.message)
      execution.setVariable('apiFailed', true)
    }
  }
}

execution.setVariable('retryCount', retryCount)
```

---

## 4. Configuration Workflows

### 4.1 Créer Workflow

```
BPM → Process Builder → New

Name:            lead_qualification_ia
Description:     Workflow qualification automatique Lead IA
Version:         1.0
```

### 4.2 Lier à Modèle

```
Process Config:
├── Model:              com.axelor.apps.crm.db.Lead
├── Is Active:          ✅ Yes
├── Is Direct Creation: ✅ Yes (démarre automatiquement à création)
└── Status Selection:   crm.lead.status (optionnel)
```

### 4.3 Configurer User Tasks

```
User Task: Valider Lead
├── Assigned To:    ${lead.user}              (expression dynamique)
├── Deadline:       ${__date__.plusDays(2)}   (2 jours)
├── Form View:      lead-form
├── Email Template: task_lead_validation
└── Priority:       High
```

### 4.4 Configurer Timers

```
Timer Event:
├── Type:     Duration
├── Duration: PT7D     (7 jours)
└── Action:   Relance email après 7j sans réponse
```

**Formats ISO-8601** :
```
PT1H        = 1 heure
PT30M       = 30 minutes
P1D         = 1 jour
P7D         = 7 jours
P1M         = 1 mois
R3/PT1H     = 3 fois toutes les heures
R/P1D       = Tous les jours (infini)
```

### 4.5 Conditions Gateway

```javascript
// Exclusive Gateway: Routage selon score

// Condition branche "Hot Lead"
${leadScore >= 70}

// Condition branche "Warm Lead"
${leadScore >= 50 && leadScore < 70}

// Condition branche "Cold Lead"
${leadScore < 50}

// Condition complexe
${(leadScore >= 70 || budgetIA >= 100000) && urgenceProjet == 'haute'}

// Null-safe
${lead.attrs.niveauMaturiteIA != null && lead.attrs.niveauMaturiteIA == 'expert'}
```

### 4.6 Déploiement

```
BPM → Process Builder → [Votre Processus]
Action: Deploy
Status: Deployed ✅

Vérification SQL:
SELECT id, name, is_deployed, is_active
FROM bpm_wkf_model
WHERE code = 'lead_qualification_ia';
```

---

## 5. Patterns Workflows Courants

### 5.1 Pattern : Sequential

```
⭕ Start
    ↓
📋 Task A
    ↓
📋 Task B
    ↓
📋 Task C
    ↓
⭕ End
```

### 5.2 Pattern : Conditional Routing

```
⭕ Start
    ↓
💻 Script: Calculer
    ↓
◆ Gateway: Condition ?
    ↙ true        ↘ false
📋 Task A      📋 Task B
    ↘            ↙
    ◆ Join
        ↓
    ⭕ End
```

### 5.3 Pattern : Parallel Execution

```
⭕ Start
    ↓
✚ Parallel Split
    ↙       ↓       ↘
📋 Task A  📋 Task B  📋 Task C
    ↘       ↓       ↙
    ✚ Parallel Join
        ↓
    ⭕ End
```

### 5.4 Pattern : Escalation (Timer Boundary)

```
⭕ Start
    ↓
📋 User Task (2j deadline)
    ↓ (timer boundary 2j)
    ⏰ ──→ 📧 Escalade Manager
    ↓
⭕ End
```

### 5.5 Pattern : Retry Loop

```
⭕ Start
    ↓
💻 Script: Try API
    ↓
◆ Gateway: Success ?
    ↙ false (retry < 3)    ↘ true
💻 Increment retry       ⭕ End Success
    ↓
◆ Retry < 3 ?
    ↙ true  ↘ false
   Loop     ⭕ End Failure
```

---

## 6. Monitoring & Debugging

### 6.1 SQL Queries Monitoring

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

-- Workflows failed
SELECT
  wi.id,
  wi.name,
  wi.wkf_status,
  wi.error_message
FROM bpm_wkf_instance wi
WHERE wi.wkf_status = 'FAILED'
ORDER BY wi.created_on DESC
LIMIT 10;
```

### 6.2 Logs Debugging

```groovy
// Dans Script Task
println "DEBUG: Lead ID=${lead.id}, Score=${score}"
println "Variables workflow: ${execution.getVariables()}"
println "Context user: ${__user__.name}"

// Logs visibles dans:
// 1. Console serveur (stdout)
// 2. BPM → History → [Instance] → Logs
// 3. Table bpm_wkf_log
```

### 6.3 Interface BPM - Dashboard

```
BPM → Dashboard
├── Running Instances     (instances actives)
├── Completed Instances   (terminées)
├── Failed Instances      (erreurs)
└── My Tasks              (mes tâches)

BPM → History
├── Filtrer par processus
├── Filtrer par statut
└── Voir détails (logs, variables, timeline)
```

---

## 7. Best Practices Techniques

### 7.1 Design Workflows

**✅ Recommandé** :
- Un processus = un objectif clair
- Nommer explicitement : `lead_qualification_ia`, `opportunity_follow_up`
- Versionner workflows (1.0, 1.1, 2.0...)
- Documenter (commentaires BPMN, description)
- Workflows < 20 tâches (sinon sub-processes)

**❌ À éviter** :
- Workflows too complexes (>20 tâches)
- Boucles infinies sans condition sortie
- Hardcode IDs, emails, dates
- Scripts >50 lignes (→ service Java)

### 7.2 Performance Scripts

```groovy
// ✅ BON: Filter en SQL
def leads = leadRepo.all()
  .filter("self.createdOn > ?", __date__.minusDays(7))
  .fetch(10)

// ❌ MAUVAIS: Fetch all puis filter Groovy
def leads = leadRepo.all().fetch()
  .findAll { it.createdOn > __date__.minusDays(7) }

// ✅ BON: Batch save
leads.each { it.status = 'QUALIFIED' }
leadRepo.save(leads)

// ❌ MAUVAIS: Save dans loop
leads.each { lead ->
  lead.status = 'QUALIFIED'
  lead.save()  // N requêtes SQL
}
```

### 7.3 Gestion Erreurs

```groovy
// ✅ BON: Try-catch avec logging
try {
  def result = callAPI(lead)
  execution.setVariable('apiResult', result)
} catch(Exception e) {
  println "ERROR: ${e.message}"
  execution.setVariable('error', e.message)
  // Gateway peut router vers branche erreur
}

// ❌ MAUVAIS: Pas de gestion
def result = callAPI(lead)  // Peut crash workflow
```

### 7.4 Variables Workflow

**Nommage** :
```groovy
// ✅ BON: Noms explicites
execution.setVariable('leadScore', 85)
execution.setVariable('isHotLead', true)
execution.setVariable('opportunityId', 123L)

// ❌ MAUVAIS: Noms cryptiques
execution.setVariable('v1', 85)
execution.setVariable('flag', true)
```

**Types supportés** :
- Primitives : Integer, Long, String, Boolean, BigDecimal
- Date/Time : LocalDate, LocalDateTime
- Collections : List, Map (sérialisables)
- Objets métier : Lead, Opportunity (via ID)

---

## 8. Troubleshooting

### 8.1 Workflow ne démarre pas

**Causes** :
- ❌ Process non déployé (is_deployed=false)
- ❌ Is Active = false
- ❌ Mauvais modèle configuré
- ❌ Permissions user

**Solutions** :
```sql
-- Vérifier config
SELECT id, name, model, is_active, is_deployed
FROM bpm_wkf_model
WHERE code = 'lead_qualification_ia';

-- Doit être: is_active=true, is_deployed=true
```

### 8.2 Script Task en erreur

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
  // Process
}

// ✅ Imports
import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository

// Voir logs erreur:
// BPM → History → [Instance Failed] → Error Message
```

### 8.3 Timer ne se déclenche pas

**Causes** :
- ❌ Format durée invalide (doit être ISO-8601)
- ❌ Scheduler Axelor désactivé
- ❌ Instance workflow en pause

**Solutions** :
```
Format ISO-8601 valide:
PT1H, PT30M, P1D, P7D, R3/PT1H

// Config scheduler (axelor-config.properties)
quartz.enable = true

// Vérifier scheduler
SELECT * FROM qrtz_triggers WHERE trigger_state = 'WAITING';
```

---

## 9. Références Techniques

### Documentation Officielle
- **Axelor BPM** : https://docs.axelor.com/adk/7.4/modules/bpm.html
- **BPMN 2.0 Spec** : https://www.omg.org/spec/BPMN/2.0/
- **Groovy Language** : https://groovy-lang.org/documentation.html

### GitHub
- **Axelor Studio** : https://github.com/axelor/axelor-studio (BPM inclus)

### Spécifications
- **ISO-8601 Duration** : https://en.wikipedia.org/wiki/ISO_8601#Durations

---

**Knowledge Base maintenue par** : Équipe Dev Axelor Vecia
**Version** : 1.0
**Dernière mise à jour** : 3 Octobre 2025
