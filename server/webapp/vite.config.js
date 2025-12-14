import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 8000,
    proxy: {
      '/upload': 'http://localhost:8000',
      '/download': 'http://localhost:8000',
      '/status': 'http://localhost:8000',
      '/clear': 'http://localhost:8000',
      '/health': 'http://localhost:8000'
    }
  }
})
