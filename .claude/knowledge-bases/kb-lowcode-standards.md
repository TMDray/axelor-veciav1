# Knowledge Base : Low-Code Standards & Governance

**Type** : Pure Technical Reference (no agent narrative)
**Version Axelor** : 8.3.15 / AOP 7.4
**Scope** : Low-code configuration standards, naming conventions, governance
**Usage** : Accessed by agent-configuration for validation

---

## 1. Naming Conventions

### 1.1 Custom Fields

**Format** : `camelCase` (première lettre minuscule)

**Pattern** : `[contextOptional][concept][Type]`

**Exemples** :
```
✅ statutContact          // Statut du contact
✅ niveauMaturiteIA       // Niveau maturité IA
✅ budgetIA               // Budget IA
✅ dateDebutRelation      // Date début relation
✅ tauxTVAPersonnalise    // Taux TVA personnalisé
✅ isClientActif          // Boolean (préfixe "is")
✅ hasEquipeData          // Boolean (préfixe "has")
✅ enableNotifications    // Boolean (préfixe "enable")
```

**Anti-Patterns** :
```
❌ statut_contact         // Underscore interdit
❌ Statut Contact         // Espaces interdits
❌ StatutContact          // PascalCase (réservé classes Java)
❌ statutContâct          // Accents interdits
❌ sc                     // Abréviation obscure
❌ status                 // Anglais/Français mixte (choisir une langue)
```

**Règles** :
- ✅ Caractères autorisés : `a-z`, `A-Z`, `0-9`
- ❌ Caractères interdits : `_`, `-`, ` `, accents, caractères spéciaux
- ✅ Longueur : 5-30 caractères recommandé
- ✅ Suffixe type optionnel pour clarté : `Date`, `Amount`, `Rate`, `Count`
- ✅ Préfixe booléen obligatoire : `is`, `has`, `enable`, `allow`

### 1.2 Selections (Meta Select)

**Format** : `kebab-case` avec préfixe module

**Pattern** : `[module]-[entity]-[concept]-select`

**Exemples** :
```
✅ crm-partner-statut-select
✅ crm-lead-maturite-ia-select
✅ sale-opportunity-type-select
✅ base-partner-infrastructure-select
✅ hr-employee-contract-type-select
```

**Anti-Patterns** :
```
❌ partner_status_select  // Underscores
❌ PartnerStatusSelect    // PascalCase
❌ partner-status         // Manque suffixe "-select"
❌ statutPartner          // Mélange casse
❌ crm-statut-select      // Manque entity (trop générique)
```

**Règles** :
- ✅ Format : `[module]-[entity]-[concept]-select`
- ✅ Séparateur : `-` (tiret/kebab-case)
- ✅ Suffixe obligatoire : `-select`
- ✅ Longueur : 15-50 caractères
- ✅ Tout minuscules

### 1.3 Selection Values (Option Values)

**Format** : `kebab-case`, lowercase

**Exemples** :
```
✅ prospect
✅ client-actif
✅ client-inactif
✅ ancien-client
✅ niveau-expert
✅ urgence-haute
```

**Anti-Patterns** :
```
❌ "Client Actif"         // Espaces interdits
❌ CLIENT_ACTIF           // Underscore + majuscules
❌ clientActif            // camelCase (réservé custom fields)
❌ client actif           // Espaces
❌ client-Actif           // Casse mixte
```

**Règles** :
- ✅ Tout minuscules (lowercase)
- ✅ Séparateur : `-` (tiret)
- ❌ Pas d'espaces, underscores, caractères spéciaux
- ✅ Longueur : 3-30 caractères
- ✅ Langue cohérente (français OU anglais, pas mixte)

**Labels (Affichage UI)** :
Les labels peuvent contenir espaces, majuscules, accents :
```xml
<option value="client-actif">Client Actif</option>
<option value="niveau-expert">Niveau Expert (Data Science Interne)</option>
```

### 1.4 Custom Models

**Format** : `PascalCase` (Java class convention)

**Pattern** : `[Module][Concept]`

**Exemples** :
```
✅ CrmServiceIA          // Service IA (CRM)
✅ SaleContractTemplate  // Template contrat (Sales)
✅ HrSkillMatrix         // Matrice compétences (HR)
```

