/// Field validation utilities for form inputs.
///
/// This module provides validators based on the YAML configuration schema.
class FieldValidator {
  final String type;
  final String? message;
  final dynamic min;
  final dynamic max;
  final String? pattern;

  const FieldValidator({
    required this.type,
    this.message,
    this.min,
    this.max,
    this.pattern,
  });

  /// Creates a validator from YAML configuration.
  factory FieldValidator.fromMap(Map<String, dynamic> map) {
    return FieldValidator(
      type: map['type'] as String,
      message: map['message'] as String?,
      min: map['min'],
      max: map['max'],
      pattern: map['pattern'] as String?,
    );
  }

  /// Validates a value according to this validator's rules.
  ///
  /// Returns null if valid, error message if invalid.
  String? validate(dynamic value) {
    switch (type) {
      case 'required':
        return _validateRequired(value);
      case 'range':
        return _validateRange(value);
      case 'regex':
        return _validateRegex(value);
      case 'email':
        return _validateEmail(value);
      case 'min_length':
        return _validateMinLength(value);
      case 'max_length':
        return _validateMaxLength(value);
      default:
        return null; // Unknown validator type, skip
    }
  }

  String? _validateRequired(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }

  String? _validateRange(dynamic value) {
    if (value == null) return null; // Only validate if value exists

    num? numValue;
    if (value is num) {
      numValue = value;
    } else if (value is String) {
      numValue = num.tryParse(value);
      if (numValue == null) {
        return message ?? 'Value must be a number';
      }
    } else {
      return message ?? 'Value must be a number';
    }

    if (min != null && numValue < (min as num)) {
      return message ?? 'Value must be at least $min';
    }
    if (max != null && numValue > (max as num)) {
      return message ?? 'Value must be at most $max';
    }
    return null;
  }

  String? _validateRegex(dynamic value) {
    if (value == null || pattern == null) return null;

    final stringValue = value.toString();
    final regex = RegExp(pattern!);

    if (!regex.hasMatch(stringValue)) {
      return message ?? 'Invalid format';
    }
    return null;
  }

  String? _validateEmail(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(stringValue)) {
      return message ?? 'Invalid email address';
    }
    return null;
  }

  String? _validateMinLength(dynamic value) {
    if (value == null || min == null) return null;

    final stringValue = value.toString();
    if (stringValue.length < (min as int)) {
      return message ?? 'Must be at least $min characters';
    }
    return null;
  }

  String? _validateMaxLength(dynamic value) {
    if (value == null || max == null) return null;

    final stringValue = value.toString();
    if (stringValue.length > (max as int)) {
      return message ?? 'Must be at most $max characters';
    }
    return null;
  }
}

/// Combines multiple validators for a single field.
class FieldValidators {
  final List<FieldValidator> validators;

  const FieldValidators(this.validators);

  /// Creates validators from YAML configuration.
  factory FieldValidators.fromList(List<dynamic>? validatorsList) {
    if (validatorsList == null) return const FieldValidators([]);

    final validators = validatorsList
        .whereType<Map<String, dynamic>>()
        .map((v) => FieldValidator.fromMap(v))
        .toList();

    return FieldValidators(validators);
  }

  /// Validates a value against all validators.
  ///
  /// Returns the first error message encountered, or null if all pass.
  String? validate(dynamic value) {
    for (final validator in validators) {
      final error = validator.validate(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Creates a Flutter validator function for use with TextFormField.
  String? Function(String?) asFormValidator() {
    return (value) => validate(value);
  }
}
