# Odalisque Security Documentation - Phase 2 Enhancements

## Version 0.14.0 - Enhanced Security Features

---

## Phase 2: Enhanced Security ✅

### Implementation Status

- ✅ Multi-Factor Authentication (TOTP)
- ✅ Recovery codes for account recovery
- ✅ Token rotation service (90-day automatic rotation)
- ✅ Certificate pinning for HTTPS connections
- ✅ Security alert service (email & push notifications)
- ✅ Enhanced security headers (CSP, HSTS, etc.)
- ✅ Intrusion detection patterns

---

## Multi-Factor Authentication (MFA)

### Overview

TOTP-based two-factor authentication compatible with Google Authenticator, Authy, and Microsoft Authenticator.

### Features

1. **TOTP Generation & Validation**
   - 6-digit codes refreshing every 30 seconds
   - SHA-1 algorithm (Google Authenticator compatible)
   - Clock drift tolerance (±1 window)

2. **QR Code Setup**
   - Automatic QR code generation
   - Manual secret key entry option
   - Step-by-step setup wizard

3. **Recovery Codes**
   - 10 single-use recovery codes
   - Hashed storage (SHA-256)
   - Regeneration capability

4. **Enforcement Policies**
   - Mandatory for admin accounts (configurable)
   - Optional for regular users
   - Grace period for setup

### Setup Instructions

```dart
// Initialize MFA service
final mfaService = MFAService(
  secureStorage: SecureStorageService(),
  auditLogService: auditLogService,
);

// Setup MFA for a user
final setupData = await mfaService.setupMFA(
  userId: userId,
  username: username,
  issuer: 'Odalisque',
);

// Display QR code to user
showQRCode(setupData.qrCodeData);

// Verify and enable MFA
final success = await mfaService.enableMFA(
  userId: userId,
  username: username,
  verificationCode: userEnteredCode,
);
```

### User Experience

**Setup Flow**:
1. User navigates to Settings → Security → Enable MFA
2. Scan QR code with authenticator app
3. Enter verification code to confirm setup
4. Save recovery codes in a safe place
5. MFA is now active

**Login Flow with MFA**:
1. Enter username and password
2. Enter 6-digit MFA code
3. Login successful

**Using Recovery Code**:
- If authenticator app is lost, use a recovery code instead of TOTP
- Each recovery code can only be used once
- Remaining codes shown in security settings

### Security Considerations

- **Secret Storage**: MFA secrets stored in platform-encrypted secure storage
- **Recovery Codes**: Hashed with SHA-256, single-use
- **Brute Force Protection**: Rate limiting applies to MFA attempts
- **Audit Logging**: All MFA events logged (setup, login, disable)

### MFA Enforcement

```yaml
security:
  mfa:
    enforce_for_admins: true
    enforce_for_all: false
    setup_grace_period_days: 7
```

---

## Token Rotation

### Overview

Automatic rotation of API keys to minimize the impact of key compromise.

### Features

1. **Scheduled Rotation**
   - Default: 90-day rotation interval
   - Automatic rotation 7 days before expiry
   - Manual rotation capability

2. **Grace Period**
   - 24-hour grace period where both old and new keys work
   - Prevents service interruption
   - Automatic cleanup after grace period

3. **Rotation Monitoring**
   - Days until next rotation
   - Rotation history in audit logs
   - Expiry warnings

### Configuration

```dart
final tokenRotationService = TokenRotationService(
  baseUrl: gristBaseUrl,
  currentApiKey: apiKey,
  docId: gristDocId,
  secureStorage: secureStorage,
  auditLogService: auditLogService,
  rotationInterval: Duration(days: 90),
  gracePeriod: Duration(hours: 24),
);

// Initialize and start automatic rotation
await tokenRotationService.initialize();

// Manual rotation (admin action)
final result = await tokenRotationService.rotateToken(
  force: true,
  adminUsername: 'admin@example.com',
);

// Check rotation status
final status = await tokenRotationService.getRotationStatus();
print('Days until rotation: ${status.daysUntilExpiry}');
```

### Rotation Process

