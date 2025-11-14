# Odalisque Security Documentation v0.13.0

## Overview

Odalisque v0.13.0 introduces comprehensive production security hardening with a focus on data protection, authentication security, and threat monitoring. This document describes all security features, best practices, and operational procedures.

---

## Table of Contents

1. [Phase 1: Critical Security Fixes](#phase-1-critical-security-fixes)
2. [Secure Storage](#secure-storage)
3. [Authentication Security](#authentication-security)
4. [Audit Logging](#audit-logging)
5. [Rate Limiting](#rate-limiting)
6. [Security Monitoring Dashboard](#security-monitoring-dashboard)
7. [Production Build Security](#production-build-security)
8. [Certificate Pinning](#certificate-pinning)
9. [Grist Table Setup](#grist-table-setup)
10. [Best Practices](#best-practices)
11. [Incident Response](#incident-response)

---

## Phase 1: Critical Security Fixes

### Implementation Status ✅

- ✅ Secure encrypted storage for sensitive data
- ✅ Server-side rate limiting and account lockout
- ✅ Comprehensive audit logging to Grist backend
- ✅ Code obfuscation for production builds
- ✅ Security monitoring dashboard
- ⏳ Certificate pinning (ready for configuration)

---

## Secure Storage

### Overview

Replaced `SharedPreferences` with `flutter_secure_storage` for all sensitive data storage.

### Features

- **Platform-Specific Encryption**:
  - iOS: Keychain
  - Android: Keystore with AES-256-GCM
  - Biometric protection support

- **Encrypted Data**:
  - User credentials (email, role)
  - API keys and tokens
  - Session data
  - MFA secrets (when enabled)

### Implementation

```dart
import 'package:odalisque/src/services/secure_storage_service.dart';

final storage = SecureStorageService();
await storage.initialize();

// Store sensitive data
await storage.write(SecureStorageKeys.gristApiKey, apiKey);

// Retrieve data
final apiKey = await storage.read(SecureStorageKeys.gristApiKey);

// Delete data
await storage.delete(SecureStorageKeys.gristApiKey);
```

### Storage Keys

All storage keys are defined in `SecureStorageKeys` class:

- `userEmail`, `userRole` - User identity
- `authToken`, `sessionToken` - Authentication tokens
- `gristApiKey` - API authentication
- `mfaSecret`, `mfaEnabled` - MFA configuration
- `lastActivityTimestamp` - Session management

### Migration

The system automatically migrates data from `SharedPreferences` to secure storage on first launch of v0.13.0.

---

## Authentication Security

### Features

1. **Bcrypt Password Hashing**
   - Salt rounds: 10
   - No plaintext password storage

2. **Account Lockout**
   - Max failed attempts: 5
   - Lockout duration: 15 minutes
   - Server-side tracking (not client-side)
   - IP-based and user-based lockout

3. **Session Management**
   - Configurable timeout (default: 60 minutes)
   - Auto-logout on inactivity
   - Secure session token storage
   - Activity tracking

### Rate Limiting Configuration

```yaml
security:
  rate_limiting:
    max_failed_attempts: 5
    lockout_duration_minutes: 15
    rate_limit_window_minutes: 1
    max_requests_per_window: 100
```

### Implementation

```dart
// Initialize security services
final rateLimitService = RateLimitService(
  baseUrl: gristBaseUrl,
  apiKey: gristApiKey,
  docId: gristDocId,
  maxFailedAttempts: 5,
  lockoutDuration: Duration(minutes: 15),
);

final auditLogService = AuditLogService(
  baseUrl: gristBaseUrl,
  apiKey: gristApiKey,
  docId: gristDocId,
);

// Create AuthProvider with security services
final authProvider = AuthProvider(
  gristService: gristService,
  authSettings: authSettings,
  auditLogService: auditLogService,
  rateLimitService: rateLimitService,
);

// Login with IP tracking
await authProvider.login(
  email,
  password,
  ipAddress: userIpAddress,
);
```

---

## Audit Logging

### Overview

All security events are logged to a Grist table for compliance, forensics, and monitoring.

### Logged Events

**Authentication Events**:
- `LOGIN_SUCCESS` - Successful login
- `LOGIN_FAILED` - Failed login attempt
- `LOGOUT` - User logout
- `ACCOUNT_LOCKED` - Account locked due to failed attempts
- `ACCOUNT_UNLOCKED` - Admin unlocked account
- `PASSWORD_RESET` - Password reset initiated
- `PASSWORD_CHANGED` - Password changed

**Data Operations**:
- `CREATE`, `READ`, `UPDATE`, `DELETE` - CRUD operations
- `EXPORT`, `IMPORT` - Data transfer operations

**Admin Actions**:
- `USER_CREATED`, `USER_UPDATED`, `USER_DELETED`
- `ROLE_CHANGED`, `PERMISSION_CHANGED`
- `CONFIG_CHANGED`

**Security Events**:
- `SUSPICIOUS_ACTIVITY` - Anomaly detected
- `BRUTE_FORCE_ATTEMPT` - Multiple failed logins
- `UNAUTHORIZED_ACCESS` - Access without permission
- `RATE_LIMIT_EXCEEDED` - Too many requests

### Log Structure

Each log entry contains:

```json
{
  "timestamp": "2024-01-15T10:30:45Z",
  "action": "LOGIN_FAILED",
  "resource": "authentication",
  "username": "user@example.com",
  "user_id": "123",
  "success": false,
  "ip_address": "192.168.1.100",
  "device_fingerprint": "abc123...",
  "user_agent": "Mozilla/5.0...",
  "metadata": {
    "reason": "Invalid credentials",
    "attempt_number": 3
  }
}
```

### Usage

```dart
// Log authentication event
await auditLogService.logAuthEvent(
  action: AuditActions.loginFailed,
  username: email,
  success: false,
  ipAddress: '192.168.1.100',
  metadata: {'reason': 'Invalid credentials'},
);

// Log data operation
await auditLogService.logDataOperation(
  action: AuditActions.update,
  resource: 'products',
  username: currentUser.email,
  recordId: '123',
  changes: {'price': 29.99},
);

// Query audit logs
final logs = await auditLogService.getAuditLogs(
  username: 'user@example.com',
  startDate: DateTime.now().subtract(Duration(days: 7)),
  limit: 100,
);
```

### Retention Policy

- Logs stored indefinitely in Grist
- Recommended: Archive logs older than 90 days
- Export capability for compliance requirements

---

## Rate Limiting

### Overview

Server-side rate limiting prevents brute force attacks and API abuse.

### Limits

1. **Login Rate Limiting**
   - 5 failed attempts per user
   - 15-minute lockout
   - IP-based blocking for distributed attacks

2. **API Rate Limiting**
   - 100 requests per minute per user
   - 1000 requests per hour per user
   - Automatic throttling on excess

### Implementation

Rate limits are stored in Grist tables:
- `RateLimits` - Login attempt tracking
- `RateLimits_API` - API request tracking

### Monitoring

```dart
// Check if user is rate limited
final result = await rateLimitService.checkLoginRateLimit(
  identifier: username,
);

if (!result.allowed) {
  // User is locked out
  print('Locked until: ${result.lockedUntil}');
  print('Reason: ${result.reason}');
}

// Manually unlock (admin action)
await rateLimitService.unlockAccount(username);
```

---

## Security Monitoring Dashboard

### Overview

Real-time security monitoring dashboard for administrators.

### Features

1. **Summary Cards**
   - Failed login attempts (24h)
   - Active sessions
   - API requests (1h)
   - Critical/high/medium alerts

2. **Security Alerts**
   - Brute force attempts
   - Suspicious IP activity
   - Multiple IP logins for same user
   - Rate limit violations

3. **Failed Login Tracking**
   - Total attempts
   - Unique IPs and users
   - Top IPs by failed attempts
   - Suspicious IP detection

4. **Active Sessions**
   - Currently logged-in users
   - Last activity timestamp
   - User roles
   - IP addresses

5. **API Usage Patterns**
   - Total requests per hour
   - Average response time
   - Top actions and endpoints
   - Rate limit violations

### Access

The security dashboard is only accessible to users with the `admin` role:

```yaml
pages:
  - id: security_dashboard
    title: Security Dashboard
    type: security_dashboard
    visible_if: "user.role == 'admin'"
```

### Configuration

```yaml
security_monitoring:
  auto_refresh: true
  refresh_interval_seconds: 30
  failed_login_threshold: 10  # Alert threshold
  suspicious_ip_threshold: 20  # IPs with >20 failures
  api_abuse_threshold: 500    # Requests/hour
```

---

## Production Build Security

### Code Obfuscation

All production builds include Dart code obfuscation to prevent reverse engineering.

### Build Script

```bash
# Build for all platforms
./build_production.sh --all

# Build for specific platform
./build_production.sh --android
./build_production.sh --ios
./build_production.sh --web
```

### Android Security

**ProGuard Rules** (`android/app/proguard-rules.pro`):
- Obfuscates class and method names
- Removes debug logging
- Strips debug symbols
- Optimizes bytecode

**Build Configuration**:
```bash
flutter build apk \
  --release \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

### iOS Security

**Build Configuration**:
```bash
flutter build ios \
  --release \
  --obfuscate \
  --split-debug-info=build/ios/symbols
```

### Debug Symbols

Debug symbols are saved separately for crash reporting but NOT included in release builds:
- Android: `build/app/outputs/symbols/`
- iOS: `build/ios/symbols/`

**Store symbols securely** - they're needed to deobfuscate crash reports.

---

## Certificate Pinning

### Overview

Certificate pinning prevents man-in-the-middle attacks by validating SSL certificates.

### Configuration (Planned for Phase 2)

```dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

// Configure pinned certificates
final secureClient = CertificatePinningClient(
  pins: [
    Pin(
      hostname: 'your-grist-domain.com',
      sha256Hashes: [
        'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      ],
    ),
  ],
);
```

### Getting Certificate Fingerprint

```bash
# Get certificate fingerprint
openssl s_client -connect your-grist-domain.com:443 < /dev/null \
  | openssl x509 -fingerprint -noout -sha256
```

---

## Grist Table Setup

### Required Tables

The following Grist tables must be created for security features:

#### 1. AuditLogs Table

| Column | Type | Description |
|--------|------|-------------|
| `timestamp` | DateTime | When event occurred |
| `action` | Text | Action performed (LOGIN_SUCCESS, etc.) |
| `resource` | Text | Resource accessed (authentication, products) |
| `username` | Text | User who performed action |
| `user_id` | Text | User ID |
| `record_id` | Text | Record ID (for data operations) |
| `success` | Toggle | Whether action succeeded |
| `ip_address` | Text | User IP address |
| `device_fingerprint` | Text | Device identifier |
| `user_agent` | Text | Browser/client user agent |
| `metadata` | Text | JSON metadata |

#### 2. RateLimits Table

| Column | Type | Description |
|--------|------|-------------|
| `identifier` | Text | Username or IP address |
| `is_ip_based` | Toggle | Whether this is IP-based limiting |
| `failed_attempts` | Integer | Number of failed attempts |
| `last_failed_at` | DateTime | Last failed attempt timestamp |
| `locked_until` | DateTime | When lockout expires |
| `metadata` | Text | Additional information |

#### 3. RateLimits_API Table

| Column | Type | Description |
|--------|------|-------------|
| `identifier` | Text | User ID or IP address |
| `request_count` | Integer | Number of requests in window |
| `window_start` | DateTime | Window start time |
| `metadata` | Text | Endpoint information |

### Grist Permissions

- **AuditLogs**: Write-only for app, Read for admins
- **RateLimits**: Read/write for app
- **RateLimits_API**: Read/write for app

---

## Best Practices

### Development

1. **Never commit secrets**
   - Use `.env` files (gitignored)
   - Use environment variables
   - Run `gitleaks` before commits

2. **Test security features**
   - Test rate limiting
   - Test account lockout
   - Test audit logging
   - Verify secure storage

3. **Code reviews**
   - Review for security vulnerabilities
   - Check for hardcoded credentials
   - Validate input sanitization

### Production

1. **Environment separation**
   - Separate dev/staging/prod Grist instances
   - Different API keys per environment
   - Isolated user databases

2. **SSL/TLS**
   - Use HTTPS only
   - Valid SSL certificates
   - Certificate pinning enabled
   - HSTS headers configured

3. **API keys**
   - Rotate API keys regularly (every 90 days)
   - Use least-privilege access
   - Monitor API key usage
   - Revoke compromised keys immediately

4. **Monitoring**
   - Check security dashboard daily
   - Review audit logs weekly
   - Monitor failed login attempts
   - Alert on suspicious activity

5. **Backups**
   - Daily encrypted backups
   - Store backups securely offsite
   - Test restore process monthly
   - Include audit logs in backups

### User Management

1. **Strong passwords**
   - Minimum 12 characters
   - Require special characters
   - Password complexity validation
   - Prevent common passwords

2. **Role-based access**
   - Principle of least privilege
   - Regular access reviews
   - Remove inactive accounts
   - Separate admin accounts

3. **Account security**
   - Enable MFA (Phase 2)
   - Monitor for account compromise
   - Force password resets on suspicious activity
   - Lock accounts after 90 days inactivity

---

## Incident Response

### Suspected Breach

1. **Immediate actions**:
   - Lock all affected accounts
   - Rotate all API keys
   - Review audit logs for suspicious activity
   - Preserve logs for forensics

2. **Investigation**:
   - Identify entry point
   - Determine scope of breach
   - Check for data exfiltration
   - Document timeline

3. **Remediation**:
   - Patch vulnerabilities
   - Force password resets
   - Enable additional monitoring
   - Notify affected users (if required)

### Brute Force Attack

1. **Detection**: Security dashboard shows high failed login attempts
2. **Action**: IP is automatically blocked after 5 attempts
3. **Response**: Review audit logs for patterns
4. **Prevention**: Consider adding IP whitelist for admin accounts

### API Abuse

1. **Detection**: Rate limit violations in monitoring dashboard
2. **Action**: Automatic throttling applies
3. **Response**: Investigate user/IP for abuse
4. **Prevention**: Lower rate limits if needed

### Account Compromise

1. **Detection**: Multiple IP logins, unusual activity patterns
2. **Action**: Lock account immediately
3. **Response**: Contact user, verify legitimate activity
4. **Remediation**: Force password reset, review recent actions

---

## Support & Contact

For security issues or questions:

1. **Security vulnerabilities**: Report via GitHub Security Advisories
2. **General security questions**: See GitHub Issues
3. **Production incidents**: Follow incident response procedures

---

## Changelog

### v0.13.0 (Current)

**Phase 1 Security Enhancements**:
- ✅ Secure encrypted storage (flutter_secure_storage)
- ✅ Server-side rate limiting and account lockout
- ✅ Comprehensive audit logging to Grist
- ✅ Security monitoring dashboard
- ✅ Code obfuscation for production builds
- ✅ ProGuard configuration for Android
- ✅ Automatic migration from SharedPreferences

**Coming in Phase 2**:
- Multi-factor authentication (TOTP)
- Certificate pinning
- Token rotation
- Enhanced security headers
- Intrusion detection
- Security alerting system

---

## Compliance

Odalisque v0.13.0 security features support:

- **OWASP Top 10** compliance
- **GDPR** readiness (audit logs, data export)
- **SOC 2** audit trail requirements
- **PCI DSS** authentication controls

For specific compliance requirements, consult with your security team.

---

**Last Updated**: 2024-01-15
**Version**: 0.13.0
**Status**: Phase 1 Complete
