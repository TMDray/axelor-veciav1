# Knowledge Base : CRM Customization (Agence IA)

**Type** : Pure Technical Reference (no agent narrative)
**Version Axelor** : 8.3.15 / AOP 7.4
**Scope** : CRM custom fields, workflows, views, integrations for AI Agency
**Usage** : Accessed dynamically by routing agents

---

## 1. Custom Fields - Lead (Agence IA)

### 1.1 Configuration Studio

**Table**: `crm_lead`
**Storage**: JSON column `attrs`

#### Champs Custom - Maturité et Contexte IA

```xml
<!-- Via Studio UI ou XML -->
<field name="niveauMaturiteIA" type="string" selection="selection-maturite-ia"
       title="Niveau Maturité IA" showIf="isAIAgency" />
<field name="budgetIA" type="decimal" title="Budget IA Estimé (€)"
       precision="20" scale="2" showIf="isAIAgency" />
<field name="stackTechnique" type="text" title="Stack Technique Client"
       multiline="true" />
<field name="infrastructureType" type="string" selection="selection-infrastructure"
       title="Type Infrastructure" />
<field name="casUsageIA" type="text" title="Cas d'Usage IA Souhaités"
       multiline="true" />
<field name="urgenceProjet" type="string" selection="selection-urgence"
       title="Urgence Projet" />
<field name="dateLancement" type="date" title="Date Lancement Souhaitée" />
<field name="leadScoringIA" type="integer" title="Score Lead IA (0-100)"
       readonly="true" />
<field name="sourceProspection" type="string" selection="selection-source"
       title="Source Prospection" />
<field name="competiteursMentionnes" type="text" title="Compétiteurs Mentionnés"
       multiline="true" />
```

#### Selections (Listes de Valeurs)

```xml
<!-- File: modules/axelor-crm/src/main/resources/domains/Lead.xml -->

<selection name="selection-maturite-ia">
  <option value="debutant">Débutant (Exploration)</option>
  <option value="intermediaire">Intermédiaire (POC en cours)</option>
  <option value="avance">Avancé (IA en production)</option>
  <option value="expert">Expert (Data Science team interne)</option>
</selection>

<selection name="selection-infrastructure">
  <option value="on-premise">On-Premise</option>
  <option value="cloud-aws">Cloud AWS</option>
  <option value="cloud-azure">Cloud Azure</option>
  <option value="cloud-gcp">Cloud GCP</option>
  <option value="hybrid">Hybrid</option>
  <option value="none">Non défini</option>
</selection>

<selection name="selection-urgence">
  <option value="faible">Faible (> 6 mois)</option>
  <option value="moyenne">Moyenne (3-6 mois)</option>
  <option value="haute">Haute (< 3 mois)</option>
  <option value="critique">Critique (< 1 mois)</option>
</selection>

<selection name="selection-source">
  <option value="linkedin">LinkedIn</option>
  <option value="referral">Référence Client</option>
  <option value="website">Site Web</option>
  <option value="event">Événement/Salon</option>
  <option value="cold-email">Cold Email</option>
  <option value="partner">Partenaire</option>
  <option value="other">Autre</option>
</selection>
```

### 1.2 Création via API REST

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "data": {
      "name": "Projet IA Prédictive - Retail Corp",
      "firstName": "Marie",
      "lastName": "Dupont",
      "emailAddress": {
        "address": "marie.dupont@retailcorp.com"
      },
      "mobilePhone": "+33612345678",
      "enterpriseName": "Retail Corp",
      "industrySector": {
        "id": 3
      },
      "user": {
        "id": 1
      },
      "attrs": {
        "niveauMaturiteIA": "intermediaire",
        "budgetIA": 75000.00,
        "stackTechnique": "Python, Pandas, Azure ML",
        "infrastructureType": "cloud-azure",
        "casUsageIA": "Prédiction demande produits, Recommandation clients, Détection fraude",
        "urgenceProjet": "haute",
        "dateLancement": "2025-12-01",
        "sourceProspection": "linkedin"
      }
    }
  }'
