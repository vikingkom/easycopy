import { useState, useEffect } from 'react'
import './App.css'

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000'
const AUTO_REFRESH_INTERVAL = 5000 // 5 seconds

function App() {
  const [clipboardData, setClipboardData] = useState(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [autoRefresh, setAutoRefresh] = useState(true)
  const [textExpanded, setTextExpanded] = useState(false)
  const [lastUpdated, setLastUpdated] = useState(null)

  const fetchClipboardStatus = async () => {
    try {
      setLoading(true)
      setError(null)
      
      const response = await fetch(`${API_URL}/status`)
      
      if (!response.ok) {
        throw new Error('Failed to fetch clipboard status')
      }
      
      const data = await response.json()
      
      if (data.has_data) {
        setClipboardData(data)
        setLastUpdated(new Date())
      } else {
        setClipboardData(null)
      }
    } catch (err) {
      setError(err.message)
      console.error('Error fetching clipboard:', err)
    } finally {
      setLoading(false)
    }
  }

  const copyToClipboard = async (text) => {
    try {
      await navigator.clipboard.writeText(text)
      alert('Copied to clipboard!')
    } catch (err) {
      alert('Failed to copy to clipboard')
      console.error('Copy error:', err)
    }
  }

  const downloadFile = async () => {
    try {
      const response = await fetch(`${API_URL}/download/file`)
      if (!response.ok) throw new Error('Download failed')
      
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = clipboardData.metadata.filename || 'download'
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (err) {
      alert('Failed to download file')
      console.error('Download error:', err)
    }
  }

  const downloadImage = async () => {
    try {
      const response = await fetch(`${API_URL}/download/image`)
      if (!response.ok) throw new Error('Download failed')
      
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `clipboard_image.${clipboardData.metadata.format?.toLowerCase() || 'png'}`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (err) {
      alert('Failed to download image')
      console.error('Download error:', err)
    }
  }

  const formatTimestamp = (timestamp) => {
    if (!timestamp) return 'Unknown'
    const date = new Date(timestamp)
    return date.toLocaleString()
  }

  const formatFileSize = (bytes) => {
    if (!bytes) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return `${(bytes / Math.pow(k, i)).toFixed(2)} ${sizes[i]}`
  }

  const getTruncatedText = (text, maxLength = 300) => {
    if (!text) return ''
    if (text.length <= maxLength) return text
    if (textExpanded) return text
    return text.substring(0, maxLength) + '...'
  }

  useEffect(() => {
    fetchClipboardStatus()
  }, [])

  useEffect(() => {
    if (!autoRefresh) return

    const interval = setInterval(() => {
      fetchClipboardStatus()
    }, AUTO_REFRESH_INTERVAL)

    return () => clearInterval(interval)
  }, [autoRefresh])

  const renderContent = () => {
    if (!clipboardData) {
      return (
        <div className="empty-state">
          <p>No clipboard data available</p>
          <p className="empty-hint">Upload something using the EasyCopy client</p>
        </div>
      )
    }

    switch (clipboardData.type) {
      case 'text':
        const textContent = clipboardData.content || ''
        const needsTruncation = textContent.length > 300
        
        return (
          <div className="content-container">
            <div className="content-header">
              <h3>Text Content</h3>
              <div className="metadata">
                <span>Length: {clipboardData.metadata.length || textContent.length} characters</span>
              </div>
            </div>
            <div className="text-content">
              <pre>{getTruncatedText(textContent)}</pre>
            </div>
            <div className="action-buttons">
              {needsTruncation && (
                <button 
                  onClick={() => setTextExpanded(!textExpanded)}
                  className="btn btn-secondary"
                >
                  {textExpanded ? 'Show Less' : 'Show More'}
                </button>
              )}
              <button 
                onClick={() => copyToClipboard(textContent)}
                className="btn btn-primary"
              >
                Copy to Clipboard
              </button>
            </div>
          </div>
        )

      case 'image':
        const imageUrl = `${API_URL}/download/image`
        
        return (
          <div className="content-container">
            <div className="content-header">
              <h3>Image Content</h3>
              <div className="metadata">
                <span>Format: {clipboardData.metadata.format || 'Unknown'}</span>
                <span>Size: {formatFileSize(clipboardData.metadata.size)}</span>
                {clipboardData.metadata.dimensions && (
                  <span>Dimensions: {clipboardData.metadata.dimensions}</span>
                )}
              </div>
            </div>
            <div className="image-content">
              <img src={imageUrl} alt="Clipboard content" />
            </div>
            <div className="action-buttons">
              <button 
                onClick={() => copyToClipboard(imageUrl)}
                className="btn btn-secondary"
              >
                Copy Image URL
              </button>
              <button 
                onClick={downloadImage}
                className="btn btn-primary"
              >
                Download Image
              </button>
            </div>
          </div>
        )

      case 'file':
        return (
          <div className="content-container">
            <div className="content-header">
              <h3>File Content</h3>
              <div className="metadata">
                <span>Filename: {clipboardData.metadata.filename || 'Unknown'}</span>
                <span>Size: {formatFileSize(clipboardData.metadata.size)}</span>
                <span>Type: {clipboardData.metadata.mime_type || 'Unknown'}</span>
              </div>
            </div>
            <div className="file-content">
              <div className="file-icon">📄</div>
              <p className="file-name">{clipboardData.metadata.filename}</p>
            </div>
            <div className="action-buttons">
              <button 
                onClick={downloadFile}
                className="btn btn-primary"
              >
                Download File
              </button>
            </div>
          </div>
        )

      default:
        return <div className="empty-state">Unknown content type</div>
    }
  }

  return (
    <div className="app">
      <header className="header">
        <h1>EasyCopy Viewer</h1>
        <p className="subtitle">Monitor your clipboard sync in real-time</p>
      </header>

      <div className="controls">
        <button 
          onClick={fetchClipboardStatus} 
          disabled={loading}
          className="btn btn-refresh"
        >
          {loading ? 'Refreshing...' : '🔄 Refresh'}
        </button>
        
        <label className="auto-refresh-toggle">
          <input 
            type="checkbox" 
            checked={autoRefresh}
            onChange={(e) => setAutoRefresh(e.target.checked)}
          />
          <span>Auto-refresh (5s)</span>
        </label>
        
        {lastUpdated && (
          <span className="last-updated">
            Last updated: {lastUpdated.toLocaleTimeString()}
          </span>
        )}
      </div>

      {error && (
        <div className="error-banner">
          ⚠️ Error: {error}
        </div>
      )}

      <div className="clipboard-info">
        {clipboardData && (
          <div className="info-bar">
            <span className="status-badge">Active</span>
            <span>Type: {clipboardData.type}</span>
            <span>Uploaded: {formatTimestamp(clipboardData.timestamp)}</span>
          </div>
        )}
      </div>

      <main className="main-content">
        {renderContent()}
      </main>

      <footer className="footer">
        <p>EasyCopy Server: {API_URL}</p>
      </footer>
    </div>
  )
}

export default App
