import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';

/// Form view for displaying and editing a single record.
class DataDetailPage extends StatefulWidget {
  final PageConfig config;
  final Map<String, dynamic> params;
  final Function(String, Map<String, dynamic>?) onNavigate;

  const DataDetailPage({
    super.key,
    required this.config,
    required this.params,
    required this.onNavigate,
  });

  @override
  State<DataDetailPage> createState() => _DataDetailPageState();
}

class _DataDetailPageState extends State<DataDetailPage> {
  Map<String, dynamic>? _record;
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
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;
      final recordIdParam = grist?['record_id_param'] as String?;

      if (tableName == null || recordIdParam == null) {
        throw Exception('Table name or record ID parameter not specified');
      }

      final recordId = widget.params[recordIdParam];
      if (recordId == null) {
        throw Exception('Record ID not provided');
      }

      final gristService = context.read<GristService>();
      final record = await gristService.fetchRecord(tableName, recordId as int);

      setState(() {
        _record = record;
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

    if (_record == null) {
      return const Center(child: Text('Record not found'));
    }

    final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
    final form = grist?['form'] as Map<String, dynamic>?;
    final fields = _record!['fields'] as Map<String, dynamic>? ?? {};
    final formFields =
        (form?['fields'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final backButton = form?['back_button'] as Map<String, dynamic>?;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...formFields.map((fieldConfig) {
                final fieldName = fieldConfig['name'] as String?;
                final label = fieldConfig['label'] as String? ?? fieldName;
                final value = fields[fieldName];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value?.toString() ?? '—',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Divider(),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        // Back button
        if (backButton?['enabled'] == true)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(backButton?['label'] as String? ?? 'Back'),
                onPressed: () {
                  final navigateTo = backButton?['navigate_to'] as String?;
                  if (navigateTo != null) {
                    widget.onNavigate(navigateTo, null);
                  }
                },
              ),
            ),
          ),
      ],
    );
  }
}
