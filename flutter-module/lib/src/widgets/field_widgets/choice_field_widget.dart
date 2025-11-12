import 'package:flutter/material.dart';

/// A form field widget for selecting from a list of choices.
///
/// Provides a dropdown menu for selecting a single value from predefined options.
/// Supports both static options and dynamic options from an external source.
class ChoiceFieldWidget extends StatefulWidget {
  /// The label text displayed above the field
  final String? label;

  /// The current selected value
  final String? value;

  /// Callback when value is selected
  final ValueChanged<String?>? onChanged;

  /// The list of available choices
  final List<String> choices;

  /// Whether the field is required
  final bool required;

  /// Custom validator function
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Hint text when no value is selected
  final String? hintText;

  /// Whether to allow clearing the selection
  final bool allowClear;

  /// Whether to make the dropdown searchable (for long lists)
  final bool searchable;

  const ChoiceFieldWidget({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    required this.choices,
    this.required = false,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.allowClear = true,
    this.searchable = false,
  });

  @override
  State<ChoiceFieldWidget> createState() => _ChoiceFieldWidgetState();
}

class _ChoiceFieldWidgetState extends State<ChoiceFieldWidget> {
  String? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(ChoiceFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _updateValue(String? value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged?.call(value);
  }

  Future<void> _showSearchableDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _SearchableChoiceDialog(
        title: widget.label ?? 'Select an option',
        choices: widget.choices,
        currentValue: _currentValue,
      ),
    );

    if (result != null) {
      _updateValue(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.searchable && widget.choices.length > 10) {
      // Use searchable dialog for long lists
      return FormField<String>(
        initialValue: _currentValue,
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
              InkWell(
                onTap: widget.enabled ? _showSearchableDialog : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.label,
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_currentValue != null &&
                            widget.allowClear &&
                            widget.enabled)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () => _updateValue(null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8, right: 12),
                          child: Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    ),
                    errorText: formFieldState.errorText,
                    enabled: widget.enabled,
                  ),
                  child: Text(
                    _currentValue ?? (widget.hintText ?? 'Select an option'),
                    style: _currentValue == null
                        ? TextStyle(color: Colors.grey.shade600)
                        : null,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // Use standard dropdown for short lists
    return DropdownButtonFormField<String>(
      value: _currentValue,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        enabled: widget.enabled,
      ),
      hint: Text(widget.hintText ?? 'Select an option'),
      items: widget.choices.map((choice) {
        return DropdownMenuItem<String>(
          value: choice,
          child: Text(choice),
        );
      }).toList(),
      onChanged: widget.enabled ? _updateValue : null,
      validator: (value) {
        if (widget.required && (value == null || value.isEmpty)) {
          return '${widget.label ?? "This field"} is required';
        }
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      isExpanded: true,
    );
  }
}

/// Dialog for searchable choice selection
class _SearchableChoiceDialog extends StatefulWidget {
  final String title;
  final List<String> choices;
  final String? currentValue;

  const _SearchableChoiceDialog({
    required this.title,
    required this.choices,
    this.currentValue,
  });

  @override
  State<_SearchableChoiceDialog> createState() =>
      _SearchableChoiceDialogState();
}

class _SearchableChoiceDialogState extends State<_SearchableChoiceDialog> {
  late List<String> _filteredChoices;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
              autofocus: true,
            ),
            const SizedBox(height: 16),
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
                        final isSelected = choice == widget.currentValue;
                        return ListTile(
                          title: Text(choice),
                          selected: isSelected,
                          leading: isSelected
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                          onTap: () {
                            Navigator.of(context).pop(choice);
                          },
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
      ],
    );
  }
}
