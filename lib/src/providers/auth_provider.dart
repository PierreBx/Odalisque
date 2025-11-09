import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/grist_service.dart';
import '../config/app_config.dart';

/// Manages authentication state.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastActivityTime;
  Timer? _sessionTimer;

  final GristService gristService;
  final AuthSettings authSettings;

  AuthProvider({
    required this.gristService,
    required this.authSettings,
  }) {
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
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      final lastActivityStr = prefs.getString('last_activity');

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _user = User(
          email: userMap['email'] as String,
          role: userMap['role'] as String,
          active: userMap['active'] as bool,
          additionalFields:
              Map<String, dynamic>.from(userMap['additionalFields'] ?? {}),
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

  /// Login with email and password.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await gristService.authenticate(
        email,
        password,
        authSettings,
      );

      if (user != null && user.active) {
        _user = user;
        _lastActivityTime = DateTime.now();

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(user.toJson()));
        await prefs.setString('last_activity', _lastActivityTime!.toIso8601String());

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = user == null
            ? 'Invalid credentials'
            : 'Account is inactive';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user.
  Future<void> logout({bool timedOut = false}) async {
    _user = null;
    _lastActivityTime = null;

    if (timedOut) {
      _error = 'Session expired due to inactivity';
    } else {
      _error = null;
    }

    // Clear saved session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('last_activity');

    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
