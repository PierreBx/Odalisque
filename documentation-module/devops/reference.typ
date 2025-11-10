// Complete DevOps Reference - FlutterGristAPI
// Configuration templates, checklists, and quick references

#import "../common/styles.typ": *

= DevOps Reference

Complete reference documentation for FlutterGristAPI DevOps operations, including configuration templates, checklists, and best practices.

== Configuration Templates

=== docker-compose.yml Template

Complete production-ready configuration:

```yaml
version: '3.8'

services:
  # Grist service - self-hosted spreadsheet database
  grist:
    image: gristlabs/grist:latest
    container_name: fluttergrist-grist
    hostname: grist

    # Port mapping (internal:external)
    ports:
      - "127.0.0.1:8484:8484"  # Bind to localhost only

    # Data persistence
    volumes:
      - ./grist-module/grist-data:/persist
      - ./backups:/backups:ro  # Backup access (read-only)

    # Environment configuration
    environment:
      - GRIST_SESSION_SECRET=${GRIST_SESSION_SECRET}
      - GRIST_SINGLE_ORG=${GRIST_ORG_NAME:-docs}
      - APP_HOME_URL=${GRIST_APP_HOME_URL:-http://localhost:8484}
      - GRIST_SANDBOX_FLAVOR=${GRIST_SANDBOX:-gvisor}
      - GRIST_DEFAULT_EMAIL=${ADMIN_EMAIL}
      - GRIST_FORCE_LOGIN=true

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
          pids: 100
        reservations:
          cpus: '0.5'
          memory: 512M

    # Health check
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8484/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Restart policy
    restart: unless-stopped

    # Network
    networks:
      - backend

    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
        compress: "true"

    # Security
    security_opt:
      - no-new-privileges:true

    # User (run as non-root)
    user: "1000:1000"

  # Flutter development environment
  flutter:
    build:
      context: ./flutter-module
      dockerfile: Dockerfile
      args:
        USER_ID: ${USER_ID:-1000}
        GROUP_ID: ${GROUP_ID:-1000}
        FLUTTER_VERSION: ${FLUTTER_VERSION:-3.16.0}

    container_name: fluttergrist-flutter-dev
    hostname: flutter-dev

    volumes:
      - ./flutter-module:/app
      - flutter_pub_cache:/home/flutterdev/.pub-cache
      - /app/.dart_tool  # Exclude from sync

    working_dir: /app

    stdin_open: true
    tty: true

    command: /bin/bash

    networks:
      - backend

    depends_on:
      grist:
        condition: service_healthy

    restart: "no"

  # Nginx reverse proxy (production)
  nginx:
    image: nginx:alpine
    container_name: fluttergrist-nginx

    ports:
      - "80:80"
      - "443:443"

    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - ./nginx/logs:/var/log/nginx
      - /etc/letsencrypt:/etc/letsencrypt:ro

    depends_on:
      - grist

    networks:
      - backend

    restart: unless-stopped

    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Optional: Backup service
  backup:
    image: alpine:latest
    container_name: fluttergrist-backup

    volumes:
      - ./grist-module/grist-data:/data:ro
      - ./backups:/backups
      - ./scripts:/scripts:ro

    command: /scripts/backup.sh

    restart: "no"

    # Run backup via cron on host instead

volumes:
  flutter_pub_cache:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${PWD}/.flutter-cache

networks:
  backend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
          gateway: 172.28.0.1
```

=== .env Template

Complete environment configuration:

