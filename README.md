# EasyCopy

Cross-platform clipboard synchronization tool. Copy on one device, paste on another.

## Features

- 📋 **Text**: Copy text on one machine, paste on another
- 📁 **Files**: Copy files with full content transfer across devices
- 🖼️ **Images**: Copy images/screenshots between devices
- 🌐 **Web Viewer**: Monitor clipboard content in real-time via browser
- 🚀 **Simple**: Just run scripts bound to keyboard shortcuts
- 🔒 **Self-hosted**: Run your own server in Docker
- 🌍 **Cross-platform**: Works on macOS, Linux, Windows, and Android (Termux)

## Architecture

```
Device A                     Docker Server              Device B
┌──────────┐                ┌──────────┐               ┌──────────┐
│          │   upload.py    │          │  download.py  │          │
│ Clipboard├───────────────►│  FastAPI ◄───────────────┤ Clipboard│
│          │                │  Server  │               │          │
└──────────┘                └──────────┘               └──────────┘
```

## Quick Start

### 1. Start the Server

```bash
# Using docker-compose (recommended)
docker-compose up -d

# Or build and run manually
cd server
docker build -t easycopy-server .
docker run -d -p 8000:8000 easycopy-server
```

The server will be available at `http://localhost:8000`

### 2. Setup Client

#### Install dependencies:

```bash
cd client
pip install -r requirements.txt
```

#### macOS additional setup:
```bash
pip install pyobjc-framework-Cocoa
```

#### Linux additional setup (for GTK support):
```bash
# Ubuntu/Debian
sudo apt-get install python3-gi python3-gi-cairo gir1.2-gtk-3.0

# Fedora
sudo dnf install python3-gobject gtk3
```

#### Windows additional setup:
```bash
pip install pywin32
```

### 3. Configure Server URL

Set the environment variable to point to your server:

```bash
export EASYCOPY_SERVER="http://your-server-ip:8000"
```

Make it permanent by adding to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.)

### 4. Test the Scripts

**Upload clipboard content:**
```bash
cd client
python upload.py
```

**Download to clipboard:**
```bash
python download.py
```

### 5. Setup Keyboard Shortcuts

#### macOS

1. Open **System Settings** → **Keyboard** → **Keyboard Shortcuts** → **App Shortcuts**
2. Click **+** to add new shortcuts
3. Choose **All Applications**
4. Add two shortcuts:
   - **Upload**: Menu Title: any name, Keyboard Shortcut: `⌘⇧C`
     - Command: `/usr/bin/python3 /path/to/easycopy/client/upload.py`
   - **Download**: Menu Title: any name, Keyboard Shortcut: `⌘⇧V`
     - Command: `/usr/bin/python3 /path/to/easycopy/client/download.py`

**Alternative (Automator + System Shortcuts):**
1. Open **Automator** → New **Quick Action**
2. Add **Run Shell Script** action
3. Paste: `/usr/bin/python3 /path/to/easycopy/client/upload.py`
4. Save as "EasyCopy Upload"
5. Go to **System Settings** → **Keyboard** → **Shortcuts** → **Services**
6. Find "EasyCopy Upload" and assign `⌘⇧C`
7. Repeat for download script

#### Linux (GNOME)

```bash
# Install dependencies
sudo apt-get install xdotool  # for keyboard simulation if needed

# Add keyboard shortcuts in Settings → Keyboard → Custom Shortcuts
# Name: EasyCopy Upload
# Command: /usr/bin/python3 /path/to/easycopy/client/upload.py
# Shortcut: Ctrl+Shift+C

# Name: EasyCopy Download  
# Command: /usr/bin/python3 /path/to/easycopy/client/download.py
# Shortcut: Ctrl+Shift+V
```

#### Linux (KDE)

1. **System Settings** → **Shortcuts** → **Custom Shortcuts**
2. Edit → New → Global Shortcut → Command/URL
3. Set trigger and action for both scripts

#### Windows

**Option 1: Using Task Scheduler + Hotkeys**
1. Create batch files `upload.bat` and `download.bat`:
```batch
@echo off
python C:\path\to\easycopy\client\upload.py
```

