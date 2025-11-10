// Security Best Practices - FlutterGristAPI
// SSL, secrets management, and security hardening

#import "../common/styles.typ": *

= Security Best Practices

This chapter covers security configuration, SSL/TLS setup, secrets management, and hardening practices for FlutterGristAPI.

#info_box(type: "danger")[
  **Security Notice**

  This documentation covers security best practices. Always:
  - Keep software updated
  - Use strong passwords and secrets
  - Regular security audits
  - Follow principle of least privilege
  - Never commit secrets to version control
]

== Security Overview

=== Security Layers

```
┌─────────────────────────────────────────┐
│  Layer 1: Network Security              │
│  • Firewall rules                       │
│  • Port restrictions                    │
│  • SSL/TLS encryption                   │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│  Layer 2: Application Security          │
│  • Authentication & Authorization       │
│  • Session management                   │
│  • API key protection                   │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│  Layer 3: Container Security            │
│  • User permissions                     │
│  • Resource limits                      │
│  • Network isolation                    │
└─────────────────────────────────────────┘
          ↓
┌─────────────────────────────────────────┐
│  Layer 4: Data Security                 │
│  • Encryption at rest                   │
│  • Backup encryption                    │
│  • Secure data deletion                 │
└─────────────────────────────────────────┘
```

=== Security Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Category*], [*Action*], [*Priority*],

  [Secrets], [Use strong random secrets (32+ bytes)], [Critical],
  [Secrets], [Never commit .env to version control], [Critical],
  [SSL/TLS], [Enable HTTPS in production], [Critical],
  [Updates], [Keep Docker images updated], [High],
  [Firewall], [Restrict port access], [High],
  [Backups], [Encrypt backups], [High],
  [Passwords], [Use bcrypt for password hashing], [High],
  [API Keys], [Rotate API keys regularly], [Medium],
  [Logs], [Sanitize sensitive data in logs], [Medium],
  [Scanning], [Run security scans regularly], [Medium],
)

== Secrets Management

=== Environment Variables

==== .env File Security

```bash
# CORRECT: Strong random secret
GRIST_SESSION_SECRET=a3f9c8b2e1d4f5g6h7i8j9k0l1m2n3o4p5q6r7s8t9u0v1w2x3y4z5

# WRONG: Weak or default secret
GRIST_SESSION_SECRET=change-this-to-a-random-secret-key
GRIST_SESSION_SECRET=password123
```

*Generate Strong Secrets:*

```bash
# Method 1: OpenSSL (Recommended)
openssl rand -hex 32

# Method 2: Python
python3 -c "import secrets; print(secrets.token_hex(32))"

# Method 3: /dev/urandom
head -c 32 /dev/urandom | base64

# Method 4: UUID-based
uuidgen | sha256sum | cut -c1-64
```

==== File Permissions

```bash
# Restrict .env file access (owner read/write only)
chmod 600 .env

# Verify permissions
ls -la .env
# Should show: -rw------- (600)

# Set correct ownership
chown $USER:$USER .env
```

==== .gitignore Configuration

Verify `.gitignore` includes:

```bash
# Environment files
.env
.env.local
.env.*.local

# Secrets
*.key
*.pem
secrets/

# Grist data (contains sensitive information)
grist-data/
!grist-data/README.md
```

*Verify files are gitignored:*

```bash
# Check if .env is tracked
git ls-files .env
# Should return nothing

# Test gitignore
git check-ignore -v .env
# Should show: .gitignore:X:.env    .env
```

=== Docker Secrets (Production)

For production deployments using Docker Swarm:

```yaml
# docker-compose.production.yml
services:
  grist:
    secrets:
      - grist_session_secret
      - grist_api_key
    environment:
      - GRIST_SESSION_SECRET_FILE=/run/secrets/grist_session_secret

secrets:
  grist_session_secret:
    external: true
  grist_api_key:
    external: true
```

*Create secrets:*

```bash
# Create secret from file
echo "your-secret-value" | \
  docker secret create grist_session_secret -

# Create from stdin
docker secret create grist_api_key -

# List secrets
docker secret ls

# Inspect secret (value not shown)
docker secret inspect grist_session_secret
```

