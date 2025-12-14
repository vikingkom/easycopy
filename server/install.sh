#!/bin/bash
set -e

# EasyCopy Server Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/vikingkom/easycopy/master/install.sh | bash

echo "╔═══════════════════════════════════════╗"
echo "║   EasyCopy Server Installation        ║"
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

# Create installation directory
INSTALL_DIR="${EASYCOPY_INSTALL_DIR:-$HOME/.easycopy}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "📁 Installing to: $INSTALL_DIR"
echo ""

# Download necessary files
echo "📥 Downloading files..."

REPO_BASE="https://raw.githubusercontent.com/vikingkom/easycopy/master/server"

# Download docker-compose.yml
curl -sSL "$REPO_BASE/docker-compose.yml" -o docker-compose.yml

# Download config template
curl -sSL "$REPO_BASE/easycopy.env.template" -o easycopy.env.template

echo "✅ Files downloaded"
echo ""

# Create config file if it doesn't exist
if [ ! -f "easycopy.env" ]; then
    echo "📝 Creating configuration file..."
    cp easycopy.env.template easycopy.env
    
    # Interactive configuration
    read -p "Server port [8000]: " PORT
    PORT=${PORT:-8000}
    sed -i.bak "s/EASYCOPY_PORT=8000/EASYCOPY_PORT=$PORT/" easycopy.env
    
    read -p "Domain (leave empty for localhost): " DOMAIN
    if [ -n "$DOMAIN" ]; then
        sed -i.bak "s/# EASYCOPY_DOMAIN=/EASYCOPY_DOMAIN=$DOMAIN/" easycopy.env
    fi
    
    read -p "Download directory [~/Downloads/easycopy]: " DOWNLOAD_DIR
    DOWNLOAD_DIR=${DOWNLOAD_DIR:-~/Downloads/easycopy}
    sed -i.bak "s|EASYCOPY_DOWNLOAD_DIR=~/Downloads/easycopy|EASYCOPY_DOWNLOAD_DIR=$DOWNLOAD_DIR|" easycopy.env
    
    rm -f easycopy.env.bak
    
    echo "✅ Configuration saved to easycopy.env"
else
    echo "ℹ️  Using existing configuration file"
fi

echo ""

# Pull and start the container
echo "🐳 Starting EasyCopy server..."
echo ""

# Use docker compose or docker-compose depending on what's available
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

$DOCKER_COMPOSE up -d

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉           ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Read port from config
PORT=$(grep "^EASYCOPY_PORT=" easycopy.env | cut -d'=' -f2)
PORT=${PORT:-8000}

DOMAIN=$(grep "^EASYCOPY_DOMAIN=" easycopy.env | cut -d'=' -f2)

if [ -n "$DOMAIN" ]; then
    echo "🌐 Server URL: http://$DOMAIN:$PORT"
    echo "📋 Web Viewer: http://$DOMAIN:$PORT"
else
    echo "🌐 Server URL: http://localhost:$PORT"
    echo "📋 Web Viewer: http://localhost:$PORT"
fi

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
echo "1. Set up clients on your devices (see README for client setup)"
if [ -n "$DOMAIN" ]; then
    echo "2. Configure clients with: export EASYCOPY_SERVER=\"http://$DOMAIN:$PORT\""
else
    echo "2. Configure clients with: export EASYCOPY_SERVER=\"http://localhost:$PORT\""
fi
echo ""
