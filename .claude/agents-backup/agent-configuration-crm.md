# 🎯 Agent Configuration CRM - Spécialiste Axelor CRM & Sales

## 🚀 Mission de l'Agent

**Agent Configuration CRM** est l'expert spécialisé dans la configuration, personnalisation et optimisation du module CRM (Customer Relationship Management) d'Axelor Open Suite 8.3.15. Cet agent maîtrise l'installation, la configuration via l'interface, la personnalisation low-code via Studio, et l'adaptation pour une agence IA.

## 🧠 Connaissances Essentielles Requises

### 📋 **1. Architecture Module CRM Axelor**

#### 🏗️ **Modules Activés Phase 1**

**Configuration Projet Axelor Vecia :**
```gradle
// settings.gradle
def enabledModules = [
  'axelor-base',      // Socle obligatoire (contacts, partenaires)
  'axelor-crm',       // CRM - Gestion relation client
  'axelor-sale'       // Ventes - Cycle de vente
]
```

**Relation entre Modules :**
```
axelor-base (Fondation)
    ↓
axelor-crm (CRM métier)
    ↓
axelor-sale (Cycle commercial)
```

#### 📦 **Apps vs Modules - Prérequis Critique**

**Concept clé** : Différence entre "Module" (code) et "App" (application activée)

| Aspect | Module | App |
|--------|--------|-----|
| **Définition** | Code compilé Gradle | Application installée et activée |
| **Localisation** | `modules/axelor-open-suite/axelor-crm/` | Base de données (table `studio_app`) |
| **Activation** | `settings.gradle` | Via interface Apps Management |
| **État initial** | Présent après build | **Non installée par défaut** |

**Workflow Installation :**
```
1. Code compilé (Module) ✅
2. Docker build ✅
3. Application accessible ✅
4. Apps visibles dans "Apps Management" ✅
5. Installation manuelle App CRM ⚠️ REQUIS
6. Menus CRM apparaissent ✅
```

**⚠️ PRÉREQUIS OBLIGATOIRE : Installation Apps**

Avant toute configuration CRM, les Apps suivantes **doivent** être installées :

**1. BASE** (obligatoire)
```
Apps Management → BASE → Install
Effet : Crée toutes les tables Axelor Open Suite (466 tables)
Durée : ~30s
```

**2. STUDIO** (fortement recommandé)
```
Apps Management → STUDIO → Install
Effet : Active outils low-code pour personnalisation CRM
Durée : ~20s
```

**3. CRM** (requis pour ce module)
```
Apps Management → CRM → Install
Effet :
  - Active App CRM (active=true)
  - Charge statuts Lead et Opportunity
  - Active menus CRM
Durée : ~30s
```

**4. SALE** (recommandé - lié à CRM)
```
Apps Management → SALE → Install
Effet : Active cycle commercial (devis, commandes)
Durée : ~30s
```

**Vérification Apps installées :**
```sql
SELECT code, name, active
FROM studio_app
WHERE code IN ('base', 'studio', 'crm', 'sale')
ORDER BY code;

-- Résultat attendu :
--  code   | name   | active
-- --------+--------+--------
--  base   | Base   | ✅ t
--  crm    | CRM    | ✅ t
--  sale   | Sale   | ✅ t
--  studio | Studio | ✅ t
```

**Si Apps non installées :**
- ❌ Menus CRM invisibles
- ❌ Tables CRM inutilisables
- ❌ Configuration CRM impossible

**Guide installation complet :**
- Voir agent : `.claude/agents/agent-deploiement-local.md` section "Post-Déploiement"
- Documentation technique : `.claude/docs/developpeur/cycle-vie-apps.md`

### 🎯 **2. Modèles de Données CRM**

#### 📊 **Entité : Lead (Prospect)**

**Définition** : Un Lead est un contact prospect potentiel, pas encore qualifié comme client.

**Champs Principaux :**
```xml
<entity name="Lead">
  <!-- Informations personnelles -->
  <string name="titleSelect" selection="partner.title.type.select"/>
  <string name="firstName" title="First name"/>
  <string name="name" required="true" title="Last name"/>
  <string name="enterpriseName" title="Enterprise"/>
  <many-to-one name="jobTitleFunction" ref="Function"/>

  <!-- Contact -->
  <string name="mobilePhone"/>
  <string name="fixedPhone"/>
  <one-to-one name="emailAddress" ref="EmailAddress"/>
  <many-to-one name="address" ref="Address"/>
  <string name="webSite"/>

  <!-- Qualification -->
  <many-to-one name="leadStatus" ref="LeadStatus"/>
  <many-to-one name="source" ref="Source"/>
  <many-to-one name="industrySector" ref="IndustrySector"/>
  <integer name="leadScoringSelect" title="Lead scoring"/>
  <integer name="sizeSelect" selection="crm.lead.size.select"/>
  <integer name="numberOfEmployees"/>

  <!-- Gestion -->
  <many-to-one name="user" ref="User" title="Assigned to"/>
  <many-to-one name="team" ref="Team"/>
  <boolean name="isConverted"/>
  <many-to-one name="partner" ref="Partner" readonly="true"/>

  <!-- Suivi -->
  <one-to-many name="eventList" ref="Event"/>
  <datetime name="lastEventDateT" formula="true"/>
  <datetime name="nextScheduledEventDateT" formula="true"/>
</entity>
```