**Règles** :
- ✅ PascalCase (première lettre majuscule)
- ✅ Préfixe module optionnel
- ✅ Nom singulier (ServiceIA, pas ServicesIA)

### 1.5 Buttons & Actions

**Format** : `kebab-case` avec préfixe action

**Pattern** : `action-[entity]-[verb]-[object]`

**Exemples** :
```
✅ action-lead-convert-to-opportunity
✅ action-partner-calculate-score
✅ action-invoice-generate-pdf
✅ btn-send-email                      // Bouton UI
```

---

## 2. Anti-Patterns à Éviter

### 2.1 Duplication Booléens vs Selection

**Problème** :
```xml
<!-- Anti-pattern -->
<boolean name="isProspect"/>
<boolean name="isCustomer"/>
<boolean name="isSupplier"/>
<field name="statutContact" type="selection"/> <!-- prospect, client, fournisseur -->
```
→ **Redondance** : 2 manières de représenter le même concept
→ **Incohérence** : isProspect=true mais statutContact="client" ?

**Solutions** :

**Option A** : Booléens natifs uniquement (simple mais limité)
```xml
<boolean name="isProspect"/>
<boolean name="isCustomer"/>
```
✅ Avantages : Compatible modules Axelor natifs
❌ Inconvénients : Pas de notion "ancien client", "client inactif"

**Option B** : Selection custom uniquement (recommandé cycle de vie)
```xml
<field name="statutContact" type="selection" selection="crm-partner-statut-select"/>
<!-- Valeurs : prospect, client-actif, client-inactif, ancien-client -->
```
✅ Avantages : Cycle de vie explicite, un statut unique clair
❌ Inconvénients : Coexistence avec booléens natifs (possible confusion)

**Option C** : Hybride avec synchronisation (avancé)
```xml
<field name="statutContact" type="selection" selection="crm-partner-statut-select"/>
<boolean name="isProspect" readonly="true"/> <!-- Calculé automatiquement -->
<boolean name="isCustomer" readonly="true"/> <!-- Calculé automatiquement -->
```
+ **Workflow BPM** qui synchronise :
```groovy
// Si statutContact change
if (partner.statutContact == 'prospect') {
  partner.isProspect = true
  partner.isCustomer = false
}
if (partner.statutContact in ['client-actif', 'client-inactif', 'ancien-client']) {
  partner.isProspect = false
  partner.isCustomer = true
}
```
✅ Avantages : Compatible modules natifs + cycle de vie explicite
❌ Inconvénients : Plus complexe, nécessite workflow

**Décision** : Documenter dans `configuration-registry.md` (section Décisions Architecturales)

### 2.2 Sélections avec Espaces

**Problème** :
```xml
<option value="Client Actif">Client Actif</option>
```
→ **Requêtes SQL complexes** : `WHERE attrs->>'statut' = 'Client Actif'` (espaces)
→ **Bugs potentiels** : Sensible casse, trim, encodage

**Solution** :
```xml
<option value="client-actif">Client Actif</option>
```
→ **Requêtes SQL propres** : `WHERE attrs->>'statut' = 'client-actif'`

### 2.3 Valeurs Non Documentées

**Problème** :
```xml
<!-- Sélection créée sans documentation -->
<selection name="crm-partner-type-select">
  <option value="a">Type A</option>
  <option value="b">Type B</option>
</selection>
```
→ Que signifie "Type A" ? Quelle utilisation ?

**Solution** :
Toujours documenter dans `configuration-registry.md` :
```markdown
### crm-partner-type-select
- **Valeur** : `a`
- **Libellé** : Type A
- **Description** : Partenaire stratégique (CA > 100k€)
- **Utilisation** : Dashboard partenaires, workflow escalade
```

### 2.4 Champs Orphelins

**Problème** :
Champ créé pour un besoin ponctuel puis jamais utilisé.
→ Pollution modèle, performances, confusion

**Solution** :
- Review trimestrielle : Lister champs non utilisés (requête SQL)
- Marquer obsolète dans registry
- Supprimer si confirmé inutile

```sql
-- Identifier champs jamais renseignés
SELECT jsonb_object_keys(attrs) AS field_name, COUNT(*) AS usage_count
FROM base_partner
WHERE attrs IS NOT NULL
GROUP BY field_name
ORDER BY usage_count ASC;
```

### 2.5 Longueur Excessive

