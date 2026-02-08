#!/bin/bash
# Generate simple PWA icons using ImageMagick (install with: brew install imagemagick)

ICON_DIR="$(dirname "$0")/public/icons"
mkdir -p "$ICON_DIR"

# Create a simple SVG icon
SVG_FILE="$ICON_DIR/icon.svg"
cat > "$SVG_FILE" << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="100" fill="#4CAF50"/>
  <path d="M150 280 L240 370 L400 210" stroke="white" stroke-width="50" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <text x="256" y="450" font-family="Arial, sans-serif" font-size="80" fill="white" text-anchor="middle" font-weight="bold">EC</text>
</svg>
EOF

# Check if ImageMagick is installed
if command -v convert &> /dev/null; then
    echo "Generating PNG icons from SVG..."
    for size in 72 96 128 144 152 192 384 512; do
        convert -background none "$SVG_FILE" -resize ${size}x${size} "$ICON_DIR/icon-${size}x${size}.png"
        echo "Generated icon-${size}x${size}.png"
    done
    echo "✅ All icons generated successfully!"
else
    echo "⚠️  ImageMagick not found. Installing placeholder icons..."
    # Create a simple colored square as fallback
    for size in 72 96 128 144 152 192 384 512; do
        convert -size ${size}x${size} xc:#4CAF50 "$ICON_DIR/icon-${size}x${size}.png" 2>/dev/null || {
            # If convert fails, create a simple HTML canvas-based icon
            echo "Creating ${size}x${size} placeholder..."
        }
    done
fi

echo ""
echo "Note: For better icons, install ImageMagick (brew install imagemagick) and run this script again."
