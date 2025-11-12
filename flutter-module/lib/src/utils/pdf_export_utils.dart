import 'dart:io';
import 'package:flutter/material.dart' hide Border;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Configuration options for PDF export.
class PdfExportOptions {
  /// Document title
  final String title;

  /// Document author
  final String? author;

  /// Document subject
  final String? subject;

  /// Page orientation (portrait or landscape)
  final PdfPageFormat pageFormat;

  /// Whether to include page numbers
  final bool includePageNumbers;

  /// Whether to include timestamp
  final bool includeTimestamp;

  /// Whether to include headers
  final bool includeHeaders;

  /// Custom header text
  final String? headerText;

  /// Custom footer text
  final String? footerText;

  /// Whether to add borders to table cells
  final bool addBorders;

  /// Whether to use alternating row colors
  final bool alternatingRows;

  /// Font size for body text
  final double fontSize;

  /// Font size for headers
  final double headerFontSize;

  const PdfExportOptions({
    this.title = 'Data Export',
    this.author,
    this.subject,
    this.pageFormat = PdfPageFormat.a4,
    this.includePageNumbers = true,
    this.includeTimestamp = true,
    this.includeHeaders = true,
    this.headerText,
    this.footerText,
    this.addBorders = true,
    this.alternatingRows = true,
    this.fontSize = 10,
    this.headerFontSize = 12,
  });
}

/// Column configuration for PDF export.
class PdfColumnConfig {
  /// Column name/key in data
  final String name;

  /// Column display label
  final String label;

  /// Column type (text, numeric, date, boolean, etc.)
  final String type;

  /// Date format for date columns
  final String? dateFormat;

  /// Flex factor for column width (1 = equal width)
  final int flex;

  const PdfColumnConfig({
    required this.name,
    required this.label,
    this.type = 'text',
    this.dateFormat,
    this.flex = 1,
  });
}