**Problème** :
```
❌ niveauMaturiteIntelligenceArtificielleDeLEntrepriseCliente (62 caractères)
```
→ Difficile à lire, erreurs typo

**Solution** :
```
✅ niveauMaturiteIA (16 caractères)
```
→ Contexte clair via documentation registry

---

## 3. Workflow de Validation

### 3.1 Avant Création Custom Field

**Checklist** :
1. ✅ Consulter `configuration-registry.md` → Existe déjà ?
2. ✅ Vérifier naming convention → camelCase OK ?
3. ✅ Type approprié → String, Selection, Decimal, Boolean ?
4. ✅ Requis ou optionnel ? Défaut ?
5. ✅ Conditions affichage → show_if, hide_if ?

**Validation Naming** :
```
Question : Nom du champ ?
Réponse : "statutContact"

Validation :
✅ camelCase → OK
✅ Pas d'underscore → OK
✅ Pas d'espace → OK
✅ Pas d'accent → OK
✅ Longueur 14 caractères → OK
✅ Concept clair → OK

Approuvé ✓
```

### 3.2 Après Création (Documentation)

**Mettre à jour registry** :
```markdown
### statutContact
- **ID Technique** : 12345 (généré par Studio)
- **Type** : Selection
- **Selection** : crm-partner-statut-select
- **Table** : base_partner
- **Date création** : 2025-10-03
- **Créé par** : Tanguy
- **Objectif** : Gérer cycle de vie contact
```

### 3.3 Review Mensuelle

**Actions** :
1. Lister nouveaux champs créés (changelog registry)
2. Vérifier utilisation réelle (requêtes SQL)
3. Identifier champs obsolètes (jamais renseignés)
4. Mettre à jour documentation si évolution

---

## 4. Best Practices par Type

### 4.1 Boolean

**Naming** :
- ✅ Préfixe obligatoire : `is`, `has`, `enable`, `allow`, `require`
- ✅ Exemples : `isProspect`, `hasDataTeam`, `enableNotifications`
- ❌ Anti-pattern : `prospect` (ambigu), `dataTeam` (pas clair que boolean)

**Valeur par défaut** :
- Toujours définir : `default="false"` ou `default="true"`

**Usage** :
- Statut binaire simple (oui/non, actif/inactif)
- Si plus de 2 états → Utiliser **Selection**

### 4.2 Selection

**Nombre de valeurs** :
- ✅ Idéal : 3-7 valeurs
- ⚠️ Acceptable : 8-15 valeurs
- ❌ Trop : > 15 valeurs → Considérer **Many-to-One** (table référence)

**Ordre des valeurs** :
- ✅ Logique métier (cycle de vie, sévérité, chronologique)
- ✅ Exemples :
  - Cycle : `prospect → client-actif → client-inactif → ancien-client`
  - Sévérité : `faible → moyenne → haute → critique`
- ❌ Anti-pattern : Ordre alphabétique si illogique métier

**Valeur par défaut** :
- Définir si applicable : `default="prospect"`

**Évolution** :
- ✅ Ajouter valeur : OK, ajouter à la fin (séquence)
- ⚠️ Modifier valeur : Créer migration SQL
- ❌ Supprimer valeur utilisée : Jamais sans migration

### 4.3 String

**Max Size** :
- ✅ Texte court : 255 caractères max
- ✅ Texte long : Utiliser **Text** (multiline)
- ✅ Exemples :
  - Nom, email, téléphone : String (255)
  - Description, commentaire : Text (multiline)

**Validation** :
- ✅ Email : `regex="^[\w\.-]+@[\w\.-]+\.\w+$"`
- ✅ Téléphone FR : `regex="^(\+33|0)[1-9]\d{8}$"`
- ✅ Code postal : `regex="^\d{5}$"`

### 4.4 Decimal

**Precision & Scale** :
- ✅ Montant financier : `precision="10" scale="2"` → 99999999.99
- ✅ Taux/pourcentage : `precision="5" scale="2"` → 100.00
- ✅ Quantité : `precision="10" scale="3"` → 9999999.999

**Validation** :
- ✅ Min/Max : `min="0" max="100"` (pour pourcentage)

### 4.5 Date / DateTime

**Type** :
- ✅ Date seule : `type="date"` (YYYY-MM-DD)
- ✅ Date + Heure : `type="datetime"` (YYYY-MM-DD HH:mm:ss)

