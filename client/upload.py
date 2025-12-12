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
        # Try AppKit first
        try:
            from AppKit import NSPasteboard, NSFilenamesPboardType
            pb = NSPasteboard.generalPasteboard()
            files = pb.propertyListForType_(NSFilenamesPboardType)
            if files and len(files) > 0:
                return [str(f) for f in files]
        except (ImportError, Exception):
            pass
        
        # Fallback: use osascript
        try:
            import subprocess
            result = subprocess.run(
                ['osascript', '-e', 'the clipboard as «class furl»'],
                capture_output=True,
                text=True,
                timeout=2
            )
            if result.returncode == 0 and result.stdout.strip():
                # Parse the file path from output
                # Format: "file Macintosh HD:Users:name:path:to:file.txt"
                output = result.stdout.strip()
                if output.startswith('file '):
                    # Remove "file " prefix and convert Mac path to Unix path
                    mac_path = output[5:]  # Remove "file "
                    # Remove drive name (e.g., "Macintosh HD:")
                    if ':' in mac_path:
                        mac_path = mac_path.split(':', 1)[1]
                    # Convert colon-separated path to slash-separated
                    unix_path = '/' + mac_path.replace(':', '/')
                    return [unix_path]
        except Exception:
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
        # Priority 1: Check for files in clipboard (platform-specific)
        files = get_clipboard_files()
        if files:
            # Upload the first file (or we could upload all)
            upload_file(files[0])
            return
        
        # Priority 2: Check for image in clipboard
        try:
            clipboard_content = ImageGrab.grabclipboard()
            # On macOS, ImageGrab.grabclipboard() returns a list of file paths when files are copied
            if clipboard_content:
                if isinstance(clipboard_content, list):
                    # This is a list of file paths
                    if len(clipboard_content) > 0:
                        upload_file(clipboard_content[0])
                        return
                elif isinstance(clipboard_content, Image.Image):
                    # This is an actual image
                    upload_image(clipboard_content)
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
