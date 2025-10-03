# Knowledge Base : Intégrations et APIs Axelor

**Type** : Pure Technical Reference (no agent narrative)
**Version Axelor** : 8.3.15 / AOP 7.4
**Scope** : API REST, Webhooks, Axelor Connect, Web Services
**Usage** : Accessed dynamically by routing agents

---

## 1. API REST Axelor

### 1.1 Endpoints Principaux

#### `/ws/rest/:model` - CRUD Operations

**GET** - List/Search
```http
GET /ws/rest/com.axelor.apps.crm.db.Lead
Headers:
  Accept: application/json
  Cookie: JSESSIONID=xxx

Query Parameters:
  - offset: 0 (pagination)
  - limit: 40 (max results)
  - fields: id,name,email,user.fullName (projection)
  - sortBy: -id (descending by id)

Body (Filter):
{
  "data": {
    "criteria": [
      {
        "fieldName": "statusSelect",
        "operator": "=",
        "value": "1"
      }
    ],
    "operator": "and"
  }
}

Response:
{
  "status": 0,
  "data": [
    {
      "id": 1,
      "name": "Lead Name",
      "email": "contact@example.com",
      "user": {
        "fullName": "John Doe"
      }
    }
  ],
  "offset": 0,
  "total": 1
}
```

**GET by ID**
```http
GET /ws/rest/com.axelor.apps.crm.db.Lead/42
Headers:
  Accept: application/json
  Cookie: JSESSIONID=xxx

Response:
{
  "status": 0,
  "data": [
    {
      "id": 42,
      "name": "My Lead",
      "email": "lead@example.com",
      "version": 1
    }
  ]
}
```

**POST** - Create
```http
POST /ws/rest/com.axelor.apps.crm.db.Lead
Headers:
  Content-Type: application/json
  Cookie: JSESSIONID=xxx

Body:
{
  "data": {
    "name": "New Lead",
    "email": "newlead@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "user": {
      "id": 1
    },
    "attrs": {
      "niveauMaturiteIA": "Intermédiaire",
      "budgetIA": 25000
    }
  }
}

Response:
{
  "status": 0,
  "data": [
    {
      "id": 43,
      "name": "New Lead",
      "version": 0,
      ...
    }
  ]
}
```

**POST** - Update
```http
POST /ws/rest/com.axelor.apps.crm.db.Lead
Headers:
  Content-Type: application/json
  Cookie: JSESSIONID=xxx

Body:
{
  "data": {
    "id": 42,
    "version": 1,  // Required for optimistic locking
    "name": "Updated Lead Name",
    "statusSelect": "2"
  }
}

Response:
{
  "status": 0,
  "data": [
    {
      "id": 42,
      "version": 2,  // Version incremented
      ...
    }
  ]
}
```

**DELETE**
```http
DELETE /ws/rest/com.axelor.apps.crm.db.Lead/42
Headers:
  Cookie: JSESSIONID=xxx

Response:
{
  "status": 0
}
```

#### `/ws/action/:actionName` - Execute Actions

```http
POST /ws/action/action-lead-method-convert-to-opportunity
Headers:
  Content-Type: application/json
  Cookie: JSESSIONID=xxx

Body:
{
  "data": {
    "context": {
      "_model": "com.axelor.apps.crm.db.Lead",
      "id": 42
    }
  }
}

Response:
{
  "status": 0,
  "data": [
    {
      "reload": true,
      "flash": "Lead converted to Opportunity"
    }
  ]
}
```

#### `/ws/meta/fields/:model` - Model Metadata

```http
GET /ws/meta/fields/com.axelor.apps.crm.db.Lead
Headers:
  Accept: application/json
  Cookie: JSESSIONID=xxx

Response:
{
  "status": 0,
  "data": {
    "fields": [
      {
        "name": "id",
        "type": "long",
        "label": "ID"
      },
      {
        "name": "name",
        "type": "string",
        "label": "Name",
        "required": true
      },
      ...
    ]
  }
}
```

### 1.2 Operators de Filtrage