**Validation** :
- ✅ Date future : Workflow validation
- ✅ Plage de dates : `dateDebut` < `dateFin`

### 4.6 Many-to-One

**Quand utiliser** :
- ✅ Si > 15 valeurs possibles
- ✅ Si valeurs évolutives (ajout fréquent)
- ✅ Si valeurs avec métadonnées (code, description, actif/inactif)

**Configuration** :
```xml
<many-to-one name="typeService" ref="com.axelor.apps.custom.db.ServiceType"
             title="Type Service" />
```

**vs Selection** :
- Selection : 3-15 valeurs statiques
- Many-to-One : > 15 valeurs ou table référence évolutive

---

## 5. Migration & Évolution

### 5.1 Changement Valeur Selection

**❌ NE PAS** :
```sql
-- Modifier directement en base (casse tout)
UPDATE meta_select_item SET value = 'nouveau-nom' WHERE value = 'ancien-nom';
```

**✅ FAIRE** :
```sql
-- Script migration documenté
BEGIN;

-- 1. Mettre à jour données (attrs JSON)
UPDATE base_partner
SET attrs = jsonb_set(
  attrs,
  '{statutContact}',
  '"nouveau-nom"'::jsonb
)
WHERE attrs->>'statutContact' = 'ancien-nom';

-- 2. Mettre à jour meta_select_item
UPDATE meta_select_item
SET value = 'nouveau-nom'
WHERE value = 'ancien-nom'
  AND select_id = (SELECT id FROM meta_select WHERE name = 'crm-partner-statut-select');

COMMIT;
```

**Documenter** :
```markdown
### DA-003 : Renommage Valeur Selection
- Date : 2025-10-15
- Sélection : crm-partner-statut-select
- Changement : "client" → "client-actif"
- Raison : Clarté cycle de vie (actif vs inactif)
- Migration : Script SQL exécuté 2025-10-15
- Impactés : 1250 records Partner
```

### 5.2 Ajout Valeur Selection

**✅ FAIRE** :
```xml
<!-- Ajouter à la fin (préserver ordre) -->
<selection name="crm-partner-statut-select">
  <option value="prospect" sequence="10">Prospect</option>
  <option value="client-actif" sequence="20">Client Actif</option>
  <option value="client-inactif" sequence="30">Client Inactif</option>
  <option value="ancien-client" sequence="40">Ancien Client</option>
  <option value="partenaire-strategique" sequence="50">Partenaire Stratégique</option> <!-- NOUVEAU -->
</selection>
```

**Documenter** :
```markdown
### Changelog
2025-10-15 : Ajout valeur "partenaire-strategique" (séquence 50)
```

### 5.3 Suppression Valeur Selection

**❌ NE PAS** :
Supprimer valeur si utilisée en base de données.

**✅ FAIRE** :
1. Vérifier utilisation :
```sql
SELECT COUNT(*)
FROM base_partner
WHERE attrs->>'statutContact' = 'valeur-a-supprimer';
```

2. Si utilisée :
   - Option A : Marquer obsolète (ne pas supprimer)
   - Option B : Migrer vers autre valeur + documenter

3. Si non utilisée :
   - Supprimer de la sélection
   - Documenter dans changelog

### 5.4 Suppression Custom Field

**Workflow** :
1. Marquer obsolète dans registry (date)
2. Attendre 3 mois (période observation)
3. Si confirmé inutile :
```sql
-- Nettoyer données JSON
UPDATE base_partner
SET attrs = attrs - 'champObsolete';

-- Supprimer meta_json_field
DELETE FROM meta_json_field WHERE name = 'champObsolete';
```
4. Documenter suppression dans changelog

---

## 6. SQL Best Practices (Custom Fields)

### 6.1 Accès Custom Field JSON

**Lecture** :
```sql
-- Opérateur ->> : Retourne TEXT
SELECT attrs->>'niveauMaturiteIA' AS niveau
FROM crm_lead;

-- Cast si type numérique
SELECT CAST(attrs->>'budgetIA' AS DECIMAL) AS budget
FROM crm_lead;

-- Cast booléen
SELECT CAST(attrs->>'equipeData' AS BOOLEAN) AS has_team
FROM crm_lead;
```

