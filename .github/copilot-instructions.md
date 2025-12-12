# EasyCopy - AI Coding Agent Instructions

## Architecture Overview

EasyCopy is a client-server clipboard sync tool with three components:

- **Server** (`server/main.py`): FastAPI app with in-memory storage, single global `clipboard_data` dict
- **Upload Client** (`client/upload.py`): Detects clipboard content type and uploads to server
- **Download Client** (`client/download.py`): Fetches from server and writes to local clipboard

Data flow: Device clipboard → upload.py → FastAPI server → download.py → Device clipboard

## Key Design Patterns

### Content Type Detection Priority (upload.py)
1. Files first (platform-specific clipboard APIs)
2. Images second (via `PIL.ImageGrab.grabclipboard()`)
3. Text last (via `pyperclip.paste()`)

This ordering matters - don't reorder without reason. Files use native clipboard APIs (`AppKit.NSPasteboard` on macOS, GTK on Linux, `win32clipboard` on Windows).

### Base64 Encoding Convention
Files and images are base64-encoded for JSON transport. Always decode with `base64.b64decode()` before writing files in `download.py`.

### Metadata Structure
Each upload includes `metadata` dict with type-specific fields:
- Text: `{"length": int}`
- File: `{"filename": str, "original_path": str, "size": int, "mime_type": str}`
- Image: `{"format": str, "size": int, "dimensions": str}`

## Development Workflow

### Running Locally
```bash
# Terminal 1 - Server
cd server && pip install -r requirements.txt && python main.py

# Terminal 2 - Test uploads
cd client && pip install -r requirements.txt && python upload.py

# Terminal 3 - Test downloads
cd client && python download.py
```

### Docker Deployment
```bash
docker-compose up -d          # Start server
docker-compose logs -f        # View logs
docker-compose down           # Stop server
```

Server listens on port 8000 (configured in `docker-compose.yml` and Dockerfile).

## Platform-Specific Code

### Clipboard File Access (upload.py lines 22-66)
- **macOS**: Uses `AppKit.NSPasteboard` with `NSFilenamesPboardType`
- **Linux**: Uses GTK3 `Gtk.Clipboard` checking `wait_is_uris_available()`
- **Windows**: Uses `win32clipboard` with `CF_HDROP` format

When modifying file upload, test on each platform - these APIs behave differently.

### Image Clipboard Handling (download.py lines 21-91)
- **macOS**: Saves PNG temporarily, loads as `NSImage`, copies with `writeObjects_`
- **Linux**: Uses `GdkPixbuf` to load image and `clipboard.set_image()`
- **Windows**: Converts to BMP format (strips 14-byte header) with `CF_DIB`

Image clipboard fallback: saves to `~/Downloads/easycopy/clipboard_image.png` if native API fails.

## Configuration

### Environment Variables
- `EASYCOPY_SERVER`: Server URL (default: `http://localhost:8000`)
- `EASYCOPY_DOWNLOAD_DIR`: File download location (default: `~/Downloads/easycopy`)

Both clients read these from `os.environ.get()`. No config files.

## Server State Management

Server uses **single in-memory dict** at module level - no database, no persistence. Each upload **replaces** previous content (no history). To add persistence, replace the global `clipboard_data` dict with Redis or SQLite.

## Common Modifications

### Adding Authentication
Add API key header check in `server/main.py` endpoints. Update client requests to include header: `requests.post(..., headers={"X-API-Key": key})`.

### Supporting Multiple Files
Change `upload.py` line 140 from `upload_file(files[0])` to loop over all files. Modify server schema to accept list instead of single item.

### Adding Clipboard History
Replace single `clipboard_data` dict with list/deque in `server/main.py`. Add `/history` endpoint returning recent items.

## Dependencies

- **Server**: FastAPI 0.104+, uvicorn 0.24+ (ASGI server)
- **Client**: Pillow 10.0+ (image handling), pyperclip 1.8+ (text clipboard), requests 2.31+
- **Optional**: Platform-specific clipboard libraries (pyobjc-framework-Cocoa for macOS, python3-gi for Linux, pywin32 for Windows)

Install platform libs only if file/image clipboard features needed.

## Testing Strategy

Manual testing approach (no automated tests currently):
1. Copy text → run `upload.py` → run `download.py` on another terminal → verify clipboard
2. Copy file in Finder → upload → download → check `~/Downloads/easycopy/`
3. Screenshot → upload → download → verify image in clipboard

Test each content type separately on target platforms.