```
Comparison:
- "=" : Equals
- "!=" : Not equals
- ">" : Greater than
- ">=" : Greater or equal
- "<" : Less than
- "<=" : Less or equal

String:
- "like" : SQL LIKE (%value%)
- "notLike" : SQL NOT LIKE
- "ilike" : Case-insensitive LIKE
- "in" : IN (value1, value2, ...)
- "notIn" : NOT IN

Null:
- "isNull" : IS NULL
- "notNull" : IS NOT NULL

Logical:
- "and" : AND operator
- "or" : OR operator
```

**Example Complex Filter**:
```json
{
  "data": {
    "criteria": [
      {
        "operator": "or",
        "criteria": [
          {
            "fieldName": "statusSelect",
            "operator": "=",
            "value": "1"
          },
          {
            "fieldName": "statusSelect",
            "operator": "=",
            "value": "2"
          }
        ]
      },
      {
        "fieldName": "attrs.budgetIA",
        "operator": ">=",
        "value": 10000
      },
      {
        "fieldName": "email",
        "operator": "like",
        "value": "@company.com"
      }
    ],
    "operator": "and"
  }
}
```

### 1.3 Authentication Methods

#### Session Cookie (Web UI)
```bash
# 1. Login
curl -c cookies.txt -X POST http://localhost:8080/callback \
  -d "username=admin" \
  -d "password=admin"

# 2. Use session
curl -b cookies.txt http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead
```

#### Basic Auth
```bash
curl -u admin:admin \
  http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead
```

#### API Key (OAuth2 Client Credentials)
```bash
# 1. Obtain token
curl -X POST http://localhost:8080/oauth/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials" \
  -d "client_id=your_client_id" \
  -d "client_secret=your_client_secret"

# Response:
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600
}

# 2. Use token
curl -H "Authorization: Bearer eyJhbGc..." \
  http://localhost:8080/ws/rest/com.axelor.apps.crm.db.Lead
```

---

## 2. Webhooks

### 2.1 Outgoing Webhooks (Axelor → External)

**Configuration** (via Studio ou Code):

#### Via Code (Event Listener)
```java
// Module: axelor-crm
// File: src/main/java/com/axelor/apps/crm/web/LeadWebhookListener.java

package com.axelor.apps.crm.web;

import com.axelor.apps.crm.db.Lead;
import com.axelor.db.JpaRepository;
import com.axelor.event.Observes;
import com.axelor.events.PostRequest;
import com.google.inject.Inject;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URI;

public class LeadWebhookListener {

  @Inject private HttpClient httpClient;

  public void onLeadCreated(@Observes PostRequest event) {
    if (event.getRequest().getModel().equals(Lead.class)) {
      Lead lead = JpaRepository.of(Lead.class).find(event.getRequest().getId());

      if (lead != null && event.getRequest().isNew()) {
        sendWebhook(lead);
      }
    }
  }

  private void sendWebhook(Lead lead) {
    try {
      String payload = String.format(
        "{\"id\": %d, \"name\": \"%s\", \"email\": \"%s\"}",
        lead.getId(), lead.getName(), lead.getEmailAddress().getAddress()
      );

      HttpRequest request = HttpRequest.newBuilder()
        .uri(URI.create("https://external-system.com/webhook/lead"))
        .header("Content-Type", "application/json")
        .header("Authorization", "Bearer YOUR_TOKEN")
        .POST(HttpRequest.BodyPublishers.ofString(payload))
        .build();

      httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString());
    } catch (Exception e) {
      // Log error
    }
  }
}
```

#### Via BPM Workflow (Service Task)
```groovy
// Service Task: Send Webhook
import java.net.http.*
import java.net.URI

def client = HttpClient.newHttpClient()
def payload = groovy.json.JsonOutput.toJson([
  id: lead.id,
  name: lead.name,
  email: lead.emailAddress?.address,
  status: lead.statusSelect
])

def request = HttpRequest.newBuilder()
  .uri(URI.create("https://external-system.com/webhook/lead"))
  .header("Content-Type", "application/json")
  .header("Authorization", "Bearer ${__config__.get('webhook.token')}")
  .POST(HttpRequest.BodyPublishers.ofString(payload))
  .build()

try {
  def response = client.send(request, HttpResponse.BodyHandlers.ofString())
  execution.setVariable('webhookStatus', response.statusCode())
  execution.setVariable('webhookResponse', response.body())
} catch (Exception e) {
  execution.setVariable('webhookError', e.message)
}
```