```

### 1.3 Requêtes SQL Custom Fields

```sql
-- Leads par niveau maturité IA
SELECT
  l.attrs->>'niveauMaturiteIA' AS niveau_maturite,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen,
  SUM(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS budget_total
FROM crm_lead l
WHERE l.attrs ? 'niveauMaturiteIA'
  AND l.status_select IN (1, 2)  -- New, Qualified
GROUP BY l.attrs->>'niveauMaturiteIA'
ORDER BY budget_total DESC;

-- Leads chauds (score ≥ 70)
SELECT
  l.id,
  l.name,
  l.enterprise_name,
  CAST(l.attrs->>'leadScoringIA' AS INTEGER) AS score,
  l.attrs->>'niveauMaturiteIA' AS maturite,
  CAST(l.attrs->>'budgetIA' AS DECIMAL) AS budget,
  l.attrs->>'urgenceProjet' AS urgence
FROM crm_lead l
WHERE CAST(l.attrs->>'leadScoringIA' AS INTEGER) >= 70
  AND l.status_select = 2  -- Qualified
ORDER BY l.attrs->>'leadScoringIA' DESC, budget DESC;

-- Matrice maturité × urgence
SELECT
  l.attrs->>'niveauMaturiteIA' AS maturite,
  l.attrs->>'urgenceProjet' AS urgence,
  COUNT(*) AS nb_leads,
  AVG(CAST(l.attrs->>'leadScoringIA' AS INTEGER)) AS score_moyen
FROM crm_lead l
WHERE l.attrs ? 'niveauMaturiteIA'
  AND l.attrs ? 'urgenceProjet'
GROUP BY l.attrs->>'niveauMaturiteIA', l.attrs->>'urgenceProjet'
ORDER BY maturite, urgence;

-- Pipeline par stack technique
SELECT
  l.attrs->>'stackTechnique' AS stack,
  COUNT(*) AS nb_leads,
  SUM(CAST(l.attrs->>'budgetIA' AS DECIMAL)) AS pipeline_value
FROM crm_lead l
WHERE l.attrs->>'stackTechnique' IS NOT NULL
  AND l.status_select IN (1, 2)
GROUP BY l.attrs->>'stackTechnique'
ORDER BY pipeline_value DESC;
```

---

## 2. Custom Fields - Opportunity

### 2.1 Configuration Studio

**Table**: `crm_opportunity`
**Storage**: JSON column `attrs`

```xml
<!-- Champs spécifiques Opportunity IA -->
<field name="typeServiceIA" type="string" selection="selection-service-ia"
       title="Type Service IA" required="true" />
<field name="complexiteProjet" type="string" selection="selection-complexite"
       title="Complexité Projet" />
<field name="dureeEstimee" type="integer" title="Durée Estimée (jours)" />
<field name="modaliteTarification" type="string" selection="selection-tarification"
       title="Modalité Tarification" />
<field name="techStack" type="string" title="Technologies Proposées"
       multiline="true" />
<field name="ressourcesInternes" type="integer" title="Nb Ressources Internes" />
<field name="partnersExterne" type="boolean" title="Partenaires Externes Requis" />
<field name="milestones" type="text" title="Milestones Projet"
       multiline="true" />
<field name="risquesIdentifies" type="text" title="Risques Identifiés"
       multiline="true" />
<field name="kpis" type="text" title="KPIs Mesure Succès"
       multiline="true" />
```

#### Selections Opportunity

```xml
<selection name="selection-service-ia">
  <option value="ml-custom">Modèle ML/DL Sur Mesure</option>
  <option value="poc">POC Intelligence Artificielle</option>
  <option value="chatbot">Chatbot / Assistant Virtuel</option>
  <option value="computer-vision">Computer Vision</option>
  <option value="nlp">NLP / Text Analytics</option>
  <option value="integration">Intégration IA Existante</option>
  <option value="conseil">Conseil & Audit Maturité IA</option>
  <option value="formation">Formation Équipe IA</option>
</selection>

<selection name="selection-complexite">
  <option value="simple">Simple (1-2 mois)</option>
  <option value="medium">Moyenne (3-6 mois)</option>
  <option value="complex">Complexe (6-12 mois)</option>
  <option value="strategic">Stratégique (> 12 mois)</option>
</selection>

<selection name="selection-tarification">
  <option value="forfait">Forfait</option>
  <option value="regie">Régie (jours/homme)</option>
  <option value="abonnement">Abonnement Mensuel</option>
  <option value="success-fee">Success Fee</option>
  <option value="hybride">Hybride</option>
</selection>
```

### 2.2 Création Opportunity depuis Lead

**Action XML** (Conversion automatique):
```xml
<!-- File: modules/axelor-crm/src/main/resources/views/Lead.xml -->

<action-record name="action-lead-convert-to-opportunity"
               model="com.axelor.apps.crm.db.Opportunity">
  <field name="name" expr="eval: lead.name"/>
  <field name="partner" expr="eval: lead.partner"/>
  <field name="user" expr="eval: lead.user"/>
  <field name="team" expr="eval: lead.team"/>
  <field name="expectedCloseDate" expr="eval: lead.attrs?.dateLancement"/>
  <field name="amount" expr="eval: lead.attrs?.budgetIA"/>
  <field name="source" expr="eval: lead.source"/>
  <field name="description" expr="eval: lead.description"/>

  <!-- Copy AI-specific fields -->
  <field name="attrs" expr="eval: [
    'typeServiceIA': determineServiceType(lead.attrs?.casUsageIA),
    'complexiteProjet': mapComplexity(lead.attrs?.urgenceProjet),
    'techStack': lead.attrs?.stackTechnique,
    'modaliteTarification': 'forfait'
  ]"/>