=== API Key Management

==== Generating API Keys

1. Access Grist UI: http://localhost:8484
2. Click profile icon → "Profile Settings"
3. Navigate to "API" section
4. Click "Create" to generate new API key
5. **Copy immediately** (shown only once)
6. Store securely in `.env` or secrets manager

==== API Key Rotation

```bash
# Rotation procedure:
# 1. Generate new API key in Grist UI
# 2. Update .env file
echo "GRIST_API_KEY=new-api-key-here" >> .env.new

# 3. Test new key
curl -H "Authorization: Bearer new-api-key-here" \
  http://localhost:8484/api/docs

# 4. Replace old key if test succeeds
mv .env .env.backup
mv .env.new .env

# 5. Restart services
docker-compose restart

# 6. Verify functionality
# 7. Delete old key from Grist UI
# 8. Securely delete backup
shred -u .env.backup  # Linux
rm -P .env.backup     # macOS
```

*Rotation Schedule:*
- Development: Every 90 days
- Staging: Every 60 days
- Production: Every 30 days
- After security incident: Immediately

=== Secrets Scanning

==== Using Gitleaks

```bash
# Install gitleaks
# macOS:
brew install gitleaks

# Linux:
wget https://github.com/zricethezav/gitleaks/releases/download/v8.18.0/gitleaks_8.18.0_linux_x64.tar.gz
tar xzf gitleaks_8.18.0_linux_x64.tar.gz
sudo mv gitleaks /usr/local/bin/

# Scan repository for secrets
gitleaks detect --source=. --verbose

# Scan before commit (use as git hook)
gitleaks protect --staged --verbose

# Scan entire git history
gitleaks detect --source=. --log-level=info
```

==== .gitleaksignore

Create `.gitleaksignore` for false positives:

```bash
# False positive: test data
test/fixtures/test_api_key.txt

# False positive: documentation examples
documentation-module/**/*.md:generic-api-key
```

==== Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "Running Gitleaks scan..."

if command -v gitleaks &> /dev/null; then
  gitleaks protect --staged --verbose
  if [ $? -eq 1 ]; then
    echo "⚠️  Gitleaks detected secrets!"
    echo "Remove secrets before committing."
    exit 1
  fi
else
  echo "⚠️  Gitleaks not installed, skipping scan"
fi

exit 0
```

Make executable:

```bash
chmod +x .git/hooks/pre-commit
```

== SSL/TLS Configuration

=== Development Environment

For local development, HTTP is acceptable:

```
http://localhost:8484
```

#info_box(type: "warning")[
  **Development Only**

  Plain HTTP is only acceptable for local development. Always use HTTPS in production!
]

=== Production SSL with Let's Encrypt

==== Prerequisites

- Public domain name pointing to your server
- Ports 80 and 443 open on firewall
- Nginx or reverse proxy configured

==== Automated SSL Setup (Ansible)

The project includes Ansible playbooks for SSL automation:

```bash
cd deployment-module

# Configure inventory
nano inventory/production.yml
# Set: ansible_host, domain_name

# Run SSL setup playbook
ansible-playbook -i inventory/production.yml \
  playbooks/configure_ssl.yml

# What it does:
# 1. Installs certbot and python3-certbot-nginx
# 2. Generates SSL certificate via Let's Encrypt
# 3. Configures Nginx with SSL
# 4. Sets up auto-renewal
# 5. Configures security headers
```

==== Manual SSL Setup

===== Step 1: Install Certbot

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx

# RHEL/CentOS
sudo yum install -y certbot python3-certbot-nginx

# macOS
brew install certbot
```

===== Step 2: Generate Certificate

```bash
# Stop services using ports 80/443
sudo systemctl stop nginx

# Generate certificate
sudo certbot certonly --standalone \
  -d yourdomain.com \
  -d www.yourdomain.com \
  --email admin@yourdomain.com \
  --agree-tos \
  --no-eff-email

# Certificates stored in:
# /etc/letsencrypt/live/yourdomain.com/
```

