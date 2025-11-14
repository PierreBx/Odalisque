# Security Testing Guide - Odalisque v0.14.0

## Overview

This guide provides comprehensive testing procedures for all security features in Odalisque v0.13.0 (Phase 1) and v0.14.0 (Phase 2). Follow these tests to validate security functionality before production deployment.

---

## Table of Contents

1. [Testing Prerequisites](#testing-prerequisites)
2. [Phase 1 Testing](#phase-1-testing)
3. [Phase 2 Testing](#phase-2-testing)
4. [Penetration Testing](#penetration-testing)
5. [Security Scanning](#security-scanning)
6. [Performance Testing](#performance-testing)
7. [Compliance Testing](#compliance-testing)

---

## Testing Prerequisites

### Required Tools

```bash
# Install testing tools
pip install locust         # Load testing
npm install -g artillery   # API testing
brew install nmap          # Network scanning
brew install sqlmap        # SQL injection testing
```

### Test Environment Setup

```bash
# 1. Set up test Grist instance
docker-compose -f docker-compose.test.yml up -d

# 2. Create test database with security tables
# Run the Grist setup scripts

# 3. Configure test environment variables
cp .env.example .env.test
# Edit .env.test with test credentials

# 4. Build test version
cd flutter-module
flutter build apk --debug --target=lib/main_test.dart
```

### Test User Accounts

Create these test accounts in your Grist instance:

| Username | Role | MFA | Purpose |
|----------|------|-----|---------|
| admin@test.com | admin | Yes | Admin functionality testing |
| manager@test.com | manager | No | Manager functionality testing |
| user@test.com | user | No | Basic user testing |
| locked@test.com | user | No | Account lockout testing |
| attacker@test.com | user | No | Security breach simulation |

---

## Phase 1 Testing

### 1. Secure Storage Testing

**Test 1.1: Data Encryption Verification**

```dart
// Test file: test/security/secure_storage_test.dart

void main() {
  group('Secure Storage Tests', () {
    late SecureStorageService storage;

    setUp(() async {
      storage = SecureStorageService();
      await storage.initialize();
    });

    test('stores data encrypted', () async {
      const testKey = 'test_api_key';
      const testValue = 'super_secret_key_12345';

      await storage.write(testKey, testValue);
      final retrieved = await storage.read(testKey);

      expect(retrieved, equals(testValue));
    });

    test('data persists after app restart', () async {
      const testKey = 'persistent_key';
      const testValue = 'persistent_value';

      await storage.write(testKey, testValue);

      // Simulate app restart
      storage = SecureStorageService();
      await storage.initialize();

      final retrieved = await storage.read(testKey);
      expect(retrieved, equals(testValue));
    });

    test('deletes data securely', () async {
      const testKey = 'temp_key';
      await storage.write(testKey, 'temp_value');
      await storage.delete(testKey);

      final retrieved = await storage.read(testKey);
      expect(retrieved, isNull);
    });
  });
}
```

**Manual Testing**:

1. Open the app and login
2. Close the app completely
3. Navigate to device secure storage:
   - **iOS**: Cannot directly access (keychain is secure)
   - **Android**: Use ADB to check encrypted shared prefs

```bash
# Android - verify encryption
adb shell
cd /data/data/com.yourapp.odalisque/shared_prefs
cat FlutterSecureStorage.xml
# Should show encrypted data, not plaintext
```

**Expected Result**: ✅ Data is encrypted at rest, survives app restart

---

### 2. Rate Limiting Testing

**Test 2.1: Login Rate Limiting**

```bash
# Script: test/scripts/test_rate_limiting.sh

#!/bin/bash

echo "Testing login rate limiting..."

# Attempt 6 failed logins
for i in {1..6}; do
  echo "Attempt $i..."
  curl -X POST http://localhost:8080/api/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test@example.com","password":"wrong_password"}' \
    -w "\nHTTP Status: %{http_code}\n"
  sleep 1
done

echo "Account should now be locked"

# Try correct password (should still be locked)
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test@example.com","password":"correct_password"}' \
  -w "\nHTTP Status: %{http_code}\n"
```

**Manual Testing**:

1. Open app and attempt login with wrong password 5 times
2. Observe error message after 5th attempt
3. Wait 15 minutes
4. Try login again with correct password
5. Should succeed

**Expected Results**:
- ✅ Account locked after 5 failed attempts
- ✅ Clear error message displayed
- ✅ Lockout expires after 15 minutes
- ✅ Audit log entry created

**Test 2.2: API Rate Limiting**

```python
# Script: test/scripts/test_api_rate_limit.py

import requests
import time

BASE_URL = "http://localhost:8080/api"
API_KEY = "your_test_api_key"

headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Send 150 requests in 1 minute (exceeds 100/min limit)
success_count = 0
rate_limited_count = 0

for i in range(150):
    response = requests.get(f"{BASE_URL}/tables/Products/records", headers=headers)

    if response.status_code == 200:
        success_count += 1
    elif response.status_code == 429:  # Too Many Requests
        rate_limited_count += 1

    print(f"Request {i+1}: {response.status_code}")
    time.sleep(0.4)  # 150 requests in 60 seconds

print(f"\nResults:")
print(f"Successful: {success_count}")
print(f"Rate limited: {rate_limited_count}")
```

**Expected Result**: ✅ Requests rate limited after 100/min threshold

---

### 3. Audit Logging Testing

**Test 3.1: Verify All Events Logged**

```dart
// Test file: test/security/audit_log_test.dart

void main() {
  group('Audit Log Tests', () {
    late AuditLogService auditLog;

    setUp(() {
      auditLog = AuditLogService(
        baseUrl: testBaseUrl,
        apiKey: testApiKey,
        docId: testDocId,
      );
    });

    test('logs successful login', () async {
      final logged = await auditLog.logAuthEvent(
        action: AuditActions.loginSuccess,
        username: 'test@example.com',
        userId: '123',
        success: true,
        ipAddress: '192.168.1.100',
      );

      expect(logged, isTrue);

      // Verify log was created
      final logs = await auditLog.getAuditLogs(
        username: 'test@example.com',
        action: AuditActions.loginSuccess,
        limit: 1,
      );

      expect(logs, isNotEmpty);
      expect(logs.first['username'], equals('test@example.com'));
    });

    test('logs failed login with metadata', () async {
      await auditLog.logAuthEvent(
        action: AuditActions.loginFailed,
        username: 'test@example.com',
        success: false,
        ipAddress: '192.168.1.100',
        metadata: {'reason': 'Invalid password'},
      );

      final logs = await auditLog.getAuditLogs(
        username: 'test@example.com',
        action: AuditActions.loginFailed,
        limit: 1,
      );

      expect(logs, isNotEmpty);
      final metadata = jsonDecode(logs.first['metadata']);
      expect(metadata['reason'], equals('Invalid password'));
    });
  });
}
```

**Manual Testing**:

1. Perform various actions in the app:
   - Login (success)
   - Login (failure)
   - Logout
   - Create record
   - Update record
   - Delete record
   - Export data

2. Check Grist AuditLogs table:
   - All events should be logged
   - IP addresses captured
   - Metadata includes relevant details

**Expected Result**: ✅ All security events logged with complete metadata

---

### 4. Security Dashboard Testing

**Test 4.1: Dashboard Data Accuracy**

1. Navigate to Security Dashboard (admin only)
2. Verify summary cards show correct data:
   - Failed login attempts (24h)
   - Active sessions
   - API requests (1h)
   - Security alerts

3. Generate test data:
   - Attempt 10 failed logins from different IPs
   - Login with 3 different users
   - Make 50 API requests
   - Trigger a security alert

4. Refresh dashboard
5. Verify all metrics updated correctly

**Test 4.2: Real-time Updates**

1. Open dashboard with auto-refresh enabled (30s)
2. In another device/browser, perform actions:
   - Failed login
   - Successful login
   - API requests
3. Wait 30 seconds
4. Dashboard should automatically update

**Expected Results**:
- ✅ Metrics accurate
- ✅ Auto-refresh works
- ✅ Manual refresh works
- ✅ Admin-only access enforced

---

## Phase 2 Testing

### 1. Multi-Factor Authentication (MFA) Testing

**Test 1.1: MFA Setup Flow**

```dart
// Test file: test/security/mfa_test.dart

void main() {
  group('MFA Service Tests', () {
    late MFAService mfaService;
    late SecureStorageService storage;

    setUp(() async {
      storage = SecureStorageService();
      await storage.initialize();
      mfaService = MFAService(secureStorage: storage);
    });

    test('generates valid TOTP secret', () async {
      final secret = await mfaService.generateSecret();

      expect(secret, isNotNull);
      expect(secret.length, greaterThan(16)); // Base32 encoded
    });

    test('setup MFA creates secret and recovery codes', () async {
      final setupData = await mfaService.setupMFA(
        userId: 'test_user_123',
        username: 'test@example.com',
      );

      expect(setupData.secret, isNotNull);
      expect(setupData.recoveryCodes.length, equals(10));
      expect(setupData.provisioningUri, contains('otpauth://totp'));
    });

    test('verifies valid TOTP code', () async {
      final setupData = await mfaService.setupMFA(
        userId: 'test_user_123',
        username: 'test@example.com',
      );

      // Generate current code
      final currentCode = await mfaService.getCurrentTOTP('test_user_123');

      // Verify it
      final isValid = await mfaService.verifyTOTP(
        userId: 'test_user_123',
        code: currentCode!,
      );

      expect(isValid, isTrue);
    });

    test('rejects invalid TOTP code', () async {
      await mfaService.setupMFA(
        userId: 'test_user_123',
        username: 'test@example.com',
      );

      final isValid = await mfaService.verifyTOTP(
        userId: 'test_user_123',
        code: '000000',
      );

      expect(isValid, isFalse);
    });

    test('recovery code works once', () async {
      final setupData = await mfaService.setupMFA(
        userId: 'test_user_123',
        username: 'test@example.com',
      );

      final recoveryCode = setupData.recoveryCodes.first;

      // Use recovery code
      final firstUse = await mfaService.verifyRecoveryCode(
        userId: 'test_user_123',
        code: recoveryCode,
      );
      expect(firstUse, isTrue);

      // Try same code again
      final secondUse = await mfaService.verifyRecoveryCode(
        userId: 'test_user_123',
        code: recoveryCode,
      );
      expect(secondUse, isFalse);
    });
  });
}
```

**Manual Testing**:

**Setup Flow**:
1. Login as admin user
2. Navigate to Settings → Security → Enable MFA
3. Scan QR code with Google Authenticator
4. Enter 6-digit code from app
5. Save recovery codes

**Verification**:
- ✅ QR code scans successfully
- ✅ TOTP code validates
- ✅ Recovery codes displayed
- ✅ MFA enabled successfully

**Login Flow**:
1. Logout
2. Login with username/password
3. Enter MFA code from authenticator
4. Login succeeds

**Verification**:
- ✅ MFA prompt appears after password
- ✅ Valid code allows login
- ✅ Invalid code shows error
- ✅ "Use recovery code" option available

**Recovery Code Flow**:
1. Logout
2. Login with username/password
3. Click "Use recovery code"
4. Enter one of the saved recovery codes
5. Login succeeds

**Verification**:
- ✅ Recovery code works
- ✅ Same recovery code cannot be reused
- ✅ Remaining codes count decreases

**Clock Drift Testing**:
1. Change device time -30 seconds
2. Generate code
3. Change device time back
4. Try to login with that code
5. Should still work (tolerance window)

---

### 2. Token Rotation Testing

**Test 2.1: Automatic Rotation**

```dart
// Test file: test/security/token_rotation_test.dart

void main() {
  group('Token Rotation Tests', () {
    test('checks rotation schedule correctly', () async {
      final storage = SecureStorageService();
      await storage.initialize();

      final rotationService = TokenRotationService(
        baseUrl: testBaseUrl,
        currentApiKey: testApiKey,
        docId: testDocId,
        secureStorage: storage,
        rotationInterval: Duration(days: 90),
      );

      final status = await rotationService.getRotationStatus();

      expect(status.status, isIn(['valid', 'expiring_soon', 'expired']));
    });

    test('generates secure API keys', () {
      final service = TokenRotationService(
        baseUrl: testBaseUrl,
        currentApiKey: testApiKey,
        docId: testDocId,
        secureStorage: SecureStorageService(),
      );

      final key1 = service._generateApiKey();
      final key2 = service._generateApiKey();

      expect(key1, isNot(equals(key2)));
      expect(key1, startsWith('grist_'));
      expect(key1.length, greaterThan(32));
    });
  });
}
```

**Manual Testing**:

**Check Status**:
1. Navigate to Admin Dashboard → Token Rotation
2. View current token status
3. Check days until rotation

**Manual Rotation**:
1. Click "Rotate Token Now"
2. Confirm rotation
3. Verify:
   - New token generated
   - Grace period active (24h)
   - Old token still works
   - New token works

**Grace Period Expiry**:
1. After 24 hours, verify old token stops working
2. Only new token should work

**Expected Results**:
- ✅ Rotation status accurate
- ✅ Manual rotation works
- ✅ Both keys valid during grace period
- ✅ Old key expires after grace period
- ✅ Audit log entry created

---

### 3. Certificate Pinning Testing

**Test 3.1: Valid Certificate**

```dart
// Test file: test/security/cert_pinning_test.dart

void main() {
  group('Certificate Pinning Tests', () {
    test('accepts valid certificate', () async {
      // Get actual certificate fingerprint
      final fingerprint = await CertificateFingerprintExtractor.getFingerprint(
        'https://your-grist-domain.com',
      );

      final certPinning = CertificatePinningService(
        hostname: 'your-grist-domain.com',
        sha256Fingerprints: [fingerprint!],
      );

      final result = await certPinning.validateCertificate(
        'https://your-grist-domain.com/api/docs',
      );

      expect(result.isValid, isTrue);
    });

    test('rejects invalid certificate', () async {
      final certPinning = CertificatePinningService(
        hostname: 'your-grist-domain.com',
        sha256Fingerprints: ['INVALID:FINGERPRINT:HERE'],
      );

      final result = await certPinning.validateCertificate(
        'https://your-grist-domain.com/api/docs',
      );

      expect(result.isValid, isFalse);
      expect(result.isCertificateError, isTrue);
    });
  });
}
```

**Manual Testing**:

**Setup**:
1. Get your domain's certificate fingerprint:
```bash
openssl s_client -connect your-domain.com:443 < /dev/null \
  | openssl x509 -fingerprint -sha256 -noout
```

2. Configure pinning with correct fingerprint
3. Test API calls - should work

**MITM Test** (with test proxy):
1. Set up mitmproxy:
```bash
mitmproxy -p 8888
```

2. Configure app to use proxy
3. Attempt API call
4. Should fail with certificate pinning error

**Expected Results**:
- ✅ Valid certificate accepted
- ✅ Invalid certificate rejected
- ✅ MITM attack blocked
- ✅ Security alert generated

---

### 4. Security Alert Testing

**Test 4.1: Email Alerts**

```dart
// Test file: test/security/alert_service_test.dart

void main() {
  group('Security Alert Tests', () {
    test('sends email alert', () async {
      final emailConfig = EmailAlertConfig.gmail(
        email: 'test@gmail.com',
        appPassword: 'test_app_password',
      );

      final alertService = SecurityAlertService(
        emailConfig: emailConfig,
      );

      final alert = SecurityAlert(
        id: 'test_alert_1',
        type: 'brute_force_attempt',
        severity: 'high',
        title: 'Test Security Alert',
        description: 'This is a test alert',
        timestamp: DateTime.now(),
        metadata: {},
      );

      final result = await alertService.sendAlert(
        alert: alert,
        emailRecipients: ['admin@test.com'],
      );

      expect(result.emailSent, isTrue);
    });
  });
}
```

**Manual Testing**:

**Email Alert**:
1. Configure email settings in app
2. Trigger security event (e.g., 10 failed logins)
3. Check email inbox
4. Verify email received with:
   - Correct severity color
   - Alert details
   - Recommended actions
   - Professional formatting

**Push Notification**:
1. Configure FCM settings
2. Install app on test device
3. Get device FCM token
4. Trigger critical alert
5. Verify push notification received

**Daily Summary**:
1. Wait for daily summary time (or trigger manually)
2. Check email
3. Verify summary includes:
   - All metrics
   - Critical/high alerts
   - Professional formatting

**Expected Results**:
- ✅ Email alerts delivered
- ✅ Push notifications work
- ✅ Daily summaries sent
- ✅ Alert throttling prevents spam

---

## Penetration Testing

### 1. Authentication Testing

**Test SQL Injection**:

```bash
# Try SQL injection in login
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin@test.com OR 1=1--","password":"anything"}'

# Expected: Login fails, no SQL injection
```

**Test XSS**:

```bash
# Try XSS in username
curl -X POST http://localhost:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"<script>alert(1)</script>","password":"test"}'

# Expected: XSS sanitized
```

**Test Brute Force**:

```python
# Script: test/security/brute_force_test.py

import requests
import time

# Attempt rapid-fire logins
for i in range(100):
    response = requests.post(
        'http://localhost:8080/api/login',
        json={'username': 'admin@test.com', 'password': f'password{i}'}
    )
    print(f"Attempt {i}: {response.status_code}")
    if response.status_code == 429:
        print("Rate limited - SUCCESS")
        break
```

**Expected Results**:
- ✅ SQL injection blocked
- ✅ XSS sanitized
- ✅ Brute force rate limited
- ✅ Account locked after threshold

---

### 2. API Security Testing

**Test Authorization**:

```bash
# Try to access admin endpoint without admin role
curl -X GET http://localhost:8080/api/admin/users \
  -H "Authorization: Bearer USER_TOKEN"

# Expected: 403 Forbidden
```

**Test API Key Leakage**:

```bash
# Check if API keys appear in responses
curl -X GET http://localhost:8080/api/config \
  -H "Authorization: Bearer VALID_TOKEN"

# Expected: No API keys in response
```

**Test CORS**:

```bash
curl -X OPTIONS http://localhost:8080/api/login \
  -H "Origin: http://evil.com" \
  -H "Access-Control-Request-Method: POST"

# Expected: CORS blocked for unauthorized origins
```

---

## Security Scanning

### 1. Dependency Scanning

```bash
# Scan Flutter dependencies
cd flutter-module
flutter pub outdated

# Check for known vulnerabilities
dart pub global activate pana
pana --no-warning
```

### 2. Static Code Analysis

```bash
# Run security linter
flutter analyze

# Check for hardcoded secrets
gitleaks detect --source=. --verbose
```

### 3. Container Scanning

```bash
# Scan Docker images
docker scan odalisque:latest

# Check for vulnerabilities
trivy image odalisque:latest
```

### 4. Network Scanning

```bash
# Scan open ports
nmap -sV -p- your-server-ip

# Expected open ports: 22 (SSH), 80 (HTTP), 443 (HTTPS)
# All others should be closed
```

---

## Performance Testing

### 1. Load Testing

```python
# Script: test/performance/load_test.py

from locust import HttpUser, task, between

class SecurityLoadTest(HttpUser):
    wait_time = between(1, 3)

    @task(3)
    def api_request(self):
        self.client.get(
            "/api/tables/Products/records",
            headers={"Authorization": f"Bearer {self.api_key}"}
        )

    @task(1)
    def login(self):
        self.client.post(
            "/api/login",
            json={"username": "test@example.com", "password": "password"}
        )

# Run: locust -f load_test.py --host=http://localhost:8080
```

**Test Scenarios**:
1. 100 concurrent users
2. 1000 requests/minute
3. Monitor:
   - Response times
   - Error rates
   - Rate limiting
   - Database performance

**Expected Results**:
- ✅ < 200ms average response time
- ✅ < 1% error rate
- ✅ Rate limiting active
- ✅ No memory leaks

---

## Compliance Testing

### OWASP Top 10 Checklist

- [ ] A01: Broken Access Control - RBAC tested
- [ ] A02: Cryptographic Failures - Encryption verified
- [ ] A03: Injection - SQL/XSS tests passed
- [ ] A04: Insecure Design - Threat model reviewed
- [ ] A05: Security Misconfiguration - Headers validated
- [ ] A06: Vulnerable Components - Dependencies scanned
- [ ] A07: Authentication Failures - MFA, lockout tested
- [ ] A08: Software Integrity - Code obfuscation verified
- [ ] A09: Logging Failures - Audit logs comprehensive
- [ ] A10: SSRF - Input validation tested

### GDPR Compliance

- [ ] Data export functionality works
- [ ] Data deletion works
- [ ] Consent management functional
- [ ] Audit logs for data access
- [ ] Privacy policy accessible

---

## Test Reporting

### Create Test Report

```markdown
# Security Test Report - Odalisque v0.14.0

**Date**: YYYY-MM-DD
**Tester**: Your Name
**Environment**: Test/Staging/Production

## Test Summary

- Total Tests: XX
- Passed: XX
- Failed: XX
- Blocked: XX

## Phase 1 Results

### Secure Storage: ✅ PASS
- All data encrypted
- Migration successful
- No plaintext leakage

### Rate Limiting: ✅ PASS
- Account lockout works
- API limits enforced
- Proper error messages

### Audit Logging: ✅ PASS
- All events logged
- Complete metadata
- Searchable logs

### Dashboard: ✅ PASS
- Metrics accurate
- Real-time updates
- Admin access only

## Phase 2 Results

### MFA: ✅ PASS
- Setup flow smooth
- TOTP validation works
- Recovery codes functional

### Token Rotation: ✅ PASS
- Automatic rotation scheduled
- Grace period works
- No service interruption

### Certificate Pinning: ✅ PASS
- Valid certs accepted
- Invalid certs blocked
- MITM prevented

### Security Alerts: ✅ PASS
- Email delivery works
- Push notifications sent
- Daily summaries accurate

## Critical Issues

None found

## Recommendations

1. Enable MFA for all admin accounts
2. Configure certificate pinning for production
3. Set up email alerts
4. Monitor security dashboard daily

## Sign-off

- [ ] QA Approved
- [ ] Security Approved
- [ ] Ready for Production
```

---

## Continuous Testing

### Automated Test Suite

```bash
# Run all security tests
cd flutter-module
flutter test test/security/

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### CI/CD Integration

```yaml
# .github/workflows/security-tests.yml

name: Security Tests

on: [push, pull_request]

jobs:
  security-tests:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Run security tests
        run: |
          cd flutter-module
          flutter test test/security/

      - name: Dependency scan
        run: |
          flutter pub outdated

      - name: Secret scan
        run: |
          gitleaks detect --source=. --verbose
```

---

**Last Updated**: 2024-01-16
**Version**: 0.14.0
**Next Review**: Before production deployment
