# Knowledge Base : Sales Customization (Agence IA)

**Type** : Pure Technical Reference (no agent narrative)
**Version Axelor** : 8.3.15 / AOP 7.4
**Scope** : Sales custom fields, pricing models, contracts, billing for AI Agency
**Usage** : Accessed dynamically by routing agents

---

## 1. Custom Fields - Sale Order

### 1.1 Configuration Studio

**Table**: `sale_sale_order`
**Storage**: JSON column `attrs`

```xml
<!-- Champs spécifiques Commande IA -->
<field name="modeFacturation" type="string" selection="selection-facturation"
       title="Mode Facturation" required="true" />
<field name="prixJourHomme" type="decimal" title="Prix Jour/Homme (€)"
       precision="20" scale="2" showIf="modeFacturation == 'regie'" />
<field name="tjmMoyen" type="decimal" title="TJM Moyen (€)" readonly="true" />
<field name="nbJoursEstimes" type="integer" title="Nb Jours Estimés" />
<field name="contractType" type="string" selection="selection-contract-type"
       title="Type Contrat" />
<field name="ndaSigned" type="boolean" title="NDA Signé" />
<field name="ndaDate" type="date" title="Date Signature NDA"
       showIf="ndaSigned == true" />
<field name="proprieteIntellectuelle" type="string"
       selection="selection-ip-ownership" title="Propriété Intellectuelle" />
<field name="slaType" type="string" selection="selection-sla"
       title="SLA / Support" />
<field name="garantieResultats" type="boolean" title="Garantie Résultats" />
<field name="penaliteRetard" type="boolean" title="Pénalités de Retard" />
<field name="clauseReversibilite" type="boolean" title="Clause Réversibilité" />
<field name="maintenanceInclude" type="boolean" title="Maintenance Incluse" />
<field name="dureeMaintenance" type="integer" title="Durée Maintenance (mois)"
       showIf="maintenanceInclude == true" />
```

#### Selections

```xml
<selection name="selection-facturation">
  <option value="forfait">Forfait</option>
  <option value="regie">Régie (Jours/Homme)</option>
  <option value="abonnement">Abonnement Mensuel</option>
  <option value="success-fee">Success Fee</option>
  <option value="hybride">Hybride (Forfait + Régie)</option>
</selection>

<selection name="selection-contract-type">
  <option value="service-contract">Contrat de Service</option>
  <option value="license">Licence Logicielle</option>
  <option value="saas">SaaS</option>
  <option value="framework">Contrat-Cadre</option>
  <option value="rnd">R&D Collaboratif</option>
</selection>

<selection name="selection-ip-ownership">
  <option value="client">Client (100%)</option>
  <option value="agency">Agence (100%)</option>
  <option value="shared">Partagée</option>
  <option value="license-exclusive">Licence Exclusive Client</option>
  <option value="license-non-exclusive">Licence Non-Exclusive</option>
</selection>

<selection name="selection-sla">
  <option value="none">Aucun</option>
  <option value="standard">Standard (5j/7, 9h-18h)</option>
  <option value="business-critical">Business Critical (7j/7, 9h-21h)</option>
  <option value="24-7">24/7</option>
</selection>
```

### 1.2 Création Commande via API

```bash
curl -X POST http://localhost:8080/ws/rest/com.axelor.apps.sale.db.SaleOrder \
  -H "Content-Type: application/json" \
  -H "Cookie: JSESSIONID=xxx" \
  -d '{
    "data": {
      "clientPartner": {"id": 5},
      "user": {"id": 1},
      "orderDate": "2025-10-15",
      "expectedRealisationDate": "2026-01-15",
      "statusSelect": 1,
      "attrs": {
        "modeFacturation": "forfait",
        "nbJoursEstimes": 60,
        "contractType": "service-contract",
        "ndaSigned": true,
        "ndaDate": "2025-10-01",
        "proprieteIntellectuelle": "client",
        "slaType": "standard",
        "garantieResultats": false,
        "maintenanceInclude": true,
        "dureeMaintenance": 12
      },
      "saleOrderLineList": [
        {
          "product": {"id": 10},
          "productName": "Modèle ML/DL Sur Mesure",
          "qty": 1,
          "price": 75000.00,
          "unit": {"id": 1}
        }
      ]
    }
  }'
```

---

## 2. Pricing Models - Agence IA

### 2.1 Forfait (Fixed Price)

