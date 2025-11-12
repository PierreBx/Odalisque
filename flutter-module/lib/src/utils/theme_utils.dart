import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';

/// Utilities for creating Flutter themes from configuration.
///
/// Now supports both legacy configuration-based themes and new
/// Supabase-inspired dark/light themes.
class ThemeUtils {
  /// Creates a ThemeData from theme settings (legacy method for backward compatibility).
  static ThemeData createTheme(ThemeSettings settings) {
    final primaryColor = _parseColor(settings.primaryColor);
    final secondaryColor = _parseColor(settings.secondaryColor);
    final errorColor = settings.errorColor != null
        ? _parseColor(settings.errorColor!)
        : Colors.red;

    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  /// Creates a dark theme with optional custom accent color.
  ///
  /// Uses the new AppTheme system with Supabase-inspired colors.
  /// Optionally override the accent color using settings or a custom color.
  static ThemeData createDarkTheme({
    ThemeSettings? settings,
    Color? accentColor,
  }) {
    Color? accent = accentColor;

    // If settings provided, try to use its primary color as accent
    if (accent == null && settings != null) {
      accent = _parseColor(settings.primaryColor);
    }

    return AppTheme.darkTheme(accentColor: accent);
  }

  /// Creates a light theme with optional custom accent color.
  ///
  /// Uses the new AppTheme system.
  /// Optionally override the accent color using settings or a custom color.
  static ThemeData createLightTheme({
    ThemeSettings? settings,
    Color? accentColor,
  }) {
    Color? accent = accentColor;

    // If settings provided, try to use its primary color as accent
    if (accent == null && settings != null) {
      accent = _parseColor(settings.primaryColor);
    }

    return AppTheme.lightTheme(accentColor: accent);
  }

  /// Creates both light and dark themes from settings.
  ///
  /// Returns a Map with 'light' and 'dark' keys for easy use with MaterialApp.
  static Map<String, ThemeData> createThemes({
    ThemeSettings? settings,
    Color? accentColor,
  }) {
    return {
      'light': createLightTheme(settings: settings, accentColor: accentColor),
      'dark': createDarkTheme(settings: settings, accentColor: accentColor),
    };
  }

  /// Parses a hex color string to Color.
  static Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.blue; // Default fallback
  }

  /// Get drawer background color from settings.
  static Color getDrawerBackground(ThemeSettings settings) {
    return _parseColor(settings.drawerBackground);
  }

  /// Get drawer text color from settings.
  static Color getDrawerTextColor(ThemeSettings settings) {
    return _parseColor(settings.drawerTextColor);
  }

  /// Helper to parse color from hex string (public version).
  static Color parseColor(String hexColor) => _parseColor(hexColor);
}
