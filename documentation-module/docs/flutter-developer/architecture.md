# Flutter Library Architecture

## Overview

FlutterGristAPI is a declarative application generator that transforms YAML configuration into fully functional Flutter applications. The library follows a layered architecture with clear separation of concerns.

## Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│              Application Layer                      │
│         (Generated Flutter App)                     │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────────────────────────────────────────┐
│            Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │   Pages      │  │   Widgets    │                 │
│  │  (7 types)   │  │  (Reusable)  │                 │
│  └──────────────┘  └──────────────┘                 │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────────────────────────────────────────┐
│              Business Logic Layer                    │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │  Providers   │  │   Utils      │                 │
│  │   (State)    │  │ (Validators) │                 │
│  └──────────────┘  └──────────────┘                 │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────────────────────────────────────────┐
│               Data Layer                             │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │   Services   │  │   Models     │                 │
│  │ (Grist API)  │  │   (Data)     │                 │
│  └──────────────┘  └──────────────┘                 │
└──────────────────┬──────────────────────────────────┘
                   │
┌──────────────────────────────────────────────────────┐
│            Configuration Layer                       │
│  ┌──────────────┐  ┌──────────────┐                 │
│  │ YAML Parser  │  │ Config Models│                 │
│  └──────────────┘  └──────────────┘                 │
└──────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/
├── flutter_grist_widgets.dart        # Public API exports
└── src/                              # Internal implementation
    ├── config/                       # Configuration layer
    │   ├── app_config.dart           # Config models (AppConfig, etc.)
    │   └── yaml_loader.dart          # YAML loading logic
    ├── models/                       # Data models
    │   ├── grist_config.dart         # Grist connection config
    │   └── user_model.dart           # User model
    ├── pages/                        # Page widgets
    │   ├── login_page.dart           # Authentication page
    │   ├── home_page.dart            # Main page with drawer
    │   ├── front_page.dart           # Static content page
    │   ├── data_master_page.dart     # List/table view
    │   ├── data_detail_page.dart     # Detail/edit view
    │   ├── data_create_page.dart     # Create new record
    │   └── admin_dashboard_page.dart # Admin dashboard
    ├── providers/                    # State management
    │   └── auth_provider.dart        # Authentication state
    ├── services/                     # External services
    │   └── grist_service.dart        # Grist API client
    ├── utils/                        # Utilities
    │   ├── validators.dart           # Field validators
    │   ├── expression_evaluator.dart # Conditional logic
    │   └── theme_utils.dart          # Theme conversion
    └── widgets/                      # Reusable widgets
        ├── grist_table_widget.dart   # Data table
        ├── grist_form_widget.dart    # Form fields
        └── file_upload_widget.dart   # File upload
```

## Core Components

### 1. Configuration System

#### YamlConfigLoader

Loads and parses YAML configuration files:

```dart
class YamlConfigLoader {
  static Future<AppConfig> loadFromAsset(String assetPath) async {
    // Load YAML from assets
    final yamlString = await rootBundle.loadString(assetPath);
    final yamlMap = loadYaml(yamlString);

    // Convert to AppConfig
    return AppConfig.fromMap(yamlMap);
  }
}
```

*Key responsibilities:*
- Load YAML files from assets or filesystem
- Parse YAML into Dart maps
- Validate YAML structure
- Handle parsing errors gracefully

#### AppConfig Models

Hierarchical configuration models:

```
AppConfig
├── AppSettings (app name, version, error handling)
├── GristSettings (API URL, key, document ID)
├── AuthSettings (users table, schema, session)
├── ThemeSettings (colors, styling)
├── NavigationSettings (drawer config)
└── List<PageConfig> (page definitions)
    ├── PageConfig (id, type, title, visibility)
    ├── MenuConfig (label, icon, order)
    └── Type-specific configs (varies by page type)
