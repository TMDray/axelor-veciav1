# Agents & Knowledge Bases - Architecture Guide

**Version**: 1.0
**Date**: 2025-10-03
**Architecture**: Knowledge Base + Routing Agents (Agentic RAG Pattern)

---

## 📐 Architecture Overview

This project implements a **modular agent architecture** following 2025 best practices for AI agent systems:

```
User Question
      ↓
[Routing Agent] ← Determines which KB(s) to access
      ↓
[Knowledge Bases] ← Pure technical/functional knowledge (no duplication)
      ↓
[Synthesized Response] ← Agent combines KB info + context
```

**Key Principles**:
- ✅ **Zero Duplication**: Technical knowledge documented once in KBs
- ✅ **Agentic RAG**: Agents dynamically decide which KB to retrieve from
- ✅ **Scalable**: N modules = +N KBs, not +N full agents
- ✅ **Maintainable**: Update KB once, all agents benefit
- ✅ **Specialized**: Each agent has clear domain expertise

---

## 📚 Knowledge Bases (Pure Technical Reference)

Located in: `.claude/knowledge-bases/`

### Technical Knowledge Bases

#### 1. **kb-studio-architecture.md** (823 lines)
**Content**:
- Axelor Studio architecture (MetaJsonField, JSON storage)
- Custom field types (String, Integer, Decimal, Boolean, Date, Relations, Selection, Enum)
- 76 Studio tables + 37 Meta tables reference
- SQL queries for custom fields (CRUD, statistics, export)
- Conditional fields (show_if, hide_if, required_if)
- Best practices and troubleshooting

**When to use**:
- Creating/querying custom fields
- Understanding Studio data model
- SQL operations on custom data

---

#### 2. **kb-bpm-workflows.md**
**Content**:
- BPMN 2.0 components (Events, Activities, Gateways, Sub-processes)
- Groovy scripting complete reference
- Context available (execution, __ctx__, __user__, __date__)
- Repository access patterns
- Custom field manipulation in Groovy
- 5+ complete script examples
- Workflow patterns (Sequential, Conditional, Parallel, Escalation, Retry)
- Configuration (timer formats ISO-8601, conditions, deployment)
- Monitoring and debugging

**When to use**:
- Creating BPM workflows
- Writing Groovy scripts
- Automating business processes

---

#### 3. **kb-integrations-apis.md**
**Content**:
- API REST Axelor (/ws/rest/:model, /ws/action/:action, /ws/meta/fields)
- CRUD operations (GET, POST, DELETE)
- Filter operators (=, !=, >, <, like, in, isNull, etc.)
- Authentication (Session Cookie, Basic Auth, OAuth2)
- Webhooks (outgoing: Axelor → External, incoming: External → Axelor)
- Axelor Connect (1500+ connectors: CRM, Cloud, Payment, etc.)
- Web Services Studio configuration
- Integration patterns (sync, async, batch, event-driven)
- Security best practices (rate limiting, signature verification, encryption)
- Monitoring and troubleshooting

**When to use**:
- API integration development
- External system connections
- Webhook setup

---

### Business/Functional Knowledge Bases

#### 4. **kb-crm-customization.md**
**Content**:
- Custom fields for AI agency (Lead: maturité IA, budget, stack technique, urgence)
- Custom fields for Opportunity (service type, complexity, pricing model)
- Workflows (lead scoring auto, hot lead assignment, follow-up automation)
- Views and dashboards (pipeline IA, maturity matrix, top leads)
- AI services catalog (7 services: ML Custom, POC, Chatbot, Computer Vision, NLP, Conseil)
- Integrations (LinkedIn Lead Sync, Gmail, Calendar, DocuSign)
- Reports and analytics (funnel conversion, sales performance, CLV)
- Best practices for AI agency CRM

**When to use**:
- Configuring CRM for AI agency
- Lead qualification and scoring
- AI services sales management

---

