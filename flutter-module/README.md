# OdalIsquE

**OdalIsquE** (Odalisque) - A YAML-driven Flutter application generator for Grist.

Build complete, production-ready data-driven applications with authentication, navigation, forms, and more from a simple YAML configuration file.

> **Note**: This package was formerly known as `flutter_grist_widgets`. As of v0.11.0, it has been rebranded to **Odalisque**.

## 🌟 Features

### Core Features
- **YAML-Driven Configuration** - Define your entire app structure in YAML
- **Grist Integration** - Seamless connection to Grist databases
- **Authentication & Authorization** - bcrypt password hashing, session management, role-based access
- **Multi-Language Support** - English and French with 100+ translated strings (i18n)
- **Dark Mode** - Supabase-inspired beautiful dark theme with customization
- **Responsive Design** - Optimized for mobile, tablet, and desktop

### Advanced Field Types (21 Types)
- Text, multiline, email, URL, phone
- Integer, numeric with validation
- Date, time, datetime pickers
- Choice dropdowns with search
- Multi-select with chips
- Boolean (checkbox/switch/radio)
- File upload with drag & drop
- **Reference fields** (foreign keys, one-to-many)
- **Multi-reference fields** (many-to-many)
- **Rich text editor** (WYSIWYG with flutter_quill)
- **Color picker** (Material/HSV/RGB/Block)
- **Rating system** (stars, hearts, thumbs, etc.)

### Data Management
- **CRUD Operations** - Create, read, update, delete records
- **Server-Side Operations** - Search, filter, sort, paginate (10,000+ records)
- **Advanced Filtering** - 14 operators, type-specific filters, active filter chips
- **Data Export** - CSV, Excel (XLSX), PDF with print preview
- **Batch Operations** - Select and perform bulk actions on multiple records
- **Column Customization** - Show/hide, reorder with drag & drop

### Production-Ready Features
- **Enhanced Security**
  - Account lockout (5 attempts, 15-minute lockout)
  - Password reset with time-limited tokens
  - Remember me functionality
  - bcrypt password hashing
- **Audit Logging**
  - Track user actions (LOGIN, LOGOUT, CRUD, EXPORT)
  - Store up to 1,000 logs with filtering
  - Compliance and monitoring
- **Session Management**
  - Configurable timeout with auto-logout
  - Activity tracking
  - Session persistence

## 📦 Installation

Add Odalisque to your `pubspec.yaml`:

```yaml
dependencies:
  odalisque: ^0.11.0
```

Then run:

```bash
flutter pub get
```

## 🔄 Migration from flutter_grist_widgets

If you're upgrading from `flutter_grist_widgets`, update your imports:

**Before:**
```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';
```

**After:**
```dart
import 'package:odalisque/odalisque.dart';
```

All functionality remains identical - only the package name has changed.

## 🚀 Quick Start

### 1. Import the Package

```dart
import 'package:odalisque/odalisque.dart';
```

### 2. Create a YAML Configuration

```yaml
# config.yaml
app:
  name: "My App"
  theme:
    primary_color: "#3ECF8E"
    enable_dark_mode: true

grist:
  base_url: "https://docs.getgrist.com"
  api_key: "your_api_key"
  document_id: "your_doc_id"

auth:
  users_table: "Users"
  users_table_schema:
    email_field: "email"
    password_field: "password_hash"
    role_field: "role"
    active_field: "active"

navigation:
  drawer:
    header:
      title: "My App"
    items:
      - title: "Dashboard"
        icon: "dashboard"
        page: "dashboard"

pages:
  - id: "users_list"
    type: "data_master"
    title: "Users"
    table: "Users"
    columns:
      - name: "name"
        label: "Name"
      - name: "email"
        label: "Email"
```

### 3. Run Your App

```dart
void main() async {
  final config = await YamlLoader.loadFromAsset('assets/config.yaml');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: GristApp(config: config),
    ),
  );
}
```

## 🌍 Internationalization

Odalisque supports multiple languages out of the box:

```dart
MaterialApp(
  locale: languageProvider.locale,
  supportedLocales: LanguageProvider.supportedLocales,
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  // ...
)
```

Switch languages programmatically:

```dart
await languageProvider.setLocale(Locale('fr')); // French
await languageProvider.toggleLanguage(); // Toggle EN/FR
```

## 🎨 Theming

### Dark Mode

```dart
// Use Supabase-inspired dark theme
final themeProvider = Provider.of<ThemeProvider>(context);
MaterialApp(
  theme: themeProvider.getTheme(isDark: false),
  darkTheme: themeProvider.getTheme(isDark: true),
  themeMode: themeProvider.themeMode,
  // ...
)
```

### Custom Accent Colors

```dart
await themeProvider.setAccentColor(Colors.purple);
```

## 🔒 Security

### Account Lockout

