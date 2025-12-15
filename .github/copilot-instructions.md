# EasyCopy - AI Agent Instructions

## Architecture Overview

EasyCopy is a cross-platform clipboard sync tool with **three tightly-coupled components**:

- **Server** (`server/main.py`): FastAPI app serving both API and integrated React webapp from single port 8000
- **Upload Client** (`client/upload.py`): Detects clipboard type (files→images→text priority) and POSTs to `/upload`
- **Download Client** (`client/download.py`): GETs from `/download` and writes to OS clipboard via platform APIs

**Critical:** Server stores **only one clipboard item** in global `clipboard_data` dict (line 28-33 in main.py) - no history, no persistence, no database. Each upload replaces previous content.

```
Device A clipboard → upload.py → FastAPI (port 8000) → download.py → Device B clipboard
                                       ↓
                                 React webapp (same port)
```

## Key Design Decisions

### Content Type Detection Order (upload.py lines 22-140)
**Must check in this exact order:**
1. **Files first** - Platform-specific APIs (NSPasteboard on macOS, GTK on Linux, win32clipboard on Windows)
2. **Images second** - `PIL.ImageGrab.grabclipboard()`
3. **Text last** - `pyperclip.paste()`

**Why:** macOS reports files as images in Pillow, so file check must happen first. Don't reorder without testing on all platforms.

### Base64 Transport Convention
All non-text content (files, images) is base64-encoded for JSON transport (line 163 in upload.py, line 159 in download.py). Always use `base64.b64decode()` before writing - never try to write base64 string directly to files.

### Integrated Webapp Architecture
The webapp is **not a separate service** - it's built into `server/static/` and served by FastAPI's `StaticFiles` mount (line 174-175 in main.py). No separate web server, no port 3000 - everything on 8000.

## Development Workflow

### Quick Start
```bash
cd server && ./build_webapp.sh && python main.py  # Builds webapp if needed, starts server on 8000
```

### Manual Development
```bash
# Server (builds webapp first time only)
cd server && ./build_webapp.sh && python main.py

# Clients (in separate terminals)
cd client
python upload.py    # Copy something first
python download.py  # Pastes to clipboard

# Webapp dev mode (optional, hot reload)
cd server/webapp && npm run dev  # Port 8000 with API proxy
```

### Docker Build
Multi-stage `server/Dockerfile`:
1. Node stage builds React app from `server/webapp/`
2. Python stage copies built webapp to `static/`, installs FastAPI

**Important:** Build context is repo root (`..` from server dir) - see `server/docker-compose.build.yml` context setting.

## Platform-Specific Gotchas

### macOS File Detection (upload.py lines 29-68)
Uses `AppKit.NSPasteboard` with `NSFilenamesPboardType`. Falls back to osascript but **must validate** output format (`file Macintosh HD:...`) and verify path exists before returning - osascript fails gracefully but returns junk for non-file clipboard.

### Image Clipboard on Windows (download.py lines 70-91)
Windows needs **CF_DIB format** (device-independent bitmap), not raw PNG. Must strip 14-byte BMP header before calling `SetClipboardData()`.

### Linux GTK Dependencies
Both clients need GTK3 bindings (`python3-gi`) installed via apt/dnf - pip can't install these. Document in setup instructions.

## Configuration

**Configuration** (`server/easycopy.env` for server, environment variables for clients):
- `EASYCOPY_SERVER`: Client target URL (default: `http://localhost:8000`)
- `EASYCOPY_DOWNLOAD_DIR`: File save location (default: `~/Downloads/easycopy`)
- `HTTP_PORT`: Server port (default: 8000)
- `HTTPS_PORT`: Server port (default: 443)
- `EASYCOPY_DOMAIN`: Server domain (optional)
- `SSL_DOMAIN`: Production SSL cert domain (server/docker-compose.production.yml only)

Read with `os.environ.get()` in clients (line 19 in upload.py, line 19 in download.py).

## API Endpoints

| Method | Path | Purpose | Returns 404? |
|--------|------|---------|--------------|
| POST | `/upload` | Replace clipboard | No |
| GET | `/download` | Get full content | Yes if empty |
| GET | `/status` | Get metadata only | No (returns `has_data: false`) |
| DELETE | `/clear` | Empty clipboard | No |
| GET | `/download/file` | Browser file download | Yes if not file |
| GET | `/download/image` | Browser image display | Yes if not image |

**State structure** (line 28-33 in main.py):
```python
clipboard_data = {
    "type": "text"|"file"|"image"|None,
    "content": str,  # Plain text or base64
    "metadata": {"filename": str, "length": int, ...},
    "timestamp": str  # ISO 8601
}
```

## Common Modifications

**Add clipboard history:** Replace `clipboard_data` dict with `collections.deque(maxlen=10)` in main.py. Change `/upload` to append, `/download` to return list. Update webapp to show history list.

**Add authentication:** Insert API key check decorator on endpoints (line 53). Pass key in client requests: `requests.post(..., headers={"X-API-Key": os.environ["EASYCOPY_KEY"]})`. Update webapp fetch calls.

**Support multiple files:** Change upload.py line 140 from `upload_file(files[0])` to loop. Modify `ClipboardUpload` schema to accept `content: list[str]`. Handle list in download.py.

## Testing

**No automated tests.** Manual verification on each platform:
1. Text: Copy → upload.py → download.py on different machine → verify paste
2. Files: Copy file in Finder/Explorer → upload → download → check `~/Downloads/easycopy/`
3. Images: Screenshot → upload → download → verify clipboard (or fallback file saved)

**Platform testing is critical** - clipboard APIs differ significantly. Test file detection on macOS vs Linux vs Windows separately.
