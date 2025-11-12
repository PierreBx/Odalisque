import 'package:shared_preferences.dart';
import 'dart:convert';

/// Security utilities for account lockout and authentication security.
///
/// Manages failed login attempt tracking and account lockout.
class SecurityUtils {
  static const String _prefsKeyPrefix = 'security_';
  static const String _failedAttemptsSuffix = '_failed_attempts';
  static const String _lockoutTimeSuffix = '_lockout_time';

  /// Maximum failed login attempts before lockout
  static const int maxFailedAttempts = 5;

  /// Lockout duration in minutes
  static const int lockoutDurationMinutes = 15;

  /// Record a failed login attempt for an email address
  static Future<void> recordFailedAttempt(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$email$_failedAttemptsSuffix';

    final currentAttempts = prefs.getInt(key) ?? 0;
    final newAttempts = currentAttempts + 1;

    await prefs.setInt(key, newAttempts);

    // If max attempts reached, lock the account
    if (newAttempts >= maxFailedAttempts) {
      await _lockAccount(email);
    }
  }

  /// Lock an account for a specified duration
  static Future<void> _lockAccount(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$email$_lockoutTimeSuffix';
    final lockoutTime = DateTime.now().add(
      Duration(minutes: lockoutDurationMinutes),
    );

    await prefs.setString(key, lockoutTime.toIso8601String());
  }

  /// Reset failed login attempts (called on successful login)
  static Future<void> resetFailedAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final attemptsKey = '$_prefsKeyPrefix$email$_failedAttemptsSuffix';
    final lockoutKey = '$_prefsKeyPrefix$email$_lockoutTimeSuffix';

    await prefs.remove(attemptsKey);
    await prefs.remove(lockoutKey);
  }

  /// Check if an account is locked
  static Future<bool> isAccountLocked(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$email$_lockoutTimeSuffix';
    final lockoutTimeStr = prefs.getString(key);

    if (lockoutTimeStr == null) return false;

    final lockoutTime = DateTime.parse(lockoutTimeStr);
    final now = DateTime.now();

    // If lockout time has passed, unlock the account
    if (now.isAfter(lockoutTime)) {
      await resetFailedAttempts(email);
      return false;
    }

    return true;
  }

  /// Get remaining lockout time in minutes
  static Future<int> getRemainingLockoutMinutes(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$email$_lockoutTimeSuffix';
    final lockoutTimeStr = prefs.getString(key);

    if (lockoutTimeStr == null) return 0;

    final lockoutTime = DateTime.parse(lockoutTimeStr);
    final now = DateTime.now();

    if (now.isAfter(lockoutTime)) {
      return 0;
    }

    final difference = lockoutTime.difference(now);
    return difference.inMinutes + 1;
  }

  /// Get number of failed login attempts
  static Future<int> getFailedAttempts(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefsKeyPrefix$email$_failedAttemptsSuffix';
    return prefs.getInt(key) ?? 0;
  }

  /// Get remaining attempts before lockout
  static Future<int> getRemainingAttempts(String email) async {
    final failedAttempts = await getFailedAttempts(email);
    return maxFailedAttempts - failedAttempts;
  }
}

/// Password reset utilities
class PasswordResetUtils {
  static const String _prefsKeyPrefix = 'password_reset_';
  static const String _tokenSuffix = '_token';
  static const String _expirationSuffix = '_expiration';

  /// Token validity duration in hours
  static const int tokenValidityHours = 1;

  /// Generate a password reset token for an email
  static Future<String> generateResetToken(String email) async {
    final prefs = await SharedPreferences.getInstance();

    // Generate a simple token (in production, use crypto-secure random)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final token = '$email-$timestamp'.hashCode.toString();

    final tokenKey = '$_prefsKeyPrefix$email$_tokenSuffix';
    final expirationKey = '$_prefsKeyPrefix$email$_expirationSuffix';

    final expiration = DateTime.now().add(
      Duration(hours: tokenValidityHours),
    );

    await prefs.setString(tokenKey, token);
    await prefs.setString(expirationKey, expiration.toIso8601String());

    return token;
  }

