#import "../common/styles.typ": *

#apply_standard_styles()

#doc_header(
  "Complete Developer Reference",
  subtitle: "Comprehensive Guide for Flutter Developers",
  version: "0.3.0"
)

= Complete Developer Reference

This document serves as a comprehensive reference for Flutter developers working on the FlutterGristAPI library.

== Documentation Structure

The Flutter Developer documentation is organized into the following guides:

=== Core Documentation

1. *overview.typ* - Start here
   - Role description and responsibilities
   - Prerequisites and required skills
   - Project structure overview
   - Development environment setup overview

2. *quickstart.typ* - Get started
   - Step-by-step environment setup
   - Tool installation guides
   - First contribution walkthrough
   - Verification steps

3. *architecture.typ* - Understand the codebase
   - System architecture
   - Layer structure
   - Component descriptions
   - Data flow diagrams
   - Design patterns used

4. *api-reference.typ* - API documentation
   - Public API reference
   - Class and method documentation
   - Usage examples
   - Best practices

=== Development Guides

5. *development-workflow.typ* - Daily workflow
   - Morning routine
   - Feature development steps
   - Testing workflow
   - Code review process
   - Git best practices

6. *extending.typ* - Add features
   - Adding validators
   - Creating page types
   - Building widgets
   - Adding configuration options
   - Extension patterns

7. *commands.typ* - Command reference
   - Docker test commands
   - Flutter commands
   - Git commands
   - Useful aliases and one-liners

8. *troubleshooting.typ* - Problem solving
   - Common errors and solutions
   - Build issues
   - Test failures
   - Dependency problems
   - Getting help

== Quick Reference

=== Project Directories

```
flutterGristAPI/
├── flutter-module/           # Flutter library code (YOUR WORK)
│   ├── lib/                  # Library source code
│   │   ├── flutter_grist_widgets.dart  # Public exports
│   │   └── src/              # Internal implementation
│   │       ├── config/       # YAML parsing
│   │       ├── models/       # Data models
│   │       ├── pages/        # Page widgets
│   │       ├── providers/    # State management
│   │       ├── services/     # API clients
│   │       ├── utils/        # Utilities
│   │       └── widgets/      # Reusable widgets
│   ├── test/                 # Tests (77 tests)
│   ├── example/              # Example configurations
│   └── pubspec.yaml          # Dependencies
│
├── grist-module/             # Grist and testing
│   ├── docker-test.sh        # Main test script
│   ├── docker-compose.yml    # Docker setup
│   └── grist-data/           # Grist database files
│
├── documentation-module/     # Documentation
│   ├── flutter-developer/    # This documentation
│   └── ...
│
└── deployment-module/        # CI/CD and deployment
    └── ...
```

=== Essential Commands

```bash
# Start Grist
cd grist-module
./docker-test.sh grist-start

# Run tests
./docker-test.sh test

# Run analysis
./docker-test.sh analyze

# Run both
./docker-test.sh all

# Interactive shell
./docker-test.sh shell
```

=== Common Tasks

==== Add a New Validator

```dart
// 1. Edit lib/src/utils/validators.dart
case 'url':
  return _validateUrl(value);

String? _validateUrl(dynamic value) {
  // Implementation
}

// 2. Write test in test/utils/validators_test.dart
test('url validator', () {
  final validator = FieldValidator(type: 'url');
  expect(validator.validate('https://example.com'), null);
});

// 3. Run tests
cd grist-module && ./docker-test.sh test
```

==== Add a New Page Type

```dart
// 1. Create lib/src/pages/my_page.dart
class MyPage extends StatefulWidget {
  final PageConfig config;
  // Implementation
}

// 2. Register in lib/src/pages/home_page.dart
case 'my_page':
  return MyPage(config: pageConfig);

// 3. Export in lib/flutter_grist_widgets.dart
export 'src/pages/my_page.dart';
```

==== Fix a Bug

```bash
# 1. Create branch
git checkout -b fix/bug-description

# 2. Write failing test
# Edit test/...

# 3. Fix bug
# Edit lib/src/...

# 4. Verify fix
./docker-test.sh all

# 5. Commit
git add .
git commit -m "fix: bug description"
git push origin fix/bug-description
```

