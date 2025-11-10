# API Reference

This document provides comprehensive API documentation for the flutter_grist_widgets library.

## Installation

```yaml
dependencies:
  flutter_grist_widgets: ^0.3.0
```

## Imports

```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';
```

This import provides access to all public APIs.

## Core Classes

### GristApp

Main application widget that generates a complete Flutter app from YAML configuration.

```dart
class GristApp extends StatelessWidget {
  const GristApp({
    Key? key,
    required this.config,
  });

  final AppConfig config;

  static Future<GristApp> fromYaml(String assetPath);
}
```

*Constructor Parameters:*
- `config` (required): AppConfig object containing all configuration

*Static Methods:*
- `fromYaml(String assetPath)`: Create GristApp from YAML asset file

*Example:*
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Option 1: Load from YAML
  final app = await GristApp.fromYaml('assets/config.yaml');
  runApp(app);

  // Option 2: Use existing config
  final config = AppConfig(...);
  runApp(GristApp(config: config));
}
```

### AppConfig

Complete application configuration.

```dart
class AppConfig {
  const AppConfig({
    required this.app,
    required this.grist,
    required this.auth,
    required this.theme,
    required this.navigation,
    required this.pages,
  });

  final AppSettings app;
  final GristSettings grist;
  final AuthSettings auth;
  final ThemeSettings theme;
  final NavigationSettings navigation;
  final List<PageConfig> pages;

  factory AppConfig.fromMap(Map<String, dynamic> map);
}
```

*Properties:*
- `app`: Application settings (name, version)
- `grist`: Grist connection settings
- `auth`: Authentication configuration
- `theme`: UI theme settings
- `navigation`: Navigation drawer configuration
- `pages`: List of page configurations

*Factory Methods:*
- `fromMap(Map<String, dynamic>)`: Create from map

### YamlConfigLoader

Loads and parses YAML configuration.

```dart
class YamlConfigLoader {
  static Future<AppConfig> loadFromAsset(String assetPath);
  static Future<AppConfig> loadFromFile(String filePath);
}
```

*Static Methods:*
- `loadFromAsset(String)`: Load from Flutter assets
- `loadFromFile(String)`: Load from file system (mainly for testing)

*Example:*
```dart

final config = await YamlConfigLoader.loadFromAsset('assets/app_config.yaml');

final config = await YamlConfigLoader.loadFromFile('/path/to/config.yaml');
```

## Configuration Models

### AppSettings

Application-level settings.

```dart
class AppSettings {
  const AppSettings({
    required this.name,
    this.version = '1.0.0',
    this.errorHandling,
    this.loading,
  });

  final String name;
  final String version;
  final ErrorHandlingSettings? errorHandling;
  final LoadingSettings? loading;

  factory AppSettings.fromMap(Map<String, dynamic> map);
}
```

*Properties:*
- `name`: Application name
- `version`: Version string
- `errorHandling`: Error handling configuration (optional)
- `loading`: Loading state configuration (optional)

### GristSettings

Grist connection settings.

```dart
class GristSettings {
  const GristSettings({
    required this.baseUrl,
    required this.apiKey,
    required this.documentId,
  });

  final String baseUrl;
  final String apiKey;
  final String documentId;

  factory GristSettings.fromMap(Map<String, dynamic> map);
}
```

*Properties:*
- `baseUrl`: Grist instance URL (e.g., "http://localhost:8484")
- `apiKey`: Grist API key for authentication
- `documentId`: Grist document ID

### AuthSettings

Authentication configuration.

```dart
class AuthSettings {
  const AuthSettings({
    required this.usersTable,
    required this.usersTableSchema,
    this.session,
    this.loginPage,
  });

  final String usersTable;
  final UsersTableSchema usersTableSchema;
  final SessionSettings? session;
  final LoginPageSettings? loginPage;

  factory AuthSettings.fromMap(Map<String, dynamic> map);
}
```

*Properties:*
- `usersTable`: Name of users table in Grist
- `usersTableSchema`: Column name mappings
- `session`: Session management settings (optional)
- `loginPage`: Login page customization (optional)

### ThemeSettings

UI theme configuration.

```dart
class ThemeSettings {
  const ThemeSettings({
    this.primaryColor = '#2196F3',
    this.secondaryColor = '#FFC107',
    this.drawerBackground = '#263238',
    this.drawerTextColor = '#FFFFFF',
    this.errorColor,
    this.successColor,
  });