</action-record>

<action-method name="action-lead-method-convert">
  <call class="com.axelor.apps.crm.web.LeadController" method="convertLead"/>
</action-method>
```

**Controller Implementation**:
```java
// File: src/main/java/com/axelor/apps/crm/web/LeadController.java

public void convertLead(ActionRequest request, ActionResponse response) {
  Lead lead = request.getContext().asType(Lead.class);
  lead = leadRepository.find(lead.getId());

  // Create Opportunity
  Opportunity opportunity = new Opportunity();
  opportunity.setName(lead.getName());
  opportunity.setPartner(lead.getPartner());
  opportunity.setUser(lead.getUser());

  // Map AI fields
  Map<String, Object> attrs = new HashMap<>();
  attrs.put("typeServiceIA", determineServiceType(lead.getAttrs()));
  attrs.put("complexiteProjet", mapComplexity(lead.getAttrs()));
  attrs.put("techStack", lead.getAttrs().get("stackTechnique"));

  opportunity.setAttrs(attrs);

  opportunityRepository.save(opportunity);

  // Update lead status
  lead.setStatusSelect(3); // Converted
  lead.setOpportunity(opportunity);
  leadRepository.save(lead);

  response.setReload(true);
  response.setFlash("Lead converted to Opportunity");
}

private String determineServiceType(Map<String, Object> leadAttrs) {
  String casUsage = (String) leadAttrs.get("casUsageIA");
  if (casUsage == null) return "ml-custom";

  if (casUsage.toLowerCase().contains("chatbot")) return "chatbot";
  if (casUsage.toLowerCase().contains("vision") || casUsage.contains("image"))
    return "computer-vision";
  if (casUsage.toLowerCase().contains("nlp") || casUsage.contains("text"))
    return "nlp";
  if (casUsage.toLowerCase().contains("poc")) return "poc";

  return "ml-custom";
}
```

---

## 3. Workflows CRM - Agence IA

### 3.1 Workflow : Lead Scoring IA

**Process BPMN**: `lead-scoring-ia.bpmn`

```groovy
// Service Task 1: Calculer Score Lead IA
def lead = execution.getVariable("lead") as com.axelor.apps.crm.db.Lead
def score = 0

// 1. Score Maturité IA (0-40 points)
def maturite = lead.attrs?.niveauMaturiteIA
switch (maturite) {
  case 'expert':
    score += 40
    break
  case 'avance':
    score += 30
    break
  case 'intermediaire':
    score += 20
    break
  case 'debutant':
    score += 10
    break
}

// 2. Score Budget (0-30 points)
def budget = lead.attrs?.budgetIA as BigDecimal
if (budget != null) {
  if (budget >= 100000) score += 30
  else if (budget >= 50000) score += 25
  else if (budget >= 25000) score += 15
  else if (budget >= 10000) score += 5
}

// 3. Score Urgence (0-20 points)
def urgence = lead.attrs?.urgenceProjet
switch (urgence) {
  case 'critique':
    score += 20
    break
  case 'haute':
    score += 15
    break
  case 'moyenne':
    score += 10
    break
  case 'faible':
    score += 5
    break
}

// 4. Score Source (0-10 points)
def source = lead.attrs?.sourceProspection
switch (source) {
  case 'referral':
    score += 10
    break
  case 'partner':
    score += 8
    break
  case 'event':
    score += 6
    break
  case 'linkedin':
  case 'website':
    score += 4
    break
  case 'cold-email':
    score += 2
    break
}

// Mise à jour Lead
lead.attrs = lead.attrs ?: [:]
lead.attrs['leadScoringIA'] = score
lead.save()

// Variables workflow
execution.setVariable('leadScore', score)
execution.setVariable('isHotLead', score >= 70)
execution.setVariable('isColdLead', score < 40)

__log__.info("Lead #{lead.id} - Score calculé: ${score}")
```

**Gateway Exclusif** (Routing par score):
```
Condition 1: ${leadScore >= 70}
  → Hot Lead Path (Assignation commerciale immédiate)

