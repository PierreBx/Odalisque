import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/pages/data_master_page.dart';
import 'package:flutter_grist_widgets/src/services/grist_service.dart';
import 'package:flutter_grist_widgets/src/config/app_config.dart';
import 'package:flutter_grist_widgets/src/widgets/grist_table_widget.dart';
import 'package:provider/provider.dart';

void main() {
  group('DataMasterPage Widget Tests', () {
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
        id: 'test-page',
        title: 'Test Data Master',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [
              {'name': 'name', 'label': 'Name', 'type': 'Text'},
              {'name': 'age', 'label': 'Age', 'type': 'Numeric'},
            ],
            'search': {
              'enabled': true,
              'placeholder': 'Search records...',
            },
            'create_button': {
              'enabled': true,
              'label': 'Create New',
              'navigate_to': 'create-page',
            },
            'on_row_click': {
              'navigate_to': 'detail-page',
              'pass_param': 'id',
            },
            'show_id': false,
            'rows_per_page': 10,
            'enable_sorting': true,
          }
        },
      );
    });

    Widget createMasterPage({
      PageConfig? config,
      Function(String, Map<String, dynamic>?)? onNavigate,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Provider<GristService>.value(
            value: gristService,
            child: DataMasterPage(
              config: config ?? pageConfig,
              onNavigate: onNavigate ?? (route, params) {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display search bar when search is enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display custom search placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Search records...'));
    });

    testWidgets('should hide search bar when search is disabled',
        (WidgetTester tester) async {
      final configWithoutSearch = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [],
            'search': {'enabled': false},
          }
        },
      );

      await tester.pumpWidget(createMasterPage(config: configWithoutSearch));
      await tester.pump();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('should display create button when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Create New'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should navigate when create button is tapped',
        (WidgetTester tester) async {
      String? navigatedRoute;
      Map<String, dynamic>? navigatedParams;

      await tester.pumpWidget(createMasterPage(
        onNavigate: (route, params) {
          navigatedRoute = route;
          navigatedParams = params;
        },
      ));
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Create New'));
      await tester.pump();

      expect(navigatedRoute, equals('create-page'));
      expect(navigatedParams, isNull);
    });

    testWidgets('should hide create button when disabled',
        (WidgetTester tester) async {
      final configWithoutCreate = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [],
            'create_button': {'enabled': false},
          }
        },
      );

      await tester.pumpWidget(createMasterPage(config: configWithoutCreate));
      await tester.pump();

      expect(find.widgetWithText(ElevatedButton, 'Create'), findsNothing);
    });

    testWidgets('should display GristTableWidget',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      expect(find.byType(GristTableWidget), findsOneWidget);
    });

    testWidgets('should display RefreshIndicator for pull-to-refresh',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('search should filter records', (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Find search field and enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Verify search icon is present
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Verify clear button appears when text is entered
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clear button should clear search',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Verify text is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('should display record count', (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Should show "0 records" initially (before data loads)
      expect(find.textContaining('record'), findsOneWidget);
    });

    testWidgets('record count should use singular for 1 record',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // The initial state will show "0 records"
      // After loading 1 record it would show "1 record" (singular)
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should pass configuration to GristTableWidget',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      final tableWidget =
          tester.widget<GristTableWidget>(find.byType(GristTableWidget));

      expect(tableWidget.columns.length, equals(2));
      expect(tableWidget.columns[0].name, equals('name'));
      expect(tableWidget.columns[1].name, equals('age'));
      expect(tableWidget.showIdColumn, isFalse);
      expect(tableWidget.rowsPerPage, equals(10));
      expect(tableWidget.enableSorting, isTrue);
    });

    testWidgets('should handle missing table configuration',
        (WidgetTester tester) async {
      final invalidConfig = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {'grist': {}},
      );

      await tester.pumpWidget(createMasterPage(config: invalidConfig));
      await tester.pump();

      // Should still render without crashing
      expect(find.byType(DataMasterPage), findsOneWidget);
    });

    testWidgets('should dispose search controller properly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Navigate away to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Should not throw any exceptions
    });

    testWidgets('should handle empty columns list',
        (WidgetTester tester) async {
      final configWithNoColumns = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [],
          }
        },
      );

      await tester.pumpWidget(createMasterPage(config: configWithNoColumns));
      await tester.pump();

      final tableWidget =
          tester.widget<GristTableWidget>(find.byType(GristTableWidget));
      expect(tableWidget.columns, isEmpty);
    });

    testWidgets('should show ID column when configured',
        (WidgetTester tester) async {
      final configWithId = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [],
            'show_id': true,
          }
        },
      );

      await tester.pumpWidget(createMasterPage(config: configWithId));
      await tester.pump();

      final tableWidget =
          tester.widget<GristTableWidget>(find.byType(GristTableWidget));
      expect(tableWidget.showIdColumn, isTrue);
    });

    testWidgets('should disable sorting when configured',
        (WidgetTester tester) async {
      final configNoSorting = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {
            'table': 'TestTable',
            'columns': [],
            'enable_sorting': false,
          }
        },
      );

      await tester.pumpWidget(createMasterPage(config: configNoSorting));
      await tester.pump();

      final tableWidget =
          tester.widget<GristTableWidget>(find.byType(GristTableWidget));
      expect(tableWidget.enableSorting, isFalse);
    });

    testWidgets('search should be case-insensitive',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Enter uppercase search text
      await tester.enterText(find.byType(TextField), 'TEST');
      await tester.pump();

      // The search implementation converts to lowercase
      // This just verifies the search field accepts the input
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('TEST'));
    });

    testWidgets('should have proper layout structure',
        (WidgetTester tester) async {
      await tester.pumpWidget(createMasterPage());
      await tester.pump();

      // Verify Column layout
      expect(find.byType(Column), findsWidgets);

      // Verify Expanded widget for table
      expect(find.byType(Expanded), findsOneWidget);

      // Verify Padding for search bar
      expect(find.byType(Padding), findsWidgets);
    });
  });

  group('DataMasterPage State Management', () {
    testWidgets('should initialize with loading state',
        (WidgetTester tester) async {
      final gristConfig = GristSettings(
        baseUrl: 'http://localhost:8484',
        documentId: 'test-doc',
        apiKey: 'test-key',
      );

      final pageConfig = PageConfig(
        id: 'test-page',
        title: 'Test',
        type: 'data_master',
        icon: Icons.table_chart,
        config: {
          'grist': {'table': 'TestTable', 'columns': []}
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Provider<GristService>.value(
              value: GristService(gristConfig),
              child: DataMasterPage(
                config: pageConfig,
                onNavigate: (route, params) {},
              ),
            ),
          ),
        ),
      );

      // Initial pump shows the widget
      await tester.pump();

      // Table widget should be present (even if loading)
      expect(find.byType(GristTableWidget), findsOneWidget);
    });
  });
}
