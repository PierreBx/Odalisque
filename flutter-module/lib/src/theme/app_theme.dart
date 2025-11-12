import 'package:flutter/material.dart';

/// App theme definitions inspired by Supabase's beautiful dark mode design.
///
/// Features:
/// - Deep black and elegant grey backgrounds
/// - High contrast text for readability
/// - Vibrant accent color for actions and highlights
/// - Subtle borders and elevations
/// - Support for both light and dark modes
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // Dark Theme Colors (Supabase-inspired)
  // ============================================================================

  /// Deepest background color - used for main app background
  static const Color darkBackground = Color(0xFF0E1117);

  /// Surface color - used for cards, dialogs, bottom sheets
  static const Color darkSurface = Color(0xFF1A1A1A);

  /// Elevated surface - used for app bar, navigation, elevated components
  static const Color darkSurfaceElevated = Color(0xFF2A2A2A);

  /// Border color - used for dividers, outlines, separators
  static const Color darkBorder = Color(0xFF2E2E2E);

  /// Subtle border - used for very subtle separations
  static const Color darkBorderSubtle = Color(0xFF1F1F1F);

  /// Primary text color - high contrast white
  static const Color darkTextPrimary = Color(0xFFF3F4F6);

  /// Secondary text color - medium contrast grey
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// Tertiary text color - low contrast grey for hints
  static const Color darkTextTertiary = Color(0xFF6B7280);

  /// Disabled text color
  static const Color darkTextDisabled = Color(0xFF4B5563);

  /// Accent/brand color - vibrant green (Supabase-inspired)
  static const Color darkAccent = Color(0xFF3ECF8E);

  /// Accent hover/pressed state
  static const Color darkAccentHover = Color(0xFF4ADE94);

  /// Accent color for dark surfaces (slightly brighter)
  static const Color darkAccentBright = Color(0xFF5AFF9F);

  /// Error color for dark mode
  static const Color darkError = Color(0xFFEF4444);

  /// Warning color for dark mode
  static const Color darkWarning = Color(0xFFF59E0B);

  /// Success color for dark mode (similar to accent but distinct)
  static const Color darkSuccess = Color(0xFF10B981);

  /// Info color for dark mode
  static const Color darkInfo = Color(0xFF3B82F6);

  // ============================================================================
  // Light Theme Colors
  // ============================================================================

  /// Light background color
  static const Color lightBackground = Color(0xFFFFFFFF);

  /// Light surface color
  static const Color lightSurface = Color(0xFFF9FAFB);

  /// Light elevated surface
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);

  /// Light border color
  static const Color lightBorder = Color(0xFFE5E7EB);

  /// Subtle border for light theme
  static const Color lightBorderSubtle = Color(0xFFF3F4F6);

  /// Primary text color for light theme
  static const Color lightTextPrimary = Color(0xFF111827);

  /// Secondary text color for light theme
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Tertiary text color for light theme
  static const Color lightTextTertiary = Color(0xFF9CA3AF);

  /// Disabled text color for light theme
  static const Color lightTextDisabled = Color(0xFFD1D5DB);

  /// Accent color for light theme (darker for better contrast)
  static const Color lightAccent = Color(0xFF10B981);

  /// Accent hover state for light theme
  static const Color lightAccentHover = Color(0xFF059669);

  /// Error color for light mode
  static const Color lightError = Color(0xFFDC2626);

  /// Warning color for light mode
  static const Color lightWarning = Color(0xFFD97706);

  /// Success color for light mode
  static const Color lightSuccess = Color(0xFF059669);

  /// Info color for light mode
  static const Color lightInfo = Color(0xFF2563EB);

  // ============================================================================
  // Theme Data Builders
  // ============================================================================

  /// Creates a dark ThemeData with Supabase-inspired colors
  static ThemeData darkTheme({Color? accentColor}) {
    final accent = accentColor ?? darkAccent;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: ColorScheme.dark(
        brightness: Brightness.dark,
        primary: accent,
        onPrimary: darkBackground,
        primaryContainer: darkSurfaceElevated,
        onPrimaryContainer: darkTextPrimary,
        secondary: darkAccentBright,
        onSecondary: darkBackground,
        secondaryContainer: darkSurface,
        onSecondaryContainer: darkTextSecondary,
        tertiary: darkInfo,
        onTertiary: darkBackground,
        error: darkError,
        onError: darkBackground,
        errorContainer: Color(0xFF2D1515),
        onErrorContainer: Color(0xFFFFB4AB),
        background: darkBackground,
        onBackground: darkTextPrimary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceVariant: darkSurfaceElevated,
        onSurfaceVariant: darkTextSecondary,
        outline: darkBorder,
        outlineVariant: darkBorderSubtle,
        shadow: Colors.black.withOpacity(0.5),
        scrim: Colors.black.withOpacity(0.8),
        inverseSurface: lightSurface,
        onInverseSurface: lightTextPrimary,
        inversePrimary: lightAccent,
      ),

      // Scaffold
      scaffoldBackgroundColor: darkBackground,

      // Card
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceElevated,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceElevated,
        selectedItemColor: accent,
        unselectedItemColor: darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: darkSurface,
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 14,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: IconThemeData(
        color: darkTextSecondary,
        size: 24,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: darkTextPrimary, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: darkTextPrimary, fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: darkTextPrimary, fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: darkTextPrimary, fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: darkTextPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: darkTextSecondary, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: darkTextTertiary, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: darkTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: darkTextTertiary, fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkError, width: 2),
        ),
        labelStyle: TextStyle(color: darkTextSecondary),
        hintStyle: TextStyle(color: darkTextTertiary),
        errorStyle: TextStyle(color: darkError),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: BorderSide(color: darkBorder, width: 1),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        deleteIconColor: darkTextSecondary,
        selectedColor: accent.withOpacity(0.2),
        secondarySelectedColor: accent.withOpacity(0.3),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(color: darkTextPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: darkTextPrimary, fontSize: 13),
        brightness: Brightness.dark,
        side: BorderSide(color: darkBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkBackground;
          }
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return darkBorder;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(darkBackground),
        side: BorderSide(color: darkBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return darkBorder;
        }),
      ),

      // Data table
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          color: darkTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 14,
        ),
        headingRowColor: MaterialStateProperty.all(darkSurfaceElevated),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent.withOpacity(0.08);
          }
          return null;
        }),
        dividerThickness: 1,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkSurfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: darkBorder, width: 1),
        ),
        textStyle: TextStyle(color: darkTextPrimary, fontSize: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: darkBorder,
        circularTrackColor: darkBorder,
      ),

      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceElevated,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: darkBorder, width: 1),
        ),
      ),
    );
  }

  /// Creates a light ThemeData
  static ThemeData lightTheme({Color? accentColor}) {
    final accent = accentColor ?? lightAccent;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.light(
        brightness: Brightness.light,
        primary: accent,
        onPrimary: Colors.white,
        primaryContainer: lightSurface,
        onPrimaryContainer: lightTextPrimary,
        secondary: lightAccent,
        onSecondary: Colors.white,
        secondaryContainer: lightSurfaceElevated,
        onSecondaryContainer: lightTextSecondary,
        tertiary: lightInfo,
        onTertiary: Colors.white,
        error: lightError,
        onError: Colors.white,
        errorContainer: Color(0xFFFEE2E2),
        onErrorContainer: Color(0xFF7F1D1D),
        background: lightBackground,
        onBackground: lightTextPrimary,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceVariant: lightSurfaceElevated,
        onSurfaceVariant: lightTextSecondary,
        outline: lightBorder,
        outlineVariant: lightBorderSubtle,
        shadow: Colors.black.withOpacity(0.1),
        scrim: Colors.black.withOpacity(0.5),
        inverseSurface: darkSurface,
        onInverseSurface: darkTextPrimary,
        inversePrimary: darkAccent,
      ),

      // Scaffold
      scaffoldBackgroundColor: lightBackground,

      // Card
      cardTheme: CardTheme(
        color: lightSurfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // App bar
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurfaceElevated,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightTextPrimary),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Bottom navigation bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurfaceElevated,
        selectedItemColor: accent,
        unselectedItemColor: lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: lightSurfaceElevated,
        elevation: 0,
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: lightSurfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightBorder, width: 1),
        ),
        titleTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: lightTextSecondary,
          fontSize: 14,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: IconThemeData(
        color: lightTextSecondary,
        size: 24,
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: TextStyle(color: lightTextPrimary, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: lightTextPrimary, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: lightTextPrimary, fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: lightTextPrimary, fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: lightTextTertiary, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: lightTextTertiary, fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightError, width: 2),
        ),
        labelStyle: TextStyle(color: lightTextSecondary),
        hintStyle: TextStyle(color: lightTextTertiary),
        errorStyle: TextStyle(color: lightError),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightTextPrimary,
          side: BorderSide(color: lightBorder, width: 1),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: lightSurface,
        deleteIconColor: lightTextSecondary,
        selectedColor: accent.withOpacity(0.1),
        secondarySelectedColor: accent.withOpacity(0.2),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(color: lightTextPrimary, fontSize: 13),
        secondaryLabelStyle: TextStyle(color: lightTextPrimary, fontSize: 13),
        brightness: Brightness.light,
        side: BorderSide(color: lightBorder, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return lightTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return lightBorder;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: lightBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent;
          }
          return lightBorder;
        }),
      ),

      // Data table
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          color: lightTextSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: TextStyle(
          color: lightTextPrimary,
          fontSize: 14,
        ),
        headingRowColor: MaterialStateProperty.all(lightSurface),
        dataRowColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accent.withOpacity(0.05);
          }
          return null;
        }),
        dividerThickness: 1,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: lightSurfaceElevated,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: lightBorder, width: 1),
        ),
        textStyle: TextStyle(color: lightTextPrimary, fontSize: 12),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Progress indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: lightBorder,
        circularTrackColor: lightBorder,
      ),

      // Snack bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightSurfaceElevated,
        contentTextStyle: TextStyle(color: lightTextPrimary),
        actionTextColor: accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: lightBorder, width: 1),
        ),
      ),
    );
  }
}
