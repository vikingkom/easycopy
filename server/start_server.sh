#!/bin/bash
# EasyCopy Server Startup Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Activate the local virtual environment
source .venv/bin/activate

echo "Starting EasyCopy Server on http://localhost:8000"
exec python main.py