```bash
# ==============================================================================
# FlutterGristAPI Environment Configuration
# ==============================================================================
# IMPORTANT: Never commit this file to version control!
# Copy from .env.example and customize for your environment
# ==============================================================================

# ------------------------------------------------------------------------------
# Grist Configuration
# ------------------------------------------------------------------------------

# Session secret for Grist (REQUIRED)
# Generate with: openssl rand -hex 32
GRIST_SESSION_SECRET=your-64-character-random-hex-string-here

# Application URL (adjust for your domain)
GRIST_APP_HOME_URL=http://localhost:8484

# Organization name
GRIST_ORG_NAME=docs

# Sandbox mode (unsandboxed, gvisor, or pynbox)
# Production: use gvisor
# Development: use unsandboxed
GRIST_SANDBOX=unsandboxed

# Admin email (optional)
ADMIN_EMAIL=admin@example.com

# ------------------------------------------------------------------------------
# Grist API Configuration
# ------------------------------------------------------------------------------

# API Key (generate in Grist UI: Profile → API → Create)
# Keep this secret!
GRIST_API_KEY=your-grist-api-key-here

# Document ID (from URL: /doc/DOCUMENT_ID)
GRIST_DOCUMENT_ID=your-document-id-here

# ------------------------------------------------------------------------------
# Flutter Configuration
# ------------------------------------------------------------------------------

# Flutter version
FLUTTER_VERSION=3.16.0

# User/Group IDs for file permissions (Linux/macOS)
# Use your user ID: $(id -u)
USER_ID=1000
GROUP_ID=1000

# ------------------------------------------------------------------------------
# Docker Configuration
# ------------------------------------------------------------------------------

# Compose project name (optional)
COMPOSE_PROJECT_NAME=fluttergrist

# ------------------------------------------------------------------------------
# Production Settings (SSL/TLS)
# ------------------------------------------------------------------------------

# Domain name for SSL certificate
DOMAIN_NAME=yourdomain.com

# Email for Let's Encrypt notifications
LETSENCRYPT_EMAIL=admin@yourdomain.com

# ------------------------------------------------------------------------------
# Backup Configuration
# ------------------------------------------------------------------------------

# Backup retention (days)
BACKUP_RETENTION_DAILY=7
BACKUP_RETENTION_WEEKLY=28
BACKUP_RETENTION_MONTHLY=90

# Backup destination
BACKUP_DESTINATION=/opt/backups

# S3 backup (optional)
# AWS_ACCESS_KEY_ID=your-access-key
# AWS_SECRET_ACCESS_KEY=your-secret-key
# AWS_BUCKET=your-backup-bucket
# AWS_REGION=us-east-1

# ------------------------------------------------------------------------------
# Monitoring Configuration (optional)
# ------------------------------------------------------------------------------

# Prometheus metrics
# PROMETHEUS_ENABLED=false
# PROMETHEUS_PORT=9090

# Grafana dashboard
# GRAFANA_ENABLED=false
# GRAFANA_PORT=3000
# GRAFANA_ADMIN_PASSWORD=change-this-password

# Alert email
# ALERT_EMAIL=ops@example.com

# ------------------------------------------------------------------------------
# Development Settings
# ------------------------------------------------------------------------------

# Debug mode (true/false)
DEBUG=false

# Log level (debug, info, warn, error)
LOG_LEVEL=info

# ==============================================================================
# End of configuration
# ==============================================================================
```

=== Dockerfile Template (Flutter)

Optimized Flutter development container:

```dockerfile
# ==============================================================================
# Flutter Development Dockerfile
# ==============================================================================
FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# ==============================================================================
# Install system dependencies
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    # Required libraries
    libglu1-mesa \
    # SSL certificates
    ca-certificates \
    gnupg \
    # Additional tools
    wget \
    vim \
    nano \
    # Cleanup
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Install Flutter SDK
# ==============================================================================
ARG FLUTTER_VERSION=3.16.0
ENV FLUTTER_VERSION=${FLUTTER_VERSION}
ENV FLUTTER_ROOT=/opt/flutter
ENV PATH="${FLUTTER_ROOT}/bin:${FLUTTER_ROOT}/bin/cache/dart-sdk/bin:${PATH}"

RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_ROOT}

# Pre-download Flutter artifacts
RUN flutter precache && \
    flutter config --no-analytics && \
    flutter doctor

# ==============================================================================
# Create non-root user
# ==============================================================================
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g ${GROUP_ID} flutterdev && \
    useradd -m -u ${USER_ID} -g flutterdev -s /bin/bash flutterdev && \
    mkdir -p /home/flutterdev/.pub-cache && \
    chown -R flutterdev:flutterdev /home/flutterdev

# ==============================================================================
# Setup working directory
# ==============================================================================
WORKDIR /app
RUN chown -R flutterdev:flutterdev /app

# Switch to non-root user
USER flutterdev

# ==============================================================================
# Configure Flutter for user
# ==============================================================================
RUN flutter config --no-analytics

# Set pub cache
ENV PUB_CACHE=/home/flutterdev/.pub-cache

# ==============================================================================
# Health check
# ==============================================================================
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD flutter doctor || exit 1

# ==============================================================================
# Default command
# ==============================================================================
CMD ["/bin/bash"]
```

