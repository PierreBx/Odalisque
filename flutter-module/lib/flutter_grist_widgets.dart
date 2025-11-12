/// A YAML-driven Flutter application generator for Grist.
///
/// Build complete data-driven applications with authentication, navigation,
/// and forms from a simple YAML configuration file.
library flutter_grist_widgets;

// Core exports
export 'src/grist_app.dart';
export 'src/config/app_config.dart';
export 'src/config/yaml_loader.dart';
export 'src/models/user_model.dart';
export 'src/services/grist_service.dart';
export 'src/providers/auth_provider.dart';
export 'src/providers/language_provider.dart';
export 'src/utils/validators.dart';

// Widget exports
export 'src/widgets/file_upload_widget.dart';
export 'src/widgets/grist_table_widget.dart';
export 'src/widgets/field_widgets/reference_field_widget.dart';
export 'src/widgets/field_widgets/multi_reference_field_widget.dart';
export 'src/widgets/field_widgets/date_field_widget.dart';
export 'src/widgets/field_widgets/choice_field_widget.dart';
export 'src/widgets/field_widgets/boolean_field_widget.dart';
export 'src/widgets/field_widgets/multi_select_field_widget.dart';
export 'src/widgets/field_widgets/rich_text_field_widget.dart';
export 'src/widgets/field_widgets/color_picker_field_widget.dart';
export 'src/widgets/field_widgets/rating_field_widget.dart';
export 'src/widgets/image_preview_widget.dart';
export 'src/widgets/column_renderer.dart';
export 'src/widgets/column_chooser_dialog.dart';
export 'src/widgets/batch_action_bar.dart';

// Utility exports
export 'src/utils/field_type_builder.dart';
export 'src/utils/column_filter_utils.dart';
export 'src/utils/export_utils.dart';
export 'src/utils/excel_export_utils.dart';
export 'src/utils/pdf_export_utils.dart';
export 'src/utils/responsive_utils.dart';
export 'src/utils/theme_utils.dart';
export 'src/utils/batch_operations_utils.dart';
export 'src/utils/security_utils.dart';

// Theme exports
export 'src/theme/app_theme.dart';
export 'src/theme/theme_provider.dart';
export 'src/widgets/theme_toggle_widget.dart';

// Internationalization exports
export 'src/widgets/language_switcher_widget.dart';

// Page exports
export 'src/pages/data_create_page.dart';
