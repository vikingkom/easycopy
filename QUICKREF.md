# EasyCopy Web Viewer - Quick Reference

## 🚀 Quick Start

```bash
# From project root
cd server && ./build_webapp.sh && python main.py
```

Then open http://localhost:8000

## 📡 API Endpoints

### Server Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/status` | GET | Get clipboard status and metadata |
| `/upload` | POST | Upload clipboard content |
| `/download` | GET | Download clipboard content |
| `/download/file` | GET | Download file with original name |
| `/download/image` | GET | Get image for display/download |
| `/clear` | DELETE | Clear clipboard data |

### Status Response

```json
{
  "has_data": true,
  "type": "text|file|image",
  "size": 1234,
  "metadata": {
    "filename": "example.txt",
    "mime_type": "text/plain",
    ...
  },
  "timestamp": "2025-12-12T10:30:00"
}
```

## 🎨 Web Viewer Features

### Auto-Refresh
- **Enabled by default** (5-second interval)
- Toggle on/off with checkbox
- Manual refresh button always available

### Content Types

#### Text
- Character count displayed
- Truncates at 300 chars
- "Show More" button for long text
- "Copy to Clipboard" button

#### Image
- Inline preview
- Format, size, dimensions shown
- "Copy Image URL" button
- "Download Image" button

#### File
- File icon display
- Filename, size, MIME type shown
- "Download File" button
- Downloads with original filename

## ⚙️ Configuration

### Environment Variables

**Server:**
```bash
# No config needed for local development
# For remote: just change host binding in main.py
```

**Web Viewer:**
```bash
# Create server/webapp/.env (optional, defaults to http://localhost:8000)
VITE_API_URL=http://your-server:8000
```

**Upload/Download Clients:**
```bash
export EASYCOPY_SERVER="http://your-server:8000"
```

## 🔧 Useful Commands

### Development

```bash
# Server with integrated web viewer
cd server && ./build_webapp.sh && uvicorn main:app --reload

# Test upload
cd client && python upload.py

# Test download
cd client && python download.py
```

### Production

```bash
# Build web viewer
cd webapp && npm run build

# Preview production build
npm run preview

# Serve with Python
cd dist && python3 -m http.server 3000
```

### Docker

```bash
# Start server
docker-compose up -d

# View logs
docker-compose logs -f

# Stop server
docker-compose down
```

### Debugging

```bash
# Check server status
curl http://localhost:8000/status

# Check ports
lsof -i :8000  # Server
lsof -i :3000  # Web viewer

# Kill processes
lsof -ti:8000 | xargs kill -9
lsof -ti:3000 | xargs kill -9
```

## 🐛 Common Issues

### CORS Error
**Problem:** Web viewer can't connect to server  
**Solution:** CORS is already configured. Check server URL in `.env`

### Port in Use
**Problem:** "Address already in use"  
**Solution:** Kill the process: `lsof -ti:PORT | xargs kill -9`

### Dependencies Error
**Problem:** Import errors  
**Solution:**
```bash
# Server
cd server && pip install -r requirements.txt

# Web viewer
cd webapp && npm install
```

### Image Not Loading
**Problem:** Image shows broken icon  
**Solution:** 
1. Verify upload worked
2. Check server logs
3. Try refreshing page
4. Open `/download/image` directly

## 📊 Keyboard Shortcuts (Browser)

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + R` | Refresh page |
| `Cmd/Ctrl + Shift + R` | Hard refresh |
| `F12` | Open DevTools |
| `Cmd/Ctrl + C` | Copy selected text |

## 🔐 Security Notes

- **Default:** No authentication
- **Production:** Add API keys or OAuth
- **CORS:** Currently allows all origins (`*`)
  - Update `allow_origins` in `server/main.py` for production
 - **TLS:** Terminate TLS at your infrastructure edge (reverse proxy, load balancer, CDN)

## 📱 Browser Support

- ✅ Chrome/Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Opera 76+

## 🎯 Workflow Example

1. **Start services**
   ```bash
   cd server && ./build_webapp.sh && python main.py
   ```

2. **Open web viewer**
   - Navigate to http://localhost:8000
   - Enable auto-refresh

3. **Upload content**
   ```bash
   # Copy something to clipboard
   cd client && python upload.py
   ```

4. **Watch it appear**
   - Web viewer updates automatically
   - Or click refresh button

5. **Interact**
   - Copy text to clipboard
   - Download files/images
   - View metadata

## 📚 File Structure

```
easycopy/
├── server/          # FastAPI backend with integrated webapp
│   ├── main.py
│   ├── webapp/      # React web viewer source
│   │   ├── src/
│   │   │   ├── App.jsx      # Main component
│   │   │   ├── App.css      # Styles
│   │   │   ├── main.jsx     # Entry point
│   │   │   └── index.css    # Global styles
│   │   ├── package.json
│   │   └── vite.config.js
│   ├── static/      # Built webapp (generated)
│   └── build_webapp.sh
├── client/          # Upload/download scripts
├── SETUP.md        # Detailed setup guide
└── README.md       # Main documentation
```

## 💡 Tips

1. **Use auto-refresh** for continuous monitoring
2. **Check "Last updated"** to see refresh status
3. **Use browser DevTools** to debug connection issues
5. **Keep server logs visible** during development
6. **Bookmark** http://localhost:8000 for quick access

## 🚨 Need Help?

1. Check server logs
2. Check browser console (F12)
3. Review SETUP.md for troubleshooting
4. Test API directly: `curl http://localhost:8000/status`
