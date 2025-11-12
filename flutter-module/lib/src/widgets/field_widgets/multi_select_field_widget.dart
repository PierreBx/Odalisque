import 'package:flutter/material.dart';

/// A form field widget for selecting multiple values from a list.
///
/// Displays selected values as chips and provides a dialog for selection.
class MultiSelectFieldWidget extends StatefulWidget {
  /// The label text displayed above the field
  final String? label;

  /// The current selected values
  final List<String>? values;

  /// Callback when values change
  final ValueChanged<List<String>?>? onChanged;

  /// The list of available choices
  final List<String> choices;

  /// Whether the field is required
  final bool required;

  /// Custom validator function
  final String? Function(List<String>?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Hint text when no values are selected
  final String? hintText;

  /// Maximum number of selections allowed (null = unlimited)
  final int? maxSelections;

  const MultiSelectFieldWidget({
    super.key,
    this.label,
    this.values,
    this.onChanged,
    required this.choices,
    this.required = false,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.maxSelections,
  });

  @override
  State<MultiSelectFieldWidget> createState() => _MultiSelectFieldWidgetState();
}

class _MultiSelectFieldWidgetState extends State<MultiSelectFieldWidget> {
  List<String> _currentValues = [];

  @override
  void initState() {
    super.initState();
    _currentValues = widget.values ?? [];
  }

  @override
  void didUpdateWidget(MultiSelectFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) {
      _currentValues = widget.values ?? [];
    }
  }

  void _updateValues(List<String> values) {
    setState(() {
      _currentValues = values;
    });
    widget.onChanged?.call(values.isEmpty ? null : values);
  }

  void _removeValue(String value) {
    final newValues = List<String>.from(_currentValues);
    newValues.remove(value);
    _updateValues(newValues);
  }

  Future<void> _showSelectionDialog() async {
    if (!widget.enabled) return;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _MultiSelectDialog(
        title: widget.label ?? 'Select options',
        choices: widget.choices,
        selectedValues: _currentValues,
        maxSelections: widget.maxSelections,
      ),
    );

    if (result != null) {
      _updateValues(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: _currentValues,
      validator: (value) {
        if (widget.required && (value == null || value.isEmpty)) {
          return '${widget.label ?? "This field"} is required';
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            InkWell(
              onTap: widget.enabled ? _showSelectionDialog : null,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: formFieldState.hasError
                        ? Theme.of(context).colorScheme.error
                        : Colors.grey.shade400,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _currentValues.isEmpty
                    ? Text(
                        widget.hintText ?? 'Select options',
                        style: TextStyle(color: Colors.grey.shade600),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentValues.map((value) {
                          return Chip(
                            label: Text(value),
                            deleteIcon: widget.enabled
                                ? const Icon(Icons.close, size: 18)
                                : null,
                            onDeleted:
                                widget.enabled ? () => _removeValue(value) : null,
                          );
                        }).toList(),
                      ),
              ),
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  formFieldState.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            if (widget.maxSelections != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  '${_currentValues.length} / ${widget.maxSelections} selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Dialog for multi-select choice selection
class _MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> choices;
  final List<String> selectedValues;
  final int? maxSelections;

  const _MultiSelectDialog({
    required this.title,
    required this.choices,
    required this.selectedValues,
    this.maxSelections,
  });

  @override
  State<_MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<_MultiSelectDialog> {
  late Set<String> _selectedSet;
  late List<String> _filteredChoices;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSet = Set<String>.from(widget.selectedValues);
    _filteredChoices = widget.choices;
    _searchController.addListener(_filterChoices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChoices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredChoices = widget.choices;
      } else {
        _filteredChoices = widget.choices
            .where((choice) => choice.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _toggleSelection(String choice) {
    setState(() {
      if (_selectedSet.contains(choice)) {
        _selectedSet.remove(choice);
      } else {
        if (widget.maxSelections != null &&
            _selectedSet.length >= widget.maxSelections!) {
          // Show snackbar or don't add
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Maximum ${widget.maxSelections} selections allowed'),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selectedSet.add(choice);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            if (widget.maxSelections != null)
              Text(
                '${_selectedSet.length} / ${widget.maxSelections} selected',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _filteredChoices.isEmpty
                  ? const Center(
                      child: Text('No results found'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredChoices.length,
                      itemBuilder: (context, index) {
                        final choice = _filteredChoices[index];
                        final isSelected = _selectedSet.contains(choice);
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) => _toggleSelection(choice),
                          title: Text(choice),
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
          onPressed: () {
            Navigator.of(context).pop(_selectedSet.toList());
          },
          child: const Text('Done'),
        ),
      ],
    );
  }
}
