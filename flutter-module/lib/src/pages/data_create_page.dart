import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';
import '../utils/validators.dart';
import '../utils/field_type_builder.dart';
import '../widgets/file_upload_widget.dart';
import '../utils/notifications.dart';

/// Form view for creating a new record.
class DataCreatePage extends StatefulWidget {
  final PageConfig config;
  final Function(String, Map<String, dynamic>?) onNavigate;

  const DataCreatePage({
    super.key,
    required this.config,
    required this.onNavigate,
  });

  @override
  State<DataCreatePage> createState() => _DataCreatePageState();
}

class _DataCreatePageState extends State<DataCreatePage> {
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FieldValidators> _validators = {};
  final Map<String, dynamic> _fieldValues = {}; // For all non-text fields

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeForm() {
    final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
    final form = grist?['form'] as Map<String, dynamic>?;
    final formFields =
        (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    for (var fieldConfig in formFields) {
      final fieldName = fieldConfig['name'] as String?;
      if (fieldName == null) continue;

      final readonly = fieldConfig['readonly'] as bool? ?? false;
      if (readonly) continue;

      final type = fieldConfig['type'] as String?;

      // Initialize appropriate controller or value based on type
      if (_isTextBasedField(type)) {
        _controllers[fieldName] = TextEditingController();
      }
      // Non-text fields will be stored in _fieldValues as they are updated

      // Initialize validators
      final validatorsList = fieldConfig['validators'] as List<dynamic>?;
      _validators[fieldName] = FieldValidators.fromList(validatorsList);
    }
  }

  bool _isTextBasedField(String? type) {
    return type == null ||
        type == 'text' ||
        type == 'multiline' ||
        type == 'textarea' ||
        type == 'email' ||
        type == 'url' ||
        type == 'phone' ||
        type == 'integer' ||
        type == 'numeric' ||
        type == 'number';
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;

      if (tableName == null) {
        throw Exception('Table name not specified');
      }

      final form = grist['form'] as Map<String, dynamic>?;
      final formFields =
          (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

      // Collect field values from both controllers and field values
      final fields = <String, dynamic>{};

      // Text-based fields
      for (var entry in _controllers.entries) {
        if (entry.value.text.isNotEmpty) {
          fields[entry.key] = entry.value.text;
        }
      }

      // Non-text fields (dates, booleans, choices, files, etc.)
      for (var entry in _fieldValues.entries) {
        final value = entry.value;
        if (value != null) {
          // Special handling for different types
          if (value is DateTime) {
            // Format dates for Grist
            fields[entry.key] = DateFormat('yyyy-MM-dd').format(value);
          } else if (value is FileUploadResult) {
            // Store file as data URL or file URL
            fields[entry.key] = value.toDataUrl() ?? value.fileUrl;
          } else {
            fields[entry.key] = value;
          }
        }
      }

      final gristService = context.read<GristService>();
      final newRecordId = await gristService.createRecord(tableName, fields);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        AppNotifications.showSuccess(
          context,
          'Record created successfully (ID: $newRecordId)',
        );

        // Navigate back
        final backButton = form?['back_button'] as Map<String, dynamic>?;
        final navigateTo = backButton?['navigate_to'] as String?;

        if (navigateTo != null) {
          widget.onNavigate(navigateTo, null);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        AppNotifications.showError(
          context,
          'Failed to create record: $e',
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
    final form = grist?['form'] as Map<String, dynamic>?;
    final formFields =
        (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final backButton = form?['back_button'] as Map<String, dynamic>?;

    return Column(
      children: [
        // Form content
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Create New Record',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),

                ...formFields.map((fieldConfig) {
                  final fieldName = fieldConfig['name'] as String?;
                  if (fieldName == null) return const SizedBox.shrink();

                  final readonly = fieldConfig['readonly'] as bool? ?? false;
                  if (readonly) return const SizedBox.shrink();

                  // Use FieldTypeBuilder to create the appropriate field widget
                  return FieldTypeBuilder.buildField(
                    fieldName: fieldName,
                    fieldConfig: fieldConfig,
                    controller: _controllers[fieldName],
                    value: _fieldValues[fieldName],
                    onChanged: (newValue) {
                      if (_isTextBasedField(fieldConfig['type'] as String?)) {
                        // Text fields are handled by controller
                      } else {
                        // Non-text fields update _fieldValues
                        setState(() {
                          _fieldValues[fieldName] = newValue;
                        });
                      }
                    },
                    onFileSelected: (file) {
                      setState(() {
                        _fieldValues[fieldName] = file;
                      });
                    },
                    enabled: !_isSaving,
                    validators: _validators[fieldName],
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving
                      ? null
                      : () {
                          final navigateTo = backButton?['navigate_to'] as String?;
                          if (navigateTo != null) {
                            widget.onNavigate(navigateTo, null);
                          }
                        },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
