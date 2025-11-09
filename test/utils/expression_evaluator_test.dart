import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/utils/expression_evaluator.dart';
import 'package:flutter_grist_widgets/src/models/user_model.dart';

void main() {
  group('ExpressionEvaluator', () {
    late User adminUser;
    late User regularUser;

    setUp(() {
      adminUser = User(
        id: 1,
        email: 'admin@test.com',
        role: 'admin',
        active: true,
        fields: {'department': 'IT', 'level': 5},
      );

      regularUser = User(
        id: 2,
        email: 'user@test.com',
        role: 'user',
        active: true,
        fields: {'department': 'Sales', 'level': 2},
      );
    });

    group('Literal expressions', () {
      test('returns true for "true" literal', () {
        expect(ExpressionEvaluator.evaluate('true', adminUser), isTrue);
      });

      test('returns false for "false" literal', () {
        expect(ExpressionEvaluator.evaluate('false', adminUser), isFalse);
      });

      test('returns true for null or empty expression', () {
        expect(ExpressionEvaluator.evaluate(null, adminUser), isTrue);
        expect(ExpressionEvaluator.evaluate('', adminUser), isTrue);
        expect(ExpressionEvaluator.evaluate('   ', adminUser), isTrue);
      });
    });

    group('Equality comparisons', () {
      test('evaluates == operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate("user.role == 'admin'", adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate("user.role == 'user'", adminUser),
          isFalse,
        );
      });

      test('evaluates != operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate("user.role != 'user'", adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate("user.role != 'admin'", adminUser),
          isFalse,
        );
      });

      test('handles quoted strings', () {
        expect(
          ExpressionEvaluator.evaluate('user.role == "admin"', adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate("user.role == 'admin'", adminUser),
          isTrue,
        );
      });
    });

    group('Numeric comparisons', () {
      test('evaluates > operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate('user.level > 3', adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate('user.level > 5', adminUser),
          isFalse,
        );
      });

      test('evaluates < operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate('user.level < 10', adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate('user.level < 5', adminUser),
          isFalse,
        );
      });

      test('evaluates >= operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate('user.level >= 5', adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate('user.level >= 6', adminUser),
          isFalse,
        );
      });

      test('evaluates <= operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate('user.level <= 5', adminUser),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate('user.level <= 4', adminUser),
          isFalse,
        );
      });
    });

    group('Logical operators', () {
      test('evaluates AND operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'admin' AND user.level > 3",
            adminUser,
          ),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'admin' AND user.level < 3",
            adminUser,
          ),
          isFalse,
        );
      });

      test('evaluates OR operator correctly', () {
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'admin' OR user.role == 'manager'",
            adminUser,
          ),
          isTrue,
        );
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'user' OR user.role == 'guest'",
            adminUser,
          ),
          isFalse,
        );
      });

      test('combines AND and OR correctly', () {
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'admin' AND user.level >= 5 OR user.role == 'manager'",
            adminUser,
          ),
          isTrue,
        );
      });
    });

    group('Complex expressions', () {
      test('evaluates multi-condition expressions', () {
        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'admin' AND user.department == 'IT' AND user.level > 4",
            adminUser,
          ),
          isTrue,
        );

        expect(
          ExpressionEvaluator.evaluate(
            "user.role == 'user' OR user.department == 'IT'",
            adminUser,
          ),
          isTrue,
        );
      });

      test('works with different user contexts', () {
        final expr = "user.role == 'admin' OR user.level > 5";
        expect(ExpressionEvaluator.evaluate(expr, adminUser), isTrue);
        expect(ExpressionEvaluator.evaluate(expr, regularUser), isFalse);
      });
    });

    group('Error handling', () {
      test('returns false for invalid expressions', () {
        expect(
          ExpressionEvaluator.evaluate('invalid.expression.here', adminUser),
          isFalse,
        );
      });

      test('returns false for malformed comparisons', () {
        expect(
          ExpressionEvaluator.evaluate('user.role ==', adminUser),
          isFalse,
        );
      });

      test('handles non-existent fields gracefully', () {
        expect(
          ExpressionEvaluator.evaluate(
            "user.nonexistent == 'value'",
            adminUser,
          ),
          isFalse,
        );
      });
    });

    group('Edge cases', () {
      test('handles whitespace correctly', () {
        expect(
          ExpressionEvaluator.evaluate(
            "  user.role  ==  'admin'  ",
            adminUser,
          ),
          isTrue,
        );
      });

      test('handles boolean field values', () {
        final userWithBool = User(
          id: 3,
          email: 'test@test.com',
          role: 'user',
          active: true,
          fields: {'isPremium': true},
        );

        expect(
          ExpressionEvaluator.evaluate('user.isPremium == true', userWithBool),
          isTrue,
        );
      });

      test('handles numeric strings', () {
        expect(
          ExpressionEvaluator.evaluate('user.level > "3"', adminUser),
          isTrue,
        );
      });
    });
  });
}