== File Organization

=== Configuration Files

- `pubspec.yaml` - Dependencies and package metadata
- `analysis_options.yaml` - Linter rules and analyzer config
- `Dockerfile` - Docker image for testing
- `docker-compose.yml` - Multi-container setup
- `.gitignore` - Files to ignore in git

=== Source Code Organization

```
lib/src/
├── config/
│   ├── app_config.dart       # Main config model
│   └── yaml_loader.dart      # YAML loading
│
├── models/
│   ├── grist_config.dart     # Grist connection config
│   └── user_model.dart       # User data model
│
├── pages/
│   ├── login_page.dart       # Auth page
│   ├── home_page.dart        # Main container
│   ├── front_page.dart       # Static content
│   ├── data_master_page.dart # Table view
│   ├── data_detail_page.dart # Detail view
│   ├── data_create_page.dart # Create form
│   └── admin_dashboard_page.dart # Admin page
│
├── providers/
│   └── auth_provider.dart    # Auth state
│
├── services/
│   └── grist_service.dart    # Grist API client
│
├── utils/
│   ├── validators.dart       # Field validators
│   ├── expression_evaluator.dart # Conditional logic
│   └── theme_utils.dart      # Theme conversion
│
└── widgets/
    ├── grist_table_widget.dart # Data table
    ├── grist_form_widget.dart  # Form builder
    └── file_upload_widget.dart # File upload
```

=== Test Organization

```
test/
├── services/
│   └── grist_service_test.dart      # 7 tests
│
└── utils/
    ├── validators_test.dart          # 46 tests
    └── expression_evaluator_test.dart # 24 tests

Total: 77 tests
```

== Development Standards

=== Code Style

```dart
// Class names: PascalCase
class DataMasterPage { }

// Methods and variables: camelCase
void fetchRecords() { }
final userName = 'John';

// Private members: prefix with _
bool _isLoading = false;
void _validateInput() { }

// Constants: camelCase
const defaultTimeout = 30;

// File names: snake_case
data_master_page.dart
grist_service.dart
```

=== Documentation

```dart
/// Brief description on first line.
///
/// More detailed description after blank line.
///
/// Example:
/// ```dart
/// final result = myFunction('input');
/// ```
///
/// Parameters:
/// - [param1]: Description
///
/// Returns description.
///
/// Throws [ExceptionType] when...
void myFunction(String param1) { }
```

=== Testing

```dart
// Test structure
group('Feature Name', () {
  // Setup
  setUp(() {
    // Initialize test dependencies
  });

  // Teardown
  tearDown(() {
    // Clean up
  });

  // Test cases
  test('should do something', () {
    // Arrange
    final input = 'test';

    // Act
    final result = function(input);

    // Assert
    expect(result, expectedValue);
  });
});
```

=== Git Commits

```
<type>: <short description>

<optional detailed description>

<optional footer>
```

Types:
- `feat:` New feature
- `fix:` Bug fix
- `test:` Tests
- `refactor:` Code refactoring
- `docs:` Documentation
- `style:` Formatting
- `chore:` Maintenance

Examples:
```
feat: add URL validator

Implements URL validation with support for HTTP and HTTPS protocols.
Includes tests and documentation.

Closes #123
```

== Key Concepts

=== YAML Configuration

All app features are defined in YAML:

```yaml
app:
  name: "My App"
  version: "1.0.0"

grist:
  base_url: "http://localhost:8484"
  api_key: "your_api_key"
  document_id: "your_doc_id"

pages:
  - id: "home"
    type: "data_master"
    title: "Home Page"
    config:
      grist:
        table: "Products"
