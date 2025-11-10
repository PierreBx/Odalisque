# Role Overview

## Who is a Flutter Developer?

Flutter Developers are the core library contributors who extend and maintain the FlutterGristAPI library itself. Unlike App Designers who use the library, Flutter Developers work directly with Dart/Flutter code to add new features, fix bugs, improve performance, and enhance the library's capabilities.

## Responsibilities

As a Flutter Developer on the FlutterGristAPI project, you will:

### Core Development
- Implement new page types and widgets
- Extend the YAML configuration parser
- Add new validators and field types
- Develop reusable UI components
- Enhance the Grist API client
- Improve state management with Provider/Riverpod

### Code Quality
- Write comprehensive unit and widget tests
- Follow Flutter and Dart best practices
- Maintain code documentation
- Perform code reviews
- Ensure code passes static analysis
- Keep dependencies up to date

### Architecture
- Design modular, extensible components
- Maintain separation of concerns
- Follow the established project structure
- Document architectural decisions
- Ensure backward compatibility
- Optimize performance

### Testing & Quality Assurance
- Write tests for all new features
- Maintain test coverage above 70%
- Fix bugs and regressions
- Test across different Flutter versions
- Validate with real Grist instances

## Prerequisites

### Required Skills

#### Flutter & Dart (Essential)
- *Dart language*: Strong understanding of Dart syntax, async/await, futures, streams
- *Flutter widgets*: StatelessWidget, StatefulWidget, InheritedWidget
- *Material Design*: Material components, theming, navigation
- *State management*: Provider (currently used), understanding of Riverpod
- *Routing*: Flutter Navigator, named routes, route parameters

#### Software Development
- *Version control*: Git workflow, branching, pull requests
- *Testing*: Unit testing, widget testing, test-driven development
- *Code analysis*: Linting, static analysis, code formatting
- *Documentation*: Writing clear code comments and API documentation
- *Debugging*: Flutter DevTools, debugging techniques

#### REST APIs & HTTP
- *HTTP requests*: GET, POST, PATCH, DELETE
- *JSON*: Parsing, serialization, deserialization
- *Authentication*: API keys, bearer tokens
- *Error handling*: HTTP status codes, exception handling

### Recommended Skills

#### Advanced Flutter
- Custom paint and animation
- Platform channels for native integration
- Performance optimization techniques
- Accessibility features
- Internationalization (i18n)

#### DevOps & Tools
- Docker basics (for development environment)
- CI/CD concepts
- Package publishing (pub.dev)
- Build automation

#### Domain Knowledge
- Database concepts and CRUD operations
- Form validation patterns
- Authentication and authorization
- Security best practices

## Development Environment

### Required Tools

```bash
# Flutter SDK (3.0.0 or higher)
flutter --version

# Dart SDK (included with Flutter)
dart --version

# Git
git --version

# Docker (for Grist development environment)
docker --version
docker-compose --version
```

### Recommended IDE Setup

#### VS Code (Recommended)
```bash
# Install extensions:
# - Dart
# - Flutter
# - Flutter Widget Snippets
# - Pubspec Assist
# - Error Lens
```

#### Android Studio / IntelliJ IDEA
```bash
# Install plugins:
# - Flutter
# - Dart
```

### Editor Configuration

The project includes configuration files:

- `analysis_options.yaml` - Dart linter rules
- `.vscode/settings.json` - VS Code settings (if using VS Code)
- `.editorconfig` - Editor formatting rules

## Project Structure Overview

```
flutter-module/
├── lib/
│   ├── flutter_grist_widgets.dart    # Main library export
│   └── src/
│       ├── config/                   # YAML config parsing
│       │   ├── app_config.dart       # Config models
│       │   └── yaml_loader.dart      # YAML loading
│       ├── models/                   # Data models
│       │   ├── grist_config.dart
│       │   └── user_model.dart
│       ├── pages/                    # Page widgets
│       │   ├── login_page.dart
│       │   ├── home_page.dart
│       │   ├── front_page.dart
│       │   ├── data_master_page.dart
│       │   ├── data_detail_page.dart
│       │   ├── data_create_page.dart
│       │   └── admin_dashboard_page.dart
│       ├── providers/                # State management
│       │   └── auth_provider.dart
│       ├── services/                 # External services
│       │   └── grist_service.dart
│       ├── utils/                    # Utilities
│       │   ├── validators.dart
│       │   ├── expression_evaluator.dart
│       │   └── theme_utils.dart
│       └── widgets/                  # Reusable widgets
│           ├── grist_table_widget.dart
│           ├── grist_form_widget.dart
│           └── file_upload_widget.dart
├── test/                            # Unit & widget tests
│   ├── services/
│   └── utils/
├── example/                         # Example configurations
├── pubspec.yaml                     # Dependencies
├── analysis_options.yaml            # Linter config
└── README.md                        # Module documentation
```

