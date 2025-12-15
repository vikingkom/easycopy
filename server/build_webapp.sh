#!/bin/bash
# Build the React webapp and copy to server/static/

set -e

echo "Building EasyCopy webapp..."

cd "$(dirname "$0")/webapp"

# Copy .env if present (for VITE_API_URL)
if [ -f .env ]; then
	echo "Using .env for webapp build:"
	cat .env
else
	echo "No .env found in webapp directory."
fi

npm install
npm run build

echo "Copying build to static/..."
mkdir -p ../static
cp -r dist/* ../static/

echo "✓ Webapp built successfully!"
echo "  Output: server/static/"
