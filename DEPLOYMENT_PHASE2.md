# Phase 2 Deployment Guide - Odalisque v0.14.0

## Overview

This guide provides step-by-step instructions for deploying Odalisque v0.14.0 (Phase 2 Enhanced Security Features) to production. Follow all steps carefully to ensure a secure and successful deployment.

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Grist Database Setup](#grist-database-setup)
3. [Backend Configuration](#backend-configuration)
4. [Nginx Security Headers](#nginx-security-headers)
5. [Certificate Pinning Setup](#certificate-pinning-setup)
6. [MFA Configuration](#mfa-configuration)
7. [Token Rotation Setup](#token-rotation-setup)
8. [Alert Service Configuration](#alert-service-configuration)
9. [Flutter App Deployment](#flutter-app-deployment)
10. [Post-Deployment Verification](#post-deployment-verification)
11. [Monitoring Setup](#monitoring-setup)
12. [Rollback Procedures](#rollback-procedures)

---

## Pre-Deployment Checklist

### ✅ Requirements Verification

**Infrastructure**:
- [ ] Production server meets minimum requirements:
  - 2GB RAM minimum
  - 20GB disk space
  - Ubuntu 20.04+ or Debian 11+
- [ ] SSL certificate valid and not expiring soon
- [ ] Backup system tested and working
- [ ] DNS configured correctly

**Dependencies**:
- [ ] Grist v1.1.0+ running
- [ ] PostgreSQL 12+ (if using)
- [ ] Nginx 1.18+ installed
- [ ] Docker 20.10+ (if containerized)
- [ ] Flutter 3.0+ for building

**Access**:
- [ ] SSH access to production server
- [ ] Admin access to Grist instance
- [ ] Domain admin access (for DNS/SSL)
- [ ] Email credentials for alerts (Gmail/SMTP)
- [ ] Firebase project for push notifications (optional)

**Backups**:
- [ ] Full database backup completed
- [ ] Configuration files backed up
- [ ] SSL certificates backed up
- [ ] Documented rollback procedures

### 📋 Pre-Deployment Testing

- [ ] All Phase 2 features tested in staging
- [ ] Security tests passed (see SECURITY_TESTING.md)
- [ ] Performance tests passed
- [ ] User acceptance testing completed
- [ ] Migration tested with production-like data

---

## Grist Database Setup

### Step 1: Create Required Tables

Connect to your Grist instance and create these tables if not already present:

#### 1. AuditLogs Table (from Phase 1)

| Column | Type | Description |
|--------|------|-------------|
| timestamp | DateTime | Event timestamp |
| action | Text | Action type |
| resource | Text | Resource affected |
| username | Text | User who performed action |
| user_id | Text | User ID |
| record_id | Text | Record ID (optional) |
| success | Toggle | Success status |
| ip_address | Text | IP address |
| device_fingerprint | Text | Device identifier |
| user_agent | Text | User agent string |
| metadata | Text | JSON metadata |

#### 2. RateLimits Table (from Phase 1)

| Column | Type | Description |
|--------|------|-------------|
| identifier | Text | Username or IP |
| is_ip_based | Toggle | IP-based flag |
| failed_attempts | Numeric | Failed count |
| last_failed_at | DateTime | Last failure time |
| locked_until | DateTime | Lockout expiry |
| metadata | Text | Additional info |

#### 3. RateLimits_API Table (from Phase 1)

| Column | Type | Description |
|--------|------|-------------|
| identifier | Text | User ID or IP |
| request_count | Numeric | Request count |
| window_start | DateTime | Window start time |
| metadata | Text | Endpoint info |

#### 4. APIKeys Table (NEW - Phase 2)

| Column | Type | Description |
|--------|------|-------------|
| key | Text | API key value |
| created_at | DateTime | Creation timestamp |
| expires_at | DateTime | Expiration timestamp |
| status | Choice | active, revoked, expired |
| created_by | Text | Admin username |
| last_used | DateTime | Last usage timestamp |
| rotation_count | Numeric | Number of rotations |

**Create via Grist UI or API**:

```python
# Script: setup_grist_tables.py

import requests
import json

BASE_URL = "https://your-grist-domain.com"
API_KEY = "your_admin_api_key"
DOC_ID = "your_doc_id"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Create APIKeys table
table_schema = {
    "tables": [{
        "id": "APIKeys",
        "columns": [
            {"id": "key", "fields": {"type": "Text", "label": "API Key"}},
            {"id": "created_at", "fields": {"type": "DateTime", "label": "Created At"}},
            {"id": "expires_at", "fields": {"type": "DateTime", "label": "Expires At"}},
            {"id": "status", "fields": {"type": "Choice", "label": "Status"}},
            {"id": "created_by", "fields": {"type": "Text", "label": "Created By"}},
            {"id": "last_used", "fields": {"type": "DateTime", "label": "Last Used"}},
            {"id": "rotation_count", "fields": {"type": "Numeric", "label": "Rotation Count"}}
        ]
    }]
}

response = requests.post(
    f"{BASE_URL}/api/docs/{DOC_ID}/tables",
    headers=headers,
    json=table_schema
)

print(f"Table creation: {response.status_code}")
```

### Step 2: Set Up Permissions

Configure Grist table permissions:

1. **AuditLogs**: Write-only for app, Read for admins
2. **RateLimits**: Read/Write for app
3. **RateLimits_API**: Read/Write for app
4. **APIKeys**: Read/Write for admins only

### Step 3: Initialize Data

```python
# Add initial API key record
initial_key = {
    "key": "your_current_api_key",
    "created_at": "2024-01-16T00:00:00Z",
    "expires_at": "2024-04-16T00:00:00Z",  # 90 days
    "status": "active",
    "created_by": "admin@yourdomain.com",
    "last_used": "2024-01-16T00:00:00Z",
    "rotation_count": 0
}

response = requests.post(
    f"{BASE_URL}/api/docs/{DOC_ID}/tables/APIKeys/records",
    headers=headers,
    json={"records": [{"fields": initial_key}]}
)
```

---

## Backend Configuration

### Step 1: Environment Variables

Create production environment file:

```bash
# /home/user/Odalisque/.env.production

# Grist Configuration
GRIST_BASE_URL=https://your-grist-domain.com
GRIST_API_KEY=your_production_api_key
GRIST_DOC_ID=your_production_doc_id

# Security Configuration
MFA_ENFORCE_FOR_ADMINS=true
MFA_ENFORCE_FOR_ALL=false
MFA_GRACE_PERIOD_DAYS=7

TOKEN_ROTATION_ENABLED=true
TOKEN_ROTATION_INTERVAL_DAYS=90
TOKEN_ROTATION_GRACE_HOURS=24

CERT_PINNING_ENABLED=true
CERT_PINNING_FINGERPRINTS=AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99

# Alert Configuration
EMAIL_ALERTS_ENABLED=true
EMAIL_PROVIDER=gmail
EMAIL_FROM=security@yourdomain.com
EMAIL_FROM_NAME=Odalisque Security
EMAIL_USERNAME=security@yourdomain.com
EMAIL_PASSWORD=your_app_password

PUSH_ALERTS_ENABLED=true
FCM_SERVER_KEY=your_fcm_server_key

ALERT_SEVERITY_THRESHOLD=high
DAILY_SUMMARY_ENABLED=true
DAILY_SUMMARY_TIME=08:00
DAILY_SUMMARY_RECIPIENTS=admin@yourdomain.com,security@yourdomain.com

# Rate Limiting
RATE_LIMIT_GENERAL=100
RATE_LIMIT_API=200
RATE_LIMIT_AUTH=10
```

**Security Note**: ⚠️ Never commit `.env.production` to git!

```bash
# Add to .gitignore if not already there
echo ".env.production" >> .gitignore
```

### Step 2: Deploy Environment File

```bash
# Copy to production server
scp .env.production user@your-server:/opt/odalisque/.env

# Set permissions
ssh user@your-server "chmod 600 /opt/odalisque/.env"
```

---

## Nginx Security Headers

### Step 1: Get Certificate Fingerprint

```bash
# SSH to production server
ssh user@your-server

# Get certificate fingerprint
openssl s_client -connect your-grist-domain.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -fingerprint -sha256 -noout

# Output: SHA256 Fingerprint=AA:BB:CC:DD:...
# Save this fingerprint for certificate pinning
```

### Step 2: Deploy Security Headers

```bash
# On production server
cd /opt/odalisque/deployment-module

# Deploy security headers using Ansible
ansible-playbook -i inventory/production deploy-security-headers.yml

# Or manually copy the configuration
sudo cp roles/security/templates/security-headers.conf.j2 \
  /etc/nginx/conf.d/security-headers.conf

# Update Grist base URL in the file
sudo sed -i 's/{{ grist_base_url }}/https:\/\/your-grist-domain.com/g' \
  /etc/nginx/conf.d/security-headers.conf
```

### Step 3: Update Main Nginx Config

Edit `/etc/nginx/sites-available/odalisque`:

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # Include security headers
    include /etc/nginx/conf.d/security-headers.conf;

    # Rate limiting
    location /api/login {
        limit_req zone=auth burst=5 nodelay;
        proxy_pass http://localhost:8080;
    }

    location /api/ {
        limit_req zone=api burst=20 nodelay;
        proxy_pass http://localhost:8080;
    }

    location / {
        limit_req zone=general burst=10 nodelay;
        proxy_pass http://localhost:8080;
    }

    # Logging
    access_log /var/log/nginx/odalisque_access.log;
    error_log /var/log/nginx/odalisque_error.log;
}
```

### Step 4: Test and Reload

```bash
# Test nginx configuration
sudo nginx -t

# If OK, reload nginx
sudo systemctl reload nginx

# Verify security headers
curl -I https://your-domain.com | grep -E "Content-Security|Strict-Transport|X-Frame"
```

**Expected Output**:
```
Content-Security-Policy: default-src 'self'; ...
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
```

---

## Certificate Pinning Setup

### Step 1: Extract Certificate Fingerprint

Already done in Nginx Security Headers step. Use that fingerprint.

### Step 2: Configure in App

Update `app_config.yaml`:

```yaml
security:
  certificate_pinning:
    enabled: true
    hostname: your-grist-domain.com
    fingerprints:
      - "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99"
```

### Step 3: Build with Pinning

```bash
cd flutter-module

# Build production release with pinning
./build_production.sh --android
```

### Step 4: Test Certificate Validation

```bash
# Test with valid certificate (should work)
flutter run --release

# Test with MITM proxy (should fail)
# Set up mitmproxy and configure app to use it
# Certificate pinning should block the connection
```

---

## MFA Configuration

### Step 1: Enable MFA Enforcement

Update `app_config.yaml`:

```yaml
security:
  mfa:
    enforce_for_admins: true
    enforce_for_all: false  # Set to true for all users
    setup_grace_period_days: 7
    recovery_codes_count: 10
```

### Step 2: Create MFA Setup Flow

Ensure MFA setup is accessible:

```yaml
pages:
  - id: security_settings
    title: Security Settings
    type: settings
    sections:
      - title: Two-Factor Authentication
        fields:
          - id: mfa_status
            type: info
            label: MFA Status
          - id: enable_mfa
            type: action
            label: Enable MFA
            action: navigate_to_mfa_setup
```

### Step 3: Test MFA Flow

1. Login as admin user
2. Navigate to Security Settings
3. Enable MFA
4. Scan QR code
5. Verify code
6. Save recovery codes
7. Logout and login with MFA

**Verification Checklist**:
- [ ] QR code generates correctly
- [ ] TOTP validation works
- [ ] Recovery codes saved
- [ ] MFA login flow smooth
- [ ] Recovery code login works

---

## Token Rotation Setup

### Step 1: Initialize Rotation Service

```bash
# On first deployment, set current key expiry
# This will be automated in future rotations

# Add to app initialization
```

```dart
// In main.dart or app initialization
final rotationService = TokenRotationService(
  baseUrl: gristBaseUrl,
  currentApiKey: currentApiKey,
  docId: gristDocId,
  secureStorage: secureStorage,
  auditLogService: auditLogService,
  rotationInterval: Duration(days: 90),
  gracePeriod: Duration(hours: 24),
);

await rotationService.initialize();
```

### Step 2: Schedule Rotation Checks

Set up daily cron job to check rotation status:

```bash
# Add to crontab
crontab -e

# Add this line (runs daily at 2 AM)
0 2 * * * /opt/odalisque/scripts/check_token_rotation.sh
```

Create the check script:

```bash
#!/bin/bash
# /opt/odalisque/scripts/check_token_rotation.sh

cd /opt/odalisque/flutter-module

# Run rotation check
flutter run lib/scripts/check_rotation.dart

# Log result
echo "$(date): Token rotation check completed" >> /var/log/odalisque/rotation.log
```

### Step 3: Monitor Rotation Status

Add to admin dashboard:

```dart
// In SecurityDashboardPage
final rotationStatus = await rotationService.getRotationStatus();

// Display in UI
Card(
  child: Column(
    children: [
      Text('Token Rotation Status'),
      Text('Status: ${rotationStatus.status}'),
      Text('Days until rotation: ${rotationStatus.daysUntilExpiry}'),
      if (rotationStatus.needsRotation)
        ElevatedButton(
          onPressed: () => _rotateToken(),
          child: Text('Rotate Now'),
        ),
    ],
  ),
)
```

---

## Alert Service Configuration

### Step 1: Gmail Setup (for Email Alerts)

1. Go to Google Account settings
2. Enable 2-Step Verification
3. Generate App Password:
   - Security → 2-Step Verification → App passwords
   - Select app: Mail
   - Select device: Other (Custom name): "Odalisque"
   - Copy generated password

4. Update `.env.production`:
```bash
EMAIL_PASSWORD=your_16_char_app_password
```

### Step 2: Firebase Setup (for Push Notifications)

1. Go to Firebase Console: https://console.firebase.google.com
2. Create project (if not exists)
3. Add Android/iOS apps
4. Download config files:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

5. Get Server Key:
   - Project Settings → Cloud Messaging
   - Copy Server key

6. Update `.env.production`:
```bash
FCM_SERVER_KEY=your_fcm_server_key
```

7. Place config files:
```bash
# Android
cp google-services.json flutter-module/android/app/

# iOS
cp GoogleService-Info.plist flutter-module/ios/Runner/
```

### Step 3: Configure Alert Recipients

Update `.env.production`:

```bash
# Email recipients (comma-separated)
ALERT_RECIPIENTS=admin@yourdomain.com,security@yourdomain.com,cto@yourdomain.com

# Severity threshold (low, medium, high, critical)
ALERT_SEVERITY_THRESHOLD=high

# Daily summary
DAILY_SUMMARY_ENABLED=true
DAILY_SUMMARY_TIME=08:00
DAILY_SUMMARY_TIMEZONE=UTC
```

### Step 4: Test Alert Delivery

```bash
# Send test email alert
curl -X POST http://localhost:8080/api/admin/test-alert \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "test",
    "severity": "high",
    "title": "Test Security Alert",
    "description": "This is a test alert to verify email delivery"
  }'

# Check email inbox
# Should receive alert within 1 minute
```

### Step 5: Set Up Daily Summary

```bash
# Add cron job for daily summary
crontab -e

# Add line (runs at 8 AM daily)
0 8 * * * /opt/odalisque/scripts/send_daily_summary.sh
```

---

## Flutter App Deployment

### Step 1: Build Production Release

```bash
cd flutter-module

# Update version
# Edit pubspec.yaml: version: 0.14.0

# Run production build
./build_production.sh --all

# Or specific platforms
./build_production.sh --android
./build_production.sh --ios
./build_production.sh --web
```

### Step 2: Verify Build

```bash
# Check build artifacts
ls -lh build/app/outputs/flutter-apk/*.apk
ls -lh build/app/outputs/bundle/release/*.aab
ls -lh build/ios/iphoneos/*.app
ls -lh build/web/

# Verify obfuscation
# Symbols should be in separate directory
ls -lh build/app/outputs/symbols/
```

### Step 3: Code Signing

**Android**:
```bash
# Sign APK
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore your-keystore.jks \
  build/app/outputs/flutter-apk/app-release.apk \
  your-key-alias

# Verify signature
jarsigner -verify -verbose -certs \
  build/app/outputs/flutter-apk/app-release.apk
```

**iOS**:
```bash
# Code signing handled by Xcode
# Or via command line:
codesign --force --sign "iPhone Distribution: Your Company" \
  --entitlements path/to/entitlements.plist \
  build/ios/iphoneos/Runner.app
```

### Step 4: Deploy to App Stores

**Google Play**:
```bash
# Upload AAB to Google Play Console
# Or use fastlane:
fastlane supply --aab build/app/outputs/bundle/release/app-release.aab
```

**Apple App Store**:
```bash
# Upload via Xcode or
fastlane deliver
```

**Web**:
```bash
# Deploy to hosting
rsync -avz build/web/ user@your-server:/var/www/odalisque/

# Or deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## Post-Deployment Verification

### Step 1: Smoke Tests

```bash
# Test basic functionality
curl https://your-domain.com/health
# Expected: {"status": "healthy"}

# Test API endpoint
curl https://your-domain.com/api/tables
# Expected: List of tables

# Test security headers
curl -I https://your-domain.com | grep -i "security\|strict\|x-frame"
# Expected: All security headers present
```

### Step 2: Security Verification

**Test MFA**:
1. Login as admin
2. Set up MFA
3. Logout and login with MFA
4. Verify recovery code works

**Test Rate Limiting**:
```bash
# Attempt 10 rapid logins
for i in {1..10}; do
  curl -X POST https://your-domain.com/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test@test.com","password":"wrong"}' \
    -w "\nStatus: %{http_code}\n"
done

# Should see rate limiting kick in
```

**Test Audit Logging**:
1. Perform various actions
2. Check Grist AuditLogs table
3. Verify all events logged

**Test Alerts**:
1. Trigger security event (e.g., 10 failed logins)
2. Check email inbox
3. Verify alert received

### Step 3: Performance Testing

```bash
# Load test
ab -n 1000 -c 10 https://your-domain.com/api/tables/Products/records

# Expected:
# - Requests per second: > 50
# - Time per request: < 200ms
# - No failed requests
```

### Step 4: Monitoring Checks

```bash
# Check logs for errors
tail -f /var/log/nginx/odalisque_error.log
tail -f /var/log/odalisque/app.log

# Check system resources
htop
df -h
free -m

# Check security dashboard
# Navigate to https://your-domain.com/admin/security
# Verify all metrics showing correctly
```

---

## Monitoring Setup

### Step 1: Log Aggregation

Set up centralized logging:

```bash
# Install log aggregation
sudo apt-get install filebeat

# Configure filebeat
sudo vi /etc/filebeat/filebeat.yml
```

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/nginx/odalisque_*.log
      - /var/log/odalisque/app.log
      - /var/log/odalisque/security.log

output.elasticsearch:
  hosts: ["your-elasticsearch:9200"]
```

### Step 2: Metrics Collection

```bash
# Install Prometheus exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-*.tar.gz
sudo cp node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

# Create systemd service
sudo vi /etc/systemd/system/node_exporter.service
```

```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```

### Step 3: Uptime Monitoring

Configure uptime checks:

```bash
# Add to cron
*/5 * * * * /opt/odalisque/scripts/uptime_check.sh
```

```bash
#!/bin/bash
# /opt/odalisque/scripts/uptime_check.sh

URL="https://your-domain.com/health"
ALERT_EMAIL="admin@yourdomain.com"

if ! curl -f -s -o /dev/null "$URL"; then
  echo "ALERT: Odalisque is down!" | mail -s "Odalisque Down" "$ALERT_EMAIL"
fi
```

### Step 4: Security Monitoring

Daily security report:

```bash
# Add to cron (daily at 9 AM)
0 9 * * * /opt/odalisque/scripts/security_report.sh
```

```bash
#!/bin/bash
# /opt/odalisque/scripts/security_report.sh

# Check failed logins
FAILED_LOGINS=$(psql -U odalisque -d odalisque -t -c \
  "SELECT COUNT(*) FROM AuditLogs WHERE action='LOGIN_FAILED' AND timestamp > NOW() - INTERVAL '24 hours'")

# Check rate limit violations
RATE_LIMIT_VIOLATIONS=$(psql -U odalisque -d odalisque -t -c \
  "SELECT COUNT(*) FROM AuditLogs WHERE action='RATE_LIMIT_EXCEEDED' AND timestamp > NOW() - INTERVAL '24 hours'")

echo "Daily Security Report - $(date)" > /tmp/security_report.txt
echo "Failed Logins (24h): $FAILED_LOGINS" >> /tmp/security_report.txt
echo "Rate Limit Violations (24h): $RATE_LIMIT_VIOLATIONS" >> /tmp/security_report.txt

mail -s "Daily Security Report" admin@yourdomain.com < /tmp/security_report.txt
```

---

## Rollback Procedures

### If Issues Occur During Deployment

**Step 1: Immediate Rollback**

```bash
# Stop current version
sudo systemctl stop odalisque

# Restore previous version
sudo cp /opt/odalisque/backups/app-v0.13.0.tar.gz /opt/odalisque/
cd /opt/odalisque
tar xzf app-v0.13.0.tar.gz

# Restore configuration
sudo cp /opt/odalisque/backups/.env.v0.13.0 /opt/odalisque/.env

# Restart
sudo systemctl start odalisque
```

**Step 2: Restore Database**

```bash
# Restore Grist backup
docker-compose down
sudo cp /opt/odalisque/backups/grist-data-2024-01-15.tar.gz /opt/odalisque/grist-data/
cd /opt/odalisque/grist-data
tar xzf grist-data-2024-01-15.tar.gz
docker-compose up -d
```

**Step 3: Restore Nginx Config**

```bash
# Restore previous nginx config
sudo cp /opt/odalisque/backups/nginx-odalisque.conf /etc/nginx/sites-available/odalisque
sudo nginx -t
sudo systemctl reload nginx
```

**Step 4: Verify Rollback**

```bash
# Check app version
curl https://your-domain.com/api/version
# Should show v0.13.0

# Test basic functionality
# Login, view data, etc.
```

### Post-Rollback Analysis

1. Review deployment logs
2. Identify root cause
3. Fix issues in staging
4. Re-test thoroughly
5. Plan new deployment

---

## Deployment Checklist

### Pre-Deployment (1 week before)

- [ ] All Phase 2 features tested in staging
- [ ] Security tests passed
- [ ] Performance tests passed
- [ ] Backup system verified
- [ ] Rollback procedure documented
- [ ] Team trained on new features
- [ ] Change request approved
- [ ] Maintenance window scheduled
- [ ] Stakeholders notified

### Deployment Day (D-Day)

**1 Hour Before**:
- [ ] Final backup completed
- [ ] Team on standby
- [ ] Monitoring tools ready
- [ ] Communication channels open

**During Deployment**:
- [ ] Enable maintenance mode
- [ ] Deploy Grist table changes
- [ ] Deploy nginx configuration
- [ ] Deploy Flutter app
- [ ] Run database migrations
- [ ] Configure security services
- [ ] Test basic functionality
- [ ] Disable maintenance mode

**Immediately After**:
- [ ] Smoke tests passed
- [ ] Security verification complete
- [ ] Performance acceptable
- [ ] Error logs clean
- [ ] Monitoring active
- [ ] Team notified of success

### Post-Deployment (24 hours)

- [ ] Monitor error rates
- [ ] Monitor performance
- [ ] Check security alerts
- [ ] Verify MFA working
- [ ] Verify token rotation scheduled
- [ ] Verify certificate pinning active
- [ ] User feedback collected
- [ ] Documentation updated

### Week 1 After Deployment

- [ ] No critical issues reported
- [ ] Performance stable
- [ ] Security metrics normal
- [ ] User adoption increasing
- [ ] Team comfortable with features
- [ ] Monitoring dashboards reviewed
- [ ] Stakeholders updated

---

## Support & Troubleshooting

### Common Issues

**Issue: MFA setup fails**
- Check: TOTP secret generation
- Verify: Time sync on server
- Test: Manual secret entry

**Issue: Token rotation fails**
- Check: Grist API permissions
- Verify: APIKeys table exists
- Test: Manual token creation

**Issue: Alerts not sending**
- Check: Email credentials
- Verify: FCM server key
- Test: Send test alert

**Issue: Certificate pinning blocks connections**
- Check: Fingerprint matches
- Verify: SSL certificate valid
- Test: Disable pinning temporarily

### Getting Help

- **Documentation**: See SECURITY_PHASE2.md
- **Testing**: See SECURITY_TESTING.md
- **Issues**: GitHub Issues
- **Emergency**: Contact DevOps team

---

## Success Criteria

Deployment is successful when:

✅ All smoke tests passed
✅ Security verification complete
✅ Performance acceptable (< 200ms avg)
✅ Error rate < 1%
✅ MFA working for admins
✅ Token rotation scheduled
✅ Alerts configured and tested
✅ Certificate pinning active
✅ Monitoring operational
✅ Team trained
✅ Documentation complete

---

**Last Updated**: 2024-01-16
**Version**: 0.14.0
**Next Review**: After first production deployment

**Prepared by**: Claude AI Assistant
**Approved by**: [Your Name]
