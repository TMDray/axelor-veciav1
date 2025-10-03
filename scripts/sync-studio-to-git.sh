#!/bin/bash
# =============================================================================
# Script: Sync Studio Configuration from Database to Git
# Purpose: Extract Axelor Studio custom fields from PostgreSQL and sync to Git
# Standard: GitOps 2025 - Continuous Reconciliation
# Version: 1.0.0
# =============================================================================

set -euo pipefail  # Exit on error, undefined var, pipe failure

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONTAINER_NAME="axelor-vecia-postgres"
DB_NAME="axelor_vecia"
DB_USER="axelor"
OUTPUT_DIR=".claude/configs/extracted"
REGISTRY_FILE=".claude/configuration-registry.md"

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🔄 Sync Studio Config DB → Git         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}"
echo ""

# Check if Docker container is running
echo -e "${YELLOW}ℹ️  Vérification container PostgreSQL...${NC}"
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container PostgreSQL non démarré${NC}"
    echo -e "${YELLOW}→ Démarrer avec: docker-compose up -d${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Container PostgreSQL opérationnel${NC}"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to extract custom fields from meta_json_field table
extract_custom_fields() {
    echo -e "${YELLOW}ℹ️  Extraction custom fields depuis meta_json_field...${NC}"

    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -A -F"," -c "
        SELECT
            mjf.name AS field_name,
            mjf.type AS field_type,
            mjf.title AS field_title,
            mjf.model AS model,
            mjf.model_field AS model_field,
            mjf.selection AS selection_name,
            mjf.required,
            mjf.readonly,
            mjf.hidden,
            mjf.help,
            mjf.sequence,
            mjf.created_on,
            u.code AS created_by
        FROM meta_json_field mjf
        LEFT JOIN auth_user u ON mjf.created_by = u.id
        ORDER BY mjf.model, mjf.sequence;
    " > "$OUTPUT_DIR/custom_fields.csv"

    local count=$(wc -l < "$OUTPUT_DIR/custom_fields.csv" | tr -d ' ')

    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Aucun custom field trouvé${NC}"
        return 0
    fi

    echo -e "${GREEN}✅ $count custom fields extraits${NC}"
    echo -e "${BLUE}→ Fichier: $OUTPUT_DIR/custom_fields.csv${NC}"
    echo ""
}

# Function to extract selections
extract_selections() {
    echo -e "${YELLOW}ℹ️  Extraction selections depuis meta_select...${NC}"

    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -A -F"," -c "
        SELECT
            ms.name AS selection_name,
            ms.module AS module_name,
            COUNT(msi.id) AS values_count
        FROM meta_select ms
        LEFT JOIN meta_select_item msi ON ms.id = msi.select_id
        GROUP BY ms.id, ms.name, ms.module
        ORDER BY ms.name;
    " > "$OUTPUT_DIR/selections.csv"

    local count=$(wc -l < "$OUTPUT_DIR/selections.csv" | tr -d ' ')

    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Aucune selection trouvée${NC}"
        return 0
    fi

    echo -e "${GREEN}✅ $count selections extraites${NC}"
    echo -e "${BLUE}→ Fichier: $OUTPUT_DIR/selections.csv${NC}"
    echo ""
}

