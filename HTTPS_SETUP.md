# Let's Encrypt Setup for Production

This guide explains how to set up Let's Encrypt SSL certificates for production deployment.

## Prerequisites

- A domain name pointing to your server's IP address
- Docker and docker-compose installed
- Ports 80 and 443 accessible from the internet

## Option 1: Manual Let's Encrypt Setup

### 1. Install Certbot

```bash
# On Ubuntu/Debian
sudo apt-get update
sudo apt-get install certbot

# On macOS
brew install certbot
```

### 2. Generate Certificates

```bash
# Stop docker-compose if running
docker-compose down

# Generate certificate (replace yourdomain.com)
sudo certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Certificates will be in: /etc/letsencrypt/live/yourdomain.com/
```

### 3. Copy Certificates

```bash
# Create ssl directory
mkdir -p ./ssl

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ./ssl/server.crt
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ./ssl/server.key

# Fix permissions
sudo chown $USER:$USER ./ssl/server.*
chmod 600 ./ssl/server.key
chmod 644 ./ssl/server.crt
```

### 4. Update nginx Configuration

Edit `nginx/nginx.conf` and replace `server_name _;` with your domain:

```nginx
server_name yourdomain.com www.yourdomain.com;
```

### 5. Start Services

```bash
docker-compose up -d
```

## Option 2: Automated Let's Encrypt with Docker

### 1. Create Production Docker Compose

Use the included `docker-compose.production.yml` with certbot service:

```yaml
version: '3.8'

services:
  easycopy-server:
    # ... existing config ...

  nginx:
    # ... existing config ...
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt

  certbot:
    image: certbot/certbot
    volumes:
      - certbot-etc:/etc/letsencrypt
      - certbot-var:/var/lib/letsencrypt
    entrypoint: "/bin/sh -c 'trap exit TERM; while :; do certbot renew; sleep 12h & wait $${!}; done;'"

volumes:
  certbot-etc:
  certbot-var:
```

### 2. Initial Certificate Generation

```bash
# Replace yourdomain.com with your actual domain
docker-compose run --rm certbot certonly --webroot \
  -w /var/www/certbot \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email
```

### 3. Update nginx for Let's Encrypt

Update `nginx/nginx.conf` to use Let's Encrypt certificates:

```nginx
ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
```

## Certificate Renewal

Let's Encrypt certificates are valid for 90 days.

### Manual Renewal

```bash
sudo certbot renew
# Then copy new certificates to ./ssl/ directory
```

### Automatic Renewal (with certbot container)

The certbot container will automatically attempt renewal every 12 hours. Certificates are only renewed if they expire within 30 days.

## Testing

Visit your domain:
```
https://yourdomain.com
```

Check SSL certificate:
```bash
openssl s_client -connect yourdomain.com:443 -servername yourdomain.com
```

## Troubleshooting

### Certificate Errors

If browsers show certificate errors:
1. Verify domain DNS points to your server
2. Check certificate files exist in ./ssl/
3. Restart nginx: `docker-compose restart nginx`

### Port 80 Required

Let's Encrypt validation requires port 80 to be accessible. Ensure your firewall allows it:

```bash
# Check if port 80 is open
sudo netstat -tlnp | grep :80

# If using ufw firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Permission Issues

If nginx can't read certificates:

```bash
chmod 600 ./ssl/server.key
chmod 644 ./ssl/server.crt
```

## Security Best Practices

1. **Keep certificates updated** - Set up automatic renewal
2. **Use strong ciphers** - Already configured in nginx.conf
3. **Enable HSTS** - Already configured (Strict-Transport-Security header)
4. **Regular updates** - Keep Docker images updated
5. **Firewall** - Only expose ports 80 and 443

## Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [SSL Labs Test](https://www.ssllabs.com/ssltest/) - Test your SSL configuration
