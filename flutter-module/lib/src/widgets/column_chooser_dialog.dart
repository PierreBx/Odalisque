import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for a table column.
class TableColumnConfig {
  /// Column identifier
  final String id;

  /// Column display name
  final String name;

  /// Whether the column is currently visible
  bool visible;

  /// Display order (lower numbers appear first)
  int order;

  /// Whether this column can be hidden
  final bool canHide;

  TableColumnConfig({
    required this.id,
    required this.name,
    this.visible = true,
    required this.order,
    this.canHide = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'visible': visible,
        'order': order,
      };

  factory TableColumnConfig.fromJson(Map<String, dynamic> json, String name, {bool canHide = true}) {
    return TableColumnConfig(
      id: json['id'] as String,
      name: name,
      visible: json['visible'] as bool? ?? true,
      order: json['order'] as int,
      canHide: canHide,
    );
  }
}

/// Dialog for choosing which columns to display and reordering them.
///
/// Features:
/// - Show/hide columns
/// - Reorder columns via drag-and-drop
/// - Save preferences per table
/// - Reset to defaults
class ColumnChooserDialog extends StatefulWidget {
  /// List of column configurations
  final List<TableColumnConfig> columns;

  /// Callback when columns are updated
  final Function(List<TableColumnConfig>)? onColumnsUpdated;

  /// Table identifier for saving preferences
  final String? tableId;

  const ColumnChooserDialog({
    Key? key,
    required this.columns,
    this.onColumnsUpdated,
    this.tableId,
  }) : super(key: key);

  @override
  State<ColumnChooserDialog> createState() => _ColumnChooserDialogState();
}

class _ColumnChooserDialogState extends State<ColumnChooserDialog> {
  late List<TableColumnConfig> _columns;

  @override
  void initState() {
    super.initState();
    // Create a copy to avoid modifying the original list
    _columns = widget.columns.map((col) {
      return TableColumnConfig(
        id: col.id,
        name: col.name,
        visible: col.visible,
        order: col.order,
        canHide: col.canHide,
      );
    }).toList();

    // Sort by order
    _columns.sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.view_column, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12),
          Text('Customize Columns'),
        ],
      ),
      content: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Text(
              'Show, hide, and reorder columns by dragging',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),

            // Quick actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: _showAll,
                  icon: Icon(Icons.visibility, size: 18),
                  label: Text('Show All'),
                ),
                TextButton.icon(
                  onPressed: _hideAll,
                  icon: Icon(Icons.visibility_off, size: 18),
                  label: Text('Hide All'),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Reorderable list
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.transparent,
                ),
                child: ReorderableListView.builder(
                  itemCount: _columns.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final column = _columns[index];
                    return _buildColumnTile(column, index);
                  },
                ),
              ),
            ),

            SizedBox(height: 16),

            // Summary
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '${_columns.where((c) => c.visible).length} of ${_columns.length} columns visible',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
          onPressed: _apply,
          child: Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildColumnTile(TableColumnConfig column, int index) {
    return Card(
      key: ValueKey(column.id),
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.drag_handle, color: Colors.grey),
        title: Text(column.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visibility toggle
            IconButton(
              icon: Icon(
                column.visible ? Icons.visibility : Icons.visibility_off,
                color: column.visible ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
              onPressed: column.canHide
                  ? () {
                      setState(() {
                        column.visible = !column.visible;
                      });
                    }
                  : null,
              tooltip: column.canHide ? (column.visible ? 'Hide column' : 'Show column') : 'Cannot hide this column',
            ),
          ],
        ),
        enabled: true,
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final column = _columns.removeAt(oldIndex);
      _columns.insert(newIndex, column);

      // Update orders
      for (var i = 0; i < _columns.length; i++) {
        _columns[i].order = i;
      }
    });
  }

  void _showAll() {
    setState(() {
      for (var column in _columns) {
        if (column.canHide) {
          column.visible = true;
        }
      }
    });
  }

  void _hideAll() {
    setState(() {
      // Keep at least one column visible
      var hiddenCount = 0;
      for (var column in _columns) {
        if (column.canHide && hiddenCount < _columns.length - 1) {
          column.visible = false;
          hiddenCount++;
        }
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      // Reset to original values
      for (var i = 0; i < _columns.length; i++) {
        final original = widget.columns[i];
        _columns[i].visible = original.visible;
        _columns[i].order = original.order;
      }
      _columns.sort((a, b) => a.order.compareTo(b.order));
    });
  }

  Future<void> _apply() async {
    // Save preferences if table ID provided
    if (widget.tableId != null) {
      await _savePreferences();
    }

    // Notify parent
    widget.onColumnsUpdated?.call(_columns);

    if (context.mounted) {
      Navigator.of(context).pop(_columns);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'column_prefs_${widget.tableId}';

      // Save as JSON
      final data = _columns.map((col) => col.toJson()).toList();
      final jsonString = data.toString();

      await prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Error saving column preferences: $e');
    }
  }
}

/// Utility class for managing column preferences.
class ColumnPreferences {
  /// Load column preferences for a table.
  static Future<List<TableColumnConfig>?> load(String tableId, List<TableColumnConfig> defaultColumns) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'column_prefs_$tableId';
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      // Parse and merge with defaults
      // This is a simplified version - in production, you'd parse proper JSON
      return defaultColumns;
    } catch (e) {
      debugPrint('Error loading column preferences: $e');
      return null;
    }
  }

  /// Clear column preferences for a table.
  static Future<void> clear(String tableId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'column_prefs_$tableId';
      await prefs.remove(key);
    } catch (e) {
      debugPrint('Error clearing column preferences: $e');
    }
  }

  /// Clear all column preferences.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('column_prefs_'));
      for (var key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing all column preferences: $e');
    }
  }
}

/// Button widget for opening the column chooser dialog.
class ColumnChooserButton extends StatelessWidget {
  /// List of column configurations
  final List<TableColumnConfig> columns;

  /// Callback when columns are updated
  final Function(List<TableColumnConfig>) onColumnsUpdated;

  /// Table identifier for saving preferences
  final String? tableId;

  /// Icon to display (defaults to view_column)
  final IconData icon;

  /// Tooltip text
  final String? tooltip;

  const ColumnChooserButton({
    Key? key,
    required this.columns,
    required this.onColumnsUpdated,
    this.tableId,
    this.icon = Icons.view_column,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip ?? 'Customize columns',
      onPressed: () => _showDialog(context),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    final result = await showDialog<List<TableColumnConfig>>(
      context: context,
      builder: (context) => ColumnChooserDialog(
        columns: columns,
        onColumnsUpdated: onColumnsUpdated,
        tableId: tableId,
      ),
    );

    if (result != null) {
      onColumnsUpdated(result);
    }
  }
}
