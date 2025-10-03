# 🔌 Agent Integrations - Expert Axelor Connect & APIs

## 📋 Mission

Agent spécialisé dans les **intégrations externes** Axelor : Axelor Connect (1500+ connecteurs), Web Services Studio, API REST, Webhooks et synchronisations. Expert dans la connexion d'Axelor avec outils tiers (emails, calendriers, CRM externes, outils IA, etc.).

**Rôle** : Assistant expert qui guide l'utilisateur dans la configuration des intégrations (interface web + configuration fichiers).

## 🎯 Domaines d'Expertise

### 1. Axelor Connect
- 1500+ connecteurs préconfigurés (Gmail, Outlook, Slack, etc.)
- Interface No-code pour workflows d'intégration
- Mapping données automatique
- Synchronisation bidirectionnelle

### 2. Web Services (Studio)
- Configuration Web Services via Axelor Studio
- Authentification (Basic, OAuth2, API Key, Token)
- Requêtes HTTP (GET, POST, PUT, DELETE)
- Transformation réponses (JSON, XML)
- Appel depuis BPM workflows

### 3. API REST Axelor
- Endpoints REST standards (/ws/rest, /ws/action)
- Authentification JWT/Session
- CRUD opérations sur tous modèles
- Actions métier
- Advanced Search (criteria)

### 4. Webhooks & Events
- Configuration webhooks entrants
- Déclenchement événements Axelor
- Webhooks sortants (notifications)
- Intégration temps réel

## 🌐 Axelor Connect - Overview

### Qu'est-ce qu'Axelor Connect ?

**Axelor Connect** est la plateforme d'intégration No-code d'Axelor permettant de connecter Axelor avec **1500+ applications** tierces sans écrire de code.

**Fonctionnement** :
```
Application Externe (Gmail, Slack, etc.)
            ↓
    Axelor Connect (Cloud)
            ↓
   Triggers & Actions
            ↓
  Transformation Données
            ↓
   Axelor ERP (On-premise)
```

### Connecteurs Disponibles

**Catégories principales** :

| Catégorie | Exemples | Cas d'Usage Agence IA |
|-----------|----------|----------------------|
| **Email** | Gmail, Outlook, SendGrid | Sync emails leads, notifications projets |
| **Calendrier** | Google Calendar, Outlook Calendar | Sync RDV clients, planning équipe |
| **Communication** | Slack, Microsoft Teams, Discord | Notifications temps réel, alertes projets |
| **Stockage** | Google Drive, Dropbox, OneDrive | Documents projets IA, datasets |
| **CRM** | Salesforce, HubSpot, Pipedrive | Migration données, sync contacts |
| **Productivité** | Trello, Asana, Jira | Gestion tâches projets IA |
| **Paiement** | Stripe, PayPal | Facturation services IA |
| **IA & ML** | OpenAI, Hugging Face, AWS SageMaker | Enrichissement données, prédictions |
| **Analytics** | Google Analytics, Mixpanel | Tracking performance, dashboards |

### Configuration Axelor Connect

**Étape 1 : Activer Axelor Connect**

```properties
# axelor-config.properties
utils.api.enable = true
studio.apps.install = all

# Connecteur Axelor Connect (URL cloud Axelor)
axelor.connect.url = https://connect.axelor.com
axelor.connect.api.key = YOUR_API_KEY  # Obtenir depuis console Axelor
```

**Étape 2 : Créer Connexion (Interface Web)**

```
Administration → Integrations → Axelor Connect
  ↓
New Connection
  ├── Name:        Gmail Sync Leads
  ├── Connector:   Gmail
  ├── Auth:        OAuth2 (auto-config)
  └── Test:        Test Connection ✅
```

**Étape 3 : Créer Workflow d'Intégration**

```
Trigger: Nouveau email reçu (Gmail)
   ↓
Filter: Email contient "demande de renseignement"
   ↓
Action: Créer Lead dans Axelor
   ↓
Mapping:
   - email.subject       → lead.name
   - email.from          → lead.emailAddress
   - email.body          → lead.description
   - email.from_name     → lead.firstName + lastName
   ↓
Action: Envoyer notification Slack
   ↓
End
```

## 🛠️ Web Services Studio

### Architecture Web Services

