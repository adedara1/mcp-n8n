#!/bin/bash
# Script de déploiement pour Render.com - n8n MCP Server

set -e

echo "🚀 Préparation du déploiement pour Render.com..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Ce script doit être exécuté depuis la racine du projet n8n-mcp"
    exit 1
fi

# Check if render.yaml exists
if [ ! -f "render.yaml" ]; then
    print_error "Le fichier render.yaml n'existe pas. Créez-le d'abord."
    exit 1
fi

print_info "Vérification des prérequis..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js n'est pas installé"
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    print_error "Git n'est pas installé"
    exit 1
fi

print_success "Prérequis validés"

# Build the project locally to check for errors
print_info "Test de compilation local..."
if ! npm run build; then
    print_error "Échec de la compilation. Corrigez les erreurs avant de déployer."
    exit 1
fi
print_success "Compilation réussie"

# Check if there are uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_warning "Il y a des changements non commiténts dans le répertoire de travail"
    read -p "Voulez-vous continuer ? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
print_info "Branche actuelle: $CURRENT_BRANCH"

# Check if render CLI is installed
if command -v render &> /dev/null; then
    print_info "Render CLI détecté, déploiement automatique possible"
    
    read -p "Voulez-vous déployer automatiquement avec Render CLI ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Déploiement avec Render CLI..."
        
        # Deploy each service
        print_info "Déploiement du serveur HTTP standard..."
        render services deploy --service-id n8n-mcp-server 2>/dev/null || print_warning "Service HTTP non trouvé ou erreur de déploiement"
        
        print_info "Déploiement du serveur SSE..."
        render services deploy --service-id n8n-mcp-sse-server 2>/dev/null || print_warning "Service SSE non trouvé ou erreur de déploiement"
        
        print_info "Déploiement du serveur n8n-compatible..."
        render services deploy --service-id n8n-mcp-n8n-compat 2>/dev/null || print_warning "Service n8n-compat non trouvé ou erreur de déploiement"
        
        print_success "Déploiement terminé"
    fi
else
    print_info "Render CLI non installé. Déploiement manuel requis."
fi

echo ""
print_info "Instructions de déploiement manuel :"
echo "1. Connectez-vous à https://dashboard.render.com"
echo "2. Connectez votre dépôt GitHub"
echo "3. Créez un nouveau service Web avec les paramètres suivants :"
echo "   - Build Command: npm install && npm run build"
echo "   - Start Command: npm run start:http"
echo "   - Node Version: 22"
echo ""
print_info "Variables d'environnement recommandées :"
echo "   - NODE_ENV=production"
echo "   - AUTH_TOKEN=[générez un token sécurisé]"
echo "   - LOG_LEVEL=info"
echo "   - CORS_ORIGIN=*"
echo "   - TRUST_PROXY=1"
echo ""
print_info "Pour SSE mode, utilisez: npm run start:sse"
print_info "Pour mode n8n-compatible, ajoutez: N8N_COMPATIBILITY_MODE=true"
echo ""
print_info "Fichiers de configuration créés :"
echo "   - render.yaml (configuration multi-services)"
echo "   - Dockerfile.render (containerisation optimisée)"
echo "   - .env.render (variables d'environnement par défaut)"
echo ""
print_success "Préparation terminée ! 🎉"
echo ""
print_warning "N'oubliez pas de :"
echo "1. Définir AUTH_TOKEN dans les variables d'environnement Render"
echo "2. Configurer les URLs d'API n8n si nécessaire"
echo "3. Tester le health check : https://your-app.onrender.com/health"