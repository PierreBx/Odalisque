import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'secure_storage_service.dart';
import 'audit_log_service.dart';

/// Token Rotation Service for API key management
///
/// Provides:
/// - Automatic API key rotation (90-day default)
/// - Scheduled rotation jobs
/// - Key expiration tracking
/// - Seamless rotation without downtime
/// - Audit logging of rotation events
class TokenRotationService {
  final String baseUrl;
  final String currentApiKey;
  final String docId;
  final SecureStorageService _secureStorage;
  final AuditLogService? _auditLogService;

  // Rotation configuration
  final Duration rotationInterval;
  final Duration gracePeriod; // Both old and new keys valid during this period

  Timer? _rotationTimer;
  static const String _rotationScheduleKey = 'token_rotation_schedule';
  static const String _previousKeyKey = 'previous_api_key';
  static const String _currentKeyExpiryKey = 'current_key_expiry';

  TokenRotationService({
    required this.baseUrl,
    required this.currentApiKey,
    required this.docId,
    required SecureStorageService secureStorage,
    AuditLogService? auditLogService,
    this.rotationInterval = const Duration(days: 90),
    this.gracePeriod = const Duration(hours: 24),
  })  : _secureStorage = secureStorage,
        _auditLogService = auditLogService;

  /// Initialize the rotation service and schedule rotation
  Future<void> initialize() async {
    await _secureStorage.initialize();

    // Check if rotation is due
    final needsRotation = await _checkRotationNeeded();

    if (needsRotation) {
      await rotateToken(force: false);
    }

    // Schedule periodic checks
    _scheduleRotation();
  }

  /// Manually rotate the API token
  Future<TokenRotationResult> rotateToken({
    bool force = false,
    String? adminUsername,
  }) async {
    try {
      // Check if rotation is needed (unless forced)
      if (!force) {
        final needed = await _checkRotationNeeded();
        if (!needed) {
          return TokenRotationResult(
            success: false,
            message: 'Rotation not needed yet',
          );
        }
      }

      // Generate new API key
      final newApiKey = _generateApiKey();

      // Store previous key for grace period
      await _secureStorage.write(_previousKeyKey, currentApiKey);

      // Update to new key in Grist
      final updated = await _updateApiKeyInGrist(newApiKey);

      if (!updated) {
        return TokenRotationResult(
          success: false,
          message: 'Failed to update API key in Grist',
        );
      }

      // Store new key
      await _secureStorage.write(SecureStorageKeys.gristApiKey, newApiKey);

      // Set expiry for new key
      final newExpiry = DateTime.now().add(rotationInterval);
      await _secureStorage.write(
        _currentKeyExpiryKey,
        newExpiry.toIso8601String(),
      );

      // Schedule grace period cleanup
      _scheduleGracePeriodCleanup();

      // Log rotation
      await _auditLogService?.logAdminAction(
        action: 'API_KEY_ROTATED',
        resource: 'api_keys',
        username: adminUsername ?? 'system',
        metadata: {
          'forced': force,
          'expiry': newExpiry.toIso8601String(),
          'grace_period_hours': gracePeriod.inHours,
        },
      );

      return TokenRotationResult(
        success: true,
        message: 'API key rotated successfully',
        newKey: newApiKey,
        expiresAt: newExpiry,
      );
    } catch (e) {
      await _auditLogService?.logSecurityEvent(
        action: 'API_KEY_ROTATION_FAILED',
        description: 'Failed to rotate API key: $e',
        severity: 'high',
      );

      return TokenRotationResult(
        success: false,
        message: 'Rotation failed: $e',
      );
    }
  }

  /// Check if token rotation is needed
  Future<bool> _checkRotationNeeded() async {
    final expiryStr = await _secureStorage.read(_currentKeyExpiryKey);

    if (expiryStr == null) {
      // No expiry set, schedule rotation for 90 days from now
      final expiry = DateTime.now().add(rotationInterval);
      await _secureStorage.write(
        _currentKeyExpiryKey,
        expiry.toIso8601String(),
      );
      return false;
    }

    final expiry = DateTime.parse(expiryStr);
    final now = DateTime.now();

    // Rotate 7 days before expiry
    return now.isAfter(expiry.subtract(const Duration(days: 7)));
  }