```
┌────────────────────────────────────────────┐
│  Axelor Studio - Web Service Config        │
├────────────────────────────────────────────┤
│                                            │
│  1. Authentication                         │
│     ├── Type: OAuth2 / API Key / Basic    │
│     ├── Token Endpoint                     │
│     └── Headers                            │
│                                            │
│  2. Request                                │
│     ├── Method: GET / POST / PUT          │
│     ├── URL: https://api.example.com      │
│     ├── Headers                            │
│     └── Body (JSON/XML)                    │
│                                            │
│  3. Response                               │
│     ├── Parser: JSON / XML                │
│     ├── Mapping Fields                     │
│     └── Error Handling                     │
│                                            │
│  4. Integration                            │
│     ├── BPM Workflows (Service Task)       │
│     ├── Buttons Actions                    │
│     └── Scheduled Jobs                     │
│                                            │
└────────────────────────────────────────────┘
```

### Procédure : Créer Web Service

**Exemple : Enrichir Lead avec API externe**

**Étape 1 : Créer Web Service (Studio)**

```
Administration → Studio → Web Services → New

Name:            enrichLeadWithAI
Description:     Enrichir Lead avec scoring IA externe
Method:          POST
URL:             https://api.ai-scoring.com/v1/score
```

**Étape 2 : Configuration Authentication**

```
Auth Type:       Bearer Token
Header Name:     Authorization
Header Value:    Bearer ${apiToken}  # Variable config

# Ou OAuth2
Auth Type:       OAuth2
Token Endpoint:  https://api.ai-scoring.com/oauth/token
Client ID:       ${oauthClientId}
Client Secret:   ${oauthClientSecret}
```

**Étape 3 : Configuration Request**

```
Headers:
  Content-Type: application/json
  Accept: application/json

Body (JSON):
{
  "email": "${lead.emailAddress}",
  "company": "${lead.enterpriseName}",
  "industry": "${lead.industry.name}",
  "website": "${lead.webSite}"
}

# Variables disponibles: Tous champs du contexte (lead, opportunity, etc.)
```

**Étape 4 : Configuration Response**

```
Response Type:   JSON
Parser:          JSONPath

Mapping:
  $.score              → lead.attrs.aiScore          (Integer)
  $.confidence         → lead.attrs.aiConfidence     (Decimal)
  $.industry_match     → lead.attrs.industryMatch    (Boolean)
  $.recommended_services → lead.attrs.recommendedServices (Text)

Error Handling:
  On Error: Log error and continue
  Error Variable: ${wsError}
```

**Étape 5 : Utilisation**

**A. Depuis BPM Workflow** :

```groovy
// Service Task dans workflow
import com.axelor.studio.db.WsRequest
import com.axelor.studio.service.StudioWsService

def wsService = __ctx__.getBean(StudioWsService.class)
def wsRequest = WsRequest.findByName('enrichLeadWithAI')

def response = wsService.callWs(wsRequest, lead)

if (response.statusCode == 200) {
  println "Lead enrichi avec score AI: ${lead.attrs.aiScore}"
  execution.setVariable('enrichmentSuccess', true)
} else {
  println "Erreur enrichissement: ${response.error}"
  execution.setVariable('enrichmentSuccess', false)
}
```

**B. Depuis Button Action (Custom)** :

```
Button: "Enrichir avec IA"
  ↓
Action Type: Script
  ↓
Groovy Script:
  import com.axelor.studio.service.StudioWsService
  def wsService = __ctx__.getBean(StudioWsService.class)
  def ws = WsRequest.findByName('enrichLeadWithAI')
  wsService.callWs(ws, lead)
  lead.refresh()
```

**C. Depuis Scheduled Job** :

```
Cron: 0 2 * * *  (tous les jours à 2h)
Script:
  def leads = Lead.all()
    .filter("self.attrs.aiScore IS NULL")
    .fetch()

  leads.each { lead ->
    wsService.callWs(enrichLeadWs, lead)
  }
```

## 🔑 API REST Axelor

### Architecture API REST

**Base URL** : `http://localhost:8080/ws`

**Endpoints principaux** :
```
/ws/rest/:model          # CRUD sur modèles
/ws/action/:action       # Actions métier
/ws/meta/fields          # Métadonnées champs
/ws/meta/models          # Métadonnées modèles
/ws/search/:model        # Recherche avancée
```

### Authentification

**1. Session-based (Cookie)**