### 2.2 Incoming Webhooks (External → Axelor)

**Create REST Controller**:

```java
// Module: axelor-crm
// File: src/main/java/com/axelor/apps/crm/web/WebhookController.java

package com.axelor.apps.crm.web;

import com.axelor.apps.crm.db.Lead;
import com.axelor.apps.crm.db.repo.LeadRepository;
import com.axelor.inject.Beans;
import com.axelor.rpc.ActionRequest;
import com.axelor.rpc.ActionResponse;
import com.google.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/webhook")
public class WebhookController {

  @Inject private LeadRepository leadRepository;

  @POST
  @Path("/lead/create")
  @Consumes(MediaType.APPLICATION_JSON)
  @Produces(MediaType.APPLICATION_JSON)
  public Response createLead(WebhookPayload payload) {
    // Validate webhook signature/token
    if (!isValidWebhook(payload.getToken())) {
      return Response.status(401).entity("{\"error\": \"Unauthorized\"}").build();
    }

    try {
      Lead lead = new Lead();
      lead.setName(payload.getName());
      lead.setFirstName(payload.getFirstName());
      lead.setLastName(payload.getLastName());
      // ... set other fields

      leadRepository.save(lead);

      return Response.ok()
        .entity("{\"status\": \"success\", \"id\": " + lead.getId() + "}")
        .build();
    } catch (Exception e) {
      return Response.status(500)
        .entity("{\"error\": \"" + e.getMessage() + "\"}")
        .build();
    }
  }

  private boolean isValidWebhook(String token) {
    String expectedToken = Beans.get(AppSettings.class).get("webhook.secret.token");
    return expectedToken != null && expectedToken.equals(token);
  }
}
```

**Register Controller** (axelor-config.properties):
```properties
# REST API Configuration
rest.cors.enable = true
rest.cors.allow-origin = *
rest.cors.allow-methods = GET,POST,PUT,DELETE,OPTIONS
rest.cors.allow-headers = Origin,Content-Type,Accept,Authorization
```

---

## 3. Axelor Connect (Connecteurs)

### 3.1 Architecture Axelor Connect

```
External System  →  Connector (1500+ disponibles)  →  Axelor
                         ↓
                    Configuration
                    - Credentials
                    - Mapping
                    - Filters
                    - Schedule
```

**Connecteurs Populaires**:
- CRM: Salesforce, HubSpot, Pipedrive, Zoho CRM
- Communication: Gmail, Outlook, Slack, Teams
- Comptabilité: QuickBooks, Xero, Sage
- E-commerce: Shopify, WooCommerce, Magento
- Marketing: Mailchimp, SendGrid, ActiveCampaign
- Cloud Storage: Google Drive, Dropbox, OneDrive
- Payment: Stripe, PayPal, Square
- Developer: GitHub, GitLab, Jira, Trello

### 3.2 Configuration Connector (Example: Gmail)

**Via UI** (Studio → Configurations → Connectors):
```
1. Name: Gmail Lead Sync
2. Type: Gmail (OAuth2)
3. Credentials:
   - Client ID: your_google_client_id
   - Client Secret: your_google_client_secret
   - Redirect URI: http://localhost:8080/oauth/callback
4. Mapping:
   - Gmail Email → Lead
   - From: email → lead.emailAddress
   - Subject → lead.name
   - Body → lead.description
5. Filter:
   - Label: "leads"
   - Unread only: true
6. Schedule: Every 15 minutes
```

**Configuration File** (.axelor/data-config.xml):
```xml
<csv-inputs>
  <input file="connector-gmail-config.xml" type="com.axelor.apps.base.db.Connector">
    <bind column="name" to="name"/>
    <bind column="type" to="typeSelect"/>
    <bind column="clientId" to="clientId"/>
    <bind column="clientSecret" to="clientSecret"/>
    <bind column="redirectUri" to="redirectUri"/>
    <bind column="schedule" to="schedule"/>
  </input>
</csv-inputs>
```

