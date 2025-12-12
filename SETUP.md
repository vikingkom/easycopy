# EasyCopy Web Viewer - Setup Guide

This guide will help you set up and run the complete EasyCopy system with the web viewer.

## Prerequisites

- **Python 3.8+** with pip
- **Node.js 18+** with npm
- **Docker** (optional, for containerized server)

## Step-by-Step Setup

### 1. Install Server Dependencies

```bash
cd server
pip install -r requirements.txt
```

### 2. Install Web Viewer Dependencies

```bash
cd ../webapp
npm install
```

### 3. Start Everything (Easy Mode)

From the project root:

```bash
./start.sh
```

This will:
- Start the FastAPI server on port 8000
- Start the React web viewer on port 3000
- Automatically open both in your browser

### 4. Manual Start (Alternative)

If you prefer to start components separately:

**Terminal 1 - Server:**
```bash
cd server
python main.py
```

**Terminal 2 - Web Viewer:**
```bash
cd webapp
npm run dev
```

**Terminal 3 - Test Upload:**
```bash
cd client
pip install -r requirements.txt
python upload.py
```

## Using the Web Viewer

1. Open http://localhost:3000 in your browser
2. Copy something to your clipboard
3. Run `python client/upload.py` to upload to server
4. Watch the web viewer automatically update (or click Refresh)

### Web Viewer Features

- **Auto-refresh**: Updates every 5 seconds (toggle on/off)
- **Manual refresh**: Click the refresh button anytime
- **Text content**: 
  - Shows character count
  - Truncates long text with "Show More"
  - Copy to clipboard button
- **Image content**:
  - Displays inline
  - Shows format, size, dimensions
  - Download button
- **File content**:
  - Shows filename, size, MIME type
  - Download button with original filename

## Configuration

### Server URL

By default, the web viewer connects to `http://localhost:8000`.

To change this, create `webapp/.env`:

```bash
VITE_API_URL=http://your-server-ip:8000
```

### Client Server URL

For upload/download clients, set:

```bash
export EASYCOPY_SERVER="http://your-server-ip:8000"
```

## Production Deployment

### Build the Web Viewer

```bash
cd webapp
npm run build
```

This creates optimized static files in `webapp/dist/`.

### Serve Static Files

**Option 1: Python HTTP Server**
```bash
cd webapp/dist
python3 -m http.server 3000
```

**Option 2: Nginx**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        root /path/to/easycopy/webapp/dist;
        try_files $uri /index.html;
    }
}
```

**Option 3: Serve from FastAPI**

Add to `server/main.py`:
```python
from fastapi.staticfiles import StaticFiles

app.mount("/", StaticFiles(directory="../webapp/dist", html=True), name="static")
```

### Docker Deployment

Use docker-compose for the server:

```bash
docker-compose up -d
```

Then serve the web viewer separately or add it to docker-compose.

## Troubleshooting

### Port Already in Use

**Server (8000):**
```bash
lsof -ti:8000 | xargs kill -9
```

**Web Viewer (3000):**
```bash
lsof -ti:3000 | xargs kill -9
```

### CORS Issues

If you see CORS errors in the browser console:
1. Ensure the server has CORS middleware enabled (already configured)
2. Check that `VITE_API_URL` matches your actual server URL
3. For production, update the `allow_origins` in `server/main.py`

### Web Viewer Not Connecting

1. Verify server is running: `curl http://localhost:8000/status`
2. Check browser console for errors (F12)
3. Verify the API URL in browser DevTools → Network tab

### Images Not Displaying

1. Ensure the image was uploaded successfully
2. Check server logs for errors
3. Try refreshing the page
4. Verify the `/download/image` endpoint works: open in new tab

### Dependencies Issues

**Server:**
```bash
cd server
pip install --upgrade -r requirements.txt
```

**Web Viewer:**
```bash
cd webapp
rm -rf node_modules package-lock.json
npm install
```

## Testing

### Test Server

```bash
curl http://localhost:8000/status
```

Expected: `{"has_data":false}` (if nothing uploaded yet)

### Test Upload

```bash
cd client
python upload.py
```

Copy some text first, then run the command.

### Test Web Viewer

1. Upload some content
2. Open http://localhost:3000
3. Click "Refresh" button
4. Verify content appears

## Development

### Hot Reload

Both server and web viewer support hot reload:

**Server:**
```bash
cd server
uvicorn main:app --reload
```

**Web Viewer:**
```bash
cd webapp
npm run dev
```

Changes are automatically reflected.

### API Documentation

FastAPI provides auto-generated docs:
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Next Steps

1. Set up keyboard shortcuts for upload/download (see main README)
2. Configure for remote access
3. Add authentication (future enhancement)
4. Set up SSL/TLS for production

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review server logs
3. Check browser console
4. Open an issue on GitHub
