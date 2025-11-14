import 'dart:math';
import 'dart:convert';
import 'package:otp/otp.dart';
import 'package:crypto/crypto.dart';
import 'secure_storage_service.dart';
import 'audit_log_service.dart';

/// Multi-Factor Authentication Service using TOTP (Time-based One-Time Password)
///
/// Provides:
/// - TOTP generation and validation (Google Authenticator compatible)
/// - QR code data generation for easy setup
/// - Recovery codes for account recovery
/// - Secure secret storage
/// - MFA enforcement policies
class MFAService {
  final SecureStorageService _secureStorage;
  final AuditLogService? _auditLogService;

  // TOTP configuration
  static const int totpInterval = 30; // 30 seconds
  static const int totpDigits = 6;
  static const Algorithm totpAlgorithm = Algorithm.SHA1;
  static const int recoveryCodeCount = 10;
  static const int recoveryCodeLength = 8;

  MFAService({
    required SecureStorageService secureStorage,
    AuditLogService? auditLogService,
  })  : _secureStorage = secureStorage,
        _auditLogService = auditLogService;

  /// Check if MFA is enabled for a user
  Future<bool> isMFAEnabled(String userId) async {
    final enabled = await _secureStorage.read('${SecureStorageKeys.mfaEnabled}_$userId');
    return enabled == 'true';
  }

  /// Generate a new TOTP secret for a user
  /// Returns the base32-encoded secret
  Future<String> generateSecret() async {
    // Generate 160-bit (20 bytes) random secret
    final random = Random.secure();
    final bytes = List<int>.generate(20, (_) => random.nextInt(256));

    // Encode as base32
    final secret = _base32Encode(bytes);

    return secret;
  }

  /// Setup MFA for a user
  /// Returns the secret and recovery codes
  Future<MFASetupData> setupMFA({
    required String userId,
    required String username,
    String issuer = 'Odalisque',
  }) async {
    // Generate secret
    final secret = await generateSecret();

    // Generate recovery codes
    final recoveryCodes = _generateRecoveryCodes();

    // Store secret (but don't enable yet - user must verify first)
    await _secureStorage.write(
      '${SecureStorageKeys.mfaSecret}_$userId',
      secret,
    );

    // Store recovery codes (hashed)
    final hashedCodes = recoveryCodes.map(_hashRecoveryCode).toList();
    await _secureStorage.write(
      '${SecureStorageKeys.mfaRecoveryCodes}_$userId',
      jsonEncode(hashedCodes),
    );

    // Generate provisioning URI for QR code
    final uri = _generateProvisioningUri(
      secret: secret,
      username: username,
      issuer: issuer,
    );

    // Log MFA setup initiation
    await _auditLogService?.logAuthEvent(
      action: 'MFA_SETUP_INITIATED',
      username: username,
      userId: userId,
      success: true,
      metadata: {'method': 'TOTP'},
    );

    return MFASetupData(
      secret: secret,
      recoveryCodes: recoveryCodes,
      provisioningUri: uri,
    );
  }

  /// Enable MFA after user has verified the setup
  Future<bool> enableMFA({
    required String userId,
    required String username,
    required String verificationCode,
  }) async {
    // Verify the code
    final isValid = await verifyTOTP(userId: userId, code: verificationCode);

    if (isValid) {
      // Enable MFA
      await _secureStorage.write(
        '${SecureStorageKeys.mfaEnabled}_$userId',
        'true',
      );

      // Log MFA enabled
      await _auditLogService?.logAuthEvent(
        action: 'MFA_ENABLED',
        username: username,
        userId: userId,
        success: true,
        metadata: {'method': 'TOTP'},
      );

      return true;
    }

    return false;
  }

  /// Disable MFA for a user (admin or user action)
  Future<void> disableMFA({
    required String userId,
    required String username,
    String? adminUsername,
  }) async {
    await _secureStorage.delete('${SecureStorageKeys.mfaEnabled}_$userId');
    await _secureStorage.delete('${SecureStorageKeys.mfaSecret}_$userId');
    await _secureStorage.delete('${SecureStorageKeys.mfaRecoveryCodes}_$userId');

    // Log MFA disabled
    await _auditLogService?.logAuthEvent(
      action: 'MFA_DISABLED',
      username: username,
      userId: userId,
      success: true,
      metadata: {
        'method': 'TOTP',
        if (adminUsername != null) 'admin_username': adminUsername,
      },
    );
  }

  /// Verify a TOTP code
  Future<bool> verifyTOTP({
    required String userId,
    required String code,
  }) async {
    final secret = await _secureStorage.read('${SecureStorageKeys.mfaSecret}_$userId');

    if (secret == null) {
      return false;
    }

    // Generate current TOTP
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Check current window and ±1 window for clock drift
    for (int i = -1; i <= 1; i++) {
      final time = now + (i * totpInterval);
      final expectedCode = OTP.generateTOTPCodeString(
        secret,
        time,
        length: totpDigits,
        interval: totpInterval,
        algorithm: totpAlgorithm,
        isGoogle: true,
      );

      if (code == expectedCode) {
        return true;
      }
    }

    return false;
  }

