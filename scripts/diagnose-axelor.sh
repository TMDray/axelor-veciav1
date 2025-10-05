#!/bin/bash
# =============================================================================
# Script de Diagnostic - Axelor Vecia
# =============================================================================
# Description : Diagnostic complet de l'installation Axelor
# Usage : ./scripts/diagnose-axelor.sh
# Auteur : Équipe Dev Axelor Vecia
# =============================================================================

set -e
set -u

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

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
# Diagnostic
# =============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🔍 Diagnostic Axelor Vecia             ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    # Section 1 : État containers
    section "1. État des Containers Docker"

    if docker-compose ps > /dev/null 2>&1; then
        docker-compose ps
        success "Docker Compose opérationnel"
    else
        error "Docker Compose non accessible"
        exit 1
    fi

    # Section 2 : Vérification santé containers
    section "2. Santé des Containers"

    POSTGRES_HEALTH=$(docker inspect axelor-vecia-postgres --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
    AXELOR_HEALTH=$(docker inspect axelor-vecia-app --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")

    echo "PostgreSQL : $POSTGRES_HEALTH"
    echo "Axelor App : $AXELOR_HEALTH"

    if [ "$POSTGRES_HEALTH" = "healthy" ]; then
        success "PostgreSQL healthy"
    else
        error "PostgreSQL NOT healthy"
    fi

    if [ "$AXELOR_HEALTH" = "healthy" ]; then
        success "Axelor App healthy"
    else
        error "Axelor App NOT healthy"
    fi

    # Section 3 : Logs récents
    section "3. Logs Récents Axelor"

    echo "Dernières lignes des logs :"
    docker-compose logs axelor --tail=10

    if docker-compose logs axelor | grep -q "Ready to serve"; then
        success "Application démarrée (Ready to serve)"
    else
        warning "Application peut-être pas démarrée"
    fi

    # Section 4 : Réseau Docker
    section "4. Configuration Réseau Docker"

    echo "IP du container Axelor :"
    AXELOR_IP=$(docker inspect axelor-vecia-app --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "N/A")
    echo "  → $AXELOR_IP"

    echo ""
    echo "Ports mappés :"
    docker port axelor-vecia-app 2>/dev/null || echo "  Aucun"

    # Section 5 : Tests de connectivité
    section "5. Tests de Connectivité"

    echo "Test 1 : Depuis l'intérieur du container (curl)"
    if docker exec axelor-vecia-app curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q "200"; then
        success "HTTP 200 OK depuis le container"
    else
        error "Échec HTTP depuis le container"
    fi

    echo ""
    echo "Test 2 : Depuis l'hôte (netcat)"
    if nc -zv localhost 8080 > /dev/null 2>&1; then
        success "Port 8080 accessible (TCP)"
    else
        error "Port 8080 NON accessible (TCP)"
    fi

    echo ""
    echo "Test 3 : Depuis l'hôte (curl)"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null || echo "FAIL")

    if [ "$HTTP_CODE" = "200" ]; then
        success "HTTP 200 OK depuis l'hôte"
    else
        error "HTTP depuis l'hôte : $HTTP_CODE"
    fi

    echo ""
    echo "Test 4 : Depuis l'hôte vers IP container"
    HTTP_CODE_IP=$(curl -s -o /dev/null -w "%{http_code}" http://$AXELOR_IP:8080/ 2>/dev/null || echo "FAIL")

    if [ "$HTTP_CODE_IP" = "200" ]; then
        success "HTTP 200 OK vers IP container"
    else
        error "HTTP vers IP container : $HTTP_CODE_IP"
    fi

    # Section 6 : Configuration Axelor
    section "6. Configuration Axelor"

    echo "Mode applicatif :"
    docker exec axelor-vecia-app grep "application.mode" /opt/axelor/axelor-config.properties 2>/dev/null || echo "  N/A"

    echo ""
    echo "Base URL :"
    docker exec axelor-vecia-app grep "application.base-url" /opt/axelor/axelor-config.properties 2>/dev/null || echo "  N/A"

    echo ""
    echo "Locale :"
    docker exec axelor-vecia-app grep "application.locale" /opt/axelor/axelor-config.properties 2>/dev/null || echo "  N/A"

    # Section 7 : Vérification Tomcat
    section "7. Configuration Tomcat"

    echo "Connector HTTP/1.1 sur port 8080 :"
    docker exec axelor-vecia-app cat /usr/local/tomcat/conf/server.xml | grep -A3 "Connector.*8080" 2>/dev/null || echo "  N/A"

    # Section 8 : Diagnostics système
    section "8. Informations Système"

    echo "Docker version :"
    docker version --format '{{.Server.Version}}' 2>/dev/null || echo "  N/A"

    echo ""
    echo "Docker Compose version :"
    docker-compose version --short 2>/dev/null || echo "  N/A"

    echo ""
    echo "OS :"
    uname -a

    # Section 9 : Recommandations
    section "9. Recommandations"

    echo ""
    if [ "$HTTP_CODE" != "200" ] && docker-compose logs axelor | grep -q "Ready to serve"; then
        warning "PROBLÈME DÉTECTÉ : Application OK dans le container, mais inaccessible depuis l'hôte"
        echo ""
        echo "Solutions possibles :"
        echo "  1. Problème Docker Desktop macOS - Redémarrer Docker Desktop"
        echo "  2. Essayer d'accéder via le navigateur (pas seulement curl)"
        echo "  3. Vérifier firewall macOS"
        echo "  4. Essayer avec l'IP du container : http://$AXELOR_IP:8080/"
        echo ""
        info "Commande de test navigateur :"
        echo "  open http://localhost:8080/"
        echo ""
        info "Commande de redémarrage Docker :"
        echo "  docker-compose down && docker-compose up -d"
    elif [ "$HTTP_CODE" = "200" ]; then
        success "TOUT FONCTIONNE ! Application accessible"
        echo ""
        info "URL : http://localhost:8080/"
        info "Login : admin / admin"
    else
        error "PROBLÈME MAJEUR : Application ne répond pas correctement"
        echo ""
        echo "Actions recommandées :"
        echo "  1. Vérifier les logs : docker-compose logs axelor"
        echo "  2. Redémarrer : docker-compose restart axelor"
        echo "  3. Rebuild : docker-compose down && docker-compose build && docker-compose up -d"
    fi

    echo ""
    section "Fin du diagnostic"
    echo ""
}

main "$@"