**Use case**: Projets scope défini, livrables clairs

**Configuration**:
```java
// File: src/main/java/com/axelor/apps/sale/service/SaleOrderPricingService.java

public BigDecimal calculateForfaitPrice(SaleOrder saleOrder) {
  BigDecimal basePrice = BigDecimal.ZERO;

  // Base price from product catalog
  for (SaleOrderLine line : saleOrder.getSaleOrderLineList()) {
    basePrice = basePrice.add(
      line.getPrice().multiply(line.getQty())
    );
  }

  // Complexity multiplier (from opportunity)
  String complexite = (String) saleOrder.getAttrs().get("complexiteProjet");
  BigDecimal multiplier = getComplexityMultiplier(complexite);

  // Risk buffer (10-30% based on uncertainty)
  BigDecimal riskBuffer = basePrice.multiply(getRiskFactor(saleOrder));

  return basePrice.multiply(multiplier).add(riskBuffer);
}

private BigDecimal getRiskFactor(SaleOrder saleOrder) {
  // Low risk: well-defined, standard tech
  // High risk: R&D, bleeding-edge tech, vague requirements
  String typeService = (String) saleOrder.getAttrs().get("typeServiceIA");

  switch (typeService) {
    case "poc":
      return new BigDecimal("0.10"); // 10% buffer
    case "chatbot":
    case "integration":
      return new BigDecimal("0.15"); // 15% buffer
    case "ml-custom":
    case "computer-vision":
      return new BigDecimal("0.25"); // 25% buffer
    case "nlp":
      return new BigDecimal("0.30"); // 30% buffer
    default:
      return new BigDecimal("0.20");
  }
}
```

**Invoice Schedule** (Milestones):
```xml
<!-- Milestone 1: Kickoff (20%) -->
<record model="com.axelor.apps.account.db.Invoice">
  <field name="operationTypeSelect">3</field>
  <field name="partner" ref="partner-retail-corp"/>
  <field name="invoiceDate">2025-10-15</field>
  <field name="dueDate">2025-11-15</field>
  <field name="description">Milestone 1 : Démarrage Projet (20%)</field>
  <field name="exTaxTotal">15000.00</field>
</record>

<!-- Milestone 2: POC Validated (30%) -->
<record model="com.axelor.apps.account.db.Invoice">
  <field name="description">Milestone 2 : POC Validé (30%)</field>
  <field name="exTaxTotal">22500.00</field>
</record>

<!-- Milestone 3: MVP Delivered (30%) -->
<record model="com.axelor.apps.account.db.Invoice">
  <field name="description">Milestone 3 : MVP Livré (30%)</field>
  <field name="exTaxTotal">22500.00</field>
</record>

<!-- Milestone 4: Production (20%) -->
<record model="com.axelor.apps.account.db.Invoice">
  <field name="description">Milestone 4 : Mise en Production (20%)</field>
  <field name="exTaxTotal">15000.00</field>
</record>
```

### 2.2 Régie (Time & Materials)

**Use case**: Scope évolutif, augmentation d'équipe

**Configuration**:
```java
public BigDecimal calculateRegiePrice(SaleOrder saleOrder) {
  Integer nbJours = (Integer) saleOrder.getAttrs().get("nbJoursEstimes");
  BigDecimal tjm = (BigDecimal) saleOrder.getAttrs().get("prixJourHomme");

  if (nbJours == null || tjm == null) {
    throw new AxelorException("Nombre de jours et TJM requis pour mode Régie");
  }

  // Volume discount
  BigDecimal discount = BigDecimal.ONE;
  if (nbJours > 100) discount = new BigDecimal("0.90"); // -10%
  if (nbJours > 200) discount = new BigDecimal("0.85"); // -15%

  return tjm.multiply(new BigDecimal(nbJours)).multiply(discount);
}
```

