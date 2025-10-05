# Knowledge Base: Docker Custom Modules Deployment

**Version**: 1.0.0
**Date**: 2025-10-05
**Status**: ✅ Production
**Auteur**: Claude Code (agent-docker-custom-modules)

---

## 📋 Vue d'Ensemble

Ce KB distille les **best practices** et **pièges courants** du déploiement de modules custom Axelor dans Docker, basé sur 2 REX complets.

**Problématique**: Gradle multi-module + Docker multi-stage build = configuration en 2 endroits critiques.

---

## ⚡ Quick Reference - Checklist Pré-Build

```bash
# 1. Module dans Dockerfile ?
grep "COPY modules/axelor-vecia-crm" Dockerfile
# ✅ DOIT être présent

# 2. Module dans appModules ?
grep -B 5 "gradle.ext.appModules" settings.gradle | grep "axelor-vecia-crm"
# ✅ DOIT être dans la liste modules AVANT appModules

# 3. Build Docker
docker-compose build axelor  # Incrémental (recommandé)
# OU
docker-compose build --no-cache axelor  # Complet (si nécessaire)

# 4. Validation post-build
docker-compose exec axelor ls /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ | grep vecia
# ✅ DOIT montrer axelor-vecia-crm-*.jar
```

---

## 🚨 2 Pièges Critiques (100% des problèmes)

### Piège #1: Module Pas dans Dockerfile

**Symptôme**: Build local OK, Docker build OK, menus invisibles

**Cause**: Dockerfile ne COPY pas les sources du module custom avant `gradle build`

**Fix**:
```dockerfile
# Après COPY modules/axelor-open-suite/
COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/
```

**Temps perdu si manqué**: ~45 min

---

### Piège #2: Module Pas dans appModules

**Symptôme**:
- Build OK
- Logs "Loading package axelor-vecia-crm" ✅
- JAR existe localement ✅
- JAR ABSENT du WAR ❌
- Menus invisibles ❌

**Cause**: Module `include`d dans settings.gradle mais PAS ajouté à `gradle.ext.appModules`

**Diagnostic**:
```bash
# Vérifier JAR local (compilation)
ls modules/axelor-vecia-crm/build/libs/*.jar
# ✅ Présent

# Vérifier JAR dans WAR (packaging)
docker-compose exec axelor ls /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ | grep vecia
# ❌ ABSENT → Problème appModules
```

**Fix**:
```gradle
// settings.gradle
def modules = []
enabledModules.each { moduleName ->
  modules.add(file("modules/axelor-open-suite/${moduleName}"))
}

// AJOUTER ICI (AVANT appModules)
def customModuleDir = file("modules/axelor-vecia-crm")
if (customModuleDir.exists() && new File(customModuleDir, "build.gradle").exists()) {
  modules.add(customModuleDir)
}

gradle.ext.appModules = modules  // NOW includes vecia-crm
```

**Temps perdu si manqué**: ~60 min

---

## 🔍 Validation 7 Niveaux (Script Automatisé)

```bash
#!/bin/bash
echo "🔍 7-Level Validation..."

# 1. Compilation
ls modules/axelor-vecia-crm/build/libs/*.jar && echo "✅ L1: JAR compiled" || exit 1

# 2. Packaging
docker-compose exec axelor ls /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/axelor-vecia-crm-*.jar && echo "✅ L2: JAR in WAR" || exit 1

# 3. Module Loading
docker-compose logs axelor | grep -q "Loading package axelor-vecia-crm" && echo "✅ L3: Module loaded" || exit 1

# 4. Resource Import
docker-compose logs axelor | grep -q "Importing.*vecia.*Menu.xml" && echo "✅ L4: Menu.xml imported" || exit 1

# 5. Menu Registration
docker-compose logs axelor | grep -q "Loading menu.*crm-all-partners" && echo "✅ L5: Menus registered" || exit 1

# 6. HTTP Access
curl -f -s -I http://localhost:8080/ > /dev/null && echo "✅ L6: HTTP 200" || { echo "⚠️ L6: Port forwarding issue - Restart Docker Desktop"; exit 1; }

# 7. UI (Manuel)
echo "📋 L7: Manual UI validation required"
echo "  → http://localhost:8080/ → CRM → Check menus"
```

**Sauvegarder**: `scripts/validate-deployment.sh`

---

## 🐳 Docker Desktop macOS - Port Forwarding Bug

### Pattern Reproductible (100%)

```
Build --no-cache #1 → Port forwarding corrompu ❌
Build --no-cache #2 → Port forwarding corrompu ❌
Build --no-cache #3 → Port forwarding corrompu ❌
```

### Symptômes

```bash
docker-compose ps            # UP + healthy ✅
docker exec axelor curl ...  # HTTP 200 ✅
curl localhost:8080          # Empty reply ❌
```

### Solution (2-3 min)

```bash
# 1. Quit Docker Desktop (menu bar)
# 2. Wait 10s
# 3. Reopen Docker Desktop
# 4. Wait "running" status
# 5. Test: curl -I http://localhost:8080/
```

### Prévention

