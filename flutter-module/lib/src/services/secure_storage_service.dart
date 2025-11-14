import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data using platform-specific secure storage
/// iOS: Keychain, Android: Keystore
///
/// Provides encrypted storage for:
/// - Authentication tokens
/// - API keys
/// - Session data
/// - User credentials
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  SecureStorageService._internal();

  late final FlutterSecureStorage _storage;
  bool _initialized = false;

  /// Initialize the secure storage with platform-specific options
  Future<void> initialize() async {
    if (_initialized) return;

    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    );

    const iosOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    );

    const linuxOptions = LinuxOptions();
    const windowsOptions = WindowsOptions();
    const webOptions = WebOptions();
    const macOsOptions = MacOsOptions();

    _storage = FlutterSecureStorage(
      aOptions: androidOptions,
      iOptions: iosOptions,
      lOptions: linuxOptions,
      wOptions: windowsOptions,
      webOptions: webOptions,
      mOptions: macOsOptions,
    );

    _initialized = true;
  }

  /// Write a value to secure storage
  Future<void> write(String key, String value) async {
    await _ensureInitialized();
    await _storage.write(key: key, value: value);
  }

  /// Read a value from secure storage
  Future<String?> read(String key) async {
    await _ensureInitialized();
    return await _storage.read(key: key);
  }

  /// Delete a value from secure storage
  Future<void> delete(String key) async {
    await _ensureInitialized();
    await _storage.delete(key: key);
  }

  /// Check if a key exists in secure storage
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return await _storage.containsKey(key: key);
  }

  /// Delete all values from secure storage
  Future<void> deleteAll() async {
    await _ensureInitialized();
    await _storage.deleteAll();
  }

  /// Get all keys from secure storage
  Future<Map<String, String>> readAll() async {
    await _ensureInitialized();
    return await _storage.readAll();
  }

  /// Migrate data from SharedPreferences to secure storage
  /// Returns true if migration was successful
  Future<bool> migrateFromSharedPreferences(
    Map<String, String> data,
  ) async {
    try {
      await _ensureInitialized();

      for (final entry in data.entries) {
        await write(entry.key, entry.value);
      }

      return true;
    } catch (e) {
      // Log error but don't throw to avoid breaking the app
      return false;
    }
  }

  /// Ensure storage is initialized before use
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }
}

/// Storage keys used throughout the app
class SecureStorageKeys {
  // Authentication
  static const String userId = 'user_id';
  static const String username = 'username';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String authToken = 'auth_token';
  static const String sessionToken = 'session_token';
  static const String lastActivityTimestamp = 'last_activity_timestamp';
  static const String rememberMe = 'remember_me';

  // API Configuration
  static const String gristApiKey = 'grist_api_key';
  static const String gristBaseUrl = 'grist_base_url';
  static const String gristDocId = 'grist_doc_id';

  // Security
  static const String failedLoginAttempts = 'failed_login_attempts';
  static const String accountLockedUntil = 'account_locked_until';
  static const String lastLoginIp = 'last_login_ip';
  static const String deviceFingerprint = 'device_fingerprint';

  // MFA
  static const String mfaSecret = 'mfa_secret';
  static const String mfaEnabled = 'mfa_enabled';
  static const String mfaRecoveryCodes = 'mfa_recovery_codes';

  // Session Management
  static const String activeSessionId = 'active_session_id';
  static const String sessionExpiresAt = 'session_expires_at';
}