  /// Verify a recovery code
  Future<bool> verifyRecoveryCode({
    required String userId,
    required String code,
  }) async {
    final codesJson = await _secureStorage.read(
      '${SecureStorageKeys.mfaRecoveryCodes}_$userId',
    );

    if (codesJson == null) {
      return false;
    }

    final hashedCodes = List<String>.from(jsonDecode(codesJson));
    final hashedInput = _hashRecoveryCode(code);

    // Check if code matches any stored hash
    if (hashedCodes.contains(hashedInput)) {
      // Remove used recovery code
      hashedCodes.remove(hashedInput);
      await _secureStorage.write(
        '${SecureStorageKeys.mfaRecoveryCodes}_$userId',
        jsonEncode(hashedCodes),
      );

      return true;
    }

    return false;
  }

  /// Get remaining recovery codes count
  Future<int> getRemainingRecoveryCodesCount(String userId) async {
    final codesJson = await _secureStorage.read(
      '${SecureStorageKeys.mfaRecoveryCodes}_$userId',
    );

    if (codesJson == null) {
      return 0;
    }

    final hashedCodes = List<String>.from(jsonDecode(codesJson));
    return hashedCodes.length;
  }

  /// Regenerate recovery codes
  Future<List<String>> regenerateRecoveryCodes({
    required String userId,
    required String username,
  }) async {
    final recoveryCodes = _generateRecoveryCodes();
    final hashedCodes = recoveryCodes.map(_hashRecoveryCode).toList();

    await _secureStorage.write(
      '${SecureStorageKeys.mfaRecoveryCodes}_$userId',
      jsonEncode(hashedCodes),
    );

    // Log recovery codes regeneration
    await _auditLogService?.logAuthEvent(
      action: 'MFA_RECOVERY_CODES_REGENERATED',
      username: username,
      userId: userId,
      success: true,
    );

    return recoveryCodes;
  }

  // Private helper methods

  String _base32Encode(List<int> bytes) {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final output = StringBuffer();

    int buffer = 0;
    int bitsInBuffer = 0;

    for (final byte in bytes) {
      buffer = (buffer << 8) | byte;
      bitsInBuffer += 8;

      while (bitsInBuffer >= 5) {
        final index = (buffer >> (bitsInBuffer - 5)) & 0x1F;
        output.write(base32Chars[index]);
        bitsInBuffer -= 5;
      }
    }

    if (bitsInBuffer > 0) {
      final index = (buffer << (5 - bitsInBuffer)) & 0x1F;
      output.write(base32Chars[index]);
    }

    return output.toString();
  }

  String _generateProvisioningUri({
    required String secret,
    required String username,
    required String issuer,
  }) {
    final label = Uri.encodeComponent('$issuer:$username');
    final params = {
      'secret': secret,
      'issuer': issuer,
      'algorithm': 'SHA1',
      'digits': totpDigits.toString(),
      'period': totpInterval.toString(),
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'otpauth://totp/$label?$queryString';
  }

  List<String> _generateRecoveryCodes() {
    final random = Random.secure();
    final codes = <String>[];

    for (int i = 0; i < recoveryCodeCount; i++) {
      final code = List.generate(
        recoveryCodeLength,
        (_) => random.nextInt(10).toString(),
      ).join();

      // Format as XXXX-XXXX for readability
      final formatted = '${code.substring(0, 4)}-${code.substring(4)}';
      codes.add(formatted);
    }

    return codes;
  }

  String _hashRecoveryCode(String code) {
    // Remove formatting
    final cleaned = code.replaceAll('-', '');
    final bytes = utf8.encode(cleaned);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Enforce MFA for admin accounts
  Future<bool> shouldEnforceMFA({
    required String role,
    bool enforceForAdmins = true,
    bool enforceForAll = false,
  }) async {
    if (enforceForAll) {
      return true;
    }

    if (enforceForAdmins && role == 'admin') {
      return true;
    }

    return false;
  }

  /// Get current TOTP code (for testing/debugging only)
  Future<String?> getCurrentTOTP(String userId) async {
    final secret = await _secureStorage.read('${SecureStorageKeys.mfaSecret}_$userId');

    if (secret == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return OTP.generateTOTPCodeString(
      secret,
      now,
      length: totpDigits,
      interval: totpInterval,
      algorithm: totpAlgorithm,
      isGoogle: true,
    );
  }
}

/// MFA setup data returned to user
class MFASetupData {
  final String secret;
  final List<String> recoveryCodes;
  final String provisioningUri;

  MFASetupData({
    required this.secret,
    required this.recoveryCodes,
    required this.provisioningUri,
  });

  /// Get QR code data (to be displayed to user)
  String get qrCodeData => provisioningUri;
}

/// MFA verification result
enum MFAVerificationResult {
  success,
  invalidCode,
  notEnabled,
  accountLocked,
}
