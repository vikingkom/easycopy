#!/bin/bash
# EasyCopy Server Startup Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Starting EasyCopy Server on http://localhost:8000"
exec python3 main.py
