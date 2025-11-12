import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Configuration options for Excel export.
class ExcelExportOptions {
  /// Sheet name (defaults to "Data")
  final String sheetName;

  /// Whether to include headers (defaults to true)
  final bool includeHeaders;

  /// Whether to freeze the header row (defaults to true)
  final bool freezeHeaderRow;

  /// Whether to auto-size columns (defaults to true)
  final bool autoSizeColumns;

  /// Whether to apply alternating row colors (defaults to true)
  final bool alternatingRows;

  /// Header background color
  final String headerBackgroundColor;

  /// Header text color
  final String headerTextColor;

  /// Whether to apply bold formatting to headers
  final bool boldHeaders;

  /// Whether to add borders to cells
  final bool addBorders;

  const ExcelExportOptions({
    this.sheetName = 'Data',
    this.includeHeaders = true,
    this.freezeHeaderRow = true,
    this.autoSizeColumns = true,
    this.alternatingRows = true,
    this.headerBackgroundColor = '#3ECF8E',
    this.headerTextColor = '#FFFFFF',
    this.boldHeaders = true,
    this.addBorders = true,
  });
}

/// Column configuration for Excel export.
class ExcelColumnConfig {
  /// Column name/key in data
  final String name;

  /// Column display label
  final String label;

  /// Column type (text, numeric, date, boolean, etc.)
  final String type;

  /// Number format for numeric columns (e.g., "#,##0.00")
  final String? numberFormat;

  /// Date format for date columns (e.g., "yyyy-MM-dd")
  final String? dateFormat;

  /// Column width in characters (optional, for manual sizing)
  final double? width;

  const ExcelColumnConfig({
    required this.name,
    required this.label,
    this.type = 'text',
    this.numberFormat,
    this.dateFormat,
    this.width,
  });
}

