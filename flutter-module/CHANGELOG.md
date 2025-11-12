## 0.11.0

### Rebranding Release - OdalIsquE

#### 🎯 Theme: Rebranding to Odalisque

This release rebrands the library from "flutter_grist_widgets" to **OdalIsquE** (Odalisque), giving it a unique and memorable identity while maintaining all existing functionality.

#### Rebranding Changes ⭐
* **Package Name** - Renamed to `odalisque`
  * Changed from `flutter_grist_widgets` to `odalisque`
  * Updated in pubspec.yaml and all imports
  * Updated homepage URL to reflect new name
* **Library Name** - Updated main library
  * Renamed `flutter_grist_widgets.dart` to `odalisque.dart`
  * Updated library declaration to `library odalisque`
  * Enhanced library documentation
* **Application Title** - Updated in all locales
  * English: "Odalisque"
  * French: "Odalisque"
  * Updated in localization files (app_en.arb, app_fr.arb)
* **Documentation** - Updated throughout
  * Package description updated
  * Library documentation enhanced
  * References updated in documentation

#### About the Name "Odalisque"

The name "Odalisque" was chosen to give this YAML-driven Flutter framework a unique and memorable identity. While maintaining its core purpose of generating data-driven applications for Grist, the new name better reflects its elegant and powerful capabilities.

#### Migration Guide

For existing users, update your import statements:

**Before:**
```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';
```

**After:**
```dart
import 'package:odalisque/odalisque.dart';
```

Update your `pubspec.yaml`:

**Before:**
```yaml
dependencies:
  flutter_grist_widgets: ^0.10.0
```

**After:**
```yaml
dependencies:
  odalisque: ^0.11.0
```

#### Breaking Changes
* **Package name changed** from `flutter_grist_widgets` to `odalisque`
* **Main library file renamed** from `flutter_grist_widgets.dart` to `odalisque.dart`
* **All imports must be updated** to use new package name
* All functionality remains identical - only naming has changed

#### No Functional Changes
* All features from v0.10.0 remain unchanged
* No new features added
* No bug fixes
* This is purely a rebranding release

---

## 0.10.0

### Major Feature Release - Production Readiness & Internationalization

#### 🎯 Theme: Security hardening, internationalization, and production-ready features

This release focuses on making the library production-ready with comprehensive security features, full internationalization support (English + French), enhanced session management, and audit logging capabilities.

#### Internationalization (i18n) ⭐
* **NEW LanguageProvider** - Language state management
  * Support for English and French locales
  * Persistent language preferences with SharedPreferences
  * Reactive updates via ChangeNotifier
  * Easy language switching API
  * System locale detection
* **NEW Language Switcher Widgets** - 5 variants for language selection
  * LanguageToggleButton - Quick toggle icon button
  * LanguageDropdown - Dropdown selector with flags
  * LanguageSelector - Segmented button style
  * LanguageSettingsTile - Settings tile with selector
  * LanguageCustomizationCard - Complete customization UI
* **Comprehensive Translations**
  * 100+ translated strings in ARB format
  * Authentication and authorization strings
  * Common UI actions (save, cancel, delete, etc.)
  * CRUD operations
  * Table and list operations
  * Export/import operations
  * Batch operations
  * Validation messages
  * Settings and configuration
  * File upload
* **flutter_localizations** integration
  * Full Material localization support
  * Date/time formatting per locale
  * Number formatting per locale

#### Enhanced Security ⭐
* **NEW SecurityUtils** - Account lockout and security management
  * Track failed login attempts per user
  * Automatic account lockout after 5 failed attempts
  * 15-minute lockout duration (configurable)
  * Automatic unlock after timeout
  * Get remaining lockout time and attempts
* **NEW PasswordResetUtils** - Password reset flow
  * Generate time-limited reset tokens (1-hour validity)
  * Token verification with expiration
  * Secure token storage
  * Clear reset tokens after use or expiration
* **NEW RememberMeUtils** - Remember me functionality
  * Persistent email storage for quick login
  * Enable/disable remember me preference
  * Clear remembered data on logout
  * Secure preference storage
* **Existing bcrypt integration** (from v0.1.1)
  * Already using production-ready password hashing
  * BCrypt.hashpw() for secure password storage
  * BCrypt.checkpw() for secure password verification

#### Audit Logging ⭐
* **NEW AuditLogger** - Comprehensive audit trail
  * Log user actions with timestamps
  * Track login/logout events
  * Record CRUD operations
  * Monitor data exports
  * Store up to 1,000 most recent logs
  * Filter logs by user, action, date range
  * Predefined action constants
  * Get logs count and statistics
  * Clear audit logs
* **Audit Action Types**
  * LOGIN, LOGOUT
  * CREATE, UPDATE, DELETE, VIEW
  * EXPORT, PASSWORD_RESET
  * ACCOUNT_LOCKED

#### Session Management Enhancements
* **Existing Features** (from v0.2.0):
  * Session timeout monitoring (every minute)
  * Configurable timeout duration
  * Automatic logout on timeout
  * Activity tracking with timestamps
  * Session persistence
  * Last activity time tracking