#### 5. **kb-sales-customization.md**
**Content**:
- Custom fields Sale Order (mode facturation, contract type, NDA, IP ownership, SLA)
- 4 pricing models (Forfait, Régie, Abonnement, Success Fee)
- Contract management (NDA, Service Contract, SaaS templates)
- IP ownership options (Client, Agency, Shared, License)
- Milestone-based invoicing (auto-generation on validation)
- Discount management (volume, loyalty, early payment)
- Sales analytics (revenue by service, forecast, CLV, payment terms)
- Quote generation for AI projects (estimation engine)
- Best practices (pricing strategy, negotiation, upsell)

**When to use**:
- Configuring Sales for AI agency
- Pricing and contract setup
- Invoice and billing management

---

## 🤖 Specialized Agents

Located in: `.claude/agents/`

### 1. **agent-lowcode.md** (Router Agent)

**Type**: Routing Agent (Agentic RAG)
**Expertise**: Axelor low-code/no-code technical implementation

**Role**:
- Analyze user requests (Studio, BPM, Integrations)
- Route to appropriate KB(s)
- Access KBs dynamically (never duplicate content)
- Synthesize information from multiple KBs if needed

**When to use**:
- "How do I create a custom field?"
- "Show me Groovy script for lead scoring"
- "How to call Axelor REST API?"
- "Create workflow + external API call"

**Routing Matrix**:
| Request Type | Primary KB | Secondary KB |
|-------------|-----------|-------------|
| Custom field creation | Studio | - |
| Workflow creation | BPM | - |
| API integration | Integrations | - |
| Custom field + workflow | Studio | BPM |
| Workflow + API call | BPM | Integrations |
| Full automation | Studio | BPM + Integrations |

**Collaboration**:
- Delegates to business agents for functional requirements
- Provides technical implementation details

---

### 2. **agent-crm.md** (CRM Configuration Agent)

**Type**: Business/Functional Agent
**Expertise**: CRM & Sales configuration for AI agency

**Role**:
- Define functional requirements (what data to capture)
- Design business processes (lead qualification, opportunity management)
- Configure CRM/Sales modules
- Guide on best practices for AI services sales

**When to use**:
- "What custom fields do I need for AI leads?"
- "How should I configure lead qualification?"
- "What's the best pricing model for AI projects?"
- "CRM best practices for AI agency"

**Key Capabilities**:
- Lead management setup (fields, scoring criteria, qualification)
- Opportunity configuration (service types, complexity, milestones)
- Sales pipeline design (stages, progression criteria)
- AI services catalog definition
- Pricing strategy guidance (forfait vs régie vs subscription)
- Contract management (NDA, IP, SLA)
- Reports and analytics setup

**Collaboration**:
- Defines functional requirements
- Delegates technical implementation to agent-lowcode
- Uses kb-crm-customization.md and kb-sales-customization.md

---

### 3. **agent-data-management.md** (Data Management Agent)

**Type**: Specialized Agent
**Expertise**: Data import, export, migration, transformation, bulk operations

**Role**:
- Import data from external sources (CSV, Excel, databases, APIs)
- Export data to various formats
- Migrate data from legacy systems
- Clean and transform data
- Execute bulk operations (mass updates, deletions)
- Backup and restore

**When to use**:
- "Import 5,000 leads from CSV"
- "Migrate data from Salesforce"
- "Clean up duplicate leads"
- "Bulk update all leads from last month"
- "Backup database before deployment"

**Key Capabilities**:
- CSV/Excel import (Axelor data-config.xml)
- Database migration (SQL → Axelor via Groovy)
- API import (programmatic bulk import)
- Data export (CSV, JSON, SQL)
- Data transformation (normalization, cleaning)
- Deduplication (merge duplicates by email)
- Bulk operations (mass update/delete via API or SQL)
- Data validation (quality checks, business rules)
- Backup and restore (PostgreSQL dumps, JSON exports)

**Collaboration**:
- Can use kb-studio-architecture.md to understand data model
- Can use kb-integrations-apis.md for API imports/exports
- Delegates technical questions to agent-lowcode

---

### 4. **agent-deploiement.md** (Deployment Agent)

**Type**: Specialized Agent
**Expertise**: Deployment, infrastructure, DevOps