### 3.3 Custom Connector (Java)

**Create Connector Service**:
```java
// Module: axelor-crm
// File: src/main/java/com/axelor/apps/crm/service/ExternalAPIConnectorService.java

package com.axelor.apps.crm.service;

import com.axelor.apps.crm.db.Lead;
import com.axelor.apps.crm.db.repo.LeadRepository;
import com.google.inject.Inject;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URI;
import com.fasterxml.jackson.databind.ObjectMapper;

public class ExternalAPIConnectorService {

  @Inject private LeadRepository leadRepository;
  @Inject private HttpClient httpClient;
  @Inject private ObjectMapper objectMapper;

  public void syncLeadsFromExternalAPI() throws Exception {
    // 1. Fetch data from external API
    HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("https://api.external-crm.com/leads"))
      .header("Authorization", "Bearer YOUR_API_TOKEN")
      .GET()
      .build();

    HttpResponse<String> response = httpClient.send(
      request,
      HttpResponse.BodyHandlers.ofString()
    );

    // 2. Parse JSON response
    ExternalLead[] externalLeads = objectMapper.readValue(
      response.body(),
      ExternalLead[].class
    );

    // 3. Map and save to Axelor
    for (ExternalLead extLead : externalLeads) {
      Lead lead = leadRepository.findByExternalId(extLead.getId());

      if (lead == null) {
        lead = new Lead();
        lead.setExternalId(extLead.getId());
      }

      lead.setName(extLead.getName());
      lead.setFirstName(extLead.getFirstName());
      lead.setLastName(extLead.getLastName());
      lead.setStatusSelect(mapStatus(extLead.getStatus()));

      leadRepository.save(lead);
    }
  }

  private Integer mapStatus(String externalStatus) {
    switch (externalStatus) {
      case "NEW": return 1;
      case "QUALIFIED": return 2;
      case "CONVERTED": return 3;
      default: return 1;
    }
  }
}

// DTO Class
class ExternalLead {
  private String id;
  private String name;
  private String firstName;
  private String lastName;
  private String status;

  // Getters/Setters
}
```

**Schedule Connector** (Quartz Scheduler):
```java
// File: src/main/java/com/axelor/apps/crm/job/LeadSyncJob.java

package com.axelor.apps.crm.job;

import com.axelor.apps.crm.service.ExternalAPIConnectorService;
import com.google.inject.Inject;
import org.quartz.Job;
import org.quartz.JobExecutionContext;

public class LeadSyncJob implements Job {

  @Inject private ExternalAPIConnectorService connectorService;

  @Override
  public void execute(JobExecutionContext context) {
    try {
      connectorService.syncLeadsFromExternalAPI();
    } catch (Exception e) {
      // Log error
    }
  }
}
```

**Schedule Configuration** (application.properties):
```properties
# Quartz Scheduler
quartz.enable = true
quartz.job.lead-sync.cron = 0 */15 * * * ?
quartz.job.lead-sync.class = com.axelor.apps.crm.job.LeadSyncJob
```

---

## 4. Web Services (Studio Configuration)

### 4.1 Create Web Service in Studio

**Via Studio UI**:
```
1. Navigate to: Studio → Configurations → Web Services
2. Create new Web Service:
   - Name: Lead API
   - Type: REST
   - Base URL: /api/v1/leads
   - Authentication: OAuth2
3. Add Endpoints:
   - GET /api/v1/leads → action-lead-api-list
   - GET /api/v1/leads/:id → action-lead-api-get
   - POST /api/v1/leads → action-lead-api-create
   - PUT /api/v1/leads/:id → action-lead-api-update
   - DELETE /api/v1/leads/:id → action-lead-api-delete
```

### 4.2 Web Service Actions (XML)

