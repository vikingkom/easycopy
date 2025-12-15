# ⚠️ Webapp Has Been Moved

**The webapp has been integrated into the server module.**

## New Location

The webapp source is now located at: **`server/webapp/`**

This directory is kept for backward compatibility but will be removed in a future version.

## Quick Start

To build and run the server with integrated web viewer:

```bash
# Quick start (builds if needed and runs server)
cd server && ./build_webapp.sh && python main.py

# Or manually
cd server
./build_webapp.sh  # First time only
python main.py
```

The web viewer will be available at `http://localhost:8000`

## Development

For webapp development with hot reload:

```bash
cd server/webapp
npm install
npm run dev  # Opens development server on port 3000
```

## Migration Notes

- All webapp source files are now in `server/webapp/`
- Built files are served from `server/static/`
- The webapp is fully integrated into the FastAPI server
- No separate web server needed - everything runs on port 8000

See the main [README.md](../README.md) for full documentation.

---

# Old Documentation (Deprecated)

## Features

- 📊 Real-time clipboard monitoring with auto-refresh (5s interval)
- 📝 Text content display with truncation and "Show More" functionality
- 📋 Copy text directly to your browser clipboard
- 🖼️ Image preview with download capability
- 📁 File information display with download button
- 🔄 Manual refresh button
- ⏱️ Last updated timestamp
- 📱 Responsive design

## Configuration (Old)

Create a `.env` file in the webapp directory (optional):

```bash
VITE_API_URL=http://localhost:8000
```

## Old Build Instructions

```bash
npm run build
```

This creates optimized static files in the `dist/` directory. You can serve these with any static file server:

```bash
npm run preview
```

Or use a simple HTTP server:

```bash
cd dist
python3 -m http.server 3000
```

## Usage

1. **Start the EasyCopy server** (in another terminal):
   ```bash
   cd ../server
   python main.py
   ```

2. **Upload clipboard content** using the upload client:
   ```bash
   cd ../client
   python upload.py
   ```

3. **Open the web viewer** at http://localhost:3000

4. The viewer will automatically:
   - Fetch clipboard status every 5 seconds (if auto-refresh is enabled)
   - Display the content type, metadata, and timestamp
   - Allow you to interact with the content (copy, download, etc.)

## Content Type Handling

### Text Content
- Shows character count
- Truncates at 300 characters with "Show More" button
- "Copy to Clipboard" button copies full text

### Image Content
- Displays image inline
- Shows format, size, and dimensions
- "Download Image" button saves with original format

### File Content
- Shows filename, size, and MIME type
- Large file icon indicator
- "Download File" button downloads with original filename

## Controls

- **Refresh Button**: Manually fetch latest clipboard status
- **Auto-refresh Toggle**: Enable/disable automatic 5-second refresh
- **Last Updated**: Shows timestamp of last successful fetch

## Troubleshooting

### CORS Errors
If you see CORS errors, ensure the server is running with CORS middleware enabled (already configured in the updated `server/main.py`).

### Connection Refused
- Verify the server is running on port 8000
- Check the `VITE_API_URL` configuration
- Ensure no firewall is blocking the connection

### Images Not Loading
- Check browser console for errors
- Verify the image was uploaded correctly to the server
- Try refreshing the page

## Development

The app uses:
- **React 18** for UI
- **Vite** for fast development and building
- **Native Fetch API** for server communication
- **CSS** for styling (no additional libraries)

### Project Structure

```
webapp/
├── src/
│   ├── App.jsx          # Main component with all logic
│   ├── App.css          # Component styles
│   ├── main.jsx         # React entry point
│   └── index.css        # Global styles
├── index.html           # HTML template
├── vite.config.js       # Vite configuration
└── package.json         # Dependencies
```

## API Endpoints Used

- `GET /status` - Get clipboard status and metadata
- `GET /download/file` - Download file content
- `GET /download/image` - Download/display image content