Condition 2: ${leadScore >= 40 && leadScore < 70}
  → Warm Lead Path (Relance automatique + 3 jours)

Condition 3: ${leadScore < 40}
  → Cold Lead Path (Nurturing campaign)
```

### 3.2 Workflow : Hot Lead Auto-Assignment

```groovy
// Service Task: Assigner Lead Chaud au Meilleur Commercial
import com.axelor.apps.base.db.repo.UserRepository
import com.axelor.apps.crm.db.repo.LeadRepository

def leadRepo = __ctx__.getBean(LeadRepository.class)
def userRepo = __ctx__.getBean(UserRepository.class)

def lead = execution.getVariable("lead") as com.axelor.apps.crm.db.Lead

// Trouver commercial avec le moins de leads chauds actifs
def query = """
  SELECT u.id, u.full_name, COUNT(l.id) as lead_count
  FROM auth_user u
  LEFT JOIN crm_lead l ON l.user_id = u.id
    AND CAST(l.attrs->>'leadScoringIA' AS INTEGER) >= 70
    AND l.status_select IN (1, 2)
  WHERE u.active_team = true
    AND EXISTS (
      SELECT 1 FROM auth_user_group ug
      WHERE ug.user_id = u.id
        AND ug.group_code = 'sales'
    )
  GROUP BY u.id, u.full_name
  ORDER BY lead_count ASC, RANDOM()
  LIMIT 1
"""

def result = __em__.createNativeQuery(query).getSingleResult()
def bestUserId = result[0] as Long

def assignedUser = userRepo.find(bestUserId)
lead.setUser(assignedUser)
lead.setTeam(assignedUser.getActiveTeam())
leadRepo.save(lead)

execution.setVariable('assignedUserId', bestUserId)
execution.setVariable('assignedUserName', assignedUser.getFullName())

__log__.info("Lead #{lead.id} assigné à ${assignedUser.fullName}")
```

**Send Email Notification** (Service Task):
```groovy
// Service Task: Notifier Commercial Lead Chaud
import com.axelor.apps.message.db.Message
import com.axelor.apps.message.db.repo.MessageRepository

def messageRepo = __ctx__.getBean(MessageRepository.class)
def lead = execution.getVariable("lead")
def score = execution.getVariable("leadScore")

def message = new Message()
message.setSubject("🔥 Nouveau Lead Chaud : ${lead.name}")
message.setContent("""
Bonjour ${lead.user.fullName},

Un nouveau lead à fort potentiel vous a été assigné :

📊 Score Lead IA : ${score}/100
🏢 Entreprise : ${lead.enterpriseName}
👤 Contact : ${lead.firstName} ${lead.lastName}
💰 Budget : ${lead.attrs?.budgetIA ?: 'N/A'} €
🎯 Maturité IA : ${lead.attrs?.niveauMaturiteIA}
⚡ Urgence : ${lead.attrs?.urgenceProjet}

Cas d'usage souhaités :
${lead.attrs?.casUsageIA}

Action requise : Contacter sous 24h

Accéder au lead : ${__config__.get('application.url')}/crm/lead/${lead.id}

Bonne vente !
""")

message.setToEmailAddressSet([lead.user.email])
message.setStatusSelect(1) // Ready to send
messageRepo.save(message)

__log__.info("Email notification envoyée à ${lead.user.email}")
```

### 3.3 Workflow : Relance Automatique Lead

**Timer Event** (Tous les lundis 9h):
```
Timer Definition: R/0 0 9 ? * MON
```

```groovy
// Service Task: Identifier Leads à Relancer
import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository

def leadRepo = __ctx__.getBean(LeadRepository.class)

// Leads qualifiés sans activité depuis 7 jours
def leads = leadRepo.all()
  .filter("self.statusSelect = 2 AND self.lastActivity < ?", __date__.minusDays(7))
  .fetch()

leads.each { lead ->
  // Créer tâche de relance
  def task = new com.axelor.apps.crm.db.Task()
  task.setName("Relancer ${lead.name}")
  task.setTaskDate(__date__.plusDays(1))
  task.setTypeSelect("call")
  task.setUser(lead.user)
  task.setLead(lead)
  task.setPrioritySelect(2) // Medium

  task.save()

  __log__.info("Tâche de relance créée pour Lead #{lead.id}")
}

execution.setVariable('leadsToFollowUp', leads.size())
```

---

## 4. Vues et Dashboards CRM

### 4.1 Vue Kanban - Pipeline IA

**Configuration Vue** (via Studio):
```xml
<!-- File: modules/axelor-crm/src/main/resources/views/Opportunity.xml -->

