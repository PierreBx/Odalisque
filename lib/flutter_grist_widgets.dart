/// A Flutter library for visualizing and editing data tables stored in Grist.
///
/// This library provides widgets that make it easy to display and edit Grist data
/// in your Flutter applications. Simply provide a Grist object ID and configure
/// which attributes should be readable or writable.
library flutter_grist_widgets;

// Core exports
export 'src/models/grist_config.dart';
export 'src/widgets/grist_table_widget.dart';
export 'src/widgets/grist_form_widget.dart';
export 'src/services/grist_api_service.dart';