===== Step 3: Configure Nginx

Create `/etc/nginx/sites-available/fluttergrist-ssl.conf`:

```nginx
# HTTP → HTTPS redirect
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;

    # ACME challenge for Let's Encrypt
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    # Redirect all HTTP to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Modern SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;

    # SSL session optimization
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomain.com/chain.pem;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Reverse proxy to Grist
    location / {
        proxy_pass http://localhost:8484;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # Logging
    access_log /var/log/nginx/fluttergrist_access.log;
    error_log /var/log/nginx/fluttergrist_error.log;
}
```

===== Step 4: Enable and Test

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/fluttergrist-ssl.conf \
  /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# Test HTTPS
curl -I https://yourdomain.com
```

==== Auto-Renewal

Let's Encrypt certificates expire after 90 days. Set up auto-renewal:

```bash
# Test renewal (dry run)
sudo certbot renew --dry-run

# Certbot automatically installs renewal cron job at:
# /etc/cron.d/certbot
# OR
# Systemd timer: certbot.timer

# Verify auto-renewal is configured
sudo systemctl status certbot.timer
# OR
sudo cat /etc/cron.d/certbot
```

*Manual renewal:*

```bash
# Renew all certificates
sudo certbot renew

# Renew specific certificate
sudo certbot renew --cert-name yourdomain.com

# Force renewal (even if not expiring)
sudo certbot renew --force-renewal
```

==== Certificate Monitoring

Create monitoring script:

```bash
#!/bin/bash
# check_ssl_expiry.sh

DOMAIN="yourdomain.com"
DAYS_WARNING=30

# Get expiry date
EXPIRY=$(echo | openssl s_client -servername $DOMAIN \
  -connect $DOMAIN:443 2>/dev/null | \
  openssl x509 -noout -dates | grep notAfter | cut -d= -f2)

# Calculate days until expiry
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

echo "SSL Certificate for $DOMAIN"
echo "Expires: $EXPIRY"
echo "Days remaining: $DAYS_LEFT"