* **Ready for Integration**:
  * Account lockout can be integrated with AuthProvider
  * Remember me can be integrated with login flow
  * Password reset utilities ready for UI implementation
  * Audit logging ready for integration across all operations

#### Developer Experience
* All new utilities and providers exported
* Comprehensive inline documentation
* Ready-to-use security utilities
* Easy integration with existing authentication
* Type-safe localization with ARB format
* Multiple language switcher variants for different UX needs

#### New Dependencies
* `flutter_localizations` - Flutter localization support (SDK)
* Uses existing `intl: ^0.19.0` for internationalization
* Uses existing `shared_preferences: ^2.2.2` for persistence

#### Usage Examples

**Internationalization Setup:**
```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          locale: languageProvider.locale,
          supportedLocales: LanguageProvider.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomePage(),
        );
      },
    );
  }
}
```

**Language Switching:**
```dart
// In AppBar
AppBar(
  actions: [
    LanguageToggleButton(),
  ],
)

// In Settings page
LanguageSettingsTile(
  title: 'Language',
  subtitle: 'Choose your preferred language',
)

// Programmatic switching
final languageProvider = Provider.of<LanguageProvider>(context);
await languageProvider.setLocale(Locale('fr')); // Switch to French
await languageProvider.toggleLanguage(); // Toggle between EN/FR
```

**Account Lockout:**
```dart
// In login flow
final email = emailController.text;

// Check if account is locked
if (await SecurityUtils.isAccountLocked(email)) {
  final minutes = await SecurityUtils.getRemainingLockoutMinutes(email);
  showError('Account locked. Try again in $minutes minutes.');
  return;
}

// Attempt login
final success = await authProvider.login(email, password);

if (success) {
  // Reset failed attempts on successful login
  await SecurityUtils.resetFailedAttempts(email);
} else {
  // Record failed attempt
  await SecurityUtils.recordFailedAttempt(email);

  final remaining = await SecurityUtils.getRemainingAttempts(email);
  if (remaining > 0) {
    showError('Invalid credentials. $remaining attempts remaining.');
  }
}
```

**Password Reset:**
```dart
// Request reset
final token = await PasswordResetUtils.generateResetToken(email);
// Send token to user via email (not implemented in this version)

// Verify and reset
if (await PasswordResetUtils.verifyResetToken(email, token)) {
  // Update password in Grist
  final hashedPassword = GristService.hashPassword(newPassword);
  // ... update record ...

  await PasswordResetUtils.clearResetToken(email);
  showSuccess('Password reset successfully');
}
```

**Remember Me:**
```dart
// On login
final rememberMe = rememberMeCheckbox.value;
await RememberMeUtils.setRememberMe(rememberMe, email: email);

// On app start
final remembered = await RememberMeUtils.getRememberedEmail();
if (remembered != null) {
  emailController.text = remembered;
}
```

**Audit Logging:**
```dart
// Log user actions
await AuditLogger.log(
  userId: user.email,
  action: AuditLogger.actionLogin,
  resource: 'auth',
  details: 'User logged in successfully',
);

await AuditLogger.log(
  userId: user.email,
  action: AuditLogger.actionDelete,
  resource: 'orders/$recordId',
  details: 'Deleted order',
  metadata: {'orderId': recordId, 'timestamp': DateTime.now().toIso8601String()},
);

// Get audit logs
final logs = await AuditLogger.getLogs(
  userId: user.email,
  action: AuditLogger.actionLogin,
  startDate: DateTime.now().subtract(Duration(days: 7)),
);

final logsCount = await AuditLogger.getLogsCount();
```

#### Breaking Changes
* None - All changes are additive and backward compatible
* Existing authentication and session management continues to work
* New features opt-in and don't affect existing functionality

#### Bug Fixes
* Improved session timeout reliability
* Better error handling in security utilities

#### Notes
* This release provides the infrastructure for production-ready apps
* Password reset UI components not included (utilities only)
* Account lockout requires integration with existing AuthProvider
* Audit logging requires integration across UI components
* All French translations professionally done
* Security utilities are production-ready and tested

---

## 0.9.0

### Major Feature Release - Advanced Input Fields & Batch Operations

#### 🎯 Theme: Rich content editing and powerful bulk data management

This release introduces advanced input field widgets for rich content creation (WYSIWYG editor, color picker, rating system) and a comprehensive batch operations system for selecting and performing bulk actions on table records.

#### Rich Text Editor ⭐
* **NEW RichTextFieldWidget** - WYSIWYG text editor
  * Full rich text editing with flutter_quill
  * Text formatting (bold, italic, underline, strikethrough)
  * Text alignment (left, center, right, justify)
  * Lists (bullet points, numbered lists)
  * Headers (H1, H2, H3)
  * Block quotes and code blocks
  * Links and text colors
  * Undo/redo support
  * Customizable toolbar
  * Stores content as JSON (Quill Delta format)
  * Plain text fallback support
  * Configurable min/max height
  * Toolbar positioning (top/bottom)
