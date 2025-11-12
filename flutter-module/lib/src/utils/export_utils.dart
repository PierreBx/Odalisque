import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/grist_table_widget.dart';
import 'excel_export_utils.dart';
import 'pdf_export_utils.dart';

/// Utility class for exporting table data to various formats
class ExportUtils {
  /// Exports records to CSV format
  ///
  /// Parameters:
  /// - [records]: List of records to export
  /// - [columns]: Column configurations
  /// - [fileName]: Name of the export file (without extension)
  /// - [includeHeaders]: Whether to include column headers
  ///
  /// Returns the file path of the exported CSV file
  static Future<String> exportToCsv({
    required List<Map<String, dynamic>> records,
    required List<TableColumnConfig> columns,
    required String fileName,
    bool includeHeaders = true,
  }) async {
    final visibleColumns = columns.where((col) => col.visible).toList();

    // Build CSV data
    final List<List<dynamic>> csvData = [];

    // Add headers
    if (includeHeaders) {
      csvData.add(visibleColumns.map((col) => col.label).toList());
    }

    // Add data rows
    for (final record in records) {
      final fields = record['fields'] as Map<String, dynamic>? ?? {};
      final row = visibleColumns.map((col) {
        final value = fields[col.name];
        return _formatValueForExport(value, col.type);
      }).toList();
      csvData.add(row);
    }

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName.csv';
    final file = File(filePath);
    await file.writeAsString(csvString);

    return filePath;
  }

  /// Exports records to Excel format (XLSX)
  static Future<String> exportToExcel({
    required List<Map<String, dynamic>> records,
    required List<TableColumnConfig> columns,
    required String fileName,
    bool includeHeaders = true,
  }) async {
    final visibleColumns = columns.where((col) => col.visible).toList();

    // Convert to ExcelColumnConfig
    final excelColumns = visibleColumns.map((col) {
      return ExcelColumnConfig(
        name: col.name,
        label: col.label,
        type: col.type ?? 'text',
      );
    }).toList();

    // Extract fields from records
    final dataRecords = records.map((record) {
      final fields = record['fields'] as Map<String, dynamic>? ?? {};
      return fields;
    }).toList();

    // Create options
    final options = ExcelExportOptions(
      includeHeaders: includeHeaders,
      freezeHeaderRow: true,
      autoSizeColumns: true,
      alternatingRows: true,
      addBorders: true,
    );

    // Export using ExcelExportUtils
    return await ExcelExportUtils.exportToExcel(
      records: dataRecords,
      columns: excelColumns,
      fileName: '$fileName.xlsx',
      options: options,
    );
  }

  /// Exports records to PDF format
  static Future<String> exportToPdf({
    required List<Map<String, dynamic>> records,
    required List<TableColumnConfig> columns,
    required String fileName,
    String? title,
  }) async {
    final visibleColumns = columns.where((col) => col.visible).toList();

    // Convert to PdfColumnConfig
    final pdfColumns = visibleColumns.map((col) {
      return PdfColumnConfig(
        name: col.name,
        label: col.label,
        type: col.type ?? 'text',
      );
    }).toList();

    // Extract fields from records
    final dataRecords = records.map((record) {
      final fields = record['fields'] as Map<String, dynamic>? ?? {};
      return fields;
    }).toList();

    // Create options
    final options = PdfExportOptions(
      title: title ?? 'Data Export',
      includeHeaders: true,
      includePageNumbers: true,
      includeTimestamp: true,
      addBorders: true,
      alternatingRows: true,
    );

    // Export using PdfExportUtils
    return await PdfExportUtils.exportToPdf(
      records: dataRecords,
      columns: pdfColumns,
      fileName: '$fileName.pdf',
      options: options,
    );
  }

  /// Formats a value for export (removes formatting, converts to plain text)
  static String _formatValueForExport(dynamic value, String? type) {
    if (value == null) return '';

    switch (type?.toLowerCase()) {
      case 'boolean':
      case 'bool':
        return value.toString() == 'true' || value == true ? 'true' : 'false';

      case 'date':
        try {
          final date = DateTime.parse(value.toString());
          return DateFormat('yyyy-MM-dd').format(date);
        } catch (_) {
          return value.toString();
        }

      case 'datetime':
        try {
          final date = DateTime.parse(value.toString());
          return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
        } catch (_) {
          return value.toString();
        }

      case 'file':
      case 'image':
        // For data URLs, just indicate that a file is attached
        final valueStr = value.toString();
        if (valueStr.startsWith('data:')) {
          return '[File Attached]';
        }
        return valueStr.split('/').last; // Get filename from URL

      default:
        return value.toString();
    }
  }