**Timesheet Integration** (Track actual days):
```groovy
// BPM Workflow: Monthly Invoicing (Régie)
// Timer Event: 1st day of month

import com.axelor.apps.hr.db.Timesheet
import com.axelor.apps.hr.db.repo.TimesheetRepository
import com.axelor.apps.account.db.Invoice

def timesheetRepo = __ctx__.getBean(TimesheetRepository.class)
def saleOrder = execution.getVariable("saleOrder")

// Get timesheets for last month
def lastMonth = __date__.minusMonths(1)
def timesheets = timesheetRepo.all()
  .filter("self.saleOrder = ? AND self.period = ?", saleOrder, lastMonth)
  .fetch()

def totalDays = timesheets.sum { it.totalDays } ?: 0
def tjm = saleOrder.attrs?.prixJourHomme as BigDecimal

if (totalDays > 0 && tjm != null) {
  // Create invoice
  def invoice = new Invoice()
  invoice.partner = saleOrder.clientPartner
  invoice.invoiceDate = __date__
  invoice.description = "Régie ${lastMonth.format('MMMM yyyy')} - ${totalDays} jours"
  invoice.exTaxTotal = tjm.multiply(new BigDecimal(totalDays))

  invoice.save()

  execution.setVariable('invoiceCreated', true)
  execution.setVariable('invoiceAmount', invoice.exTaxTotal)
}
```

### 2.3 Abonnement (Subscription)

**Use case**: SaaS, support récurrent, maintenance

**Configuration**:
```xml
<!-- Subscription Product -->
<record model="com.axelor.apps.sale.db.Product">
  <field name="code">SUB-CHATBOT-MONTHLY</field>
  <field name="name">Abonnement Chatbot (Mensuel)</field>
  <field name="productTypeSelect">service</field>
  <field name="salePrice">2500.00</field>
  <field name="isSubscription">true</field>
  <field name="subscriptionDuration">1</field>
  <field name="subscriptionUnit">month</field>
  <field name="description"><![CDATA[
    Abonnement mensuel chatbot incluant :
    - Hébergement & infrastructure
    - Monitoring 24/7
    - Support technique (SLA Standard)
    - Mises à jour mineures
    - 10 000 conversations/mois incluses
    - Rapports analytics mensuels
  ]]></field>
</record>
```

**Recurring Invoice Workflow**:
```groovy
// BPM Timer: Monthly subscription billing
// Cron: 0 0 0 1 * ? (1st day of month, midnight)

import com.axelor.apps.sale.db.SaleOrder
import com.axelor.apps.sale.db.repo.SaleOrderRepository

def saleOrderRepo = __ctx__.getBean(SaleOrderRepository.class)

// Find all active subscriptions
def subscriptions = saleOrderRepo.all()
  .filter("self.attrs->>'modeFacturation' = 'abonnement' AND self.statusSelect = 3")
  .fetch()

subscriptions.each { saleOrder ->
  // Check if invoice already created this month
  def existingInvoice = Invoice.all()
    .filter("self.saleOrder = ? AND MONTH(self.invoiceDate) = ? AND YEAR(self.invoiceDate) = ?",
            saleOrder, __date__.getMonthValue(), __date__.getYear())
    .fetchOne()

  if (existingInvoice == null) {
    // Create monthly invoice
    def invoice = new Invoice()
    invoice.partner = saleOrder.clientPartner
    invoice.saleOrder = saleOrder
    invoice.invoiceDate = __date__
    invoice.dueDate = __date__.plusDays(30)
    invoice.description = "Abonnement ${__date__.format('MMMM yyyy')}"

    // Copy order lines
    saleOrder.saleOrderLineList.each { line ->
      def invoiceLine = new InvoiceLine()
      invoiceLine.product = line.product
      invoiceLine.productName = line.productName
      invoiceLine.qty = line.qty
      invoiceLine.price = line.price
      invoice.addInvoiceLineListItem(invoiceLine)
    }

    invoice.save()

    __log__.info("Facture abonnement créée : SaleOrder #${saleOrder.id}")
  }
}
```

### 2.4 Success Fee

**Use case**: Projets ROI mesurable (ex: prédiction optimisation)

**Configuration**:
```java
public BigDecimal calculateSuccessFee(SaleOrder saleOrder, Map<String, Object> kpiResults) {
  BigDecimal basePrice = (BigDecimal) saleOrder.getAttrs().get("basePriceSuccessFee");
  BigDecimal targetKPI = (BigDecimal) saleOrder.getAttrs().get("targetKPI");
  BigDecimal actualKPI = (BigDecimal) kpiResults.get("actualKPI");

  if (actualKPI == null || targetKPI == null) {
    return basePrice; // Return base price if KPI not measured
  }

  // Calculate achievement percentage
  BigDecimal achievement = actualKPI.divide(targetKPI, 4, RoundingMode.HALF_UP);

  // Tiered success fee
  if (achievement.compareTo(new BigDecimal("1.2")) >= 0) {
    // 120%+ of target: +50% bonus
    return basePrice.multiply(new BigDecimal("1.5"));
  } else if (achievement.compareTo(new BigDecimal("1.0")) >= 0) {
    // 100-120% of target: +30% bonus
    return basePrice.multiply(new BigDecimal("1.3"));
  } else if (achievement.compareTo(new BigDecimal("0.8")) >= 0) {
    // 80-100% of target: base price only
    return basePrice;
  } else {
    // < 80% of target: 50% of base price
    return basePrice.multiply(new BigDecimal("0.5"));
  }
}
```

