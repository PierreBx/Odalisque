import '../models/user_model.dart';

/// Evaluates simple expressions for conditional visibility.
class ExpressionEvaluator {
  /// Evaluates an expression against a user context.
  /// Supports: ==, !=, AND, OR operators
  /// Example: "user.role == 'admin' OR user.role == 'manager'"
  static bool evaluate(String? expression, User user) {
    if (expression == null || expression.trim().isEmpty) {
      return true;
    }

    try {
      return _evaluateExpression(expression.trim(), user);
    } catch (e) {
      // If evaluation fails, default to false for safety
      return false;
    }
  }

  static bool _evaluateExpression(String expr, User user) {
    // Handle "true" and "false" literals
    if (expr == 'true') return true;
    if (expr == 'false') return false;

    // Handle OR operator (lowest precedence)
    if (expr.contains(' OR ')) {
      return expr
          .split(' OR ')
          .any((part) => _evaluateExpression(part.trim(), user));
    }

    // Handle AND operator
    if (expr.contains(' AND ')) {
      return expr
          .split(' AND ')
          .every((part) => _evaluateExpression(part.trim(), user));
    }

    // Handle comparison operators
    if (expr.contains('==')) {
      return _evaluateComparison(expr, '==', user);
    }
    if (expr.contains('!=')) {
      return _evaluateComparison(expr, '!=', user);
    }
    if (expr.contains('>=')) {
      return _evaluateNumericComparison(expr, '>=', user);
    }
    if (expr.contains('<=')) {
      return _evaluateNumericComparison(expr, '<=', user);
    }
    if (expr.contains('>')) {
      return _evaluateNumericComparison(expr, '>', user);
    }
    if (expr.contains('<')) {
      return _evaluateNumericComparison(expr, '<', user);
    }

    // If no operators, treat as a field name and check if truthy
    return _getValue(expr.trim(), user) == true;
  }

  static bool _evaluateComparison(String expr, String operator, User user) {
    final parts = expr.split(operator).map((s) => s.trim()).toList();
    if (parts.length != 2) return false;

    final leftValue = _getValue(parts[0], user);
    final rightValue = _parseValue(parts[1]);

    if (operator == '==') {
      return leftValue.toString() == rightValue.toString();
    } else if (operator == '!=') {
      return leftValue.toString() != rightValue.toString();
    }

    return false;
  }

  static bool _evaluateNumericComparison(
      String expr, String operator, User user) {
    final parts = expr.split(operator).map((s) => s.trim()).toList();
    if (parts.length != 2) return false;

    final leftValue = _getValue(parts[0], user);
    final rightValue = _parseValue(parts[1]);

    final left = num.tryParse(leftValue.toString());
    final right = num.tryParse(rightValue.toString());

    if (left == null || right == null) return false;

    switch (operator) {
      case '>':
        return left > right;
      case '<':
        return left < right;
      case '>=':
        return left >= right;
      case '<=':
        return left <= right;
      default:
        return false;
    }
  }

  static dynamic _getValue(String path, User user) {
    // Handle user.field notation
    if (path.startsWith('user.')) {
      final fieldName = path.substring(5); // Remove 'user.'
      return user.getField(fieldName);
    }

    return path;
  }

  static dynamic _parseValue(String value) {
    final trimmed = value.trim();

    // Remove quotes if present
    if ((trimmed.startsWith("'") && trimmed.endsWith("'")) ||
        (trimmed.startsWith('"') && trimmed.endsWith('"'))) {
      return trimmed.substring(1, trimmed.length - 1);
    }

    // Try to parse as number
    final numValue = num.tryParse(trimmed);
    if (numValue != null) return numValue;

    // Try to parse as boolean
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;

    return trimmed;
  }
}
