#import "../common/styles.typ": *

#apply_standard_styles()

#doc_header(
  "Extending the Library",
  subtitle: "Adding New Features and Functionality",
  version: "0.3.0"
)

= Extending FlutterGristAPI

This guide shows you how to add new features and extend the library's capabilities.

== Adding New Validators

Validators are used to validate form field inputs. Here's how to add a new validator type.

=== Step 1: Add Validation Logic

Edit `lib/src/utils/validators.dart`:

```dart
class FieldValidator {
  // ... existing code ...

  String? validate(dynamic value) {
    switch (type) {
      case 'required':
        return _validateRequired(value);
      case 'email':
        return _validateEmail(value);
      // Add your new validator here
      case 'url':
        return _validateUrl(value);
      case 'phone':
        return _validatePhone(value);
      default:
        return null;
    }
  }

  // Add your validator implementation
  String? _validateUrl(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString();
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.'
      r'[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(stringValue)) {
      return message ?? 'Invalid URL format';
    }
    return null;
  }

  String? _validatePhone(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString().replaceAll(RegExp(r'[-()\s]'), '');
    final phoneRegex = RegExp(r'^\d{10}$');

    if (!phoneRegex.hasMatch(stringValue)) {
      return message ?? 'Invalid phone number';
    }
    return null;
  }
}
```

=== Step 2: Write Tests

Add tests to `test/utils/validators_test.dart`:

```dart
group('URL Validator', () {
  test('accepts valid URLs', () {
    final validator = FieldValidator(type: 'url');

    expect(validator.validate('https://example.com'), null);
    expect(validator.validate('http://test.org/path'), null);
    expect(validator.validate('https://sub.domain.com'), null);
  });

  test('rejects invalid URLs', () {
    final validator = FieldValidator(type: 'url');

    expect(validator.validate('not-a-url'), isNotNull);
    expect(validator.validate('example'), isNotNull);
    expect(validator.validate('www.example.com'), isNotNull);
  });

  test('handles null values', () {
    final validator = FieldValidator(type: 'url');
    expect(validator.validate(null), null);
  });

  test('uses custom message', () {
    final validator = FieldValidator(
      type: 'url',
      message: 'Please enter a valid URL',
    );
    final result = validator.validate('invalid');
    expect(result, 'Please enter a valid URL');
  });
});
```

=== Step 3: Run Tests

```bash
cd grist-module
./docker-test.sh test
```

=== Step 4: Usage in YAML

App designers can now use your validator:

```yaml
pages:
  - id: "website_form"
    type: "data_create"
    config:
      fields:
        - name: "website"
          label: "Website URL"
          type: "text"
          validators:
            - type: "url"
              message: "Please enter a valid URL"
```

== Adding New Page Types

Page types define different ways to display data. Here's how to add a new page type.

=== Step 1: Create Page Widget

Create `lib/src/pages/data_chart_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';

class DataChartPage extends StatefulWidget {
  final PageConfig config;

  const DataChartPage({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  State<DataChartPage> createState() => _DataChartPageState();
}

class _DataChartPageState extends State<DataChartPage> {
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = context.read<GristService>();
      final tableName = widget.config.config?['grist']?['table'] as String?;

      if (tableName == null) {
        throw Exception('Table name not configured');
      }

      final records = await service.fetchRecords(tableName);
      setState(() {
        _data = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.title),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    // TODO: Implement chart visualization
    return Center(
      child: Text('Chart view with ${_data.length} records'),
    );
  }
}
```

=== Step 2: Register Page Type

Edit `lib/src/pages/home_page.dart` to register the new page type:

```dart
import 'data_chart_page.dart';

class HomePage extends StatelessWidget {
  // ... existing code ...

  Widget _buildPageForRoute(BuildContext context, String route) {
    final pageConfig = _findPageConfig(route);
    if (pageConfig == null) {
      return NotFoundPage();
    }

    switch (pageConfig.type) {
      case 'front':
        return FrontPage(config: pageConfig);
      case 'data_master':
        return DataMasterPage(config: pageConfig);
      case 'data_detail':
        return DataDetailPage(config: pageConfig);
      case 'data_create':
        return DataCreatePage(config: pageConfig);
      case 'admin_dashboard':
        return AdminDashboardPage(config: pageConfig);
      // Add your new page type
      case 'data_chart':
        return DataChartPage(config: pageConfig);
      default:
        return UnknownPageTypePage(type: pageConfig.type);
    }
  }
}
```

=== Step 3: Export from Library

Add to `lib/flutter_grist_widgets.dart`:

```dart
// Page exports
export 'src/pages/data_create_page.dart';
export 'src/pages/data_chart_page.dart';  // Add this
```

=== Step 4: Write Tests

Create `test/pages/data_chart_page_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  group('DataChartPage', () {
    test('creates with valid config', () {
      final config = PageConfig(
        id: 'chart1',
        type: 'data_chart',
        title: 'Sales Chart',
        config: {
          'grist': {'table': 'Sales'},
        },
      );

      final page = DataChartPage(config: config);
      expect(page, isNotNull);
    });

    // Add more tests for data loading, error handling, etc.
  });
}
```