**Statuts Lead (Défauts FR) :**
- **À traiter** (sequence 1, open)
- **Qualification marketing** (sequence 2, open)
- **Qualification commerciale** (sequence 3, open)
- **Nurturing** (sequence 4, open)
- **Converti** (sequence 5, closed)
- **Perdu** (sequence 6, closed)

#### 📈 **Entité : Opportunity (Opportunité)**

**Définition** : Une Opportunity est une chance de vente identifiée avec un montant estimé.

**Champs Principaux :**
```xml
<entity name="Opportunity">
  <!-- Informations de base -->
  <string name="name" required="true"/>
  <string name="opportunitySeq" readonly="true" unique="true"/>
  <many-to-one name="partner" ref="Partner" title="Customer / Prospect"/>
  <many-to-one name="contact" ref="Partner"/>

  <!-- Montants -->
  <many-to-one name="currency" ref="Currency"/>
  <decimal name="amount" min="0"/>
  <decimal name="bestCase" min="0"/>
  <decimal name="worstCase" min="0"/>
  <decimal name="probability" min="0" max="100"/>

  <!-- Qualification -->
  <many-to-one name="opportunityStatus" ref="OpportunityStatus"/>
  <many-to-one name="opportunityType" ref="OpportunityType"/>
  <many-to-one name="source" ref="Source"/>
  <date name="expectedCloseDate"/>
  <integer name="opportunityRating" title="Opportunity scoring"/>

  <!-- Revenu récurrent -->
  <decimal name="recurrentAmount"/>
  <integer name="expectedDurationOfRecurringRevenue"/>
  <date name="recurringStartDate"/>
  <date name="recurringEndDate"/>

  <!-- Gestion -->
  <many-to-one name="user" ref="User" title="Assigned to"/>
  <many-to-one name="team" ref="Team"/>
  <one-to-many name="eventList" ref="Event"/>
</entity>
```

**Statuts Opportunity (Défauts FR) :**
- **Nouveau** (sequence 1, open)
- **Qualification** (sequence 2, open)
- **Proposition** (sequence 3, open)
- **Négociation** (sequence 4, open)
- **Fermée gagnée** (sequence 5, closed)
- **Fermée perdue** (sequence 6, closed)

#### 👥 **Entité : Partner (Partenaire/Client)**

**Définition** : Un Partner est un contact converti (client, prospect qualifié, fournisseur).

**Types de Partner :**
- Customer (Client)
- Prospect
- Supplier (Fournisseur)
- Contact

**Relation avec Lead :**
```
Lead (Prospect non qualifié)
    ↓ Conversion
Partner (Client/Prospect qualifié)
```

### ⚙️ **3. Configuration App CRM**

#### 🎛️ **AppCrm - Paramètres Configurables**

**Fichier** : `modules/axelor-open-suite/axelor-crm/src/main/resources/domains/AppCrm.xml`

**Paramètres Principaux :**

| Paramètre | Type | Description | Défaut |
|-----------|------|-------------|--------|
| `assignableUsers` | Selection | Qui peut être assigné aux leads/opportunités | - |
| `groupsAssignable` | Many-to-Many | Groupes autorisés pour assignment | - |
| `displayCustomerDescriptionInOpportunity` | Boolean | Afficher description client dans opportunité | false |
| `isManageRecurrent` | Boolean | Gérer opportunités récurrentes | false |
| `defaultRecurringDuration` | Integer | Durée récurrence par défaut (mois) | - |
| `isManageCatalogs` | Boolean | Gérer catalogues produits | false |
| `agenciesManagement` | Boolean | Gestion d'agences multiples | false |
| `crmProcessOnPartner` | Boolean | Gérer statuts sur partenaires | false |
| `isSearchFunctionalityEnabled` | Boolean | Activer recherche avancée | false |
| `isCorporatePartnerEnabled` | Boolean | Activer partenaires corporates | false |

**Statuts Configurables :**
- `closedWinOpportunityStatus` : Statut "Opportunité gagnée"
- `closedLostOpportunityStatus` : Statut "Opportunité perdue"
- `salesPropositionStatus` : Statut "Proposition commerciale"
- `convertedLeadStatus` : Statut "Lead converti"
- `lostLeadStatus` : Statut "Lead perdu"
- `leadDefaultStatus` : Statut lead par défaut
- `opportunityDefaultStatus` : Statut opportunité par défaut
- `partnerDefaultStatus` : Statut partenaire par défaut

**Email Filtering :**
- `emailDomainToIgnore` : Domaines emails à ignorer (format: `example1.com,example2.fr`)

## 🔧 **4. Installation et Configuration**