  /// Shows a dialog to configure export options
  static Future<ExportConfig?> showExportDialog({
    required BuildContext context,
    required List<TableColumnConfig> columns,
    required int recordCount,
  }) async {
    return showDialog<ExportConfig>(
      context: context,
      builder: (context) => ExportDialog(
        columns: columns,
        recordCount: recordCount,
      ),
    );
  }
}

/// Configuration for export operation
class ExportConfig {
  final String fileName;
  final List<String> selectedColumns;
  final bool includeHeaders;
  final ExportFormat format;

  const ExportConfig({
    required this.fileName,
    required this.selectedColumns,
    this.includeHeaders = true,
    this.format = ExportFormat.csv,
  });
}

/// Export format options
enum ExportFormat {
  csv,
  excel,
  pdf,
}

/// Dialog for configuring export options
class ExportDialog extends StatefulWidget {
  final List<TableColumnConfig> columns;
  final int recordCount;

  const ExportDialog({
    super.key,
    required this.columns,
    required this.recordCount,
  });

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  late List<String> _selectedColumns;
  late TextEditingController _fileNameController;
  bool _includeHeaders = true;
  ExportFormat _format = ExportFormat.csv;

  @override
  void initState() {
    super.initState();
    _selectedColumns = widget.columns
        .where((col) => col.visible)
        .map((col) => col.name)
        .toList();
    _fileNameController = TextEditingController(
      text: 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}',
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File name input
              TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  hintText: 'Enter file name (without extension)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Format selection
              const Text(
                'Format:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ExportFormat>(
                segments: const [
                  ButtonSegment(
                    value: ExportFormat.csv,
                    label: Text('CSV'),
                    icon: Icon(Icons.table_chart),
                  ),
                  ButtonSegment(
                    value: ExportFormat.excel,
                    label: Text('Excel'),
                    icon: Icon(Icons.grid_on),
                  ),
                  ButtonSegment(
                    value: ExportFormat.pdf,
                    label: Text('PDF'),
                    icon: Icon(Icons.picture_as_pdf),
                  ),
                ],
                selected: {_format},
                onSelectionChanged: (Set<ExportFormat> selected) {
                  setState(() => _format = selected.first);
                },
              ),
              const SizedBox(height: 16),

              // Include headers checkbox
              CheckboxListTile(
                value: _includeHeaders,
                onChanged: (value) {
                  setState(() => _includeHeaders = value ?? true);
                },
                title: const Text('Include column headers'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),

              // Column selection
              const Text(
                'Columns to export:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              // Select/Deselect all
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedColumns = widget.columns
                            .where((col) => col.visible)
                            .map((col) => col.name)
                            .toList();
                      });
                    },
                    icon: const Icon(Icons.check_box, size: 16),
                    label: const Text('Select All'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _selectedColumns.clear());
                    },
                    icon: const Icon(Icons.check_box_outline_blank, size: 16),
                    label: const Text('Deselect All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Column checkboxes
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: widget.columns
                      .where((col) => col.visible)
                      .map((col) {
                    return CheckboxListTile(
                      value: _selectedColumns.contains(col.name),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedColumns.add(col.name);
                          } else {
                            _selectedColumns.remove(col.name);
                          }
                        });
                      },
                      title: Text(col.label),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Export info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Records: ${widget.recordCount}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                    Text(
                      '• Columns: ${_selectedColumns.length}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                    Text(
                      '• Format: ${_format.name.toUpperCase()}',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedColumns.isEmpty
              ? null
              : () {
                  if (_fileNameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a file name'),
                      ),
                    );
                    return;
                  }

                  final config = ExportConfig(
                    fileName: _fileNameController.text,
                    selectedColumns: _selectedColumns,
                    includeHeaders: _includeHeaders,
                    format: _format,
                  );

                  Navigator.of(context).pop(config);
                },
          icon: const Icon(Icons.download),
          label: const Text('Export'),
        ),
      ],
    );
  }
}
