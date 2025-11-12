import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A form field widget for date and datetime selection.
///
/// Provides a tap-able input field that opens a date picker dialog.
/// Supports date-only, time-only, and datetime modes.
class DateFieldWidget extends StatefulWidget {
  /// The label text displayed above the field
  final String? label;

  /// The current date value
  final DateTime? value;

  /// Callback when date is selected
  final ValueChanged<DateTime?>? onChanged;

  /// Whether the field is required
  final bool required;

  /// Custom validator function
  final String? Function(DateTime?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// The mode of date selection (date, time, or datetime)
  final DateFieldMode mode;

  /// The date format for display
  final DateFormat? displayFormat;

  /// The earliest selectable date
  final DateTime? firstDate;

  /// The latest selectable date
  final DateTime? lastDate;

  /// Hint text when no date is selected
  final String? hintText;

  const DateFieldWidget({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.required = false,
    this.validator,
    this.enabled = true,
    this.mode = DateFieldMode.date,
    this.displayFormat,
    this.firstDate,
    this.lastDate,
    this.hintText,
  });

  @override
  State<DateFieldWidget> createState() => _DateFieldWidgetState();
}

class _DateFieldWidgetState extends State<DateFieldWidget> {
  DateTime? _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(DateFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;

    if (widget.mode == DateFieldMode.time) {
      await _pickTime();
      return;
    }

    final initialDate = _currentValue ?? DateTime.now();
    final firstDate = widget.firstDate ?? DateTime(1900);
    final lastDate = widget.lastDate ?? DateTime(2100);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      if (widget.mode == DateFieldMode.datetime) {
        // Also pick time
        final time = await _pickTimeForDate(picked);
        if (time != null) {
          final combined = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          _updateValue(combined);
        }
      } else {
        _updateValue(picked);
      }
    }
  }

  Future<void> _pickTime() async {
    if (!widget.enabled) return;

    final initialTime = _currentValue != null
        ? TimeOfDay.fromDateTime(_currentValue!)
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      _updateValue(dateTime);
    }
  }

  Future<TimeOfDay?> _pickTimeForDate(DateTime date) async {
    final initialTime = _currentValue != null
        ? TimeOfDay.fromDateTime(_currentValue!)
        : TimeOfDay.now();

    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  void _updateValue(DateTime value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged?.call(value);
  }

  void _clearValue() {
    setState(() {
      _currentValue = null;
    });
    widget.onChanged?.call(null);
  }

  String _formatDate(DateTime date) {
    if (widget.displayFormat != null) {
      return widget.displayFormat!.format(date);
    }

    switch (widget.mode) {
      case DateFieldMode.date:
        return DateFormat('yyyy-MM-dd').format(date);
      case DateFieldMode.time:
        return DateFormat('HH:mm').format(date);
      case DateFieldMode.datetime:
        return DateFormat('yyyy-MM-dd HH:mm').format(date);
    }
  }

  String get _defaultHintText {
    switch (widget.mode) {
      case DateFieldMode.date:
        return 'Select date';
      case DateFieldMode.time:
        return 'Select time';
      case DateFieldMode.datetime:
        return 'Select date and time';
    }
  }

  IconData get _icon {
    switch (widget.mode) {
      case DateFieldMode.date:
      case DateFieldMode.datetime:
        return Icons.calendar_today;
      case DateFieldMode.time:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: _currentValue,
      validator: (value) {
        if (widget.required && value == null) {
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
              onTap: widget.enabled ? _pickDate : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: widget.label,
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_currentValue != null && widget.enabled)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: _clearValue,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 12),
                        child: Icon(_icon),
                      ),
                    ],
                  ),
                  errorText: formFieldState.errorText,
                  enabled: widget.enabled,
                ),
                child: Text(
                  _currentValue != null
                      ? _formatDate(_currentValue!)
                      : (widget.hintText ?? _defaultHintText),
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
}

/// The mode of date/time selection
enum DateFieldMode {
  /// Date only (yyyy-MM-dd)
  date,

  /// Time only (HH:mm)
  time,

  /// Date and time (yyyy-MM-dd HH:mm)
  datetime,
}