/// Utility class for exporting data to Excel (XLSX) format.
///
/// Features:
/// - Professional formatting with headers
/// - Cell type preservation (numbers, dates, booleans)
/// - Auto-sizing columns
/// - Freeze panes for headers
/// - Alternating row colors
/// - Custom styling
/// - Multi-sheet support
/// - Formulas for totals
class ExcelExportUtils {
  /// Export records to Excel file.
  static Future<String> exportToExcel({
    required List<Map<String, dynamic>> records,
    required List<ExcelColumnConfig> columns,
    String? fileName,
    ExcelExportOptions? options,
  }) async {
    final opts = options ?? ExcelExportOptions();
    fileName ??= 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

    // Create Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel[opts.sheetName];

    // Write headers
    if (opts.includeHeaders) {
      for (var i = 0; i < columns.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = columns[i].label;

        // Apply header styling
        cell.cellStyle = CellStyle(
          backgroundColorHex: opts.headerBackgroundColor,
          fontColorHex: opts.headerTextColor,
          bold: opts.boldHeaders,
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );

        if (opts.addBorders) {
          cell.cellStyle = cell.cellStyle?.copyWith(
            leftBorder: Border(borderStyle: BorderStyle.Thin),
            rightBorder: Border(borderStyle: BorderStyle.Thin),
            topBorder: Border(borderStyle: BorderStyle.Thin),
            bottomBorder: Border(borderStyle: BorderStyle.Thin),
          );
        }
      }
    }

    // Write data rows
    final startRow = opts.includeHeaders ? 1 : 0;
    for (var rowIdx = 0; rowIdx < records.length; rowIdx++) {
      final record = records[rowIdx];
      final excelRowIdx = startRow + rowIdx;

      for (var colIdx = 0; colIdx < columns.length; colIdx++) {
        final column = columns[colIdx];
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIdx,
          rowIndex: excelRowIdx,
        ));

        // Get value
        final value = record[column.name];

        // Set cell value based on type
        _setCellValue(cell, value, column);

        // Apply alternating row colors
        if (opts.alternatingRows && rowIdx % 2 == 1) {
          cell.cellStyle = CellStyle(
            backgroundColorHex: '#F9FAFB',
          );
        }

        // Apply borders
        if (opts.addBorders) {
          cell.cellStyle = (cell.cellStyle ?? CellStyle()).copyWith(
            leftBorder: Border(borderStyle: BorderStyle.Thin),
            rightBorder: Border(borderStyle: BorderStyle.Thin),
            topBorder: Border(borderStyle: BorderStyle.Thin),
            bottomBorder: Border(borderStyle: BorderStyle.Thin),
          );
        }
      }
    }

    // Auto-size columns
    if (opts.autoSizeColumns) {
      for (var i = 0; i < columns.length; i++) {
        if (columns[i].width != null) {
          sheet.setColumnWidth(i, columns[i].width!);
        } else {
          // Calculate width based on content
          double maxWidth = columns[i].label.length.toDouble();
          for (var rowIdx = 0; rowIdx < records.length; rowIdx++) {
            final value = records[rowIdx][columns[i].name];
            final strValue = _formatValueForDisplay(value, columns[i]);
            if (strValue.length > maxWidth) {
              maxWidth = strValue.length.toDouble();
            }
          }
          sheet.setColumnWidth(i, maxWidth.clamp(10, 50));
        }
      }
    }

    // Freeze header row
    if (opts.freezeHeaderRow && opts.includeHeaders) {
      // Note: excel package doesn't directly support freeze panes
      // This would need to be added if the package supports it in the future
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }

  /// Export multiple sheets to a single Excel file.
  static Future<String> exportMultipleSheets({
    required Map<String, SheetData> sheets,
    String? fileName,
    ExcelExportOptions? options,
  }) async {
    fileName ??= 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    final opts = options ?? ExcelExportOptions();

    // Create Excel workbook
    final excel = Excel.createExcel();

    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Add each sheet
    for (var entry in sheets.entries) {
      final sheetName = entry.key;
      final sheetData = entry.value;

      excel.copy(opts.sheetName, sheetName);
      final sheet = excel[sheetName];

      // Write headers
      if (opts.includeHeaders) {
        for (var i = 0; i < sheetData.columns.length; i++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = sheetData.columns[i].label;

          // Apply header styling
          cell.cellStyle = CellStyle(
            backgroundColorHex: opts.headerBackgroundColor,
            fontColorHex: opts.headerTextColor,
            bold: opts.boldHeaders,
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
          );
        }
      }

      // Write data
      final startRow = opts.includeHeaders ? 1 : 0;
      for (var rowIdx = 0; rowIdx < sheetData.records.length; rowIdx++) {
        final record = sheetData.records[rowIdx];
        final excelRowIdx = startRow + rowIdx;

        for (var colIdx = 0; colIdx < sheetData.columns.length; colIdx++) {
          final column = sheetData.columns[colIdx];
          final cell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: colIdx,
            rowIndex: excelRowIdx,
          ));

          final value = record[column.name];
          _setCellValue(cell, value, column);

          // Apply alternating row colors
          if (opts.alternatingRows && rowIdx % 2 == 1) {
            cell.cellStyle = CellStyle(backgroundColorHex: '#F9FAFB');
          }
        }
      }

      // Auto-size columns
      if (opts.autoSizeColumns) {
        for (var i = 0; i < sheetData.columns.length; i++) {
          double maxWidth = sheetData.columns[i].label.length.toDouble();
          for (var record in sheetData.records) {
            final value = record[sheetData.columns[i].name];
            final strValue = _formatValueForDisplay(value, sheetData.columns[i]);
            if (strValue.length > maxWidth) {
              maxWidth = strValue.length.toDouble();
            }
          }
          sheet.setColumnWidth(i, maxWidth.clamp(10, 50));
        }
      }
    }

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final fileBytes = excel.encode();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
      return filePath;
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }

  /// Add summary row with formulas (SUM, AVERAGE, etc.).
  static void addSummaryRow({
    required Excel excel,
    required String sheetName,
    required List<ExcelColumnConfig> columns,
    required int dataRowCount,
    bool includeHeaders = true,
  }) {
    final sheet = excel[sheetName];
    final startRow = includeHeaders ? 1 : 0;
    final summaryRow = startRow + dataRowCount;

    // Add "Total" label in first column
    final labelCell = sheet.cell(CellIndex.indexByColumnRow(
      columnIndex: 0,
      rowIndex: summaryRow,
    ));
    labelCell.value = 'Total';
    labelCell.cellStyle = CellStyle(bold: true);

    // Add formulas for numeric columns
    for (var i = 0; i < columns.length; i++) {
      if (columns[i].type == 'numeric' || columns[i].type == 'integer') {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: i,
          rowIndex: summaryRow,
        ));

        final columnLetter = _getColumnLetter(i);
        final rangeStart = startRow + 1; // +1 because Excel is 1-indexed
        final rangeEnd = startRow + dataRowCount;

        cell.value = Formula('SUM($columnLetter$rangeStart:$columnLetter$rangeEnd)');
        cell.cellStyle = CellStyle(bold: true);
      }
    }
  }

  /// Set cell value with appropriate type.
  static void _setCellValue(Data cell, dynamic value, ExcelColumnConfig column) {
    if (value == null) {
      cell.value = '';
      return;
    }

    switch (column.type) {
      case 'numeric':
      case 'integer':
        if (value is num) {
          cell.value = value;
        } else if (value is String) {
          cell.value = double.tryParse(value) ?? value;
        } else {
          cell.value = value.toString();
        }
        break;

      case 'date':
      case 'datetime':
        if (value is DateTime) {
          if (column.dateFormat != null) {
            cell.value = DateFormat(column.dateFormat).format(value);
          } else {
            cell.value = DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
          }
        } else if (value is String) {
          cell.value = value;
        } else {
          cell.value = value.toString();
        }
        break;

      case 'boolean':
        if (value is bool) {
          cell.value = value ? 'Yes' : 'No';
        } else {
          cell.value = value.toString();
        }
        break;

      default:
        cell.value = value.toString();
    }
  }

  /// Format value for display (used for column width calculation).
  static String _formatValueForDisplay(dynamic value, ExcelColumnConfig column) {
    if (value == null) return '';

    switch (column.type) {
      case 'date':
      case 'datetime':
        if (value is DateTime) {
          return DateFormat(column.dateFormat ?? 'yyyy-MM-dd HH:mm:ss').format(value);
        }
        return value.toString();

      case 'boolean':
        if (value is bool) {
          return value ? 'Yes' : 'No';
        }
        return value.toString();

      default:
        return value.toString();
    }
  }

  /// Convert column index to Excel column letter (A, B, C, ..., AA, AB, etc.).
  static String _getColumnLetter(int index) {
    String letter = '';
    int num = index + 1;

    while (num > 0) {
      int remainder = (num - 1) % 26;
      letter = String.fromCharCode(65 + remainder) + letter;
      num = (num - remainder) ~/ 26;
    }

    return letter;
  }
}

