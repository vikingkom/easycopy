#!/bin/bash

# EasyCopy Quick Start Script
# Starts the server (which includes the web viewer)

echo "🚀 Starting EasyCopy..."

# Check if server is already running
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Server already running on port 8000"
else
    echo "📡 Starting server with integrated web viewer..."
    cd server
    
    # Build webapp if static files don't exist
    if [ ! -d "static" ] || [ ! -f "static/index.html" ]; then
        echo "📦 Building web viewer (first time setup)..."
        ./build_webapp.sh
    fi
    
    python main.py &
    SERVER_PID=$!
    cd ..
    echo "✅ Server started (PID: $SERVER_PID)"
fi

echo ""
echo "✨ EasyCopy is ready!"
echo ""
echo "📡 Server API: http://localhost:8000"
echo "🌐 Web Viewer: http://localhost:8000"
echo ""
echo "To stop, press Ctrl+C"

# Wait for user interrupt
wait