== Operations Checklists

=== Daily Operations Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Task*], [*Command*], [*Status*],

  [Check container status], [`docker ps`], [□],
  [View Grist logs], [`./docker-test.sh grist-logs` (Ctrl+C to exit)], [□],
  [Check resource usage], [`docker stats --no-stream`], [□],
  [Verify Grist accessible], [Open http://localhost:8484], [□],
  [Check disk space], [`df -h`], [□],
  [Review error logs], [`docker-compose logs grist | grep -i error`], [□],
)

=== Weekly Maintenance Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Task*], [*Action*], [*Status*],

  [Update Docker images], [`docker-compose pull && docker-compose up -d`], [□],
  [Verify backups], [Check backup directory for recent backups], [□],
  [Test backup restore], [Restore to test environment], [□],
  [Review logs], [Check for warnings or errors], [□],
  [Check disk usage], [`docker system df`], [□],
  [Cleanup old data], [`docker system prune`], [□],
  [Security scan], [`docker scan gristlabs/grist:latest`], [□],
  [Update documentation], [Document any changes or issues], [□],
)

=== Monthly Security Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Task*], [*Action*], [*Status*],

  [Rotate API keys], [Generate new keys in Grist UI, update .env], [□],
  [Review access logs], [Check for unauthorized access attempts], [□],
  [Update SSL certificates], [Verify auto-renewal working], [□],
  [Security patch updates], [Update all Docker images], [□],
  [Secrets scan], [Run gitleaks on repository], [□],
  [Review firewall rules], [Verify only necessary ports open], [□],
  [Test disaster recovery], [Practice full restore procedure], [□],
  [Security audit], [Review all security configurations], [□],
)

=== Pre-Deployment Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Task*], [*Action*], [*Status*],

  [Backup current state], [`tar -czf pre-deploy-backup.tar.gz grist-data/`], [□],
  [Test in development], [Run `./docker-test.sh all`], [□],
  [Code review completed], [All changes reviewed and approved], [□],
  [Update documentation], [Document changes and new features], [□],
  [Check dependencies], [`docker-compose config`], [□],
  [Verify environment vars], [Check .env file complete], [□],
  [Plan rollback], [Document rollback procedure], [□],
  [Schedule maintenance], [Notify users of downtime], [□],
  [Test rollback], [Verify rollback procedure works], [□],
)

=== Post-Deployment Checklist

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Task*], [*Action*], [*Status*],

  [Verify services running], [`docker ps`], [□],
  [Test Grist UI], [Open http://localhost:8484], [□],
  [Check logs for errors], [`docker-compose logs --tail=100`], [□],
  [Test API endpoints], [Verify API responses], [□],
  [Monitor resource usage], [`docker stats`], [□],
  [Verify data integrity], [Check data in Grist UI], [□],
  [Test user workflows], [Verify key features working], [□],
  [Document deployment], [Record deployment details], [□],
  [Monitor for 1 hour], [Watch for issues], [□],
)

== Quick Reference Tables

=== Port Reference

