import 'package:flutter/material.dart';
import '../models/grist_config.dart';

/// A widget that displays Grist data in a form format.
class GristFormWidget extends StatefulWidget {
  /// Configuration for the Grist data source
  final GristConfig config;

  /// The ID of the record to display/edit
  final int recordId;

  const GristFormWidget({
    super.key,
    required this.config,
    required this.recordId,
  });

  @override
  State<GristFormWidget> createState() => _GristFormWidgetState();
}

class _GristFormWidgetState extends State<GristFormWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement form view
    return Center(
      child: Text('Grist Form Widget - Coming Soon'),
    );
  }
}