```

=== State Management

Uses Provider pattern:

```dart
// Provide services
MultiProvider(
  providers: [
    Provider<GristService>.value(value: service),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: app,
);

// Consume in widgets
final service = context.read<GristService>();
final auth = context.watch<AuthProvider>();
```

=== Page Types

7 built-in page types:

1. *login* - Authentication
2. *home* - Navigation container
3. *front* - Static content
4. *data_master* - Table view
5. *data_detail* - Detail view
6. *data_create* - Create form
7. *admin_dashboard* - Admin panel

=== Validators

8 validator types:

1. *required* - Value must exist
2. *email* - Valid email format
3. *range* - Numeric range
4. *min_length* - Minimum string length
5. *max_length* - Maximum string length
6. *regex* - Custom regex pattern
7. *url* - Valid URL (custom extension)
8. *phone* - Phone number (custom extension)

== Testing Strategy

=== Test Coverage Goals

- Overall: 70% minimum
- New code: 90% coverage
- Critical paths: 100% coverage

=== Test Types

1. *Unit tests* - Individual functions and classes
2. *Widget tests* - Widget behavior
3. *Integration tests* - Full workflows
4. *Smoke tests* - Basic functionality

=== Running Tests

```bash
# All tests
./docker-test.sh test

# Specific file
flutter test test/utils/validators_test.dart

# With coverage
flutter test --coverage

# Watch mode (manual)
./docker-test.sh shell
# Inside: flutter test --watch
```

== Dependencies

=== Core Dependencies

```yaml
dependencies:
  flutter: sdk
  http: ^1.1.0            # HTTP client
  yaml: ^3.1.2            # YAML parsing
  provider: ^6.1.1        # State management
  crypto: ^3.0.3          # Hashing (deprecated, use bcrypt)
  bcrypt: ^1.1.3          # Password hashing
  shared_preferences: ^2.2.2  # Local storage
  file_picker: ^6.1.1     # File selection
  image_picker: ^1.0.7    # Image selection
  mime: ^1.0.5            # MIME type detection
  intl: ^0.19.0           # Internationalization

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^3.0.0   # Linting rules
```

=== Updating Dependencies

```bash
# Check for updates
flutter pub outdated

# Update all
flutter pub upgrade

# Update specific package
flutter pub upgrade provider

# Test after updating
./docker-test.sh all
```

== Security Considerations

=== Password Hashing

```dart
// Use bcrypt (production-ready)
import 'package:bcrypt/bcrypt.dart';

// Hash password
final hash = BCrypt.hashpw(password, BCrypt.gensalt());

// Verify password
final valid = BCrypt.checkpw(password, hash);
```

=== API Keys

```yaml
# Never commit API keys
# Use environment variables or secure storage

# Development: local config
grist:
  api_key: "dev_api_key"

# Production: environment variable
grist:
  api_key: ${GRIST_API_KEY}
```

=== Session Management

```dart
// Session timeout
class AuthProvider {
  final Duration timeout = Duration(minutes: 30);

  void _checkTimeout() {
    if (DateTime.now().difference(_lastActivity) > timeout) {
      logout(timedOut: true);
    }
  }
}
```

== Performance Tips

=== Efficient Data Loading

```dart
// Use pagination
final pageSize = 50;
final offset = currentPage * pageSize;

// Lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    if (index == items.length - 1) {
      _loadMore();  // Load next page
    }
    return ItemWidget(items[index]);
  },
);
```

=== Caching

```dart
// Cache frequently accessed data
class GristService {
  final _cache = <String, List<Map<String, dynamic>>>{};
  final _cacheTimeout = Duration(minutes: 5);

  Future<List<Map<String, dynamic>>> fetchRecords(String table) async {
    if (_cache.containsKey(table) && !_isCacheExpired(table)) {
      return _cache[table]!;
    }
    // Fetch and cache
  }
}
```

=== Memory Management

```dart
// Always dispose controllers
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  _timer?.cancel();
  super.dispose();
}
```

== Resources

=== Official Documentation

- *Flutter*: https://flutter.dev/docs
- *Dart*: https://dart.dev/guides
- *Provider*: https://pub.dev/packages/provider
- *Grist API*: https://support.getgrist.com/api/

=== Project Documentation

All documentation in `documentation-module/flutter-developer/`:

- `overview.typ` - Role and prerequisites
- `quickstart.typ` - Environment setup
- `development-workflow.typ` - Daily workflow
- `architecture.typ` - System architecture
- `api-reference.typ` - API documentation
- `extending.typ` - Adding features
- `commands.typ` - Command reference
- `troubleshooting.typ` - Problem solving
- `reference.typ` - This document

=== Community

- *GitHub*: https://github.com/yourusername/flutterGristAPI
- *Issues*: https://github.com/yourusername/flutterGristAPI/issues
- *Discussions*: https://github.com/yourusername/flutterGristAPI/discussions

== Version Information

Current Version: *0.3.0*

=== Version History

- *0.3.0* - File uploads, pagination, enhanced tables
- *0.2.0* - Full CRUD operations
- *0.1.1* - Security fixes, validation, 77 tests
- *0.1.0* - Initial release

=== Breaking Changes

See CHANGELOG.md for breaking changes between versions.

=== Upgrading

```bash
# Update dependency
# Edit pubspec.yaml
dependencies:
  flutter_grist_widgets: ^0.3.0