1. Check if rotation is due (< 7 days until expiry)
2. Generate new API key (cryptographically secure)
3. Store previous key for grace period
4. Update key in Grist
5. Update secure storage with new key
6. Log rotation event
7. Schedule grace period cleanup

### Monitoring

**Security Dashboard** shows:
- Current API key status (valid, expiring soon, expired)
- Days until next rotation
- Last rotation date
- Grace period status

---

## Certificate Pinning

### Overview

SSL certificate pinning prevents Man-in-the-Middle (MITM) attacks by validating server certificates.

### Features

1. **SHA-256 Fingerprint Pinning**
   - Pin specific certificates by fingerprint
   - Support for multiple fingerprints (for rotation)
   - Automatic validation on every HTTPS request

2. **Certificate Rotation Support**
   - Add new fingerprint before rotation
   - Remove old fingerprint after rotation
   - Zero-downtime rotation

3. **Failure Detection**
   - Immediate alert on pinning failure
   - Audit log entry with details
   - Connection blocked on validation failure

### Setup

**1. Get Certificate Fingerprint**

```bash
# Using OpenSSL
openssl s_client -connect your-grist-domain.com:443 < /dev/null \
  | openssl x509 -fingerprint -sha256 -noout

# Output: SHA256 Fingerprint=AA:BB:CC:DD:...
```

**2. Configure Pinning**

```dart
final certPinningService = CertificatePinningService(
  hostname: 'your-grist-domain.com',
  sha256Fingerprints: [
    'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99',
  ],
  auditLogService: auditLogService,
  allowBadCertificates: false, // Set to true ONLY in development
);

// Use pinned HTTP client
final client = certPinningService.client;
final response = await client.get(Uri.parse('https://your-grist-domain.com/api/...'));
```

**3. Certificate Rotation**

```dart
// Before rotating certificate on server:
// 1. Add new certificate fingerprint
certPinningService.addFingerprint(newFingerprint);

// 2. Rotate certificate on server

// 3. After grace period, remove old fingerprint
certPinningService.removeFingerprint(oldFingerprint);
```

### Validation

```dart
// Validate certificate for a URL
final result = await certPinningService.validateCertificate(
  'https://your-grist-domain.com',
);

if (!result.isValid) {
  // Handle pinning failure
  if (result.isCertificateError) {
    // CRITICAL: Possible MITM attack!
    showSecurityAlert();
  }
}
```

---

## Security Alert Service

### Overview

Real-time security event notifications via email and push notifications.

### Features

1. **Email Alerts**
   - HTML-formatted security alerts
   - Daily security summaries
   - Customizable templates
   - SMTP/Gmail support

2. **Push Notifications**
   - Firebase Cloud Messaging (FCM)
   - Critical alerts on mobile devices
   - Custom notification data

3. **Alert Throttling**
   - Prevent notification spam
   - 1-hour throttle window (configurable)
   - Force send capability

4. **Severity Filtering**
   - Only send alerts above threshold
   - Critical, high, medium, low levels

### Configuration

**Email Alerts**:

```dart
// Gmail configuration
final emailConfig = EmailAlertConfig.gmail(
  email: 'security@yourdomain.com',
  appPassword: 'your-app-password', // Gmail App Password
  name: 'Odalisque Security',
);

// SMTP configuration
final emailConfig = EmailAlertConfig.smtp(
  host: 'smtp.yourdomain.com',
  port: 587,
  email: 'security@yourdomain.com',
  username: 'security@yourdomain.com',
  password: 'your-password',
  useSsl: true,
);
```

**Push Notifications**:

```dart
final pushConfig = PushNotificationConfig(
  fcmServerKey: 'your-fcm-server-key',
);
```

**Alert Service**:

```dart
final alertService = SecurityAlertService(
  emailConfig: emailConfig,
  pushConfig: pushConfig,
  auditLogService: auditLogService,
  throttleDuration: Duration(hours: 1),
);
```

### Usage

**Send Individual Alert**:

```dart
await alertService.sendAlert(
  alert: securityAlert,
  emailRecipients: ['admin@example.com'],
  pushTokens: ['fcm-device-token'],
);
```

**Send Batch Alerts**:

