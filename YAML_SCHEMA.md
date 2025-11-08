# YAML Configuration Schema

Complete reference for the `flutter_grist_widgets` YAML-driven app generator.

## Overview

This library allows you to create a complete Flutter application by providing a YAML configuration file that describes:
- Application settings and theme
- Grist connection details
- Authentication system
- Navigation structure
- Pages (front pages, data tables, forms, admin dashboard)
- Error handling and loading states

## Top-Level Structure

```yaml
app: {...}
grist: {...}
auth: {...}
theme: {...}
navigation: {...}
pages: [...]
```

---

## 1. App Configuration

```yaml
app:
  name: "My App"
  version: "1.0.0"

  error_handling:
    show_error_details: true  # Show stack traces (dev mode)
    default_error_message: "Something went wrong"
    retry_enabled: true

  loading:
    show_skeleton: true  # Skeleton screens vs spinners
    spinner_type: "circular"  # "circular" or "linear"
    timeout_seconds: 30
```

---

## 2. Grist Configuration

```yaml
grist:
  base_url: "https://docs.getgrist.com"
  api_key: "your_api_key"
  document_id: "your_document_id"
```

---

## 3. Authentication

```yaml
auth:
  users_table: "Users"

  users_table_schema:
    email_field: "email"
    password_field: "password_hash"
    role_field: "role"
    active_field: "active"

  session:
    timeout_minutes: 60
    remember_me: true
    auto_logout_on_timeout: true

  login_page:
    title: "Login"
    logo: "assets/logo.png"
    background_image: "assets/login_bg.png"
    welcome_text: "Welcome message"
```

### Expected Users Table Structure in Grist

| Column | Type | Description |
|--------|------|-------------|
| email | Text | User email (username) |
| password_hash | Text | Hashed password |
| role | Text | User role (admin, manager, user, etc.) |
| active | Toggle | Whether user can log in |

---

## 4. Theme

```yaml
theme:
  primary_color: "#2196F3"
  secondary_color: "#FFC107"
  drawer_background: "#263238"
  drawer_text_color: "#FFFFFF"
  error_color: "#F44336"
  success_color: "#4CAF50"
```

Colors should be hex format with `#`.

---

## 5. Navigation

```yaml
navigation:
  drawer_header:
    title: "App Title"
    subtitle: "Subtitle"
    background_image: "assets/header.png"

  drawer_footer:
    show_user_info: true
    show_logout_button: true
    logout_confirmation: true
```

---

## 6. Pages

### 6.1 Front Page (Static Content)

```yaml
- id: "home"
  type: "front"
  title: "Home"
  menu:
    label: "Home"
    icon: "home"  # Material Icons name
    order: 1
  content:
    text: "Welcome text"
    image: "assets/welcome.png"
    alignment: "center"  # "left", "center", "right"
  visible_if: "true"
```

### 6.2 Data Master Page (Tabular View)

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

    record_number:
      enabled: true
      column_label: "N"
      sortable: true
      keep_original_after_filter: true

    columns:
      - name: "id"
        label: "ID"
        visible: true
        sortable: true
        searchable: false
        width: 80
        format: "integer"  # "text", "currency", "datetime"
        visible_if: "true"

      - name: "name"
        label: "Product Name"
        visible: true
        sortable: true
        searchable: true

    enable_search: true
    enable_filter: true

    pagination:
      enabled: true
      page_size: 20

    on_row_click:
      navigate_to: "products_detail"
      pass_param: "id"

  visible_if: "user.active == true"