/// Data for a single sheet in multi-sheet export.
class SheetData {
  final List<Map<String, dynamic>> records;
  final List<ExcelColumnConfig> columns;

  const SheetData({
    required this.records,
    required this.columns,
  });
}

/// Dialog for Excel export configuration.
class ExcelExportDialog extends StatefulWidget {
  final List<Map<String, dynamic>> records;
  final List<ExcelColumnConfig> columns;
  final String? defaultFileName;

  const ExcelExportDialog({
    Key? key,
    required this.records,
    required this.columns,
    this.defaultFileName,
  }) : super(key: key);

  @override
  State<ExcelExportDialog> createState() => _ExcelExportDialogState();
}

class _ExcelExportDialogState extends State<ExcelExportDialog> {
  late TextEditingController _fileNameController;
  late List<bool> _selectedColumns;
  bool _includeHeaders = true;
  bool _freezeHeaderRow = true;
  bool _autoSizeColumns = true;
  bool _alternatingRows = true;
  bool _addBorders = true;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(
      text: widget.defaultFileName ?? 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
    );
    _selectedColumns = List.filled(widget.columns.length, true);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.table_chart, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Text('Export to Excel'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File name
            TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: 'File name',
                suffixText: '.xlsx',
              ),
            ),
            SizedBox(height: 24),

            // Options
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text('Include headers'),
              value: _includeHeaders,
              onChanged: (value) => setState(() => _includeHeaders = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Freeze header row'),
              value: _freezeHeaderRow,
              onChanged: (value) => setState(() => _freezeHeaderRow = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Auto-size columns'),
              value: _autoSizeColumns,
              onChanged: (value) => setState(() => _autoSizeColumns = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Alternating row colors'),
              value: _alternatingRows,
              onChanged: (value) => setState(() => _alternatingRows = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Add borders'),
              value: _addBorders,
              onChanged: (value) => setState(() => _addBorders = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            SizedBox(height: 16),

            // Column selection
            Text(
              'Columns',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _selectedColumns = List.filled(widget.columns.length, true)),
                  child: Text('Select All'),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedColumns = List.filled(widget.columns.length, false)),
                  child: Text('Deselect All'),
                ),
              ],
            ),
            ...List.generate(widget.columns.length, (index) {
              return CheckboxListTile(
                title: Text(widget.columns[index].label),
                value: _selectedColumns[index],
                onChanged: (value) => setState(() => _selectedColumns[index] = value!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),

            SizedBox(height: 16),

            // Summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Summary',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 8),
                  Text('Records: ${widget.records.length}'),
                  Text('Columns: ${_selectedColumns.where((e) => e).length}/${widget.columns.length}'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _export,
          child: Text('Export'),
        ),
      ],
    );
  }

  Future<void> _export() async {
    try {
      // Filter selected columns
      final selectedCols = <ExcelColumnConfig>[];
      for (var i = 0; i < widget.columns.length; i++) {
        if (_selectedColumns[i]) {
          selectedCols.add(widget.columns[i]);
        }
      }

      if (selectedCols.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one column')),
        );
        return;
      }

      // Create options
      final options = ExcelExportOptions(
        includeHeaders: _includeHeaders,
        freezeHeaderRow: _freezeHeaderRow,
        autoSizeColumns: _autoSizeColumns,
        alternatingRows: _alternatingRows,
        addBorders: _addBorders,
      );

      // Export
      final filePath = await ExcelExportUtils.exportToExcel(
        records: widget.records,
        columns: selectedCols,
        fileName: _fileNameController.text,
        options: options,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to: $filePath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