```

*Design principles:*
- Immutable configuration objects
- Factory constructors from maps
- Sensible defaults for optional fields
- Type-safe access to config values

### 2. Application Entry Point

#### GristApp Widget

Main application widget that ties everything together:

```dart
class GristApp extends StatelessWidget {
  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(...)),
        Provider<AppConfig>.value(value: config),
        Provider<GristService>.value(value: gristService),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            theme: ThemeUtils.createTheme(config.theme),
            home: auth.isAuthenticated ? HomePage() : LoginPage(),
          );
        },
      ),
    );
  }
}
```

*Key responsibilities:*
- Set up dependency injection (providers)
- Configure theme from YAML
- Handle authentication routing
- Initialize services

### 3. State Management

Uses Provider pattern for state management:

```dart
┌─────────────────────────────────────┐
│         MultiProvider               │
│  ┌────────────────────────────────┐ │
│  │     AuthProvider               │ │
│  │  - User state                  │ │
│  │  - Login/logout                │ │
│  │  - Session management          │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │     AppConfig (Provider)       │ │
│  │  - Immutable configuration     │ │
│  └────────────────────────────────┘ │
│  ┌────────────────────────────────┐ │
│  │     GristService (Provider)    │ │
│  │  - API client                  │ │
│  └────────────────────────────────┘ │
└─────────────────────────────────────┘
```

#### AuthProvider

Manages authentication state:

```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  DateTime? _lastActivityTime;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  // Methods
  Future<bool> login(String email, String password) { }
  Future<void> logout() { }
  void recordActivity() { }  // For session timeout
}
```

*Features:*
- Session persistence (SharedPreferences)
- Session timeout monitoring
- Activity tracking
- Automatic logout on timeout

### 4. Services Layer

#### GristService

Main API client for Grist:

```dart
class GristService {
  final GristSettings config;

  // CRUD operations
  Future<List<Map<String, dynamic>>> fetchRecords(String table);
  Future<Map<String, dynamic>?> fetchRecord(String table, int id);
  Future<int> createRecord(String table, Map<String, dynamic> fields);
  Future<void> updateRecord(String table, int id, Map fields);
  Future<void> deleteRecord(String table, int id);

  // Authentication
  Future<User?> authenticate(String email, String password);

  // Metadata
  Future<List<Map<String, dynamic>>> fetchTables();
  Future<List<Map<String, dynamic>>> fetchColumns(String table);

  // Utility
  static String hashPassword(String password);
}
```

*Implementation details:*
- Uses `http` package for REST calls
- Bearer token authentication
- Error handling with exceptions
- bcrypt for password hashing

### 5. Page System

The library supports 7 page types:

#### LoginPage
Authentication interface:
- Email/password form
- Validation
- Loading states
- Error display
- Customizable styling

#### HomePage
Main navigation container:
- Permanent drawer navigation
- Menu items from config
- Conditional visibility
- User info display
- Logout button

#### FrontPage (Static Content)
Static information display:
- Text content
- Images
- Configurable alignment
- Markdown support (future)

#### DataMasterPage (Table View)
Tabular data display:
- Fetch records from Grist table
- Display in list/table format
- Search functionality
- Pull-to-refresh
- Navigate to detail on tap
- Pagination (client-side)
- Sorting by column

#### DataDetailPage (Detail View)
Single record display/edit:
- Fetch single record
- Display all fields
- Edit mode (when enabled)
- Field validation
- Save changes
- Delete record

#### DataCreatePage (Create Form)
Create new records:
- Form with all fields
- Validation
- Create and save
- Navigate back on success

#### AdminDashboardPage
System monitoring:
- Database summary
- Table list with record counts
- System information
- Refresh capability

### 6. Widget System

Reusable UI components:

#### GristTableWidget

Data table with features:

```dart
class GristTableWidget extends StatefulWidget {
  final String tableName;
  final List<String> columns;
  final Function(int)? onRowTap;
  final bool sortable;
  final bool paginated;
  final int pageSize;

  // Features:
  // - Column sorting
  // - Pagination
  // - Search
  // - Loading states
  // - Error handling
  // - Pull to refresh
}
```

#### GristFormWidget

Form builder:

```dart
class GristFormWidget extends StatefulWidget {
  final List<FieldConfig> fields;
  final Map<String, dynamic>? initialValues;
  final Function(Map<String, dynamic>) onSubmit;

