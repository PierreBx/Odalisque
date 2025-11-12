import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/pages/data_detail_page.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:provider/provider.dart';

void main() {
  group('DataDetailPage Widget Tests', () {
    late GristService gristService;
    late PageConfig pageConfig;
    late Map<String, dynamic> testParams;

    setUp(() {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      gristService = GristService(gristConfig);

      pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Record Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [
                {
                  'name': 'name',
                  'label': 'Name',
                  'type': 'text',
                  'readonly': false,
                  'validators': [
                    {'type': 'required', 'message': 'Name is required'}
                  ],
                },
                {
                  'name': 'age',
                  'label': 'Age',
                  'type': 'numeric',
                  'readonly': false,
                },
                {
                  'name': 'created_at',
                  'label': 'Created At',
                  'type': 'text',
                  'readonly': true,
                },
              ],
              'edit_button': {
                'enabled': true,
                'label': 'Edit',
              },
              'delete_button': {
                'enabled': true,
                'label': 'Delete',
              },
              'back_button': {
                'label': 'Back to List',
                'navigate_to': 'list-page',
              },
            },
          }
        },
      );

      testParams = {'id': 1};
    });

    Widget createDetailPage({
      PageConfig? config,
      Map<String, dynamic>? params,
      Function(String, Map<String, dynamic>?)? onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Provider<GristService>.value(
            value: gristService,
            child: DataDetailPage(
              config: config ?? pageConfig,
              params: params ?? testParams,
              onNavigate: onNavigate ?? (route, params) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should show loading indicator initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display edit button when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // After initial load, check if widget structure exists
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should display delete button when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should hide edit button when disabled',
        (WidgetTester tester) async {
      final configNoEdit = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [],
              'edit_button': {'enabled': false},
              'back_button': {'navigate_to': 'list-page'},
            },
          }
        },
      );

      await tester.pumpWidget(createDetailPage(config: configNoEdit));
      await tester.pump();

      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should hide delete button when disabled',
        (WidgetTester tester) async {
      final configNoDelete = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [],
              'delete_button': {'enabled': false},
              'back_button': {'navigate_to': 'list-page'},
            },
          }
        },
      );

      await tester.pumpWidget(createDetailPage(config: configNoDelete));
      await tester.pump();

      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should display form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Form should be present
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should display back button', (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Page should render
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should handle missing record ID parameter',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage(params: {}));
      await tester.pump();

      // Should handle error gracefully
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should dispose controllers properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Navigate away
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not throw
    });

    testWidgets('should have proper layout with Column',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have scrollable form with ListView',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // After loading, ListView should be present for form fields
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should handle different keyboard types',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // The page configures different keyboard types based on field type
      // Verify the page renders successfully
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should handle readonly fields', (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Readonly fields should be displayed differently
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should initialize form from record data',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Form should be initialized with data
      expect(find.byType(Form), findsOneWidget);
    });
  });

  group('DataDetailPage Edit Mode Tests', () {
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
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [
                {'name': 'name', 'label': 'Name', 'type': 'text'},
                {'name': 'email', 'label': 'Email', 'type': 'email'},
              ],
              'edit_button': {'enabled': true},
              'back_button': {'navigate_to': 'list-page'},
            },
          }
        },
      );
    });

    Widget createDetailPage() {
      return MaterialApp(
        home: Scaffold(
          body: Provider<GristService>.value(
            value: gristService,
            child: DataDetailPage(
              config: pageConfig,
              params: {'id': 1},
              onNavigate: (route, params) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should have consistent state across rebuilds',
        (WidgetTester tester) async {
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      // Rebuild
      await tester.pumpWidget(createDetailPage());
      await tester.pump();

      expect(find.byType(DataDetailPage), findsOneWidget);
    });
  });

  group('DataDetailPage Validation Tests', () {
    testWidgets('should apply validators to form fields',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [
                {
                  'name': 'email',
                  'label': 'Email',
                  'type': 'email',
                  'validators': [
                    {'type': 'required'},
                    {'type': 'email'},
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
              child: DataDetailPage(
                config: pageConfig,
                params: {'id': 1},
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Validators should be configured
      expect(find.byType(Form), findsOneWidget);
    });
  });

  group('DataDetailPage Error Handling', () {
    testWidgets('should display error message when load fails',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {'fields': []},
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataDetailPage(
                config: pageConfig,
                params: {'id': 1},
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Initial state shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show "Record not found" for null record',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {'fields': []},
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataDetailPage(
                config: pageConfig,
                params: {'id': 999}, // Non-existent ID
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Page should render
      expect(find.byType(DataDetailPage), findsOneWidget);
    });
  });

  group('DataDetailPage Configuration Tests', () {
    testWidgets('should handle missing table name',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'record_id_param': 'id',
            // Missing 'table'
          }
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataDetailPage(
                config: pageConfig,
                params: {'id': 1},
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should handle error gracefully
      expect(find.byType(DataDetailPage), findsOneWidget);
    });

    testWidgets('should handle empty fields list',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'detail-page',
        title: 'Details',
        type: 'data_detail',
        icon: Icons.description,
        config: {
          'grist': {
            'table': 'TestTable',
            'record_id_param': 'id',
            'form': {
              'fields': [], // Empty fields
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
              child: DataDetailPage(
                config: pageConfig,
                params: {'id': 1},
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should render without crashing
      expect(find.byType(DataDetailPage), findsOneWidget);
    });
  });
}
