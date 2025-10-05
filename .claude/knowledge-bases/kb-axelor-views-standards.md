# Knowledge Base: Axelor Views Standards (Nomenclature Officielle)

**Version**: 1.0.0
**Axelor Version**: 8.3.15 / AOP 7.4
**Date**: 2025-10-05
**Purpose**: Référence exhaustive des noms de vues standards Axelor pour éviter erreurs de naming

---

## 🎯 Règle d'Or

**❌ NE JAMAIS inventer des noms de vues**
**✅ TOUJOURS utiliser les vues standards existantes**

Si une vue standard existe pour ton cas d'usage, **tu DOIS l'utiliser**.

---

## 📋 Pattern de Naming Axelor

### Format Standard
```
{model}-{variant}-{type}
```

**Exemples** :
- `partner-grid` → Modèle Partner, variant standard, type grid
- `partner-contact-grid` → Modèle Partner, variant contact, type grid
- `partner-customer-form` → Modèle Partner, variant customer, type form

### Types de Vues
- `grid` → Liste/tableau
- `form` → Formulaire
- `cards` → Vue cartes
- `kanban` → Vue kanban
- `calendar` → Calendrier
- `chart` → Graphique
- `search-filters` → Filtres recherche
- `dashboard` → Tableau de bord

---

## 🏢 Module: axelor-base

### Partner (com.axelor.apps.base.db.Partner)

#### Vues Grid
```yaml
partner-grid:
  description: Liste de tous les partners (entreprises + contacts)
  usage: Vue générale partners

partner-contact-grid:
  description: Liste des contacts (personnes, isContact=true)
  usage: Afficher uniquement les contacts/personnes
  domain_suggested: self.isContact = true AND self.isEmployee = false

partner-customer-grid:
  description: Liste des clients (isCustomer=true)
  usage: Afficher uniquement les clients
  domain_suggested: self.isCustomer = true

partner-supplier-grid:
  description: Liste des fournisseurs (isSupplier=true)
  usage: Afficher uniquement les fournisseurs
  domain_suggested: self.isSupplier = true

partner-related-contact-grid:
  description: Liste contacts liés à un partner
  usage: Panel contacts d'une entreprise
  module: axelor-crm

sync-contact-grid:
  description: Contacts synchronisés (Gmail, etc.)
  usage: Synchronisation contacts externes
```

#### Vues Form
```yaml
partner-form:
  description: Formulaire partner standard (entreprise)
  usage: Création/édition entreprise

partner-contact-form:
  description: Formulaire contact (personne)
  usage: Création/édition contact/personne
  note: Plusieurs définitions (base + crm), CRM prioritaire

partner-customer-form:
  description: Formulaire client
  usage: Vue spécifique client (si besoin champs custom)

partner-supplier-form:
  description: Formulaire fournisseur
  usage: Vue spécifique fournisseur
```

#### Autres Vues
```yaml
partner-contact-cards:
  type: cards
  description: Vue cartes contacts

contact-filters:
  type: search-filters
  description: Filtres recherche contacts

base.contact.dashboard:
  type: dashboard
  description: Dashboard contacts
```

---

## 📞 Module: axelor-crm

### Lead (com.axelor.apps.crm.db.Lead)

```yaml
lead-grid:
  type: grid
  description: Liste des leads

lead-form:
  type: form
  description: Formulaire lead

lead-kanban:
  type: kanban
  description: Vue kanban leads par statut
```

### Opportunity (com.axelor.apps.crm.db.Opportunity)

```yaml
opportunity-grid:
  type: grid
  description: Liste des opportunités

opportunity-form:
  type: form
  description: Formulaire opportunité

opportunity-kanban:
  type: kanban
  description: Vue kanban opportunités
```

### Event (com.axelor.apps.crm.db.Event)

```yaml
event-grid:
  type: grid
  description: Liste des événements

event-form:
  type: form
  description: Formulaire événement

event-calendar:
  type: calendar
  description: Calendrier événements

event-attendee-contact-grid:
  type: grid
  description: Contacts participants événement

event-attendee-contact-form:
  type: form
  description: Formulaire participant contact
```

---

## 💰 Module: axelor-sale

### SaleOrder (com.axelor.apps.sale.db.SaleOrder)

```yaml
sale-order-grid:
  type: grid
  description: Liste commandes client

sale-order-form:
  type: form
  description: Formulaire commande client

sale-order-line-grid:
  type: grid
  description: Lignes commande (dans formulaire)
```

### Quotation

```yaml
quotation-grid:
  type: grid
  description: Liste des devis

quotation-form:
  type: form
  description: Formulaire devis
```

---

## 📦 Module: axelor-stock

### StockMove (com.axelor.apps.stock.db.StockMove)

```yaml
stock-move-grid:
  type: grid
  description: Liste mouvements stock

stock-move-form:
  type: form
  description: Formulaire mouvement stock
```

---

## ⚠️ Pièges Fréquents (ERREURS À ÉVITER)

### Erreur #1 : Noms Abrégés
```yaml
# ❌ INCORRECT
contact-grid
contact-form

# ✅ CORRECT
partner-contact-grid
partner-contact-form
```

**Raison** : Axelor préfixe toujours par le modèle (`partner-`)

---

### Erreur #2 : Inventions Créatives
```yaml
# ❌ INCORRECT (n'existe pas)
all-partners-grid
customer-list-grid
partner-company-grid

# ✅ CORRECT (vues standards)
partner-grid
partner-customer-grid
partner-grid (avec domain filter)
```

**Raison** : Utiliser vues existantes, domaines pour filtrer