  final String primaryColor;
  final String secondaryColor;
  final String drawerBackground;
  final String drawerTextColor;
  final String? errorColor;
  final String? successColor;

  factory ThemeSettings.fromMap(Map<String, dynamic> map);
}
```

*Properties:*
- `primaryColor`: Primary theme color (hex string)
- `secondaryColor`: Secondary theme color
- `drawerBackground`: Navigation drawer background color
- `drawerTextColor`: Navigation drawer text color
- `errorColor`: Error message color (optional)
- `successColor`: Success message color (optional)

## Services

### GristService

Main API client for Grist operations.

```dart
class GristService {
  GristService(this.config);

  final GristSettings config;

  // CRUD Operations
  Future<List<Map<String, dynamic>>> fetchRecords(String tableName);
  Future<Map<String, dynamic>?> fetchRecord(String tableName, int recordId);
  Future<int> createRecord(String tableName, Map<String, dynamic> fields);
  Future<void> updateRecord(String tableName, int recordId, Map<String, dynamic> fields);
  Future<void> deleteRecord(String tableName, int recordId);

  // Authentication
  Future<User?> authenticate(String email, String password, AuthSettings authSettings);

  // Metadata
  Future<List<Map<String, dynamic>>> fetchTables();
  Future<List<Map<String, dynamic>>> fetchColumns(String tableName);

  // Utilities
  static String hashPassword(String password);
}
```

#### fetchRecords

Fetch all records from a table.

```dart
Future<List<Map<String, dynamic>>> fetchRecords(String tableName)
```

*Parameters:*
- `tableName`: Name of the Grist table

*Returns:*
- `Future<List<Map<String, dynamic>>>`: List of records, each with 'id' and 'fields'

*Throws:*
- `Exception` if fetch fails

*Example:*
```dart
final service = GristService(gristSettings);
try {
  final records = await service.fetchRecords('Products');
  for (var record in records) {
    final id = record['id'];
    final fields = record['fields'];
    print('Product: ${fields['name']}');
  }
} catch (e) {
  print('Error: $e');
}
```

#### fetchRecord

Fetch a single record by ID.

```dart
Future<Map<String, dynamic>?> fetchRecord(String tableName, int recordId)
```

*Parameters:*
- `tableName`: Name of the Grist table
- `recordId`: Record ID

*Returns:*
- `Future<Map<String, dynamic>?>`: Record data or null if not found

*Example:*
```dart
final record = await service.fetchRecord('Products', 42);
if (record != null) {
  final fields = record['fields'];
  print('Product: ${fields['name']}');
}
```

#### createRecord

Create a new record.

```dart
Future<int> createRecord(String tableName, Map<String, dynamic> fields)
```

*Parameters:*
- `tableName`: Name of the Grist table
- `fields`: Map of field names to values

*Returns:*
- `Future<int>`: ID of newly created record

*Throws:*
- `Exception` if creation fails

*Example:*
```dart
final newId = await service.createRecord('Products', {
  'name': 'New Product',
  'price': 29.99,
  'in_stock': true,
});
print('Created product with ID: $newId');
```

#### updateRecord

Update an existing record.

```dart
Future<void> updateRecord(String tableName, int recordId, Map<String, dynamic> fields)
```

*Parameters:*
- `tableName`: Name of the Grist table
- `recordId`: Record ID to update
- `fields`: Map of field names to new values (only changed fields)

*Throws:*
- `Exception` if update fails

*Example:*
```dart
await service.updateRecord('Products', 42, {
  'price': 24.99,
  'in_stock': false,
});
```

#### deleteRecord

Delete a record.

```dart
Future<void> deleteRecord(String tableName, int recordId)
```

*Parameters:*
- `tableName`: Name of the Grist table
- `recordId`: Record ID to delete

*Throws:*
- `Exception` if deletion fails

*Example:*
```dart
await service.deleteRecord('Products', 42);
```

#### authenticate

Authenticate a user against the users table.

```dart
Future<User?> authenticate(String email, String password, AuthSettings authSettings)
```

*Parameters:*
- `email`: User email
- `password`: Plain text password
- `authSettings`: Authentication configuration

*Returns:*
- `Future<User?>`: User object if valid, null if invalid

*Example:*
```dart
final user = await service.authenticate(
  'user@example.com',
  'password123',
  authSettings,
);
if (user != null) {
  print('Authenticated as: ${user.email}');
}
```

#### hashPassword

Hash a password using bcrypt (static method).

```dart
static String hashPassword(String password)
```

*Parameters:*
- `password`: Plain text password

*Returns:*
- `String`: Bcrypt hash suitable for storage

*Example:*
```dart
final hash = GristService.hashPassword('mypassword');