* **NEW CompactRichTextFieldWidget** - Compact editor variant
* **NEW RichTextViewer** - Read-only rich text display
* Rich text field support in FieldTypeBuilder (types: rich_text, richtext, html)

#### Color Picker ⭐
* **NEW ColorPickerFieldWidget** - Professional color selection
  * Multiple picker types:
    - Material color picker
    - Block color picker
    - HSV color picker
    - RGB sliders
  * Hex color input with validation
  * Alpha channel support (opacity)
  * Color preview display
  * RGB value display
  * Predefined color swatches
  * Recently used colors tracking (last 12)
  * Custom color swatches support
  * Stores as hex color strings (#RRGGBB or #AARRGGBB)
* **NEW CompactColorPickerWidget** - Compact display variant
* **NEW ColorSwatches** - Predefined color palettes
  * Material colors (19 colors)
  * Basic colors (11 colors)
  * Pastel colors (8 colors)
* Color field support in FieldTypeBuilder (types: color, color_picker)

#### Rating System ⭐
* **NEW RatingFieldWidget** - Interactive star ratings
  * Customizable rating icons:
    - Star (default)
    - Heart
    - Thumb up
    - Circle
    - Square
  * Configurable rating range (default 0-5)
  * Half-star support
  * Custom colors for filled/unfilled icons
  * Rating value display (numeric)
  * Rating labels (optional text descriptions)
  * Glow effect on hover
  * Custom icon sizes
  * Read-only mode for display
* **NEW CompactRatingWidget** - Compact display variant
* **NEW RatingWithBarWidget** - Rating with percentage bar
* **NEW RatingLabels** - Predefined label sets
  * Satisfaction (Very Dissatisfied to Very Satisfied)
  * Quality (Poor to Excellent)
  * Agreement (Strongly Disagree to Strongly Agree)
  * Likelihood (Very Unlikely to Very Likely)
  * Difficulty (Very Easy to Very Hard)
* Rating field support in FieldTypeBuilder (types: rating, stars)

#### Batch Operations System ⭐
* **NEW BatchOperationsManager** - Selection state management
  * Select/deselect individual records
  * Select all/deselect all
  * Toggle selection
  * Track selected count
  * Check if all selected
  * Invert selection
  * Get selected records from list
  * ChangeNotifier for reactive updates
* **NEW BatchAction** - Action definition class
  * Action ID, label, and icon
  * Custom colors per action
  * Confirmation dialog support
  * Async execution handler
  * Enable/disable state
* **NEW BatchActions** - Predefined actions
  * Delete (with confirmation)
  * Export
  * Duplicate
  * Archive
  * Move To
  * Add Tag
  * Print
  * Share
* **NEW executeBatchOperation()** - Progress tracking
  * Execute operations on multiple records
  * Progress dialog display
  * Success/failure tracking
  * Error message collection
  * Result summary
* **NEW showBatchOperationResult()** - Result dialog

#### Batch Action Bar Widgets ⭐
* **NEW BatchActionBar** - Full-featured action bar
  * Selection count display with icon
  * Select all/deselect all button
  * Custom action buttons
  * Close button
  * Confirmation dialogs for destructive actions
  * Progress indication during execution
  * Customizable colors and elevation
  * Auto-hide when no selection
  * Animated appearance/disappearance
* **NEW CompactBatchActionBar** - Compact variant
  * Icon buttons only (no labels)
  * Minimal space usage
  * Rounded container design
* **NEW FloatingBatchActionBar** - Floating variant
  * Appears at bottom of screen
  * Material elevation effect
  * Full width with padding
* **NEW BatchSelectionCheckbox** - Row selection checkbox
  * Reactive to manager changes
  * Auto-updates on selection change
* **NEW BatchSelectAllCheckbox** - Header checkbox
  * Tristate support (all/none/some)
  * Select/deselect all functionality

#### Enhanced FieldTypeBuilder
* Added support for rich_text field type
* Added support for color field type
* Added support for rating field type
* Helper methods for type conversion:
  * _getColorPickerType() - Map string to ColorPickerType enum
  * _getRatingIcon() - Map string to RatingIcon enum

#### New Dependencies
* `flutter_quill: ^9.3.0` - Rich text editing
* `flutter_colorpicker: ^1.0.3` - Color picker widgets
* `flutter_rating_bar: ^4.0.1` - Rating widgets

#### Developer Experience
* All new widgets and utilities exported
* Comprehensive documentation
* Type-safe enums and configurations
* Reusable components for various use cases
* Reactive state management with ChangeNotifier
* Easy integration with existing forms and tables

#### Usage Examples

**Rich Text Field:**
```dart
RichTextFieldWidget(
  label: 'Description',
  value: existingJsonContent,
  onChanged: (jsonContent) {
    // Save JSON content
  },
  minHeight: 200,
  showToolbar: true,
  toolbarPosition: ToolbarPosition.top,
)
```

**Color Picker Field:**
```dart
ColorPickerFieldWidget(
  label: 'Brand Color',
  value: '#3ECF8E',
  onChanged: (hexColor) {
    // Save hex color
  },
  pickerType: ColorPickerType.material,
  showAlpha: false,
  colorSwatches: ColorSwatches.material,
)
```

**Rating Field:**
```dart
RatingFieldWidget(
  label: 'Customer Satisfaction',
  value: 4.5,
  onChanged: (rating) {
    // Save rating
  },
  maxRating: 5.0,
  allowHalfRating: true,
  icon: RatingIcon.star,
  ratingLabels: RatingLabels.satisfaction,
)
```

**Batch Operations (YAML):**
```yaml
table:
  batch_operations:
    enabled: true
    actions:
      - type: "delete"
        label: "Delete Selected"
        icon: "delete"
        color: "#EF4444"
        requires_confirmation: true
      - type: "export"
        label: "Export Selected"
        icon: "download"
```

**Batch Operations (Dart):**
```dart
final manager = BatchOperationsManager();
manager.setAllIds(records.map((r) => r['id'].toString()).toList());

BatchActionBar(
  manager: manager,
  actions: [
    BatchActions.delete(
      onDelete: (selectedIds) async {
        for (var id in selectedIds) {
          await gristService.deleteRecord('MyTable', id);
        }
      },
    ),
    BatchActions.export(
      onExport: (selectedIds) async {
        final selectedRecords = records
          .where((r) => selectedIds.contains(r['id'].toString()))
          .toList();
        await ExportUtils.exportToCSV(records: selectedRecords);
      },
    ),
  ],
)
```

#### Breaking Changes
* None - All changes are additive and backward compatible

#### Bug Fixes
* Improved color parsing for various hex formats
* Better null handling in rating widgets
* Proper disposal of Quill controllers

---

## 0.8.0

### Major Feature Release - Data Export & Advanced Table Operations

#### 🎯 Theme: Professional data export and enhanced table customization

This release introduces comprehensive data export capabilities with Excel and PDF support, custom column renderers for better data visualization, and powerful table customization options.

#### Excel Export (XLSX) ⭐
* **NEW ExcelExportUtils** - Professional Excel export capabilities
  * Full XLSX format support with formatting
  * Multi-sheet export support
  * Cell type preservation (numbers, dates, booleans)
  * Auto-sizing columns based on content
  * Freeze panes for header rows
  * Alternating row colors for readability
  * Custom styling (header colors, borders, bold text)
  * Configurable column widths
  * Summary rows with formulas (SUM, AVERAGE)
  * Export dialog with preview
* **NEW ExcelExportDialog** - User-friendly export configuration
  * File name customization
  * Column selection
  * Export options (headers, borders, alternating rows)
  * Export summary display

#### PDF Export ⭐
* **NEW PdfExportUtils** - Generate professional PDF reports
  * PDF generation with customizable layouts
  * Portrait and landscape orientations
  * Page numbers and timestamps
  * Custom headers and footers
  * Table formatting with borders
  * Auto page breaks for long tables
  * Print preview support
  * Professional styling
* **NEW PdfExportDialog** - PDF configuration interface
  * Document title customization
  * Page format selection (A4, Letter, Landscape)
  * Header/footer customization
  * Column selection
  * Print preview before export

#### Custom Column Renderers ⭐
* **NEW ColumnRenderer** - Base class for custom cell renderers
  * Abstract interface for custom visualizations
  * Export formatting support
* **NEW StatusBadgeRenderer** - Color-coded status badges
  * Configurable color mapping
  * Rounded or pill-shaped badges
  * Border styling
* **NEW ProgressBarRenderer** - Visual progress indicators
  * Min/max value configuration
  * Custom colors
  * Percentage text overlay
  * Configurable height
* **NEW CurrencyRenderer** - Formatted currency display
  * Custom currency symbols
  * Decimal place configuration
  * Thousand separators
  * Color coding for positive/negative values
* **NEW IconRenderer** - Icon-based value display
  * Value-to-icon mapping
  * Custom colors per value
  * Configurable icon size
* **NEW LinkRenderer** - Clickable URL links
  * URL truncation options
  * Custom display text
  * Underlined styling
* **NEW ChipRenderer** - Chip-style display
  * Custom colors
  * Optional delete icon
* **NEW RendererFactory** - Create renderers from YAML config

#### Column Customization ⭐
* **NEW ColumnChooserDialog** - Show/hide and reorder columns
  * Drag-and-drop column reordering
  * Show/hide column visibility
  * Save preferences per table
  * Reset to defaults
  * Select all/deselect all
  * Visual summary of selections
* **NEW ColumnChooserButton** - Quick access widget
* **NEW ColumnPreferences** - Persistent column settings
  * Save column order and visibility
  * Load saved preferences
  * Clear preferences

#### Enhanced Export System
* **Updated ExportUtils** - Now supports all three formats
  * CSV export (existing, enhanced)
  * Excel export (NEW)
  * PDF export (NEW)
* **Updated ExportDialog** - Multi-format selection
  * Format picker (CSV/Excel/PDF)
  * Format-specific options
  * Unified export interface

#### Developer Experience
* All export utilities exported for easy use
* Column renderer system fully extensible
* YAML configuration support for renderers
* Type-safe export options
* Comprehensive error handling

#### Usage Examples

**Excel Export:**
```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

await ExcelExportUtils.exportToExcel(
  records: records,
  columns: columns,
  fileName: 'my_data.xlsx',
  options: ExcelExportOptions(
    includeHeaders: true,
    autoSizeColumns: true,
    alternatingRows: true,
  ),
);
```

**PDF Export:**
```dart
await PdfExportUtils.exportToPdf(
  records: records,
  columns: columns,
  fileName: 'report.pdf',
  options: PdfExportOptions(
    title: 'Monthly Report',
    includePageNumbers: true,
    pageFormat: PdfPageFormat.a4,
  ),
);
```

**Custom Renderer (YAML):**
```yaml
columns:
  - name: "status"
    renderer:
      type: "status_badge"
      color_map:
        active: "#10B981"
        pending: "#F59E0B"
        inactive: "#6B7280"
      shape: "pill"
  - name: "progress"
    renderer:
      type: "progress_bar"
      min: 0
      max: 100
      color: "#3ECF8E"
      show_text: true
```

**Column Chooser:**
```dart
ColumnChooserButton(
  columns: tableColumns,
  tableId: 'my_table',
  onColumnsUpdated: (updatedColumns) {
    setState(() {
      columns = updatedColumns;
    });
  },
)
```

#### Breaking Changes
* None - All changes are additive and backward compatible
* Existing CSV export continues to work unchanged

#### Bug Fixes
* Improved export file naming consistency
* Better handling of null values in exports
* Fixed date formatting in all export formats

---

## 0.7.0

### Major Feature Release - Supabase-Inspired Dark Mode & Theme System

#### 🎯 Theme: Beautiful, modern dark theme with comprehensive theming support

This release introduces a complete theme system inspired by Supabase's elegant dark mode design, featuring deep blacks, sophisticated greys, and vibrant accent colors for a professional, modern look.

#### Dark Mode & Theme System ⭐
* **NEW AppTheme** - Supabase-inspired theme definitions
  * Deep black background (#0E1117) for main app surface
  * Elegant grey surfaces (#1A1A1A, #2A2A2A) for cards and elevated components
  * Vibrant accent colors (Supabase green #3ECF8E by default)
  * High-contrast text colors for optimal readability
  * Subtle borders and elevations for depth
  * Complete Material 3 component theming
  * Both dark and light theme variants
* **NEW ThemeProvider** - State management for themes
  * Theme mode switching (light/dark/system)
  * Custom accent color support
  * Persistent theme preferences using SharedPreferences
  * Reactive updates via ChangeNotifier
  * Easy integration with Provider pattern
* **NEW Theme Toggle Widgets**
  * ThemeToggleButton - Quick icon button toggle
  * ThemeModeSelector - Segmented button for light/dark/auto
  * ThemeModeSwitch - Clean switch widget
  * ThemeSettingsTile - Full settings tile with icon and selector
  * ThemeCustomizationCard - Complete theme customization UI
* **Enhanced ThemeUtils**
  * New createDarkTheme() and createLightTheme() methods
  * createThemes() for both themes at once
  * Backward compatible with existing configuration
  * Support for custom accent colors
  * Integration with new AppTheme system

#### Color Palette (Dark Mode)
* **Backgrounds**:
  * Deepest: #0E1117
  * Surface: #1A1A1A
  * Elevated: #2A2A2A
* **Borders**:
  * Standard: #2E2E2E
  * Subtle: #1F1F1F
* **Text**:
  * Primary: #F3F4F6 (high contrast)
  * Secondary: #9CA3AF (medium contrast)
  * Tertiary: #6B7280 (low contrast)
* **Accent**: #3ECF8E (Supabase green)
  * Hover: #4ADE94
  * Bright: #5AFF9F
* **Semantic Colors**:
  * Error: #EF4444
  * Warning: #F59E0B
  * Success: #10B981
  * Info: #3B82F6

#### Developer Experience
* All theme components exported for easy use
* Simple integration with MaterialApp
* Theme persistence across app restarts
* Multiple theme toggle widget options
* Customizable accent colors
* System theme detection support
* Type-safe theme access

#### Usage Examples

**Basic Setup:**
```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.getTheme(isDark: false),
          darkTheme: themeProvider.getTheme(isDark: true),
          themeMode: themeProvider.themeMode,
          home: HomePage(),
        );
      },
    );
  }
}
```

**Theme Toggle in AppBar:**
```dart
AppBar(
  title: Text('My App'),
  actions: [
    ThemeToggleButton(), // Simple icon button
  ],
)
```

**Theme Settings Page:**
```dart
ListView(
  children: [
    ThemeSettingsTile(
      title: 'Appearance',
      subtitle: 'Customize the app theme',
    ),
    // Or use the full customization card
    ThemeCustomizationCard(
      showAccentColorPicker: true,
    ),
  ],
)
```

**Custom Accent Color:**
```dart
final themeProvider = Provider.of<ThemeProvider>(context);
await themeProvider.setAccentColor(Colors.purple);
```

#### Breaking Changes
* None - All changes are additive and backward compatible
* Existing ThemeUtils.createTheme() continues to work

#### Bug Fixes
* Improved contrast ratios for accessibility
* Better text visibility on all backgrounds
* Consistent component styling across themes

---

## 0.6.0

### Major Feature Release - Multi-References, Responsive Design & Image Previews

#### 🎯 Theme: Enhanced UX with many-to-many relationships, responsive layouts, and rich media support

This release focuses on multi-reference fields for many-to-many relationships, responsive design for all screen sizes, and enhanced image preview capabilities with lightbox viewer.

#### Multi-Reference Fields (Many-to-Many) ⭐
* **NEW MultiReferenceFieldWidget** - Manage many-to-many relationships
  * Select multiple records from referenced tables
  * Chip-based display of selected items
  * Search and filter available records
  * Configurable maximum selections
  * Individual item removal
  * Works seamlessly with Grist RefList columns
* Multi-reference field support in FieldTypeBuilder
* Auto-detection from Grist RefList column types
* Integration with form widgets

#### Responsive Design System ⭐
* **NEW ResponsiveUtils** utility class
  * Breakpoint detection (mobile < 600px, tablet < 1024px, desktop >= 1024px)
  * Helper methods for responsive values
  * Responsive padding, spacing, and font sizes
  * Column count calculation for grids
* **NEW ResponsiveBuilder** widget
  * Build different layouts based on screen size
  * Access current breakpoint in builder
* **NEW ResponsiveLayout** widget
  * Show different widgets for mobile/tablet/desktop
  * Automatic fallback to smaller breakpoints
* **NEW ResponsiveGrid** widget
  * Adaptive column count
  * Configurable for each breakpoint
* **NEW ResponsiveFormField** widget
  * Width adaptation based on screen size

#### Image Preview & Lightbox ⭐
* **NEW ImagePreviewWidget** - Rich image display
  * Thumbnail preview with configurable size
  * Click to open lightbox viewer
  * Support for URLs and data URLs (base64)
  * Loading states and error handling
  * Customizable border radius and fit
* **NEW ImageLightbox** - Full-screen image viewer
  * Pinch to zoom (0.5x - 4x)
  * Drag to pan
  * Interactive viewer controls
  * Close button and instructions
  * Black background for focus
* **Enhanced FileUploadWidget**
  * Integrated ImagePreviewWidget for thumbnails
  * Lightbox view on click
  * Better image display
* **NEW ImageGalleryWidget**
  * Display multiple images in grid
  * Individual lightbox for each image

#### Developer Experience
* MultiReferenceFieldWidget, ImagePreviewWidget, and ResponsiveUtils exported
* Comprehensive responsive design utilities
* Reusable image components
* Better UX for image-heavy applications
* Type-safe breakpoint handling

#### Breaking Changes
* None - All changes are additive and backward compatible

#### Bug Fixes
* Improved image memory handling in FileUploadWidget
* Better null safety in multi-reference fields

#### YAML Configuration Additions
```yaml
grist:
  form:
    fields:
      # Multi-reference field configuration (many-to-many)
      - name: "team_member_ids"
        type: "multi_reference"
        label: "Team Members"
        reference_table: "Users"
        display_fields: ["name", "department"]
        value_field: "id"
        display_separator: " - "
        max_selections: 5  # Optional limit
```

---

## 0.5.0

### Major Feature Release - Data Relationships & Scale

#### 🎯 Theme: Handle complex data relationships and large datasets efficiently

This release focuses on enabling apps that work with relational data and scale beyond 1,000 records with advanced filtering, search, and export capabilities.

#### Reference Fields (Foreign Keys) ⭐
* **NEW ReferenceFieldWidget** - Autocomplete for related records
  * Fetch and display records from referenced tables
  * Search across related records with autocomplete
  * Display formatted labels from multiple fields (e.g., "John Doe - john@example.com")
  * Support single references (BelongsTo relationships)
  * Configurable display fields and separators
  * Clear button to reset selection
  * Auto-detection from Grist Ref column types
* Reference field support in FieldTypeBuilder
* Auto-extraction of reference table metadata from Grist
* Integration with form widgets and GristFormWidget

#### Server-Side Search & Filtering
* **Enhanced GristService.fetchRecords()** with server-side capabilities
  * Optional `filter` parameter for Grist filter formulas
  * Optional `limit` parameter for pagination
  * Optional `offset` parameter for pagination
  * Optional `sort` parameter for server-side sorting
  * Supports large datasets (10,000+ records)
* Reduced memory usage for large tables
* Better performance with server-side operations

#### Column Filtering UI ⭐
* **NEW ColumnFilter system** with visual filtering interface
  * Filter icon on each column header
  * Click to open filter dialog
  * Type-specific filter operators:
    - Text: contains, equals, starts with, ends with
    - Numeric: =, ≠, >, <, ≥, ≤, between
    - Date: =, >, <, between (with date picker)
    - Boolean: is true, is false, is empty
    * Choice: in list (with multi-select)
  * Active filter chips display below toolbar
  * Individual filter removal (click X on chip)
  * "Clear All" button to remove all filters
  * Filter count indicator in column headers
  * Client-side filtering with efficient matching
  * Works seamlessly with sorting and pagination

#### CSV Export Functionality ⭐
* **NEW ExportUtils** for data export
  * Export table data to CSV format
  * Configurable export dialog with:
    - Custom file name input
    - Column selection (choose which columns to export)
    - Select/Deselect all columns
    - Include/exclude headers option
    - Export summary (record count, column count, format)
  * Type-aware value formatting for export
  * Proper handling of dates, booleans, files, and special characters
  * Save to device storage with path_provider
  * Future-ready for Excel and PDF export

#### New Dependencies
* `csv: ^6.0.0` - CSV file generation
* `path_provider: ^2.1.1` - File system access for exports

#### Developer Experience
* ReferenceFieldWidget, ColumnFilter, and ExportUtils exported
* Comprehensive documentation for new features
* Type-safe filter operators enum
* Reusable filter dialog component
* Enhanced GristService API with backward compatibility
* Better error handling for reference fields

#### Breaking Changes
* GristService.fetchRecords() now accepts optional named parameters (backward compatible)
* GristTableWidget now manages filter state internally
* Column headers now include filter icons (may affect layout slightly)

#### Bug Fixes
* Proper null handling in column filters
* Date parsing improvements in filter matching
* Memory-efficient filtering for large datasets

#### YAML Configuration Additions
```yaml
grist:
  # Enable server-side search (recommended for large datasets)
  use_server_side_search: true

  form:
    fields:
      # Reference field configuration
      - name: "manager_id"
        type: "reference"
        label: "Manager"
        reference_table: "Users"
        display_fields: ["name", "email"]
        value_field: "id"
        display_separator: " - "
        show_clear_button: true
```

---

## 0.3.0

### Major Feature Release - File Uploads, Pagination & Enhanced Tables

#### File Upload with Drag & Drop
* **NEW FileUploadWidget** with drag & drop support
  * Visual drag & drop zone with hover effects
  * Click to browse file picker integration
  * Image preview for uploaded files
  * File size validation and limits
  * File type restrictions (allowed extensions)
  * File info display (name, size, type)
  * Base64 encoding for storage
  * Data URL generation for images
  * Comprehensive file icon set based on MIME type
* File field type support in forms
* Integration with file_picker and image_picker packages

#### Create New Record Page
* **NEW DataCreatePage** for adding records
  * Form-based record creation
  * Support for all field types (text, numeric, date, file)
  * Date picker integration
  * File upload support
  * Field validation enforcement
  * Cancel/Create actions
  * Success/error feedback
  * Auto-navigation after creation

#### Column Sorting
* Click column headers to sort ascending/descending
* Sort indicator (arrow) on active column
* Multi-type sort support:
  * Numeric sorting for numbers
  * Date sorting for dates
  * Alphabetical for text
* Configurable sortable columns
* Null value handling in sorts
* Sort state persistence during filtering

#### Pagination
* Configurable rows per page
* Page navigation controls (First, Previous, Next, Last)
* Page indicator (Page X of Y)
* Automatic page reset on sorting
* Works seamlessly with search/filter
* YAML-configurable via `rows_per_page`

#### Enhanced Date Handling
* Date picker widget for date fields
* Improved date formatting with intl package
  * yyyy-MM-dd format for dates
  * yyyy-MM-dd HH:mm for datetime
* Parse and display date values correctly
* Date field type in create/edit forms

#### Image Preview in Tables
* Automatic image detection in table cells
* Thumbnail preview for image files
* Support for data URLs (base64 images)
* Support for image URLs (.jpg, .png, .gif)
* Fallback to filename if image fails to load
* 40px height constraint for table rows

#### Enhanced Value Formatting
* File/image fields show "📎 Attached" for data URLs
* Filename extraction from URLs
* Better date/datetime formatting
* Currency formatting maintained
* Boolean checkmark symbols

#### New Dependencies
* `file_picker: ^6.1.1` - Cross-platform file picking
* `image_picker: ^1.0.7` - Image selection
* `mime: ^1.0.5` - MIME type detection
* `intl: ^0.19.0` - Internationalization and date formatting

#### Breaking Changes
* GristTableWidget converted from StatelessWidget to StatefulWidget
* TableColumnConfig added `sortable` property (defaults to true)
* Data table now requires more vertical space for pagination controls
* File fields store as data URLs or file URLs (not file paths)

#### Developer Experience
* FileUploadWidget and FileUploadResult exported
* DataCreatePage exported for custom implementations
* Better type detection for keyboard types
* Comprehensive error handling in file operations
* Memory-efficient image handling

#### Bug Fixes
* Proper image memory widget usage
* Safe type casting in column sorting
* Null-safe date parsing
* Proper scroll behavior with pagination

#### YAML Configuration Additions
```yaml
grist:
  rows_per_page: 20  # Enable pagination
  enable_sorting: true  # Enable column sorting

  form:
    fields:
      - name: "profile_picture"
        type: "file"
        allowed_extensions: ["jpg", "png", "gif"]
        max_file_size: 5242880  # 5MB
      - name: "birth_date"
        type: "date"
```

---

## 0.2.0

### Major Feature Release - Full CRUD Operations

#### CRUD Operations (Create, Read, Update, Delete)
* **Create**: New `createRecord()` method in GristService returns created record ID
* **Update**: Enhanced `updateRecord()` method (already existed)
* **Delete**: New `deleteRecord()` method with confirmation dialog
* Full CRUD functionality in data detail pages

#### Data Table Widget
* Complete rewrite of GristTableWidget
* Proper DataTable implementation with scrollable rows and columns
* Column configuration support (name, label, type, visibility, width)
* Type-based value formatting (boolean, currency, date, numeric)
* Empty state and error state handling
* Row tap callbacks for navigation

#### Search and Filtering
* Real-time search across all record fields
* Search bar with clear button
* Record count display showing filtered results
* Configurable search placeholder text

#### Data Master Page Enhancements
* Replaced ListTile view with proper DataTable
* Integrated search and filter functionality
* "Create New" button for adding records
* Pull-to-refresh support maintained
* Show/hide ID column option

#### Data Detail Page Enhancements
* View/Edit mode toggle
* Inline form editing with validation
* Edit and Delete buttons
* Save/Cancel actions when editing
* Form validation using FieldValidators
* Proper keyboard types based on field type (email, number, URL, text)
* Read-only field support
* Success/error feedback with SnackBars

#### Session Timeout Enforcement
* Automatic session timeout monitoring
* Configurable timeout duration (from YAML)
* Auto-logout on timeout
* Activity tracking with timestamp persistence
* Session expiry message on timeout
* Timer-based monitoring every minute
* recordActivity() method for manual activity tracking

#### Developer Experience
* Exported TableColumnConfig in main library
* Better keyboard type detection for form fields
* Improved error handling with user feedback
* Proper controller disposal in stateful widgets

#### Breaking Changes
* Data master pages now use DataTable instead of ListView
* Page configuration structure expanded to support new features
* Auth provider logout() now accepts optional `timedOut` parameter

#### Bug Fixes
* Fixed controller disposal in data detail page
* Proper state management for edit mode
* Better null safety in form initialization

---

## 0.1.1

### Critical Security Fixes and Improvements

#### Security Fixes
* **CRITICAL**: Replace SHA256 password hashing with bcrypt
* Passwords now use bcrypt with proper salt generation
* Added static `GristService.hashPassword()` helper
* Production-ready password security

#### Performance Improvements
* Fix inefficient record fetching (now uses direct API endpoint)
* Significantly improved performance with large datasets
* Proper 404 handling for missing records

#### Code Quality
* Remove duplicate grist_api_service.dart file
* Eliminate code duplication and maintenance burden

#### New Features
* Comprehensive field validation system
* New FieldValidator and FieldValidators classes
* Support for: required, range, regex, email, min_length, max_length
* YAML-driven validator configuration
* Flutter-compatible form validators

#### Testing
* Complete test suite for validators (46 tests)
* Complete test suite for expression evaluator (24 tests)
* Basic tests for password hashing (7 tests)
* Total: 77 unit tests

#### Dependencies
* Add bcrypt ^1.1.3 for secure password hashing

#### Breaking Changes
* Password hashing changed from SHA256 to bcrypt
* Existing password hashes must be regenerated

---

## 0.1.0

### Initial Release - YAML-Driven App Generator

#### Core Architecture
* Complete YAML configuration parser
* Configuration models for all YAML sections
* Main GristApp widget with multi-provider setup
* Theme utilities for YAML-to-Flutter theme conversion

#### Authentication & Security
* User authentication against Grist users table
* Login page with email/password
* Session management with SharedPreferences
* Role-based access control
* Logout with confirmation dialog

#### Navigation
* Permanent left drawer navigation
* Dynamic menu generation from YAML config
* User profile display in drawer footer
* Conditional visibility based on user roles

#### Page Types
* **Front Page**: Static content with text and images
* **Data Master**: List view of Grist table data with pull-to-refresh
* **Data Detail**: Read-only form view of individual records
* **Admin Dashboard**: System info and database statistics

#### Grist Integration
* Grist API service with authentication
* Fetch records, tables, and columns
* Read-only data display
* Auto-detection of table schemas

#### Expression Engine
* Conditional visibility evaluator
* Support for comparison operators (==, !=, <, >, etc.)
* Support for logical operators (AND, OR)
* User context evaluation (user.role, user.email, etc.)

#### Known Limitations
* Read-only data views (no editing yet)
* Basic table display using ListTiles (not full DataTable)
* Field validators defined but not yet enforced
* SHA256 password hashing (not production-ready)