**Filtrage** :
```sql
-- Égalité
WHERE attrs->>'statutContact' = 'client-actif'

-- Comparaison numérique (cast requis)
WHERE CAST(attrs->>'budgetIA' AS DECIMAL) >= 50000

-- Existence du champ
WHERE attrs ? 'niveauMaturiteIA'

-- NULL check
WHERE attrs->>'niveauMaturiteIA' IS NOT NULL
```

### 6.2 Index pour Performance

**Créer index sur custom field fréquemment filtré** :
```sql
-- Index GIN sur colonne JSON
CREATE INDEX idx_partner_attrs_gin ON base_partner USING GIN (attrs);

-- Index expression pour champ spécifique
CREATE INDEX idx_partner_statut
ON base_partner ((attrs->>'statutContact'));
```

### 6.3 Agrégations

**COUNT par valeur** :
```sql
SELECT
  attrs->>'statutContact' AS statut,
  COUNT(*) AS nb_partners
FROM base_partner
WHERE attrs ? 'statutContact'
GROUP BY attrs->>'statutContact'
ORDER BY nb_partners DESC;
```

**SUM / AVG** :
```sql
SELECT
  attrs->>'niveauMaturiteIA' AS niveau,
  AVG(CAST(attrs->>'budgetIA' AS DECIMAL)) AS budget_moyen,
  SUM(CAST(attrs->>'budgetIA' AS DECIMAL)) AS budget_total
FROM crm_lead
WHERE attrs ? 'budgetIA'
GROUP BY attrs->>'niveauMaturiteIA';
```

---

## 7. Security & Permissions

### 7.1 Field-Level Security

**Champ sensible** (ex: budget, données financières) :
```xml
<field name="budgetIA" type="decimal"
       readonly="true"
       showIf="__user__.code == 'admin' || __user__.group.code == 'sales-manager'"/>
```

**Masquage conditionnel** :
```xml
<field name="margeCommerciale" type="decimal"
       hideIf="!(__user__.hasRole('ROLE_FINANCE'))"/>
```

### 7.2 Audit Trail

**Tracer modifications** :
- Activer `auditable="true"` sur entité
- Requête historique :
```sql
SELECT *
FROM meta_audit_line
WHERE model = 'com.axelor.apps.base.db.Partner'
  AND field_name = 'attrs'
ORDER BY created_on DESC;
```

---

## 8. Documentation Templates

### 8.1 Template Custom Field (Registry)

```markdown
### [nomChamp]
- **ID Technique** : [ID généré Studio]
- **Type** : [String, Integer, Decimal, Boolean, Date, Selection, Many-to-One]
- **Selection** : [nom-selection] (si type Selection)
- **Titre** : [Libellé affiché]
- **Requis** : [Oui/Non]
- **Table** : [base_partner, crm_lead, etc.]
- **Colonne JSON** : attrs
- **Date création** : [YYYY-MM-DD]
- **Créé par** : [Nom]
- **Objectif** : [Description métier]
- **Valeurs** : [Voir selection X] ou [Min/Max pour Decimal]
- **Conditions** : [show_if, hide_if, required_if si applicable]
- **Utilisé dans** :
  - [Vue form X (panel Y)]
  - [Dashboard Z]
  - [Workflow W]
- **Relations** : [Autres champs liés, workflows dépendants]
- **Requêtes SQL** :
  ```sql
  -- Exemple requête
  SELECT ...
  ```
```

### 8.2 Template Selection (Registry)

```markdown
### [nom-selection]
- **Nom technique** : [nom-selection]
- **Titre** : [Libellé]
- **Module** : [axelor-crm, axelor-custom, etc.]
- **Table** : meta_select
- **Date création** : [YYYY-MM-DD]
- **Valeurs** :

| Valeur | Libellé | Séquence | Description | Actif |
|--------|---------|----------|-------------|-------|
| `val1` | Label 1 | 10 | Description val1 | ✅ |
| `val2` | Label 2 | 20 | Description val2 | ✅ |

**Transitions autorisées** : [Workflow cycle de vie si applicable]
**Anti-pattern évité** : [Référence DA si applicable]
```

### 8.3 Template Décision Architecturale

```markdown
### DA-XXX : [Titre Décision]
- **Date** : [YYYY-MM-DD]
- **Contexte** : [Problème à résoudre]
- **Options évaluées** :
  - Option A : [Description]
  - Option B : [Description]
  - Option C : [Description] ✅ CHOISI

- **Décision** : [Option choisie]
- **Raisons** :
  - [Raison 1]
  - [Raison 2]

- **Conséquences** :
  - [Conséquence positive 1]
  - [Conséquence négative 1 (mitigation)]

- **Alternatives futures** : [Si besoin évolution]
```

