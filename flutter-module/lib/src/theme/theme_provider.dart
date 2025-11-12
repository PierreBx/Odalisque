import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Provider for managing app theme state.
///
/// Features:
/// - Theme mode switching (light/dark/system)
/// - Custom accent color support
/// - Persistent theme preferences
/// - Notify listeners on theme changes
class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';

  ThemeMode _themeMode = ThemeMode.system;
  Color? _customAccentColor;
  SharedPreferences? _prefs;
  bool _initialized = false;

  ThemeProvider() {
    _loadPreferences();
  }

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Custom accent color (if set)
  Color? get customAccentColor => _customAccentColor;

  /// Whether the provider has loaded preferences
  bool get initialized => _initialized;

  /// Check if current theme is dark based on brightness
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Get the current theme data
  ThemeData getTheme({required bool isDark}) {
    if (isDark) {
      return AppTheme.darkTheme(accentColor: _customAccentColor);
    } else {
      return AppTheme.lightTheme(accentColor: _customAccentColor);
    }
  }

  /// Load preferences from shared preferences
  Future<void> _loadPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeString = _prefs?.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      // Load accent color
      final accentColorValue = _prefs?.getInt(_accentColorKey);
      if (accentColorValue != null) {
        _customAccentColor = Color(accentColorValue);
      }

      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  /// Set the theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      await _prefs?.setString(_themeModeKey, mode.toString());
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set a custom accent color
  Future<void> setAccentColor(Color color) async {
    if (_customAccentColor == color) return;

    _customAccentColor = color;
    notifyListeners();

    try {
      await _prefs?.setInt(_accentColorKey, color.value);
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  /// Clear custom accent color (use default)
  Future<void> clearAccentColor() async {
    if (_customAccentColor == null) return;

    _customAccentColor = null;
    notifyListeners();

    try {
      await _prefs?.remove(_accentColorKey);
    } catch (e) {
      debugPrint('Error clearing accent color: $e');
    }
  }

  /// Reset all theme preferences to defaults
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _customAccentColor = null;
    notifyListeners();

    try {
      await _prefs?.remove(_themeModeKey);
      await _prefs?.remove(_accentColorKey);
    } catch (e) {
      debugPrint('Error resetting theme preferences: $e');
    }
  }
}
