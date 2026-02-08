import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';

function ShareTarget() {
  const navigate = useNavigate();

  useEffect(() => {
    const handleSharedContent = async () => {
      try {
        // Get URL parameters
        const params = new URLSearchParams(window.location.search);
        const title = params.get('title');
        const text = params.get('text');
        const url = params.get('url');

        // If text or URL is shared, upload it
        if (text || url) {
          const content = [text, url].filter(Boolean).join('\n');
          const payload = {
            type: 'text',
            content: content,
            metadata: { 
              length: content.length,
              shared_from: 'web_share_api',
              title: title || 'Shared content'
            }
          };

          const response = await fetch('/upload', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
          });

          if (response.ok) {
            alert('Content shared successfully!');
          } else {
            throw new Error('Failed to share content');
          }
        }

        // Navigate back to home
        navigate('/');
      } catch (error) {
        console.error('Error handling shared content:', error);
        alert('Failed to share content: ' + error.message);
        navigate('/');
      }
    };

    handleSharedContent();
  }, [navigate]);

  return (
    <div className="share-target-loading">
      <h2>Processing shared content...</h2>
      <p>Please wait while we process your shared content.</p>
    </div>
  );
}

export default ShareTarget;
