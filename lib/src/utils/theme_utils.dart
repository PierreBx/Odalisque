import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Utilities for creating Flutter themes from configuration.
class ThemeUtils {
  /// Creates a ThemeData from theme settings.
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
}