```xml
<!-- File: modules/axelor-crm/src/main/resources/views/Lead.xml -->

<action-record name="action-lead-api-create" model="com.axelor.apps.crm.db.Lead">
  <field name="name" expr="eval: __json__.name"/>
  <field name="firstName" expr="eval: __json__.firstName"/>
  <field name="lastName" expr="eval: __json__.lastName"/>
  <field name="emailAddress" expr="eval: __json__.email"/>
  <field name="statusSelect" expr="eval: 1"/>
</action-record>

<action-method name="action-lead-api-list">
  <call class="com.axelor.apps.crm.web.LeadController" method="listLeads"/>
</action-method>

<action-method name="action-lead-api-get">
  <call class="com.axelor.apps.crm.web.LeadController" method="getLead"/>
</action-method>
```

**Controller Implementation**:
```java
// File: src/main/java/com/axelor/apps/crm/web/LeadController.java

public class LeadController {

  @Inject private LeadRepository leadRepository;

  public void listLeads(ActionRequest request, ActionResponse response) {
    List<Lead> leads = leadRepository.all()
      .filter("self.statusSelect = ?", request.getContext().get("status"))
      .order("-id")
      .fetch();

    List<Map<String, Object>> data = leads.stream()
      .map(this::toJSON)
      .collect(Collectors.toList());

    response.setData(data);
  }

  public void getLead(ActionRequest request, ActionResponse response) {
    Long id = (Long) request.getContext().get("id");
    Lead lead = leadRepository.find(id);

    if (lead != null) {
      response.setData(toJSON(lead));
    } else {
      response.setError("Lead not found");
    }
  }

  private Map<String, Object> toJSON(Lead lead) {
    Map<String, Object> json = new HashMap<>();
    json.put("id", lead.getId());
    json.put("name", lead.getName());
    json.put("email", lead.getEmailAddress() != null
      ? lead.getEmailAddress().getAddress() : null);
    json.put("status", lead.getStatusSelect());
    return json;
  }
}
```

---

## 5. Integration Patterns

### 5.1 Synchronous Integration (API Call)

**Use case**: Real-time data exchange (payment processing, address validation)

```java
public class PaymentService {

  @Inject private HttpClient httpClient;

  public PaymentResponse processPayment(Invoice invoice) {
    // Call external payment API synchronously
    HttpRequest request = HttpRequest.newBuilder()
      .uri(URI.create("https://api.stripe.com/v1/charges"))
      .header("Authorization", "Bearer sk_test_...")
      .header("Content-Type", "application/x-www-form-urlencoded")
      .POST(HttpRequest.BodyPublishers.ofString(
        "amount=" + invoice.getInTaxTotal().multiply(new BigDecimal(100)).intValue() +
        "&currency=eur" +
        "&source=" + invoice.getPaymentToken()
      ))
      .build();

    try {
      HttpResponse<String> response = httpClient.send(
        request,
        HttpResponse.BodyHandlers.ofString()
      );

      if (response.statusCode() == 200) {
        // Parse response and update invoice
        return parsePaymentResponse(response.body());
      } else {
        throw new Exception("Payment failed: " + response.body());
      }
    } catch (Exception e) {
      // Handle error
      throw new RuntimeException(e);
    }
  }
}
```

### 5.2 Asynchronous Integration (Message Queue)

**Use case**: Bulk data sync, non-blocking operations

```java
// Using JMS/ActiveMQ
public class LeadMessageProducer {

  @Inject private ConnectionFactory connectionFactory;

  public void sendLeadToQueue(Lead lead) {
    try (Connection connection = connectionFactory.createConnection();
         Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE)) {

      MessageProducer producer = session.createProducer(
        session.createQueue("lead.created")
      );

      TextMessage message = session.createTextMessage();
      message.setText(toJSON(lead));
      message.setStringProperty("leadId", String.valueOf(lead.getId()));

      producer.send(message);
    } catch (Exception e) {
      // Handle error
    }
  }
}

// Consumer
public class LeadMessageConsumer implements MessageListener {

  @Inject private ExternalCRMService externalCRMService;

  @Override
  public void onMessage(Message message) {
    try {
      TextMessage textMessage = (TextMessage) message;
      String leadJSON = textMessage.getText();

      // Process message asynchronously
      externalCRMService.syncLeadToExternalCRM(leadJSON);
    } catch (Exception e) {
      // Handle error
    }
  }
}
```