#table(
  columns: (auto, auto, 1fr),
  align: (center, left, left),
  [*Port*], [*Service*], [*Purpose*],

  [8484], [Grist], [Web UI and API access],
  [80], [Nginx], [HTTP (redirects to HTTPS)],
  [443], [Nginx], [HTTPS (production)],
  [22], [SSH], [Server administration],
  [9090], [Prometheus], [Metrics (optional)],
  [3000], [Grafana], [Dashboard (optional)],
)

=== Volume Reference

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Volume*], [*Mount Point*], [*Purpose*],

  [`./grist-data`], [`/persist`], [Grist database files (CRITICAL)],
  [`./flutter-module`], [`/app`], [Flutter source code (live sync)],
  [`flutter_pub_cache`], [`/home/flutterdev/.pub-cache`], [Flutter dependencies cache],
  [`./backups`], [`/backups`], [Backup storage],
  [`./nginx/ssl`], [`/etc/nginx/ssl`], [SSL certificates],
)

=== Environment Variable Reference

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Variable*], [*Required*], [*Description*],

  [`GRIST_SESSION_SECRET`], [Yes], [Session encryption key (64 chars)],
  [`GRIST_APP_HOME_URL`], [No], [Public URL (default: http://localhost:8484)],
  [`GRIST_SINGLE_ORG`], [No], [Organization name (default: docs)],
  [`GRIST_API_KEY`], [No], [API access key (generate in UI)],
  [`USER_ID`], [No], [User ID for file permissions (default: 1000)],
  [`GROUP_ID`], [No], [Group ID for file permissions (default: 1000)],
  [`FLUTTER_VERSION`], [No], [Flutter SDK version (default: 3.16.0)],
)

=== Docker Compose Service Reference

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*Service*], [*Purpose*], [*Restart*],

  [`grist`], [Database server (always running)], [unless-stopped],
  [`flutter`], [Interactive development shell], [no],
  [`flutter-test`], [Automated test runner (temporary)], [no],
  [`flutter-analyze`], [Static analysis (temporary)], [no],
)

=== Common Exit Codes

#table(
  columns: (auto, 1fr, 1fr),
  align: (center, left, left),
  [*Code*], [*Meaning*], [*Action*],

  [0], [Success], [Normal exit],
  [1], [General error], [Check logs for details],
  [2], [Misuse of shell command], [Check command syntax],
  [126], [Command cannot execute], [Check permissions],
  [127], [Command not found], [Verify command exists],
  [130], [Terminated by Ctrl+C], [User interruption],
  [137], [SIGKILL (OOM)], [Out of memory - increase limits],
  [143], [SIGTERM], [Graceful shutdown],
)

=== Log Severity Levels

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Level*], [*Description*], [*Action Required*],

  [DEBUG], [Detailed information for debugging], [No],
  [INFO], [General informational messages], [No],
  [WARN], [Warning messages, potential issues], [Review],
  [ERROR], [Error messages, functionality impaired], [Investigate],
  [FATAL], [Critical errors, service failure], [Immediate],
)

== Backup Strategies

=== Backup Schedule

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, center, center, left),
  [*Type*], [*Frequency*], [*Retention*], [*Purpose*],

  [Hourly], [Every hour], [24 hours], [Recent changes, quick recovery],
  [Daily], [2:00 AM], [7 days], [Daily snapshots],
  [Weekly], [Sunday 2:00 AM], [4 weeks], [Weekly archives],
  [Monthly], [1st of month], [12 months], [Long-term storage],
)

=== Backup Script Template

