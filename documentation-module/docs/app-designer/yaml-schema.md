# YAML Configuration Schema

Complete reference for the FlutterGristAPI YAML-driven app generator.

## Schema Overview

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

# 1. App Configuration

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

## Configuration Options

| Field | Type | Description |
| --- | --- | --- |
| name | String | Application name displayed in UI |
| version | String | Application version number |
| error_handling | Object | Error handling configuration |
| loading | Object | Loading state configuration |

---

# 2. Grist Configuration

```yaml
grist:
  base_url: "https://docs.getgrist.com"
  api_key: "your_api_key"
  document_id: "your_document_id"
```

## Required Fields

| Field | Description |
| --- | --- |
| base_url | Grist instance URL (self-hosted or docs.getgrist.com) |
| api_key | API key from Grist Profile Settings → API (use env vars!) |
| document_id | Document ID from URL after /doc/ |

> **Warning**: *Security:* Use environment variables for API keys:
>
> ```yaml
> api_key: "${GRIST_API_KEY}"
> ```
>
> Then set in your environment:
> ```bash
> export GRIST_API_KEY="your_actual_key"
> ```

---

# 3. Authentication Configuration

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

## Required Users Table Structure in Grist

| Column | Type | Description |
| --- | --- | --- |
| email | Text | User email address (used as username) |
| password_hash | Text | Hashed password (bcrypt, Argon2, etc.) |
| role | Text | User role (admin, manager, user, etc.) |
| active | Toggle | Whether user account is active and can log in |

---

# 4. Theme Configuration

```yaml
theme:
  primary_color: "#2196F3"
  secondary_color: "#FFC107"
  drawer_background: "#263238"
  drawer_text_color: "#FFFFFF"
  error_color: "#F44336"
  success_color: "#4CAF50"
```

Colors should be in hex format with `#` prefix.

---

# 5. Navigation Configuration

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

# 6. Pages Configuration

Pages are the core of your application. FlutterGristAPI supports four page types.

## 6.1 Front Page (Static Content)

Static content pages with text and images.

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

## 6.2 Data Master Page (Tabular View)

Displays Grist table data in a sortable, searchable table.

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

### Column Configuration Options

| Field | Type | Description |
| --- | --- | --- |
| name | String | Column name in Grist (case-sensitive) |
| label | String | Display label in UI |
| visible | Boolean | Whether column is displayed |
| sortable | Boolean | Enable sorting on this column |
| searchable | Boolean | Include in search functionality |
| width | Integer | Column width in pixels (optional) |
| format | String | Data format (integer, currency, datetime) |
| visible_if | String | Conditional visibility expression |

## 6.3 Data Detail Page (Form View)

Displays a single record as a form with validation.

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

### Field Configuration Options

| Field | Type | Description |
| --- | --- | --- |
| name | String | Field name in Grist |
| label | String | Display label |
| type | String | Data type (text, integer, numeric, datetime, boolean) |
| readonly | Boolean | Field is read-only (for v0.1.0, all fields are readonly) |
| multiline | Boolean | Multi-line text input |
| validators | Array | Validation rules |
| format | Object | Display formatting |

## 6.4 Admin Dashboard

Monitoring and administration page.

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

# 7. Field Types

| Type | Description | Example Use |
| --- | --- | --- |
| text | Single-line text | Name, Email, SKU |
| integer | Whole numbers | Age, Quantity, ID |
| numeric | Decimal numbers | Price, Weight, Rating |
| datetime | Date and time | Created At, Last Modified |
| boolean | True/False (Toggle) | Active, Published, In Stock |

---

# 8. Validators

| Validator | Parameters | Description |
| --- | --- | --- |
| required | message | Field must not be empty |
| email | message | Valid email format |
| integer | message | Must be an integer |
| numeric | message | Must be numeric |
| range | min`, `max`, `message | Value within numeric range |
| minLength | value`, `message | Minimum text length |
| maxLength | value`, `message | Maximum text length |
| regex | pattern`, `message | Custom regular expression pattern |

## Validator Examples

