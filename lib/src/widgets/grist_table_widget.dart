import 'package:flutter/material.dart';
import '../models/grist_config.dart';

/// A widget that displays Grist data in a tabular format.
class GristTableWidget extends StatefulWidget {
  /// Configuration for the Grist data source
  final GristConfig config;

  const GristTableWidget({
    super.key,
    required this.config,
  });

  @override
  State<GristTableWidget> createState() => _GristTableWidgetState();
}

class _GristTableWidgetState extends State<GristTableWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement table view
    return Center(
      child: Text('Grist Table Widget - Coming Soon'),
    );
  }
}
