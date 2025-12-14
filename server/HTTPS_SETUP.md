# HTTPS Setup for Production

This guide explains the SSL/TLS certificate setup for EasyCopy production deployment.

## Overview

EasyCopy uses **self-signed SSL certificates** in production that are automatically generated on first startup. This provides encrypted HTTPS connections without requiring a domain name or certificate authority.

## Prerequisites

- Docker and docker-compose installed
- Ports 80 and 443 accessible from the internet

## Production Deployment with Self-Signed Certificates

### 1. Deploy Using Production Compose File

```bash
# Start production services
docker-compose -f docker-compose.production.yml up -d
```

On first startup, the `certbot` container will:
- Generate a self-signed SSL certificate valid for 365 days
- Save certificates to the `ssl-certs` Docker volume
- Use the domain from `SSL_DOMAIN` environment variable (defaults to `localhost`)

### 2. Custom Domain Configuration (Optional)

To generate certificates for your domain:

```bash
# Set your domain before starting
export SSL_DOMAIN=yourdomain.com
docker-compose -f docker-compose.production.yml up -d
```

This updates the certificate's CN (Common Name) and Subject Alternative Name fields.

### 3. Verify HTTPS is Working

Visit your server:
```
https://your-server-ip
# or
https://yourdomain.com
```

**Note**: Browsers will show a security warning because the certificate is self-signed. This is expected. Click "Advanced" → "Proceed" to access the site.

## Certificate Details

### Storage Location
Certificates are stored in a Docker volume named `ssl-certs`:
- Certificate: `/etc/nginx/ssl/server.crt`
- Private Key: `/etc/nginx/ssl/server.key`

### Certificate Properties
- **Type**: Self-signed X.509
- **Algorithm**: RSA 2048-bit
- **Validity**: 365 days from generation
- **Subject**: CN=yourdomain.com (or localhost)
- **SAN**: DNS entries for domain and localhost, plus IP 127.0.0.1

### nginx Configuration
The `server/nginx.conf` file is already configured to use these certificates:

```nginx
ssl_certificate /etc/nginx/ssl/server.crt;
ssl_certificate_key /etc/nginx/ssl/server.key;
```

## How It Works

The `docker-compose.production.yml` includes three key services:

1. **easycopy-server**: FastAPI backend (port 8000, internal only)
2. **nginx**: Reverse proxy handling HTTPS (ports 80→443, 443 for SSL)
3. **certbot**: Alpine container that generates self-signed certificates once on startup

### Certificate Generation Process

The certbot container runs this logic:
```bash
if [ ! -f /etc/nginx/ssl/server.crt ]; then
  # Generate new self-signed certificate
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj '/C=US/ST=State/L=City/O=EasyCopy/CN='${SSL_DOMAIN} \
    -addext 'subjectAltName=DNS:'${SSL_DOMAIN}',DNS:localhost,IP:127.0.0.1'
else
  # Skip if certificates already exist
fi
```

Certificates persist in the `ssl-certs` volume, so they're only generated once.

## Certificate Management

### Regenerate Certificates

To generate new certificates (e.g., for a new domain):

```bash
# Stop services
docker-compose -f docker-compose.production.yml down

# Remove the volume
docker volume rm easycopy_ssl-certs

# Restart with new domain
export SSL_DOMAIN=newdomain.com
docker-compose -f docker-compose.production.yml up -d
```

### Inspect Current Certificates

```bash
# View certificate details
docker-compose -f docker-compose.production.yml exec nginx \
  openssl x509 -in /etc/nginx/ssl/server.crt -text -noout

# Check expiration date
docker-compose -f docker-compose.production.yml exec nginx \
  openssl x509 -in /etc/nginx/ssl/server.crt -enddate -noout
```

### Manual Certificate Replacement

To use your own certificates (e.g., from a CA):

```bash
# Copy certificates into the volume using a temporary container
docker run --rm -v easycopy_ssl-certs:/certs -v $(pwd):/source alpine sh -c "
  cp /source/your-cert.crt /certs/server.crt &&
  cp /source/your-key.key /certs/server.key &&
  chmod 644 /certs/server.crt &&
  chmod 600 /certs/server.key
"

# Restart nginx to load new certificates
docker-compose -f docker-compose.production.yml restart nginx
```

## Browser Security Warnings

Self-signed certificates will trigger browser warnings:

- **Chrome/Edge**: "Your connection is not private" (NET::ERR_CERT_AUTHORITY_INVALID)
- **Firefox**: "Warning: Potential Security Risk Ahead"
- **Safari**: "This Connection Is Not Private"

This is **expected behavior** and does not mean the connection is unencrypted. The warning appears because browsers don't trust self-signed certificates.

### For Development/Testing
Click "Advanced" → "Proceed to [site]" to continue.

### For Production Use
Consider these options:
1. **Accept the warning**: Fine for internal/private deployments
2. **Import certificate**: Add `server.crt` to client browsers' trusted certificates
3. **Use a real CA**: Replace self-signed cert with one from Let's Encrypt or commercial CA

## Security Notes

### What Self-Signed Certificates Provide
✅ Encrypted connection (TLS/SSL)  
✅ Protection against eavesdropping  
✅ Data integrity (prevents tampering)  

### What They Don't Provide
❌ Browser trust (no CA validation)  
❌ Identity verification (anyone can generate matching cert)  
❌ Automatic device/browser acceptance  

### SSL/TLS Configuration
The `server/nginx.conf` already includes secure defaults:
- TLS 1.2 and 1.3 only
- Strong cipher suites
- HSTS header (forces HTTPS)
- Security headers (X-Frame-Options, X-Content-Type-Options, etc.)

## Troubleshooting

### nginx Won't Start

Check certificate files exist:
```bash
docker-compose -f docker-compose.production.yml exec nginx ls -la /etc/nginx/ssl/
```

Expected output:
```
-rw-r--r-- 1 root root 1383 Dec 14 server.crt
-rw------- 1 root root 1704 Dec 14 server.key
```

### Port Conflicts

Ensure ports 80 and 443 are available:
```bash
# Check what's using the ports
sudo lsof -i :80
sudo lsof -i :443

# On Linux, allow through firewall
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### View nginx Logs

```bash
docker-compose -f docker-compose.production.yml logs nginx
```

## Upgrading to Real Certificates (Optional)

For public-facing production deployments, consider using real CA-signed certificates:

### Option 1: Let's Encrypt (Free)
Use Certbot to get free certificates with 90-day validity (auto-renewable):
```bash
# Install certbot on host
sudo apt install certbot  # Ubuntu/Debian
# or
brew install certbot      # macOS

# Generate certificate (requires domain and port 80 access)
sudo certbot certonly --standalone -d yourdomain.com
```

Then copy certificates into the Docker volume as shown in "Manual Certificate Replacement" above.

### Option 2: Commercial CA
Purchase certificates from providers like DigiCert, Sectigo, or GlobalSign, then use the manual replacement method.

## Additional Resources

- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [nginx SSL/TLS Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
