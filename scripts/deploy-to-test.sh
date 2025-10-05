#!/bin/bash
# =============================================================================
# Script de Déploiement - Axelor Vecia sur Serveur Test
# =============================================================================
# Description : Déploie l'application Axelor sur serveur HPE ProLiant via Tailscale
# Usage : ./scripts/deploy-to-test.sh
# Auteur : Équipe Dev Axelor Vecia
# =============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable

# -----------------------------------------------------------------------------
# Variables
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Serveur Test
SERVER_IP="100.124.143.6"
SERVER_USER="axelor"
SERVER_PATH="/home/axelor/axelor-vecia"
SERVER_SSH="${SERVER_USER}@${SERVER_IP}"

# Docker
IMAGE_NAME="axelor-vecia"
IMAGE_TAG="latest"
IMAGE_TAR="/tmp/${IMAGE_NAME}-${IMAGE_TAG}.tar"

# Couleurs output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Fonctions Helper
# -----------------------------------------------------------------------------
error() {
    echo -e "${RED}❌ Erreur: $1${NC}" >&2
    exit 1
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# -----------------------------------------------------------------------------
# Phase 1 : Vérifications Pré-Déploiement
# -----------------------------------------------------------------------------
phase1_verifications() {
    echo ""
    echo "========================================="
    echo "Phase 1 : Vérifications Pré-Déploiement"
    echo "========================================="

    # Vérifier Tailscale actif
    info "Vérification Tailscale..."
    if ! tailscale status > /dev/null 2>&1; then
        error "Tailscale non actif. Lancer: tailscale up"
    fi

    if ! tailscale status | grep -q "$SERVER_IP"; then
        error "Serveur $SERVER_IP non trouvé dans Tailscale"
    fi
    success "Tailscale OK"

    # Test ping serveur
    info "Test connectivité serveur..."
    if ! ping -c 2 "$SERVER_IP" > /dev/null 2>&1; then
        error "Serveur $SERVER_IP non accessible (ping failed)"
    fi
    success "Connectivité serveur OK"

    # Test SSH
    info "Test connexion SSH..."
    if ! ssh -o ConnectTimeout=5 "$SERVER_SSH" "echo 'SSH OK'" > /dev/null 2>&1; then
        error "Connexion SSH impossible vers $SERVER_SSH"
    fi
    success "SSH OK"

    # Vérifier Docker local
    info "Vérification Docker local..."
    if ! docker info > /dev/null 2>&1; then
        error "Docker non accessible localement"
    fi
    success "Docker local OK"

    # Vérifier Docker distant
    info "Vérification Docker distant..."
    if ! ssh "$SERVER_SSH" "docker info" > /dev/null 2>&1; then
        error "Docker non accessible sur serveur"
    fi
    success "Docker distant OK"
}

# -----------------------------------------------------------------------------
# Phase 2 : Build Image Docker
# -----------------------------------------------------------------------------
phase2_build() {
    echo ""
    echo "==============================="
    echo "Phase 2 : Build Image Docker"
    echo "==============================="

    cd "$PROJECT_ROOT"

    info "Build de l'image Docker Axelor..."
    info "Cela peut prendre 10-15 minutes (compilation Gradle)..."

    if ! docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .; then
        error "Build Docker échoué"
    fi

    success "Image ${IMAGE_NAME}:${IMAGE_TAG} créée"

    # Afficher taille image
    IMAGE_SIZE=$(docker images "${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.Size}}")
    info "Taille image : $IMAGE_SIZE"
}

# -----------------------------------------------------------------------------
# Phase 3 : Export et Transfert Image
# -----------------------------------------------------------------------------
phase3_transfer() {
    echo ""
    echo "========================================"
    echo "Phase 3 : Export et Transfert Image"
    echo "========================================"

    # Export image en TAR
    info "Export image en tar..."
    if ! docker save -o "$IMAGE_TAR" "${IMAGE_NAME}:${IMAGE_TAG}"; then
        error "Export image échoué"
    fi
    success "Image exportée : $IMAGE_TAR"

    TAR_SIZE=$(du -h "$IMAGE_TAR" | cut -f1)
    info "Taille fichier tar : $TAR_SIZE"

    # Créer répertoire distant si nécessaire
    info "Création répertoire distant..."
    ssh "$SERVER_SSH" "mkdir -p $SERVER_PATH"

    # Transfert via SCP
    info "Transfert image vers serveur (peut prendre quelques minutes)..."
    if ! scp "$IMAGE_TAR" "${SERVER_SSH}:${SERVER_PATH}/"; then
        error "Transfert SCP échoué"
    fi
    success "Image transférée sur serveur"

    # Nettoyer tar local
    rm -f "$IMAGE_TAR"
}

# -----------------------------------------------------------------------------
# Phase 4 : Transfert Fichiers de Configuration
# -----------------------------------------------------------------------------
phase4_config() {
    echo ""
    echo "=========================================="
    echo "Phase 4 : Transfert Configuration"
    echo "=========================================="

    cd "$PROJECT_ROOT"

    # Transfert docker-compose.prod.yml
    info "Transfert docker-compose.prod.yml..."
    scp docker-compose.prod.yml "${SERVER_SSH}:${SERVER_PATH}/docker-compose.yml"

    # Transfert application-prod.properties
    info "Transfert application-prod.properties..."
    scp application-prod.properties "${SERVER_SSH}:${SERVER_PATH}/"

    success "Configuration transférée"
}

# -----------------------------------------------------------------------------
# Phase 5 : Déploiement sur Serveur
# -----------------------------------------------------------------------------
phase5_deploy() {
    echo ""
    echo "====================================="
    echo "Phase 5 : Déploiement sur Serveur"
    echo "====================================="

    ssh "$SERVER_SSH" << ENDSSH
set -e

cd $SERVER_PATH

echo "📦 Chargement image Docker..."
docker load -i ${IMAGE_NAME}-${IMAGE_TAG}.tar

echo "🛑 Arrêt ancienne version (si existe)..."
docker-compose down || true

echo "🔧 Vérification réseau citeos-network..."
if ! docker network inspect citeos-network > /dev/null 2>&1; then
    echo "⚠️  Réseau citeos-network n'existe pas, création..."
    docker network create citeos-network
fi

echo "🗄️  Vérification base de données..."
# Créer base de données si n'existe pas
docker exec citeos-postgres psql -U axelor -tc "SELECT 1 FROM pg_database WHERE datname = 'axelor_vecia'" | grep -q 1 || \
    docker exec citeos-postgres psql -U axelor -c "CREATE DATABASE axelor_vecia;"

echo "🚀 Démarrage Axelor..."
docker-compose up -d

echo "⏳ Attente démarrage application (60 secondes)..."
sleep 60

echo "📊 Status containers:"
docker-compose ps

echo "📝 Logs récents:"
docker-compose logs --tail=50 axelor

ENDSSH

    success "Déploiement terminé"
}

# -----------------------------------------------------------------------------
# Phase 6 : Validation Post-Déploiement
# -----------------------------------------------------------------------------
phase6_validation() {
    echo ""
    echo "=========================================="
    echo "Phase 6 : Validation Post-Déploiement"
    echo "=========================================="

    # Attendre un peu plus pour être sûr
    info "Attente supplémentaire (30s) pour warm-up..."
    sleep 30

    # Test HTTP
    info "Test accès HTTP..."
    if curl -f "http://${SERVER_IP}:8080/" > /dev/null 2>&1; then
        success "Application accessible"
    else
        warning "Application pas encore accessible (peut nécessiter plus de temps)"
        warning "Vérifier manuellement : http://${SERVER_IP}:8080/"
    fi

    # Afficher infos connexion
    echo ""
    echo "=========================================="
    success "DÉPLOIEMENT RÉUSSI !"
    echo "=========================================="
    echo ""
    echo "🌐 URL Application : http://${SERVER_IP}:8080/"
    echo "👤 Login admin     : admin"
    echo "🔑 Password admin  : admin (à changer)"
    echo ""
    echo "📊 Monitoring:"
    echo "   ssh ${SERVER_SSH} 'cd ${SERVER_PATH} && docker-compose logs -f axelor'"
    echo ""
    echo "🔍 Status:"
    echo "   ssh ${SERVER_SSH} 'cd ${SERVER_PATH} && docker-compose ps'"
    echo ""
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🚀 Déploiement Axelor Vecia - Test     ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    phase1_verifications
    phase2_build
    phase3_transfer
    phase4_config
    phase5_deploy
    phase6_validation

    success "Déploiement complet terminé avec succès !"
}

main "$@"