/// Utility class for exporting data to PDF format.
///
/// Features:
/// - Professional table layout
/// - Customizable page formats (A4, Letter, etc.)
/// - Headers and footers
/// - Page numbers
/// - Timestamps
/// - Auto page breaks
/// - Print preview support
class PdfExportUtils {
  /// Export records to PDF file.
  static Future<String> exportToPdf({
    required List<Map<String, dynamic>> records,
    required List<PdfColumnConfig> columns,
    String? fileName,
    PdfExportOptions? options,
  }) async {
    final opts = options ?? PdfExportOptions();
    fileName ??= 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';

    final pdf = await _createPdf(
      records: records,
      columns: columns,
      options: opts,
    );

    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  /// Show print preview dialog.
  static Future<void> showPrintPreview({
    required BuildContext context,
    required List<Map<String, dynamic>> records,
    required List<PdfColumnConfig> columns,
    PdfExportOptions? options,
  }) async {
    final opts = options ?? PdfExportOptions();

    await Printing.layoutPdf(
      onLayout: (format) async {
        final pdf = await _createPdf(
          records: records,
          columns: columns,
          options: opts,
        );
        return pdf.save();
      },
      name: opts.title,
      format: opts.pageFormat,
    );
  }

  /// Create PDF document.
  static Future<pw.Document> _createPdf({
    required List<Map<String, dynamic>> records,
    required List<PdfColumnConfig> columns,
    required PdfExportOptions options,
  }) async {
    final pdf = pw.Document(
      title: options.title,
      author: options.author,
      subject: options.subject,
    );

    // Calculate rows per page (approximate)
    final rowsPerPage = _calculateRowsPerPage(options);
    final totalPages = (records.length / rowsPerPage).ceil();

    for (var pageNum = 0; pageNum < totalPages; pageNum++) {
      final startIdx = pageNum * rowsPerPage;
      final endIdx = (startIdx + rowsPerPage).clamp(0, records.length);
      final pageRecords = records.sublist(startIdx, endIdx);

      pdf.addPage(
        pw.Page(
          pageFormat: options.pageFormat,
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                if (pageNum == 0) _buildHeader(options),

                // Table
                pw.Expanded(
                  child: _buildTable(
                    columns: columns,
                    records: pageRecords,
                    options: options,
                    startRowIndex: startIdx,
                  ),
                ),

                // Footer
                _buildFooter(
                  options: options,
                  currentPage: pageNum + 1,
                  totalPages: totalPages,
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  /// Build document header.
  static pw.Widget _buildHeader(PdfExportOptions options) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Text(
          options.title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),

        // Custom header text
        if (options.headerText != null) ...[
          pw.Text(
            options.headerText!,
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 8),
        ],

        // Timestamp
        if (options.includeTimestamp) ...[
          pw.Text(
            'Generated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 16),
        ],

        // Divider
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 16),
      ],
    );
  }

  /// Build data table.
  static pw.Widget _buildTable({
    required List<PdfColumnConfig> columns,
    required List<Map<String, dynamic>> records,
    required PdfExportOptions options,
    required int startRowIndex,
  }) {
    return pw.Table(
      border: options.addBorders ? pw.TableBorder.all(color: PdfColors.grey400) : null,
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: pw.FlexColumnWidth(columns[i].flex.toDouble()),
      },
      children: [
        // Header row
        if (options.includeHeaders)
          pw.TableRow(
            decoration: pw.BoxDecoration(
              color: PdfColors.green300,
            ),
            children: columns.map((col) {
              return pw.Container(
                padding: pw.EdgeInsets.all(8),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  col.label,
                  style: pw.TextStyle(
                    fontSize: options.headerFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
          ),

        // Data rows
        ...records.asMap().entries.map((entry) {
          final rowIndex = entry.key;
          final record = entry.value;

          return pw.TableRow(
            decoration: options.alternatingRows && rowIndex % 2 == 1
                ? pw.BoxDecoration(color: PdfColors.grey100)
                : null,
            children: columns.map((col) {
              final value = record[col.name];
              final displayValue = _formatValueForPdf(value, col);

              return pw.Container(
                padding: pw.EdgeInsets.all(6),
                alignment: _getAlignment(col.type),
                child: pw.Text(
                  displayValue,
                  style: pw.TextStyle(fontSize: options.fontSize),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  /// Build document footer.
  static pw.Widget _buildFooter({
    required PdfExportOptions options,
    required int currentPage,
    required int totalPages,
  }) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 16),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Footer text
            pw.Text(
              options.footerText ?? '',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),

            // Page numbers
            if (options.includePageNumbers)
              pw.Text(
                'Page $currentPage of $totalPages',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Format value for PDF display.
  static String _formatValueForPdf(dynamic value, PdfColumnConfig column) {
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

      case 'numeric':
      case 'integer':
        if (value is num) {
          return NumberFormat('#,##0.##').format(value);
        }
        return value.toString();

      default:
        return value.toString();
    }
  }

  /// Get text alignment based on column type.
  static pw.Alignment _getAlignment(String type) {
    switch (type) {
      case 'numeric':
      case 'integer':
        return pw.Alignment.centerRight;
      case 'boolean':
        return pw.Alignment.center;
      default:
        return pw.Alignment.centerLeft;
    }
  }

  /// Calculate approximate rows per page.
  static int _calculateRowsPerPage(PdfExportOptions options) {
    // Rough estimation based on page height and font size
    // A4 height is approximately 842 points
    final pageHeight = options.pageFormat.height;
    final headerHeight = 150.0; // Approximate header height
    final footerHeight = 50.0; // Approximate footer height
    final rowHeight = options.fontSize + 12; // Font size + padding

    final availableHeight = pageHeight - headerHeight - footerHeight;
    return (availableHeight / rowHeight).floor();
  }
}

/// Dialog for PDF export configuration.
class PdfExportDialog extends StatefulWidget {
  final List<Map<String, dynamic>> records;
  final List<PdfColumnConfig> columns;
  final String? defaultFileName;
  final String? defaultTitle;

  const PdfExportDialog({
    Key? key,
    required this.records,
    required this.columns,
    this.defaultFileName,
    this.defaultTitle,
  }) : super(key: key);

  @override
  State<PdfExportDialog> createState() => _PdfExportDialogState();
}

class _PdfExportDialogState extends State<PdfExportDialog> {
  late TextEditingController _fileNameController;
  late TextEditingController _titleController;
  late TextEditingController _headerController;
  late TextEditingController _footerController;
  late List<bool> _selectedColumns;

  PdfPageFormat _pageFormat = PdfPageFormat.a4;
  bool _includePageNumbers = true;
  bool _includeTimestamp = true;
  bool _includeHeaders = true;
  bool _addBorders = true;
  bool _alternatingRows = true;

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController(
      text: widget.defaultFileName ?? 'export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
    _titleController = TextEditingController(text: widget.defaultTitle ?? 'Data Export');
    _headerController = TextEditingController();
    _footerController = TextEditingController();
    _selectedColumns = List.filled(widget.columns.length, true);
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    _titleController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Text('Export to PDF'),
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
                suffixText: '.pdf',
              ),
            ),
            SizedBox(height: 16),

            // Document title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Document title',
              ),
            ),
            SizedBox(height: 24),

            // Page format
            Text(
              'Page Format',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            SegmentedButton<PdfPageFormat>(
              segments: [
                ButtonSegment(value: PdfPageFormat.a4, label: Text('A4')),
                ButtonSegment(value: PdfPageFormat.letter, label: Text('Letter')),
                ButtonSegment(
                  value: PdfPageFormat.a4.landscape,
                  label: Text('Landscape'),
                ),
              ],
              selected: {_pageFormat},
              onSelectionChanged: (Set<PdfPageFormat> newSelection) {
                setState(() => _pageFormat = newSelection.first);
              },
            ),
            SizedBox(height: 16),

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
              title: Text('Include page numbers'),
              value: _includePageNumbers,
              onChanged: (value) => setState(() => _includePageNumbers = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text('Include timestamp'),
              value: _includeTimestamp,
              onChanged: (value) => setState(() => _includeTimestamp = value!),
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
            CheckboxListTile(
              title: Text('Alternating row colors'),
              value: _alternatingRows,
              onChanged: (value) => setState(() => _alternatingRows = value!),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),

            SizedBox(height: 16),

            // Header and footer
            TextField(
              controller: _headerController,
              decoration: InputDecoration(
                labelText: 'Custom header text (optional)',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _footerController,
              decoration: InputDecoration(
                labelText: 'Custom footer text (optional)',
              ),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _showPreview,
          child: Text('Preview'),
        ),
        ElevatedButton(
          onPressed: _export,
          child: Text('Export'),
        ),
      ],
    );
  }

  Future<void> _showPreview() async {
    final selectedCols = _getSelectedColumns();

    if (selectedCols.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one column')),
      );
      return;
    }

    final options = _buildOptions();

    await PdfExportUtils.showPrintPreview(
      context: context,
      records: widget.records,
      columns: selectedCols,
      options: options,
    );
  }

  Future<void> _export() async {
    try {
      final selectedCols = _getSelectedColumns();

      if (selectedCols.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one column')),
        );
        return;
      }

      final options = _buildOptions();

      final filePath = await PdfExportUtils.exportToPdf(
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

  List<PdfColumnConfig> _getSelectedColumns() {
    final selectedCols = <PdfColumnConfig>[];
    for (var i = 0; i < widget.columns.length; i++) {
      if (_selectedColumns[i]) {
        selectedCols.add(widget.columns[i]);
      }
    }
    return selectedCols;
  }

  PdfExportOptions _buildOptions() {
    return PdfExportOptions(
      title: _titleController.text,
      pageFormat: _pageFormat,
      includePageNumbers: _includePageNumbers,
      includeTimestamp: _includeTimestamp,
      includeHeaders: _includeHeaders,
      headerText: _headerController.text.isEmpty ? null : _headerController.text,
      footerText: _footerController.text.isEmpty ? null : _footerController.text,
      addBorders: _addBorders,
      alternatingRows: _alternatingRows,
    );
  }
}
