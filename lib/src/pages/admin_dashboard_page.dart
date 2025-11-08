import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';

/// Admin dashboard with system information.
class AdminDashboardPage extends StatefulWidget {
  final PageConfig config;

  const AdminDashboardPage({
    super.key,
    required this.config,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<Map<String, dynamic>> _tables = [];
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
      final gristService = context.read<GristService>();
      final tables = await gristService.fetchTables();

      // Fetch record counts for configured tables
      final widgets =
          widget.config.config?['widgets'] as List<dynamic>? ?? [];
      final dbSummaryWidget = widgets.firstWhere(
        (w) => w['type'] == 'database_summary',
        orElse: () => <String, dynamic>{},
      ) as Map<String, dynamic>?;

      if (dbSummaryWidget != null) {
        final gristTables =
            (dbSummaryWidget['grist_tables'] as List<dynamic>?)?.cast<String>() ??
                [];

        for (final tableName in gristTables) {
          final tableInfo = tables.firstWhere(
            (t) => t['id'] == tableName,
            orElse: () => {'id': tableName},
          );

          try {
            final records = await gristService.fetchRecords(tableName);
            tableInfo['record_count'] = records.length;
          } catch (e) {
            tableInfo['record_count'] = 'Error';
          }
        }

        // Filter to only show configured tables
        _tables = tables
            .where((t) => gristTables.contains(t['id']))
            .toList();
      }

      setState(() {
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

    final appConfig = context.read<AppConfig>();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // System info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  _buildInfoRow('Application', appConfig.app.name),
                  _buildInfoRow('Version', appConfig.app.version),
                  _buildInfoRow(
                      'Grist Document', appConfig.grist.documentId),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Database summary card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Database Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  ..._tables.map((table) {
                    return ListTile(
                      leading: const Icon(Icons.table_chart),
                      title: Text(table['id'] as String? ?? 'Unknown'),
                      trailing: Text(
                        '${table['record_count']} records',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