```dart
await alertService.sendAlerts(
  alerts: securityAlerts,
  emailRecipients: ['admin@example.com'],
  pushTokens: ['fcm-device-token'],
  severityThreshold: 'high', // Only send high and critical
);
```

**Daily Summary**:

```dart
await alertService.sendDailySummary(
  summary: dashboardSummary,
  alerts: todaysAlerts,
  emailRecipients: ['admin@example.com'],
);
```

### Alert Types

- `brute_force_attempt` - Multiple failed logins from IP
- `suspicious_activity` - Unusual user behavior detected
- `rate_limit_exceeded` - API abuse detected
- `certificate_pinning_failure` - Possible MITM attack
- `account_locked` - Account locked due to failed attempts
- `mfa_disabled` - MFA was disabled for account
- `api_key_rotated` - API key was rotated
- `unauthorized_access` - Access attempt without permission

### Email Templates

Alerts include:
- Color-coded severity headers
- Alert details and metadata
- Recommended actions
- Timestamp and alert ID
- Links to security dashboard (future)

---

## Enhanced Security Headers

### Overview

Comprehensive HTTP security headers configured in nginx to prevent common web vulnerabilities.

### Headers Implemented

1. **Content-Security-Policy (CSP)**
   - Prevents XSS attacks
   - Controls resource loading
   - Blocks inline scripts (with exceptions for Flutter)

2. **X-Frame-Options: DENY**
   - Prevents clickjacking attacks
   - Blocks iframe embedding

3. **X-Content-Type-Options: nosniff**
   - Prevents MIME-sniffing attacks
   - Forces correct content type

4. **X-XSS-Protection: 1; mode=block**
   - Enables browser XSS filter
   - Legacy browser protection

5. **Strict-Transport-Security (HSTS)**
   - Forces HTTPS connections
   - 1-year max-age
   - Includes subdomains
   - Preload ready

6. **Referrer-Policy: strict-origin-when-cross-origin**
   - Controls referrer information
   - Privacy protection

7. **Permissions-Policy**
   - Disables unused browser features
   - Geolocation, camera, microphone, etc.

8. **Cross-Origin-*-Policy Headers**
   - COOP, COEP, CORP for resource isolation
   - Enhanced security boundary

### nginx Configuration

Located at: `deployment-module/roles/security/templates/security-headers.conf.j2`

**Rate Limiting Zones**:
- General: 100 requests/minute
- API: 200 requests/minute
- Auth: 10 requests/minute

**Connection Limits**:
- Max 10 concurrent connections per IP

**Timeout Configuration**:
- Client header timeout: 10s
- Client body timeout: 10s
- Send timeout: 10s
- Keepalive timeout: 65s

### Deployment

```bash
# Deploy security headers configuration
ansible-playbook -i inventory deploy-security-headers.yml

# Test configuration
nginx -t

# Reload nginx
systemctl reload nginx
```

### Validation

**Check Headers**:

```bash
curl -I https://your-domain.com

# Should see security headers:
# Content-Security-Policy: ...
# Strict-Transport-Security: ...
# X-Frame-Options: DENY
# etc.
```

**Security Scanner**:

```bash
# Use Mozilla Observatory
https://observatory.mozilla.org/

# Use SecurityHeaders.com
https://securityheaders.com/
```

Target Score: **A+**

---

## Intrusion Detection

### Overview

Pattern-based intrusion detection integrated with security monitoring.

### Detection Patterns

1. **Brute Force Detection**
   - 10+ failed logins from same IP in 24h
   - Automatic IP blocking
   - Alert sent to admins

2. **Suspicious Activity Detection**
   - Multiple IP addresses for same user
   - Unusual time-of-day access
   - Geographic anomalies (future)

3. **API Abuse Detection**
   - Exceeds rate limits
   - Unusual endpoint patterns
   - Rapid sequential requests

4. **Account Compromise Indicators**
   - Password change after failed logins
   - MFA disabled unexpectedly
   - Role elevation attempts

### Automated Responses

- **Brute Force**: Lock account, block IP
- **API Abuse**: Rate limit, temporary ban
- **Suspicious Activity**: Alert admin, require re-authentication
- **Account Compromise**: Force password reset, enable MFA