---

## 9. Quick Reference

### Naming Quick Check

```
Custom Field     → camelCase      → niveauMaturiteIA
Selection        → kebab-case     → crm-partner-statut-select
Selection Value  → kebab-case     → client-actif
Custom Model     → PascalCase     → CrmServiceIA
Action           → kebab-case     → action-lead-convert
```

### Type Decision Tree

```
Question : Quel type de champ ?

Binaire (Oui/Non) → Boolean (isXxx, hasXxx)

3-15 valeurs fixes → Selection

> 15 valeurs ou évolutif → Many-to-One

Texte court (< 255) → String

Texte long → Text (multiline)

Nombre entier → Integer

Nombre décimal (finance) → Decimal (precision, scale)

Date seule → Date

Date + Heure → DateTime
```

### Validation Checklist

```
✅ Consulté configuration-registry.md (pas de duplication)
✅ Naming convention respectée
✅ Type approprié choisi
✅ Valeur par défaut définie (si applicable)
✅ Conditions affichage définies (si applicable)
✅ Documenté dans registry
✅ Migration SQL préparée (si modification)
```

---

## 10. Custom Fields via REST API

### 10.1 Contexte et Limitations

**❌ CSV Auto-Import Ne Fonctionne PAS pour Modules Custom**

Les fichiers CSV placés dans `data-init/input/` ne sont **jamais auto-importés** pour les modules custom.

**Root Cause** :
- Bug dans `com.axelor.meta.MetaScanner.findAll()`
- Le scanner ne trouve pas les ressources `data-init/` pour les modules en dehors de `axelor-open-suite/`
- Non documenté par Axelor

**Investigation** : Voir `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/investigation-complete-solution-python-api.md`

**Conséquence** :
- ❌ CSV import ne fonctionne pas pour MetaJsonField
- ❌ Même après rebuild, aucun log, aucune erreur
- ✅ Solution : **REST API externe**

### 10.2 Solution : Python REST API Script

**Avantages** :
- ✅ **Externe** : Aucune modification du code Axelor (sanctuarisé)
- ✅ **Aucun rebuild** : Pas de recompilation nécessaire pour le field
- ✅ **Versionné** : Configuration Git-tracked (config.json)
- ✅ **Idempotent** : Peut être exécuté plusieurs fois sans erreur
- ✅ **Réutilisable** : Template pour tous futurs custom fields

**Localisation** : `scripts/custom-fields/`

**Fichiers** :
```
scripts/custom-fields/
├── import-custom-fields.py    # Script principal
├── config.json                # Configuration des fields
├── requirements.txt           # Dépendances Python
└── README.md                  # Documentation complète
```

### 10.3 Workflow Complet

**Étape 1 : Créer Selection XML** (si type dropdown)

Fichier : `modules/axelor-vecia-crm/src/main/resources/views/Selections.xml`

```xml
<selection name="contact-provenance-select">
  <option value="linkedin">LinkedIn</option>
  <option value="site-web">Site Web</option>
  <option value="recommandation">Recommandation</option>
  <option value="salon-conference">Salon/Conférence</option>
  <option value="reseau-professionnel">Réseau Professionnel</option>
  <option value="cold-outreach">Cold Outreach</option>
  <option value="partenaire">Partenaire</option>
  <option value="autre">Autre</option>
</selection>
```

**Étape 2 : Configurer Field JSON**

Fichier : `scripts/custom-fields/config.json`

```json
{
  "axelor_url": "http://localhost:8080",
  "username": "admin",
  "password": "admin",
  "custom_fields": [
    {
      "name": "provenance",
      "title": "Provenance",
      "type": "string",
      "model": "com.axelor.apps.base.db.Partner",
      "modelField": "contactAttrs",
      "selection": "contact-provenance-select",
      "widget": "selection",
      "sequence": 10,
      "showIf": "isContact == true",
      "visibleInGrid": true,
      "required": false,
      "readonly": false,
      "hidden": false,
      "help": "Source d'acquisition du contact (LinkedIn, Site Web, Recommandation, etc.)"
    }
  ]
}
```

