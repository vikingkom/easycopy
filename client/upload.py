#!/usr/bin/env python3
"""
EasyCopy Upload Client
Reads clipboard content and uploads it to the EasyCopy server
Supports: text, files, and images
"""

import sys
import os
import base64
import json
import mimetypes
from pathlib import Path
import requests
import pyperclip
from PIL import ImageGrab, Image
from io import BytesIO

# Server configuration
SERVER_URL = os.environ.get("EASYCOPY_SERVER", "http://localhost:8000")


def get_clipboard_files():
    """
    Try to get file paths from clipboard
    Platform-specific implementation
    """
    # On macOS, we can check if files are in clipboard
    if sys.platform == "darwin":
        try:
            from AppKit import NSPasteboard, NSFilenamesPboardType
            pb = NSPasteboard.generalPasteboard()
            files = pb.propertyListForType_(NSFilenamesPboardType)
            if files:
                return [str(f) for f in files]
        except ImportError:
            pass
    
    # On Linux with GTK
    elif sys.platform.startswith("linux"):
        try:
            import gi
            gi.require_version('Gtk', '3.0')
            from gi.repository import Gtk, Gdk
            
            clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
            
            # Check for file URIs
            if clipboard.wait_is_uris_available():
                uris = clipboard.wait_for_uris()
                if uris:
                    # Convert URIs to file paths
                    return [uri.replace('file://', '') for uri in uris]
        except (ImportError, Exception):
            pass
    
    # On Windows
    elif sys.platform == "win32":
        try:
            import win32clipboard
            win32clipboard.OpenClipboard()
            try:
                # CF_HDROP format contains file paths
                files = win32clipboard.GetClipboardData(win32clipboard.CF_HDROP)
                win32clipboard.CloseClipboard()
                if files:
                    return files
            except:
                win32clipboard.CloseClipboard()
        except ImportError:
            pass
    
    return None


def upload_text(text):
    """Upload text content to server"""
    payload = {
        "type": "text",
        "content": text,
        "metadata": {
            "length": len(text)
        }
    }
    
    response = requests.post(f"{SERVER_URL}/upload", json=payload)
    response.raise_for_status()
    print(f"✓ Uploaded text ({len(text)} characters)")
    return response.json()


def upload_file(file_path):
    """Upload file content to server"""
    path = Path(file_path)
    
    if not path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")
    
    if not path.is_file():
        raise ValueError(f"Not a file: {file_path}")
    
    # Read file and encode to base64
    with open(path, "rb") as f:
        file_content = f.read()
    
    content_base64 = base64.b64encode(file_content).decode('utf-8')
    
    # Detect mime type
    mime_type, _ = mimetypes.guess_type(str(path))
    
    payload = {
        "type": "file",
        "content": content_base64,
        "metadata": {
            "filename": path.name,
            "original_path": str(path.absolute()),
            "size": len(file_content),
            "mime_type": mime_type or "application/octet-stream"
        }
    }
    
    response = requests.post(f"{SERVER_URL}/upload", json=payload)
    response.raise_for_status()
    print(f"✓ Uploaded file: {path.name} ({len(file_content)} bytes)")
    return response.json()


def upload_image(image):
    """Upload image from clipboard to server"""
    # Convert image to PNG and encode to base64
    buffer = BytesIO()
    image.save(buffer, format="PNG")
    image_bytes = buffer.getvalue()
    content_base64 = base64.b64encode(image_bytes).decode('utf-8')
    
    payload = {
        "type": "image",
        "content": content_base64,
        "metadata": {
            "format": "PNG",
            "size": len(image_bytes),
            "dimensions": f"{image.width}x{image.height}"
        }
    }
    
    response = requests.post(f"{SERVER_URL}/upload", json=payload)
    response.raise_for_status()
    print(f"✓ Uploaded image ({image.width}x{image.height}, {len(image_bytes)} bytes)")
    return response.json()


def main():
    """Main upload logic - detect clipboard type and upload"""
    try:
        # Priority 1: Check for files in clipboard
        files = get_clipboard_files()
        if files:
            # Upload the first file (or we could upload all)
            upload_file(files[0])
            return
        
        # Priority 2: Check for image in clipboard
        try:
            image = ImageGrab.grabclipboard()
            if image and isinstance(image, Image.Image):
                upload_image(image)
                return
        except Exception as e:
            # Not an image or error reading image
            pass
        
        # Priority 3: Check for text in clipboard
        text = pyperclip.paste()
        if text:
            upload_text(text)
            return
        
        # Nothing in clipboard
        print("✗ No content found in clipboard")
        sys.exit(1)
        
    except requests.exceptions.ConnectionError:
        print(f"✗ Error: Cannot connect to server at {SERVER_URL}")
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"✗ Error uploading to server: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"✗ Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