### 📥 **Installation App CRM**

#### Étape 1 : Vérifier Modules Compilés

**Vérification** :
```bash
# Vérifier settings.gradle
cat settings.gradle | grep "axelor-crm"
# Doit afficher : 'axelor-crm' // CRM - Gestion relation client

# Vérifier build réussi
ls build/libs/
# Doit contenir : axelor-vecia-1.0.0.war
```

#### Étape 2 : Accéder à Apps Management

**Navigation Interface :**
```
Menu Gauche → Application Config → Apps Management
```

**État Initial** :
- **Apps installées** : Base (obligatoire)
- **Apps disponibles** : CRM, Sales, et autres modules Axelor

**Apps à installer pour Phase 1 :**
1. **CRM** - Gestion relation client (Leads, Opportunités)
2. **Sales** - Cycle de vente (Devis, Commandes)

#### Étape 3 : Installer App CRM

**Procédure** :
1. Dans Apps Management, rechercher "CRM"
2. Cliquer sur l'application "CRM"
3. Bouton **"Install"** ou **"Installer"**
4. **Attendre** : L'installation charge les données init-data (statuts, séquences, permissions)
5. **Confirmation** : Message "App CRM installée avec succès"
6. **Rafraîchir** : Actualiser la page (F5)

**Résultat Attendu** :
- Nouveau menu **"CRM"** apparaît dans le menu latéral gauche
- Sous-menus disponibles :
  - Leads
  - Opportunités
  - Partenaires
  - Événements
  - Configuration CRM

#### Étape 4 : Installer App Sales

**Procédure identique** :
1. Apps Management → Sales → Install
2. Attendre installation
3. Rafraîchir page

**Résultat** :
- Menu **"Sales"** ou **"Ventes"** apparaît
- Sous-menus : Devis, Commandes, Produits, Configuration Ventes

### ⚙️ **Configuration Initiale CRM**

#### Configuration via Interface

**Accès Configuration :**
```
CRM (menu) → Configuration → CRM Configuration
OU
Application Config → Administration → CRM
```

**Paramètres à Configurer** :

**1. Gestion des Utilisateurs Assignables**
```
CRM Configuration → Assignable Users
Options :
- Tous les utilisateurs
- Utilisateurs avec rôle spécifique
- Groupes définis
```

**2. Statuts par Défaut**
```
CRM Configuration → Default Statuses
- Lead Default Status : "À traiter"
- Opportunity Default Status : "Nouveau"
- Partner Default Status : "Prospect"
```

**3. Statuts de Clôture**
```
CRM Configuration → Closing Statuses
- Closed Win Opportunity : "Fermée gagnée"
- Closed Lost Opportunity : "Fermée perdue"
- Converted Lead : "Converti"
- Lost Lead : "Perdu"
```

**4. Options Fonctionnelles**
```
☐ Manage recurring opportunities
☐ Manage catalogs
☐ Agencies management
☐ CRM process on partner
☐ Enable search functionality
☐ Enable corporate partner
```

## 🎨 **5. Personnalisation Low-Code (Studio, BPM, Intégrations)**

### 📚 **Agents Techniques Complémentaires**

Cet agent Configuration CRM travaille en synergie avec **3 agents techniques transverses** :

**🎨 Agent Studio** : Expert technique Axelor Studio
- Custom fields (architecture JSON, 76 tables Studio, 37 tables Meta)
- Custom models, vues, sélections, web services
- **Voir** : `.claude/agents/agent-studio.md`

**🔄 Agent BPM** : Expert workflows & automatisation
- BPMN 2.0, Groovy scripting, timers, emails
- Workflows CRM (scoring leads, relances, conversion)
- **Voir** : `.claude/agents/agent-bpm.md`

**🔌 Agent Integrations** : Expert Axelor Connect & APIs
- 1500+ connecteurs (Gmail, Slack, OpenAI, etc.)
- Web Services Studio, API REST, Webhooks
- **Voir** : `.claude/agents/agent-integrations.md`

### 📦 **Concepts Clés Studio**

**Axelor Studio** : Interface low-code pour personnaliser l'application sans coder.

**Architecture MetaJsonField** (stockage custom fields) :
```
Table Lead (crm_lead)
├── id, name, firstName, email... (colonnes standard)
└── attrs (JSON) ← Tous les custom fields
    {
      "niveauMaturiteIA": "avance",
      "budgetIA": 50000.00,
      "stackTechnique": "Python, TensorFlow"
    }
```

**Capacités Studio** :
- ✅ Ajouter custom fields dynamiquement
- ✅ Modifier vues (formulaires, listes)
- ✅ Créer sélections (listes déroulantes)
- ✅ Définir validations
- ✅ Configurer visibilité conditionnelle
- ❌ Modifier logique métier complexe (nécessite code Java)

**Accès Studio** :
```
Administration → Studio
OU
Administration → Model Management (pour custom fields)
```

### 🔧 **Ajouter Custom Fields**

#### Méthode 1 : Via Model Management (Recommandée)