```bash
# Éviter --no-cache quand possible
docker-compose build axelor  # Build incrémental (5-10s)

# --no-cache SEULEMENT si:
# - Premier build
# - Modification Dockerfile
# - Modification settings.gradle
# - Ajout nouveau module
```

**Référence**: docker/for-mac#3763

---

## 📐 Architecture - Où Va Quoi

### Dockerfile (Stage 1: Builder)
```
Contrôle: Quels modules sont COMPILÉS
```

```dockerfile
COPY modules/axelor-open-suite/ ./modules/axelor-open-suite/
COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/  # CRITIQUE
RUN gradle build  # Compile tout ce qui est COPY
```

**❌ Si module pas COPY**: Gradle ne peut pas le trouver → Compilation échoue ou module ignoré

---

### settings.gradle
```
Contrôle: Quels modules compilés sont INCLUS dans WAR
```

```gradle
// Déclare modules disponibles (compilation)
include ':modules:axelor-base'
include ':modules:axelor-vecia-crm'

// ⚠️ MAIS include seul ne suffit PAS!

// Déclare modules dans WAR (packaging)
gradle.ext.appModules = modules  # DOIT contenir vecia-crm
```

**❌ Si module pas dans appModules**: Compile ✅ mais JAR pas dans WAR ❌

---

### build.gradle
```
Utilise: gradle.ext.appModules pour dépendances
```

```gradle
dependencies {
  gradle.appModules.each { dir ->
    implementation project(":modules:$dir.name")
  }
}
```

**❌ Si module pas dans appModules**: Loop de dépendances le saute

---

## 🎯 Best Practices

### 1. Ordre de Vérification

```
1. Dockerfile COPY   → Contrôle compilation
2. settings.gradle   → Contrôle packaging
3. Build Docker      → Execute compilation + packaging
4. Validation WAR    → Vérifie présence JAR
5. Validation logs   → Vérifie chargement module
6. Validation UI     → Vérifie fonctionnel
```

**Ne PAS sauter d'étapes**: Logs peuvent mentir!

---

### 2. Naming Modules Custom

```
modules/
├── axelor-open-suite/
├── axelor-vecia-crm/      # Préfixe vecia
├── axelor-vecia-sales/    # Préfixe vecia
└── axelor-vecia-*         # Pattern matching facile
```

**Avantage**: Facilite wildcards et détection

---

### 3. Dockerfile Multi-Modules

**1-3 modules**: Copie explicite
```dockerfile
COPY modules/axelor-vecia-crm/ ./modules/axelor-vecia-crm/
COPY modules/axelor-vecia-sales/ ./modules/axelor-vecia-sales/
```

**4+ modules**: Copie globale
```dockerfile
COPY modules/ ./modules/
```

---

### 4. .dockerignore Optimal

```
*.md
docs/
README*
CHANGELOG*
build/
.gradle/
**/build/
.idea/
*.iml
**/test-data/
```

---

## 🚨 Troubleshooting - Cache Axelor Database

### Problème : Vues/Actions Pas Importées Après Rebuild

**Symptômes** :
- ✅ Module custom chargé (logs : `Loading package axelor-vecia-crm`)
- ❌ Aucun import Menu.xml dans logs (`Importing: ...Menu.xml` absent)
- ❌ Actions/Menus absents en DB (`SELECT * FROM meta_action WHERE module = '...'` → 0 rows)
- ❌ Menus invisibles dans UI ou erreurs 500

**Root Cause** :
Axelor importe les vues XML en base **uniquement au premier démarrage**. Si une vue/action avec le même nom existe déjà en DB, Axelor **ne la met PAS à jour automatiquement**, même après rebuild.

### Solution 1 : Clear Cache Spécifique (Recommandé)

**Étape 1 - Identifier module et vues impactées** :
```bash
# Vérifier si module chargé
docker-compose logs axelor | grep "Loading package axelor-vecia"
# → Si présent : module OK, problème = cache DB

# Vérifier actions en DB
docker-compose exec postgres psql -U axelor -d axelor_vecia \
  -c "SELECT name, module FROM meta_action WHERE module = 'axelor-vecia-crm';"
# → Si vide : actions pas importées
```

**Étape 2 - Supprimer cache module** :
```bash
docker-compose exec postgres psql -U axelor -d axelor_vecia <<EOF
-- Supprimer vues custom module
DELETE FROM meta_view WHERE module = 'axelor-vecia-crm';

-- Supprimer actions custom module
DELETE FROM meta_action WHERE module = 'axelor-vecia-crm';

-- Supprimer menus custom module
DELETE FROM meta_menu WHERE module = 'axelor-vecia-crm';

-- Vérifier suppression
SELECT 'meta_view' as table, COUNT(*) FROM meta_view WHERE module = 'axelor-vecia-crm'
UNION ALL
SELECT 'meta_action', COUNT(*) FROM meta_action WHERE module = 'axelor-vecia-crm'
UNION ALL
SELECT 'meta_menu', COUNT(*) FROM meta_menu WHERE module = 'axelor-vecia-crm';
-- → Doit retourner 0, 0, 0
EOF
```