# Get new version
flutter pub get

# Check for breaking changes
# Review CHANGELOG.md

# Update code if needed
# Run tests
./docker-test.sh all
```

== Contributing

=== Before Contributing

1. Read all documentation
2. Set up development environment
3. Run tests to verify setup
4. Find an issue to work on

=== Contribution Workflow

1. Fork repository (if external contributor)
2. Create feature branch
3. Write code and tests
4. Run all checks
5. Submit pull request
6. Address review feedback
7. Merge when approved

=== Code Review Checklist

- [ ] Tests pass (`./docker-test.sh all`)
- [ ] Code formatted (`flutter format`)
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Changelog updated
- [ ] Commit messages follow conventions

== Maintenance

=== Weekly Tasks

```bash
# Update dependencies
flutter pub outdated
flutter pub upgrade

# Run full test suite
./docker-test.sh all

# Clean up Docker
docker system prune -f

# Review open PRs
gh pr list

# Update documentation
# If anything changed, update docs
```

=== Monthly Tasks

```bash
# Review and update dependencies
# Check for security updates

# Review test coverage
flutter test --coverage

# Update documentation
# Review all docs for accuracy

# Plan upcoming features
# Review GitHub issues and discussions
```

== Getting Help

If you need help:

1. *Check documentation* - Start with relevant guide
2. *Search issues* - Someone may have had same problem
3. *Check troubleshooting* - Common issues are documented
4. *Ask in discussions* - For questions and help
5. *Create issue* - For bugs or feature requests

== Index of Topics

=== A-D
- API Reference → api-reference.typ
- Architecture → architecture.typ
- Authentication → api-reference.typ (AuthProvider)
- Build Errors → troubleshooting.typ
- Code Style → This document (Development Standards)
- Commands → commands.typ
- Configuration → architecture.typ (Config System)
- Contributing → This document (Contributing)
- Dependencies → This document (Dependencies)
- Development Workflow → development-workflow.typ
- Docker → commands.typ, troubleshooting.typ

=== E-P
- Extending → extending.typ
- Flutter Commands → commands.typ
- Git Commands → commands.typ
- Grist Service → api-reference.typ
- Page Types → architecture.typ (Page System)
- Performance → This document (Performance Tips)
- Prerequisites → overview.typ
- Providers → api-reference.typ (State Management)

=== Q-Z
- Quickstart → quickstart.typ
- Security → This document (Security Considerations)
- State Management → architecture.typ, api-reference.typ
- Testing → development-workflow.typ, commands.typ
- Troubleshooting → troubleshooting.typ
- Validators → api-reference.typ, extending.typ
- Widgets → architecture.typ, extending.typ

== Summary

This reference provides:

- Quick access to essential information
- Links to detailed guides
- Standards and conventions
- Common patterns and solutions
- Resource links

For detailed information on any topic, refer to the specific guide mentioned.

#info_box(type: "success")[
  This completes the Flutter Developer documentation. You now have everything you need to contribute effectively to the FlutterGristAPI library. Happy coding!
]

== Contact

For questions or support:

- GitHub Issues: https://github.com/yourusername/flutterGristAPI/issues
- GitHub Discussions: https://github.com/yourusername/flutterGristAPI/discussions
- Email: dev@fluttergristapi.example.com

---

*Document Version:* 0.3.0 \
*Last Updated:* 2025-11-10 \
*Maintained by:* FlutterGristAPI Development Team
