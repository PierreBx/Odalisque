import 'package:flutter/material.dart';

/// Base class for custom column renderers.
///
/// Column renderers allow customization of how data is displayed in tables.
/// Implement this class to create custom visualizations for specific data types.
abstract class ColumnRenderer {
  /// Render the cell value.
  ///
  /// [value] is the cell value to render.
  /// [record] is the complete record (for accessing related fields).
  /// [context] is the build context for theming.
  Widget render(
    dynamic value,
    Map<String, dynamic> record,
    BuildContext context,
  );

  /// Optional: Format value for export (CSV, Excel, PDF).
  ///
  /// By default returns the value's string representation.
  String formatForExport(dynamic value) {
    return value?.toString() ?? '';
  }
}

/// Configuration for a column renderer.
class ColumnRendererConfig {
  /// The column name this renderer applies to
  final String columnName;

  /// The renderer instance
  final ColumnRenderer renderer;

  const ColumnRendererConfig({
    required this.columnName,
    required this.renderer,
  });
}

/// Factory for creating renderers from configuration.
class RendererFactory {
  /// Create a renderer from YAML configuration.
  static ColumnRenderer? fromConfig(Map<String, dynamic> config) {
    final type = config['type'] as String?;

    if (type == null) return null;

    switch (type) {
      case 'status_badge':
        return StatusBadgeRenderer.fromConfig(config);

      case 'progress_bar':
        return ProgressBarRenderer.fromConfig(config);

      case 'currency':
        return CurrencyRenderer.fromConfig(config);

      case 'icon':
        return IconRenderer.fromConfig(config);

      case 'link':
        return LinkRenderer.fromConfig(config);

      case 'chip':
        return ChipRenderer.fromConfig(config);

      default:
        return null;
    }
  }
}

/// Renderer for status badges with color coding.
class StatusBadgeRenderer extends ColumnRenderer {
  /// Map of status values to colors
  final Map<String, Color> colorMap;

  /// Default color for unmapped statuses
  final Color defaultColor;

  /// Shape of the badge
  final BadgeShape shape;

  StatusBadgeRenderer({
    required this.colorMap,
    this.defaultColor = Colors.grey,
    this.shape = BadgeShape.rounded,
  });

  factory StatusBadgeRenderer.fromConfig(Map<String, dynamic> config) {
    final colorMapConfig = config['color_map'] as Map<String, dynamic>? ?? {};
    final colorMap = <String, Color>{};

    for (var entry in colorMapConfig.entries) {
      colorMap[entry.key] = _parseColor(entry.value as String);
    }

    return StatusBadgeRenderer(
      colorMap: colorMap,
      defaultColor: config['default_color'] != null
          ? _parseColor(config['default_color'] as String)
          : Colors.grey,
      shape: config['shape'] == 'pill' ? BadgeShape.pill : BadgeShape.rounded,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final status = value?.toString() ?? '';
    final color = colorMap[status] ?? defaultColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: shape == BadgeShape.pill
            ? BorderRadius.circular(100)
            : BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color _parseColor(String hex) {
    final hexColor = hex.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    }
    return Colors.grey;
  }
}

enum BadgeShape { rounded, pill }

/// Renderer for progress bars showing numeric values.
class ProgressBarRenderer extends ColumnRenderer {
  /// Minimum value (defaults to 0)
  final double min;

  /// Maximum value (defaults to 100)
  final double max;

  /// Progress bar color
  final Color color;

  /// Whether to show the percentage text
  final bool showText;

  /// Height of the progress bar
  final double height;

  ProgressBarRenderer({
    this.min = 0,
    this.max = 100,
    this.color = const Color(0xFF3ECF8E),
    this.showText = true,
    this.height = 24,
  });