  // Features:
  // - Dynamic field rendering
  // - Validation
  // - Error display
  // - Various field types
}
```

#### FileUploadWidget

File upload component:

```dart
class FileUploadWidget extends StatefulWidget {
  final Function(File) onFileSelected;
  final List<String> allowedExtensions;
  final int maxSizeBytes;

  // Features:
  // - Drag and drop
  // - File picker
  // - Image preview
  // - Validation
  // - Progress indicator
}
```

### 7. Utilities

#### Validators

Field validation system:

```dart
class FieldValidator {
  final String type;  // required, email, range, regex, etc.
  final String? message;
  final dynamic min;
  final dynamic max;
  final String? pattern;

  String? validate(dynamic value) {
    // Returns null if valid, error message if invalid
  }
}

```

#### ExpressionEvaluator

Conditional visibility evaluator:

```dart
class ExpressionEvaluator {
  static bool evaluate(String expression, Map<String, dynamic> context) {
    // Supports:
    // - Comparisons: ==, !=, <, >, <=, >=
    // - Logical: AND, OR
    // - User context: user.role, user.email, etc.
    //
    // Examples:
    // - "user.role == 'admin'"
    // - "user.role == 'admin' OR user.role == 'manager'"
    // - "user.active == true AND user.role == 'admin'"
  }
}
```

#### ThemeUtils

Theme conversion:

```dart
class ThemeUtils {
  static ThemeData createTheme(ThemeSettings settings) {
    // Converts YAML theme config to Flutter ThemeData
    return ThemeData(
      primaryColor: _parseColor(settings.primaryColor),
      // ... more theme properties
    );
  }

  static Color _parseColor(String hexColor) {
    // Parse hex color strings (#RRGGBB)
  }
}
```

## Data Flow

### Authentication Flow

```
1. User enters credentials
   ↓
2. LoginPage calls AuthProvider.login()
   ↓
3. AuthProvider calls GristService.authenticate()
   ↓
4. GristService fetches Users table from Grist
   ↓
5. Verify password with bcrypt
   ↓
6. Return User object if valid
   ↓
7. AuthProvider saves user to SharedPreferences
   ↓
8. AuthProvider notifies listeners
   ↓
9. GristApp rebuilds with HomePage
```

### Page Navigation Flow

```
1. User clicks menu item in drawer
   ↓
2. HomePage navigates to page route
   ↓
3. Navigator pushes page widget
   ↓
4. Page widget loads config from Provider
   ↓
5. Page widget fetches data from GristService
   ↓
6. Page widget renders UI with data
```

### Data Fetch Flow

```
1. Page calls GristService.fetchRecords()
   ↓
2. GristService builds API URL
   ↓
3. Send HTTP GET with Bearer token
   ↓
4. Grist API returns JSON response
   ↓
5. Parse JSON to List<Map<String, dynamic>>
   ↓
6. Return to page
   ↓
7. Page calls setState() to rebuild with data
```

### Form Submit Flow

```
1. User fills form and clicks submit
   ↓
2. Form validates all fields
   ↓
3. If valid, call GristService.createRecord()
   ↓
4. GristService builds request body
   ↓
5. Send HTTP POST to Grist
   ↓
6. Grist creates record and returns ID
   ↓
7. Navigate back to master page
   ↓
8. Master page refreshes data
```

## Design Patterns

### 1. Provider Pattern

Used for dependency injection and state management:

```dart

MultiProvider(
  providers: [
    Provider<GristService>.value(value: gristService),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MyApp(),
);

final service = Provider.of<GristService>(context, listen: false);
final auth = context.watch<AuthProvider>();
```

### 2. Factory Pattern

Used for creating objects from maps:

```dart
class AppConfig {
  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      app: AppSettings.fromMap(map['app']),
      grist: GristSettings.fromMap(map['grist']),
      // ...
    );
  }
}
```

### 3. Strategy Pattern

Used for field validators:

```dart