---

## 3. Contract Management

### 3.1 Contract Templates

**NDA Template** (Confidentiality Agreement):
```xml
<!-- File: templates/contracts/NDA_Template.docx -->
<!-- Variables: ${partner.name}, ${currentDate}, ${project.name} -->

<record model="com.axelor.apps.base.db.PrintTemplate">
  <field name="name">NDA - Accord de Confidentialité</field>
  <field name="templateLink">templates/contracts/NDA_Template.docx</field>
  <field name="metaModel" ref="meta-model-partner"/>
  <field name="language" ref="language-french"/>
</record>
```

**Service Contract Template**:
```xml
<record model="com.axelor.apps.base.db.PrintTemplate">
  <field name="name">Contrat de Service IA</field>
  <field name="templateLink">templates/contracts/Service_Contract_AI.docx</field>
  <field name="metaModel" ref="meta-model-sale-order"/>
  <field name="language" ref="language-french"/>
</record>
```

**Key Contract Clauses** (Agence IA):
```markdown
## Article 1 : Objet du Contrat
Développement de [Type Service IA] pour [Client Name]

## Article 2 : Propriété Intellectuelle
[Option configurée : Client / Agence / Partagée / Licence]

## Article 3 : Confidentialité et Données
- NDA réciproque
- RGPD compliance
- Sécurité données d'entraînement
- Anonymisation si requis

## Article 4 : Garanties et Responsabilités
- Garantie de conformité fonctionnelle : 3 mois
- Garantie biais algorithmiques : Best effort
- Limitation responsabilité : Montant du contrat
- Assurance RC Professionnelle : 2M€

## Article 5 : Livraison et Recette
- Livrables définis en Annexe A
- Procédure de recette : 15 jours
- Critères d'acceptation mesurables (KPIs)

## Article 6 : Maintenance et Support
[Si maintenanceInclude = true]
- Durée : [dureeMaintenance] mois
- SLA : [slaType]
- Mises à jour correctives incluses
- Mises à jour évolutives : devis séparé

## Article 7 : Réversibilité
[Si clauseReversibilite = true]
- Export données : Format ouvert
- Documentation transfert
- Assistance migration : [X] jours
```

### 3.2 Contract Generation Workflow

```groovy
// BPM Service Task: Generate Contract
import com.axelor.apps.base.service.PrintTemplateService

def saleOrder = execution.getVariable("saleOrder")
def printTemplateService = __ctx__.getBean(PrintTemplateService.class)

// Select template based on contract type
def contractType = saleOrder.attrs?.contractType
def templateName = contractType == 'saas'
  ? 'Contrat SaaS IA'
  : 'Contrat de Service IA'

def template = PrintTemplate.all()
  .filter("self.name = ?", templateName)
  .fetchOne()

if (template != null) {
  // Generate contract document
  def contractFile = printTemplateService.generateDocument(template, saleOrder)

  // Attach to sale order
  def dmsFile = new com.axelor.dms.db.DMSFile()
  dmsFile.fileName = "Contrat_${saleOrder.saleOrderSeq}_${__date__.format('yyyyMMdd')}.pdf"
  dmsFile.filePath = contractFile.getAbsolutePath()
  dmsFile.relatedModel = 'com.axelor.apps.sale.db.SaleOrder'
  dmsFile.relatedId = saleOrder.id
  dmsFile.save()

  execution.setVariable('contractGenerated', true)
  execution.setVariable('contractFileId', dmsFile.id)
}
```

### 3.3 E-Signature Integration