await service.createRecord('Users', {
  'email': 'newuser@example.com',
  'password_hash': hash,
  'role': 'user',
});
```

## State Management

### AuthProvider

Manages authentication state using Provider pattern.

```dart
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.gristService,
    required this.authSettings,
  });

  final GristService gristService;
  final AuthSettings authSettings;

  // Getters
  User? get user;
  bool get isAuthenticated;
  bool get isLoading;
  String? get error;

  // Methods
  Future<void> init();
  Future<bool> login(String email, String password);
  Future<void> logout({bool timedOut = false});
  void recordActivity();
  void clearError();
}
```

#### Getters

- `user`: Current authenticated user (null if not authenticated)
- `isAuthenticated`: True if user is logged in
- `isLoading`: True during login/initialization
- `error`: Last error message (null if no error)

#### Methods

##### init

Initialize provider and restore session.

```dart
Future<void> init()
```

Call this once when creating the provider. It restores saved sessions from SharedPreferences.

*Example:*
```dart
ChangeNotifierProvider(
  create: (_) => AuthProvider(
    gristService: gristService,
    authSettings: authSettings,
  )..init(),  // Initialize immediately
);
```

##### login

Attempt to log in a user.

```dart
Future<bool> login(String email, String password)
```

*Parameters:*
- `email`: User email
- `password`: User password

*Returns:*
- `Future<bool>`: True if login successful, false otherwise

*Side Effects:*
- Sets `user` if successful
- Sets `error` if failed
- Saves session to SharedPreferences
- Notifies listeners

*Example:*
```dart
final auth = context.read<AuthProvider>();
final success = await auth.login(email, password);
if (success) {
  // Navigate to home
} else {
  // Show error: auth.error
}
```

##### logout

Log out the current user.

```dart
Future<void> logout({bool timedOut = false})
```

*Parameters:*
- `timedOut`: Set to true if logout due to timeout

*Side Effects:*
- Clears user
- Removes session from SharedPreferences
- Sets error message if timedOut
- Notifies listeners

*Example:*
```dart
await auth.logout();
```

##### recordActivity

Record user activity (resets session timeout).

```dart
void recordActivity()
```

Call this when user interacts with the app to prevent session timeout.

*Example:*
```dart
@override
void initState() {
  super.initState();
  context.read<AuthProvider>().recordActivity();
}
```

## Models

### User

User model.

```dart
class User {
  const User({
    required this.email,
    required this.role,
    required this.active,
    this.additionalFields = const {},
  });

  final String email;
  final String role;
  final bool active;
  final Map<String, dynamic> additionalFields;

  factory User.fromGristRecord(
    Map<String, dynamic> record,
    String emailField,
    String roleField,
    String activeField,
  );

  Map<String, dynamic> toJson();
}
```

*Properties:*
- `email`: User email address
- `role`: User role (e.g., 'admin', 'user')
- `active`: Whether user account is active
- `additionalFields`: Additional fields from Grist

*Factory Methods:*
- `fromGristRecord`: Create from Grist API response

*Methods:*
- `toJson()`: Convert to JSON for serialization

### GristConfig

Configuration for GristTableWidget and GristFormWidget.

```dart
class GristConfig {
  const GristConfig({
    required this.documentId,
    required this.tableId,
    required this.apiKey,
    this.baseUrl = 'https://docs.getgrist.com',
    this.readableAttributes = const [],
    this.writableAttributes = const [],
  });

  final String documentId;
  final String tableId;
  final String apiKey;
  final String baseUrl;
  final List<String> readableAttributes;
  final List<String> writableAttributes;