---

## Compliance

### OWASP Top 10 Coverage

1. **A01:2021 - Broken Access Control** ✅
   - Role-based access control
   - Server-side authorization
   - Audit logging

2. **A02:2021 - Cryptographic Failures** ✅
   - Encrypted storage
   - HTTPS only
   - Certificate pinning
   - Bcrypt password hashing

3. **A03:2021 - Injection** ✅
   - Parameterized queries
   - Input validation
   - CSP headers

4. **A04:2021 - Insecure Design** ✅
   - Threat modeling
   - Security by design
   - Defense in depth

5. **A05:2021 - Security Misconfiguration** ✅
   - Secure defaults
   - Security headers
   - Error handling

6. **A06:2021 - Vulnerable Components** ✅
   - Dependency scanning
   - Regular updates
   - Version pinning

7. **A07:2021 - Authentication Failures** ✅
   - MFA support
   - Account lockout
   - Session management
   - Rate limiting

8. **A08:2021 - Software Integrity Failures** ✅
   - Code obfuscation
   - Integrity checks
   - Secure updates

9. **A09:2021 - Logging Failures** ✅
   - Comprehensive audit logs
   - Tamper-proof storage
   - Real-time alerts

10. **A10:2021 - SSRF** ✅
    - Input validation
    - URL whitelisting
    - Network segmentation

### Additional Compliance

- **GDPR**: Audit logs, data export, right to deletion
- **PCI DSS**: Strong authentication, encryption, audit trails
- **SOC 2**: Security monitoring, incident response, access controls
- **HIPAA**: Encryption, audit logs, access controls (if applicable)

---

## Migration Guide: v0.13.0 → v0.14.0

### Breaking Changes

None - fully backwards compatible

### New Features to Enable

1. **Enable MFA for Admin Accounts**

```dart
// In app initialization
if (user.role == 'admin') {
  final mfaEnabled = await mfaService.isMFAEnabled(user.id);
  if (!mfaEnabled) {
    showMFASetupPrompt();
  }
}
```

2. **Configure Token Rotation**

```dart
// Initialize rotation service
final rotationService = TokenRotationService(...);
await rotationService.initialize();
```

3. **Setup Certificate Pinning**

```dart
// Get certificate fingerprint
final fingerprint = await CertificateFingerprintExtractor.getFingerprint(
  gristBaseUrl,
);

// Configure pinning
final certPinning = CertificatePinningService(
  hostname: gristDomain,
  sha256Fingerprints: [fingerprint],
);
```

4. **Enable Security Alerts**

```dart
// Configure email alerts
final alertService = SecurityAlertService(
  emailConfig: EmailAlertConfig.gmail(...),
);

// Send test alert
await alertService.sendAlert(...);
```

### Configuration Updates

**Add to `app_config.yaml`**:

```yaml
security:
  mfa:
    enforce_for_admins: true
    enforce_for_all: false
    setup_grace_period_days: 7

  token_rotation:
    enabled: true
    interval_days: 90
    grace_period_hours: 24

  alerts:
    email_enabled: true
    push_enabled: true
    severity_threshold: "high"
    daily_summary: true

  certificate_pinning:
    enabled: true
    allow_bad_certs: false # Only true in development
```

---

## Changelog: v0.14.0

### Added

- Multi-factor authentication (TOTP) with QR code setup
- Recovery codes for MFA account recovery
- Automatic API key rotation (90-day default)
- Certificate pinning for HTTPS connections
- Security alert service (email & push notifications)
- Enhanced nginx security headers
- Intrusion detection patterns
- Daily security summary emails

### Dependencies Added

- `otp: ^3.1.4` - TOTP generation
- `qr_flutter: ^4.1.0` - QR code generation
- `pin_code_fields: ^8.0.1` - MFA code input
- `mailer: ^6.0.1` - Email alerts
- `firebase_messaging: ^14.7.9` - Push notifications
- `uuid: ^4.2.2` - Token generation

---

**Last Updated**: 2024-01-16
**Version**: 0.14.0
**Status**: Phase 2 Complete