# Function to extract selection values
extract_selection_values() {
    echo -e "${YELLOW}ℹ️  Extraction valeurs selections...${NC}"

    docker exec "$CONTAINER_NAME" psql -U "$DB_USER" -d "$DB_NAME" -t -A -F"," -c "
        SELECT
            ms.name AS selection_name,
            msi.value AS value,
            msi.title AS label,
            msi.order AS sequence
        FROM meta_select_item msi
        JOIN meta_select ms ON msi.select_id = ms.id
        ORDER BY ms.name, msi.order;
    " > "$OUTPUT_DIR/selection_values.csv"

    local count=$(wc -l < "$OUTPUT_DIR/selection_values.csv" | tr -d ' ')

    if [ "$count" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Aucune valeur de selection trouvée${NC}"
        return 0
    fi

    echo -e "${GREEN}✅ $count valeurs de selection extraites${NC}"
    echo -e "${BLUE}→ Fichier: $OUTPUT_DIR/selection_values.csv${NC}"
    echo ""
}

# Function to compare with registry
compare_with_registry() {
    echo -e "${YELLOW}ℹ️  Comparaison avec configuration-registry.md...${NC}"

    if [ ! -f "$REGISTRY_FILE" ]; then
        echo -e "${YELLOW}⚠️  Fichier registry non trouvé: $REGISTRY_FILE${NC}"
        echo -e "${BLUE}→ Créer le registry d'abord${NC}"
        return 0
    fi

    # Simple check: count custom fields in CSV vs mentions in registry
    local db_count=$(wc -l < "$OUTPUT_DIR/custom_fields.csv" | tr -d ' ')
    local registry_count=$(grep -c "field_name:" "$REGISTRY_FILE" 2>/dev/null || echo "0")

    echo ""
    echo -e "${BLUE}📊 Statistiques:${NC}"
    echo -e "   Custom fields DB   : $db_count"
    echo -e "   Custom fields Registry : $registry_count"

    if [ "$db_count" -eq "$registry_count" ]; then
        echo -e "${GREEN}✅ Configuration synchronisée${NC}"
    else
        echo -e "${YELLOW}⚠️  Désynchronisation détectée (drift)${NC}"
        echo -e "${BLUE}→ Vérifier les différences et mettre à jour le registry${NC}"
    fi
    echo ""
}

# Function to generate summary
generate_summary() {
    echo -e "${YELLOW}ℹ️  Génération du résumé...${NC}"

    cat > "$OUTPUT_DIR/SUMMARY.md" << EOF
# Studio Configuration Extraction Summary

**Date**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Database**: $DB_NAME
**Container**: $CONTAINER_NAME

## Extracted Data

### Custom Fields
- File: \`custom_fields.csv\`
- Count: $(wc -l < "$OUTPUT_DIR/custom_fields.csv" | tr -d ' ')
- Columns: field_name, field_type, field_title, model, selection_name, required, etc.

### Selections
- File: \`selections.csv\`
- Count: $(wc -l < "$OUTPUT_DIR/selections.csv" | tr -d ' ')
- Columns: selection_name, module_name, values_count

### Selection Values
- File: \`selection_values.csv\`
- Count: $(wc -l < "$OUTPUT_DIR/selection_values.csv" | tr -d ' ')
- Columns: selection_name, value, label, sequence

## Next Steps

1. Review extracted CSV files
2. Compare with configuration-registry.md
3. Update registry if drift detected
4. Generate YAML configs if needed
5. Commit changes with conventional commit message

## Commands

\`\`\`bash
# View custom fields
cat $OUTPUT_DIR/custom_fields.csv

# View selections
cat $OUTPUT_DIR/selections.csv

# View selection values
cat $OUTPUT_DIR/selection_values.csv

# Validate configs
./scripts/validate-configs.sh
\`\`\`
EOF

    echo -e "${GREEN}✅ Résumé généré${NC}"
    echo -e "${BLUE}→ Fichier: $OUTPUT_DIR/SUMMARY.md${NC}"
    echo ""
}

# Main execution
main() {
    extract_custom_fields
    extract_selections
    extract_selection_values
    compare_with_registry
    generate_summary

    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ 🎉 SYNCHRONISATION TERMINÉE !${NC}"
    echo -e "${GREEN}══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}📁 Fichiers extraits dans: $OUTPUT_DIR/${NC}"
    echo -e "${BLUE}📄 Résumé disponible: $OUTPUT_DIR/SUMMARY.md${NC}"
    echo ""
    echo -e "${YELLOW}ℹ️  Prochaines étapes:${NC}"
    echo -e "  1. cat $OUTPUT_DIR/SUMMARY.md"
    echo -e "  2. Comparer avec configuration-registry.md"
    echo -e "  3. Mettre à jour registry si besoin"
    echo -e "  4. ./scripts/validate-configs.sh"
}

main
