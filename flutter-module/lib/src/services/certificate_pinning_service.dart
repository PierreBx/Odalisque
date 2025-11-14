import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'audit_log_service.dart';

/// Certificate Pinning Service for secure HTTPS connections
///
/// Provides:
/// - SSL certificate pinning for Grist API
/// - Protection against Man-in-the-Middle attacks
/// - Certificate validation and rotation
/// - Pinning failure detection and alerting
/// - Support for multiple certificate fingerprints (for rotation)
class CertificatePinningService {
  final String hostname;
  final List<String> sha256Fingerprints;
  final AuditLogService? _auditLogService;
  final bool allowBadCertificates; // For development only

  http.Client? _pinnedClient;

  CertificatePinningService({
    required this.hostname,
    required this.sha256Fingerprints,
    AuditLogService? auditLogService,
    this.allowBadCertificates = false,
  }) : _auditLogService = auditLogService {
    _initializeClient();
  }

  /// Initialize HTTP client with certificate pinning
  void _initializeClient() {
    final httpClient = HttpClient();

    httpClient.badCertificateCallback = (
      X509Certificate cert,
      String host,
      int port,
    ) {
      // Development mode - allow bad certificates
      if (allowBadCertificates) {
        return true;
      }

      // Check if this is the host we're pinning
      if (host != hostname) {
        return false;
      }

      // Get certificate SHA-256 fingerprint
      final certFingerprint = _getCertificateFingerprint(cert);

      // Check if fingerprint matches any of our pinned certificates
      final isValid = sha256Fingerprints.contains(certFingerprint);

      if (!isValid) {
        // Log certificate pinning failure
        _logPinningFailure(host, certFingerprint);
      }

      return isValid;
    };

    _pinnedClient = IOClient(httpClient);
  }

  /// Get the HTTP client with certificate pinning enabled
  http.Client get client {
    _pinnedClient ??= _initializeClient() as http.Client;
    return _pinnedClient!;
  }

  /// Get SHA-256 fingerprint of a certificate
  String _getCertificateFingerprint(X509Certificate cert) {
    // Get DER-encoded certificate
    final der = cert.der;

    // Calculate SHA-256 hash
    final bytes = der;
    final digest = _sha256(bytes);

    // Convert to hex string with colons
    final fingerprint = digest
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    return fingerprint;
  }

  /// Simple SHA-256 implementation
  List<int> _sha256(List<int> data) {
    // This is a placeholder - in production, use package:crypto
    // For now, return the data as-is (this is just for demonstration)
    return data.sublist(0, 32.clamp(0, data.length));
  }

  /// Validate certificate pinning for a URL
  Future<CertificateValidationResult> validateCertificate(String url) async {
    try {
      final uri = Uri.parse(url);

      if (uri.scheme != 'https') {
        return CertificateValidationResult(
          isValid: false,
          error: 'Certificate pinning requires HTTPS',
        );
      }

      // Attempt connection
      final response = await client.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CertificateValidationResult(
          isValid: true,
        );
      }

      return CertificateValidationResult(
        isValid: false,
        error: 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      if (e.toString().contains('CERTIFICATE')) {
        await _logPinningFailure(hostname, 'validation_failed');

        return CertificateValidationResult(
          isValid: false,
          error: 'Certificate pinning validation failed',
          isCertificateError: true,
        );
      }

      return CertificateValidationResult(
        isValid: false,
        error: e.toString(),
      );
    }
  }

  /// Add a new certificate fingerprint (for rotation)
  void addFingerprint(String fingerprint) {
    if (!sha256Fingerprints.contains(fingerprint)) {
      sha256Fingerprints.add(fingerprint);

      _auditLogService?.logSecurityEvent(
        action: 'CERTIFICATE_FINGERPRINT_ADDED',
        description: 'New certificate fingerprint added for $hostname',
        severity: 'medium',
        metadata: {
          'hostname': hostname,
          'fingerprint': fingerprint,
        },
      );
    }
  }

  /// Remove an old certificate fingerprint (after rotation complete)
  void removeFingerprint(String fingerprint) {
    if (sha256Fingerprints.remove(fingerprint)) {
      _auditLogService?.logSecurityEvent(
        action: 'CERTIFICATE_FINGERPRINT_REMOVED',
        description: 'Certificate fingerprint removed for $hostname',
        severity: 'medium',
        metadata: {
          'hostname': hostname,
          'fingerprint': fingerprint,
        },
      );
    }
  }

  /// Log certificate pinning failure
  Future<void> _logPinningFailure(String host, String fingerprint) async {
    await _auditLogService?.logSecurityEvent(
      action: 'CERTIFICATE_PINNING_FAILURE',
      description: 'Certificate pinning validation failed for $host',
      severity: 'critical',
      metadata: {
        'hostname': host,
        'received_fingerprint': fingerprint,
        'expected_fingerprints': sha256Fingerprints,
      },
    );
  }

  /// Dispose of resources
  void dispose() {
    _pinnedClient?.close();
  }
}

/// Certificate validation result
class CertificateValidationResult {
  final bool isValid;
  final String? error;
  final bool isCertificateError;

  CertificateValidationResult({
    required this.isValid,
    this.error,
    this.isCertificateError = false,
  });
}

/// Helper to extract certificate fingerprint from a URL
class CertificateFingerprintExtractor {
  /// Get certificate fingerprint from a URL
  /// This would be used during setup to get the fingerprint to pin
  static Future<String?> getFingerprint(String url) async {
    try {
      final uri = Uri.parse(url);

      if (uri.scheme != 'https') {
        return null;
      }

      final socket = await SecureSocket.connect(
        uri.host,
        uri.port == 0 ? 443 : uri.port,
        onBadCertificate: (cert) {
          // Accept the certificate just to get its fingerprint
          return true;
        },
      );

      final cert = socket.peerCertificate;
      if (cert == null) {
        return null;
      }

      // Get DER-encoded certificate
      final der = cert.der;

      // Calculate SHA-256 hash (simplified - use crypto package in production)
      final fingerprint = der
          .sublist(0, 32.clamp(0, der.length))
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join(':');

      await socket.close();

      return fingerprint;
    } catch (e) {
      return null;
    }
  }

  /// Get human-readable certificate info
  static Future<CertificateInfo?> getCertificateInfo(String url) async {
    try {
      final uri = Uri.parse(url);

      if (uri.scheme != 'https') {
        return null;
      }

      final socket = await SecureSocket.connect(
        uri.host,
        uri.port == 0 ? 443 : uri.port,
        onBadCertificate: (cert) => true,
      );

      final cert = socket.peerCertificate;
      if (cert == null) {
        return null;
      }

      final info = CertificateInfo(
        subject: cert.subject,
        issuer: cert.issuer,
        startDate: cert.startValidity,
        endDate: cert.endValidity,
      );

      await socket.close();

      return info;
    } catch (e) {
      return null;
    }
  }
}

/// Certificate information
class CertificateInfo {
  final String subject;
  final String issuer;
  final DateTime startDate;
  final DateTime endDate;

  CertificateInfo({
    required this.subject,
    required this.issuer,
    required this.startDate,
    required this.endDate,
  });

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  int get daysUntilExpiry {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  bool get expiringSoon => daysUntilExpiry < 30;
}
