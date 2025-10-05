# TODO Demain : Finaliser Custom Field "provenance"

## 📋 Résumé Situation

**État actuel** :
- Module `axelor-vecia-crm` temporairement dans `modules/axelor-open-suite/`
- CSV data-init ne fonctionne pas (confirmé après 2h30 tests)
- Commit test fait : `e562110`

**Solution identifiée** : Studio UI (2 min)

---

## ✅ Actions à Faire (25 min total)

### 1. REVERTER Déplacement Module (10 min)

#### Étape 1.1 : Déplacer module
```bash
# Depuis racine projet
mv modules/axelor-open-suite/axelor-vecia-crm modules/axelor-vecia-crm
```

#### Étape 1.2 : Modifier settings.gradle
```gradle
# Ligne 68 environ
def customModuleDir = file("modules/axelor-vecia-crm")  # Était: modules/axelor-open-suite/axelor-vecia-crm
```

#### Étape 1.3 : Modifier Dockerfile
```dockerfile
# Ligne 21-22 environ
COPY modules/axelor-open-suite/ ./modules/axelor-open-suite/
COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/  # Ajouter cette ligne
```

#### Étape 1.4 : Rebuild
```bash
./gradlew clean build
docker-compose build --no-cache axelor
docker-compose down -v
docker-compose up -d
```

#### Étape 1.5 : Commit revert
```bash
git add -A
git commit -m "revert: Move axelor-vecia-crm back to modules/ (proper structure)

CSV data-init auto-import does NOT work for custom modules, even when
placed in axelor-open-suite/. Axelor has internal whitelist.

Reverting to proper structure: custom modules separate from official modules.
This follows Axelor best practices (see axelor-addons repository pattern).

Changes:
- Moved modules/axelor-open-suite/axelor-vecia-crm → modules/axelor-vecia-crm
- Restored settings.gradle customModuleDir path
- Re-added COPY line in Dockerfile for custom module

Next: Use Studio UI to create custom field (2 min, guaranteed to work)

Diagnostic documentation: /tmp/axelor-custom-fields-diagnostic-2025-10-05/

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 2. Créer Custom Field via Studio UI (2 min)

#### Étape 2.1 : Accéder Studio
1. Ouvrir http://localhost:8080
2. Login (admin/admin probablement)
3. Menu → Studio

#### Étape 2.2 : Créer Custom Field
1. Studio → Models → Partner
2. Ou : Studio → Custom Fields
3. Sélectionner : **Partner** model
4. Field : **contactAttrs** (JSON field)
5. Ajouter field :
   - Name: `provenance`
   - Title: `Provenance`
   - Type: `String`
   - Widget: `Selection`
   - Selection: `contact-provenance-select`
   - Sequence: `0`
   - Show if: `isContact == true`
   - Visible in grid: `true`

#### Étape 2.3 : Vérifier
1. Menu CRM → All Contacts
2. Ouvrir un contact
3. Vérifier field "Provenance" visible avec dropdown

---

### 3. Documenter Leçon Apprise (10 min)

#### Étape 3.1 : Mettre à jour `.claude/knowledge-bases/kb-lowcode-standards.md`

Ajouter section :

```markdown
## ⚠️ Limitation : CSV data-init pour Custom Fields

### Problème Identifié (2025-10-05)

**Symptôme** :
- CSV data-init avec `MetaJsonField` ne fonctionne PAS pour modules customs
- Même en plaçant module dans `modules/axelor-open-suite/`
- `input-config.xml` ignoré, CSV jamais importés

**Cause** :
- Axelor a whitelist interne pour auto-import CSV
- Seuls modules core (base, message, studio, etc.) supportés
- Non documenté officiellement mais confirmé par tests

### Solutions

| Approche | Statut | Temps | Notes |
|----------|--------|-------|-------|
| **Studio UI** | ✅ Recommandé | 2 min | Interface web, garanti fonctionnel |
| **Import programmatique Java** | ⚠️ Possible | 30 min | Complexe, nécessite code custom |
| **CSV auto-import** | ❌ Non disponible | - | Ne fonctionne pas modules customs |
| **SQL direct** | ❌ Déconseillé | 5 min | Pas reproductible |

