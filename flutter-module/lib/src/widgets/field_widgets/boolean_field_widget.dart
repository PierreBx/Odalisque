import 'package:flutter/material.dart';

/// A form field widget for boolean (yes/no) values.
///
/// Provides checkbox, switch, or radio button styles for boolean input.
class BooleanFieldWidget extends StatefulWidget {
  /// The label text displayed next to the field
  final String? label;

  /// The current boolean value
  final bool? value;

  /// Callback when value changes
  final ValueChanged<bool?>? onChanged;

  /// Whether the field is required
  final bool required;

  /// Custom validator function
  final String? Function(bool?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// The style of boolean input (checkbox, switch, or radio)
  final BooleanFieldStyle style;

  /// Optional subtitle text
  final String? subtitle;

  /// Whether to allow null/indeterminate state (for checkbox only)
  final bool tristate;

  const BooleanFieldWidget({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.required = false,
    this.validator,
    this.enabled = true,
    this.style = BooleanFieldStyle.checkbox,
    this.subtitle,
    this.tristate = false,
  });

  @override
  State<BooleanFieldWidget> createState() => _BooleanFieldWidgetState();
}

class _BooleanFieldWidgetState extends State<BooleanFieldWidget> {
  bool? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(BooleanFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _updateValue(bool? value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: _currentValue,
      validator: (value) {
        if (widget.required && value != true) {
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
            _buildInputWidget(),
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
          ],
        );
      },
    );
  }

  Widget _buildInputWidget() {
    switch (widget.style) {
      case BooleanFieldStyle.checkbox:
        return CheckboxListTile(
          value: _currentValue,
          onChanged: widget.enabled ? _updateValue : null,
          title: widget.label != null ? Text(widget.label!) : null,
          subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
          tristate: widget.tristate,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );

      case BooleanFieldStyle.switchToggle:
        return SwitchListTile(
          value: _currentValue ?? false,
          onChanged: widget.enabled ? (value) => _updateValue(value) : null,
          title: widget.label != null ? Text(widget.label!) : null,
          subtitle: widget.subtitle != null ? Text(widget.subtitle!) : null,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        );

      case BooleanFieldStyle.radio:
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    value: true,
                    groupValue: _currentValue,
                    onChanged:
                        widget.enabled ? (value) => _updateValue(value) : null,
                    title: const Text('Yes'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: _currentValue,
                    onChanged:
                        widget.enabled ? (value) => _updateValue(value) : null,
                    title: const Text('No'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            if (widget.subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
          ],
        );
    }
  }
}

/// The style of boolean input widget
enum BooleanFieldStyle {
  /// Standard checkbox
  checkbox,

  /// Toggle switch
  switchToggle,

  /// Radio buttons (Yes/No)
  radio,
}
