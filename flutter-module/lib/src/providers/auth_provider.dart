import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/grist_service.dart';
import '../services/secure_storage_service.dart';
import '../services/audit_log_service.dart';
import '../services/rate_limit_service.dart';
import '../config/app_config.dart';

/// Manages authentication state with secure storage and audit logging.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastActivityTime;
  Timer? _sessionTimer;

  final GristService gristService;
  final AuthSettings authSettings;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Security services
  AuditLogService? _auditLogService;
  RateLimitService? _rateLimitService;

  AuthProvider({
    required this.gristService,
    required this.authSettings,
    AuditLogService? auditLogService,
    RateLimitService? rateLimitService,
  }) : _auditLogService = auditLogService,
       _rateLimitService = rateLimitService {
    _startSessionMonitoring();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  /// Start monitoring session timeout.
  void _startSessionMonitoring() {
    final session = authSettings.session;
    if (session == null || !session.autoLogoutOnTimeout) return;

    // Check every minute
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkSessionTimeout();
    });
  }

  /// Check if session has timed out.
  void _checkSessionTimeout() {
    if (_user == null || _lastActivityTime == null) return;

    final session = authSettings.session;
    if (session == null || !session.autoLogoutOnTimeout) return;

    final timeout = Duration(minutes: session.timeoutMinutes);
    final now = DateTime.now();
    final timeSinceActivity = now.difference(_lastActivityTime!);

    if (timeSinceActivity >= timeout) {
      logout(timedOut: true);
    }
  }

  /// Record user activity to reset timeout.
  void recordActivity() {
    _lastActivityTime = DateTime.now();
  }

  /// Initialize auth state from saved session.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _secureStorage.initialize();

      // Migrate from SharedPreferences if needed
      await _migrateLegacyStorage();

      final userEmail = await _secureStorage.read(SecureStorageKeys.userEmail);
      final userRole = await _secureStorage.read(SecureStorageKeys.userRole);
      final lastActivityStr = await _secureStorage.read(SecureStorageKeys.lastActivityTimestamp);

      if (userEmail != null && userRole != null) {
        _user = User(
          email: userEmail,
          role: userRole,
          active: true,
          additionalFields: {},
        );

        // Restore last activity time
        if (lastActivityStr != null) {
          _lastActivityTime = DateTime.parse(lastActivityStr);

          // Check if session has already timed out
          _checkSessionTimeout();
        } else {
          _lastActivityTime = DateTime.now();
        }
      }
    } catch (e) {
      _error = 'Failed to restore session: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Migrate from SharedPreferences to SecureStorage (one-time migration)
  Future<void> _migrateLegacyStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;

        // Migrate to secure storage
        await _secureStorage.write(SecureStorageKeys.userEmail, userMap['email'] as String);
        await _secureStorage.write(SecureStorageKeys.userRole, userMap['role'] as String);

        final lastActivity = prefs.getString('last_activity');
        if (lastActivity != null) {
          await _secureStorage.write(SecureStorageKeys.lastActivityTimestamp, lastActivity);
        }

        // Clear old SharedPreferences
        await prefs.remove('user');
        await prefs.remove('last_activity');
      }
    } catch (e) {
      // Silently fail migration - not critical
    }
  }

  /// Login with email and password.
  Future<bool> login(String email, String password, {String? ipAddress}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check rate limit before attempting login
      if (_rateLimitService != null) {
        final rateLimitResult = await _rateLimitService!.checkLoginRateLimit(
          identifier: email,
          isIpBased: false,
        );

        if (!rateLimitResult.allowed) {
          _error = rateLimitResult.message;
          _isLoading = false;
          notifyListeners();

          // Log failed attempt due to rate limit
          await _auditLogService?.logAuthEvent(
            action: AuditActions.loginFailed,
            username: email,
            success: false,
            ipAddress: ipAddress,
            metadata: {'reason': 'rate_limit_exceeded'},
          );

          return false;
        }
      }

      final user = await gristService.authenticate(
        email,
        password,
        authSettings,
      );

      if (user != null && user.active) {
        _user = user;
        _lastActivityTime = DateTime.now();

        // Save session to secure storage
        await _secureStorage.write(SecureStorageKeys.userEmail, user.email);
        await _secureStorage.write(SecureStorageKeys.userRole, user.role);
        await _secureStorage.write(
          SecureStorageKeys.lastActivityTimestamp,
          _lastActivityTime!.toIso8601String(),
        );

        // Record successful login in rate limiter
        await _rateLimitService?.recordSuccessfulLogin(
          identifier: email,
          isIpBased: false,
        );

        // Log successful login
        await _auditLogService?.logAuthEvent(
          action: AuditActions.loginSuccess,
          username: email,
          userId: user.email,
          success: true,
          ipAddress: ipAddress,
          metadata: {
            'role': user.role,
            'email': user.email,
          },
        );

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = user == null
            ? 'Invalid credentials'
            : 'Account is inactive';

        // Record failed login attempt
        await _rateLimitService?.recordFailedLogin(
          identifier: email,
          isIpBased: false,
          metadata: _error,
        );

        // Log failed login
        await _auditLogService?.logAuthEvent(
          action: AuditActions.loginFailed,
          username: email,
          success: false,
          ipAddress: ipAddress,
          metadata: {'reason': _error},
        );

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';

      // Record failed login attempt
      await _rateLimitService?.recordFailedLogin(
        identifier: email,
        isIpBased: false,
        metadata: _error,
      );

      // Log failed login
      await _auditLogService?.logAuthEvent(
        action: AuditActions.loginFailed,
        username: email,
        success: false,
        ipAddress: ipAddress,
        metadata: {'reason': _error},
      );

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user.
  Future<void> logout({bool timedOut = false, String? ipAddress}) async {
    final username = _user?.email ?? 'unknown';
    final userId = _user?.email;

    _user = null;
    _lastActivityTime = null;

    if (timedOut) {
      _error = 'Session expired due to inactivity';
    } else {
      _error = null;
    }

    // Clear saved session from secure storage
    await _secureStorage.delete(SecureStorageKeys.userEmail);
    await _secureStorage.delete(SecureStorageKeys.userRole);
    await _secureStorage.delete(SecureStorageKeys.lastActivityTimestamp);

    // Log logout event
    await _auditLogService?.logAuthEvent(
      action: AuditActions.logout,
      username: username,
      userId: userId,
      success: true,
      ipAddress: ipAddress,
      metadata: {
        'timed_out': timedOut,
      },
    );

    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
