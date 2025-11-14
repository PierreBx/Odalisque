# Changelog

All notable changes to the Odalisque project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.13.0] - 2025-01-15

### 🔒 Security - Phase 1: Production Hardening

This release focuses entirely on securing the application for production deployments with comprehensive security enhancements.

#### Added

**Secure Storage**
- Implemented `flutter_secure_storage` for all sensitive data
- Platform-specific encryption (iOS Keychain, Android Keystore)
- Automatic migration from SharedPreferences to secure storage
- Support for MFA secrets storage (ready for Phase 2)

**Server-Side Rate Limiting**
- Rate limiting service with Grist backend storage
- Account lockout after 5 failed login attempts
- 15-minute lockout duration
- IP-based and user-based rate limiting
- API rate limiting (100 requests/min, 1000/hour)
- Manual account unlock for administrators

**Comprehensive Audit Logging**
- Server-side audit log service with Grist storage
- All authentication events logged (login, logout, failures)
- Data operation tracking (CRUD operations)
- Admin action logging
- Security event logging
- IP address, device fingerprint, and user agent tracking
- Immutable, tamper-proof audit trail
- 90-day retention policy support

**Security Monitoring Dashboard**
- Real-time security metrics dashboard
- Failed login attempt tracking with suspicious IP detection
- Active sessions monitoring
- API usage patterns and rate limit violations
- Security alerts with severity levels (critical, high, medium)
- Auto-refresh capability (configurable interval)
- Admin-only access control

**Production Build Security**
- Code obfuscation for all release builds
- ProGuard rules for Android (optimized for security)
- Debug symbol extraction and separation
- Production build script with security checklist
- Automated security validation in build process

**Certificate Pinning Support**
- Added `http_certificate_pinning` package
- Certificate pinning configuration ready (to be enabled in Phase 2)
- SSL certificate validation framework

#### Changed

**Authentication**
- AuthProvider now uses `SecureStorageService` instead of SharedPreferences
- Login method includes IP address tracking
- Logout method includes audit logging
- Session data stored in encrypted storage
- Enhanced error messages for rate limit violations

**Security Services Integration**
- GristService prepared for secure API key storage
- All security services integrated with AuthProvider
- Centralized security configuration

#### Security

**Critical Fixes**
- ✅ Eliminated plaintext storage of sensitive data
- ✅ Implemented server-side rate limiting (prevents client-side bypass)
- ✅ Added comprehensive audit logging for compliance
- ✅ Enabled code obfuscation to prevent reverse engineering
- ✅ Separated debug symbols from production builds

**Risk Mitigation**
- Brute force attack protection via rate limiting
- Account compromise detection via audit logs
- API abuse prevention via rate limiting
- Man-in-the-middle attack prevention (certificate pinning ready)
- Data breach prevention via encryption at rest

#### Documentation

- Added comprehensive `SECURITY.md` documentation
- Production build instructions
- Security best practices guide
- Incident response procedures
- Grist table setup guide
- Compliance information (OWASP, GDPR, SOC 2, PCI DSS)

#### Development

- Build script: `build_production.sh` for secure release builds
- ProGuard rules: `android/app/proguard-rules.pro`
- Security services: `secure_storage_service.dart`, `audit_log_service.dart`, `rate_limit_service.dart`
- Monitoring service: `security_monitoring_service.dart`
- Dashboard page: `security_dashboard_page.dart`

---

## [0.12.0] - 2024-01-10

### Added

**Admin Dashboard**
- Real-time monitoring with auto-refresh
- System health monitoring (API, database, authentication)
- Performance metrics tracking (response times, error rates)
- Active users widget with session tracking
- Database overview with record counts

**Navigation Enhancements**
- Deep linking with go_router
- URL-based navigation (`/page/:pageId/record/:recordId`)
- Breadcrumb navigation widget
- Tab-based navigation with swipe support
- Browser back/forward support

### Changed
- Enhanced routing with `go_router` v13.0.0
- Improved navigation structure

---

## [0.11.0] - 2024-01-05

### Added
- Role-based access control (RBAC)
- Expression-based visibility rules
- Page-level permissions
- Field-level permissions

### Changed
- Enhanced configuration with `visible_if` expressions

---

## [0.10.0] - 2024-01-01

### Added
- File upload widget with drag & drop
- Image preview support
- Base64 attachment encoding
- File type validation

---

## [0.9.0] - 2023-12-20

### Added
- Data export (CSV, Excel, PDF)
- Print functionality
- Export configuration options

---

## [0.8.0] - 2023-12-15

### Added
- Rich text editor (flutter_quill)
- Color picker widget
- Rating widget
- Enhanced form inputs

---

## [0.7.0] - 2023-12-10

### Added
- Search functionality
- Filtering capabilities
- Sorting by columns
- Pagination controls

---

## [0.6.0] - 2023-12-05

### Added
- Data create page
- Form validation
- Dynamic form generation from schema
- Field type support (text, numeric, date, choice, etc.)

---

## [0.5.0] - 2023-12-01

### Added
- Data detail page
- Record viewing
- Record editing
- Field rendering based on type

---

## [0.4.0] - 2023-11-25

### Added
- Data master page with table view
- Grist API integration
- CRUD operations
- Auto-schema detection

---

## [0.3.0] - 2023-11-20

### Added
- Authentication system
- Bcrypt password hashing
- Session management
- Login page UI
- Account lockout (client-side - moved to server-side in v0.13.0)

---

## [0.2.0] - 2023-11-15

### Added
- YAML-based configuration
- Page types framework
- Provider state management
- Theme support (light/dark)
- Internationalization (i18n)

---

## [0.1.0] - 2023-11-10

### Added
- Initial project structure
- Flutter module setup
- Grist service foundation
- Basic navigation
- Home page and front page

---

## Roadmap

### Phase 2: Enhanced Security (Planned)
- [ ] Multi-factor authentication (TOTP)
- [ ] Token rotation mechanism
- [ ] Enhanced security headers (CSP, X-Frame-Options)
- [ ] Intrusion detection system
- [ ] Security alerting via email/push
- [ ] Penetration testing

### Phase 3: Infrastructure Security (Planned)
- [ ] WAF rules for nginx
- [ ] Backup encryption
- [ ] Container security hardening
- [ ] Offsite backup replication
- [ ] VPN support for admin access

### Phase 4: Compliance & Testing (Planned)
- [ ] GDPR compliance features (data export, deletion)
- [ ] Comprehensive penetration testing
- [ ] Security audit
- [ ] Compliance documentation
- [ ] Security training materials

---

[0.13.0]: https://github.com/yourusername/odalisque/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/yourusername/odalisque/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/yourusername/odalisque/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/yourusername/odalisque/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/yourusername/odalisque/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/yourusername/odalisque/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/yourusername/odalisque/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/yourusername/odalisque/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/yourusername/odalisque/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/yourusername/odalisque/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/yourusername/odalisque/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/yourusername/odalisque/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/yourusername/odalisque/releases/tag/v0.1.0