```bash
# Login
curl -X POST http://localhost:8080/login.jsp \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin&password=admin" \
  -c cookies.txt

# Utiliser session
curl http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -b cookies.txt
```

**2. Basic Auth**

```bash
curl -X GET http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -u admin:admin \
  -H "Accept: application/json"
```

**3. API Key (Custom)**

```properties
# axelor-config.properties
auth.api.key.enabled = true
auth.api.key.header = X-API-Key
```

```bash
curl http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -H "X-API-Key: YOUR_API_KEY"
```

### CRUD Operations

**Create Lead** :

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "firstName": "John",
      "name": "Doe Corp",
      "emailAddress": "john@doecorp.com",
      "mobilePhone": "+33612345678",
      "attrs": {
        "niveauMaturiteIA": "intermediaire",
        "budgetIA": 50000,
        "secteurIA": "computer_vision"
      }
    }
  }'
```

**Read Lead** :

```bash
# Par ID
curl http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead/123 \
  -u admin:admin

# Tous (paginated)
curl http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -u admin:admin \
  -G -d "offset=0" -d "limit=10"

# Avec fields spécifiques
curl http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -u admin:admin \
  -G -d "fields=id,name,emailAddress,attrs"
```

**Update Lead** :

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead/123 \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "id": 123,
      "version": 1,
      "leadStatus": "QUALIFIED",
      "leadScoringSelect": 85
    }
  }'
```

**Delete Lead** :

```bash
curl -X DELETE http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead/123 \
  -u admin:admin
```

### Advanced Search

**Recherche avec critères** :

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead/search \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "offset": 0,
    "limit": 20,
    "sortBy": ["name"],
    "data": {
      "_domain": "self.emailAddress LIKE :email AND self.leadScoringSelect >= :score",
      "_domainContext": {
        "email": "%@gmail.com",
        "score": 70
      }
    },
    "fields": ["id", "name", "emailAddress", "leadScoringSelect", "attrs"]
  }'
```

**Recherche custom fields JSON** :

```bash
# Leads avec maturité IA = "avance"
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead/search \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "_domain": "self.attrs.niveauMaturiteIA = :maturite",
      "_domainContext": {
        "maturite": "avance"
      }
    }
  }'
```

### Actions Métier

**Appeler action Axelor** :

```bash
curl -X POST http://localhost:8080/ws/action/action-lead-method-convert-to-opportunity \
  -u admin:admin \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "context": {
        "id": 123,
        "_model": "com.axelor.apps.crm.db.Lead"
      }
    }
  }'
```

## 🎯 Cas Pratiques - Agence IA

### Cas 1 : Sync Emails → Leads (Gmail + Axelor)

**Objectif** : Créer Lead automatiquement depuis emails Gmail

**Solution 1 : Axelor Connect**

```
Trigger: Nouveau email Gmail
Filter:  Label = "Demande Projet IA"
   ↓
Extract:
  - Subject → leadName
  - From Email → leadEmail
  - From Name → firstName, name
  - Body → description
   ↓
Action: POST API REST Axelor (Create Lead)
   ↓
Action: Ajouter label Gmail "Traité Axelor"
```

**Solution 2 : Gmail API + Scheduled Job**

```groovy
// Scheduled Job (toutes les 15 min)
import com.google.api.services.gmail.Gmail
import com.axelor.apps.crm.db.Lead

def gmailService = getGmailService()  // OAuth2 config
def messages = gmailService.users().messages()
  .list('me')
  .setQ('label:Demande-Projet-IA is:unread')
  .execute()

messages.getMessages().each { msg ->
  def fullMsg = gmailService.users().messages()
    .get('me', msg.getId()).execute()

  def lead = new Lead()
  lead.name = extractSubject(fullMsg)
  lead.emailAddress = extractFrom(fullMsg)
  lead.description = extractBody(fullMsg)
  lead.attrs = [
    source: 'Gmail',
    emailId: msg.getId()
  ]
  lead.save()

  // Marquer comme lu
  gmailService.users().messages()
    .modify('me', msg.getId(), ['removeLabelIds': ['UNREAD']])
    .execute()
}
```

### Cas 2 : Enrichissement Lead avec OpenAI

**Objectif** : Analyser description Lead avec GPT pour extraire infos IA

**Web Service Studio** :

```
Name:   analyzeLeadWithGPT
Method: POST
URL:    https://api.openai.com/v1/chat/completions

