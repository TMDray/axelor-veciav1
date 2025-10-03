# BPM Workflow Changelog

All notable changes to Axelor BPM workflows and automations will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Lead scoring workflow (automatic calculation based on custom fields)
- Opportunity follow-up automation
- Partner status change notifications

---

## [1.0.0] - 2025-09-30

### Added
- BPM module installed and activated
- Workflow engine ready for custom processes

### Infrastructure
- BPMN 2.0 support enabled
- Groovy scripting engine configured
- Process monitoring available

---

## Notes

### How to Add Entries

When creating a new BPM workflow:

1. **Document immediately** in this file under `[Unreleased]`
2. **Include**:
   - Workflow name and purpose
   - Trigger conditions
   - Process steps (high-level)
   - Groovy scripts (snippets or file references)
   - Variables and context used
   - Schedule (if timer-based)
3. **Move to versioned release** when deploying
4. **Update** `.claude/configuration-registry.md` simultaneously
5. **Commit** with conventional commit message

### Conventional Commit Format

```bash
feat(bpm): add Lead scoring automation workflow

- Trigger: On Lead save
- Calculates score based on maturité IA, budget, urgence
- Updates leadScoringIA field automatically
- Service task with Groovy script

See bpm-changelog.md for details
```

---

**Last updated**: 2025-10-03
**Maintained by**: Configuration Team
**Reference**: [Configuration Registry](../configuration-registry.md)
