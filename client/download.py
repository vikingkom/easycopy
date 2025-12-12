#!/usr/bin/env python3
"""
EasyCopy Download Client
Downloads clipboard content from the EasyCopy server and puts it in the local clipboard
Supports: text, files, and images
"""

import sys
import os
import base64
import json
from pathlib import Path
import requests
import pyperclip
from PIL import Image
from io import BytesIO

# Server configuration
SERVER_URL = os.environ.get("EASYCOPY_SERVER", "http://localhost:8000")

# Default download directory for files
DOWNLOAD_DIR = Path(os.environ.get("EASYCOPY_DOWNLOAD_DIR", 
                                   Path.home() / "Downloads" / "easycopy"))


def set_clipboard_image(image):
    """Set image to clipboard (platform-specific)"""
    if sys.platform == "darwin":
        # macOS
        try:
            from AppKit import NSPasteboard, NSImage, NSPasteboardTypePNG
            import tempfile
            
            # Save image to temporary file
            with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp:
                image.save(tmp.name, 'PNG')
                tmp_path = tmp.name
            
            # Load into NSImage and copy to clipboard
            ns_image = NSImage.alloc().initWithContentsOfFile_(tmp_path)
            pb = NSPasteboard.generalPasteboard()
            pb.clearContents()
            pb.writeObjects_([ns_image])
            
            # Clean up temp file
            os.unlink(tmp_path)
            return True
        except ImportError:
            pass
    
    elif sys.platform.startswith("linux"):
        # Linux with GTK
        try:
            import gi
            gi.require_version('Gtk', '3.0')
            from gi.repository import Gtk, Gdk, GdkPixbuf
            import tempfile
            
            # Save to temp file
            with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as tmp:
                image.save(tmp.name, 'PNG')
                tmp_path = tmp.name
            
            # Load and set to clipboard
            pixbuf = GdkPixbuf.Pixbuf.new_from_file(tmp_path)
            clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
            clipboard.set_image(pixbuf)
            clipboard.store()
            
            os.unlink(tmp_path)
            return True
        except (ImportError, Exception):
            pass
    
    elif sys.platform == "win32":
        # Windows
        try:
            import win32clipboard
            from io import BytesIO
            
            output = BytesIO()
            image.convert('RGB').save(output, 'BMP')
            data = output.getvalue()[14:]  # Remove BMP header
            output.close()
            
            win32clipboard.OpenClipboard()
            win32clipboard.EmptyClipboard()
            win32clipboard.SetClipboardData(win32clipboard.CF_DIB, data)
            win32clipboard.CloseClipboard()
            return True
        except ImportError:
            pass
    
    return False


def download_text(content, metadata):
    """Download text and put in clipboard"""
    pyperclip.copy(content)
    print(f"✓ Downloaded text to clipboard ({metadata.get('length', len(content))} characters)")


def download_file(content_base64, metadata):
    """Download file and save to disk, copy path to clipboard"""
    # Decode base64 content
    file_content = base64.b64decode(content_base64)
    
    # Ensure download directory exists
    DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
    
    # Use original filename
    filename = metadata.get('filename', 'downloaded_file')
    file_path = DOWNLOAD_DIR / filename
    
    # Handle duplicate filenames
    counter = 1
    original_stem = file_path.stem
    while file_path.exists():
        file_path = DOWNLOAD_DIR / f"{original_stem}_{counter}{file_path.suffix}"
        counter += 1
    
    # Write file
    with open(file_path, 'wb') as f:
        f.write(file_content)
    
    # Copy file path to clipboard
    pyperclip.copy(str(file_path))
    
    print(f"✓ Downloaded file: {file_path}")
    print(f"  Original: {metadata.get('original_path', 'unknown')}")
    print(f"  Size: {len(file_content)} bytes")
    print(f"  Path copied to clipboard")


def download_image(content_base64, metadata):
    """Download image and put in clipboard"""
    # Decode base64 content
    image_bytes = base64.b64decode(content_base64)
    image = Image.open(BytesIO(image_bytes))
    
    # Try to set image to clipboard
    if set_clipboard_image(image):
        print(f"✓ Downloaded image to clipboard ({metadata.get('dimensions', 'unknown')})")
    else:
        # Fallback: save to file and copy path
        DOWNLOAD_DIR.mkdir(parents=True, exist_ok=True)
        file_path = DOWNLOAD_DIR / "clipboard_image.png"
        
        counter = 1
        while file_path.exists():
            file_path = DOWNLOAD_DIR / f"clipboard_image_{counter}.png"
            counter += 1
        
        image.save(file_path)
        pyperclip.copy(str(file_path))
        
        print(f"✓ Downloaded image to: {file_path}")
        print(f"  (Could not set to clipboard directly, path copied instead)")


def main():
    """Main download logic"""
    try:
        # Download from server
        response = requests.get(f"{SERVER_URL}/download")
        response.raise_for_status()
        
        data = response.json()
        content_type = data.get("type")
        content = data.get("content")
        metadata = data.get("metadata", {})
        
        if not content_type or not content:
            print("✗ No valid content received from server")
            sys.exit(1)
        
        # Process based on type
        if content_type == "text":
            download_text(content, metadata)
        elif content_type == "file":
            download_file(content, metadata)
        elif content_type == "image":
            download_image(content, metadata)
        else:
            print(f"✗ Unknown content type: {content_type}")
            sys.exit(1)
            
    except requests.exceptions.ConnectionError:
        print(f"✗ Error: Cannot connect to server at {SERVER_URL}")
        sys.exit(1)
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 404:
            print("✗ No clipboard data available on server")
        else:
            print(f"✗ Error downloading from server: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