  List<String> get allAttributes;
}
```

*Properties:*
- `documentId`: Grist document ID
- `tableId`: Grist table ID
- `apiKey`: API key for authentication
- `baseUrl`: Grist instance URL
- `readableAttributes`: Fields that can be read
- `writableAttributes`: Fields that can be written

## Utilities

### FieldValidator

Field validation for forms.

```dart
class FieldValidator {
  const FieldValidator({
    required this.type,
    this.message,
    this.min,
    this.max,
    this.pattern,
  });

  final String type;
  final String? message;
  final dynamic min;
  final dynamic max;
  final String? pattern;

  factory FieldValidator.fromMap(Map<String, dynamic> map);
  String? validate(dynamic value);
}
```

#### Validator Types

- `required`: Value must not be empty
- `email`: Must be valid email format
- `range`: Numeric value within min/max
- `min_length`: String minimum length
- `max_length`: String maximum length
- `regex`: Match custom regex pattern

#### Example Usage

```dart

final required = FieldValidator(
  type: 'required',
  message: 'This field is required',
);
print(required.validate('')); // "This field is required"
print(required.validate('text')); // null (valid)

final email = FieldValidator(type: 'email');
print(email.validate('invalid')); // "Invalid email address"
print(email.validate('user@example.com')); // null (valid)

final range = FieldValidator(
  type: 'range',
  min: 0,
  max: 100,
  message: 'Must be 0-100',
);
print(range.validate(150)); // "Must be 0-100"
print(range.validate(50)); // null (valid)

final phone = FieldValidator(
  type: 'regex',
  pattern: r'^\d{3}-\d{3}-\d{4}$',
  message: 'Invalid phone format',
);
print(phone.validate('123-456-7890')); // null (valid)
print(phone.validate('invalid')); // "Invalid phone format"
```

### FieldValidators

Container for multiple validators.

```dart
class FieldValidators {
  const FieldValidators(this.validators);

  final List<FieldValidator> validators;

  factory FieldValidators.fromList(List<dynamic>? validatorsList);
  String? validate(dynamic value);
  String? Function(String?) asFormValidator();
}
```

#### Example Usage

```dart

final validators = FieldValidators([
  FieldValidator(type: 'required'),
  FieldValidator(type: 'email'),
]);

print(validators.validate('')); // "This field is required"
print(validators.validate('invalid')); // "Invalid email address"
print(validators.validate('user@example.com')); // null (all valid)

TextFormField(
  validator: validators.asFormValidator(),
  // ...
);
```

### ExpressionEvaluator

Evaluate conditional visibility expressions.

```dart
class ExpressionEvaluator {
  static bool evaluate(String expression, Map<String, dynamic> context);
}
```

#### Supported Operators

*Comparison:*
- `==` - Equal
- `!=` - Not equal
- `<` - Less than
- `>` - Greater than
- `<=` - Less than or equal
- `>=` - Greater than or equal

*Logical:*
- `AND` - Logical AND
- `OR` - Logical OR

#### Example Usage

```dart
final context = {
  'user': {
    'role': 'admin',
    'active': true,
    'email': 'admin@example.com',
  }
};

ExpressionEvaluator.evaluate('user.role == "admin"', context);

ExpressionEvaluator.evaluate(
  'user.role == "admin" AND user.active == true',
  context
);

ExpressionEvaluator.evaluate(
  'user.role == "manager" OR user.role == "admin"',
  context
);

ExpressionEvaluator.evaluate('user.email == "admin@example.com"', context);

```

## Widgets

### GristTableWidget

Data table widget with sorting and pagination.

```dart
class GristTableWidget extends StatefulWidget {
  const GristTableWidget({
    Key? key,
    required this.tableName,
    required this.columns,
    this.onRowTap,
    this.sortable = true,
    this.paginated = true,
    this.pageSize = 50,
  });

  final String tableName;
  final List<String> columns;
  final Function(int recordId)? onRowTap;
  final bool sortable;
  final bool paginated;
  final int pageSize;
}
```

*Properties:*
- `tableName`: Grist table to display
- `columns`: List of column names to show
- `onRowTap`: Callback when row is tapped (receives record ID)
- `sortable`: Enable column sorting
- `paginated`: Enable pagination
- `pageSize`: Records per page

*Example:*
```dart
GristTableWidget(
  tableName: 'Products',
  columns: ['name', 'price', 'in_stock'],
  onRowTap: (recordId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(recordId: recordId),
      ),
    );
  },
  sortable: true,
  paginated: true,
  pageSize: 25,
)
```

### FileUploadWidget

File upload widget with drag-and-drop.

```dart
class FileUploadWidget extends StatefulWidget {
  const FileUploadWidget({
    Key? key,
    required this.onFileSelected,
    this.allowedExtensions = const [],
    this.maxSizeBytes = 10485760,  // 10MB default
  });

