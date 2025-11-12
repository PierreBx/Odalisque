import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

/// Manages application language/locale state.
///
/// Provides language switching functionality with persistence.
/// Supports English (en) and French (fr) locales.
///
/// Usage:
/// ```dart
/// final languageProvider = Provider.of<LanguageProvider>(context);
/// await languageProvider.setLocale(Locale('fr'));
/// ```
class LanguageProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_locale';
  static const Locale _defaultLocale = Locale('en');

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('fr'), // French
  ];

  Locale _locale = _defaultLocale;

  /// Current locale
  Locale get locale => _locale;

  /// Get locale language code (e.g., 'en', 'fr')
  String get languageCode => _locale.languageCode;

  /// Check if locale is English
  bool get isEnglish => _locale.languageCode == 'en';

  /// Check if locale is French
  bool get isFrench => _locale.languageCode == 'fr';

  LanguageProvider() {
    _loadLocale();
  }

  /// Load saved locale from preferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_prefsKey);

      if (languageCode != null) {
        final savedLocale = Locale(languageCode);
        if (_isSupportedLocale(savedLocale)) {
          _locale = savedLocale;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to load locale: $e');
    }
  }

  /// Set application locale
  Future<void> setLocale(Locale locale) async {
    if (!_isSupportedLocale(locale)) {
      debugPrint('Unsupported locale: ${locale.languageCode}');
      return;
    }

    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (e) {
      debugPrint('Failed to save locale: $e');
    }
  }

  /// Set locale by language code
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Toggle between English and French
  Future<void> toggleLanguage() async {
    final newLocale = isEnglish ? const Locale('fr') : const Locale('en');
    await setLocale(newLocale);
  }

  /// Reset to default locale (English)
  Future<void> resetToDefault() async {
    await setLocale(_defaultLocale);
  }

  /// Check if locale is supported
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  /// Get localized language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }

  /// Get current language name
  String get currentLanguageName => getLanguageName(languageCode);

  /// Get native language name (in its own language)
  String getNativeLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }
}
