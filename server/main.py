#!/usr/bin/env python3
"""
EasyCopy Server - Simple clipboard sync server
Stores the latest clipboard content (text, file, or image) with metadata
"""

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, Literal
import base64
from datetime import datetime

app = FastAPI(title="EasyCopy Server")

# In-memory storage for the latest clipboard content
clipboard_data = {
    "type": None,  # "text", "file", or "image"
    "content": None,  # The actual content (text or base64 encoded)
    "metadata": {},  # Additional metadata (filename, path, mime_type, etc.)
    "timestamp": None,
}


class ClipboardUpload(BaseModel):
    type: Literal["text", "file", "image"]
    content: str  # For text: plain text; For file/image: base64 encoded
    metadata: Optional[dict] = {}


class ClipboardResponse(BaseModel):
    type: Optional[str]
    content: Optional[str]
    metadata: dict
    timestamp: Optional[str]


@app.get("/")
async def root():
    """Health check endpoint"""
    return {"status": "ok", "service": "easycopy-server"}


@app.post("/upload")
async def upload_clipboard(data: ClipboardUpload):
    """
    Upload clipboard content to server
    Replaces the current stored content
    """
    global clipboard_data
    
    clipboard_data = {
        "type": data.type,
        "content": data.content,
        "metadata": data.metadata or {},
        "timestamp": datetime.utcnow().isoformat(),
    }
    
    print(f"[{clipboard_data['timestamp']}] Uploaded {data.type} " +
          f"({len(data.content)} bytes)" +
          (f" - {data.metadata.get('filename', '')}" if data.type == 'file' else ""))
    
    return {
        "status": "success",
        "type": data.type,
        "size": len(data.content),
        "timestamp": clipboard_data['timestamp']
    }


@app.get("/download")
async def download_clipboard() -> ClipboardResponse:
    """
    Download the latest clipboard content from server
    Returns 404 if no content is available
    """
    if clipboard_data["type"] is None:
        raise HTTPException(status_code=404, detail="No clipboard data available")
    
    print(f"[{datetime.utcnow().isoformat()}] Downloaded {clipboard_data['type']}")
    
    return ClipboardResponse(
        type=clipboard_data["type"],
        content=clipboard_data["content"],
        metadata=clipboard_data["metadata"],
        timestamp=clipboard_data["timestamp"]
    )


@app.get("/status")
async def get_status():
    """Get information about the currently stored clipboard data"""
    if clipboard_data["type"] is None:
        return {"has_data": False}
    
    return {
        "has_data": True,
        "type": clipboard_data["type"],
        "size": len(clipboard_data["content"]) if clipboard_data["content"] else 0,
        "metadata": clipboard_data["metadata"],
        "timestamp": clipboard_data["timestamp"]
    }


@app.delete("/clear")
async def clear_clipboard():
    """Clear the stored clipboard data"""
    global clipboard_data
    
    clipboard_data = {
        "type": None,
        "content": None,
        "metadata": {},
        "timestamp": None,
    }
    
    print(f"[{datetime.utcnow().isoformat()}] Clipboard cleared")
    return {"status": "success", "message": "Clipboard data cleared"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