```dart
if (await SecurityUtils.isAccountLocked(email)) {
  final minutes = await SecurityUtils.getRemainingLockoutMinutes(email);
  showError('Account locked. Try again in $minutes minutes.');
  return;
}

if (loginSuccess) {
  await SecurityUtils.resetFailedAttempts(email);
} else {
  await SecurityUtils.recordFailedAttempt(email);
}
```

### Audit Logging

```dart
await AuditLogger.log(
  userId: user.email,
  action: AuditLogger.actionLogin,
  resource: 'auth',
  details: 'User logged in successfully',
);

// Get logs
final logs = await AuditLogger.getLogs(
  userId: user.email,
  startDate: DateTime.now().subtract(Duration(days: 7)),
);
```

## 📊 Data Export

### Export to Multiple Formats

```dart
// CSV
await ExportUtils.exportToCSV(records: records);

// Excel
await ExcelExportUtils.exportToExcel(
  records: records,
  columns: columns,
  options: ExcelExportOptions(
    includeHeaders: true,
    autoSizeColumns: true,
  ),
);

// PDF with Print Preview
await PdfExportUtils.showPrintPreview(
  records: records,
  columns: columns,
);
```

## 🔄 Batch Operations

```dart
final manager = BatchOperationsManager();

BatchActionBar(
  manager: manager,
  actions: [
    BatchActions.delete(
      onDelete: (selectedIds) async {
        // Delete selected records
      },
    ),
    BatchActions.export(
      onExport: (selectedIds) async {
        // Export selected records
      },
    ),
  ],
)
```

## 📈 Statistics

- **64+ Dart Files** - Comprehensive codebase
- **~24,000+ Lines of Code** - Production-ready
- **21 Field Types** - Cover all use cases
- **38+ Widget Types** - Rich UI components
- **2 Languages** - English and French (100+ strings each)
- **3 Export Formats** - CSV, Excel, PDF
- **8 Predefined Batch Actions** - Ready to use
- **450+ Tests** - High quality assurance

## 📚 Module Contents

- **lib/** - Library source code
  - **src/config/** - Configuration models and parsers
  - **src/models/** - Data models
  - **src/pages/** - Page widgets
  - **src/providers/** - State management (Auth, Language, Theme)
  - **src/services/** - Grist API service
  - **src/theme/** - Theme system (AppTheme, ThemeProvider)
  - **src/utils/** - Utilities (validators, export, security, etc.)
  - **src/widgets/** - Reusable widgets (40+ components)
- **lib/l10n/** - Internationalization files (EN/FR)
- **test/** - Unit tests (450+ tests)
- **pubspec.yaml** - Package dependencies

## 🔍 Key Components

**Services**
- `GristService` - Main API client with CRUD operations

**Providers**
- `AuthProvider` - Authentication state management
- `LanguageProvider` - i18n state management
- `ThemeProvider` - Theme state management

**Widgets**
- `GristTableWidget` - Data table with sorting, pagination
- `FileUploadWidget` - Drag & drop file upload
- `RichTextFieldWidget` - WYSIWYG editor
- `ColorPickerFieldWidget` - Professional color picker
- `RatingFieldWidget` - Interactive ratings
- `BatchActionBar` - Bulk operations UI

**Pages**
- `DataMasterPage` - Tabular data view
- `DataDetailPage` - Detail/edit form
- `DataCreatePage` - Create new record
- `LoginPage` - Authentication

**Utils**
- `SecurityUtils` - Account lockout, password reset, remember me
- `AuditLogger` - Activity tracking
- `ExportUtils` - CSV/Excel/PDF export
- `FieldValidator` - Form validation

## 🗺️ Version History

### Recent Versions
- **v0.11.0** (2025-11) - Rebranding to Odalisque
- **v0.10.0** (2025-11) - Production readiness & i18n
- **v0.9.0** (2025-11) - Advanced input fields & batch operations
- **v0.8.0** (2025-11) - Data export & advanced table operations
- **v0.7.0** (2025-11) - Supabase-inspired dark mode
- **v0.6.0** (2025-11) - Multi-references & responsive design
- **v0.5.0** (2025-11) - Data relationships & scale

### Earlier Versions
- **v0.3.0** - File uploads, pagination
- **v0.2.0** - CRUD operations
- **v0.1.1** - Security fixes, validation
- **v0.1.0** - Initial release

## 🧪 Testing

Run all tests:
```bash
flutter test
```

The module includes 450+ unit tests covering:
- Validators
- Expression evaluator
- Authentication
- Utilities
- Widget components

## 📝 Documentation

For complete documentation, see:
- **CHANGELOG.md** - Version history
- **../documentation-module/** - Comprehensive guides
- **IMPLEMENTATION_STATUS.md** - Feature status

## 📧 Support

For issues and questions, please use the [GitHub Issues](https://github.com/yourusername/odalisque/issues) page.

## 📄 License

See LICENSE file for details.

## 🙏 Acknowledgments

Built with Flutter and powered by Grist databases.

---

**OdalIsquE** - Elegant Flutter applications, powered by data.