### 5.3 Batch Integration (Scheduled Jobs)

**Use case**: Nightly data sync, report generation

```groovy
// BPM Timer Event (Daily at 2 AM)
// Script Task: Export Leads to External System

import com.axelor.apps.crm.db.Lead
import com.axelor.apps.crm.db.repo.LeadRepository
import groovy.json.JsonOutput

def leadRepo = __ctx__.getBean(LeadRepository.class)
def leads = leadRepo.all()
  .filter("self.createdOn >= ?", __date__.minusDays(1))
  .fetch()

def leadsData = leads.collect { lead ->
  [
    id: lead.id,
    name: lead.name,
    email: lead.emailAddress?.address,
    status: lead.statusSelect,
    createdOn: lead.createdOn.toString()
  ]
}

def json = JsonOutput.toJson(leadsData)

// Upload to external system (FTP, S3, API)
def ftpClient = new org.apache.commons.net.ftp.FTPClient()
ftpClient.connect("ftp.external-system.com")
ftpClient.login("username", "password")
ftpClient.storeFile("/uploads/leads_${__date__}.json", new ByteArrayInputStream(json.bytes))
ftpClient.disconnect()

execution.setVariable('exportedLeads', leads.size())
```

### 5.4 Event-Driven Integration (Webhooks)

**Use case**: Real-time notifications, trigger external workflows

See Section 2.1 (Outgoing Webhooks) above.

---

## 6. Security Best Practices

### 6.1 API Authentication

**OAuth2 Configuration** (application.properties):
```properties
# OAuth2 Configuration
auth.oauth.enable = true
auth.oauth.client-id = your_client_id
auth.oauth.client-secret = your_client_secret
auth.oauth.access-token-validity = 3600
auth.oauth.refresh-token-validity = 86400

# CORS
cors.allow-origin = https://trusted-domain.com
cors.allow-credentials = true
cors.allow-methods = GET,POST,PUT,DELETE
cors.allow-headers = Authorization,Content-Type
```

### 6.2 API Rate Limiting

```java
// Custom Filter
public class RateLimitFilter implements Filter {

  private static final Map<String, RateLimiter> limiters = new ConcurrentHashMap<>();
  private static final int MAX_REQUESTS_PER_MINUTE = 60;

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    String apiKey = httpRequest.getHeader("X-API-Key");

    RateLimiter limiter = limiters.computeIfAbsent(
      apiKey,
      k -> RateLimiter.create(MAX_REQUESTS_PER_MINUTE / 60.0)
    );

    if (limiter.tryAcquire()) {
      chain.doFilter(request, response);
    } else {
      HttpServletResponse httpResponse = (HttpServletResponse) response;
      httpResponse.setStatus(429);
      httpResponse.getWriter().write("{\"error\": \"Rate limit exceeded\"}");
    }
  }
}
```

### 6.3 Webhook Signature Verification

```java
public class WebhookValidator {

  public boolean isValidSignature(String payload, String signature, String secret) {
    try {
      Mac mac = Mac.getInstance("HmacSHA256");
      SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(), "HmacSHA256");
      mac.init(secretKey);

      byte[] hash = mac.doFinal(payload.getBytes());
      String computedSignature = Base64.getEncoder().encodeToString(hash);

      return MessageDigest.isEqual(
        signature.getBytes(),
        computedSignature.getBytes()
      );
    } catch (Exception e) {
      return false;
    }
  }
}

// Usage in Webhook Controller
@POST
@Path("/webhook/external")
public Response handleWebhook(String payload, @HeaderParam("X-Signature") String signature) {
  if (!webhookValidator.isValidSignature(payload, signature, SECRET_KEY)) {
    return Response.status(401).entity("{\"error\": \"Invalid signature\"}").build();
  }

  // Process webhook
  return Response.ok().build();
}
```

### 6.4 Data Encryption