class FieldValidator {
  String? validate(dynamic value) {
    switch (type) {
      case 'required': return _validateRequired(value);
      case 'email': return _validateEmail(value);
      case 'range': return _validateRange(value);
      // ...
    }
  }
}
```

### 4. Builder Pattern

Used for constructing complex pages:

```dart
class DataMasterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
    );
  }
}
```

## Extension Points

The architecture is designed for extension:

### Adding New Page Types

```dart

class MyCustomPage extends StatelessWidget { }

PageWidget _createPage(PageConfig config) {
  switch (config.type) {
    case 'custom': return MyCustomPage(config: config);
    // ...
  }
}
```

### Adding New Validators

```dart

case 'custom':
  return _validateCustom(value);
```

### Adding New Field Types

```dart

case 'custom':
  return CustomFieldWidget(config: fieldConfig);
```

## Performance Considerations

### 1. Lazy Loading

Pages and data are loaded on demand:

```dart

class HomePage extends StatelessWidget {
  Widget _buildPageForRoute(String route) {
    // Create page widget only when needed
  }
}
```

### 2. Caching

Consider adding caching for frequently accessed data:

```dart
class GristService {
  final Map<String, List<Map<String, dynamic>>> _cache = {};

  Future<List<Map<String, dynamic>>> fetchRecords(String table) async {
    if (_cache.containsKey(table)) {
      return _cache[table]!;
    }
    // Fetch from API...
  }
}
```

### 3. Pagination

For large datasets, use pagination:

```dart
class DataMasterPage {
  int _currentPage = 0;
  int _pageSize = 50;

  List<Map<String, dynamic>> _getCurrentPageData() {
    final start = _currentPage * _pageSize;
    final end = start + _pageSize;
    return _allRecords.sublist(start, end);
  }
}
```

## Testing Architecture

```
test/
├── services/
│   └── grist_service_test.dart      # API client tests
├── utils/
│   ├── validators_test.dart         # Validator tests
│   └── expression_evaluator_test.dart
└── widgets/
    └── (widget tests TBD)
```

*Testing strategy:*
- Unit tests for utilities and services
- Widget tests for reusable widgets
- Integration tests for full flows
- Mock GristService for page tests

## Security Considerations

### 1. Password Security

```dart

static String hashPassword(String password) {
  return BCrypt.hashpw(password, BCrypt.gensalt());
}

BCrypt.checkpw(password, hash);
```

### 2. API Key Protection

```dart

final apiKey = await FlutterSecureStorage().read(key: 'grist_api_key');
```

### 3. Session Security

```dart

class AuthProvider {
  void _checkSessionTimeout() {
    final timeout = Duration(minutes: settings.timeoutMinutes);
    if (now.difference(_lastActivityTime) >= timeout) {
      logout(timedOut: true);
    }
  }
}
```

## Future Architectural Improvements

### Planned Enhancements

1. *Riverpod Migration*
   - Move from Provider to Riverpod for better state management
   - Improved testability and type safety

2. *Offline Support*
   - Local database (SQLite or Hive)
   - Sync queue for offline changes
   - Conflict resolution

3. *Plugin System*
   - Allow third-party widgets
   - Custom page types
   - Custom validators

4. *Code Generation*
   - Generate models from Grist schema
   - Type-safe API client
   - Reduce boilerplate

5. *GraphQL Support*
   - Alternative to REST API
   - More efficient data fetching
   - Real-time subscriptions

## Summary

The FlutterGristAPI library follows a clean, layered architecture:

- *Configuration-driven*: Everything defined in YAML
- *Modular*: Clear separation of concerns
- *Extensible*: Easy to add new features
- *Testable*: Dependencies injected via Provider
- *Type-safe*: Strong Dart typing throughout

Understanding this architecture will help you:
- Navigate the codebase effectively
- Add new features consistently
- Maintain code quality
- Debug issues efficiently
- Design improvements systematically

> **Note**: For extending the library, see `extending.typ`. For API details, see `api-reference.typ`.