  /// Get time until next rotation
  Future<Duration?> getTimeUntilRotation() async {
    final expiryStr = await _secureStorage.read(_currentKeyExpiryKey);

    if (expiryStr == null) {
      return null;
    }

    final expiry = DateTime.parse(expiryStr);
    final now = DateTime.now();

    if (now.isAfter(expiry)) {
      return Duration.zero;
    }

    return expiry.difference(now);
  }

  /// Get rotation status
  Future<TokenRotationStatus> getRotationStatus() async {
    final expiryStr = await _secureStorage.read(_currentKeyExpiryKey);
    final previousKey = await _secureStorage.read(_previousKeyKey);

    DateTime? expiry;
    if (expiryStr != null) {
      expiry = DateTime.parse(expiryStr);
    }

    final now = DateTime.now();
    final daysUntilExpiry = expiry != null
        ? expiry.difference(now).inDays
        : null;

    String status;
    if (daysUntilExpiry == null) {
      status = 'unknown';
    } else if (daysUntilExpiry < 0) {
      status = 'expired';
    } else if (daysUntilExpiry < 7) {
      status = 'expiring_soon';
    } else {
      status = 'valid';
    }

    return TokenRotationStatus(
      status: status,
      expiresAt: expiry,
      daysUntilExpiry: daysUntilExpiry,
      gracePeriodActive: previousKey != null,
    );
  }

  /// Schedule automatic rotation
  void _scheduleRotation() {
    // Check daily for rotation needs
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(const Duration(hours: 24), (_) async {
      final needed = await _checkRotationNeeded();
      if (needed) {
        await rotateToken(force: false);
      }
    });
  }

  /// Schedule grace period cleanup
  void _scheduleGracePeriodCleanup() {
    Timer(gracePeriod, () async {
      await _secureStorage.delete(_previousKeyKey);

      await _auditLogService?.logAdminAction(
        action: 'API_KEY_GRACE_PERIOD_EXPIRED',
        resource: 'api_keys',
        username: 'system',
        metadata: {'grace_period_hours': gracePeriod.inHours},
      );
    });
  }

  /// Generate a new API key
  String _generateApiKey() {
    const uuid = Uuid();
    final random = Random.secure();

    // Generate a secure API key: prefix + UUID + random suffix
    final prefix = 'grist';
    final id = uuid.v4().replaceAll('-', '');
    final suffix = List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();

    return '${prefix}_$id$suffix';
  }

  /// Update API key in Grist (placeholder - implement based on your Grist setup)
  Future<bool> _updateApiKeyInGrist(String newKey) async {
    try {
      // This is a placeholder. In production, you would:
      // 1. Call Grist API to update the API key
      // 2. Update the key in the Users table or API keys table
      // 3. Verify the new key works

      // For now, we'll simulate success
      // In reality, you'd need admin access to rotate keys

      final response = await http.post(
        Uri.parse('$baseUrl/api/docs/$docId/tables/APIKeys/records'),
        headers: {
          'Authorization': 'Bearer $currentApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'records': [
            {
              'fields': {
                'key': newKey,
                'created_at': DateTime.now().toIso8601String(),
                'expires_at': DateTime.now().add(rotationInterval).toIso8601String(),
                'status': 'active',
              }
            }
          ]
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Validate an API key is still valid
  Future<bool> validateKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/docs/$docId/tables'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Dispose of the service
  void dispose() {
    _rotationTimer?.cancel();
  }
}

/// Token rotation result
class TokenRotationResult {
  final bool success;
  final String message;
  final String? newKey;
  final DateTime? expiresAt;

  TokenRotationResult({
    required this.success,
    required this.message,
    this.newKey,
    this.expiresAt,
  });
}

/// Token rotation status
class TokenRotationStatus {
  final String status; // valid, expiring_soon, expired, unknown
  final DateTime? expiresAt;
  final int? daysUntilExpiry;
  final bool gracePeriodActive;

  TokenRotationStatus({
    required this.status,
    this.expiresAt,
    this.daysUntilExpiry,
    required this.gracePeriodActive,
  });

  bool get needsRotation => status == 'expired' || status == 'expiring_soon';

  String get statusMessage {
    switch (status) {
      case 'valid':
        return 'API key is valid';
      case 'expiring_soon':
        return 'API key expires in $daysUntilExpiry days';
      case 'expired':
        return 'API key has expired';
      default:
        return 'Unknown status';
    }
  }
}
