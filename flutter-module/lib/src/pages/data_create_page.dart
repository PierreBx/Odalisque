import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';
import '../utils/validators.dart';
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
  final Map<String, FileUploadResult?> _fileUploads = {};
  final Map<String, DateTime?> _dateValues = {};

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

      // Initialize appropriate controller based on type
      if (type != 'file' && type != 'date') {
        _controllers[fieldName] = TextEditingController();
      }

      // Initialize validators
      final validatorsList = fieldConfig['validators'] as List<dynamic>?;
      _validators[fieldName] = FieldValidators.fromList(validatorsList);
    }
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

      // Collect field values
      final fields = <String, dynamic>{};
      for (var fieldConfig in formFields) {
        final fieldName = fieldConfig['name'] as String?;
        if (fieldName == null) continue;

        final type = fieldConfig['type'] as String?;

        // Get value based on field type
        if (type == 'file') {
          final upload = _fileUploads[fieldName];
          if (upload != null) {
            // Store as data URL (base64) or file URL
            fields[fieldName] = upload.toDataUrl() ?? upload.fileUrl;
          }
        } else if (type == 'date') {
          final date = _dateValues[fieldName];
          if (date != null) {
            fields[fieldName] = DateFormat('yyyy-MM-dd').format(date);
          }
        } else {
          final controller = _controllers[fieldName];
          if (controller != null && controller.text.isNotEmpty) {
            fields[fieldName] = controller.text;
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

  Future<void> _pickDate(String fieldName) async {
    final initialDate = _dateValues[fieldName] ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateValues[fieldName] = picked;
      });
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
                  final label = fieldConfig['label'] as String? ?? fieldName;
                  final readonly = fieldConfig['readonly'] as bool? ?? false;
                  final type = fieldConfig['type'] as String?;

                  if (readonly) return const SizedBox.shrink();

                  // File upload field
                  if (type == 'file') {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FileUploadWidget(
                        label: label,
                        allowedExtensions:
                            (fieldConfig['allowed_extensions'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList(),
                        maxFileSize: fieldConfig['max_file_size'] as int?,
                        onFileSelected: (file) {
                          _fileUploads[fieldName!] = file;
                        },
                      ),
                    );
                  }

                  // Date picker field
                  if (type == 'date') {
                    final selectedDate = _dateValues[fieldName];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: _isSaving ? null : () => _pickDate(fieldName!),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: label,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(selectedDate)
                                : 'Select date',
                            style: selectedDate == null
                                ? TextStyle(color: Colors.grey.shade600)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }

                  // Regular text field
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _controllers[fieldName],
                      decoration: InputDecoration(
                        labelText: label,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: _getKeyboardType(type),
                      validator: _validators[fieldName]?.asFormValidator(),
                      enabled: !_isSaving,
                      maxLines: type == 'text' ? 3 : 1,
                    ),
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

  TextInputType _getKeyboardType(String? type) {
    switch (type) {
      case 'integer':
      case 'numeric':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }
}