**DocuSign Integration**:
```java
// File: src/main/java/com/axelor/apps/sale/service/ESignatureService.java

public class ESignatureService {

  @Inject private HttpClient httpClient;

  public String sendForSignature(SaleOrder saleOrder, DMSFile contract) throws Exception {
    // 1. Upload document to DocuSign
    byte[] documentBytes = Files.readAllBytes(Paths.get(contract.getFilePath()));
    String base64Doc = Base64.getEncoder().encodeToString(documentBytes);

    // 2. Create envelope
    Map<String, Object> envelope = Map.of(
      "emailSubject", "Signature Contrat - " + saleOrder.getSaleOrderSeq(),
      "documents", List.of(Map.of(
        "documentBase64", base64Doc,
        "name", contract.getFileName(),
        "fileExtension", "pdf",
        "documentId", "1"
      )),
      "recipients", Map.of(
        "signers", List.of(
          Map.of(
            "email", saleOrder.getClientPartner().getEmailAddress().getAddress(),
            "name", saleOrder.getClientPartner().getName(),
            "recipientId", "1",
            "tabs", Map.of(
              "signHereTabs", List.of(Map.of(
                "documentId", "1",
                "pageNumber", "5",
                "xPosition", "100",
                "yPosition", "200"
              ))
            )
          )
        )
      ),
      "status", "sent"
    );

    // 3. Send to DocuSign API
    HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("https://demo.docusign.net/restapi/v2.1/accounts/{accountId}/envelopes"))
      .header("Authorization", "Bearer " + getDocuSignToken())
      .header("Content-Type", "application/json")
      .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(envelope)))
      .build();

    HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

    Map<String, Object> result = objectMapper.readValue(response.body(), Map.class);
    return (String) result.get("envelopeId");
  }
}
```

---

## 4. Invoicing - Milestones

### 4.1 Milestone Configuration

**Custom Fields - Sale Order Line**:
```xml
<field name="isMilestone" type="boolean" title="Est un Milestone" />
<field name="milestoneOrder" type="integer" title="Ordre Milestone" />
<field name="milestonePercentage" type="decimal" title="% Total Projet" />
<field name="milestoneDueDate" type="date" title="Date Échéance" />
<field name="milestoneStatus" type="string" selection="selection-milestone-status"
       title="Statut Milestone" />
<field name="milestoneValidatedDate" type="date" title="Date Validation" />
<field name="milestoneValidatedBy" type="many-to-one" ref="auth.User"
       title="Validé par" />
```

```xml
<selection name="selection-milestone-status">
  <option value="pending">En Attente</option>
  <option value="in-progress">En Cours</option>
  <option value="delivered">Livré</option>
  <option value="validated">Validé (Recette OK)</option>
  <option value="invoiced">Facturé</option>
</selection>
```

### 4.2 Milestone Invoicing Workflow

```groovy
// BPM User Task: Validate Milestone Delivery
// Task assigned to: Client Project Manager

def saleOrderLine = execution.getVariable("milestone")

// Wait for client validation
// User completes task with validation = true/false

def validated = execution.getVariable("milestoneValidated") as Boolean

if (validated) {
  saleOrderLine.attrs = saleOrderLine.attrs ?: [:]
  saleOrderLine.attrs['milestoneStatus'] = 'validated'
  saleOrderLine.attrs['milestoneValidatedDate'] = __date__
  saleOrderLine.save()

  // Trigger invoice generation
  execution.setVariable('generateInvoice', true)
} else {
  // Send back to development
  execution.setVariable('requiresRework', true)
}
```

**Auto-Generate Invoice**:
```groovy
// Service Task: Generate Milestone Invoice
def saleOrderLine = execution.getVariable("milestone")
def saleOrder = saleOrderLine.saleOrder

def invoice = new Invoice()
invoice.partner = saleOrder.clientPartner
invoice.saleOrder = saleOrder
invoice.invoiceDate = __date__
invoice.dueDate = __date__.plusDays(30)
invoice.description = "Milestone ${saleOrderLine.attrs?.milestoneOrder} : ${saleOrderLine.productName}"

def invoiceLine = new InvoiceLine()
invoiceLine.product = saleOrderLine.product
invoiceLine.productName = saleOrderLine.productName
invoiceLine.qty = saleOrderLine.qty
invoiceLine.price = saleOrderLine.price

invoice.addInvoiceLineListItem(invoiceLine)
invoice.save()

// Update milestone status
saleOrderLine.attrs['milestoneStatus'] = 'invoiced'
saleOrderLine.save()

execution.setVariable('invoiceId', invoice.id)
__log__.info("Facture milestone créée : Invoice #${invoice.id}")
```

