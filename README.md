# flutter_grist_widgets

A Flutter library for building complete data-driven applications from Grist using YAML configuration.

## Overview

`flutter_grist_widgets` is a **declarative app generator** that creates full-featured Flutter applications from a simple YAML configuration file. Connect your Grist database and define your app structure in YAML - the library handles everything else.

**Key Concept**: Instead of writing code, you write a YAML file that describes your app's structure, pages, navigation, and data connections. The library automatically generates a complete Flutter application with authentication, navigation, data tables, forms, and admin features.

## Features

### Core Capabilities
- 📄 **YAML-Driven** - Define your entire app in a declarative YAML file
- 🔐 **Built-in Authentication** - Multi-user support with role-based access control
- 🗄️ **Auto-Schema Detection** - Automatically discovers table structures from Grist
- 📊 **Multiple View Types** - Tabular lists, detail forms, static pages, admin dashboard
- 🎨 **Themeable** - Customize colors and branding via YAML
- 🔍 **Search & Filter** - Built-in search and filtering for data tables
- ✅ **Validation** - Rich field validation (required, email, regex, ranges, etc.)
- 👁️ **Conditional Visibility** - Show/hide fields based on user roles or data

### Page Types
- **Front Pages** - Static content pages with text and images
- **Data Master** - Tabular view of Grist tables with search, sort, pagination
- **Data Detail** - Form view for individual records
- **Admin Dashboard** - Monitor active users, database stats, system info

### Smart Features
- Auto-generated record numbers (independent of Grist ID)
- Master-detail navigation with back button
- Permanent left drawer navigation
- User profile display and logout
- Loading states and error handling
- Expression-based visibility rules

## Getting Started

### 📚 Quick Navigation

- **🚀 [QUICKSTART.md](QUICKSTART.md)** - First time setup guide (Docker + Grist)
- **📅 [DAILY_USAGE.md](DAILY_USAGE.md)** - Daily development workflow
- **🐳 [README_DOCKER.md](README_DOCKER.md)** - Detailed Docker documentation

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_grist_widgets: ^0.1.0
```

### Quick Start

1. **Create a YAML configuration file** (`app_config.yaml`):

```yaml
app:
  name: "My Business App"
  version: "1.0.0"

grist:
  base_url: "https://docs.getgrist.com"
  api_key: "your_api_key"
  document_id: "your_document_id"

auth:
  users_table: "Users"

pages:
  - id: "products_master"
    type: "data_master"
    title: "Products"
    menu:
      label: "Products"
      icon: "inventory"
    grist:
      table: "Products"
      record_number:
        enabled: true
      columns:
        - name: "name"
          label: "Product Name"
          visible: true
      on_row_click:
        navigate_to: "products_detail"
        pass_param: "id"
```

2. **Generate your app**:

```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  runApp(
    GristApp.fromYaml('assets/app_config.yaml'),
  );
}
```

That's it! The library generates a complete app with authentication, navigation, and data views.

## Documentation

- **[YAML Schema Reference](YAML_SCHEMA.md)** - Complete documentation of all YAML options
- **[Example Configuration](example/app_config.yaml)** - Full working example with all features
- **[Typst Documentation](documentation.typ)** - Printable documentation (compile with `typst compile documentation.typ`)

## YAML Configuration Structure

```yaml
app:              # Application settings, error handling, loading states
grist:            # Grist connection details
auth:             # Authentication and user management
theme:            # Colors and styling
navigation:       # Drawer menu configuration
pages:            # Array of page definitions
  - type: front              # Static content page
  - type: data_master        # Tabular data view
  - type: data_detail        # Form detail view
  - type: admin_dashboard    # Admin monitoring page
```

See [YAML_SCHEMA.md](YAML_SCHEMA.md) for complete details.

## Example Features

### Conditional Visibility
```yaml
fields:
  - name: "salary"
    visible_if: "user.role == 'admin' OR user.role == 'hr'"
```

### Field Validation
```yaml
fields:
  - name: "email"
    validators:
      - type: "required"
      - type: "email"
      - type: "regex"
        pattern: "^[a-z0-9._%+-]+@company\\.com$"
        message: "Must be a company email"
```

### Admin Dashboard
```yaml
- id: "admin"
  type: "admin_dashboard"
  visible_if: "user.role == 'admin'"
  widgets:
    - type: "active_users"
    - type: "database_summary"
      grist_tables: ["Products", "Customers"]
```

## Requirements

### Grist Setup
Your Grist document must include a **Users table** with these columns:
- `email` (Text) - User login email
- `password_hash` (Text) - Hashed password
- `role` (Text) - User role (admin, manager, user, etc.)
- `active` (Toggle) - Whether user can log in

## Roadmap

**Current Version (v0.1.0)**: Read-only data views

**Planned Features**:
- Editable forms (create, update, delete records)
- Custom action buttons
- Pull-to-refresh
- Offline support
- Export functionality (PDF, CSV)
- Custom validators as functions
- Audit logging

## Project Status

This library is currently in active development (v0.1.0). The YAML schema is being finalized and implementation is in progress.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
