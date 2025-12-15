#!/bin/bash
set -e

# EasyCopy Server Installation Script
# Installs to current directory

echo "╔═══════════════════════════════════════╗"
echo "║   EasyCopy Server Installation        ║"
echo "╚═══════════════════════════════════════╝"
echo ""

# Check if Docker Compose is available
if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose is not installed"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi



# Download necessary files
echo "📥 Downloading files..."


REPO_BASE="https://raw.githubusercontent.com/vikingkom/easycopy/master/server"

curl -sSL "$REPO_BASE/docker-compose.yml" -o docker-compose.yml
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

# Start the container using the main compose file
echo "🐳 Starting EasyCopy server..."
$DOCKER_COMPOSE -f docker-compose.yml up -d

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║   Installation Complete! 🎉           ║"
echo "╚═══════════════════════════════════════╝"
echo ""
echo "🌐 Server URL: http://localhost:8000"
echo "📋 Web Viewer: http://localhost:8000"
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
