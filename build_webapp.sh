#!/bin/bash
# Build the React webapp and copy to server/static/

set -e

echo "Building EasyCopy webapp..."

cd webapp
npm install
npm run build

echo "Copying build to server/static/..."
mkdir -p ../server/static
cp -r dist/* ../server/static/

echo "✓ Webapp built successfully!"
echo "  Output: server/static/"
