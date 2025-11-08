import 'package:flutter/foundation.dart';
import 'package:shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/grist_service.dart';
import '../config/app_config.dart';

/// Manages authentication state.
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  final GristService gristService;
  final AuthSettings authSettings;

  AuthProvider({
    required this.gristService,
    required this.authSettings,
  });

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize auth state from saved session.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        _user = User(
          email: userMap['email'] as String,
          role: userMap['role'] as String,
          active: userMap['active'] as bool,
          additionalFields:
              Map<String, dynamic>.from(userMap['additionalFields'] ?? {}),
        );
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

        // Save session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(user.toJson()));

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
  Future<void> logout() async {
    _user = null;
    _error = null;

    // Clear saved session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    notifyListeners();
  }

  /// Clear error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