<kanban name="opportunity-kanban-ia" title="Pipeline IA"
        model="com.axelor.apps.crm.db.Opportunity"
        columnBy="salesStageSelect"
        sequenceBy="sequence">

  <field name="name"/>
  <field name="partner"/>
  <field name="amount"/>
  <field name="expectedCloseDate"/>
  <field name="attrs"/>

  <template><![CDATA[
    <div class="card-body">
      <h5>{{name}}</h5>
      <span class="badge badge-info">{{attrs.typeServiceIA}}</span>
      <hr/>
      <div class="row">
        <div class="col-6">
          <small>Montant</small><br/>
          <strong>{{amount | currency}}</strong>
        </div>
        <div class="col-6">
          <small>Clôture</small><br/>
          <strong>{{expectedCloseDate | date}}</strong>
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-12">
          <small>Complexité: {{attrs.complexiteProjet}}</small><br/>
          <small>Durée: {{attrs.dureeEstimee}} jours</small>
        </div>
      </div>
    </div>
  ]]></template>
</kanban>
```

### 4.2 Dashboard - Leads IA

```xml
<!-- File: modules/axelor-crm/src/main/resources/views/Dashboard.xml -->

<dashboard name="dashboard-leads-ia" title="Dashboard Leads IA">

  <!-- KPI Cards -->
  <dashlet name="dashlet-leads-total" title="Total Leads" action="action-leads-count">
    <dataset type="sql">
      SELECT COUNT(*) as count FROM crm_lead WHERE status_select IN (1,2)
    </dataset>
  </dashlet>

  <dashlet name="dashlet-leads-hot" title="Leads Chauds (≥70)" action="action-leads-hot">
    <dataset type="sql">
      SELECT COUNT(*) as count FROM crm_lead
      WHERE CAST(attrs->>'leadScoringIA' AS INTEGER) >= 70
        AND status_select = 2
    </dataset>
  </dashlet>

  <dashlet name="dashlet-pipeline-value" title="Pipeline Value" colspan="2">
    <dataset type="sql">
      SELECT SUM(CAST(attrs->>'budgetIA' AS DECIMAL)) as total
      FROM crm_lead WHERE status_select IN (1,2)
    </dataset>
  </dashlet>

  <!-- Chart: Leads par Maturité IA -->
  <dashlet name="dashlet-leads-maturite" title="Leads par Maturité IA" colspan="6">
    <dataset type="rpc">
      com.axelor.apps.crm.web.DashboardController:getLeadsByMaturity
    </dataset>
    <chart type="pie" stacked="false">
      <category key="maturite" type="text"/>
      <series key="count" type="number"/>
    </chart>
  </dashlet>

  <!-- Chart: Pipeline par Service IA -->
  <dashlet name="dashlet-pipeline-service" title="Pipeline par Service IA" colspan="6">
    <dataset type="sql">
      SELECT
        COALESCE(o.attrs->>'typeServiceIA', 'Non défini') as service,
        COUNT(*) as count,
        SUM(o.amount) as total_amount
      FROM crm_opportunity o
      WHERE o.sales_stage_select IN (1,2,3,4,5)
      GROUP BY o.attrs->>'typeServiceIA'
    </dataset>
    <chart type="bar" stacked="false">
      <category key="service" type="text"/>
      <series key="total_amount" type="number" title="Montant"/>
    </chart>
  </dashlet>

  <!-- Table: Top 10 Leads Chauds -->
  <dashlet name="dashlet-top-leads" title="Top 10 Leads Chauds" colspan="12" action="action-view-lead">
    <dataset type="sql">
      SELECT
        l.id,
        l.name,
        l.enterprise_name as company,
        CAST(l.attrs->>'leadScoringIA' AS INTEGER) as score,
        CAST(l.attrs->>'budgetIA' AS DECIMAL) as budget,
        l.attrs->>'niveauMaturiteIA' as maturite
      FROM crm_lead l
      WHERE l.status_select = 2
        AND CAST(l.attrs->>'leadScoringIA' AS INTEGER) >= 70
      ORDER BY score DESC, budget DESC
      LIMIT 10
    </dataset>
  </dashlet>

</dashboard>
```

**Dashboard Controller** (RPC Dataset):
```java
// File: src/main/java/com/axelor/apps/crm/web/DashboardController.java

