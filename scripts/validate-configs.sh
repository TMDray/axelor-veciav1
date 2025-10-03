#!/bin/bash
# =============================================================================
# Script: Validate Configuration Consistency
# Purpose: Check consistency between DB, Registry, and YAML configs
# Standard: GitOps 2025 - Continuous Reconciliation
# Version: 1.0.0
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REGISTRY_FILE=".claude/configuration-registry.md"
CHANGELOG_STUDIO=".claude/changelogs/studio-changelog.md"
CHANGELOG_BPM=".claude/changelogs/bpm-changelog.md"
CHANGELOG_API=".claude/changelogs/api-changelog.md"
CONFIGS_DIR=".claude/configs"

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ✅ Validation Configuration            ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check function
check() {
    CHECKS=$((CHECKS + 1))
    local test_name="$1"
    local test_command="$2"

    echo -ne "${YELLOW}[$CHECKS] $test_name...${NC} "

    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAIL${NC}"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

# Warning function
warn() {
    WARNINGS=$((WARNINGS + 1))
    local message="$1"
    echo -e "${YELLOW}⚠️  WARNING: $message${NC}"
}

# === FILE EXISTENCE CHECKS ===
echo -e "${BLUE}## Vérification Fichiers Requis${NC}"
echo ""

check "CHANGELOG.md exists" "test -f CHANGELOG.md"
check "configuration-registry.md exists" "test -f $REGISTRY_FILE"
check "studio-changelog.md exists" "test -f $CHANGELOG_STUDIO"
check "bpm-changelog.md exists" "test -f $CHANGELOG_BPM"
check "api-changelog.md exists" "test -f $CHANGELOG_API"

echo ""

# === FORMAT VALIDATION ===
echo -e "${BLUE}## Validation Format Changelogs${NC}"
echo ""

check "CHANGELOG has [Unreleased] section" "grep -q '## \[Unreleased\]' CHANGELOG.md"
check "CHANGELOG references Keep a Changelog" "grep -q 'keepachangelog.com' CHANGELOG.md"
check "CHANGELOG references Semantic Versioning" "grep -q 'semver.org' CHANGELOG.md"

check "Studio changelog has version sections" "grep -q '## \[' $CHANGELOG_STUDIO"
check "Studio changelog has Added/Changed/etc categories" "grep -qE '### (Added|Changed|Removed|Fixed)' $CHANGELOG_STUDIO"

echo ""

# === REGISTRY VALIDATION ===
echo -e "${BLUE}## Validation Configuration Registry${NC}"
echo ""

check "Registry has Overview table" "grep -q '## 📊 Overview' $REGISTRY_FILE"
check "Registry has Custom Fields section" "grep -q '## 1. Custom Fields' $REGISTRY_FILE"
check "Registry has Naming Conventions section" "grep -q '## 📋 Naming Conventions' $REGISTRY_FILE"
check "Registry has Update Process section" "grep -q '## 🔄 Update Process' $REGISTRY_FILE"

echo ""

# === YAML CONFIGS VALIDATION ===
echo -e "${BLUE}## Validation Configs YAML${NC}"
echo ""

if [ -d "$CONFIGS_DIR" ]; then
    yaml_count=$(find "$CONFIGS_DIR" -name "*.yaml" -o -name "*.yml" | wc -l | tr -d ' ')
    echo -e "${GREEN}✅ $yaml_count fichiers YAML trouvés${NC}"

    # Check partner-config.yaml if exists
    if [ -f "$CONFIGS_DIR/partner-config.yaml" ]; then
        check "partner-config.yaml has metadata section" "grep -q 'metadata:' $CONFIGS_DIR/partner-config.yaml"
        check "partner-config.yaml has custom_fields section" "grep -q 'custom_fields:' $CONFIGS_DIR/partner-config.yaml"
        check "partner-config.yaml has selections section" "grep -q 'selections:' $CONFIGS_DIR/partner-config.yaml"
    fi
else
    warn "Configs directory not found: $CONFIGS_DIR"
fi

echo ""

# === CONSISTENCY CHECKS ===
echo -e "${BLUE}## Vérification Cohérence${NC}"
echo ""

# Check if configurations mentioned in registry exist in changelogs
if grep -q "statutContact" "$REGISTRY_FILE"; then
    check "Partner.statutContact documented in studio-changelog" "grep -q 'statutContact' $CHANGELOG_STUDIO"
fi

# Check if YAML configs match registry
if [ -f "$CONFIGS_DIR/partner-config.yaml" ]; then
    check "partner-config.yaml references registry" "grep -q 'registry_ref:' $CONFIGS_DIR/partner-config.yaml"
    check "partner-config.yaml references changelog" "grep -q 'changelog_ref:' $CONFIGS_DIR/partner-config.yaml"
fi

echo ""

# === NAMING CONVENTION CHECKS ===
echo -e "${BLUE}## Vérification Conventions Nommage${NC}"
echo ""

# Check for camelCase in field names (should not have underscores or spaces)
if grep -E "field_name.*[_\s]" "$REGISTRY_FILE" > /dev/null 2>&1; then
    warn "Possible naming convention violation (underscore/space in field name)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✅ Field names follow camelCase convention${NC}"
    CHECKS=$((CHECKS + 1))
fi

# Check for kebab-case in selection names (should have "selection-" prefix and kebab-case)
if grep -oP 'selection_name: \K[^,\s]+' "$REGISTRY_FILE" 2>/dev/null | grep -v "^selection-" > /dev/null; then
    warn "Selection names should start with 'selection-' prefix"
else
    echo -e "${GREEN}✅ Selection names follow kebab-case convention${NC}"
    CHECKS=$((CHECKS + 1))
fi

echo ""

# === VERSION CONSISTENCY ===
echo -e "${BLUE}## Vérification Cohérence Versions${NC}"
echo ""

# Extract versions from different files
changelog_version=$(grep -oP '## \[\K[0-9]+\.[0-9]+\.[0-9]+' CHANGELOG.md | head -1 || echo "none")
registry_version=$(grep -oP 'Version\*\*: \K[0-9]+\.[0-9]+\.[0-9]+' "$REGISTRY_FILE" | head -1 || echo "none")

echo -e "${BLUE}Versions détectées:${NC}"
echo -e "  CHANGELOG.md           : $changelog_version"
echo -e "  configuration-registry : $registry_version"

if [ "$changelog_version" = "$registry_version" ]; then
    echo -e "${GREEN}✅ Versions cohérentes${NC}"
    CHECKS=$((CHECKS + 1))
else
    warn "Version mismatch between CHANGELOG and registry"
fi

echo ""

# === SCRIPTS VALIDATION ===
echo -e "${BLUE}## Vérification Scripts${NC}"
echo ""

check "sync-studio-to-git.sh exists" "test -f scripts/sync-studio-to-git.sh"
check "sync-studio-to-git.sh is executable" "test -x scripts/sync-studio-to-git.sh"
check "validate-configs.sh exists" "test -f scripts/validate-configs.sh"
check "validate-configs.sh is executable" "test -x scripts/validate-configs.sh"

echo ""

# === SUMMARY ===
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo -e "${BLUE}📊 RÉSUMÉ VALIDATION${NC}"
echo -e "${BLUE}══════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}✅ Checks réussis : $((CHECKS - ERRORS))${NC}"
echo -e "${RED}❌ Checks échoués  : $ERRORS${NC}"
echo -e "${YELLOW}⚠️  Warnings        : $WARNINGS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Total checks    : $CHECKS${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ 🎉 VALIDATION RÉUSSIE !${NC}"
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${GREEN}Toutes les configurations sont valides et cohérentes.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️  VALIDATION AVEC WARNINGS${NC}"
    echo -e "${YELLOW}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}Pas d'erreurs critiques, mais $WARNINGS warnings à examiner.${NC}"
    exit 0
else
    echo -e "${RED}══════════════════════════════════════════${NC}"
    echo -e "${RED}❌ VALIDATION ÉCHOUÉE${NC}"
    echo -e "${RED}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${RED}$ERRORS erreurs critiques détectées.${NC}"
    echo -e "${YELLOW}Corriger les erreurs avant de continuer.${NC}"
    exit 1
fi
