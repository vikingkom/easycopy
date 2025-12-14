# EasyCopy Server Quick Reference

## Installation

**Development (HTTP):**
```bash
curl -sSL https://raw.githubusercontent.com/vikingkom/easycopy/master/server/install.sh | bash
```

**Production (HTTPS):**
```bash
curl -sSL https://raw.githubusercontent.com/vikingkom/easycopy/master/server/install-production.sh | bash
```

Default installation directory: `~/.easycopy`

## Configuration

Edit `~/.easycopy/easycopy.env` (or `easycopy.env` in your installation directory):

```bash
# Server port
EASYCOPY_PORT=8000

# Domain (optional, for remote access)
EASYCOPY_DOMAIN=your-server.com

# Download directory for files
EASYCOPY_DOWNLOAD_DIR=~/Downloads/easycopy

# Timezone
TZ=UTC
```

After changing configuration:
```bash
cd ~/.easycopy
docker compose restart
```

## Server Management

All commands should be run from your installation directory (default: `~/.easycopy`)

### Start server
```bash
docker compose start
```

### Stop server
```bash
docker compose stop
```

### Restart server
```bash
docker compose restart
```

### View logs
```bash
docker compose logs -f
```

### Update server
```bash
docker compose pull
docker compose up -d
```

### Check status
```bash
docker compose ps
```

### Remove server completely
```bash
docker compose down
```

## Accessing the Server

- **API**: `http://localhost:8000` (or your configured port/domain)
- **Web Viewer**: `http://localhost:8000` (same URL, opens in browser)

## Client Configuration

Set the server URL in your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
export EASYCOPY_SERVER="http://localhost:8000"
```

For remote server:
```bash
export EASYCOPY_SERVER="http://your-server.com:8000"
```

## Troubleshooting

### Port already in use
```bash
# Change port in easycopy.env
EASYCOPY_PORT=8001

# Restart
docker compose restart
```

### Cannot connect to server
```bash
# Check if server is running
docker compose ps

# View logs for errors
docker compose logs

# Verify port is accessible
curl http://localhost:8000/health
```

### Reset everything
```bash
cd ~/.easycopy
docker compose down
docker compose up -d
```

## Uninstallation

```bash
cd ~/.easycopy
docker compose down
rm -rf ~/.easycopy
```

Remove client configuration from shell profile.