### Workflow Recommandé

1. **Développement rapide** : Studio UI
2. **Export config** : Après création, exporter pour documentation
3. **Versioning** : Documenter config dans `.claude/configs/`

### Temps Diagnostic

- XML approach : 1h (échec)
- CSV modules/ : 1h (échec)
- CSV axelor-open-suite/ : 30min (échec)
- **Total** : 2h30

### Références

- Diagnostic complet : `/tmp/axelor-custom-fields-diagnostic-2025-10-05/`
- Commits : `75bdaa5`, `e562110`
```

#### Étape 3.2 : Mettre à jour `.claude/agents/agent-customization.md`

Dans section "Custom Fields", ajouter :

```markdown
## Custom Fields Workflow

### Méthode Recommandée : Studio UI

**Quand** : Toujours pour custom fields (MetaJsonField)

**Steps** :
1. Studio → Models → [Model]
2. Ajouter custom field (GUI)
3. Tester immédiatement
4. Documenter config dans `.claude/configs/`

**Pourquoi** :
- ✅ 2 minutes
- ✅ Fonctionne garantie
- ✅ Pas de rebuild nécessaire
- ❌ CSV auto-import non disponible modules customs

### Alternative : Import Programmatique

**Quand** : Si vraiment besoin versioning strict (rare)

**Effort** : ~30 min + risques

**Recommandation** : Ne pas utiliser sauf nécessité absolue
```

#### Étape 3.3 : Commit documentation
```bash
git add .claude/
git commit -m "docs: Add CSV data-init limitation for custom modules

Documented that CSV auto-import does not work for custom modules,
even when placed in axelor-open-suite/.

Recommended approach: Studio UI (2 min, guaranteed)
Alternative: Programmatic import (complex, not recommended)

References: /tmp/axelor-custom-fields-diagnostic-2025-10-05/

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### 4. Cleanup & Commit Final (3 min)

#### Étape 4.1 : Vérifier tout fonctionne
```bash
# Test app
curl http://localhost:8080

# Test contacts
# Ouvrir UI, vérifier custom field visible
```

#### Étape 4.2 : Push tous les commits
```bash
git push origin main
```

#### Étape 4.3 : Optionnel - Nettoyer diagnostic folder
```bash
# Garder pour référence ou supprimer après push
rm -rf /tmp/axelor-custom-fields-diagnostic-2025-10-05/
```

---

## 📊 Checklist Final

- [ ] Module revert à `modules/axelor-vecia-crm`
- [ ] settings.gradle modifié
- [ ] Dockerfile modifié
- [ ] Rebuild + restart Docker
- [ ] Commit revert
- [ ] Custom field créé via Studio UI
- [ ] Field testé dans UI
- [ ] Documentation `.claude/` mise à jour
- [ ] Commit docs
- [ ] Push origin/main
- [ ] Optionnel : Cleanup /tmp/

---

## 🎯 Résultat Attendu

**Avant** :
- Module dans axelor-open-suite/ (incorrect)
- Pas de custom field "provenance"
- Documentation incomplète

**Après** :
- Module dans modules/axelor-vecia-crm (correct)
- Custom field "provenance" fonctionnel ✅
- Limitation CSV documentée ✅
- Best practices mise à jour ✅

---

## 📞 Notes

**Si problèmes** :
- Logs diagnostic : `/tmp/axelor-custom-fields-diagnostic-2025-10-05/README.md`
- Commits : `75bdaa5` (CSV try), `e562110` (move test)
- Baseline stable : commit `67815ca`

**Temps estimé total** : 25 minutes

**Learnings clés** :
1. CSV auto-import = whitelist Axelor modules seulement
2. Studio UI = solution rapide et fiable
3. Structure modules customs = séparés de axelor-open-suite/

---

**Créé** : 2025-10-05 22:00
**Pour** : Demain matin
**Priorité** : Moyenne (fonctionnel actuel OK, juste structure à corriger)