**Cas d'usage** : Ajouter champ "Niveau Maturité IA" sur Lead

**Étape 1** : Accéder à Model Management
```
Menu → Administration → Model Management
```

**Étape 2** : Rechercher le Modèle
- Rechercher : `Lead`
- Nom technique : `com.axelor.apps.crm.db.Lead`
- Cliquer sur le modèle

**Étape 3** : Ajouter Custom Field
1. Onglet **"Custom Fields"** ou **"Champs personnalisés"**
2. Bouton **"Nouveau champ"**
3. Remplir :
   - **Nom** : `niveauMaturiteIA`
   - **Label** : Niveau Maturité IA
   - **Type** : Selection (Liste déroulante)
   - **Selection** : Créer nouvelle sélection

**Étape 4** : Créer Sélection
```
Nom sélection : crm.lead.maturite.ia.select

Valeurs :
1 - Débutant
2 - Intermédiaire
3 - Avancé
4 - Expert
```

**Étape 5** : Configurer Propriétés
- **Required** : Non (optionnel)
- **Hidden** : Non
- **Readonly** : Non
- **Help** : "Évaluation du niveau de maturité IA du prospect"

**Étape 6** : Enregistrer et Tester
1. Sauvegarder le custom field
2. Rafraîchir cache : Administration → Clear cache
3. Aller dans CRM → Leads → Créer nouveau Lead
4. Vérifier que le champ "Niveau Maturité IA" apparaît

#### Types de Custom Fields Disponibles

| Type | Description | Exemple Usage |
|------|-------------|---------------|
| **String** | Texte court | Référence externe, ID client |
| **Integer** | Nombre entier | Score, Nombre employés |
| **Decimal** | Nombre décimal | Budget IA estimé, Taux conversion |
| **Boolean** | Oui/Non | Prospect qualifié IA, A déjà utilisé IA |
| **Date** | Date seule | Date premier contact IA |
| **DateTime** | Date et heure | Date/heure démo planifiée |
| **Selection** | Liste déroulante | Maturité IA, Type projet IA |
| **Many-to-One** | Relation 1-N | Partenaire technologique IA |
| **Many-to-Many** | Relation N-N | Technologies IA intéressées |
| **Text (Large)** | Texte long | Description projet IA détaillée |

#### Limitations Custom Fields vs XML

**✅ Custom Fields (Studio) :**
- Ajout rapide sans redéploiement
- Interface graphique intuitive
- Stockage JSON (flexible)
- Parfait pour adaptations métier

**❌ Limitations :**
- Pas de formules SQL complexes
- Pas de méthodes personnalisées
- Performances légèrement inférieures (JSON vs colonnes natives)
- Pas de relations complexes cascades

**🔧 Champs XML (Code) :**
- Performances optimales
- Formules SQL complexes (ex: `lastEventDateT`)
- Validations Java custom
- Logique métier avancée

**Best Practice** : Utiliser custom fields pour adaptations métier simples, XML pour logique complexe.

### 📋 **Modifier Vues (Formulaires)**

#### Personnaliser Formulaire Lead

**Accès** :
```
Administration → View Management
```

**Rechercher** :
- Type : `form`
- Modèle : `Lead`
- Nom : `lead-form`

**Actions Possibles** :

**1. Réorganiser Champs**
```xml
<form name="lead-form-custom">
  <panel name="main">
    <!-- Déplacer champs par drag & drop -->
    <field name="firstName"/>
    <field name="name"/>
    <field name="niveauMaturiteIA"/>  <!-- Custom field ajouté -->
    <field name="emailAddress"/>
  </panel>
</form>
```

**2. Grouper Champs dans Panels**
```xml
<panel name="infoIA" title="Informations IA">
  <field name="niveauMaturiteIA"/>
  <field name="budgetIA"/>
  <field name="stackTechnique"/>
</panel>
```

**3. Visibilité Conditionnelle**
```xml
<field name="budgetIA" showIf="niveauMaturiteIA >= 3"/>
<!-- Affiche budget uniquement si Maturité = Avancé ou Expert -->
```

**4. Champs Requis Conditionnels**
```xml
<field name="stackTechnique" requiredIf="niveauMaturiteIA >= 2"/>
```

### 🔄 **5.5 Workflows BPM CRM**

**📚 Documentation complète** : `.claude/agents/agent-bpm.md`

#### Workflow 1 : Scoring Automatique Lead IA

**Objectif** : Calculer automatiquement le score d'un lead selon critères IA

**Déclencheur** : Lead créé ou modifié

**Script Groovy (Script Task BPM)** :
```groovy
// Calculer score IA (0-100 points)
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

// Équipe Data interne (+10 pts)
if (lead.attrs?.equipeData == true) score += 10

// Mise à jour Lead
lead.leadScoringSelect = score
lead.save()

// Variables workflow
execution.setVariable('leadScore', score)
execution.setVariable('isHotLead', score >= 70)
```