public void getLeadsByMaturity(ActionRequest request, ActionResponse response) {
  String sql = """
    SELECT
      l.attrs->>'niveauMaturiteIA' as maturite,
      COUNT(*) as count
    FROM crm_lead l
    WHERE l.attrs ? 'niveauMaturiteIA'
      AND l.status_select IN (1, 2)
    GROUP BY l.attrs->>'niveauMaturiteIA'
  """;

  List<Map<String, Object>> results = new ArrayList<>();
  Query query = JPA.em().createNativeQuery(sql);

  for (Object[] row : (List<Object[]>) query.getResultList()) {
    Map<String, Object> map = new HashMap<>();
    map.put("maturite", translateMaturity((String) row[0]));
    map.put("count", ((Number) row[1]).intValue());
    results.add(map);
  }

  response.setData(results);
}

private String translateMaturity(String level) {
  switch (level) {
    case "debutant": return "Débutant";
    case "intermediaire": return "Intermédiaire";
    case "avance": return "Avancé";
    case "expert": return "Expert";
    default: return level;
  }
}
```

---

## 5. Catalogue Services IA

### 5.1 Configuration Produits/Services

**Table**: `sale_product`
**Catégorie**: Services IA

```xml
<!-- Products Configuration -->
<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-ML-CUSTOM</field>
  <field name="name">Modèle ML/DL Sur Mesure</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">15000.00</field>
  <field name="unit" ref="unit-days"/>
  <field name="description"><![CDATA[
    Développement de modèles Machine Learning ou Deep Learning personnalisés :
    - Analyse besoins et données
    - Feature engineering
    - Entraînement modèle
    - Validation et tuning
    - Déploiement production
    - Documentation technique

    Livrable : Modèle entraîné + API + Documentation
    Durée typique : 2-4 mois
  ]]></field>
</record>

<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-POC-IA</field>
  <field name="name">POC Intelligence Artificielle</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">8000.00</field>
  <field name="description"><![CDATA[
    Proof of Concept rapide pour valider faisabilité technique :
    - Workshop cadrage (1 jour)
    - Analyse données
    - Prototype fonctionnel
    - Rapport faisabilité

    Livrable : Prototype + Rapport + Roadmap
    Durée : 3-6 semaines
  ]]></field>
</record>

<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-CHATBOT</field>
  <field name="name">Chatbot / Assistant Virtuel</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">12000.00</field>
  <field name="description"><![CDATA[
    Développement chatbot conversationnel :
    - Design conversations
    - Entraînement NLU
    - Intégrations (Slack, Teams, Web)
    - Tableau de bord analytics

    Livrable : Chatbot opérationnel + Dashboard
    Durée : 1-3 mois
  ]]></field>
</record>

<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-COMPUTER-VISION</field>
  <field name="name">Computer Vision</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">18000.00</field>
  <field name="description"><![CDATA[
    Solutions Computer Vision :
    - Détection objets
    - Classification images
    - Segmentation
    - OCR avancé
    - Reconnaissance faciale

    Livrable : Modèle + API + Interface
    Durée : 2-4 mois
  ]]></field>
</record>

<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-NLP</field>
  <field name="name">NLP / Text Analytics</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">14000.00</field>
  <field name="description"><![CDATA[
    Analyse et traitement du langage naturel :
    - Analyse sentiment
    - Classification texte
    - Extraction entités
    - Résumé automatique
    - Traduction

    Livrable : Pipeline NLP + API
    Durée : 2-3 mois
  ]]></field>
</record>

<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SVC-CONSEIL-IA</field>
  <field name="name">Conseil & Audit Maturité IA</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">5000.00</field>
  <field name="description"><![CDATA[
    Audit maturité IA et roadmap stratégique :
    - Évaluation maturité IA
    - Analyse données existantes
    - Identification cas d'usage
    - Roadmap priorisation
    - Estimation ROI

    Livrable : Rapport audit + Roadmap IA
    Durée : 2-4 semaines
  ]]></field>
</record>
```

### 5.2 Configurateur Devis Automatique

**Action Method** (Generate Quote from Opportunity):
```java
// File: src/main/java/com/axelor/apps/crm/web/OpportunityController.java

