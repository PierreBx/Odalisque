import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/grist_service.dart';

/// A widget for selecting multiple references to other records (many-to-many).
///
/// Features:
/// - Multi-select with chips display
/// - Search/filter across related records
/// - Display formatted labels from multiple fields
/// - Returns list of selected record IDs
/// - Configurable maximum selections
///
/// Example:
/// ```dart
/// MultiReferenceFieldWidget(
///   label: 'Team Members',
///   referenceTable: 'Users',
///   displayFields: ['name', 'email'],
///   valueField: 'id',
///   values: currentMemberIds,
///   onChanged: (recordIds) => setState(() => memberIds = recordIds),
/// )
/// ```
class MultiReferenceFieldWidget extends StatefulWidget {
  /// Label for the field
  final String label;

  /// The table to fetch reference records from
  final String referenceTable;

  /// Fields to display in the dropdown (e.g., ['name', 'email'])
  final List<String> displayFields;

  /// Field to use as the value (typically 'id')
  final String valueField;

  /// Currently selected values (list of record IDs)
  final List<dynamic>? values;

  /// Callback when selection changes
  final ValueChanged<List<dynamic>>? onChanged;

  /// Whether the field is required
  final bool required;

  /// Custom validator
  final String? Function(List<dynamic>?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Optional hint text
  final String? hint;

  /// Separator for display fields (default: ' - ')
  final String displaySeparator;

  /// Maximum number of selections (null = unlimited)
  final int? maxSelections;

  const MultiReferenceFieldWidget({
    super.key,
    required this.label,
    required this.referenceTable,
    required this.displayFields,
    this.valueField = 'id',
    this.values,
    this.onChanged,
    this.required = false,
    this.validator,
    this.enabled = true,
    this.hint,
    this.displaySeparator = ' - ',
    this.maxSelections,
  });

  @override
  State<MultiReferenceFieldWidget> createState() =>
      _MultiReferenceFieldWidgetState();
}

class _MultiReferenceFieldWidgetState extends State<MultiReferenceFieldWidget> {
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _selectedRecords = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void didUpdateWidget(MultiReferenceFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referenceTable != widget.referenceTable) {
      _loadRecords();
    }
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gristService = Provider.of<GristService>(context, listen: false);
      final records = await gristService.fetchRecords(widget.referenceTable);

      setState(() {
        _records = records;
        _isLoading = false;

        // Find selected records if values are set
        if (widget.values != null && widget.values!.isNotEmpty) {
          _selectedRecords = _records.where((r) {
            final value = _getFieldValue(r, widget.valueField);
            return widget.values!.contains(value);
          }).toList();
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  dynamic _getFieldValue(Map<String, dynamic> record, String fieldName) {
    final fields = record['fields'] as Map<String, dynamic>?;
    return fields?[fieldName];
  }

  String _formatDisplayText(Map<String, dynamic> record) {
    final parts = <String>[];
    for (final field in widget.displayFields) {
      final value = _getFieldValue(record, field);
      if (value != null && value.toString().isNotEmpty) {
        parts.add(value.toString());
      }
    }
    return parts.join(widget.displaySeparator);
  }

  void _showSelectionDialog() async {
    final selected = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (context) => _MultiSelectDialog(
        title: widget.label,
        records: _records,
        selectedRecords: _selectedRecords,
        formatDisplayText: _formatDisplayText,
        maxSelections: widget.maxSelections,
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedRecords = selected;
      });

      final selectedValues = _selectedRecords
          .map((r) => _getFieldValue(r, widget.valueField))
          .toList();
      widget.onChanged?.call(selectedValues);
    }
  }

  void _removeSelection(Map<String, dynamic> record) {
    setState(() {
      _selectedRecords.remove(record);
    });

    final selectedValues = _selectedRecords
        .map((r) => _getFieldValue(r, widget.valueField))
        .toList();
    widget.onChanged?.call(selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
            const SizedBox(height: 4),
            const Text(
              'Loading options...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Error loading options: $_error',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _loadRecords,
                    tooltip: 'Retry',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),

          // Selected items as chips
          if (_selectedRecords.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedRecords.map((record) {
                  return Chip(
                    label: Text(_formatDisplayText(record)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: widget.enabled
                        ? () => _removeSelection(record)
                        : null,
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 8),

          // Add button
          OutlinedButton.icon(
            onPressed: widget.enabled ? _showSelectionDialog : null,
            icon: const Icon(Icons.add),
            label: Text(
              _selectedRecords.isEmpty
                  ? 'Select ${widget.label}'
                  : 'Add More',
            ),
          ),

          // Show max selections info
          if (widget.maxSelections != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${_selectedRecords.length}/${widget.maxSelections} selected',
                style: TextStyle(
                  fontSize: 12,
                  color: _selectedRecords.length >= widget.maxSelections!
                      ? Colors.orange
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog for multi-select from available records
class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> records;
  final List<Map<String, dynamic>> selectedRecords;
  final String Function(Map<String, dynamic>) formatDisplayText;
  final int? maxSelections;

  const _MultiSelectDialog({
    required this.title,
    required this.records,
    required this.selectedRecords,
    required this.formatDisplayText,
    this.maxSelections,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late List<Map<String, dynamic>> _selectedRecords;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRecords = List.from(widget.selectedRecords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRecords {
    if (_searchQuery.isEmpty) {
      return widget.records;
    }
    return widget.records.where((record) {
      final displayText = widget.formatDisplayText(record).toLowerCase();
      return displayText.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool _isSelected(Map<String, dynamic> record) {
    return _selectedRecords.any((r) => r['id'] == record['id']);
  }

  void _toggleSelection(Map<String, dynamic> record) {
    setState(() {
      if (_isSelected(record)) {
        _selectedRecords.removeWhere((r) => r['id'] == record['id']);
      } else {
        if (widget.maxSelections == null ||
            _selectedRecords.length < widget.maxSelections!) {
          _selectedRecords.add(record);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maximum ${widget.maxSelections} selections allowed'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.title}'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Selection count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedRecords.length} selected',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (widget.maxSelections != null)
                  Text(
                    'Max: ${widget.maxSelections}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // List of records
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  final isSelected = _isSelected(record);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggleSelection(record),
                    title: Text(widget.formatDisplayText(record)),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedRecords),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