---

## 5. Discount Management

### 5.1 Volume Discounts

```java
public class DiscountService {

  public BigDecimal calculateVolumeDiscount(SaleOrder saleOrder) {
    BigDecimal totalAmount = saleOrder.getExTaxTotal();
    BigDecimal discountRate = BigDecimal.ZERO;

    // Tiered volume discount
    if (totalAmount.compareTo(new BigDecimal("100000")) >= 0) {
      discountRate = new BigDecimal("0.15"); // 15%
    } else if (totalAmount.compareTo(new BigDecimal("50000")) >= 0) {
      discountRate = new BigDecimal("0.10"); // 10%
    } else if (totalAmount.compareTo(new BigDecimal("25000")) >= 0) {
      discountRate = new BigDecimal("0.05"); // 5%
    }

    return totalAmount.multiply(discountRate);
  }

  public BigDecimal calculateLoyaltyDiscount(Partner partner) {
    // Count completed projects
    Long projectCount = SaleOrder.all()
      .filter("self.clientPartner = ? AND self.statusSelect = 4", partner)
      .count();

    if (projectCount >= 5) return new BigDecimal("0.10"); // 10% for 5+ projects
    if (projectCount >= 3) return new BigDecimal("0.07"); // 7% for 3-4 projects
    if (projectCount >= 1) return new BigDecimal("0.03"); // 3% for repeat customer

    return BigDecimal.ZERO;
  }

  public BigDecimal calculateEarlyPaymentDiscount(Invoice invoice, Integer daysEarly) {
    // 2% discount if paid 15+ days early
    if (daysEarly >= 15) {
      return invoice.getInTaxTotal().multiply(new BigDecimal("0.02"));
    }
    return BigDecimal.ZERO;
  }
}
```

### 5.2 Promotional Campaigns

```xml
<!-- Summer Campaign: 20% off POC -->
<record model="com.axelor.apps.sale.db.PriceList">
  <field name="name">Promo Été 2025 - POC IA</field>
  <field name="typeSelect">sale</field>
  <field name="startDate">2025-06-01</field>
  <field name="endDate">2025-08-31</field>
</record>

<record model="com.axelor.apps.sale.db.PriceListLine">
  <field name="priceList" ref="promo-summer-2025"/>
  <field name="product" ref="product-poc-ia"/>
  <field name="typeSelect">2</field> <!-- Discount -->
  <field name="discountAmount">20.00</field>
  <field name="discountTypeSelect">1</field> <!-- Percentage -->
</record>
```

---

## 6. Reporting - Sales Analytics

### 6.1 Revenue by Service Type

```sql
-- CA par type de service IA (YTD)
SELECT
  COALESCE(so.attrs->>'typeServiceIA', 'Non défini') AS service_type,
  COUNT(DISTINCT so.id) AS nb_commandes,
  SUM(so.ex_tax_total) AS ca_total,
  AVG(so.ex_tax_total) AS panier_moyen,
  SUM(CASE WHEN so.status_select = 4 THEN so.ex_tax_total ELSE 0 END) AS ca_finalise
FROM sale_sale_order so
WHERE EXTRACT(YEAR FROM so.order_date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY so.attrs->>'typeServiceIA'
ORDER BY ca_total DESC;
```

### 6.2 Invoicing Forecast (Pipeline)

```sql
-- Prévisionnel facturation 90 jours
SELECT
  TO_CHAR(so.expected_realisation_date, 'YYYY-MM') AS month,
  COUNT(*) AS nb_projets,
  SUM(so.ex_tax_total) AS ca_previsionnel,
  SUM(so.ex_tax_total) * 0.7 AS ca_weighted  -- 70% probability
FROM sale_sale_order so
WHERE so.status_select IN (2, 3)  -- Confirmed, In Progress
  AND so.expected_realisation_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '90 days'
GROUP BY TO_CHAR(so.expected_realisation_date, 'YYYY-MM')
ORDER BY month;
```

### 6.3 Customer Lifetime Value (CLV)