**Étape 3 : Exécuter Script Python**

**Option A : Depuis laptop** (si Axelor accessible sur localhost:8080)
```bash
cd scripts/custom-fields
pip install -r requirements.txt
python import-custom-fields.py
```

**Option B : Via Docker network** (macOS ou si problème port binding)
```bash
# Modifier config.json : "axelor_url": "http://axelor-vecia-app:8080"
docker run --rm --network axelor-vecia-v1_axelor-network \
  -v "$(pwd)/scripts/custom-fields:/scripts" \
  python:3.11-slim bash -c "
    pip install -q requests &&
    cd /scripts &&
    python import-custom-fields.py --config config-docker.json
  "
```

**Output Attendu** :
```
[INFO] Configuration loaded from /scripts/config.json
[INFO] Connecting to Axelor at http://axelor-vecia-app:8080...
[INFO] Authentication successful
[INFO] Found 1 field(s) to process
[INFO] Processing field 'provenance' on Partner...
[INFO] ✓ Field 'provenance' created successfully (ID: 1)
[INFO] ==================================================
[INFO] SUMMARY: 1 field(s) created/updated, 0 error(s)
[INFO] ==================================================
```

**Temps d'exécution** : ~3 secondes

**Étape 4 : Vérifier en DB**

```sql
-- Vérifier MetaJsonField
SELECT id, name, title, type_name, model_name, model_field, selection, widget
FROM meta_json_field
WHERE name = 'provenance';

-- Résultat attendu :
-- id | name       | title      | type_name | model_name                      | model_field  | selection                 | widget
-- ---|------------|------------|-----------|---------------------------------|--------------|---------------------------|----------
-- 1  | provenance | Provenance | string    | com.axelor.apps.base.db.Partner | contactAttrs | contact-provenance-select | selection
```

**Étape 5 : Rebuild pour Charger Selection**

```bash
./gradlew build
docker-compose restart axelor
```

**Étape 6 : Vérifier Selection en DB**

```sql
-- Vérifier meta_select
SELECT id, name, module FROM meta_select WHERE name = 'contact-provenance-select';

-- Vérifier options
SELECT si.value, si.title, si.sequence
FROM meta_select_item si
JOIN meta_select s ON si.select_id = s.id
WHERE s.name = 'contact-provenance-select'
ORDER BY si.sequence;
```

### 10.4 Résultats Test Réels

**Date Test** : 2025-10-06
**Environnement** : macOS, Docker Desktop, Axelor 8.3.15

**Test 1 : Field Creation via API** ✅
- **Méthode** : Python script via Docker network
- **Durée** : 3 secondes
- **Résultat** : Field créé avec ID=1
- **Vérification DB** : ✅ Présent dans `meta_json_field`

**Test 2 : Selection Existence** ⏳
- **État Avant Rebuild** : ❌ Absent de `meta_select` (0 rows)
- **Raison** : Selections XML chargées uniquement au build
- **Action Requise** : Rebuild + restart

**Test 3 : Idempotence** ✅
- **Comportement** : Script détecte field existant (ID: 1)
- **Action** : Update au lieu de create
- **Output** : `Field 'provenance' updated successfully (ID: 1)`
- **Pas d'erreur** : ✅

**Constats** :
- ✅ REST API fonctionne parfaitement
- ✅ Pas besoin de rebuild pour le field JSON lui-même
- ⚠️ Rebuild nécessaire UNIQUEMENT pour charger les selections XML
- ✅ Script 100% idempotent

### 10.5 API Endpoints Utilisés

**Authentication** :
```http
POST /callback
Content-Type: application/json

{
  "username": "admin",
  "password": "admin"
}
```
→ Retourne session cookie (JSESSIONID)

**Search MetaJsonField** :
```http
POST /ws/rest/com.axelor.meta.db.MetaJsonField/search
Content-Type: application/json

{
  "offset": 0,
  "limit": 1,
  "fields": ["id", "name", "model"],
  "data": {
    "_domain": "self.name = :name AND self.model = :model",
    "_domainContext": {
      "name": "provenance",
      "model": "com.axelor.apps.base.db.Partner"
    }
  }
}
```
→ Retourne field existant ou `total: 0`