### Required Field
```yaml
validators:
  - type: "required"
    message: "This field is required"
```

### Email Validation
```yaml
validators:
  - type: "required"
  - type: "email"
    message: "Invalid email format"
```

### Numeric Range
```yaml
validators:
  - type: "range"
    min: 0
    max: 100
    message: "Value must be between 0 and 100"
```

### Text Length
```yaml
validators:
  - type: "minLength"
    value: 3
    message: "Minimum 3 characters"
  - type: "maxLength"
    value: 50
    message: "Maximum 50 characters"
```

### Custom Regex Pattern
```yaml
validators:
  - type: "regex"
    pattern: "^[A-Z]{2}[0-9]{4}$"
    message: "Format must be: XX1234"
```

---

# 9. Format Options

## Currency Format

```yaml
format:
  type: "currency"
  currency: "EUR"  # EUR, USD, GBP, JPY, etc.
  decimals: 2
```

## DateTime Format

```yaml
format:
  type: "datetime"
  pattern: "dd/MM/yyyy HH:mm"
```

Common patterns:
- `dd/MM/yyyy` - 31/12/2025
- `yyyy-MM-dd` - 2025-12-31
- `dd/MM/yyyy HH:mm` - 31/12/2025 14:30
- `HH:mm:ss` - 14:30:00

---

# 10. Conditional Visibility

Use expression-based visibility conditions to show/hide UI elements based on user roles or data.

## Syntax

```yaml
visible_if: "expression"
```

## Available Context Variables

| Variable | Description |
| --- | --- |
| user.email | Logged-in user's email address |
| user.role | Logged-in user's role |
| user.active | Logged-in user's active status |
| Other fields | Any other field from the Users table |

## Supported Operators

| Operator | Description |
| --- | --- |
| == | Equals |
| != | Not equals |
| > | Greater than |
| < | Less than |
| >= | Greater than or equal |
| <= | Less than or equal |
| OR | Logical OR |
| AND | Logical AND |

## Examples

### Show Only to Admins
```yaml
visible_if: "user.role == 'admin'"
```

### Show to Admins OR Managers
```yaml
visible_if: "user.role == 'admin' OR user.role == 'manager'"
```

### Show to Active Users Only
```yaml
visible_if: "user.active == true"
```

### Complex Condition
```yaml
visible_if: "(user.role == 'admin' OR user.role == 'hr') AND user.active == true"
```

---

# 11. Material Icons

For menu icons, use Material Icons names from https://fonts.google.com/icons

## Common Icons

| Icon Name | Use Case |
| --- | --- |
| home | Home page |
| inventory | Products, stock |
| people | Users, customers |
| admin_panel_settings | Admin dashboard |
| settings | Settings |
| dashboard | Dashboard |
| analytics | Reports, analytics |
| shopping_cart | Orders, cart |
| receipt | Invoices, receipts |
| attach_money | Financial data |
| calendar_today | Calendar, scheduling |
| folder | Documents, files |

---

# 12. Special Features

## Record Number Column

Automatically adds a sequential number column (1, 2, 3...) independent of Grist ID.

```yaml
record_number:
  enabled: true
  column_label: "N"
  sortable: true
  keep_original_after_filter: true  # Don't renumber after filtering
```

## Grist ID Column

Grist's internal `id` column is always available and can be displayed like any other column:

```yaml
columns:
  - name: "id"
    label: "Grist ID"
    visible: true
    sortable: true
```

---

# 13. Complete Example

Minimal complete configuration:

```yaml
app:
  name: "Business App"
  version: "1.0.0"

grist:
  base_url: "https://docs.getgrist.com"
  api_key: "${GRIST_API_KEY}"
  document_id: "ABC123xyz"

auth:
  users_table: "Users"

theme:
  primary_color: "#2196F3"

pages:
  - id: "home"
    type: "front"
    title: "Home"
    menu:
      label: "Home"
      icon: "home"
    content:
      text: "Welcome!"
```

For a complete working example with all features, see `example/app_config.yaml` in the repository.