  /// Verify a password reset token
  static Future<bool> verifyResetToken(String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = '$_prefsKeyPrefix$email$_tokenSuffix';
    final expirationKey = '$_prefsKeyPrefix$email$_expirationSuffix';

    final storedToken = prefs.getString(tokenKey);
    final expirationStr = prefs.getString(expirationKey);

    if (storedToken == null || expirationStr == null) {
      return false;
    }

    final expiration = DateTime.parse(expirationStr);
    final now = DateTime.now();

    // Check if token has expired
    if (now.isAfter(expiration)) {
      await clearResetToken(email);
      return false;
    }

    return storedToken == token;
  }

  /// Clear password reset token
  static Future<void> clearResetToken(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenKey = '$_prefsKeyPrefix$email$_tokenSuffix';
    final expirationKey = '$_prefsKeyPrefix$email$_expirationSuffix';

    await prefs.remove(tokenKey);
    await prefs.remove(expirationKey);
  }
}

/// Audit logging utilities
class AuditLogger {
  static const String _prefsKey = 'audit_logs';
  static const int _maxLogsStored = 1000;

  /// Log an audit event
  static Future<void> log({
    required String userId,
    required String action,
    required String resource,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final logEntry = {
      'userId': userId,
      'action': action,
      'resource': resource,
      'details': details,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Get existing logs
    final logsJson = prefs.getString(_prefsKey);
    List<Map<String, dynamic>> logs = [];

    if (logsJson != null) {
      try {
        final decoded = json.decode(logsJson) as List;
        logs = decoded.cast<Map<String, dynamic>>();
      } catch (e) {
        // Invalid format, start fresh
        logs = [];
      }
    }

    // Add new log
    logs.add(logEntry);

    // Keep only most recent logs
    if (logs.length > _maxLogsStored) {
      logs = logs.sublist(logs.length - _maxLogsStored);
    }

    // Save logs
    await prefs.setString(_prefsKey, json.encode(logs));
  }

  /// Get audit logs
  static Future<List<Map<String, dynamic>>> getLogs({
    String? userId,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_prefsKey);

    if (logsJson == null) return [];

    try {
      final decoded = json.decode(logsJson) as List;
      List<Map<String, dynamic>> logs = decoded.cast<Map<String, dynamic>>();

      // Filter logs
      if (userId != null) {
        logs = logs.where((log) => log['userId'] == userId).toList();
      }

      if (action != null) {
        logs = logs.where((log) => log['action'] == action).toList();
      }

      if (startDate != null) {
        logs = logs.where((log) {
          final timestamp = DateTime.parse(log['timestamp'] as String);
          return timestamp.isAfter(startDate) || timestamp.isAtSameMomentAs(startDate);
        }).toList();
      }

      if (endDate != null) {
        logs = logs.where((log) {
          final timestamp = DateTime.parse(log['timestamp'] as String);
          return timestamp.isBefore(endDate) || timestamp.isAtSameMomentAs(endDate);
        }).toList();
      }

      return logs;
    } catch (e) {
      return [];
    }
  }

  /// Clear all audit logs
  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// Get logs count
  static Future<int> getLogsCount() async {
    final logs = await getLogs();
    return logs.length;
  }

  /// Common audit actions
  static const String actionLogin = 'LOGIN';
  static const String actionLogout = 'LOGOUT';
  static const String actionCreate = 'CREATE';
  static const String actionUpdate = 'UPDATE';
  static const String actionDelete = 'DELETE';
  static const String actionView = 'VIEW';
  static const String actionExport = 'EXPORT';
  static const String actionPasswordReset = 'PASSWORD_RESET';
  static const String actionAccountLocked = 'ACCOUNT_LOCKED';
}

/// Remember me functionality
class RememberMeUtils {
  static const String _prefsKey = 'remember_me';
  static const String _emailKey = 'remembered_email';

  /// Check if remember me is enabled
  static Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Set remember me preference
  static Future<void> setRememberMe(bool remember, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, remember);

    if (remember && email != null) {
      await prefs.setString(_emailKey, email);
    } else {
      await prefs.remove(_emailKey);
    }
  }

  /// Get remembered email
  static Future<String?> getRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = await isRememberMeEnabled();

    if (remember) {
      return prefs.getString(_emailKey);
    }

    return null;
  }

  /// Clear remember me data
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    await prefs.remove(_emailKey);
  }
}