```java
// Encrypt sensitive data before external API call
public class EncryptionService {

  private static final String ALGORITHM = "AES/GCM/NoPadding";
  private static final int GCM_TAG_LENGTH = 128;

  public String encrypt(String data, SecretKey key) throws Exception {
    Cipher cipher = Cipher.getInstance(ALGORITHM);
    byte[] iv = new byte[12];
    new SecureRandom().nextBytes(iv);

    GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
    cipher.init(Cipher.ENCRYPT_MODE, key, parameterSpec);

    byte[] encrypted = cipher.doFinal(data.getBytes());
    byte[] combined = new byte[iv.length + encrypted.length];
    System.arraycopy(iv, 0, combined, 0, iv.length);
    System.arraycopy(encrypted, 0, combined, iv.length, encrypted.length);

    return Base64.getEncoder().encodeToString(combined);
  }

  public String decrypt(String encryptedData, SecretKey key) throws Exception {
    byte[] combined = Base64.getDecoder().decode(encryptedData);

    byte[] iv = new byte[12];
    byte[] encrypted = new byte[combined.length - 12];
    System.arraycopy(combined, 0, iv, 0, 12);
    System.arraycopy(combined, 12, encrypted, 0, encrypted.length);

    Cipher cipher = Cipher.getInstance(ALGORITHM);
    GCMParameterSpec parameterSpec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);
    cipher.init(Cipher.DECRYPT_MODE, key, parameterSpec);

    return new String(cipher.doFinal(encrypted));
  }
}
```

---

## 7. Monitoring and Logging

### 7.1 API Request Logging

```java
// Custom Logging Filter
public class APILoggingFilter implements Filter {

  private static final Logger LOG = LoggerFactory.getLogger(APILoggingFilter.class);

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) {
    HttpServletRequest httpRequest = (HttpServletRequest) request;
    HttpServletResponse httpResponse = (HttpServletResponse) response;

    long startTime = System.currentTimeMillis();
    String requestId = UUID.randomUUID().toString();

    LOG.info("API Request [{}] - {} {} - User: {}",
      requestId,
      httpRequest.getMethod(),
      httpRequest.getRequestURI(),
      httpRequest.getRemoteUser()
    );

    chain.doFilter(request, response);

    long duration = System.currentTimeMillis() - startTime;
    LOG.info("API Response [{}] - Status: {} - Duration: {}ms",
      requestId,
      httpResponse.getStatus(),
      duration
    );
  }
}
```

### 7.2 Integration Error Tracking

```sql
-- Table: integration_log
CREATE TABLE integration_log (
  id BIGSERIAL PRIMARY KEY,
  integration_name VARCHAR(255),
  operation VARCHAR(50),
  status VARCHAR(20),
  request_payload TEXT,
  response_payload TEXT,
  error_message TEXT,
  duration_ms INTEGER,
  created_on TIMESTAMP DEFAULT NOW()
);

-- Query failed integrations
SELECT
  integration_name,
  operation,
  COUNT(*) AS error_count,
  AVG(duration_ms) AS avg_duration
FROM integration_log
WHERE status = 'ERROR'
  AND created_on >= NOW() - INTERVAL '24 hours'
GROUP BY integration_name, operation
ORDER BY error_count DESC;
```

### 7.3 Webhook Delivery Monitoring

```java
public class WebhookDeliveryService {

  @Inject private WebhookLogRepository webhookLogRepository;

  public void sendWithRetry(String url, String payload, int maxRetries) {
    int attempt = 0;
    boolean success = false;

    while (attempt < maxRetries && !success) {
      WebhookLog log = new WebhookLog();
      log.setUrl(url);
      log.setPayload(payload);
      log.setAttempt(attempt + 1);
      log.setSentAt(LocalDateTime.now());

      try {
        HttpResponse<String> response = sendWebhook(url, payload);

        log.setStatusCode(response.statusCode());
        log.setResponse(response.body());
        log.setSuccess(response.statusCode() >= 200 && response.statusCode() < 300);

        success = log.getSuccess();
      } catch (Exception e) {
        log.setSuccess(false);
        log.setError(e.getMessage());
      }

      webhookLogRepository.save(log);

      if (!success && attempt < maxRetries - 1) {
        Thread.sleep((long) Math.pow(2, attempt) * 1000); // Exponential backoff
      }

      attempt++;
    }
  }
}
```

