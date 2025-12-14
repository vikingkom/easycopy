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

### 2. Build Web Viewer (First Time Only)

```bash
cd server
./build_webapp.sh
```

This builds the React webapp and copies it to `server/static/`.

### 3. Start the Server (Easy Mode)

From the project root:

```bash
./start.sh
```

This will:
- Build the webapp if needed (first time only)
- Start the integrated FastAPI server on port 8000
- Serve both the API and web viewer on the same port

### 4. Manual Start (Alternative)

**Start Server:**
```bash
cd server
python main.py
```

Access everything at `http://localhost:8000`

**For webapp development with hot reload:**
```bash
cd server/webapp
npm run dev  # Runs on port 8000 with API proxying
```

**Test Upload:**
```bash
cd client
pip install -r requirements.txt
python upload.py
```

## Using the Web Viewer

1. Open http://localhost:8000 in your browser
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

To change this, create `server/webapp/.env`:

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
cd server
./build_webapp.sh
```

This creates optimized static files in `server/static/`.

### Integrated Server

The web viewer is integrated into the FastAPI server and automatically served from `server/static/`.

Just start the server:
```bash
cd server
python main.py
```

Both the API and web viewer are available at `http://localhost:8000` - no separate web server needed

**For custom deployment:**

**Option 1: Nginx reverse proxy**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
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
2. Open http://localhost:8000
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
