# API & Integrations Changelog

All notable changes to Axelor API configurations, webhooks, and external integrations will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- LinkedIn integration for lead import
- Email campaign API (Mailchimp/SendGrid)
- Analytics export (Google Analytics/Mixpanel)

---

## [1.0.0] - 2025-09-30

### Added
- REST API enabled (default Axelor endpoints)
- OpenAPI documentation available at `/ws/meta/app/swagger-ui.html`

### Infrastructure
- API authentication configured (session-based)
- CORS settings ready for external integrations
- Rate limiting enabled

---

## Notes

### How to Add Entries

When creating a new integration:

1. **Document immediately** in this file under `[Unreleased]`
2. **Include**:
   - Integration name and external service
   - Authentication method (OAuth2, API Key, etc.)
   - Endpoints configured (incoming/outgoing)
   - Data mapping
   - Error handling strategy
   - Webhook URLs if applicable
3. **Move to versioned release** when deploying
4. **Update** `.claude/configuration-registry.md` simultaneously
5. **Commit** with conventional commit message

### Conventional Commit Format

```bash
feat(api): add LinkedIn lead import integration

- Webhook: POST /ws/webhook/linkedin/lead
- Authentication: OAuth2 LinkedIn API
- Maps LinkedIn lead form to CRM Lead
- Includes custom field mapping (niveauMaturiteIA)

See api-changelog.md for details
```

---

**Last updated**: 2025-10-03
**Maintained by**: Configuration Team
**Reference**: [Configuration Registry](../configuration-registry.md)
