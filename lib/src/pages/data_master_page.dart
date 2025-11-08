import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';

/// Tabular view of Grist table data.
class DataMasterPage extends StatefulWidget {
  final PageConfig config;
  final Function(String, Map<String, dynamic>?) onNavigate;

  const DataMasterPage({
    super.key,
    required this.config,
    required this.onNavigate,
  });

  @override
  State<DataMasterPage> createState() => _DataMasterPageState();
}

class _DataMasterPageState extends State<DataMasterPage> {
  List<Map<String, dynamic>> _records = [];
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
      final grist = config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;

      if (tableName == null) {
        throw Exception('Table name not specified');
      }

      final gristService = context.read<GristService>();
      final records = await gristService.fetchRecords(tableName);

      setState(() {
        _records = records;
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final gristConfig = widget.config.config?['grist'] as Map<String, dynamic>?;
    final columns =
        (gristConfig?['columns'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];
    final recordNumber = gristConfig?['record_number'] as Map<String, dynamic>?;
    final showRecordNumber = recordNumber?['enabled'] as bool? ?? false;
    final recordNumberLabel = recordNumber?['column_label'] as String? ?? 'N';

    return RefreshIndicator(
      onRefresh: _loadData,
      child: _records.isEmpty
          ? const Center(child: Text('No records found'))
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                final fields = record['fields'] as Map<String, dynamic>? ?? {};

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: showRecordNumber
                        ? CircleAvatar(
                            child: Text('${index + 1}'),
                          )
                        : null,
                    title: Text(_getRecordTitle(fields, columns)),
                    subtitle: Text(_getRecordSubtitle(fields, columns)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final onClick =
                          gristConfig?['on_row_click'] as Map<String, dynamic>?;
                      if (onClick != null) {
                        final navigateTo = onClick['navigate_to'] as String?;
                        final paramField = onClick['pass_param'] as String?;

                        if (navigateTo != null && paramField != null) {
                          widget.onNavigate(navigateTo, {
                            paramField: fields[paramField],
                          });
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  String _getRecordTitle(
      Map<String, dynamic> fields, List<Map<String, dynamic>> columns) {
    if (columns.isEmpty) {
      return fields.values.first?.toString() ?? 'Record';
    }

    final firstColumn = columns.first;
    final fieldName = firstColumn['name'] as String?;
    return fields[fieldName]?.toString() ?? 'Record';
  }

  String _getRecordSubtitle(
      Map<String, dynamic> fields, List<Map<String, dynamic>> columns) {
    if (columns.length < 2) {
      return fields['id']?.toString() ?? '';
    }

    final subtitleParts = columns.skip(1).take(2).map((col) {
      final fieldName = col['name'] as String?;
      return fields[fieldName]?.toString() ?? '';
    }).where((s) => s.isNotEmpty);

    return subtitleParts.join(' • ');
  }
}