=== Step 5: Usage in YAML

```yaml
pages:
  - id: "sales_chart"
    type: "data_chart"
    title: "Sales Dashboard"
    menu:
      label: "Sales"
      icon: "bar_chart"
    config:
      grist:
        table: "Sales"
      chart_type: "bar"
      x_axis: "month"
      y_axis: "revenue"
```

== Adding Custom Widgets

Create reusable widgets that can be used across pages.

=== Step 1: Create Widget

Create `lib/src/widgets/data_card_widget.dart`:

```dart
import 'package:flutter/material.dart';

class DataCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const DataCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: effectiveColor, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

=== Step 2: Export Widget

Add to `lib/flutter_grist_widgets.dart`:

```dart
// Widget exports
export 'src/widgets/file_upload_widget.dart';
export 'src/widgets/grist_table_widget.dart';
export 'src/widgets/data_card_widget.dart';  // Add this
```

=== Step 3: Use in Pages

```dart
import '../widgets/data_card_widget.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        DataCardWidget(
          title: 'Total Users',
          value: '1,234',
          icon: Icons.people,
          color: Colors.blue,
        ),
        DataCardWidget(
          title: 'Active Sessions',
          value: '42',
          icon: Icons.online_prediction,
          color: Colors.green,
        ),
      ],
    );
  }
}
```

== Adding Configuration Options

Add new configuration options to make features customizable via YAML.

=== Step 1: Extend Config Model

Edit `lib/src/config/app_config.dart`:

```dart
class PageConfig {
  final String id;
  final String type;
  final String title;
  final MenuConfig? menu;
  final String? visibleIf;
  final Map<String, dynamic>? config;
  // Add new fields
  final bool enableRefresh;
  final int refreshInterval;

  const PageConfig({
    required this.id,
    required this.type,
    required this.title,
    this.menu,
    this.visibleIf,
    this.config,
    this.enableRefresh = true,
    this.refreshInterval = 30,
  });

  factory PageConfig.fromMap(Map<String, dynamic> map) {
    return PageConfig(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      menu: map['menu'] != null ? MenuConfig.fromMap(map['menu']) : null,
      visibleIf: map['visible_if'] as String?,
      config: map,
      enableRefresh: map['enable_refresh'] as bool? ?? true,
      refreshInterval: map['refresh_interval'] as int? ?? 30,
    );
  }
}
```

=== Step 2: Use in Pages

```dart
class DataMasterPage extends StatefulWidget {
  final PageConfig config;

  @override
  void initState() {
    super.initState();
    if (widget.config.enableRefresh) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    Timer.periodic(
      Duration(seconds: widget.config.refreshInterval),
      (_) => _loadData(),
    );
  }
}
```

=== Step 3: Document in Schema

Update YAML schema documentation:

```yaml
pages:
  - id: "products"
    type: "data_master"
    title: "Products"
    enable_refresh: true      # New option
    refresh_interval: 60      # New option (seconds)
    config:
      grist:
        table: "Products"
```

== Adding Services

Add new services for external integrations.

=== Step 1: Create Service

Create `lib/src/services/email_service.dart`:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {
  final String apiKey;
  final String apiUrl;

  EmailService({
    required this.apiKey,
    required this.apiUrl,
  });

  Future<void> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final url = Uri.parse('$apiUrl/send');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'to': to,
        'subject': subject,
        'body': body,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.statusCode}');
    }
  }

  Future<void> sendNotification(String userId, String message) async {
    // Implementation
  }
}
```

=== Step 2: Provide Service

Add to Provider setup in `grist_app.dart`:

```dart
return MultiProvider(
  providers: [
    // Existing providers
    Provider<GristService>.value(value: gristService),
    ChangeNotifierProvider(create: (_) => AuthProvider(...)),

    // New service
    Provider<EmailService>(
      create: (_) => EmailService(
        apiKey: config.email?.apiKey ?? '',
        apiUrl: config.email?.apiUrl ?? '',
      ),
    ),
  ],
  child: // ...
);
```

=== Step 3: Use in Pages

```dart
class DataCreatePage extends StatelessWidget {
  Future<void> _createRecord() async {
    // Create record
    final recordId = await gristService.createRecord(...);

    // Send notification email
    final emailService = context.read<EmailService>();
    await emailService.sendEmail(
      to: 'admin@example.com',
      subject: 'New Record Created',
      body: 'Record $recordId was created',
    );
  }
}
```

== Adding Utility Functions

Add helper functions to utilities.

=== Step 1: Create Utility File

Create `lib/src/utils/date_utils.dart`:

```dart
import 'package:intl/intl.dart';

class GristDateUtils {
  /// Format date for display
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(date);
  }

  /// Format datetime for display
  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  /// Parse Grist date string
  static DateTime? parseGristDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      // Grist timestamps are in seconds
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
```

