import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/pages/data_create_page.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:flutter_grist_widgets/src/widgets/file_upload_widget.dart';
import 'package:provider/provider.dart';

void main() {
  group('DataCreatePage Widget Tests', () {
    late GristService gristService;
    late PageConfig pageConfig;

    setUp(() {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      gristService = GristService(gristConfig);

      pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create Record',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {
                  'name': 'name',
                  'label': 'Name',
                  'type': 'text',
                  'validators': [
                    {'type': 'required', 'message': 'Name is required'}
                  ],
                },
                {
                  'name': 'email',
                  'label': 'Email',
                  'type': 'email',
                  'validators': [
                    {'type': 'required'},
                    {'type': 'email'},
                  ],
                },
                {
                  'name': 'age',
                  'label': 'Age',
                  'type': 'numeric',
                },
                {
                  'name': 'bio',
                  'label': 'Biography',
                  'type': 'text',
                },
              ],
              'back_button': {
                'label': 'Cancel',
                'navigate_to': 'list-page',
              },
            },
          }
        },
      );
    });

    Widget createCreatePage({
      PageConfig? config,
      Function(String, Map<String, dynamic>?)? onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Provider<GristService>.value(
            value: gristService,
            child: DataCreatePage(
              config: config ?? pageConfig,
              onNavigate: onNavigate ?? (route, params) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display "Create New Record" title',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.text('Create New Record'), findsOneWidget);
    });

    testWidgets('should display form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should display all configured fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      // Should find text form fields for name, email, age, bio
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('should display cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('should display create button', (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.widgetWithText(ElevatedButton, 'Create'), findsOneWidget);
    });

    testWidgets('cancel button should navigate back',
        (WidgetTester tester) async {
      String? navigatedRoute;

      await tester.pumpWidget(createCreatePage(
        onNavigate: (route, params) {
          navigatedRoute = route;
        },
      ));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pump();

      expect(navigatedRoute, equals('list-page'));
    });

    testWidgets('should have scrollable form', (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(Row), findsOneWidget); // Bottom button row
    });

    testWidgets('should dispose controllers properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      // Navigate away
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not throw
    });

    testWidgets('should skip readonly fields', (WidgetTester tester) async {
      final configWithReadonly = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {'name': 'name', 'label': 'Name', 'type': 'text'},
                {'name': 'id', 'label': 'ID', 'type': 'text', 'readonly': true},
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(createCreatePage(config: configWithReadonly));

      // Should only show 1 text field (readonly is skipped)
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should handle empty fields list',
        (WidgetTester tester) async {
      final configEmpty = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(createCreatePage(config: configEmpty));

      // Should render without crashing
      expect(find.byType(DataCreatePage), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('should initialize empty controllers',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      // All fields should be empty initially
      final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField));
      for (var field in textFields) {
        expect(field.controller?.text, isEmpty);
      }
    });

    testWidgets('should have correct keyboard types',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      final emailField = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      ).elementAt(1); // Second field is email

      expect(emailField.keyboardType, equals(TextInputType.emailAddress));
    });

    testWidgets('text type fields should have multiple lines',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      final bioField = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      ).elementAt(3); // Fourth field is bio (text type)

      expect(bioField.maxLines, equals(3));
    });

    testWidgets('numeric fields should have number keyboard',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      final ageField = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      ).elementAt(2); // Third field is age

      expect(ageField.keyboardType, equals(TextInputType.number));
    });

    testWidgets('should apply validators to fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(createCreatePage());

      final nameField = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      ).first;

      expect(nameField.validator, isNotNull);
    });
  });

  group('DataCreatePage File Upload Tests', () {
    testWidgets('should display FileUploadWidget for file fields',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {'name': 'name', 'label': 'Name', 'type': 'text'},
                {
                  'name': 'avatar',
                  'label': 'Avatar',
                  'type': 'file',
                  'allowed_extensions': ['jpg', 'png'],
                  'max_file_size': 5242880, // 5MB
                },
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(FileUploadWidget), findsOneWidget);
    });

    testWidgets('should pass file upload configuration',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {
                  'name': 'document',
                  'label': 'Document',
                  'type': 'file',
                  'allowed_extensions': ['pdf', 'doc'],
                  'max_file_size': 10485760,
                },
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      final uploadWidget =
          tester.widget<FileUploadWidget>(find.byType(FileUploadWidget));

      expect(uploadWidget.label, equals('Document'));
      expect(uploadWidget.allowedExtensions, equals(['pdf', 'doc']));
      expect(uploadWidget.maxFileSize, equals(10485760));
    });
  });

  group('DataCreatePage Date Picker Tests', () {
    testWidgets('should display date picker for date fields',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {'name': 'name', 'label': 'Name', 'type': 'text'},
                {'name': 'birth_date', 'label': 'Birth Date', 'type': 'date'},
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(InputDecorator), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('date field should show calendar icon',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {'name': 'event_date', 'label': 'Event Date', 'type': 'date'},
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });
  });

  group('DataCreatePage Validation Tests', () {
    testWidgets('form validation should work', (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {
                  'name': 'name',
                  'label': 'Name',
                  'type': 'text',
                  'validators': [
                    {'type': 'required', 'message': 'Name is required'}
                  ],
                },
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      // Try to submit without filling required field
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pump();

      // Validation error should appear
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {
                  'name': 'email',
                  'label': 'Email',
                  'type': 'email',
                  'validators': [
                    {'type': 'email', 'message': 'Invalid email'}
                  ],
                },
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid-email');

      // Try to submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create'));
      await tester.pump();

      // Validation error should appear
      expect(find.text('Invalid email'), findsOneWidget);
    });
  });

  group('DataCreatePage Configuration Tests', () {
    testWidgets('should handle missing table name',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            // Missing 'table'
            'form': {
              'fields': [],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      // Should render without crashing
      expect(find.byType(DataCreatePage), findsOneWidget);
    });

    testWidgets('should handle URL field type', (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'create-page',
        title: 'Create',
        type: 'data_create',
        icon: Icons.add,
        config: {
          'grist': {
            'table': 'TestTable',
            'form': {
              'fields': [
                {'name': 'website', 'label': 'Website', 'type': 'url'},
              ],
              'back_button': {'navigate_to': 'list'},
            },
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataCreatePage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      final urlField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(urlField.keyboardType, equals(TextInputType.url));
    });
  });
}
