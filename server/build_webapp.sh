#!/bin/bash
# Build the React webapp and copy to server/static/

set -e

echo "Building EasyCopy webapp..."

cd "$(dirname "$0")/webapp"
npm install
npm run build

echo "Copying build to static/..."
mkdir -p ../static
cp -r dist/* ../static/

echo "✓ Webapp built successfully!"
echo "  Output: server/static/"