Auth:   Bearer Token
Token:  sk-...  (variable config)

Body:
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Tu es un expert qui analyse les besoins clients en IA. Extrait: niveau_maturite (debutant/intermediaire/avance/expert), secteur_ia (cv/nlp/ml/dl), budget_estime."
    },
    {
      "role": "user",
      "content": "${lead.description}"
    }
  ],
  "temperature": 0.3
}

Response Mapping:
$.choices[0].message.content → lead.attrs.gptAnalysis (JSON parse)

Script Post-Processing:
import groovy.json.JsonSlurper

def analysis = new JsonSlurper().parseText(lead.attrs.gptAnalysis)
lead.attrs.niveauMaturiteIA = analysis.niveau_maturite
lead.attrs.secteurIA = analysis.secteur_ia
lead.attrs.budgetIA = analysis.budget_estime
lead.save()
```

### Cas 3 : Webhook Slack → Notification Projets

**Objectif** : Envoyer notification Slack quand projet IA démarre

**Configuration Webhook Slack** :

```groovy
// BPM Workflow: Start Projet IA
// Script Task: Notify Slack

def slackWebhookUrl = 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'

def payload = [
  channel: '#projets-ia',
  username: 'Axelor Bot',
  icon_emoji: ':robot_face:',
  text: "🚀 *Nouveau Projet IA démarré*",
  attachments: [
    [
      color: '#36a64f',
      fields: [
        [title: 'Projet', value: project.name, short: true],
        [title: 'Client', value: project.clientPartner.name, short: true],
        [title: 'Type', value: project.attrs.typeProjetIA, short: true],
        [title: 'Budget', value: "${project.budgetedAmount}€", short: true],
        [title: 'Chef de Projet', value: project.assignedTo.name, short: false],
        [title: 'Deadline', value: project.toDate.toString(), short: false]
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

def response = connection.getResponseCode()
println "Slack notification sent: ${response}"
```

### Cas 4 : Sync Calendrier Google

**Objectif** : Synchroniser RDV clients Axelor ↔ Google Calendar

**Axelor Connect Workflow** :

```
Trigger A: Event créé dans Axelor
   ↓
Action: POST Google Calendar API
   ↓
Store: calendar_event_id dans Axelor Event

---

Trigger B: Event modifié dans Google Calendar
   ↓
Action: PATCH Axelor Event API
   ↓
Update: Axelor Event correspondant

---

Trigger C: Event supprimé Google Calendar
   ↓
Action: DELETE Axelor Event API
```

**Script Groovy Sync** :

```groovy
import com.google.api.services.calendar.Calendar
import com.axelor.apps.crm.db.Event

def calendarService = getGoogleCalendarService()

// Sync Axelor → Google
def event = new com.google.api.services.calendar.model.Event()
  .setSummary(axelorEvent.subject)
  .setDescription(axelorEvent.description)
  .setStart(new EventDateTime().setDateTime(axelorEvent.startDateTime))
  .setEnd(new EventDateTime().setDateTime(axelorEvent.endDateTime))
  .setAttendees([
    new EventAttendee().setEmail(axelorEvent.partner.emailAddress)
  ])

def createdEvent = calendarService.events()
  .insert('primary', event)
  .execute()

// Stocker ID Google dans Axelor
axelorEvent.attrs.googleCalendarId = createdEvent.getId()
axelorEvent.save()
```

### Cas 5 : Webhook GitHub → Mise à jour Projet

**Objectif** : Mettre à jour projet Axelor depuis commits GitHub

**Webhook GitHub** :

```
GitHub Repo → Settings → Webhooks → Add webhook

Payload URL: https://your-axelor.com/ws/webhook/github
Content type: application/json
Events: Push events, Pull request
```

**Endpoint Axelor (Custom Controller)** :

```java
// AxelorGitHubWebhookController.java
@RestController
@RequestMapping("/ws/webhook")
public class GitHubWebhookController {

  @PostMapping("/github")
  public ResponseEntity<String> handleGitHubWebhook(@RequestBody Map<String, Object> payload) {
    String event = payload.get("event");
    String repo = payload.get("repository.name");
    String commit = payload.get("head_commit.message");

    // Trouver projet Axelor correspondant
    Project project = Projects.all()
      .filter("self.attrs.githubRepo = ?", repo)
      .fetchOne();

    if (project != null) {
      // Ajouter log/commentaire
      String log = String.format("[GitHub] %s - %s", event, commit);
      addProjectLog(project, log);

      // Notifier équipe
      notifyTeam(project, log);
    }

    return ResponseEntity.ok("Webhook processed");
  }
}
```

## 🏆 Best Practices

### Sécurité Intégrations

✅ **Recommandations** :

1. **Secrets Management**
   ```properties
   # axelor-config.properties (PAS de commit!)
   api.openai.key = ${OPENAI_API_KEY}  # Env var
   api.slack.webhook = ${SLACK_WEBHOOK}

   # Docker secrets
   docker secret create openai_key openai_key.txt
   ```

2. **Authentification Forte**
   - OAuth2 > API Key > Basic Auth
   - Tokens avec expiration
   - Refresh tokens
   - HTTPS obligatoire

3. **Rate Limiting**
   ```groovy
   // Limiter appels API
   def lastCall = execution.getVariable('lastApiCall')
   def now = System.currentTimeMillis()

   if (lastCall && (now - lastCall) < 1000) {
     Thread.sleep(1000 - (now - lastCall))  // Wait
   }

   callExternalAPI()
   execution.setVariable('lastApiCall', System.currentTimeMillis())
   ```

4. **Validation Input**
   ```groovy
   // Valider avant API call
   if (!lead.emailAddress?.matches(/^[\w.-]+@[\w.-]+\.\w+$/)) {
     throw new Exception("Email invalide: ${lead.emailAddress}")
   }
   ```

### Performance

⚡ **Optimisations** :

1. **Batch Processing**
   ```groovy
   // ✅ BON: Batch API calls
   def leads = Lead.all().filter(...).fetch()
   def leadsBatch = leads.collate(50)  // Groupes de 50

   leadsBatch.each { batch ->
     callBatchAPI(batch)  // 1 call pour 50 leads
   }

   // ❌ MAUVAIS: Call par lead
   leads.each { lead ->
     callAPI(lead)  // N calls
   }
   ```

2. **Async Processing**
   ```groovy
   // Appel async (ne bloque pas)
   import java.util.concurrent.CompletableFuture

   CompletableFuture.runAsync({
     callExternalAPI(lead)
     lead.refresh()
   })

   // Workflow continue immédiatement
   ```

3. **Caching Réponses**
   ```groovy
   // Cache 1h
   def cache = __ctx__.getBean(CacheService.class)
   def cacheKey = "api_enrichment_${lead.email}"

   def result = cache.get(cacheKey)
   if (!result) {
     result = callAPI(lead)
     cache.put(cacheKey, result, 3600)  // 1h TTL
   }
   ```

### Error Handling

🛡️ **Gestion Erreurs** :

```groovy
// Pattern Retry avec Exponential Backoff
def maxRetries = 3
def retryCount = 0
def success = false

while (!success && retryCount < maxRetries) {
  try {
    def response = callExternalAPI(lead)
    success = true
    execution.setVariable('apiResult', response)
  } catch (Exception e) {
    retryCount++
    def waitTime = Math.pow(2, retryCount) * 1000  // 2s, 4s, 8s

    println "API Error (retry ${retryCount}/${maxRetries}): ${e.message}"

    if (retryCount < maxRetries) {
      Thread.sleep(waitTime as Long)
    } else {
      // Max retries → Fallback
      execution.setVariable('apiError', e.message)
      execution.setVariable('apiFailed', true)

      // Notifier admin
      sendAdminAlert("API failure pour Lead ${lead.id}: ${e.message}")
    }
  }
}
```

## 🔧 Troubleshooting

### Problème 1 : Web Service Studio timeout

**Causes** :
- ❌ API externe lente (>30s)
- ❌ Timeout Axelor trop court
- ❌ Réseau firewall

**Solutions** :
```properties
# axelor-config.properties
http.client.timeout = 60000  # 60s (default 30s)

# Dans Web Service config
Timeout: 60000 ms
Retry: 3
```

### Problème 2 : OAuth2 refresh token expiré

**Causes** :
- ❌ Refresh token expiré (>90j non utilisé)
- ❌ User a révoqué accès

**Solutions** :
```groovy
// Vérifier et refresh token
import com.axelor.studio.db.WsAuthenticator

def auth = WsAuthenticator.findByName('gmail_oauth')

if (auth.tokenExpiryDate < __date__) {
  // Refresh token
  def newToken = refreshOAuthToken(auth)
  auth.accessToken = newToken.accessToken
  auth.refreshToken = newToken.refreshToken
  auth.tokenExpiryDate = __date__.plusHours(1)
  auth.save()
}
```

### Problème 3 : Webhook non reçu

**Causes** :
- ❌ Firewall bloque IP externe
- ❌ HTTPS requis (certif invalide)
- ❌ URL incorrecte

**Solutions** :
```bash
# Tester webhook localement (ngrok)
ngrok http 8080

# URL webhook: https://abc123.ngrok.io/ws/webhook/github

# Vérifier logs serveur
tail -f axelor.log | grep webhook

# Test manuel
curl -X POST https://your-axelor.com/ws/webhook/github \
  -H "Content-Type: application/json" \
  -d '{"event":"test"}'
```

### Problème 4 : API REST 401 Unauthorized

**Causes** :
- ❌ Session expirée
- ❌ Credentials invalides
- ❌ CORS bloqué (browser)

**Solutions** :
```bash
# Vérifier credentials
curl -v -X POST http://localhost:8080/login.jsp \
  -d "username=admin&password=admin"

# Vérifier session cookie
curl -v http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -b "JSESSIONID=ABC123..."

# CORS (axelor-config.properties)
cors.allow-origin = *
cors.allow-credentials = true
```

## 📚 Références

### Documentation Officielle
- **Axelor Connect** : https://axelor.com/axelor-connect/
- **Web Services** : https://docs.axelor.com/adk/7.4/dev-guide/web-services.html
- **API REST** : https://docs.axelor.com/adk/7.4/dev-guide/rest-api.html
- **Webhooks** : https://docs.axelor.com/adk/7.4/dev-guide/webhooks.html

### APIs Tierces
- **OpenAI API** : https://platform.openai.com/docs/api-reference
- **Google Calendar API** : https://developers.google.com/calendar
- **Gmail API** : https://developers.google.com/gmail/api
- **Slack Webhooks** : https://api.slack.com/messaging/webhooks
- **GitHub Webhooks** : https://docs.github.com/en/webhooks

### Documentation Interne
- **Agent Studio** : `.claude/agents/agent-studio.md`
- **Agent BPM** : `.claude/agents/agent-bpm.md` (appels WS depuis workflows)
- **Guide Low-Code** : `.claude/docs/developpeur/low-code-axelor-studio.md`

## 📝 Checklist Configuration

```markdown
Phase 1 : Activer APIs
- [ ] utils.api.enable = true
- [ ] Configurer CORS si besoin
- [ ] Tester API REST (/ws/rest)

Phase 2 : Web Service Studio
- [ ] Créer premier Web Service (test API publique)
- [ ] Configurer auth (Bearer Token / OAuth2)
- [ ] Tester appel depuis BPM workflow
- [ ] Vérifier mapping response

Phase 3 : Axelor Connect (optionnel)
- [ ] Obtenir API key Axelor Connect
- [ ] Configurer connecteur (Gmail / Slack)
- [ ] Créer workflow d'intégration
- [ ] Tester trigger + action

Phase 4 : Webhooks
- [ ] Créer endpoint webhook custom
- [ ] Configurer source externe (GitHub, etc.)
- [ ] Tester réception payload
- [ ] Logger et monitorer

Phase 5 : Cas d'Usage Agence IA
- [ ] Enrichissement Lead OpenAI
- [ ] Sync emails Gmail → Leads
- [ ] Notifications Slack projets
- [ ] Sync calendrier Google
```

## 📝 Historique

### 2025-10-03 - Création Agent
- Création agent expert Intégrations
- Documentation Axelor Connect (1500+ connecteurs)
- Guide Web Services Studio complet
- API REST Axelor (CRUD, search, actions)
- Webhooks entrants/sortants
- 5 cas pratiques agence IA
- Best practices sécurité, performance
- Troubleshooting intégrations

---

**Maintenu par** : Équipe Dev Axelor Vecia
**Version Axelor** : 8.3.15 / AOP 7.4
**Dernière mise à jour** : 3 Octobre 2025
