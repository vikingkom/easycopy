# EasyCopy Web Viewer

A React-based web application for monitoring and interacting with your EasyCopy clipboard sync server.

## Features

- 📊 Real-time clipboard monitoring with auto-refresh (5s interval)
- 📝 Text content display with truncation and "Show More" functionality
- 📋 Copy text directly to your browser clipboard
- 🖼️ Image preview with download capability
- 📁 File information display with download button
- 🔄 Manual refresh button
- ⏱️ Last updated timestamp
- 📱 Responsive design

## Prerequisites

- Node.js 18+ and npm
- EasyCopy server running (default: http://localhost:8000)

## Installation

```bash
cd webapp
npm install
```

## Configuration

Create a `.env` file in the webapp directory (optional):

```bash
VITE_API_URL=http://localhost:8000
```

If not specified, defaults to `http://localhost:8000`.

## Running the App

### Development Mode

```bash
npm run dev
```

The app will start on http://localhost:3000

### Production Build

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