```

### 6.3 Data Detail Page (Form View)

```yaml
- id: "products_detail"
  type: "data_detail"
  title: "Product Details"
  menu:
    visible: false

  grist:
    table: "Products"
    record_id_param: "id"

    form:
      layout: "single_column"  # or "two_column"

      fields:
        - name: "id"
          label: "Product ID"
          type: "integer"
          readonly: true
          visible: true
          visible_if: "true"

          validators:
            - type: "required"
              message: "This field is required"

            - type: "range"
              min: 0
              max: 999999
              message: "Value out of range"

            - type: "regex"
              pattern: "^[A-Z0-9]+$"
              message: "Invalid format"

            - type: "email"
              message: "Invalid email"

            - type: "integer"

            - type: "numeric"

            - type: "minLength"
              value: 3
              message: "Too short"

            - type: "maxLength"
              value: 100
              message: "Too long"

          format:
            type: "currency"
            currency: "EUR"
            decimals: 2

        - name: "description"
          label: "Description"
          type: "text"
          multiline: true
          readonly: true

      back_button:
        enabled: true
        label: "Back"
        navigate_to: "products_master"
```

### 6.4 Admin Dashboard

```yaml
- id: "admin_dashboard"
  type: "admin_dashboard"
  title: "Administration"
  menu:
    label: "Admin"
    icon: "admin_panel_settings"
    order: 99
  visible_if: "user.role == 'admin'"

  widgets:
    - type: "active_users"
      title: "Currently Logged In Users"
      refresh_interval: 30
      show_columns:
        - "email"
        - "role"
        - "last_activity"

    - type: "database_summary"
      title: "Database Overview"
      grist_tables:
        - "Products"
        - "Customers"
      display:
        show_table_names: true
        show_record_counts: true
        show_last_modified: true
        sortable: true
        sort_by: "table_name"
      refresh_interval: 60

    - type: "system_info"
      title: "System Information"
      show:
        - "app_version"
        - "grist_connection_status"
        - "total_users"
        - "active_sessions"
```

---

## 7. Field Types

| Type | Description | Example |
|------|-------------|---------|
| `text` | Single-line text | Name, Email |
| `integer` | Whole numbers | Age, Quantity |
| `numeric` | Decimal numbers | Price, Weight |
| `datetime` | Date and time | Created At |
| `boolean` | True/False | Active, Published |

---

## 8. Validators

| Validator | Parameters | Description |
|-----------|------------|-------------|
| `required` | `message` | Field must not be empty |
| `email` | `message` | Valid email format |
| `integer` | `message` | Must be integer |
| `numeric` | `message` | Must be numeric |
| `range` | `min`, `max`, `message` | Value within range |
| `minLength` | `value`, `message` | Minimum text length |
| `maxLength` | `value`, `message` | Maximum text length |
| `regex` | `pattern`, `message` | Custom regex pattern |

---

## 9. Format Options

### Currency
```yaml
format:
  type: "currency"
  currency: "EUR"  # EUR, USD, GBP, etc.
  decimals: 2
```

### DateTime
```yaml
format:
  type: "datetime"
  pattern: "dd/MM/yyyy HH:mm"
```

---

## 10. Conditional Visibility

Use expression-based visibility conditions:

```yaml
visible_if: "user.role == 'admin'"
visible_if: "user.role == 'admin' OR user.role == 'manager'"
visible_if: "user.active == true"
visible_if: "true"  # Always visible
```

### Available Context Variables

- `user.email` - Logged-in user's email
- `user.role` - Logged-in user's role
- `user.active` - Logged-in user's active status
- Any other field from the Users table

### Supported Operators

- `==` - Equals
- `!=` - Not equals
- `OR` - Logical OR
- `AND` - Logical AND
- `>`, `<`, `>=`, `<=` - Comparisons

---

## 11. Material Icons

For menu icons, use [Material Icons](https://fonts.google.com/icons) names:

- `home`
- `inventory`
- `people`
- `admin_panel_settings`
- `settings`
- `dashboard`
- `analytics`
- `shopping_cart`
- etc.

---

## 12. Special Features

### Record Number Column

Automatically adds a column showing display order (1, 2, 3...):

```yaml
record_number:
  enabled: true
  column_label: "N"
  sortable: true
  keep_original_after_filter: true  # Don't renumber after filter
```

### Grist ID Column

Grist's internal `id` column is always available and can be displayed like any other column.

---

## Complete Example

See `example/app_config.yaml` for a complete working example.