  final Function(File file) onFileSelected;
  final List<String> allowedExtensions;
  final int maxSizeBytes;
}
```

*Properties:*
- `onFileSelected`: Callback when file is selected
- `allowedExtensions`: List of allowed extensions (e.g., ['jpg', 'png'])
- `maxSizeBytes`: Maximum file size in bytes

*Example:*
```dart
FileUploadWidget(
  onFileSelected: (file) async {
    // Upload file to Grist or other storage
    final bytes = await file.readAsBytes();
    // ... handle upload
  },
  allowedExtensions: ['jpg', 'png', 'pdf'],
  maxSizeBytes: 5 * 1024 * 1024, // 5MB
)
```

## Pages

All page widgets are exported but typically used internally by the framework. They can be used directly if needed:

- `LoginPage`: Authentication page
- `HomePage`: Main navigation container
- `FrontPage`: Static content display
- `DataMasterPage`: Table/list view
- `DataDetailPage`: Detail/edit view
- `DataCreatePage`: Create new record form
- `AdminDashboardPage`: Admin dashboard

## Error Handling

All async methods may throw exceptions:

```dart
try {
  final records = await gristService.fetchRecords('Products');
  // Process records
} on Exception catch (e) {
  // Handle Grist API errors
  print('Error: $e');
  // Show error to user
}
```

Common exceptions:
- `Exception('Failed to fetch records')` - API call failed
- `Exception('Authentication failed')` - Login failed
- `Exception('Invalid configuration')` - Config parsing error

## Provider Usage

Access services and state in widgets:

```dart

final service = Provider.of<GristService>(context, listen: false);

final service = context.read<GristService>();

final auth = context.watch<AuthProvider>();
if (auth.isAuthenticated) {
  // User is logged in
}

final config = context.read<AppConfig>();
```

## Testing

### Mocking GristService

```dart
class MockGristService extends Mock implements GristService {}

void main() {
  test('fetchRecords returns data', () async {
    final service = MockGristService();
    when(service.fetchRecords('Users')).thenAnswer(
      (_) async => [
        {'id': 1, 'fields': {'email': 'test@example.com'}},
      ],
    );

    final records = await service.fetchRecords('Users');
    expect(records, hasLength(1));
  });
}
```

### Testing Validators

```dart
void main() {
  test('required validator rejects empty string', () {
    final validator = FieldValidator(type: 'required');
    expect(validator.validate(''), isNotNull);
    expect(validator.validate('value'), isNull);
  });
}
```

## Best Practices

### 1. Use Provider for Dependency Injection

```dart

final service = context.read<GristService>();

final service = GristService(config);  // Hard-coded dependency
```

### 2. Handle Errors Gracefully

```dart
try {
  final records = await service.fetchRecords('Products');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to load data: $e')),
  );
}
```

### 3. Validate User Input

```dart
final validators = FieldValidators([
  FieldValidator(type: 'required'),
  FieldValidator(type: 'email'),
]);

TextFormField(
  validator: validators.asFormValidator(),
);
```

### 4. Record User Activity

```dart
class MyPage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    context.read<AuthProvider>().recordActivity();
  }
}
```

## Version Compatibility

- Flutter SDK: >= 3.0.0
- Dart SDK: >= 3.0.0

## Change Log

See CHANGELOG.md for version history and breaking changes.

## Additional Resources

- GitHub: https://github.com/yourusername/flutter_grist_widgets
- Issues: https://github.com/yourusername/flutter_grist_widgets/issues
- Grist API: https://support.getgrist.com/api/
- Flutter Docs: https://flutter.dev/docs

> **Note**: This API reference covers the public API. Internal implementation details are subject to change. Always use the public API exports from `package:flutter_grist_widgets/flutter_grist_widgets.dart`.