---

### Erreur #3 : Casse Incorrecte
```yaml
# ❌ INCORRECT
Partner-Grid          # PascalCase
partnerGrid           # camelCase
PARTNER_GRID          # UPPER_SNAKE_CASE

# ✅ CORRECT
partner-grid          # kebab-case (lowercase)
```

---

## 🔍 Comment Trouver les Vues Disponibles

### Méthode 1 : Chercher dans JARs Déployés

```bash
# Lister toutes les vues Partner
docker-compose exec axelor find /usr/local/tomcat/webapps/ROOT/WEB-INF/lib \
  -name "axelor-base*.jar" -o -name "axelor-crm*.jar" | \
  xargs -I {} jar tf {} | grep -i "partner.*\.xml"

# Lister vues d'un module spécifique
docker cp axelor-vecia-app:/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/axelor-base-8.3.15.jar /tmp/
unzip -l /tmp/axelor-base-8.3.15.jar | grep -i "views/.*\.xml"
```

### Méthode 2 : Consulter GitHub Axelor Open Suite

```bash
# URL template
https://github.com/axelor/axelor-open-suite/blob/master/axelor-{module}/src/main/resources/views/{Model}.xml

# Exemples
https://github.com/axelor/axelor-open-suite/blob/master/axelor-base/src/main/resources/views/Partner.xml
https://github.com/axelor/axelor-open-suite/blob/master/axelor-crm/src/main/resources/views/Lead.xml
```

### Méthode 3 : Query PostgreSQL

```sql
-- Lister toutes les vues Partner en DB
SELECT name, type, module
FROM meta_view
WHERE name LIKE '%partner%'
ORDER BY module, type, name;

-- Vues d'un type spécifique
SELECT name, module
FROM meta_view
WHERE type = 'grid' AND name LIKE '%contact%';
```

---

## 📐 Best Practices - Action-View

### Template Correct
```xml
<action-view name="action-custom-view-contacts" title="My Contacts"
  model="com.axelor.apps.base.db.Partner">
  <!-- ✅ Utiliser vues standards existantes -->
  <view type="grid" name="partner-contact-grid"/>
  <view type="form" name="partner-contact-form"/>

  <!-- ✅ Filtrer avec domain -->
  <domain>self.isContact = true AND self.isEmployee = false</domain>

  <context name="_showRecord" expr="eval: id"/>
</action-view>
```

### Anti-Pattern (À ÉVITER)
```xml
<action-view name="action-custom-view-contacts" title="My Contacts"
  model="com.axelor.apps.base.db.Partner">
  <!-- ❌ Vues inexistantes -->
  <view type="grid" name="contact-grid"/>
  <view type="form" name="contact-form"/>

  <domain>self.isContact = true</domain>
</action-view>
```

**Résultat** : Erreur 500 "View contact-grid doesn't exist"

---

## 🛠️ Troubleshooting

### Erreur: "View {name} doesn't exist"

**Diagnostic** :
1. Vérifier si vue existe dans standards Axelor (ce KB)
2. Si non : chercher dans JARs déployés (Méthode 1)
3. Si non : consulter GitHub (Méthode 2)
4. Si non : query meta_view en DB (Méthode 3)

**Solution** :
- Si vue existe : corriger le nom dans ton XML
- Si vue n'existe pas : utiliser vue standard proche + domain filter
- Dernier recours : créer vue custom (mais éviter si possible)

---

### Erreur: Vue Pas Importée Après Modification

**Symptômes** :
- Module chargé
- Aucun import dans logs
- Anciennes vues persistent

**Cause** : Cache Axelor DB

**Solution** :
```sql
-- Supprimer vues custom module
DELETE FROM meta_view WHERE module = 'axelor-vecia-crm';
DELETE FROM meta_action WHERE module = 'axelor-vecia-crm';
DELETE FROM meta_menu WHERE module = 'axelor-vecia-crm';
```

Puis restart container :
```bash
docker-compose restart axelor
```

---

## 📊 Checklist Pré-Création Action-View

Avant de créer une action-view avec vues :

- [ ] Consulter ce KB pour noms de vues standards
- [ ] Vérifier modèle cible (Partner, Lead, SaleOrder, etc.)
- [ ] Identifier variant approprié (contact, customer, supplier, etc.)
- [ ] Utiliser vues standards existantes
- [ ] Si besoin filtrage : utiliser `<domain>` au lieu de créer nouvelle vue
- [ ] Valider noms de vues (kebab-case, lowercase, préfixe modèle)
- [ ] Tester après import (vérifier meta_view en DB)

---

## 📚 Références

### Documentation Officielle
- [Axelor Views Documentation](https://docs.axelor.com/adk/7.4/dev-guide/views/)
- [Axelor Open Suite GitHub](https://github.com/axelor/axelor-open-suite)

### Documentation Interne
- `.claude/agents/agent-customization.md` - Workflow customisation code
- `.claude/knowledge-bases/kb-lowcode-standards.md` - Naming conventions
- `.claude/knowledge-bases/kb-crm-customization.md` - Spécifications CRM

---

## 🔄 Maintenance

**Fréquence Update** : À chaque upgrade majeur Axelor (8.x → 9.x)

**Méthode** :
1. Re-scanner JARs modules (base, crm, sale, stock)
2. Comparer avec version précédente
3. Ajouter nouvelles vues standards
4. Marquer vues dépréciées

---

**Dernière mise à jour** : 2025-10-05
**Validé avec** : Axelor 8.3.15, AOP 7.4
**Auteur** : Claude Code (session contact-grid fix)
