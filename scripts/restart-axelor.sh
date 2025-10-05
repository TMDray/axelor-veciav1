#!/bin/bash
# =============================================================================
# Script de Redémarrage - Axelor Vecia
# =============================================================================
# Description : Redémarrage propre après arrêt Docker Desktop
# Usage : ./scripts/restart-axelor.sh
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

# =============================================================================
# Redémarrage
# =============================================================================

main() {
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🚀 Redémarrage Axelor Vecia            ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    # Vérifier que Docker est bien lancé
    info "Vérification de Docker..."

    if ! docker info > /dev/null 2>&1; then
        error "Docker n'est pas démarré !"
        echo ""
        echo "Veuillez :"
        echo "  1. Lancer Docker Desktop"
        echo "  2. Attendre que Docker soit complètement démarré (icône stable)"
        echo "  3. Relancer ce script"
        exit 1
    fi

    success "Docker est opérationnel"

    # Démarrage des containers
    info "Démarrage des containers Axelor..."
    docker-compose up -d

    # Attente PostgreSQL
    info "Attente démarrage PostgreSQL (15s)..."
    sleep 15

    # Vérification PostgreSQL
    if docker exec axelor-vecia-postgres pg_isready -U axelor > /dev/null 2>&1; then
        success "PostgreSQL prêt"
    else
        warning "PostgreSQL pas encore prêt, attente supplémentaire..."
        sleep 10
    fi

    # Attente Axelor
    info "Attente démarrage Axelor (60s)..."
    echo ""
    echo "⏳ Initialisation en cours..."

    for i in {1..12}; do
        sleep 5
        if docker-compose logs axelor 2>/dev/null | grep -q "Ready to serve"; then
            echo ""
            success "Axelor démarré !"
            break
        fi
        echo -n "."
    done

    echo ""
    echo ""

    # Vérification santé
    info "Vérification santé des containers..."
    docker-compose ps

    echo ""

    # Tests de connectivité
    info "Tests de connectivité..."

    # Test 1 : Depuis container
    if docker exec axelor-vecia-app curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q "200"; then
        success "✓ HTTP OK depuis le container"
    else
        error "✗ HTTP KO depuis le container"
    fi

    # Test 2 : Port TCP
    if nc -zv localhost 8080 > /dev/null 2>&1; then
        success "✓ Port 8080 accessible"
    else
        error "✗ Port 8080 inaccessible"
    fi

    # Test 3 : HTTP depuis macOS
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        success "✓ HTTP OK depuis macOS"

        echo ""
        echo "══════════════════════════════════════════"
        success "🎉 AXELOR EST OPÉRATIONNEL !"
        echo "══════════════════════════════════════════"
        echo ""
        echo "🌐 URL      : http://localhost:8080/"
        echo "👤 Username : admin"
        echo "🔑 Password : admin"
        echo ""
        info "Commande pour ouvrir dans le navigateur :"
        echo "  open http://localhost:8080/"
        echo ""

    else
        warning "✗ HTTP KO depuis macOS (code: $HTTP_CODE)"

        echo ""
        echo "══════════════════════════════════════════"
        warning "⚠️  Problème de connectivité détecté"
        echo "══════════════════════════════════════════"
        echo ""

        # Récupérer IP container
        AXELOR_IP=$(docker inspect axelor-vecia-app --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)

        echo "Solutions à essayer :"
        echo ""
        echo "  1. Ouvrir dans le navigateur (peut fonctionner même si curl échoue) :"
        echo "     open http://localhost:8080/"
        echo ""
        echo "  2. Essayer avec l'IP du container :"
        echo "     open http://$AXELOR_IP:8080/"
        echo ""
        echo "  3. Voir les logs :"
        echo "     docker-compose logs -f axelor"
        echo ""
        echo "  4. Lancer le diagnostic :"
        echo "     ./scripts/diagnose-axelor.sh"
        echo ""
    fi
}

main "$@"
