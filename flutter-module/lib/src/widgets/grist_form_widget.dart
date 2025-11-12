import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grist_config.dart';
import '../services/grist_service.dart';
import '../utils/validators.dart';
import '../utils/field_type_builder.dart';
import 'skeleton_loader.dart';
import '../utils/notifications.dart';
import 'file_upload_widget.dart';

/// A widget that displays Grist data in a form format.
///
/// This widget fetches a record from Grist and displays its fields in a form.
/// Fields in [readableAttributes] are shown as read-only, while fields in
/// [writableAttributes] are shown as editable text fields.
class GristFormWidget extends StatefulWidget {
  /// Configuration for the Grist data source
  final GristConfig config;

  /// The ID of the record to display/edit
  final int recordId;

  /// Callback invoked when the save button is pressed and save succeeds
  final VoidCallback? onSaved;

  /// Callback invoked when the delete button is pressed (optional)
  final VoidCallback? onDeleted;

  /// Whether to show the edit/save buttons (default: true)
  final bool showEditButton;

  /// Whether to show the delete button (default: false)
  final bool showDeleteButton;

  /// Custom validators for fields (fieldName -> FieldValidators)
  final Map<String, FieldValidators>? validators;

  /// Optional field configurations (fieldName -> config map with type, choices, etc.)
  final Map<String, Map<String, dynamic>>? fieldConfigs;

  const GristFormWidget({
    super.key,
    required this.config,
    required this.recordId,
    this.onSaved,
    this.onDeleted,
    this.showEditButton = true,
    this.showDeleteButton = false,
    this.validators,
    this.fieldConfigs,
  });

  @override
  State<GristFormWidget> createState() => _GristFormWidgetState();
}

class _GristFormWidgetState extends State<GristFormWidget> {
  Map<String, dynamic>? _record;
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _fieldValues = {}; // For non-text fields

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(GristFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if recordId or config changed
    if (oldWidget.recordId != widget.recordId ||
        oldWidget.config.tableId != widget.config.tableId) {
      _loadData();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gristService = context.read<GristService>();
      final record = await gristService.fetchRecord(
        widget.config.tableId,
        widget.recordId,
      );

      if (mounted) {
        setState(() {
          _record = record;
          _isLoading = false;
          _initializeForm();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _initializeForm() {
    if (_record == null) return;

    final fields = _record!['fields'] as Map<String, dynamic>? ?? {};

    // Initialize controllers for writable text-based fields
    for (var fieldName in widget.config.writableAttributes) {
      final fieldConfig = widget.fieldConfigs?[fieldName];
      final type = fieldConfig?['type'] as String?;
      final fieldValue = fields[fieldName];

      if (_isTextBasedField(type)) {
        _controllers[fieldName] = TextEditingController(
          text: fieldValue?.toString() ?? '',
        );
      } else {
        // Store value for non-text fields
        _fieldValues[fieldName] = fieldValue;
      }
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Collect updated fields from both controllers and field values
      final updatedFields = <String, dynamic>{};

      // Text-based fields
      for (var entry in _controllers.entries) {
        updatedFields[entry.key] = entry.value.text;
      }

      // Non-text fields (dates, booleans, choices, etc.)
      for (var entry in _fieldValues.entries) {
        updatedFields[entry.key] = entry.value;
      }

      final gristService = context.read<GristService>();
      await gristService.updateRecord(
        widget.config.tableId,
        widget.recordId,
        updatedFields,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        AppNotifications.showSuccess(
          context,
          'Record updated successfully',
        );

        // Reload data to reflect changes
        await _loadData();

        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        AppNotifications.showError(
          context,
          'Failed to save: $e',
        );
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text(
            'Are you sure you want to delete this record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final gristService = context.read<GristService>();
      await gristService.deleteRecord(
        widget.config.tableId,
        widget.recordId,
      );

      if (mounted) {
        AppNotifications.showSuccess(
          context,
          'Record deleted successfully',
        );

        widget.onDeleted?.call();
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(
          context,
          'Failed to delete: $e',
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset controllers and values to original data
      final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
      for (var entry in _controllers.entries) {
        entry.value.text = fields[entry.key]?.toString() ?? '';
      }
      for (var entry in _fieldValues.entries) {
        _fieldValues[entry.key] = fields[entry.key];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FormSkeletonLoader(fieldCount: 6);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_record == null) {
      return const Center(child: Text('Record not found'));
    }

    final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
    final allAttributes = widget.config.allAttributes;

    return Column(
      children: [
        // Action buttons at top
        if (!_isEditing && (widget.showEditButton || widget.showDeleteButton))
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.showEditButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                if (widget.showEditButton && widget.showDeleteButton)
                  const SizedBox(width: 16),
                if (widget.showDeleteButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteRecord,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Form content
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...allAttributes.map((fieldName) {
                  final value = fields[fieldName];
                  final isWritable =
                      widget.config.writableAttributes.contains(fieldName);

                  // Build field configuration
                  final fieldConfig = widget.fieldConfigs?[fieldName] ??
                      {'type': 'text', 'label': _formatFieldName(fieldName)};

                  // Set readonly if not writable or not in edit mode
                  final effectiveConfig = Map<String, dynamic>.from(fieldConfig);
                  if (!_isEditing || !isWritable) {
                    effectiveConfig['readonly'] = true;
                  }
                  if (fieldConfig['label'] == null) {
                    effectiveConfig['label'] = _formatFieldName(fieldName);
                  }

                  // Use FieldTypeBuilder for consistent field rendering
                  return FieldTypeBuilder.buildField(
                    fieldName: fieldName,
                    fieldConfig: effectiveConfig,
                    controller: _controllers[fieldName],
                    value: _fieldValues[fieldName] ?? value,
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
                    enabled: _isEditing && isWritable && !_isSaving,
                    validators: widget.validators?[fieldName],
                  );
                }),
              ],
            ),
          ),
        ),

        // Bottom buttons (Save/Cancel when editing)
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _cancelEdit,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Formats a field name from snake_case or camelCase to Title Case
  String _formatFieldName(String fieldName) {
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
}
