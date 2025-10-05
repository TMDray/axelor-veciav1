#!/bin/bash
# =============================================================================
# Script de Correction - Problème Réseau Docker macOS
# =============================================================================
# Description : Corrige les problèmes de port forwarding Docker Desktop macOS
# Usage : ./scripts/fix-docker-network.sh
# Auteur : Équipe Dev Axelor Vecia
# =============================================================================

set -e
set -u

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonctions
error() {
    echo -e "${RED}❌ $1${NC}"
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

section() {
    echo ""
    echo "=============================================="
    echo "$1"
    echo "=============================================="
}

# =============================================================================
# Corrections
# =============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🔧 Correction Réseau Docker macOS      ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    section "Méthode 1 : Redémarrage Containers"

    info "Arrêt des containers..."
    docker-compose down

    info "Attente 5 secondes..."
    sleep 5

    info "Redémarrage des containers..."
    docker-compose up -d

    info "Attente démarrage (60 secondes)..."
    sleep 60

    info "Test de connectivité..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q "200"; then
        success "RÉSOLU ! Application accessible"
        echo ""
        info "URL : http://localhost:8080/"
        info "Login : admin / admin"
        exit 0
    else
        warning "Méthode 1 échouée, passage à la méthode 2..."
    fi

    section "Méthode 2 : Recreation des volumes Docker"

    warning "Cette méthode va supprimer les données de la base"
    read -p "Continuer ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Annulé par l'utilisateur"
        exit 1
    fi

    info "Arrêt et suppression complète..."
    docker-compose down -v

    info "Rebuild des images..."
    docker-compose build --no-cache

    info "Redémarrage..."
    docker-compose up -d

    info "Attente démarrage (90 secondes)..."
    sleep 90

    info "Test de connectivité..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q "200"; then
        success "RÉSOLU ! Application accessible"
        echo ""
        info "URL : http://localhost:8080/"
        info "Login : admin / admin"
        exit 0
    else
        warning "Méthode 2 échouée"
    fi

    section "Méthode 3 : Accès Direct via IP Container"

    AXELOR_IP=$(docker inspect axelor-vecia-app --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "N/A")

    if [ "$AXELOR_IP" != "N/A" ]; then
        info "IP du container Axelor : $AXELOR_IP"
        echo ""
        info "Essayez d'accéder via : http://$AXELOR_IP:8080/"
        echo ""
        info "Commande pour ouvrir dans le navigateur :"
        echo "  open http://$AXELOR_IP:8080/"
    fi

    section "Méthode 4 : Solutions Manuelles"

    echo ""
    warning "Si rien ne fonctionne, problème Docker Desktop macOS"
    echo ""
    echo "Solutions manuelles :"
    echo "  1. Redémarrer Docker Desktop"
    echo "  2. Augmenter la mémoire allouée à Docker (Préférences > Resources)"
    echo "  3. Réinitialiser Docker aux paramètres d'usine (⚠️ supprime tout)"
    echo "  4. Mettre à jour Docker Desktop vers la dernière version"
    echo "  5. Essayer avec le navigateur (Chrome/Firefox) au lieu de curl"
    echo ""
    info "Commande pour tester dans le navigateur :"
    echo "  open http://localhost:8080/"
    echo ""
    info "Commande pour voir les logs :"
    echo "  docker-compose logs -f axelor"
    echo ""
}

main "$@"
