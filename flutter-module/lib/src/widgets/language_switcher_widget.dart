import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

/// Simple icon button to toggle language between English and French.
///
/// Displays a language icon and toggles between EN/FR on tap.
///
/// Usage:
/// ```dart
/// AppBar(
///   actions: [
///     LanguageToggleButton(),
///   ],
/// )
/// ```
class LanguageToggleButton extends StatelessWidget {
  /// Optional tooltip text
  final String? tooltip;

  /// Optional icon
  final IconData? icon;

  const LanguageToggleButton({
    Key? key,
    this.tooltip,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return IconButton(
          icon: Icon(icon ?? Icons.language),
          tooltip: tooltip ?? 'Change language',
          onPressed: () => languageProvider.toggleLanguage(),
        );
      },
    );
  }
}

/// Dropdown selector for choosing language.
///
/// Shows all supported languages in a dropdown menu.
///
/// Usage:
/// ```dart
/// LanguageDropdown()
/// ```
class LanguageDropdown extends StatelessWidget {
  /// Optional label
  final String? label;

  /// Whether to show label
  final bool showLabel;

  const LanguageDropdown({
    Key? key,
    this.label,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Text(
                label ?? 'Language',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 12),
            ],
            DropdownButton<String>(
              value: languageProvider.languageCode,
              underline: Container(),
              items: LanguageProvider.supportedLocales.map((locale) {
                return DropdownMenuItem<String>(
                  value: locale.languageCode,
                  child: Row(
                    children: [
                      Text(_getFlagEmoji(locale.languageCode)),
                      const SizedBox(width: 8),
                      Text(languageProvider.getNativeLanguageName(
                        locale.languageCode,
                      )),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage(value);
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }
}

/// Segmented button style language selector.
///
/// Shows language options as toggle buttons.
///
/// Usage:
/// ```dart
/// LanguageSelector()
/// ```
class LanguageSelector extends StatelessWidget {
  /// Whether to show flags
  final bool showFlags;

  const LanguageSelector({
    Key? key,
    this.showFlags = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return SegmentedButton<String>(
          segments: LanguageProvider.supportedLocales.map((locale) {
            final code = locale.languageCode;
            return ButtonSegment<String>(
              value: code,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showFlags) ...[
                    Text(_getFlagEmoji(code)),
                    const SizedBox(width: 4),
                  ],
                  Text(code.toUpperCase()),
                ],
              ),
            );
          }).toList(),
          selected: {languageProvider.languageCode},
          onSelectionChanged: (Set<String> selected) {
            if (selected.isNotEmpty) {
              languageProvider.setLanguage(selected.first);
            }
          },
        );
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }
}

/// Settings tile for language selection.
///
/// Displays current language with icon and allows selection.
///
/// Usage:
/// ```dart
/// ListView(
///   children: [
///     LanguageSettingsTile(),
///   ],
/// )
/// ```
class LanguageSettingsTile extends StatelessWidget {
  /// Tile title
  final String? title;

  /// Tile subtitle
  final String? subtitle;

  const LanguageSettingsTile({
    Key? key,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(title ?? 'Language'),
          subtitle: subtitle != null
              ? Text(subtitle!)
              : Text(languageProvider.currentLanguageName),
          trailing: DropdownButton<String>(
            value: languageProvider.languageCode,
            underline: Container(),
            items: LanguageProvider.supportedLocales.map((locale) {
              return DropdownMenuItem<String>(
                value: locale.languageCode,
                child: Row(
                  children: [
                    Text(_getFlagEmoji(locale.languageCode)),
                    const SizedBox(width: 8),
                    Text(languageProvider.getNativeLanguageName(
                      locale.languageCode,
                    )),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                languageProvider.setLanguage(value);
              }
            },
          ),
        );
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }
}

/// Complete language customization card.
///
/// Shows current language, all options, and additional language settings.
///
/// Usage:
/// ```dart
/// LanguageCustomizationCard()
/// ```
class LanguageCustomizationCard extends StatelessWidget {
  /// Card title
  final String? title;

  /// Card subtitle
  final String? subtitle;

  const LanguageCustomizationCard({
    Key? key,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title ?? 'Language',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Current language
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getFlagEmoji(languageProvider.languageCode),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Language',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            languageProvider.currentLanguageName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Language selection
                Text(
                  'Select Language',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),

                // Language options
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: LanguageProvider.supportedLocales.map((locale) {
                    final code = locale.languageCode;
                    final isSelected = languageProvider.languageCode == code;

                    return InkWell(
                      onTap: () => languageProvider.setLanguage(code),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).dividerColor,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getFlagEmoji(code),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              languageProvider.getNativeLanguageName(code),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer
                                        : null,
                                  ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }
}