=== Step 2: Export Utility

Add to `lib/flutter_grist_widgets.dart`:

```dart
export 'src/utils/validators.dart';
export 'src/utils/date_utils.dart';  // Add this
```

=== Step 3: Use in Code

```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

class DataDetailPage extends StatelessWidget {
  Widget _buildField(String name, dynamic value) {
    if (name.contains('date')) {
      final date = GristDateUtils.parseGristDate(value);
      if (date != null) {
        return Text(GristDateUtils.formatDate(date));
      }
    }
    return Text(value.toString());
  }
}
```

== Adding State Providers

Add new providers for managing state.

=== Step 1: Create Provider

Create `lib/src/providers/navigation_provider.dart`:

```dart
import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  String _currentRoute = '/home';
  final List<String> _history = [];

  String get currentRoute => _currentRoute;
  List<String> get history => List.unmodifiable(_history);

  void navigateTo(String route) {
    _history.add(_currentRoute);
    _currentRoute = route;
    notifyListeners();
  }

  void goBack() {
    if (_history.isNotEmpty) {
      _currentRoute = _history.removeLast();
      notifyListeners();
    }
  }

  bool get canGoBack => _history.isNotEmpty;
}
```

=== Step 2: Provide in App

```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(...)),
    ChangeNotifierProvider(create: (_) => NavigationProvider()),  // Add this
  ],
  child: // ...
);
```

=== Step 3: Use in Widgets

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: nav.canGoBack
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => nav.goBack(),
              )
            : null,
      ),
      // ...
    );
  }
}
```

== Testing Extensions

Always write tests for new features.

=== Unit Tests

```dart
// test/utils/date_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  group('GristDateUtils', () {
    test('formats date correctly', () {
      final date = DateTime(2025, 1, 10);
      expect(GristDateUtils.formatDate(date), '2025-01-10');
    });

    test('parses Grist timestamp', () {
      final timestamp = 1704844800; // 2024-01-10 00:00:00 UTC
      final date = GristDateUtils.parseGristDate(timestamp);
      expect(date, isNotNull);
    });
  });
}
```

=== Widget Tests

```dart
// test/widgets/data_card_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  testWidgets('DataCardWidget displays title and value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DataCardWidget(
            title: 'Test Title',
            value: '123',
            icon: Icons.star,
          ),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
```

== Best Practices for Extensions

=== 1. Follow Existing Patterns

Study existing code before adding new features:

```dart
// Good: Follows existing pattern
class MyNewPage extends StatefulWidget { }

// Bad: Inconsistent with library style
class myNewPage extends StatelessWidget { }
```

=== 2. Make Features Configurable

Allow YAML configuration when possible:

```dart
// Good: Configurable
final refreshInterval = widget.config.refreshInterval;

// Bad: Hard-coded
final refreshInterval = 60;
```

=== 3. Handle Errors Gracefully

```dart
// Good: Error handling
try {
  final data = await service.fetchRecords(table);
  return data;
} catch (e) {
  _showError('Failed to load data: $e');
  return [];
}

// Bad: No error handling
final data = await service.fetchRecords(table);
return data;
```

=== 4. Write Comprehensive Tests

```dart
// Good: Multiple test cases
test('validates empty string', () { });
test('validates null value', () { });
test('validates special characters', () { });

// Bad: Single test
test('validates', () { });
```

=== 5. Document Public APIs

```dart
// Good: Well documented
/// Validates a URL string.
///
/// Returns `null` if valid, error message otherwise.
///
/// Example:
/// ```dart
/// final error = validator.validate('https://example.com');
/// ```
String? validateUrl(String url) { }

// Bad: No documentation
String? validateUrl(String url) { }
```

=== 6. Maintain Backward Compatibility

```dart
// Good: Optional parameter with default
class MyWidget extends StatelessWidget {
  const MyWidget({
    required this.title,
    this.showIcon = true,  // New optional parameter
  });
}

// Bad: Breaking change
class MyWidget extends StatelessWidget {
  const MyWidget({
    required this.title,
    required this.showIcon,  // Required parameter breaks existing code
  });
}
```

== Extension Checklist

Before submitting your extension:

- [ ] Code follows project style guidelines
- [ ] All tests pass (`./docker-test.sh all`)
- [ ] New code is tested (unit and widget tests)
- [ ] Documentation is updated
- [ ] YAML schema is updated (if adding config options)
- [ ] CHANGELOG.md is updated
- [ ] No breaking changes (or clearly documented)
- [ ] Public APIs have doc comments
- [ ] Examples are provided
- [ ] Performance impact is minimal

== Publishing Extensions

If you create a useful extension:

1. Submit a pull request to the main repository
2. Provide clear documentation
3. Include examples
4. Ensure all tests pass
5. Respond to code review feedback

#info_box(type: "success")[
  Extensions are what make FlutterGristAPI powerful. Thank you for contributing!
]