## Key Concepts

### 1. YAML-Driven Architecture

The library generates complete Flutter apps from YAML configuration:

```yaml
app:
  name: "My App"

pages:
  - id: "home"
    type: "data_master"
    title: "Home Page"
```

Your role is to extend what can be configured via YAML.

### 2. Config-First Design

All features should be configurable through YAML when possible. Add new config options in `app_config.dart`:

```dart
class PageConfig {
  final String id;
  final String type;
  final String title;
  // Add new configuration options here
}
```

### 3. Widget System

Pages are built from reusable widgets:
- `GristTableWidget` - Data tables
- `GristFormWidget` - Forms
- `FileUploadWidget` - File uploads

Create new widgets in `lib/src/widgets/`.

### 4. State Management

Uses Provider for state management:
- `AuthProvider` - Authentication state
- Future providers for data as needed

### 5. Grist Integration

All data operations go through `GristService`:
- `fetchRecords()` - Get table data
- `createRecord()` - Create new records
- `updateRecord()` - Update existing records
- `deleteRecord()` - Delete records

## Getting Started

### 1. Clone and Setup

```bash
# Clone repository
git clone https://github.com/yourusername/flutterGristAPI.git
cd flutterGristAPI/flutter-module

# Get dependencies
flutter pub get

# Verify setup
flutter doctor
```

### 2. Run Tests

```bash
# Navigate to grist-module for Docker commands
cd ../grist-module

# Run all tests
./docker-test.sh all

# Or run specific tests
./docker-test.sh test
```

### 3. Make Your First Change

```bash
# Create a feature branch
git checkout -b feature/my-new-feature

# Edit code in flutter-module/lib/src/

# Run analysis
cd ../grist-module
./docker-test.sh analyze

# Write tests in flutter-module/test/

# Run tests
./docker-test.sh test

# Commit changes
git add .
git commit -m "feat: add new feature"
git push origin feature/my-new-feature
```

### 4. Submit Pull Request

- Create PR on GitHub
- Ensure all tests pass
- Request code review
- Address feedback
- Wait for approval and merge

## Development Workflow

> **Note**: See `development-workflow.typ` for detailed daily workflow, testing procedures, and Git workflow.

## Learning Resources

### Official Documentation
- *Flutter*: https://flutter.dev/docs
- *Dart*: https://dart.dev/guides
- *Provider*: https://pub.dev/packages/provider
- *Grist API*: https://support.getgrist.com/api/

### Project Documentation
- `quickstart.typ` - Environment setup and first contribution
- `architecture.typ` - Detailed architecture documentation
- `api-reference.typ` - Public API reference
- `extending.typ` - Adding new features and widgets

## Code Standards

### Naming Conventions
- Classes: `PascalCase` (e.g., `DataMasterPage`)
- Methods: `camelCase` (e.g., `fetchRecords`)
- Variables: `camelCase` (e.g., `userName`)
- Constants: `camelCase` (e.g., `defaultTimeout`)
- Private members: Prefix with `_` (e.g., `_isLoading`)

### File Organization
- One class per file
- File name matches class name in snake_case
- Group related classes in directories
- Keep files under 500 lines when possible

### Documentation
- All public APIs must have doc comments
- Use `///` for documentation comments
- Include examples for complex APIs
- Document parameters and return values

Example:
```dart

Future<List<Map<String, dynamic>>> fetchRecords(String tableName) async {
  // Implementation
}
```

## Communication

### GitHub Issues
- Bug reports
- Feature requests
- Discussion of architectural changes

### Pull Requests
- Code reviews
- Implementation discussions
- Feedback and suggestions

### Documentation
- Keep documentation up to date
- Document breaking changes
- Update CHANGELOG.md

## Next Steps

1. Read `quickstart.typ` for detailed environment setup
2. Review `architecture.typ` to understand the codebase
3. Check `api-reference.typ` for API documentation
4. See `extending.typ` for adding new features
5. Browse existing code in `lib/src/`
6. Run tests to verify your setup
7. Pick an issue from GitHub to work on

> **Success**: Welcome to the FlutterGristAPI development team! We're excited to have you contribute to making this library better.
