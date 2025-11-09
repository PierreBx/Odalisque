import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/utils/validators.dart';

void main() {
  group('FieldValidator', () {
    group('Required validator', () {
      final validator = FieldValidator(
        type: 'required',
        message: 'This field is required',
      );

      test('returns error for null value', () {
        expect(validator.validate(null), equals('This field is required'));
      });

      test('returns error for empty string', () {
        expect(validator.validate(''), equals('This field is required'));
      });

      test('returns error for whitespace only', () {
        expect(validator.validate('   '), equals('This field is required'));
      });

      test('returns null for valid value', () {
        expect(validator.validate('test'), isNull);
      });
    });

    group('Range validator', () {
      final validator = FieldValidator(
        type: 'range',
        min: 0,
        max: 100,
        message: 'Value out of range',
      );

      test('returns error for value below minimum', () {
        expect(validator.validate(-1), equals('Value out of range'));
      });

      test('returns error for value above maximum', () {
        expect(validator.validate(101), equals('Value out of range'));
      });

      test('returns null for value within range', () {
        expect(validator.validate(50), isNull);
      });

      test('returns null for value at minimum', () {
        expect(validator.validate(0), isNull);
      });

      test('returns null for value at maximum', () {
        expect(validator.validate(100), isNull);
      });

      test('handles string numbers', () {
        expect(validator.validate('50'), isNull);
        expect(validator.validate('-1'), equals('Value out of range'));
      });
    });

    group('Regex validator', () {
      final validator = FieldValidator(
        type: 'regex',
        pattern: r'^[A-Z0-9]+$',
        message: 'Invalid format',
      );

      test('returns error for invalid format', () {
        expect(validator.validate('abc'), equals('Invalid format'));
      });

      test('returns null for valid format', () {
        expect(validator.validate('ABC123'), isNull);
      });

      test('returns null for null value', () {
        expect(validator.validate(null), isNull);
      });
    });

    group('Email validator', () {
      final validator = FieldValidator(
        type: 'email',
        message: 'Invalid email',
      );

      test('returns error for invalid email', () {
        expect(validator.validate('notanemail'), equals('Invalid email'));
        expect(validator.validate('test@'), equals('Invalid email'));
        expect(validator.validate('@test.com'), equals('Invalid email'));
      });

      test('returns null for valid email', () {
        expect(validator.validate('test@example.com'), isNull);
        expect(validator.validate('user.name@domain.co.uk'), isNull);
      });

      test('returns null for null value', () {
        expect(validator.validate(null), isNull);
      });
    });

    group('Min/Max length validators', () {
      final minValidator = FieldValidator(
        type: 'min_length',
        min: 5,
        message: 'Too short',
      );

      final maxValidator = FieldValidator(
        type: 'max_length',
        max: 10,
        message: 'Too long',
      );

      test('min_length returns error for short strings', () {
        expect(minValidator.validate('abc'), equals('Too short'));
      });

      test('min_length returns null for long enough strings', () {
        expect(minValidator.validate('abcdef'), isNull);
      });

      test('max_length returns error for long strings', () {
        expect(maxValidator.validate('12345678901'), equals('Too long'));
      });

      test('max_length returns null for short enough strings', () {
        expect(maxValidator.validate('abc'), isNull);
      });
    });

    group('fromMap factory', () {
      test('creates required validator from map', () {
        final map = {
          'type': 'required',
          'message': 'Custom message',
        };
        final validator = FieldValidator.fromMap(map);
        expect(validator.type, equals('required'));
        expect(validator.message, equals('Custom message'));
      });

      test('creates range validator from map', () {
        final map = {
          'type': 'range',
          'min': 0,
          'max': 999999,
          'message': 'Value out of range',
        };
        final validator = FieldValidator.fromMap(map);
        expect(validator.type, equals('range'));
        expect(validator.min, equals(0));
        expect(validator.max, equals(999999));
      });
    });
  });

  group('FieldValidators', () {
    test('validates against multiple validators', () {
      final validators = FieldValidators([
        FieldValidator(type: 'required'),
        FieldValidator(type: 'min_length', min: 3),
      ]);

      expect(validators.validate(null), isNotNull); // Fails required
      expect(validators.validate('ab'), isNotNull); // Fails min_length
      expect(validators.validate('abc'), isNull); // Passes both
    });

    test('returns first error encountered', () {
      final validators = FieldValidators([
        FieldValidator(type: 'required', message: 'Required'),
        FieldValidator(type: 'min_length', min: 3, message: 'Too short'),
      ]);

      final error = validators.validate('');
      expect(error, equals('Required')); // First validator's error
    });

    test('fromList creates validators from YAML-like list', () {
      final list = [
        {'type': 'required', 'message': 'This field is required'},
        {'type': 'range', 'min': 0, 'max': 999999},
      ];

      final validators = FieldValidators.fromList(list);
      expect(validators.validators.length, equals(2));
      expect(validators.validators[0].type, equals('required'));
      expect(validators.validators[1].type, equals('range'));
    });

    test('fromList handles null list', () {
      final validators = FieldValidators.fromList(null);
      expect(validators.validators.length, equals(0));
    });

    test('asFormValidator creates Flutter-compatible validator', () {
      final validators = FieldValidators([
        FieldValidator(type: 'required', message: 'Required'),
      ]);

      final formValidator = validators.asFormValidator();
      expect(formValidator(''), equals('Required'));
      expect(formValidator('test'), isNull);
    });
  });
}
