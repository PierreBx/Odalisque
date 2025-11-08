/// Represents an authenticated user.
class User {
  final String email;
  final String role;
  final bool active;
  final Map<String, dynamic> additionalFields;

  const User({
    required this.email,
    required this.role,
    required this.active,
    this.additionalFields = const {},
  });

  factory User.fromGristRecord(
    Map<String, dynamic> record,
    String emailField,
    String roleField,
    String activeField,
  ) {
    final fields = record['fields'] as Map<String, dynamic>? ?? {};

    return User(
      email: fields[emailField]?.toString() ?? '',
      role: fields[roleField]?.toString() ?? 'user',
      active: fields[activeField] == true || fields[activeField] == 1,
      additionalFields: Map.from(fields)
        ..remove(emailField)
        ..remove(roleField)
        ..remove(activeField),
    );
  }

  /// Get a field value by name (for expression evaluation)
  dynamic getField(String fieldName) {
    switch (fieldName) {
      case 'email':
        return email;
      case 'role':
        return role;
      case 'active':
        return active;
      default:
        return additionalFields[fieldName];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'active': active,
      ...additionalFields,
    };
  }
}
