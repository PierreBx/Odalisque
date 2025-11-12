import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/field_widgets/date_field_widget.dart';
import '../widgets/field_widgets/choice_field_widget.dart';
import '../widgets/field_widgets/boolean_field_widget.dart';
import '../widgets/field_widgets/multi_select_field_widget.dart';
import '../widgets/field_widgets/reference_field_widget.dart';
import '../widgets/field_widgets/multi_reference_field_widget.dart';
import '../widgets/file_upload_widget.dart';

/// Utility class for building form fields based on field type and configuration.
///
/// Intelligently selects the appropriate widget based on field metadata and
/// provides a unified interface for form field creation.
class FieldTypeBuilder {
  /// Builds a form field widget based on the field configuration.
  ///
  /// Parameters:
  /// - [fieldName]: The name/key of the field
  /// - [fieldConfig]: Configuration map from YAML or API
  /// - [controller]: TextEditingController for text-based fields
  /// - [value]: Current value for the field
  /// - [onChanged]: Callback when field value changes
  /// - [onFileSelected]: Callback for file upload fields
  /// - [enabled]: Whether the field is editable
  /// - [validators]: Optional validators for the field
  static Widget buildField({
    required String fieldName,
    required Map<String, dynamic> fieldConfig,
    TextEditingController? controller,
    dynamic value,
    ValueChanged<dynamic>? onChanged,
    ValueChanged<FileUploadResult>? onFileSelected,
    bool enabled = true,
    FieldValidators? validators,
  }) {
    final type = fieldConfig['type'] as String?;
    final label = fieldConfig['label'] as String? ?? _formatFieldName(fieldName);
    final required = fieldConfig['required'] as bool? ?? false;
    final readonly = fieldConfig['readonly'] as bool? ?? false;

    // Read-only fields (display only)
    if (readonly) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value?.toString() ?? '—',
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(),
          ],
        ),
      );
    }

    // Determine field type and build appropriate widget
    switch (type?.toLowerCase()) {
      case 'date':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DateFieldWidget(
            label: label,
            value: value is DateTime ? value : null,
            onChanged: onChanged,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            mode: DateFieldMode.date,
          ),
        );

      case 'datetime':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DateFieldWidget(
            label: label,
            value: value is DateTime ? value : null,
            onChanged: onChanged,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            mode: DateFieldMode.datetime,
          ),
        );

      case 'time':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DateFieldWidget(
            label: label,
            value: value is DateTime ? value : null,
            onChanged: onChanged,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            mode: DateFieldMode.time,
          ),
        );

      case 'choice':
      case 'select':
        final choices =
            (fieldConfig['choices'] as List<dynamic>?)?.cast<String>() ?? [];
        final searchable = fieldConfig['searchable'] as bool? ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChoiceFieldWidget(
            label: label,
            value: value?.toString(),
            onChanged: onChanged,
            choices: choices,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            searchable: searchable,
          ),
        );

      case 'multiselect':
      case 'multi_select':
        final choices =
            (fieldConfig['choices'] as List<dynamic>?)?.cast<String>() ?? [];
        final maxSelections = fieldConfig['max_selections'] as int?;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MultiSelectFieldWidget(
            label: label,
            values: value is List ? value.cast<String>() : null,
            onChanged: onChanged,
            choices: choices,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            maxSelections: maxSelections,
          ),
        );

      case 'boolean':
      case 'bool':
      case 'checkbox':
        final style = _getBooleanStyle(fieldConfig['style'] as String?);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BooleanFieldWidget(
            label: label,
            value: value is bool ? value : null,
            onChanged: onChanged,
            required: required,
            validator: validators?.asFormValidator(),
            enabled: enabled,
            style: style,
            subtitle: fieldConfig['subtitle'] as String?,
          ),
        );

      case 'reference':
      case 'ref':
        final referenceTable = fieldConfig['reference_table'] as String?;
        final displayFields =
            (fieldConfig['display_fields'] as List<dynamic>?)?.cast<String>() ??
                ['name'];
        final valueField = fieldConfig['value_field'] as String? ?? 'id';

        if (referenceTable == null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorText: 'Reference table not configured',
              ),
              enabled: false,
            ),
          );
        }

        return ReferenceFieldWidget(
          label: label,
          referenceTable: referenceTable,
          displayFields: displayFields,
          valueField: valueField,
          value: value,
          onChanged: onChanged,
          required: required,
          validator: validators?.asFormValidator(),
          enabled: enabled,
          hint: fieldConfig['hint'] as String?,
          displaySeparator: fieldConfig['display_separator'] as String? ?? ' - ',
          showClearButton: fieldConfig['show_clear_button'] as bool? ?? true,
        );

      case 'multi_reference':
      case 'reflist':
        final referenceTable = fieldConfig['reference_table'] as String?;
        final displayFields =
            (fieldConfig['display_fields'] as List<dynamic>?)?.cast<String>() ??
                ['name'];
        final valueField = fieldConfig['value_field'] as String? ?? 'id';

        if (referenceTable == null) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorText: 'Reference table not configured',
              ),
              enabled: false,
            ),
          );
        }

        return MultiReferenceFieldWidget(
          label: label,
          referenceTable: referenceTable,
          displayFields: displayFields,
          valueField: valueField,
          values: value is List ? value : null,
          onChanged: onChanged,
          required: required,
          enabled: enabled,
          hint: fieldConfig['hint'] as String?,
          displaySeparator: fieldConfig['display_separator'] as String? ?? ' - ',
          maxSelections: fieldConfig['max_selections'] as int?,
        );

      case 'file':
      case 'attachment':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FileUploadWidget(
            label: label,
            allowedExtensions:
                (fieldConfig['allowed_extensions'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList(),
            maxFileSize: fieldConfig['max_file_size'] as int?,
            onFileSelected: onFileSelected,
            readOnly: !enabled,
          ),
        );

      case 'integer':
      case 'numeric':
      case 'number':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validators?.asFormValidator(),
            enabled: enabled,
          ),
        );

      case 'email':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: validators?.asFormValidator(),
            enabled: enabled,
          ),
        );

      case 'url':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            validator: validators?.asFormValidator(),
            enabled: enabled,
          ),
        );

      case 'phone':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: validators?.asFormValidator(),
            enabled: enabled,
          ),
        );

      case 'multiline':
      case 'textarea':
      case 'text':
      default:
        final maxLines = fieldConfig['max_lines'] as int? ?? 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            maxLines: maxLines,
            validator: validators?.asFormValidator(),
            enabled: enabled,
          ),
        );
    }
  }

  /// Auto-detects field type from Grist column metadata.
  ///
  /// Maps Grist column types to our field types.
  static String detectFieldType(Map<String, dynamic> columnMetadata) {
    final gristType = columnMetadata['type'] as String?;

    switch (gristType?.toLowerCase()) {
      case 'date':
        return 'date';
      case 'datetime':
        return 'datetime';
      case 'bool':
        return 'boolean';
      case 'int':
        return 'integer';
      case 'numeric':
        return 'numeric';
      case 'choice':
        return 'choice';
      case 'choicelist':
        return 'multiselect';
      case 'attachments':
        return 'file';
      case 'text':
      default:
        // Check if it's a long text field
        final widgetOptions = columnMetadata['widgetOptions'] as Map?;
        if (widgetOptions?['widget'] == 'TextBox') {
          return 'multiline';
        }
        return 'text';
    }
  }

  /// Extracts choices from Grist column metadata for choice fields.
  static List<String>? extractChoices(Map<String, dynamic> columnMetadata) {
    final widgetOptions =
        columnMetadata['widgetOptions'] as Map<String, dynamic>?;
    final choices = widgetOptions?['choices'] as List<dynamic>?;

    if (choices != null) {
      return choices.cast<String>();
    }

    return null;
  }

  /// Formats a field name from snake_case or camelCase to Title Case
  static String _formatFieldName(String fieldName) {
    // Convert snake_case to spaces
    String formatted = fieldName.replaceAll('_', ' ');

    // Split on capital letters for camelCase
    formatted = formatted.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );

    // Capitalize first letter of each word
    return formatted.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ').trim();
  }

  /// Gets the boolean field style from string configuration
  static BooleanFieldStyle _getBooleanStyle(String? style) {
    switch (style?.toLowerCase()) {
      case 'switch':
        return BooleanFieldStyle.switchToggle;
      case 'radio':
        return BooleanFieldStyle.radio;
      case 'checkbox':
      default:
        return BooleanFieldStyle.checkbox;
    }
  }
}