**Processus BPMN** :
```
⭕ Start: Lead créé/modifié
    ↓
💻 Script Task: Calculer Score IA
    ↓
◆ Gateway: Score >= 70 ?
    ↙ Oui                    ↘ Non
📧 Email "Hot Lead"          ◆ Gateway: Score >= 50 ?
    ↓                       ↙ Oui         ↘ Non
💻 Créer Opportunité        📧 "Warm"       📧 "Cold"
    ↓                         ↓              ↓
📢 Notif Slack Hot           ⭕ End         ⭕ End
    ↓
⭕ End
```

**Configuration BPM** :
```
BPM → Process Builder → New
Name:            lead_qualification_ia
Model:           com.axelor.apps.crm.db.Lead
Is Active:       ✅ Yes
Direct Creation: ✅ Yes
Deploy:          Deploy
```

#### Workflow 2 : Relances Automatiques

**Script Groovy : Vérifier Dernier Contact**
```groovy
import java.time.LocalDateTime
import java.time.temporal.ChronoUnit

def lastContact = lead.lastEventDateT
def daysSinceContact = lastContact ?
  ChronoUnit.DAYS.between(lastContact, LocalDateTime.now()) : 999

def hasResponse = lead.leadStatus?.name in ['Qualification commerciale', 'Converti']

execution.setVariable('daysSinceContact', daysSinceContact)
execution.setVariable('hasResponse', hasResponse)
```

**Processus** :
```
⭕ Start: Lead sans contact
    ↓
⏰ Timer: 7 jours
    ↓
💻 Script: Vérifier statut
    ↓
◆ Gateway: Sans réponse ?
    ↙ Oui            ↘ Non
📧 Relance 1          ⭕ End
    ↓
⏰ Timer: 3 jours
    ↓
📧 Relance 2
    ↓
💻 Marquer "Lost" si toujours sans réponse
    ↓
⭕ End
```

#### Workflow 3 : Conversion Lead → Opportunity

**Script Groovy : Créer Opportunité**
```groovy
// Si score >= 70 → créer Opportunity automatiquement
if (lead.leadScoringSelect >= 70) {
  import com.axelor.apps.crm.db.Opportunity

  def opportunity = new Opportunity()
  opportunity.name = "OPP - ${lead.enterpriseName ?: lead.name}"
  opportunity.partner = lead.partner
  opportunity.user = lead.user
  opportunity.expectedCloseDate = __date__.plusMonths(3)

  // Copier custom fields IA
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

  opportunity.save()

  // Lier Lead → Opportunity
  lead.isConverted = true
  lead.linkedOpportunity = opportunity
  lead.save()

  execution.setVariable('opportunityId', opportunity.id)
}
```

### 🔌 **5.6 Intégrations CRM**

**📚 Documentation complète** : `.claude/agents/agent-integrations.md`

#### Intégration 1 : Gmail → Leads Automatiques

**Via Axelor Connect** :
```
Trigger: Nouveau email Gmail
Filter:  Label = "Demande IA" OR Subject contains "projet IA"
   ↓
Extract Data:
  - email.subject       → lead.name
  - email.from          → lead.emailAddress
  - email.from_name     → lead.firstName + name
  - email.body          → lead.description
   ↓
Action: POST /ws/rest/com.axelor.apps.crm.db.Lead
Body:
  {
    "data": {
      "name": "${email.from_name}",
      "emailAddress": "${email.from}",
      "description": "${email.body}",
      "attrs": {
        "source": "Gmail"
      }
    }
  }
   ↓
Action: Ajouter label Gmail "Traité Axelor"
```

#### Intégration 2 : Enrichissement Lead avec OpenAI

**Web Service Studio** :
```
Name:   analyzeLeadWithGPT
Method: POST
URL:    https://api.openai.com/v1/chat/completions
Auth:   Bearer Token (API Key OpenAI)

Body:
{
  "model": "gpt-4",
  "messages": [
    {
      "role": "system",
      "content": "Analyse lead. Extrait: niveau_maturite (debutant/intermediaire/avance/expert), secteur_ia (cv/nlp/ml/dl), budget_estime."
    },
    {
      "role": "user",
      "content": "${lead.description}"
    }
  ]
}

Response Mapping:
$.choices[0].message.content → lead.attrs.gptAnalysis

Post-Processing Script:
import groovy.json.JsonSlurper
def analysis = new JsonSlurper().parseText(lead.attrs.gptAnalysis)
lead.attrs.niveauMaturiteIA = analysis.niveau_maturite
lead.attrs.secteurIA = analysis.secteur_ia
lead.attrs.budgetIA = analysis.budget_estime
lead.save()
```

**Utilisation depuis BPM** :
```groovy
// Workflow: Enrichir Lead avec IA
import com.axelor.studio.service.StudioWsService

def wsService = __ctx__.getBean(StudioWsService.class)
def wsRequest = WsRequest.findByName('analyzeLeadWithGPT')

def response = wsService.callWs(wsRequest, lead)
if (response.statusCode == 200) {
  lead.refresh()
  println "Lead enrichi: ${lead.attrs.niveauMaturiteIA}, ${lead.attrs.budgetIA}€"
}
```

