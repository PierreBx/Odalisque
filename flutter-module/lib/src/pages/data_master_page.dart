import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../services/grist_service.dart';
import '../widgets/grist_table_widget.dart';
import '../widgets/skeleton_loader.dart';
import '../utils/notifications.dart';

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
  List<Map<String, dynamic>> _filteredRecords = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _applyFilter();
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredRecords = _records;
    } else {
      _filteredRecords = _records.where((record) {
        final fields = record['fields'] as Map<String, dynamic>? ?? {};
        // Search across all field values
        return fields.values.any((value) =>
            value?.toString().toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final grist = widget.config.config?['grist'] as Map<String, dynamic>?;
      final tableName = grist?['table'] as String?;

      if (tableName == null) {
        throw Exception('Table name not specified');
      }

      final gristService = context.read<GristService>();
      final records = await gristService.fetchRecords(tableName);

      setState(() {
        _records = records;
        _applyFilter();
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
    final gristConfig = widget.config.config?['grist'] as Map<String, dynamic>?;
    final columns = (gristConfig?['columns'] as List<dynamic>?)
            ?.map((col) => TableColumnConfig.fromMap(col as Map<String, dynamic>))
            .toList() ??
        [];
    final search = gristConfig?['search'] as Map<String, dynamic>?;
    final showSearch = search?['enabled'] as bool? ?? true;
    final createButton = gristConfig?['create_button'] as Map<String, dynamic>?;
    final showCreateButton = createButton?['enabled'] as bool? ?? false;

    return Column(
      children: [
        // Search bar
        if (showSearch)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: search?['placeholder'] as String? ?? 'Search...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),

        // Results count and create button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                '${_filteredRecords.length} record${_filteredRecords.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              if (showCreateButton)
                ElevatedButton.icon(
                  onPressed: () {
                    final navigateTo = createButton?['navigate_to'] as String?;
                    if (navigateTo != null) {
                      widget.onNavigate(navigateTo, null);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(createButton?['label'] as String? ?? 'Create'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Data table
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: GristTableWidget(
              columns: columns,
              records: _filteredRecords,
              isLoading: _isLoading,
              error: _error,
              showIdColumn: gristConfig?['show_id'] as bool? ?? false,
              rowsPerPage: gristConfig?['rows_per_page'] as int?,
              enableSorting: gristConfig?['enable_sorting'] as bool? ?? true,
              onRowTap: (record) {
                final onClick =
                    gristConfig?['on_row_click'] as Map<String, dynamic>?;
                if (onClick != null) {
                  final navigateTo = onClick['navigate_to'] as String?;
                  final paramField = onClick['pass_param'] as String?;
                  final fields = record['fields'] as Map<String, dynamic>? ?? {};

                  if (navigateTo != null && paramField != null) {
                    widget.onNavigate(navigateTo, {
                      paramField: fields[paramField] ?? record['id'],
                    });
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