public void generateQuote(ActionRequest request, ActionResponse response) {
  Opportunity opportunity = request.getContext().asType(Opportunity.class);
  opportunity = opportunityRepository.find(opportunity.getId());

  // Create Sale Order
  SaleOrder saleOrder = new SaleOrder();
  saleOrder.setClientPartner(opportunity.getPartner());
  saleOrder.setUser(opportunity.getUser());

  // Map service IA to product
  String typeServiceIA = (String) opportunity.getAttrs().get("typeServiceIA");
  Product product = productRepository.findByCode(mapServiceToProductCode(typeServiceIA));

  if (product != null) {
    SaleOrderLine line = new SaleOrderLine();
    line.setProduct(product);
    line.setProductName(product.getName());
    line.setQty(BigDecimal.ONE);
    line.setPrice(product.getSalePrice());

    // Adjust price based on complexity
    String complexite = (String) opportunity.getAttrs().get("complexiteProjet");
    BigDecimal multiplier = getComplexityMultiplier(complexite);
    line.setPrice(line.getPrice().multiply(multiplier));

    saleOrder.addSaleOrderLineListItem(line);
  }

  saleOrderRepository.save(saleOrder);

  response.setView(ActionView
    .define("Devis")
    .model(SaleOrder.class.getName())
    .add("form", "sale-order-form")
    .context("_showRecord", saleOrder.getId())
    .map());
}

private String mapServiceToProductCode(String typeServiceIA) {
  switch (typeServiceIA) {
    case "ml-custom": return "SVC-ML-CUSTOM";
    case "poc": return "SVC-POC-IA";
    case "chatbot": return "SVC-CHATBOT";
    case "computer-vision": return "SVC-COMPUTER-VISION";
    case "nlp": return "SVC-NLP";
    case "conseil": return "SVC-CONSEIL-IA";
    default: return "SVC-ML-CUSTOM";
  }
}

private BigDecimal getComplexityMultiplier(String complexite) {
  switch (complexite) {
    case "simple": return new BigDecimal("1.0");
    case "medium": return new BigDecimal("1.5");
    case "complex": return new BigDecimal("2.0");
    case "strategic": return new BigDecimal("3.0");
    default: return BigDecimal.ONE;
  }
}
```

---

## 6. Intégrations CRM Spécifiques

### 6.1 LinkedIn Lead Sync

**Configuration Connector**:
```properties
# application.properties
linkedin.client-id = your_linkedin_client_id
linkedin.client-secret = your_linkedin_client_secret
linkedin.redirect-uri = http://localhost:8080/oauth/linkedin/callback
linkedin.sync.enabled = true
linkedin.sync.cron = 0 0 */4 * * ?  # Every 4 hours
```

**LinkedIn API Service**:
```java
// File: src/main/java/com/axelor/apps/crm/service/LinkedInService.java

public class LinkedInService {

  @Inject private HttpClient httpClient;
  @Inject private LeadRepository leadRepository;

  public void syncLeadsFromLinkedIn() throws Exception {
    String accessToken = getAccessToken();

    HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("https://api.linkedin.com/v2/leadForms"))
      .header("Authorization", "Bearer " + accessToken)
      .GET()
      .build();

    HttpResponse<String> response = httpClient.send(
      request,
      HttpResponse.BodyHandlers.ofString()
    );

    LinkedInLeadResponse leads = objectMapper.readValue(
      response.body(),
      LinkedInLeadResponse.class
    );

    for (LinkedInLead linkedInLead : leads.getElements()) {
      Lead lead = leadRepository.findByExternalId("LINKEDIN-" + linkedInLead.getId());

      if (lead == null) {
        lead = new Lead();
        lead.setExternalId("LINKEDIN-" + linkedInLead.getId());
        lead.setSource(sourceRepository.findByCode("LINKEDIN"));
      }

      lead.setName(linkedInLead.getCompany());
      lead.setFirstName(linkedInLead.getFirstName());
      lead.setLastName(linkedInLead.getLastName());
      lead.setEmailAddress(linkedInLead.getEmail());

      // Map LinkedIn fields to AI fields
      Map<String, Object> attrs = new HashMap<>();
      attrs.put("sourceProspection", "linkedin");
      lead.setAttrs(attrs);

      leadRepository.save(lead);
    }
  }
}
```

### 6.2 Email Integration (Gmail)

**Gmail Sync Workflow** (BPM):
```groovy
// Service Task: Sync Gmail Leads
import com.google.api.services.gmail.Gmail
import com.google.api.services.gmail.model.Message

def gmailService = __ctx__.getBean(Gmail.class)
def leadRepo = __ctx__.getBean(LeadRepository.class)

def messages = gmailService.users().messages()
  .list("me")
  .setQ("label:leads is:unread")
  .execute()

