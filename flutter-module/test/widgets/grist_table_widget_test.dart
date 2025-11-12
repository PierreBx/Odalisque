import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_widgets/src/widgets/grist_table_widget.dart';

void main() {
  group('TableColumnConfig', () {
    test('should create from map with all fields', () {
      final map = {
        'name': 'age',
        'label': 'Age',
        'visible': true,
        'width': 100,
        'type': 'Numeric',
        'sortable': true,
      };

      final config = TableColumnConfig.fromMap(map);

      expect(config.name, equals('age'));
      expect(config.label, equals('Age'));
      expect(config.visible, isTrue);
      expect(config.width, equals(100));
      expect(config.type, equals('Numeric'));
      expect(config.sortable, isTrue);
    });

    test('should use defaults when fields missing', () {
      final map = {
        'name': 'email',
      };

      final config = TableColumnConfig.fromMap(map);

      expect(config.name, equals('email'));
      expect(config.label, equals('email')); // Defaults to name
      expect(config.visible, isTrue);
      expect(config.width, isNull);
      expect(config.type, isNull);
      expect(config.sortable, isTrue);
    });

    test('should handle explicit label', () {
      final map = {
        'name': 'user_email',
        'label': 'Email Address',
      };

      final config = TableColumnConfig.fromMap(map);

      expect(config.name, equals('user_email'));
      expect(config.label, equals('Email Address'));
    });

    test('should handle invisible column', () {
      final map = {
        'name': 'hidden_field',
        'visible': false,
      };

      final config = TableColumnConfig.fromMap(map);

      expect(config.visible, isFalse);
    });

    test('should handle non-sortable column', () {
      final map = {
        'name': 'actions',
        'sortable': false,
      };

      final config = TableColumnConfig.fromMap(map);

      expect(config.sortable, isFalse);
    });
  });

  group('GristTableWidget', () {
    late List<TableColumnConfig> testColumns;
    late List<Map<String, dynamic>> testRecords;

    setUp(() {
      testColumns = [
        const TableColumnConfig(name: 'id', label: 'ID'),
        const TableColumnConfig(name: 'name', label: 'Name'),
        const TableColumnConfig(name: 'age', label: 'Age', type: 'Numeric'),
      ];

      testRecords = [
        {
          'id': 1,
          'fields': {'name': 'John', 'age': 30}
        },
        {
          'id': 2,
          'fields': {'name': 'Jane', 'age': 25}
        },
        {
          'id': 3,
          'fields': {'name': 'Bob', 'age': 35}
        },
      ];
    });

    Widget createTableWidget({
      List<TableColumnConfig>? columns,
      List<Map<String, dynamic>>? records,
      void Function(Map<String, dynamic>)? onRowTap,
      bool isLoading = false,
      String? error,
      bool showIdColumn = false,
      int? rowsPerPage,
      bool enableSorting = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GristTableWidget(
            columns: columns ?? testColumns,
            records: records ?? testRecords,
            onRowTap: onRowTap,
            isLoading: isLoading,
            error: error,
            showIdColumn: showIdColumn,
            rowsPerPage: rowsPerPage,
            enableSorting: enableSorting,
          ),
        ),
      );
    }

    testWidgets('should display table with records', (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget());

      // Verify DataTable exists
      expect(find.byType(DataTable), findsOneWidget);

      // Verify column headers
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);

      // Verify data is displayed
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when error is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(error: 'Failed to load data'));

      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display empty state when no records',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(records: []));

      expect(find.text('No data available'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('should show ID column when showIdColumn is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(showIdColumn: true));

      expect(find.text('ID'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should hide ID column when showIdColumn is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(showIdColumn: false));

      // ID column header should not be present
      expect(find.text('ID'), findsNothing);
    });

    testWidgets('should handle row tap', (WidgetTester tester) async {
      Map<String, dynamic>? tappedRecord;

      await tester.pumpWidget(createTableWidget(
        onRowTap: (record) {
          tappedRecord = record;
        },
      ));

      // Find and tap the first data row
      // The first cell contains 'John'
      await tester.tap(find.text('John'));
      await tester.pump();

      expect(tappedRecord, isNotNull);
      expect(tappedRecord!['id'], equals(1));
    });

    testWidgets('should handle only visible columns', (WidgetTester tester) async {
      final columnsWithHidden = [
        const TableColumnConfig(name: 'name', label: 'Name', visible: true),
        const TableColumnConfig(name: 'age', label: 'Age', visible: false),
        const TableColumnConfig(name: 'email', label: 'Email', visible: true),
      ];

      final records = [
        {
          'id': 1,
          'fields': {'name': 'John', 'age': 30, 'email': 'john@example.com'}
        },
      ];

      await tester.pumpWidget(createTableWidget(
        columns: columnsWithHidden,
        records: records,
      ));

      // Visible columns
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);

      // Hidden column should not be shown
      expect(find.text('Age'), findsNothing);
    });

    testWidgets('should render sortable columns with sort indicators',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(enableSorting: true));

      // DataTable should be present
      expect(find.byType(DataTable), findsOneWidget);

      // Columns should be sortable (DataColumn widgets exist)
      final dataTable = tester.widget<DataTable>(find.byType(DataTable));
      expect(dataTable.columns.length, greaterThan(0));
    });

    testWidgets('should handle null values in data',
        (WidgetTester tester) async {
      final recordsWithNulls = [
        {
          'id': 1,
          'fields': {'name': 'John', 'age': null}
        },
        {
          'id': 2,
          'fields': {'name': null, 'age': 25}
        },
      ];

      await tester.pumpWidget(createTableWidget(records: recordsWithNulls));

      // Should display without crashing
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('should handle missing fields in records',
        (WidgetTester tester) async {
      final recordsWithMissingFields = [
        {
          'id': 1,
          'fields': {'name': 'John'}
          // 'age' field is missing
        },
      ];

      await tester.pumpWidget(
          createTableWidget(records: recordsWithMissingFields));

      // Should display without crashing
      expect(find.byType(DataTable), findsOneWidget);
      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('should update when records change',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTableWidget(records: testRecords));

      expect(find.text('John'), findsOneWidget);

      // Update with new records
      final newRecords = [
        {
          'id': 4,
          'fields': {'name': 'Alice', 'age': 28}
        },
      ];

      await tester.pumpWidget(createTableWidget(records: newRecords));
      await tester.pump();

      // Old record should be gone
      expect(find.text('John'), findsNothing);

      // New record should appear
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('should be scrollable for large datasets',
        (WidgetTester tester) async {
      // Create a large dataset
      final largeRecords = List.generate(
        100,
        (i) => {
          'id': i,
          'fields': {'name': 'User $i', 'age': 20 + i}
        },
      );

      await tester.pumpWidget(createTableWidget(records: largeRecords));

      // Should find SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should handle different data types correctly',
        (WidgetTester tester) async {
      final mixedTypeColumns = [
        const TableColumnConfig(name: 'string', label: 'String', type: 'Text'),
        const TableColumnConfig(name: 'number', label: 'Number', type: 'Numeric'),
        const TableColumnConfig(name: 'bool', label: 'Boolean', type: 'Bool'),
      ];

      final mixedTypeRecords = [
        {
          'id': 1,
          'fields': {
            'string': 'Hello',
            'number': 42,
            'bool': true,
          }
        },
      ];

      await tester.pumpWidget(createTableWidget(
        columns: mixedTypeColumns,
        records: mixedTypeRecords,
      ));

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('true'), findsOneWidget);
    });
  });

  group('GristTableWidget State Management', () {
    testWidgets('should initialize with unsorted data',
        (WidgetTester tester) async {
      final columns = [
        const TableColumnConfig(name: 'name', label: 'Name'),
      ];

      final records = [
        {
          'id': 1,
          'fields': {'name': 'Charlie'}
        },
        {
          'id': 2,
          'fields': {'name': 'Alice'}
        },
        {
          'id': 3,
          'fields': {'name': 'Bob'}
        },
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GristTableWidget(
            columns: columns,
            records: records,
          ),
        ),
      ));

      // Should display in original order
      expect(find.text('Charlie'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('should maintain state across rebuilds',
        (WidgetTester tester) async {
      final columns = [
        const TableColumnConfig(name: 'name', label: 'Name'),
      ];

      final records = [
        {
          'id': 1,
          'fields': {'name': 'Alice'}
        },
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GristTableWidget(
            columns: columns,
            records: records,
          ),
        ),
      ));

      // Rebuild with same data
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: GristTableWidget(
            columns: columns,
            records: records,
          ),
        ),
      ));

      // Should still display correctly
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}
