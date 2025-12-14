#!/bin/bash
set -e

# EasyCopy Production Server Installation Script (HTTPS)
# Installs to current directory
# Requires SSL_DOMAIN environment variable

echo "╔═══════════════════════════════════════╗"
echo "║   EasyCopy Production Installation    ║"
echo "║          (HTTPS/SSL)                  ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Check for required SSL_DOMAIN
if [ -z "$SSL_DOMAIN" ]; then
    echo "❌ Error: SSL_DOMAIN environment variable is required"
    echo ""
    echo "Usage: SSL_DOMAIN=your-domain.com ./install-production.sh"
    echo ""
    echo "For local/development setup without HTTPS, use install.sh instead"
    exit 1
fi

echo "📋 Domain: $SSL_DOMAIN"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo ""
    echo "Please install Docker first:"
    echo "  - macOS: https://docs.docker.com/desktop/install/mac-install/"
    echo "  - Linux: https://docs.docker.com/engine/install/"
    echo "  - Windows: https://docs.docker.com/desktop/install/windows-install/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose is not installed"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker detected"
echo ""

# Download necessary files
echo "📥 Downloading files..."

REPO_BASE="https://raw.githubusercontent.com/vikingkom/easycopy/master/server"

curl -sSL "$REPO_BASE/docker-compose.production.yml" -o docker-compose.yml
curl -sSL "$REPO_BASE/nginx.conf" -o nginx.conf
curl -sSL "$REPO_BASE/easycopy.env.template" -o .env

echo "✅ Files downloaded"
echo ""

# Create config file from template if downloaded template doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env from template..."
    curl -sSL "$REPO_BASE/easycopy.env.template" -o .env
    echo "✅ Configuration file created"
else
    echo "ℹ️  Using existing .env"
fi

echo ""

# Determine docker compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Start the containers
echo "🐳 Starting EasyCopy production server..."
$DOCKER_COMPOSE up -d

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉           ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "🌐 Server URL: https://$SSL_DOMAIN"
echo "📋 Web Viewer: https://$SSL_DOMAIN"
echo ""
echo "⚠️  Using self-signed SSL certificate"
echo "   Browsers will show security warnings"
echo "   For Let's Encrypt certificates, see HTTPS_SETUP.md"
echo ""
echo "📝 Edit .env to customize settings, then restart:"
echo "   $DOCKER_COMPOSE restart"
echo ""
echo "Useful commands:"
echo "  Start:   $DOCKER_COMPOSE start"
echo "  Stop:    $DOCKER_COMPOSE stop"
echo "  Restart: $DOCKER_COMPOSE restart"
echo "  Logs:    $DOCKER_COMPOSE logs -f"
echo "  Update:  $DOCKER_COMPOSE pull && $DOCKER_COMPOSE up -d"
echo ""