messages.getMessages()?.each { msgRef ->
  def message = gmailService.users().messages()
    .get("me", msgRef.getId())
    .execute()

  // Parse email
  def from = message.getPayload().getHeaders()
    .find { it.getName() == "From" }?.getValue()
  def subject = message.getPayload().getHeaders()
    .find { it.getName() == "Subject" }?.getValue()

  // Create Lead
  def lead = new Lead()
  lead.setName(subject)
  lead.setEmailAddress(parseEmail(from))
  lead.setDescription(message.getSnippet())
  lead.setSource(sourceRepository.findByCode("EMAIL"))

  leadRepo.save(lead)

  // Mark as read
  gmailService.users().messages()
    .modify("me", msgRef.getId(), new ModifyMessageRequest()
      .setRemoveLabelIds(["UNREAD"]))
    .execute()
}
```

---

## 7. Reports et Analytics

### 7.1 Report SQL : Funnel de Conversion

```sql
-- Funnel de conversion Lead → Opportunity → Won
WITH funnel AS (
  SELECT
    'Leads' AS stage,
    1 AS stage_order,
    COUNT(*) AS count,
    SUM(CAST(attrs->>'budgetIA' AS DECIMAL)) AS value
  FROM crm_lead
  WHERE created_on >= CURRENT_DATE - INTERVAL '30 days'

  UNION ALL

  SELECT
    'Qualified' AS stage,
    2 AS stage_order,
    COUNT(*) AS count,
    SUM(CAST(attrs->>'budgetIA' AS DECIMAL)) AS value
  FROM crm_lead
  WHERE status_select = 2
    AND created_on >= CURRENT_DATE - INTERVAL '30 days'

  UNION ALL

  SELECT
    'Opportunities' AS stage,
    3 AS stage_order,
    COUNT(*) AS count,
    SUM(amount) AS value
  FROM crm_opportunity
  WHERE created_on >= CURRENT_DATE - INTERVAL '30 days'

  UNION ALL

  SELECT
    'Won' AS stage,
    4 AS stage_order,
    COUNT(*) AS count,
    SUM(amount) AS value
  FROM crm_opportunity
  WHERE sales_stage_select = 6  -- Closed Won
    AND created_on >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT
  stage,
  count,
  value,
  ROUND(100.0 * count / LAG(count) OVER (ORDER BY stage_order), 2) AS conversion_rate
FROM funnel
ORDER BY stage_order;
```

### 7.2 Report : Performance Commerciale IA

```sql
-- Performance par commercial (services IA)
SELECT
  u.full_name AS commercial,
  COUNT(DISTINCT l.id) AS nb_leads,
  COUNT(DISTINCT o.id) AS nb_opportunities,
  COUNT(DISTINCT CASE WHEN o.sales_stage_select = 6 THEN o.id END) AS nb_won,
  SUM(CASE WHEN o.sales_stage_select = 6 THEN o.amount ELSE 0 END) AS ca_realise,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN o.sales_stage_select = 6 THEN o.id END)
    / NULLIF(COUNT(DISTINCT o.id), 0),
    2
  ) AS taux_conversion,
  AVG(CAST(l.attrs->>'leadScoringIA' AS INTEGER)) AS score_moyen_leads
FROM auth_user u
LEFT JOIN crm_lead l ON l.user_id = u.id
  AND l.created_on >= CURRENT_DATE - INTERVAL '90 days'
LEFT JOIN crm_opportunity o ON o.user_id = u.id
  AND o.created_on >= CURRENT_DATE - INTERVAL '90 days'
WHERE u.active_team = true
GROUP BY u.id, u.full_name
ORDER BY ca_realise DESC;
```

---

## 8. Best Practices - CRM Agence IA

### 8.1 Qualification Lead

**Checklist Qualification**:
- [ ] Niveau maturité IA identifié
- [ ] Budget estimé renseigné (± 30%)
- [ ] Cas d'usage IA clairs et réalistes
- [ ] Urgence projet établie
- [ ] Décideur identifié et contactable
- [ ] Stack technique client documenté
- [ ] Infrastructure compatible validée

**Score Minimum Qualification** : 40/100

### 8.2 Conversion Lead → Opportunity

**Critères Conversion**:
- Score Lead ≥ 50
- Budget confirmé ≥ 10 000 €
- Cas d'usage technique validé (faisabilité)
- Décision < 6 mois

**Actions Post-Conversion**:
1. Créer devis automatique
2. Planifier démo technique
3. Préparer étude de cas similaires
4. Assigner chef de projet technique

### 8.3 Naming Conventions

```
Leads:
  Format: [Type IA] - [Entreprise] - [Mois/Année]
  Exemple: "Chatbot - Retail Corp - 10/2025"

Opportunities:
  Format: [Service] - [Client] - [Montant]k
  Exemple: "ML Custom - Retail Corp - 75k"

Tasks:
  Format: [Action] - [Lead/Opp Name]
  Exemple: "Appel Relance - Chatbot - Retail Corp"
```

---

**End of Knowledge Base**