```bash
#!/bin/bash
# backup-grist.sh - Automated Grist backup script

set -e

# Configuration
BACKUP_DIR="/opt/backups"
SOURCE_DIR="./grist-module/grist-data"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_NAME="grist-backup-${TIMESTAMP}"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Create backup
echo "Creating backup: ${BACKUP_NAME}"
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
  -C "$(dirname ${SOURCE_DIR})" \
  "$(basename ${SOURCE_DIR})"

# Generate checksum
sha256sum "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
  > "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz.sha256"

# Encrypt (optional)
# gpg --symmetric --cipher-algo AES256 \
#   "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"

# Verify backup
echo "Verifying backup..."
tar -tzf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" > /dev/null

# Get backup size
SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
echo "Backup created: ${BACKUP_NAME}.tar.gz (${SIZE})"

# Remove old backups
echo "Cleaning old backups (older than ${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -name "grist-backup-*.tar.gz" \
  -mtime +${RETENTION_DAYS} -delete

find "${BACKUP_DIR}" -name "grist-backup-*.tar.gz.sha256" \
  -mtime +${RETENTION_DAYS} -delete

# List recent backups
echo "Recent backups:"
ls -lh "${BACKUP_DIR}/grist-backup-"*.tar.gz | tail -5

# Optional: Upload to S3
# aws s3 cp "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
#   s3://your-bucket/backups/ --sse AES256

echo "Backup complete!"
```

Make executable:

```bash
chmod +x backup-grist.sh
```

Schedule with cron:

```bash
# Edit crontab
crontab -e

# Add backup jobs
# Daily at 2 AM
0 2 * * * /path/to/backup-grist.sh >> /var/log/grist-backup.log 2>&1

# Weekly on Sunday at 3 AM
0 3 * * 0 /path/to/backup-grist.sh weekly >> /var/log/grist-backup.log 2>&1
```

=== Restore Procedure

```bash
#!/bin/bash
# restore-grist.sh - Restore from backup

set -e

# Configuration
BACKUP_FILE=$1
RESTORE_DIR="./grist-module/grist-data"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup-file.tar.gz>"
  exit 1
fi

# Verify backup exists
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: Backup file not found: $BACKUP_FILE"
  exit 1
fi

# Verify checksum if available
if [ -f "${BACKUP_FILE}.sha256" ]; then
  echo "Verifying backup integrity..."
  sha256sum -c "${BACKUP_FILE}.sha256"
fi

# Stop Grist
echo "Stopping Grist..."
./docker-test.sh grist-stop

# Backup current data
echo "Backing up current data..."
if [ -d "$RESTORE_DIR" ]; then
  mv "$RESTORE_DIR" "${RESTORE_DIR}.pre-restore-$(date +%Y%m%d-%H%M%S)"
fi

# Extract backup
echo "Restoring from backup..."
mkdir -p "$(dirname $RESTORE_DIR)"
tar -xzf "$BACKUP_FILE" -C "$(dirname $RESTORE_DIR)"

# Fix permissions
echo "Fixing permissions..."
sudo chown -R $USER:$USER "$RESTORE_DIR"
chmod -R 755 "$RESTORE_DIR"

# Start Grist
echo "Starting Grist..."
./docker-test.sh grist-start

# Wait for Grist to be ready
echo "Waiting for Grist to start..."
sleep 10

# Verify Grist is running
if curl -f -s http://localhost:8484/health > /dev/null; then
  echo "✓ Restore complete! Grist is running."
  echo "✓ Access Grist at: http://localhost:8484"
else
  echo "✗ Warning: Grist may not be responding."
  echo "  Check logs: ./docker-test.sh grist-logs"
fi
```

== Monitoring Script Templates

=== Health Check Script