if [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
  echo "⚠️  WARNING: Certificate expires in $DAYS_LEFT days!"
  # Send alert email
  # echo "Certificate expires in $DAYS_LEFT days" | \
  #   mail -s "SSL Alert: $DOMAIN" admin@example.com
fi
```

Run weekly:

```bash
chmod +x check_ssl_expiry.sh

# Add to crontab (every Monday at 9 AM)
# crontab -e
# 0 9 * * 1 /path/to/check_ssl_expiry.sh
```

=== SSL Best Practices

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Practice*], [*Implementation*],

  [Use TLS 1.2+], [Disable TLS 1.0 and 1.1 (deprecated)],
  [Strong Ciphers], [Use modern cipher suites (ECDHE, AES-GCM)],
  [HSTS], [Enable with max-age=31536000 (1 year)],
  [Certificate Chain], [Include intermediate certificates (fullchain.pem)],
  [OCSP Stapling], [Enable for faster certificate validation],
  [Perfect Forward Secrecy], [Use ECDHE key exchange],
  [Regular Renewal], [Renew 30 days before expiration],
)

== Container Security

=== Running as Non-Root

==== Flutter Dockerfile

```dockerfile
FROM ubuntu:22.04

# Install dependencies as root
RUN apt-get update && apt-get install -y ...

# Create non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} flutterdev && \
    useradd -m -u ${USER_ID} -g flutterdev flutterdev

# Switch to non-root user
USER flutterdev

# Set working directory with correct ownership
WORKDIR /app

CMD ["/bin/bash"]
```

==== User ID Mapping

```bash
# Set in .env for consistent permissions
USER_ID=$(id -u)
GROUP_ID=$(id -g)

echo "USER_ID=$USER_ID" >> .env
echo "GROUP_ID=$GROUP_ID" >> .env
```

=== Resource Limits

Prevent resource exhaustion attacks:

```yaml
services:
  grist:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
          pids: 100
        reservations:
          cpus: '1.0'
          memory: 1G
```

=== Network Isolation

```yaml
services:
  grist:
    networks:
      - backend

  flutter:
    networks:
      - frontend
      - backend

networks:
  frontend:
    internal: false  # Can access external network
  backend:
    internal: true   # Isolated from external network
```

=== Read-Only Filesystem

```yaml
services:
  grist:
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
    volumes:
      - ./grist-data:/persist  # Only /persist is writable
```

=== Security Options

```yaml
services:
  grist:
    security_opt:
      - no-new-privileges:true  # Prevent privilege escalation
      - apparmor:docker-default # Use AppArmor profile
    cap_drop:
      - ALL  # Drop all capabilities
    cap_add:
      - NET_BIND_SERVICE  # Only add needed capabilities
```

== Firewall Configuration

=== UFW (Ubuntu/Debian)

```bash
# Install UFW
sudo apt-get install -y ufw

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (important!)
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow Grist (if needed for development)
sudo ufw allow 8484/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose

# List rules by number
sudo ufw status numbered

# Delete rule
sudo ufw delete [number]
```

=== Firewalld (RHEL/CentOS)

```bash
# Install firewalld
sudo yum install -y firewalld

# Start and enable
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Add services
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=ssh

# Add custom port (Grist)
sudo firewall-cmd --permanent --add-port=8484/tcp

# Reload firewall
sudo firewall-cmd --reload

# Check status
sudo firewall-cmd --list-all
```

=== iptables

```bash
# Basic iptables rules
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8484 -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save rules
sudo iptables-save > /etc/iptables/rules.v4

# Restore on boot
sudo apt-get install -y iptables-persistent
```

== Backup Security

=== Encrypted Backups

```bash
# Backup with GPG encryption
tar -czf - grist-module/grist-data/ | \
  gpg --symmetric --cipher-algo AES256 \
  --output grist-backup-$(date +%Y%m%d).tar.gz.gpg

# Restore encrypted backup
gpg --decrypt grist-backup-20250110.tar.gz.gpg | \
  tar -xzf -

# Backup with password
tar -czf - grist-module/grist-data/ | \
  openssl enc -aes-256-cbc -salt \
  -out grist-backup-$(date +%Y%m%d).tar.gz.enc

# Restore with password
openssl enc -aes-256-cbc -d \
  -in grist-backup-20250110.tar.gz.enc | \
  tar -xzf -
```

=== Backup Integrity

```bash
# Create backup with checksum
tar -czf grist-backup.tar.gz grist-module/grist-data/
sha256sum grist-backup.tar.gz > grist-backup.tar.gz.sha256

# Verify backup integrity
sha256sum -c grist-backup.tar.gz.sha256
```

=== Off-Site Backup

```bash
# Backup to S3 (encrypted)
aws s3 cp grist-backup.tar.gz.gpg \
  s3://your-bucket/backups/$(date +%Y%m%d)/ \
  --sse AES256

# Backup to rsync server
rsync -avz --delete \
  grist-module/grist-data/ \
  user@backup-server:/backups/grist/
```

== Security Auditing

=== Docker Security Scan

```bash
# Scan Docker image for vulnerabilities
docker scan gristlabs/grist:latest

# Scan custom image
docker scan flutter_dev
```

=== Container Vulnerability Scanning

```bash
# Using Trivy
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image gristlabs/grist:latest

# Using Clair
# See: https://github.com/quay/clair
```

=== Log Auditing

```bash
# Search for failed login attempts
docker-compose logs grist | grep -i "auth.*fail"

# Search for unauthorized access
docker-compose logs grist | grep -i "unauthorized"

# Search for suspicious activity
docker-compose logs grist | grep -E "(sql injection|xss|csrf)"
```

#section_separator()

#info_box(type: "success")[
  **Security Checklist**

  - ✓ Strong secrets generated and stored securely
  - ✓ SSL/TLS enabled in production
  - ✓ Firewall configured and enabled
  - ✓ Containers running as non-root
  - ✓ Resource limits set
  - ✓ Backups encrypted
  - ✓ Secrets scanning enabled
  - ✓ Regular security updates
  - ✓ Audit logs reviewed regularly
]
