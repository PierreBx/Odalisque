import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// A widget for toggling between light and dark themes.
///
/// Features:
/// - Icon button for quick toggle
/// - Animated transition
/// - Respects current theme
/// - Optional tooltip
class ThemeToggleButton extends StatelessWidget {
  /// Tooltip text (defaults to "Toggle theme")
  final String? tooltip;

  /// Icon size
  final double iconSize;

  /// Custom icon color
  final Color? iconColor;

  const ThemeToggleButton({
    Key? key,
    this.tooltip,
    this.iconSize = 24,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode(context);
        final icon = isDark ? Icons.light_mode : Icons.dark_mode;

        return IconButton(
          icon: Icon(icon, size: iconSize),
          color: iconColor ?? Theme.of(context).iconTheme.color,
          tooltip: tooltip ?? (isDark ? 'Switch to light mode' : 'Switch to dark mode'),
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }
}

/// A segmented button for selecting theme mode (light/dark/system).
///
/// Features:
/// - Three options: Light, Dark, System
/// - Material 3 design
/// - Shows current selection
/// - Auto-updates on theme change
class ThemeModeSelector extends StatelessWidget {
  /// Whether to show labels (defaults to true)
  final bool showLabels;

  /// Custom segment colors
  final Color? selectedColor;
  final Color? unselectedColor;

  const ThemeModeSelector({
    Key? key,
    this.showLabels = true,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: showLabels ? Text('Light') : SizedBox.shrink(),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: showLabels ? Text('Dark') : SizedBox.shrink(),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto),
              label: showLabels ? Text('Auto') : SizedBox.shrink(),
            ),
          ],
          selected: {themeProvider.themeMode},
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            themeProvider.setThemeMode(newSelection.first);
          },
        );
      },
    );
  }
}

/// A switch widget for toggling between light and dark modes.
///
/// Features:
/// - Clean switch UI
/// - Optional label text
/// - Follows Material 3 design
class ThemeModeSwitch extends StatelessWidget {
  /// Label text to show next to the switch
  final String? label;

  /// Whether to show icons in the switch track
  final bool showIcons;

  const ThemeModeSwitch({
    Key? key,
    this.label,
    this.showIcons = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode(context);

        Widget switchWidget = Switch(
          value: isDark,
          onChanged: (_) => themeProvider.toggleTheme(),
        );

        if (label != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDark && showIcons)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.light_mode,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(width: 12),
              switchWidget,
              if (isDark && showIcons)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.dark_mode,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
            ],
          );
        }

        return switchWidget;
      },
    );
  }
}

/// A list tile for theme selection in settings.
///
/// Features:
/// - Title and subtitle
/// - Leading icon
/// - Trailing theme mode selector
/// - Follows Material 3 design
class ThemeSettingsTile extends StatelessWidget {
  /// Title text (defaults to "Theme")
  final String title;

  /// Subtitle text
  final String? subtitle;

  /// Whether to show the segmented button selector (defaults to true)
  /// If false, shows a simple toggle switch instead
  final bool useSegmentedButton;

  const ThemeSettingsTile({
    Key? key,
    this.title = 'Theme',
    this.subtitle,
    this.useSegmentedButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (useSegmentedButton) ...[
            SizedBox(height: 12),
            ThemeModeSelector(showLabels: true),
          ] else ...[
            SizedBox(height: 8),
            ThemeModeSwitch(label: 'Dark mode'),
          ],
        ],
      ),
    );
  }
}

/// A card widget for theme customization.
///
/// Features:
/// - Theme mode selection
/// - Accent color picker (optional)
/// - Preview of current theme
/// - Material 3 card design
class ThemeCustomizationCard extends StatelessWidget {
  /// Whether to show the accent color picker
  final bool showAccentColorPicker;

  /// Available accent colors for the picker
  final List<Color>? accentColors;

  const ThemeCustomizationCard({
    Key? key,
    this.showAccentColorPicker = true,
    this.accentColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultAccentColors = accentColors ?? [
      Color(0xFF3ECF8E), // Supabase green
      Color(0xFF10B981), // Emerald
      Color(0xFF3B82F6), // Blue
      Color(0xFF8B5CF6), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFFF59E0B), // Amber
      Color(0xFFEF4444), // Red
      Color(0xFF06B6D4), // Cyan
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Customize how the app looks',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 20),

            // Theme mode selector
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 12),
            ThemeModeSelector(showLabels: true),

            if (showAccentColorPicker) ...[
              SizedBox(height: 24),
              Text(
                'Accent Color',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 12),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: defaultAccentColors.map((color) {
                      final isSelected = themeProvider.customAccentColor == color;
                      return InkWell(
                        onTap: () => themeProvider.setAccentColor(color),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
