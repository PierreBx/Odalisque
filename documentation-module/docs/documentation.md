)

  Version 0.1.0
]

# Overview

`flutter_grist_widgets` is a *declarative app generator* that creates full-featured Flutter applications from a simple YAML configuration file. Instead of writing code, you define your app's structure, pages, navigation, and data connections in YAML -- the library handles everything else.

## Key Concept

Connect your Grist database, write a YAML file describing your app, and the library automatically generates a complete Flutter application with:

- *Authentication* -- Multi-user login with role-based access control
- *Navigation* -- Permanent left drawer menu
- *Data Views* -- Tabular lists and detail forms
- *Admin Features* -- User monitoring and database statistics
- *Smart Features* -- Search, filter, validation, conditional visibility

# Features

## Core Capabilities

  columns: (auto, 1fr),
  row-gutter: 1em,
  column-gutter: 1em,

  [📄], [*YAML-Driven* -- Define your entire app in a declarative YAML file],
  [🔐], [*Built-in Authentication* -- Multi-user support with role-based access control],
  [🗄️], [*Auto-Schema Detection* -- Automatically discovers table structures from Grist],
  [📊], [*Multiple View Types* -- Tabular lists, detail forms, static pages, admin dashboard],
  [🎨], [*Themeable* -- Customize colors and branding via YAML],
  [🔍], [*Search & Filter* -- Built-in search and filtering for data tables],
  [✅], [*Validation* -- Rich field validation (required, email, regex, ranges, etc.)],
  [👁️], [*Conditional Visibility* -- Show/hide fields based on user roles or data],
)

## Page Types

- *Front Pages* -- Static content pages with text and images
- *Data Master* -- Tabular view of Grist tables with search, sort, pagination
- *Data Detail* -- Form view for individual records
- *Admin Dashboard* -- Monitor active users, database stats, system info

## Smart Features

- Auto-generated record numbers (independent of Grist ID)
- Master-detail navigation with back button
- Permanent left drawer navigation
- User profile display and logout
- Loading states and error handling
- Expression-based visibility rules

# Getting Started

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_grist_widgets: ^0.1.0
```

## Quick Start

### Step 1: Create a YAML Configuration File

Create `assets/app_config.yaml`:

```yaml
app:
  name: "My Business App"

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

### Step 2: Generate Your App

```dart
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  runApp(
    GristApp.fromYaml('assets/app_config.yaml'),
  );
}
```

That's it! The library generates a complete app with authentication, navigation, and data views.

# Architecture

## YAML Configuration Structure

The complete app is defined in a single YAML file with the following top-level sections:

```yaml
app:              # Application settings, error handling, loading states
grist:            # Grist connection details
auth:             # Authentication and user management
theme:            # Colors and styling
navigation:       # Drawer menu configuration
pages:            # Array of page definitions
```

## Page Types

### Front Page (Static Content)

Static pages with text and images, useful for welcome screens or information pages.

```yaml
- id: "home"
  type: "front"
  title: "Home"
  menu:
    label: "Home"
    icon: "home"
  content:
    text: "Welcome to the app"
    image: "assets/welcome.png"
```

### Data Master Page (Tabular View)

Displays Grist table data in a sortable, searchable table format.

```yaml
- id: "products_master"
  type: "data_master"
  grist:
    table: "Products"
    record_number:
      enabled: true
      column_label: "N"
    columns:
      - name: "name"
        sortable: true
        searchable: true
    on_row_click:
      navigate_to: "products_detail"
```

### Data Detail Page (Form View)

Displays a single record as a form with validation and conditional fields.

```yaml
- id: "products_detail"
  type: "data_detail"
  grist:
    table: "Products"
    form:
      fields:
        - name: "price"
          type: "numeric"
          validators:
            - type: "required"
            - type: "range"
              min: 0
```

### Admin Dashboard

Monitoring page for administrators showing system statistics.

```yaml
- id: "admin"
  type: "admin_dashboard"
  visible_if: "user.role == 'admin'"
  widgets:
    - type: "active_users"
    - type: "database_summary"
```

## Core Components

The library automatically generates:

- *Authentication System* -- Login page, session management, role-based access
- *Navigation* -- Left drawer menu with user profile and logout
- *Page Router* -- Navigation between pages with parameter passing
- *Data Layer* -- Automatic Grist API integration
- *Validation Engine* -- Field validation with custom rules
- *Expression Evaluator* -- For conditional visibility rules

# Example Features

## Conditional Visibility

Show/hide fields based on user roles or other conditions:

```yaml
fields:
  - name: "salary"
    visible_if: "user.role == 'admin' OR user.role == 'hr'"
```

## Field Validation

Rich validation with multiple rules:

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

## Record Number Column

Auto-generated sequential numbers independent of Grist ID:

```yaml
record_number:
  enabled: true
  column_label: "N"
  sortable: true
  keep_original_after_filter: true
```

# Requirements

## Grist Setup

Your Grist document must include a *Users table* with these columns:

| Column | Type | Description |
| --- | --- | --- |
| email | Text | User login email |
| password_hash | Text | Hashed password |
| role | Text | User role (admin, manager, user) |
| active | Toggle | Whether user can log in |

# Documentation

For complete details, see:

- *YAML_SCHEMA.md* -- Complete reference of all YAML configuration options
- *example/app_config.yaml* -- Full working example with all features
- *README.md* -- Quick start guide and overview

# Roadmap

*Current Version (v0.1.0):* Read-only data views

*Planned Features:*
- Editable forms (create, update, delete records)
- Custom action buttons
- Pull-to-refresh
- Offline support
- Export functionality (PDF, CSV)
- Custom validators as functions
- Audit logging

# Project Status

  fill: rgb("#fff3cd"),
  inset: 1em,
  radius: 4pt,
  width: 100%,
)[
  *Note:* This library is currently in active development (v0.1.0). The YAML schema is being finalized and implementation is in progress.
]

# Contributing

Contributions are welcome! Please feel free to submit issues or pull requests to help improve this library.

# License

This project is licensed under the MIT License. See the LICENSE file for details.

]
