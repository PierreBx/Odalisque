import 'package:flutter/material.dart';

/// Configuration for a table column.
class TableColumnConfig {
  final String name;
  final String label;
  final bool visible;
  final int? width;
  final String? type;

  const TableColumnConfig({
    required this.name,
    required this.label,
    this.visible = true,
    this.width,
    this.type,
  });

  factory TableColumnConfig.fromMap(Map<String, dynamic> map) {
    return TableColumnConfig(
      name: map['name'] as String,
      label: map['label'] as String? ?? map['name'] as String,
      visible: map['visible'] as bool? ?? true,
      width: map['width'] as int?,
      type: map['type'] as String?,
    );
  }
}

/// A widget that displays data in a scrollable data table format.
class GristTableWidget extends StatelessWidget {
  /// List of column configurations
  final List<TableColumnConfig> columns;

  /// List of data records to display
  final List<Map<String, dynamic>> records;

  /// Callback when a row is tapped
  final void Function(Map<String, dynamic> record)? onRowTap;

  /// Whether the table is in loading state
  final bool isLoading;

  /// Error message to display
  final String? error;

  /// Whether to show the ID column
  final bool showIdColumn;

  /// Maximum number of rows to display per page
  final int? rowsPerPage;

  const GristTableWidget({
    super.key,
    required this.columns,
    required this.records,
    this.onRowTap,
    this.isLoading = false,
    this.error,
    this.showIdColumn = false,
    this.rowsPerPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
          ],
        ),
      );
    }

    if (records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('No records found'),
          ],
        ),
      );
    }

    final visibleColumns = columns.where((col) => col.visible).toList();

    // Build columns for DataTable
    final dataColumns = <DataColumn>[
      if (showIdColumn)
        const DataColumn(
          label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ...visibleColumns.map(
        (col) => DataColumn(
          label: Text(
            col.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];

    // Build rows for DataTable
    final dataRows = records.map((record) {
      final fields = record['fields'] as Map<String, dynamic>? ?? {};
      final recordId = record['id'];

      return DataRow(
        onSelectChanged: onRowTap != null ? (_) => onRowTap!(record) : null,
        cells: [
          if (showIdColumn)
            DataCell(Text(recordId?.toString() ?? '')),
          ...visibleColumns.map((col) {
            final value = fields[col.name];
            return DataCell(
              Text(
                _formatValue(value, col.type),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: dataColumns,
          rows: dataRows,
          showCheckboxColumn: false,
          horizontalMargin: 16,
          columnSpacing: 24,
        ),
      ),
    );
  }

  String _formatValue(dynamic value, String? type) {
    if (value == null) return '—';

    switch (type) {
      case 'boolean':
      case 'Bool':
        return value.toString() == 'true' || value == true ? '✓' : '✗';
      case 'date':
      case 'Date':
        // Simple date formatting - could be enhanced
        return value.toString();
      case 'numeric':
      case 'Numeric':
      case 'Int':
        return value.toString();
      case 'currency':
        // Simple currency formatting
        final num? numValue = num.tryParse(value.toString());
        if (numValue != null) {
          return '\$${numValue.toStringAsFixed(2)}';
        }
        return value.toString();
      default:
        return value.toString();
    }
  }
}