**Create/Update MetaJsonField** :
```http
PUT /ws/rest/com.axelor.meta.db.MetaJsonField
Content-Type: application/json

{
  "data": {
    "id": 1,              // Optionnel (si update)
    "version": 0,         // Optionnel (si update)
    "name": "provenance",
    "title": "Provenance",
    "type": "string",
    "model": "com.axelor.apps.base.db.Partner",
    "modelField": "contactAttrs",
    "selection": "contact-provenance-select",
    "widget": "selection",
    "sequence": 10,
    "showIf": "isContact == true",
    "visibleInGrid": true,
    "help": "Source d'acquisition du contact"
  }
}
```
→ Retourne `status: 0` si succès

### 10.6 Attributs Field Supportés

| Attribut | Type | Requis | Description | Exemple |
|----------|------|--------|-------------|---------|
| **name** | string | ✅ | Nom technique (camelCase) | `emailSecondaire` |
| **title** | string | ✅ | Libellé affiché | `Email Secondaire` |
| **type** | string | ✅ | Type de données | `string`, `integer`, `decimal`, `boolean`, `date`, `datetime` |
| **model** | string | ✅ | Classe modèle cible | `com.axelor.apps.base.db.Partner` |
| **modelField** | string | ⚠️ | Field JSON sur modèle | `attrs` (défaut), `contactAttrs` (Partner contacts) |
| **selection** | string | ⚠️ | Nom selection (si type dropdown) | `contact-provenance-select` |
| **widget** | string | ⚠️ | Widget UI | `selection`, `text`, `checkbox` |
| **sequence** | integer | ⚠️ | Ordre affichage | `10` |
| **showIf** | string | ⚠️ | Condition affichage | `isContact == true` |
| **visibleInGrid** | boolean | ⚠️ | Visible dans grille | `true` |
| **required** | boolean | ⚠️ | Champ obligatoire | `false` |
| **readonly** | boolean | ⚠️ | Lecture seule | `false` |
| **hidden** | boolean | ⚠️ | Caché | `false` |
| **help** | string | ⚠️ | Texte d'aide | `Format: email@example.com` |

### 10.7 Troubleshooting

**Erreur : "401 Unauthorized"**
- **Cause** : Credentials incorrects dans config.json
- **Solution** : Vérifier username/password

**Erreur : "Connection refused"**
- **Cause** : Axelor pas accessible
- **Solution** :
  - Vérifier : `curl http://localhost:8080/` → doit retourner 200
  - macOS : Utiliser Docker network (`http://axelor-vecia-app:8080`)

**Field non visible dans form**
- **Cause** : `showIf` condition non remplie
- **Solution** :
  - Vérifier condition : `isContact == true` sur Partner
  - Rebuild si nécessaire

**Selection dropdown vide**
- **Cause** : Selections.xml pas chargé
- **Solution** :
  - Vérifier fichier existe : `modules/axelor-vecia-crm/src/main/resources/views/Selections.xml`
  - Rebuild : `./gradlew build && docker-compose restart axelor`
  - Vérifier en DB : `SELECT * FROM meta_select WHERE name = 'contact-provenance-select'`

**"Field already exists" dans logs**
- **C'est normal** : Le script est idempotent, il update le field existant
- Pas d'action requise

### 10.8 Best Practices REST API

1. ✅ **Idempotence** : Toujours vérifier existence avant create
2. ✅ **Version Control** : Commiter config.json après chaque modif
3. ✅ **Documentation** : Mettre à jour registry après chaque field
4. ✅ **Testing** : Tester run 2× pour vérifier idempotence
5. ✅ **Backup** : Backup DB avant opérations bulk

### 10.9 Performance

| Action | Temps Moyen | Notes |
|--------|-------------|-------|
| Simple field (string/integer) | 3 sec | Via REST API |
| Selection field (création field) | 3 sec | Via REST API |
| Selection field (chargement XML) | 5 min | Rebuild requis |
| Batch 10 fields | 30 sec | Via REST API |
| Vérification DB | 1 sec | Query SQL |

### 10.10 Références

- **Investigation complète** : `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/investigation-complete-solution-python-api.md`
- **Agent template** : `.diagnostic-archives/axelor-custom-fields-diagnostic-2025-10-05/agent-custom-fields-template.md`
- **Script complet** : `scripts/custom-fields/`
- **Axelor REST API Docs** : https://docs.axelor.com/adk/7.2/dev-guide/web-services/rest.html

---

**End of Knowledge Base**
