# Quick Start

This guide will help you create your first FlutterGristAPI application in 15 minutes.

## Prerequisites Checklist

Before starting, ensure you have:

- ✅ Access to a Grist instance (self-hosted or docs.getgrist.com)
- ✅ A Grist document with at least a Users table
- ✅ Grist API key (from Profile Settings → API)
- ✅ Document ID (from the URL: `https://docs.getgrist.com/doc/YOUR_DOC_ID`)
- ✅ Text editor (VS Code, Sublime, etc.)

## Step 1: Set Up Grist Users Table

Your Grist document MUST have a Users table for authentication:

| Column Name | Type | Example Value |
| --- | --- | --- |
| email | Text | admin@example.com |
| password_hash | Text | $2a$10$N9qo8...` (bcrypt hash) |
| role | Text | admin |
| active | Toggle | ✓ (checked) |

> **Note**: *Test User Password Hash:* For testing, use this pre-hashed password for "password123":
>
> `$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy`
>
> Test credentials: `admin@example.com` / `password123`

## Step 2: Create Basic YAML Configuration

Create a file named `app_config.yaml`:

```yaml
app:
  name: "My First App"
  version: "1.0.0"

grist:
  base_url: "https://docs.getgrist.com"  # Or your Grist URL
  api_key: "${GRIST_API_KEY}"            # Use environment variable
  document_id: "YOUR_DOCUMENT_ID"        # Replace with your doc ID

auth:
  users_table: "Users"

theme:
  primary_color: "#2196F3"
  secondary_color: "#FFC107"

navigation:
  drawer_header:
    title: "My App"
    subtitle: "Powered by FlutterGristAPI"

pages:
  - id: "home"
    type: "front"
    title: "Welcome"
    menu:
      label: "Home"
      icon: "home"
      order: 1
    content:
      text: "Welcome to My First App!"
      alignment: "center"
```

> **Warning**: *Security:* Never hardcode API keys in YAML files! Use environment variables:
>
> ```bash
> export GRIST_API_KEY="your_api_key_here"
> ```

## Step 3: Add a Data Master Page

Let's add a page that displays data from a Grist table. First, create a sample table in Grist called "Products" with these columns:

- `id` (Integer)
- `name` (Text)
- `price` (Numeric)
- `in_stock` (Toggle)

Then add this to your `pages` section in the YAML:

```yaml
  - id: "products_master"
    type: "data_master"
    title: "Products"
    menu:
      label: "Products"
      icon: "inventory"
      order: 2
    grist:
      table: "Products"

      columns:
        - name: "id"
          label: "ID"
          visible: true
          sortable: true
          width: 80

        - name: "name"
          label: "Product Name"
          visible: true
          sortable: true
          searchable: true

        - name: "price"
          label: "Price"
          visible: true
          sortable: true

        - name: "in_stock"
          label: "In Stock"
          visible: true

      enable_search: true
      pagination:
        enabled: true
        page_size: 20

      on_row_click:
        navigate_to: "products_detail"
        pass_param: "id"
```

## Step 4: Add a Data Detail Page

Add a form view for individual product details:

```yaml
  - id: "products_detail"
    type: "data_detail"
    title: "Product Details"
    menu:
      visible: false  # Don't show in menu, accessed via row click

    grist:
      table: "Products"
      record_id_param: "id"

      form:
        layout: "single_column"

        fields:
          - name: "id"
            label: "Product ID"
            type: "integer"
            readonly: true

          - name: "name"
            label: "Product Name"
            type: "text"
            readonly: true
            validators:
              - type: "required"
                message: "Product name is required"
              - type: "minLength"
                value: 3
                message: "Name must be at least 3 characters"

          - name: "price"
            label: "Price"
            type: "numeric"
            readonly: true
            format:
              type: "currency"
              currency: "EUR"
              decimals: 2
            validators:
              - type: "required"
              - type: "range"
                min: 0
                max: 999999
                message: "Invalid price range"

          - name: "in_stock"
            label: "In Stock"
            type: "boolean"
            readonly: true

        back_button:
          enabled: true
          label: "Back to Products"
          navigate_to: "products_master"
```

## Step 5: Use Your Configuration

### Option A: Flutter Project Integration

In your Flutter app's `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() {
  runApp(
    GristApp.fromYaml('assets/app_config.yaml'),
  );
}
```

Don't forget to add the YAML file to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/app_config.yaml
```

### Option B: Test with Example App

Copy your configuration to the example directory and run:

```bash
cd example
flutter run
```

## Step 6: Test Your App

1. *Run the application*
   ```bash
   flutter run
   ```

2. *Log in with test credentials*
   - Email: `admin@example.com`
   - Password: `password123`

3. *Navigate through pages*
   - Open the drawer menu
   - Click "Home" to see the welcome page
   - Click "Products" to see the product list
   - Click a product row to see details

## Next Steps

Now that you have a working app:

✅ Add more pages for other Grist tables

✅ Configure field validation rules

✅ Set up role-based visibility with `visible_if`

✅ Add an admin dashboard

✅ Customize the theme colors

✅ Add more sophisticated navigation

## Common Issues

[Table content - see original for details]. Validate with an online YAML validator.",
    priority: "high"
  ),
  (
    issue: "Cannot connect to Grist",
    solution: "Verify base_url is correct, API key is valid, and document ID matches your Grist document.",
    priority: "high"
  ),
  (
    issue: "Login fails",
    solution: "Ensure Users table exists with correct schema (email, password_hash, role, active columns).",
    priority: "high"
  ),
  (
    issue: "Data not showing in tables",
    solution: "Check table name and column names match exactly (case-sensitive) with Grist schema.",
    priority: "medium"
  ),
  (
    issue: "Navigation doesn't work",
    solution: "Ensure page IDs are unique and navigate_to references valid page IDs.",
    priority: "medium"
  ),
))

## Template for New Pages

Use this template when adding new pages:

```yaml
  - id: "unique_page_id"
    type: "data_master"  # or "data_detail", "front", "admin_dashboard"
    title: "Page Title"
    menu:
      label: "Menu Label"
      icon: "icon_name"  # Material Icons
      order: 10
    visible_if: "true"  # Or role-based condition
    grist:
      table: "TableName"
      # ... table configuration
```

See the full YAML schema reference for all available options.