```bash
#!/bin/bash
# health-check.sh - System health monitoring

# Configuration
ALERT_EMAIL="admin@example.com"
ALERT_THRESHOLD_CPU=80
ALERT_THRESHOLD_MEM=85
ALERT_THRESHOLD_DISK=85

# Check container status
echo "=== Container Status ==="
GRIST_STATUS=$(docker inspect -f '{{.State.Status}}' grist_server 2>/dev/null)

if [ "$GRIST_STATUS" != "running" ]; then
  echo "ALERT: Grist is not running!"
  echo "Grist container not running" | \
    mail -s "FlutterGrist Alert" $ALERT_EMAIL
  exit 1
fi

echo "✓ Grist is running"

# Check CPU usage
echo -e "\n=== CPU Usage ==="
CPU=$(docker stats --no-stream grist_server --format "{{.CPUPerc}}" | sed 's/%//')
echo "CPU: ${CPU}%"

if (( $(echo "$CPU > $ALERT_THRESHOLD_CPU" | bc -l) )); then
  echo "ALERT: High CPU usage!"
  echo "CPU usage: ${CPU}%" | \
    mail -s "FlutterGrist: High CPU" $ALERT_EMAIL
fi

# Check memory usage
echo -e "\n=== Memory Usage ==="
MEM=$(docker stats --no-stream grist_server --format "{{.MemPerc}}" | sed 's/%//')
echo "Memory: ${MEM}%"

if (( $(echo "$MEM > $ALERT_THRESHOLD_MEM" | bc -l) )); then
  echo "ALERT: High memory usage!"
  echo "Memory usage: ${MEM}%" | \
    mail -s "FlutterGrist: High Memory" $ALERT_EMAIL
fi

# Check disk space
echo -e "\n=== Disk Space ==="
DISK=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo "Disk: ${DISK}%"

if [ "$DISK" -gt "$ALERT_THRESHOLD_DISK" ]; then
  echo "ALERT: Low disk space!"
  echo "Disk usage: ${DISK}%" | \
    mail -s "FlutterGrist: Low Disk Space" $ALERT_EMAIL
fi

# Check Grist connectivity
echo -e "\n=== Grist Connectivity ==="
if curl -f -s http://localhost:8484/health > /dev/null; then
  echo "✓ Grist is accessible"
else
  echo "ALERT: Grist is not responding!"
  echo "Grist not responding to health check" | \
    mail -s "FlutterGrist: Service Down" $ALERT_EMAIL
fi

# Check recent errors
echo -e "\n=== Recent Errors ==="
ERROR_COUNT=$(docker logs --since 1h grist_server 2>&1 | grep -ic error)
echo "Errors in last hour: $ERROR_COUNT"

if [ "$ERROR_COUNT" -gt 10 ]; then
  echo "ALERT: High error rate!"
  docker logs --since 1h grist_server 2>&1 | grep -i error | \
    mail -s "FlutterGrist: High Error Rate" $ALERT_EMAIL
fi

echo -e "\n=== Health Check Complete ==="
```

== Best Practices Summary

=== Security Best Practices

1. *Never commit secrets* to version control
2. *Use strong random secrets* (32+ bytes)
3. *Rotate credentials* regularly (monthly minimum)
4. *Enable SSL/TLS* in production
5. *Run containers as non-root* users
6. *Set resource limits* to prevent DoS
7. *Keep software updated* with security patches
8. *Scan for vulnerabilities* regularly
9. *Encrypt backups* at rest and in transit
10. *Implement firewall rules* to restrict access

=== Backup Best Practices

1. *Automate backups* (daily minimum)
2. *Test restores* regularly (monthly)
3. *Store offsite* for disaster recovery
4. *Verify integrity* with checksums
5. *Encrypt sensitive data* in backups
6. *Document procedures* for recovery
7. *Retain multiple versions* (3-2-1 rule)
8. *Monitor backup success* with alerts
9. *Version control* configuration files
10. *Practice disaster recovery* drills

=== Operational Best Practices

1. *Monitor continuously* for issues
2. *Log everything* for troubleshooting
3. *Document changes* immediately
4. *Test in development* before production
5. *Use version control* for infrastructure code
6. *Implement health checks* for services
7. *Set up alerts* for critical metrics
8. *Regular maintenance* windows
9. *Capacity planning* based on trends
10. *Incident response plan* documented

#section_separator()

#info_box(type: "success")[
  **Complete Reference Created**

  This reference provides templates, checklists, and best practices for all DevOps operations. Use it as a companion to other documentation chapters for comprehensive coverage.

  *Quick Navigation:*
  - Configuration templates: docker-compose.yml, .env, Dockerfile
  - Operations checklists: daily, weekly, monthly, deployment
  - Quick reference tables: ports, volumes, variables
  - Script templates: backup, restore, monitoring
  - Best practices: security, backup, operations
]