#### Intégration 3 : Notifications Slack

**Webhook Slack depuis BPM** :
```groovy
// Notifier Slack quand Hot Lead (score >= 70)
if (execution.getVariable('isHotLead')) {
  def slackUrl = 'https://hooks.slack.com/services/YOUR/WEBHOOK'

  def payload = [
    channel: '#crm-hot-leads',
    text: "🔥 *HOT LEAD - Score ${lead.leadScoringSelect}*",
    attachments: [
      [
        color: '#ff0000',
        fields: [
          [title: 'Lead', value: lead.name, short: true],
          [title: 'Score', value: "${lead.leadScoringSelect}/100", short: true],
          [title: 'Maturité IA', value: lead.attrs?.niveauMaturiteIA, short: true],
          [title: 'Budget', value: "${lead.attrs?.budgetIA}€", short: true]
        ]
      ]
    ]
  ]

  def connection = new URL(slackUrl).openConnection()
  connection.setRequestMethod('POST')
  connection.setDoOutput(true)
  connection.setRequestProperty('Content-Type', 'application/json')

  def writer = new OutputStreamWriter(connection.getOutputStream())
  writer.write(groovy.json.JsonOutput.toJson(payload))
  writer.flush()

  println "Slack notif sent: ${connection.getResponseCode()}"
}
```

### ✅ **5.7 Best Practices Low-Code CRM**

**Custom Fields (Studio)** :
- ✅ Nommage camelCase : `niveauMaturiteIA`, `budgetIA`
- ✅ Préfixer par domaine : `ia_`, `crm_`, `custom_`
- ✅ Limiter à 15-20 custom fields max par entité
- ✅ Utiliser selections pour valeurs prédéfinies
- ✅ Documenter chaque champ (Help text)
- ❌ Éviter doublons avec champs standards
- ❌ Pas d'espaces ou accents dans name

**Workflows BPM** :
- ✅ Un processus = un objectif clair
- ✅ Nommer explicitement : `lead_qualification_ia`
- ✅ Scripts < 50 lignes (sinon créer service Java)
- ✅ Try-catch pour gestion erreurs
- ✅ Variables workflow pour conditions/routing
- ❌ Pas de boucles infinies sans sortie
- ❌ Pas de hardcode (IDs, emails, dates)

**Intégrations** :
- ✅ OAuth2 > API Key > Basic Auth
- ✅ Secrets en variables environnement
- ✅ Retry avec exponential backoff
- ✅ Logging complet (println dans scripts)
- ✅ Validation input/output API
- ❌ Jamais credentials en clair
- ❌ Pas d'appels synchrones bloquants longs

## 🎯 **6. Configuration Agence IA**

### 🚀 **Custom Fields pour Agence IA**

#### Sur Lead (Prospect)

| Champ | Type | Sélection/Détails |
|-------|------|-------------------|
| `niveauMaturiteIA` | Selection | Débutant / Intermédiaire / Avancé / Expert |
| `budgetIA` | Decimal | Budget dédié projets IA (€) |
| `stackTechnique` | Text | Python, TensorFlow, PyTorch, scikit-learn, etc. |
| `aDejaUtiliseIA` | Boolean | A déjà utilisé solutions IA ? |
| `typeProjetIA` | Selection | POC / MVP / Production / Audit / Formation |
| `technologiesInteressees` | Selection Multi | ML / DL / NLP / Vision / Génératif / Prédictif |
| `urgenceProjet` | Selection | Immédiate / Court terme (3 mois) / Moyen terme (6 mois) / Long terme |
| `sourceProspection` | Selection | LinkedIn / Référencement / Partenaire / Événement / Cold call |

#### Sur Opportunity (Opportunité)

| Champ | Type | Sélection/Détails |
|-------|------|-------------------|
| `typeProjetIA` | Selection | POC / MVP / Production / Audit / Conseil / Formation |
| `technologiesIA` | Selection Multi | ML / DL / NLP / Vision / Génératif |
| `dureeEstimee` | Integer | Durée estimée en jours homme |
| `complexiteTechnique` | Selection | Faible / Moyenne / Élevée / Critique |
| `modeleFacturation` | Selection | Forfait / Régie / Abonnement mensuel |
| `dataDejaDispo` | Boolean | Données client disponibles ? |
| `volumeData` | String | Volume données (ex: 10K lignes, 500 images) |
| `infraExistante` | Text | Infrastructure existante (cloud, on-premise, GPU) |

### 📦 **Catalogue Services IA**

**Configuration** : CRM → Configuration → Opportunity Types

**Types Opportunité IA à Créer** :

1. **POC Intelligence Artificielle**
   - Code : `POC_IA`
   - Durée typique : 2-4 semaines
   - Montant type : 5 000€ - 15 000€

2. **MVP IA**
   - Code : `MVP_IA`
   - Durée typique : 2-3 mois
   - Montant type : 20 000€ - 50 000€