2. Use AutoHotkey or similar to bind keyboard shortcuts

**Option 2: Using AutoHotkey**
```ahk
^+c::  ; Ctrl+Shift+C
Run, python C:\path\to\easycopy\client\upload.py
return

^+v::  ; Ctrl+Shift+V
Run, python C:\path\to\easycopy\client\download.py
return
```

#### Android (Termux)

1. Install Termux from F-Droid
2. Install dependencies:
```bash
pkg install python
pip install requests pillow
```

3. Create Termux widgets:
   - Create `~/.shortcuts/` directory
   - Add scripts as executable files
   - Add widget to home screen

## Configuration

### Environment Variables

- `EASYCOPY_SERVER`: Server URL (default: `http://localhost:8000`)
- `EASYCOPY_DOWNLOAD_DIR`: Where to save downloaded files (default: `~/Downloads/easycopy`)

### Server Configuration

Edit `server/main.py` to customize:
- Port (default: 8000)
- Storage backend (currently in-memory, could add Redis/file storage)
- Size limits

## Usage

1. **Copy text**: Select text → press upload shortcut → text is stored on server
2. **Paste text**: Press download shortcut on another device → text appears in clipboard
3. **Copy file**: Select file in Finder/Explorer → press upload shortcut → file uploaded
4. **Get file**: Press download shortcut → file saved to downloads folder, path in clipboard
5. **Copy image**: Take screenshot or copy image → press upload shortcut
6. **Paste image**: Press download shortcut → image in clipboard (or saved to file)

## API Endpoints

- `GET /` - Health check
- `POST /upload` - Upload clipboard content
- `GET /download` - Download clipboard content
- `GET /status` - Get info about stored content
- `DELETE /clear` - Clear stored content

## Troubleshooting

### Client can't connect to server
- Check server is running: `curl http://your-server:8000/`
- Verify `EASYCOPY_SERVER` environment variable is set
- Check firewall rules

### Images not working
- macOS: Install `pip install pyobjc-framework-Cocoa`
- Linux: Install GTK3 bindings
- Windows: Install `pip install pywin32`

### File upload not detecting files
- This feature requires platform-specific clipboard APIs
- Text/image clipboard content works on all platforms
- File detection works best on macOS and Windows

## Security Notes

⚠️ **This is a simple implementation without authentication**

For production use, consider:
- Add API key authentication
- Use HTTPS/TLS encryption
- Implement rate limiting
- Add content size limits
- Set up VPN or SSH tunnel for remote access

## License

MIT License - feel free to modify and use as needed.

## Development

### Project Structure

```
easycopy/
├── client/
│   ├── upload.py          # Upload script
│   ├── download.py        # Download script
│   └── requirements.txt   # Python dependencies
├── server/
│   ├── main.py           # FastAPI server
│   ├── requirements.txt  # Server dependencies
│   └── Dockerfile        # Docker container config
├── docker-compose.yml    # Docker Compose config
└── README.md            # This file
```

### Running in Development

**Server:**
```bash
cd server
pip install -r requirements.txt
python main.py
```

**Client:**
```bash
cd client
pip install -r requirements.txt
python upload.py   # Test upload
python download.py # Test download
```

## Web Viewer

A React-based web application for monitoring clipboard content in real-time.

### Setup

```bash
cd webapp
npm install
npm run dev
```

The viewer will be available at `http://localhost:3000`

### Features

- 📊 Real-time monitoring with auto-refresh (5s)
- 📝 Text display with truncation and copy button
- 🖼️ Image preview and download
- 📁 File information and download
- 🔄 Manual refresh button
- ⏱️ Last updated timestamp

See [webapp/README.md](webapp/README.md) for detailed documentation.

## Future Enhancements

- [ ] Clipboard history (multiple items)
- [ ] End-to-end encryption
- [ ] Authentication/multi-user support
- [x] Web UI for clipboard management
- [ ] Persistent storage (Redis/Database)
- [ ] Content expiration
- [ ] File size limits
- [ ] Direct device-to-device sync (no server)
- [ ] Browser extension
- [ ] Mobile apps (native iOS/Android)

## Contributing

Contributions welcome! Feel free to open issues or submit pull requests.
