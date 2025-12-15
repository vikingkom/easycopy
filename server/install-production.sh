#!/bin/bash
set -e

# EasyCopy Production Server Installation Script
# Downloads docker-compose.production.yml and creates .env if needed

echo "╔═══════════════════════════════════════╗"
echo "║   EasyCopy Production Installation    ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Download necessary files
echo "📥 Downloading docker-compose.production.yml..."

REPO_BASE="https://raw.githubusercontent.com/vikingkom/easycopy/master/server"

curl -sSL "$REPO_BASE/docker-compose.production.yml" -o docker-compose.production.yml

echo "✅ docker-compose.production.yml downloaded"
echo ""

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose is not installed"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

# Determine docker compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi

# Create .env file from template if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env from template..."
    curl -sSL "$REPO_BASE/easycopy.env.template" -o .env
    echo "✅ .env file created"
else
    echo "ℹ️  .env file already exists"
fi

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉           ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "📝 Edit .env to configure your domain and settings"
echo ""
echo "  Start: $DOCKER_COMPOSE -f docker-compose.production.yml up -d"
echo "  Stop:    $DOCKER_COMPOSE stop"
echo "  Logs:    $DOCKER_COMPOSE logs -f"
echo "  Update:  $DOCKER_COMPOSE pull && $DOCKER_COMPOSE up -d"
echo "  Update:  $DOCKER_COMPOSE pull && $DOCKER_COMPOSE up -d"
echo ""