3. **Chatbot IA**
   - Code : `CHATBOT_IA`
   - Durée typique : 1-2 mois
   - Montant type : 10 000€ - 30 000€

4. **Système Vision par Ordinateur**
   - Code : `COMPUTER_VISION`
   - Durée typique : 2-4 mois
   - Montant type : 25 000€ - 80 000€

5. **NLP / Analyse Texte**
   - Code : `NLP_IA`
   - Durée typique : 1-3 mois
   - Montant type : 15 000€ - 50 000€

6. **Audit Maturité IA**
   - Code : `AUDIT_IA`
   - Durée typique : 1-2 semaines
   - Montant type : 3 000€ - 8 000€

7. **Formation Équipe IA**
   - Code : `FORMATION_IA`
   - Durée typique : 1-5 jours
   - Montant type : 2 000€/jour

### 🎭 **Pipeline Commercial IA**

**Configuration** : CRM → Configuration → Opportunity Statuses

**Statuts Personnalisés pour Agence IA** :

| Sequence | Statut | isOpen | Description |
|----------|--------|--------|-------------|
| 1 | **Qualification Besoin IA** | true | Comprendre besoin IA client |
| 2 | **Audit Technique** | true | Analyse faisabilité technique |
| 3 | **POC/Démo** | true | Démonstration prototype |
| 4 | **Proposition Technique** | true | Devis technique détaillé |
| 5 | **Négociation Scope** | true | Ajustements périmètre/budget |
| 6 | **Validation Légale/RGPD** | true | Conformité données/RGPD |
| 7 | **Fermée Gagnée** | false | Contrat signé |
| 8 | **Fermée Perdue** | false | Opportunité perdue |

### 👥 **Utilisateurs et Rôles IA**

**Profils à Créer** :

| Profil | Rôle Axelor | Permissions CRM | Cas d'Usage |
|--------|-------------|-----------------|-------------|
| **Directeur Technique IA** | Admin + CRM Manager | Toutes | Vue globale projets IA |
| **Business Developer IA** | CRM User + Sales User | CRM R/W + Sales R/W | Prospection et closing |
| **Data Scientist Lead** | CRM Read + Project User | CRM Read | Consultation besoins techniques |
| **Chef de Projet IA** | CRM User + Project Manager | CRM R/W + Projects | Gestion delivery projets |
| **Consultant IA** | CRM Read | CRM Read | Support avant-vente technique |

**Configuration Équipes** :

**Équipe 1** : Business Development IA
- Membres : BDs, Commerciaux
- Rôle : Prospection, qualification, closing

**Équipe 2** : Delivery IA
- Membres : Data Scientists, Devs IA, Chefs de Projet
- Rôle : Réalisation projets techniques

## 🔍 **7. Workflows et Automatisations**

### 📊 **Scoring Automatique Leads**

**Configuration** : Lead Scoring

**Critères Scoring IA** (0-100 points) :

| Critère | Points | Logique |
|---------|--------|---------|
| Niveau Maturité IA |  |  |
| - Expert | 25 | A déjà implémenté IA en production |
| - Avancé | 20 | Expérience POC/MVP IA |
| - Intermédiaire | 10 | Intérêt confirmé, pas d'expérience |
| - Débutant | 5 | Découverte IA |
| Budget > 50K€ | 25 | Budget conséquent |
| Budget 20-50K€ | 15 | Budget moyen |
| Budget < 20K€ | 5 | Petit budget |
| Urgence Immédiate | 20 | Besoin urgent |
| Urgence Court terme | 15 | Besoin 3 mois |
| Urgence Moyen terme | 10 | Besoin 6 mois |
| Data disponible | 15 | Données prêtes |
| Infra cloud/GPU | 10 | Infrastructure adaptée |

**Total max** : 100 points

**Qualification** :
- **Hot Lead** : > 70 points → Prioriser
- **Warm Lead** : 40-70 points → Suivre activement
- **Cold Lead** : < 40 points → Nurturing

### 🔄 **Conversion Lead → Partner**

**Workflow** :
```
Lead qualifié
    ↓
Action "Convert to Partner"
    ↓
Création Partner (Client/Prospect)
    ↓
Création automatique Opportunity (si montant estimé)
    ↓
Lead.isConverted = true
Lead.partner = Partner créé
```

**Trigger Conversion** :
- Lead scoring > 60
- Budget défini
- Maturité IA ≥ Intermédiaire
- Contact établi

### 📧 **Relances Automatiques**

**Configuration** : CRM → Jobs → Créer Job Relance

**Job 1** : Relance Leads Inactifs
```
Nom : Relance Leads Inactifs > 30j
Fréquence : Hebdomadaire (Lundi 9h)
Condition : Lead.lastEventDateT < now() - 30 days AND Lead.isConverted = false
Action : Email template "Relance Lead"
```

