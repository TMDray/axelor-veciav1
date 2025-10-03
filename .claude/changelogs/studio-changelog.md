# Studio Configuration Changelog

All notable changes to Axelor Studio configurations will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Partner: Additional selection value "autre" for statutContact
- Lead: Custom fields for AI maturity tracking
- Opportunity: Custom fields for service catalog

---

## [1.0.1] - 2025-10-03

### Added

#### Partner.statutContact (Selection Field)

**Business Context:**
- **Purpose**: Segment companies by type of business relationship
- **Use case**: Filter partners for targeted campaigns, reporting, CRM workflows
- **Impact**: Enables better partner classification and relationship management

**Technical Details:**
- **Object**: Partner (base_partner)
- **Field name**: `statutContact`
- **Type**: Selection
- **Storage**: JSON column `attrs` (MetaJsonField architecture)
- **Required**: No (optional field)
- **Default**: None

**Selection Values:**
```yaml
selection-statut-contact:
  - value: client
    label: Client
    sequence: 10
  - value: partenaire
    label: Partenaire
    sequence: 20
  - value: prospect
    label: Prospect
    sequence: 30
  - value: ancien-client
    label: Ancien Client
    sequence: 40
```

**Access Path in Axelor:**
- Configuration → Studio → Base → Partner → Custom Fields → statutContact

**SQL Queries:**
```sql
-- Retrieve all partners with status
SELECT
  id,
  full_name,
  attrs->>'statutContact' AS statut_contact
FROM base_partner
WHERE attrs ? 'statutContact';

-- Count by status
SELECT
  attrs->>'statutContact' AS statut,
  COUNT(*) AS nombre
FROM base_partner
WHERE attrs ? 'statutContact'
GROUP BY attrs->>'statutContact'
ORDER BY nombre DESC;

-- Filter active clients
SELECT *
FROM base_partner
WHERE attrs->>'statutContact' = 'client'
  AND is_customer = TRUE;
```

**Migration:**
- No migration needed (new optional field)
- Backward compatible: existing partners will have NULL value
- Can be populated manually or via import

**Created by**: Tanguy
**Created via**: Studio UI
**Date**: 2025-10-03T14:00:00Z
**Commit**: (to be added after commit)

---

## [1.0.0] - 2025-09-30

### Added
- Studio module installed and activated
- Initial setup completed

### Infrastructure
- Studio tables created in database
- MetaJsonField architecture initialized

---

## Notes

### How to Add Entries

When creating a new Studio configuration:

1. **Document immediately** in this file under `[Unreleased]`
2. **Include**:
   - Business context (purpose, use case)
   - Technical details (object, field name, type, storage)
   - Selection values if applicable
   - SQL queries for access
   - Migration notes if needed
3. **Move to versioned release** when deploying
4. **Update** `.claude/configuration-registry.md` simultaneously
5. **Commit** with conventional commit message

### Conventional Commit Format

```bash
feat(studio): add Partner status classification

- Created selection field statutContact on Partner
- Values: client, partenaire, prospect, ancien-client
- Location: base_partner.attrs JSON column

See studio-changelog.md for details
```

### Breaking Changes

If a configuration change breaks backward compatibility:
- Mark with **BREAKING CHANGE** in commit footer
- Document migration path
- Increment MAJOR version
- Provide deprecation warning in previous version

Example:
```markdown
## [2.0.0] - 2025-XX-XX

### BREAKING CHANGES

#### Partner.statutContact → Partner.typeRelation

**What changed**: Field renamed for consistency with data model

**Migration required**:
```sql
-- Migration script provided
-- See: scripts/migrations/001-rename-statut-contact.sql
```

**Deprecation timeline**:
- v1.5.0: Deprecation warning added
- v1.9.0: Both fields available (transition period)
- v2.0.0: Old field removed
```

---

**Last updated**: 2025-10-03
**Maintained by**: Configuration Team
**Reference**: [Configuration Registry](../configuration-registry.md)