---

## 8. Troubleshooting

### 8.1 Common API Errors

**401 Unauthorized**
```
Cause: Invalid credentials, expired token
Solution:
- Verify API credentials
- Refresh OAuth2 token
- Check user permissions
```

**403 Forbidden**
```
Cause: Insufficient permissions
Solution:
- Verify user has role: API User
- Check object-level permissions
- Review field-level security
```

**409 Conflict (Optimistic Locking)**
```
Cause: Version mismatch
Solution:
- Fetch latest version before update
- Implement retry logic with exponential backoff

Example:
{
  "data": {
    "id": 42,
    "version": 2,  // Must match current DB version
    "name": "Updated"
  }
}
```

**500 Internal Server Error**
```
Cause: Server-side exception
Solution:
- Check server logs: logs/axelor.log
- Verify data integrity
- Test with minimal payload
```

### 8.2 Webhook Debugging

**Webhook not received**:
```bash
# Test endpoint manually
curl -X POST http://localhost:8080/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# Check firewall rules
sudo iptables -L -n | grep 8080

# Verify webhook URL in logs
grep "webhook" logs/axelor.log
```

**Webhook signature validation failing**:
```java
// Debug signature computation
String payload = "{\"id\": 123}";
String secret = "your_secret";

Mac mac = Mac.getInstance("HmacSHA256");
mac.init(new SecretKeySpec(secret.getBytes(), "HmacSHA256"));
byte[] hash = mac.doFinal(payload.getBytes());
String signature = Base64.getEncoder().encodeToString(hash);

System.out.println("Expected signature: " + signature);
```

### 8.3 Connector Issues

**Connector sync failing**:
```sql
-- Check connector status
SELECT * FROM base_connector WHERE name = 'Gmail Lead Sync';

-- Check connector logs
SELECT * FROM base_connector_log
WHERE connector_id = ?
ORDER BY created_on DESC
LIMIT 10;

-- Reset connector state
UPDATE base_connector
SET last_sync = NULL
WHERE name = 'Gmail Lead Sync';
```

**OAuth2 token expired**:
```
Solution:
1. Navigate to: Configurations → Connectors → [Your Connector]
2. Click "Re-authenticate"
3. Complete OAuth2 flow
4. Verify refresh_token is saved
```

### 8.4 Performance Issues

**Slow API responses**:
```
Diagnostics:
1. Enable SQL logging (application.properties):
   hibernate.show_sql = true

2. Analyze query performance:
   EXPLAIN ANALYZE SELECT ...

3. Add indexes:
   CREATE INDEX idx_lead_email ON crm_lead(email_address);

4. Optimize API queries:
   - Use field projection: ?fields=id,name
   - Limit results: ?limit=20
   - Avoid N+1 queries (fetch relations eagerly)
```

**Integration timeout**:
```java
// Increase timeout
HttpClient client = HttpClient.newBuilder()
  .connectTimeout(Duration.ofSeconds(30))
  .build();

HttpRequest request = HttpRequest.newBuilder()
  .uri(URI.create(url))
  .timeout(Duration.ofSeconds(60))  // Request timeout
  .build();
```

---

## 9. Quick Reference

### API Endpoints Summary
```
/ws/rest/:model           - CRUD operations
/ws/action/:action        - Execute actions
/ws/meta/fields/:model    - Model metadata
/ws/meta/views            - View metadata
/login.jsp               - Web login
/oauth/token             - OAuth2 token
```

### HTTP Status Codes
```
200 OK                   - Success
201 Created              - Resource created
400 Bad Request          - Invalid request
401 Unauthorized         - Authentication required
403 Forbidden            - Insufficient permissions
404 Not Found            - Resource not found
409 Conflict             - Version mismatch
429 Too Many Requests    - Rate limit exceeded
500 Internal Error       - Server error
```

### Common Headers
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
Cookie: JSESSIONID={session}
X-CSRF-Token: {token}
X-Requested-With: XMLHttpRequest
```

---

**End of Knowledge Base**