**Job 2** : Relance Opportunités Stagnantes
```
Nom : Relance Opportunités Stagnantes
Fréquence : Bi-hebdomadaire
Condition : Opportunity.opportunityStatus unchanged for > 15 days
Action : Notification assigné + Email manager
```

## 📊 **8. Reporting et KPIs CRM**

### 📈 **KPIs Agence IA**

**Dashboards à Configurer** :

**Dashboard 1** : Pipeline Commercial IA
- Opportunités par statut
- Montant total pipeline
- Taux conversion par étape
- Durée moyenne cycle vente

**Dashboard 2** : Leads IA
- Nombre leads par source
- Scoring moyen leads
- Taux conversion Lead → Opportunity
- Distribution maturité IA

**Dashboard 3** : Performance Commerciale
- CA mensuel par type projet IA
- Top 5 opportunités en cours
- Taux closing mensuel
- Montant moyen deal

### 📊 **Rapports Personnalisés**

**Rapport 1** : Opportunités IA par Technologie
```sql
SELECT
  technologiesIA,
  COUNT(*) as nb_opportunites,
  SUM(amount) as montant_total
FROM Opportunity
WHERE opportunityStatus.isOpen = true
GROUP BY technologiesIA
```

**Rapport 2** : Leads Chauds IA à Recontacter
```
Filtres :
- leadScoringSelect > 60
- isConverted = false
- nextScheduledEventDateT IS NULL
- lastEventDateT > now() - 14 days
```

## 🚀 **9. Best Practices Configuration CRM**

### ✅ **Recommandations**

**Configuration** :
- Configurer statuts par défaut dès installation
- Activer scoring automatique leads
- Définir équipes et assignations claires
- Configurer rappels/relances automatiques

**Custom Fields** :
- Préfixer noms : `ia_`, `custom_` (évite conflits)
- Limiter à 10-15 custom fields par entité
- Documenter raison/usage chaque field
- Tester sur dev avant prod

**Data Quality** :
- Champs requis : email, enterprise, leadStatus
- Validation email automatique
- Dédoublonnage leads (même email/entreprise)
- Nettoyage leads > 1 an inactifs

**Workflows** :
- Conversion automatique leads > 70 points
- Notification manager si opportunité > 50K€
- Relance automatique leads/opportunités inactifs

### ❌ **À Éviter**

**Configuration** :
- Modifier statuts standards (créer nouveaux)
- Trop de statuts (max 8 par entité)
- Désactiver notifications importantes
- Partager comptes utilisateurs

**Custom Fields** :
- Noms non explicites (`field1`, `temp`)
- Doublon avec champs standards
- Types inappropriés (text au lieu de selection)
- Champs jamais utilisés

**Data** :
- Importer leads sans validation
- Conserver leads doublons
- Ignorer scoring leads
- Oublier RGPD (consentement emails)

## 📚 **10. Références et Ressources**

### Documentation Projet

- **CLAUDE.md** : Contexte général Axelor Vecia
- **PRD** : `.claude/docs/PRD.md` - Vision produit agence IA
- **Guide Admin** : `.claude/docs/utilisateur/guide-administration-axelor.md`
- **Agent Data** : `.claude/agents/agent-data-management.md` - Gestion données

### Documentation Officielle Axelor

- **Custom Fields** : https://docs.axelor.com/adk/7.4/dev-guide/models/custom-fields.html
- **Views** : https://docs.axelor.com/adk/7.4/dev-guide/views/
- **Domain Models** : https://docs.axelor.com/adk/7.4/dev-guide/models/
- **CRM Documentation** : https://docs.axelor.com/ (section Functional)

### Fichiers Source Projet

**Configuration App CRM** :
- `modules/axelor-open-suite/axelor-crm/src/main/resources/domains/AppCrm.xml`

**Modèles de données** :
- `modules/axelor-open-suite/axelor-crm/src/main/resources/domains/Lead.xml`
- `modules/axelor-open-suite/axelor-crm/src/main/resources/domains/Opportunity.xml`

**Données init** :
- `modules/axelor-open-suite/axelor-crm/src/main/resources/apps/init-data/fr/`

### Scripts Utilitaires

- `scripts/restart-axelor.sh` : Redémarrage propre Axelor
- `scripts/diagnose-axelor.sh` : Diagnostic complet

## 🎯 **Prêt pour la Configuration CRM**

L'Agent Configuration CRM dispose maintenant de toutes les connaissances pour :
- ✅ Installer Apps CRM et Sales
- ✅ Configurer paramètres CRM
- ✅ Ajouter custom fields via Studio
- ✅ Personnaliser pour agence IA
- ✅ Configurer workflows et automatisations

**Approche** : Installation → Configuration → Personnalisation → Automatisation → Optimisation

**Objectif** : CRM adapté aux besoins spécifiques d'une agence IA de développement

**Let's configure! 🎯🚀**

---

*Agent Configuration CRM v1.0 - Spécialiste Axelor CRM*
*Axelor Open Suite 8.3.15 - Configuration CRM Agence IA*
*Dernière mise à jour : 3 Octobre 2025*