  factory ProgressBarRenderer.fromConfig(Map<String, dynamic> config) {
    return ProgressBarRenderer(
      min: (config['min'] as num?)?.toDouble() ?? 0,
      max: (config['max'] as num?)?.toDouble() ?? 100,
      color: config['color'] != null
          ? StatusBadgeRenderer._parseColor(config['color'] as String)
          : Color(0xFF3ECF8E),
      showText: config['show_text'] as bool? ?? true,
      height: (config['height'] as num?)?.toDouble() ?? 24,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final numValue = (value is num) ? value.toDouble() : 0.0;
    final percentage = ((numValue - min) / (max - min)).clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Progress bar
          FractionallySizedBox(
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Text overlay
          if (showText)
            Center(
              child: Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: percentage > 0.5 ? Colors.white : Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  String formatForExport(dynamic value) {
    final numValue = (value is num) ? value.toDouble() : 0.0;
    return numValue.toStringAsFixed(2);
  }
}

/// Renderer for currency values with proper formatting.
class CurrencyRenderer extends ColumnRenderer {
  /// Currency symbol (e.g., '$', '€', '£')
  final String symbol;

  /// Number of decimal places
  final int decimalPlaces;

  /// Whether to use thousand separators
  final bool useGrouping;

  /// Text color for positive values
  final Color? positiveColor;

  /// Text color for negative values
  final Color? negativeColor;

  CurrencyRenderer({
    this.symbol = '\$',
    this.decimalPlaces = 2,
    this.useGrouping = true,
    this.positiveColor,
    this.negativeColor = Colors.red,
  });

  factory CurrencyRenderer.fromConfig(Map<String, dynamic> config) {
    return CurrencyRenderer(
      symbol: config['symbol'] as String? ?? '\$',
      decimalPlaces: config['decimal_places'] as int? ?? 2,
      useGrouping: config['use_grouping'] as bool? ?? true,
      positiveColor: config['positive_color'] != null
          ? StatusBadgeRenderer._parseColor(config['positive_color'] as String)
          : null,
      negativeColor: config['negative_color'] != null
          ? StatusBadgeRenderer._parseColor(config['negative_color'] as String)
          : Colors.red,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final numValue = (value is num) ? value.toDouble() : 0.0;
    final isNegative = numValue < 0;

    // Format number with grouping
    String formatted;
    if (useGrouping) {
      formatted = numValue.abs().toStringAsFixed(decimalPlaces).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else {
      formatted = numValue.abs().toStringAsFixed(decimalPlaces);
    }

    final displayText = '${isNegative ? '-' : ''}$symbol$formatted';

    Color? textColor;
    if (isNegative && negativeColor != null) {
      textColor = negativeColor;
    } else if (!isNegative && positiveColor != null) {
      textColor = positiveColor;
    }

    return Text(
      displayText,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  String formatForExport(dynamic value) {
    final numValue = (value is num) ? value.toDouble() : 0.0;
    return numValue.toStringAsFixed(decimalPlaces);
  }
}

/// Renderer for icons based on value.
class IconRenderer extends ColumnRenderer {
  /// Map of values to icon data
  final Map<String, IconData> iconMap;

  /// Default icon for unmapped values
  final IconData? defaultIcon;

  /// Icon size
  final double size;

  /// Map of values to colors
  final Map<String, Color>? colorMap;

  /// Default color
  final Color? defaultColor;

  IconRenderer({
    required this.iconMap,
    this.defaultIcon,
    this.size = 24,
    this.colorMap,
    this.defaultColor,
  });

  factory IconRenderer.fromConfig(Map<String, dynamic> config) {
    final iconMapConfig = config['icon_map'] as Map<String, dynamic>? ?? {};
    final iconMap = <String, IconData>{};

    for (var entry in iconMapConfig.entries) {
      final iconName = entry.value as String;
      iconMap[entry.key] = _getIconData(iconName);
    }

    final colorMapConfig = config['color_map'] as Map<String, dynamic>?;
    Map<String, Color>? colorMap;
    if (colorMapConfig != null) {
      colorMap = {};
      for (var entry in colorMapConfig.entries) {
        colorMap[entry.key] = StatusBadgeRenderer._parseColor(entry.value as String);
      }
    }

    return IconRenderer(
      iconMap: iconMap,
      defaultIcon: config['default_icon'] != null
          ? _getIconData(config['default_icon'] as String)
          : null,
      size: (config['size'] as num?)?.toDouble() ?? 24,
      colorMap: colorMap,
      defaultColor: config['default_color'] != null
          ? StatusBadgeRenderer._parseColor(config['default_color'] as String)
          : null,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final key = value?.toString() ?? '';
    final icon = iconMap[key] ?? defaultIcon ?? Icons.help_outline;
    final color = colorMap?[key] ?? defaultColor;

    return Icon(icon, size: size, color: color);
  }

  static IconData _getIconData(String name) {
    // Simple icon mapping - expand as needed
    switch (name) {
      case 'check':
      case 'check_circle':
        return Icons.check_circle;
      case 'cancel':
      case 'close':
        return Icons.cancel;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }
}

/// Renderer for clickable links/URLs.
class LinkRenderer extends ColumnRenderer {
  /// Whether to show the full URL or truncate it
  final bool truncate;

  /// Maximum length if truncating
  final int maxLength;

  /// Custom text to display instead of URL
  final String? displayText;

  LinkRenderer({
    this.truncate = true,
    this.maxLength = 30,
    this.displayText,
  });

  factory LinkRenderer.fromConfig(Map<String, dynamic> config) {
    return LinkRenderer(
      truncate: config['truncate'] as bool? ?? true,
      maxLength: config['max_length'] as int? ?? 30,
      displayText: config['display_text'] as String?,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final url = value?.toString() ?? '';
    if (url.isEmpty) return Text('');

    String displayValue = displayText ?? url;
    if (displayText == null && truncate && url.length > maxLength) {
      displayValue = '${url.substring(0, maxLength)}...';
    }

    return InkWell(
      onTap: () {
        // Launch URL - would need url_launcher package
        debugPrint('Opening URL: $url');
      },
      child: Text(
        displayValue,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

/// Renderer for chip-style display.
class ChipRenderer extends ColumnRenderer {
  /// Background color
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Whether to show delete icon
  final bool showDelete;

  ChipRenderer({
    this.backgroundColor,
    this.textColor,
    this.showDelete = false,
  });

  factory ChipRenderer.fromConfig(Map<String, dynamic> config) {
    return ChipRenderer(
      backgroundColor: config['background_color'] != null
          ? StatusBadgeRenderer._parseColor(config['background_color'] as String)
          : null,
      textColor: config['text_color'] != null
          ? StatusBadgeRenderer._parseColor(config['text_color'] as String)
          : null,
      showDelete: config['show_delete'] as bool? ?? false,
    );
  }

  @override
  Widget render(dynamic value, Map<String, dynamic> record, BuildContext context) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return SizedBox.shrink();

    return Chip(
      label: Text(text),
      backgroundColor: backgroundColor,
      labelStyle: textColor != null ? TextStyle(color: textColor) : null,
      deleteIcon: showDelete ? Icon(Icons.close, size: 18) : null,
      onDeleted: showDelete ? () {} : null,
    );
  }
}