**Étape 3 - Restart container pour reimport** :
```bash
docker-compose restart axelor
sleep 30  # Attendre démarrage complet

# Vérifier import réussi
docker-compose logs axelor | grep -E "Importing.*vecia.*Menu|Loading.*vecia"
```

**Temps estimé** : 2-3 min

---

### Solution 2 : Clean Install Complet (Si Solution 1 Échoue)

**⚠️ ATTENTION** : Supprime TOUTE la base (perte données dev)

```bash
# Arrêter et supprimer volumes
docker-compose down -v

# Vérifier volumes supprimés
docker volume ls | grep axelor-vecia
# → Ne doit rien retourner

# Fresh start
docker-compose up -d
sleep 60  # Attendre initialisation DB

# Vérifier import
docker-compose logs axelor | grep -E "Importing.*Menu|Loading package"
```

**Temps estimé** : 3-5 min

**Cas d'usage** :
- Solution 1 ne fonctionne pas
- Corruption DB plus profonde
- Besoin reset complet environnement dev

---

### Prévention : Quand Clear Cache ?

**Toujours clear cache si** :
- ✅ Modification nom vue existante (`contact-grid` → `partner-contact-grid`)
- ✅ Modification action-view existante
- ✅ Modification menu existant
- ✅ Rebuild après fix erreur import précédent

**Pas besoin clear cache si** :
- ❌ Ajout nouveau module (première fois)
- ❌ Modification code Java/Groovy uniquement
- ❌ Modification domain filter (si nom vue inchangé)

---

## 🧪 Commandes de Diagnostic

### Module Compilé Localement?
```bash
ls modules/axelor-vecia-crm/build/libs/*.jar
```

### Module dans WAR?
```bash
docker-compose exec axelor ls /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/ | grep vecia
```

### Module Chargé?
```bash
docker-compose logs axelor | grep "Loading package axelor-vecia"
```

### Menu.xml Importé?
```bash
docker-compose logs axelor | grep "Importing.*vecia.*Menu.xml"
```

### Menus Enregistrés?
```bash
docker-compose logs axelor | grep "Loading menu.*crm-all-partners"
```

### HTTP Accessible?
```bash
curl -I http://localhost:8080/
```

---

## 📊 Métriques Validation

| Niveau | Vérification | Commande | Attendu |
|--------|--------------|----------|---------|
| 1 | JAR local | `ls modules/*/build/libs/*.jar` | N fichiers |
| 2 | JAR in WAR | `docker exec ... ls WEB-INF/lib/` | N fichiers |
| 3 | Module load | `docker logs \| grep "Loading package"` | N lignes |
| 4 | Menu.xml | `docker logs \| grep "Importing.*Menu.xml"` | N lignes |
| 5 | Menu reg | `docker logs \| grep "Loading menu"` | N menus |
| 6 | HTTP | `curl -I localhost:8080` | 200 OK |
| 7 | UI | Manuel | Menus visibles |

**Règle d'Or**: Si N modules custom, les 6 premières métriques doivent être égales à N.

---

## ⏱️ Temps de Résolution

| Problème | Temps Diagnostic | Temps Fix | Total |
|----------|------------------|-----------|-------|
| Module pas dans Dockerfile | 20 min | 5 min | ~45 min |
| Module pas dans appModules | 30 min | 5 min | ~60 min |
| Port forwarding corrompu | 5 min | 3 min | ~8 min |

**Total overhead possible**: ~2h si tous les pièges rencontrés

**Avec ce KB**: ~10 min (validation préventive)

---

## 🔗 Références

### Documentation Interne
- `.claude/agents/agent-docker-custom-modules.md` - Agent complet
- `/tmp/axelor-custom-module-docker-deployment.md` - REX détaillé session 2025-10-05
- `/tmp/docker-restart-analysis.md` - Analyse bug port forwarding

### Documentation Externe
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Gradle Multi-Project](https://docs.gradle.org/current/userguide/multi_project_builds.html)
- [Docker for Mac Issue #3763](https://github.com/docker/for-mac/issues/3763)

---

## 📝 Template Validation Report

```markdown
# Docker Module Deployment - {date}

## Modules
- axelor-vecia-crm: ✅/❌

## Pre-Build Checks
- [ ] Dockerfile COPY
- [ ] settings.gradle appModules

## Build
- Type: `--no-cache` / incremental
- Duration: {time}
- Status: SUCCESS / FAILED

## Validation
- [ ] L1: JAR compiled
- [ ] L2: JAR in WAR
- [ ] L3: Module loaded
- [ ] L4: Menu.xml imported
- [ ] L5: Menus registered
- [ ] L6: HTTP 200
- [ ] L7: UI validated

## Issues
- Port forwarding: ✅/❌ (restart required: Y/N)
- Other: {description}

## Time
- Diagnostic: {time}
- Fix: {time}
- Total: {time}
```

---

**Dernière mise à jour**: 2025-10-05
**Validé avec**: 2 REX complets, 3 rebuilds, 100% succès après application fixes
**Version agent associé**: agent-docker-custom-modules v2.0.0
