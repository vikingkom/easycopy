#!/bin/bash
set -e

# EasyCopy Production Server Installation Script (HTTPS)
# Usage: curl -sSL https://raw.githubusercontent.com/vikingkom/easycopy/master/install-production.sh | bash

echo "╔═══════════════════════════════════════╗"
echo "║   EasyCopy Production Installation    ║"
echo "║          (HTTPS/SSL)                  ║"
echo "╚═══════════════════════════════════════╝"
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

# Require domain for production
echo "⚠️  Production setup requires a domain name"
echo ""
read -p "Enter your domain name (e.g., easycopy.example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ Error: Domain name is required for production setup"
    echo ""
    echo "For local/development setup without HTTPS, use:"
    echo "  curl -sSL https://raw.githubusercontent.com/vikingkom/easycopy/master/install.sh | bash"
    exit 1
fi

echo ""
echo "📋 Domain: $DOMAIN"
echo ""

# Use current directory for installation
INSTALL_DIR="$(pwd)"

echo "📁 Installing to: $INSTALL_DIR"
echo ""

# Download necessary files
echo "📥 Downloading files..."

REPO_BASE="https://raw.githubusercontent.com/vikingkom/easycopy/master/server"

# Download production docker-compose
curl -sSL "$REPO_BASE/docker-compose.production.yml" -o docker-compose.yml

# Download nginx config
curl -sSL "$REPO_BASE/nginx.conf" -o nginx.conf

# Download config template
curl -sSL "$REPO_BASE/easycopy.env.template" -o easycopy.env.template

echo "✅ Files downloaded"
echo ""

# Create config file if it doesn't exist
if [ ! -f "easycopy.env" ]; then
    echo "📝 Creating configuration file..."
    cp easycopy.env.template easycopy.env
    
    # Set domain
    sed -i.bak "s/# EASYCOPY_DOMAIN=/EASYCOPY_DOMAIN=$DOMAIN/" easycopy.env
    
    # SSL domain for nginx
    echo "SSL_DOMAIN=$DOMAIN" >> easycopy.env
    
    # Optional: download directory
    read -p "Download directory [~/Downloads/easycopy]: " DOWNLOAD_DIR
    DOWNLOAD_DIR=${DOWNLOAD_DIR:-~/Downloads/easycopy}
    sed -i.bak "s|EASYCOPY_DOWNLOAD_DIR=~/Downloads/easycopy|EASYCOPY_DOWNLOAD_DIR=$DOWNLOAD_DIR|" easycopy.env
    
    rm -f easycopy.env.bak
    
    echo "✅ Configuration saved to easycopy.env"
else
    echo "ℹ️  Using existing configuration file"
fi

echo ""

# SSL Certificate information
echo "🔒 SSL Certificate Setup"
echo ""
echo "This installation will generate a self-signed SSL certificate."
echo ""
echo "For production with trusted certificates (Let's Encrypt), see:"
echo "  https://github.com/vikingkom/easycopy/blob/master/HTTPS_SETUP.md"
echo ""
read -p "Continue with self-signed certificate? (y/n) [y]: " CONTINUE
CONTINUE=${CONTINUE:-y}

if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
    echo "Installation cancelled."
    echo "Please follow HTTPS_SETUP.md for Let's Encrypt setup."
    exit 0
fi

echo ""

# Pull and start the containers
echo "🐳 Starting EasyCopy production server..."
echo ""

# Use docker compose or docker-compose depending on what's available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Export SSL_DOMAIN for docker-compose
export SSL_DOMAIN="$DOMAIN"

$DOCKER_COMPOSE up -d

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉           ║"
echo "╚═══════════════════════════════════════╝"
echo ""

echo "🌐 Server URL: https://$DOMAIN"
echo "📋 Web Viewer: https://$DOMAIN"
echo "🔓 HTTP: http://$DOMAIN (redirects to HTTPS)"
echo ""
echo "⚠️  Using self-signed SSL certificate"
echo "   Browsers will show security warnings"
echo "   For trusted certificates, see: HTTPS_SETUP.md"
echo ""
echo "Useful commands:"
echo "  Start:   cd $INSTALL_DIR && $DOCKER_COMPOSE start"
echo "  Stop:    cd $INSTALL_DIR && $DOCKER_COMPOSE stop"
echo "  Restart: cd $INSTALL_DIR && $DOCKER_COMPOSE restart"
echo "  Logs:    cd $INSTALL_DIR && $DOCKER_COMPOSE logs -f"
echo "  Update:  cd $INSTALL_DIR && $DOCKER_COMPOSE pull && $DOCKER_COMPOSE up -d"
echo ""
echo "Configuration: $INSTALL_DIR/easycopy.env"
echo ""
echo "Next steps:"
echo "1. Ensure DNS points $DOMAIN to this server's IP"
echo "2. For Let's Encrypt certificates, see HTTPS_SETUP.md"
echo "3. Set up clients with: export EASYCOPY_SERVER=\"https://$DOMAIN\""
echo ""
