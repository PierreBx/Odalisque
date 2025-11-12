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