```sql
-- CLV par client (top 20)
SELECT
  p.full_name AS client,
  COUNT(DISTINCT so.id) AS nb_commandes,
  SUM(so.ex_tax_total) AS ca_total,
  AVG(so.ex_tax_total) AS panier_moyen,
  MIN(so.order_date) AS first_order,
  MAX(so.order_date) AS last_order,
  EXTRACT(DAYS FROM MAX(so.order_date) - MIN(so.order_date)) AS customer_tenure_days,
  SUM(so.ex_tax_total) / NULLIF(EXTRACT(YEARS FROM MAX(so.order_date) - MIN(so.order_date)), 0) AS annual_value
FROM base_partner p
JOIN sale_sale_order so ON so.client_partner = p.id
WHERE so.status_select = 4  -- Completed
GROUP BY p.id, p.full_name
ORDER BY ca_total DESC
LIMIT 20;
```

### 6.4 Payment Terms Analysis

```sql
-- Analyse délais de paiement
SELECT
  pt.name AS payment_terms,
  COUNT(*) AS nb_factures,
  AVG(i.due_date - i.invoice_date) AS delai_moyen,
  COUNT(CASE WHEN i.payment_date > i.due_date THEN 1 END) AS nb_retards,
  ROUND(
    100.0 * COUNT(CASE WHEN i.payment_date > i.due_date THEN 1 END) / COUNT(*),
    2
  ) AS taux_retard
FROM account_invoice i
JOIN account_payment_condition pt ON i.payment_condition = pt.id
WHERE i.status_select = 3  -- Paid
  AND i.invoice_date >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY pt.id, pt.name
ORDER BY nb_factures DESC;
```

---

## 7. Quote Generation (AI-Specific)

### 7.1 AI Service Estimator

**Estimation Engine**:
```java
// File: src/main/java/com/axelor/apps/sale/service/AIProjectEstimator.java

public class AIProjectEstimator {

  public EstimateResult estimateProject(Map<String, Object> projectSpecs) {
    String serviceType = (String) projectSpecs.get("typeServiceIA");
    String complexity = (String) projectSpecs.get("complexiteProjet");
    Integer dataVolume = (Integer) projectSpecs.get("dataVolumeGB");
    Boolean customModel = (Boolean) projectSpecs.get("requiresCustomModel");

    EstimateResult result = new EstimateResult();

    // Base effort (days)
    int baseDays = getBaseDays(serviceType);

    // Complexity multiplier
    double complexityMultiplier = getComplexityMultiplier(complexity);

    // Data volume adjustment
    int dataAdjustment = 0;
    if (dataVolume != null) {
      if (dataVolume > 1000) dataAdjustment += 10; // Large dataset
      if (dataVolume > 100) dataAdjustment += 5;   // Medium dataset
    }

    // Custom model overhead
    int customModelDays = customModel != null && customModel ? 15 : 0;

    // Total estimation
    int totalDays = (int) (baseDays * complexityMultiplier) + dataAdjustment + customModelDays;

    result.setEstimatedDays(totalDays);
    result.setEstimatedPrice(new BigDecimal(totalDays).multiply(new BigDecimal("900"))); // TJM 900€
    result.setConfidenceLevel(calculateConfidence(projectSpecs));

    return result;
  }

  private int getBaseDays(String serviceType) {
    switch (serviceType) {
      case "poc": return 15;
      case "chatbot": return 30;
      case "ml-custom": return 45;
      case "computer-vision": return 50;
      case "nlp": return 40;
      case "integration": return 20;
      case "conseil": return 5;
      default: return 30;
    }
  }

  private String calculateConfidence(Map<String, Object> specs) {
    // Check completeness of specifications
    int completeness = 0;
    if (specs.get("dataVolumeGB") != null) completeness += 20;
    if (specs.get("stackTechnique") != null) completeness += 20;
    if (specs.get("infrastructureType") != null) completeness += 20;
    if (specs.get("casUsageIA") != null) completeness += 20;
    if (specs.get("kpis") != null) completeness += 20;

    if (completeness >= 80) return "High (±15%)";
    if (completeness >= 60) return "Medium (±30%)";
    return "Low (±50%)";
  }
}
```

### 7.2 Quote Template (AI Projects)

