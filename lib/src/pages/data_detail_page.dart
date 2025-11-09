import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';
import '../utils/validators.dart';

/// Form view for displaying and editing a single record.
class DataDetailPage extends StatefulWidget {
  final PageConfig config;
  final Map<String, dynamic> params;
  final Function(String, Map<String, dynamic>?) onNavigate;

  const DataDetailPage({
    super.key,
    required this.config,
    required this.params,
    required this.onNavigate,
  });

  @override
  State<DataDetailPage> createState() => _DataDetailPageState();
}

class _DataDetailPageState extends State<DataDetailPage> {
  Map<String, dynamic>? _record;
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FieldValidators> _validators = {};

  @override
  void initState() {
    super.initState();
    _loadData();
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
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;
      final recordIdParam = grist?['record_id_param'] as String?;

      if (tableName == null || recordIdParam == null) {
        throw Exception('Table name or record ID parameter not specified');
      }

      final recordId = widget.params[recordIdParam];
      if (recordId == null) {
        throw Exception('Record ID not provided');
      }

      final gristService = context.read<GristService>();
      final record = await gristService.fetchRecord(tableName, recordId as int);

      setState(() {
        _record = record;
        _isLoading = false;
        _initializeForm();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initializeForm() {
    if (_record == null) return;

    final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
    final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
    final form = grist?['form'] as Map<String, dynamic>?;
    final formFields =
        (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    for (var fieldConfig in formFields) {
      final fieldName = fieldConfig['name'] as String?;
      if (fieldName == null) continue;

      final readonly = fieldConfig['readonly'] as bool? ?? false;
      if (readonly) continue;

      // Initialize controller
      _controllers[fieldName] = TextEditingController(
        text: fields[fieldName]?.toString() ?? '',
      );

      // Initialize validators
      final validatorsList = fieldConfig['validators'] as List<dynamic>?;
      _validators[fieldName] = FieldValidators.fromList(validatorsList);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;
      final recordId = _record!['id'] as int;

      if (tableName == null) {
        throw Exception('Table name not specified');
      }

      // Collect updated fields
      final updatedFields = <String, dynamic>{};
      for (var entry in _controllers.entries) {
        updatedFields[entry.key] = entry.value.text;
      }

      final gristService = context.read<GristService>();
      await gristService.updateRecord(tableName, recordId, updatedFields);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload data to reflect changes
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this record? This action cannot be undone.'),
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
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;
      final recordId = _record!['id'] as int;

      if (tableName == null) {
        throw Exception('Table name not specified');
      }

      final gristService = context.read<GristService>();
      await gristService.deleteRecord(tableName, recordId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        final grist2 = widget.config.config?['grist'] as Map<String, dynamic>?;
        final form = grist2?['form'] as Map<String, dynamic>?;
        final backButton = form?['back_button'] as Map<String, dynamic>?;
        final navigateTo = backButton?['navigate_to'] as String?;

        if (navigateTo != null) {
          widget.onNavigate(navigateTo, null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset controllers to original values
      final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
      for (var entry in _controllers.entries) {
        entry.value.text = fields[entry.key]?.toString() ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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

    final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
    final form = grist?['form'] as Map<String, dynamic>?;
    final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
    final formFields =
        (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final backButton = form?['back_button'] as Map<String, dynamic>?;
    final editButton = form?['edit_button'] as Map<String, dynamic>?;
    final showEditButton = editButton?['enabled'] as bool? ?? true;
    final deleteButton = form?['delete_button'] as Map<String, dynamic>?;
    final showDeleteButton = deleteButton?['enabled'] as bool? ?? true;

    return Column(
      children: [
        // Action buttons at top
        if (!_isEditing && (showEditButton || showDeleteButton))
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (showEditButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: Text(editButton?['label'] as String? ?? 'Edit'),
                    ),
                  ),
                if (showEditButton && showDeleteButton) const SizedBox(width: 16),
                if (showDeleteButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _deleteRecord,
                      icon: const Icon(Icons.delete),
                      label: Text(deleteButton?['label'] as String? ?? 'Delete'),
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
                ...formFields.map((fieldConfig) {
                  final fieldName = fieldConfig['name'] as String?;
                  final label = fieldConfig['label'] as String? ?? fieldName;
                  final value = fields[fieldName];
                  final readonly = fieldConfig['readonly'] as bool? ?? false;
                  final type = fieldConfig['type'] as String?;

                  if (_isEditing && !readonly) {
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
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label ?? '',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            value?.toString() ?? '—',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  }
                }),
              ],
            ),
          ),
        ),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(16),
          child: _isEditing
              ? Row(
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
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: Text(backButton?['label'] as String? ?? 'Back'),
                    onPressed: () {
                      final navigateTo = backButton?['navigate_to'] as String?;
                      if (navigateTo != null) {
                        widget.onNavigate(navigateTo, null);
                      }
                    },
                  ),
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