**Role**:
- Deploy Axelor to different environments (dev, test, prod)
- Configure infrastructure (Docker, databases, networking)
- Build and package applications
- Monitor application health
- Troubleshoot deployment issues

**When to use**:
- "Deploy to test server"
- "Setup Docker Compose"
- "Troubleshoot slow performance"
- "Check application health"
- "Configure production environment"

**Key Capabilities**:
- Local development setup (Gradle, PostgreSQL)
- Docker Compose configuration (multi-container setup)
- Remote deployment (HPE server via Tailscale VPN)
- Health checks and monitoring (logs, metrics, alerts)
- Troubleshooting (connection issues, performance, errors)
- Security best practices (passwords, HTTPS, firewall)
- Backup and restore procedures

**Environments**:
- **Dev**: MacBook Pro local (Gradle run)
- **Test**: HPE ProLiant ML30 Gen11 via Tailscale (100.124.143.6)
- **Production**: To be defined

**Collaboration**:
- Deploys code developed by other agents
- Handles infrastructure and DevOps
- Independent of KBs (infrastructure knowledge built-in)

---

## 🔄 Agent Collaboration Patterns

### Pattern 1: Functional → Technical Handoff

```
User: "I need to implement lead scoring for AI agency"

agent-crm (Functional):
  ↓ Defines business requirements:
    - Scoring algorithm (maturité 0-40pts, budget 0-30pts, urgence 0-20pts)
    - Thresholds (Hot ≥70, Warm 40-69, Cold <40)
    - Actions by score (assignment, follow-up, nurturing)
  ↓ Hands off to technical agent

agent-lowcode (Technical):
  ↓ Accesses kb-studio-architecture.md (custom field creation)
  ↓ Accesses kb-bpm-workflows.md (Groovy script)
  ↓ Provides implementation:
    - Studio: Create "leadScoringIA" field (Integer, readonly)
    - BPM: Create workflow with Groovy script
    - SQL: Queries to monitor scoring
```

### Pattern 2: Multi-KB Technical Request

```
User: "Create custom field + workflow to auto-populate it + expose via API"

agent-lowcode (Router):
  ↓ Identifies multi-KB request
  ↓ Accesses kb-studio-architecture.md (custom field)
  ↓ Accesses kb-bpm-workflows.md (workflow)
  ↓ Accesses kb-integrations-apis.md (API)
  ↓ Synthesizes complete solution:
    - Part 1: Custom field creation
    - Part 2: Workflow to populate
    - Part 3: API endpoint exposure
```

### Pattern 3: Data + Deployment

```
User: "Import 10,000 leads and deploy to test server"

agent-data-management:
  ↓ Handles data import:
    - Validates CSV format
    - Creates data-config.xml
    - Executes import
    - Validates results
  ↓ Notifies deployment agent

agent-deploiement:
  ↓ Deploys to test server:
    - Builds application
    - Copies to HPE server via Tailscale
    - Starts Docker services
    - Validates deployment
```

---

## 🎯 Decision Tree: Which Agent to Use?

```
Question about...

┌─ Low-code/Technical (How to implement?)
│  └─> agent-lowcode
│      ├─ Custom fields → kb-studio-architecture.md
│      ├─ Workflows → kb-bpm-workflows.md
│      └─ APIs/Integrations → kb-integrations-apis.md
│
├─ CRM/Sales Configuration (What to configure?)
│  └─> agent-crm
│      ├─ Lead/Opportunity setup → kb-crm-customization.md
│      └─ Pricing/Contracts → kb-sales-customization.md
│
├─ Data Operations (Import/Export/Migration?)
│  └─> agent-data-management
│      └─ Uses KBs to understand data model
│
└─ Deployment/Infrastructure (Where/How to deploy?)
   └─> agent-deploiement
       └─ Built-in infrastructure knowledge
```

---

## 📖 How to Use This Architecture

### For Users (Project Team):

1. **Ask your question naturally** - Claude will route automatically
2. **Start with functional agent** if defining requirements
3. **Use technical agent** if implementing
4. **Trust the routing** - Agents know which KBs to access

### For Developers (Claude Code):

