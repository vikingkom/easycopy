#!/bin/bash

# EasyCopy Quick Start Script
# Starts both the server and web viewer

echo "🚀 Starting EasyCopy..."

# Check if server is already running
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Server already running on port 8000"
else
    echo "📡 Starting server..."
    cd server
    python main.py &
    SERVER_PID=$!
    cd ..
    echo "✅ Server started (PID: $SERVER_PID)"
fi

# Check if webapp is already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✅ Web viewer already running on port 3000"
else
    echo "🌐 Starting web viewer..."
    cd webapp
    
    # Check if node_modules exists
    if [ ! -d "node_modules" ]; then
        echo "📦 Installing dependencies..."
        npm install
    fi
    
    npm run dev &
    WEBAPP_PID=$!
    cd ..
    echo "✅ Web viewer started (PID: $WEBAPP_PID)"
fi

echo ""
echo "✨ EasyCopy is ready!"
echo ""
echo "📡 Server: http://localhost:8000"
echo "🌐 Web Viewer: http://localhost:3000"
echo ""
echo "To stop, press Ctrl+C"

# Wait for user interrupt
wait