```xml
<!-- File: templates/quotes/AI_Project_Quote.docx -->
<!-- Bento template with Freemarker syntax -->

<document>
  <header>
    <company>Agence IA</company>
    <logo>logo.png</logo>
    <date>${saleOrder.orderDate?string('dd/MM/yyyy')}</date>
    <quoteNumber>${saleOrder.saleOrderSeq}</quoteNumber>
  </header>

  <client>
    <name>${saleOrder.clientPartner.fullName}</name>
    <address>${saleOrder.clientPartner.mainAddress}</address>
  </client>

  <section title="Synthèse Projet">
    <p>Type de service : ${saleOrder.attrs.typeServiceIA}</p>
    <p>Complexité : ${saleOrder.attrs.complexiteProjet}</p>
    <p>Durée estimée : ${saleOrder.attrs.nbJoursEstimes} jours</p>
    <p>Mode facturation : ${saleOrder.attrs.modeFacturation}</p>
  </section>

  <section title="Description Technique">
    <p>${saleOrder.description}</p>

    <subsection title="Stack Technique">
      <p>${saleOrder.attrs.techStack}</p>
    </subsection>

    <subsection title="Livrables">
      <#list saleOrder.saleOrderLineList as line>
      <li>${line.productName} - ${line.qty} ${line.unit.name}</li>
      </#list>
    </subsection>
  </section>

  <section title="Prix">
    <table>
      <#list saleOrder.saleOrderLineList as line>
      <tr>
        <td>${line.productName}</td>
        <td>${line.qty}</td>
        <td>${line.price?string.currency}</td>
        <td>${line.exTaxTotal?string.currency}</td>
      </tr>
      </#list>
      <tr class="total">
        <td colspan="3">Total HT</td>
        <td>${saleOrder.exTaxTotal?string.currency}</td>
      </tr>
      <tr>
        <td colspan="3">TVA 20%</td>
        <td>${saleOrder.taxTotal?string.currency}</td>
      </tr>
      <tr class="total">
        <td colspan="3">Total TTC</td>
        <td>${saleOrder.inTaxTotal?string.currency}</td>
      </tr>
    </table>
  </section>

  <section title="Modalités">
    <p>Propriété intellectuelle : ${saleOrder.attrs.proprieteIntellectuelle}</p>
    <p>Maintenance : ${saleOrder.attrs.maintenanceInclude?string('Incluse', 'Non incluse')}</p>
    <p>SLA : ${saleOrder.attrs.slaType}</p>
    <p>Garantie : 3 mois conformité fonctionnelle</p>
  </section>

  <footer>
    <p>Devis valable 30 jours</p>
    <p>Conditions générales de vente : voir annexe</p>
  </footer>
</document>
```

---

## 8. Best Practices - Sales (Agence IA)

### 8.1 Quote Preparation Checklist

- [ ] Cahier des charges technique validé
- [ ] Données client analysées (volume, qualité, disponibilité)
- [ ] Stack technique compatible confirmé
- [ ] Infrastructure hébergement définie
- [ ] KPIs de succès mesurables établis
- [ ] Risques techniques identifiés et mitigés
- [ ] NDA signé si données sensibles
- [ ] Estimations validées par équipe technique
- [ ] Milestones et planning réalistes
- [ ] Mode facturation adapté au projet

### 8.2 Pricing Strategy

**Value-Based Pricing** (Recommandé):
- Baser prix sur valeur créée pour client (ROI)
- Exemple : Économie 100k€/an → Facturer 30-40k€

**Cost-Plus Pricing**:
- Coût interne (salaires + infra) × 2.5-3.0
- Exemple : Coût 30k€ → Prix 75-90k€

**Competitive Pricing**:
- Analyser prix marché (freelances, ESN, agences)
- Se positionner premium (qualité + expertise)

### 8.3 Contract Negotiation Tips

**Red Flags** (Refuser ou contingences):
- Propriété intellectuelle 100% agence + licence client → Risque réutilisation
- Garantie résultats sans KPIs mesurables → Impossible à valider
- Pénalités retard > 20% du contrat → Risque financier excessif
- Données d'entraînement non disponibles → Projet bloqué

**Must-Have Clauses**:
- Clause de réversibilité (documentation + formation)
- Limitation de responsabilité (montant contrat)
- Propriété IP sur outils génériques développés
- Acceptation formelle livrables (PV recette)

### 8.4 Upsell Opportunities

**Après livraison**:
- Maintenance (12 mois) → 15-20% prix initial/an
- Formation équipe client → 2-5k€/jour
- Évolutions fonctionnelles → 50-70% prix initial
- Monitoring & support 24/7 → 2-5k€/mois

**Cross-sell**:
- Client POC → Proposer industrialisation
- Client Chatbot → Proposer NLP avancé
- Client ML → Proposer formation MLOps

---

**End of Knowledge Base**