1. **Read agent description** - Understand its scope
2. **Check KB access rules** - Know which KBs to use
3. **Follow collaboration patterns** - Delegate when appropriate
4. **Never duplicate KB content** - Always reference, never copy

---

## 🏗️ Architecture Benefits

### ✅ Zero Duplication
- Technical knowledge documented once
- All agents access same source of truth
- Update KB → All agents benefit immediately

### ✅ Scalable
- Add new module? Create 1 KB + small agent
- Not: Create full agent with duplicated tech knowledge

### ✅ Maintainable
- Clear separation: KBs (knowledge) vs Agents (routing + context)
- Easy to update single KB
- Easy to add new agents

### ✅ Follows 2025 Best Practices
- Agentic RAG pattern (agent decides which knowledge to retrieve)
- Modular architecture (requirement for multi-agent systems)
- Hierarchical with shared knowledge bases

---

## 📂 File Organization

```
.claude/
├── knowledge-bases/               # Pure technical/functional knowledge
│   ├── kb-studio-architecture.md  # Studio, custom fields, MetaJsonField
│   ├── kb-bpm-workflows.md        # BPMN 2.0, Groovy scripting
│   ├── kb-integrations-apis.md    # API REST, webhooks, connectors
│   ├── kb-crm-customization.md    # CRM for AI agency
│   └── kb-sales-customization.md  # Sales for AI agency
│
├── agents/                        # Specialized routing/functional agents
│   ├── agent-lowcode.md           # Technical router (Studio, BPM, Integrations)
│   ├── agent-crm.md               # CRM functional configuration
│   ├── agent-data-management.md   # Data import/export/migration
│   ├── agent-deploiement.md       # Deployment and infrastructure
│   ├── README.md                  # This file
│   └── ARCHITECTURE.md            # Detailed architecture documentation
│
└── agents-backup/                 # Old architecture (preserved for reference)
    ├── agent-studio.md            # Former technical agent (deprecated)
    ├── agent-bpm.md               # Former BPM agent (deprecated)
    ├── agent-integrations.md      # Former integration agent (deprecated)
    └── agent-configuration-crm.md # Former CRM agent (deprecated)
```

---

## 🔮 Future Enhancements

### Potential New Agents:
- `agent-finance.md`: Financial module configuration (accounting, invoicing)
- `agent-hr.md`: HR module configuration (employees, timesheets)
- `agent-testing.md`: Automated testing and quality assurance

### Potential New KBs:
- `kb-finance-customization.md`: Financial module customization for AI agency
- `kb-hr-customization.md`: HR module customization
- `kb-security.md`: Security best practices and configurations

### Architectural Improvements:
- Agent-to-agent communication protocol
- KB versioning and change tracking
- Automated KB consistency validation
- Performance metrics per agent

---

## 📊 Metrics and Success Criteria

### Agent Performance:
- **Routing Accuracy**: Correct KB(s) selected for request
- **Response Completeness**: All necessary information provided
- **Code Quality**: Working, tested examples from KBs
- **Efficiency**: No unnecessary KB reads

### Architecture Success:
- ✅ Zero content duplication across agents
- ✅ Clear agent specialization boundaries
- ✅ Consistent KB updates (no outdated info)
- ✅ Easy onboarding (new developers understand quickly)

---

## 🆘 Support

### For Technical Questions:
- Consult `agent-lowcode.md`
- Read relevant KB directly (`.claude/knowledge-bases/`)

### For Functional Questions:
- Consult `agent-crm.md`
- Read business KB (kb-crm-customization.md, kb-sales-customization.md)

### For Architecture Questions:
- Read `ARCHITECTURE.md` (detailed architectural documentation)
- Consult this README

### For Deployment Questions:
- Consult `agent-deploiement.md`
- Check deployment scripts in `scripts/`

---

## 📝 Version History

**v1.0** (2025-10-03):
- Initial architecture implementation
- 5 Knowledge Bases created
- 4 Specialized Agents created
- KB + Router pattern established
- Zero duplication achieved

---

**Last Updated**: 2025-10-03
**Maintained By**: Project Team
**Architecture Pattern**: Knowledge Base + Routing Agents (Agentic RAG)
