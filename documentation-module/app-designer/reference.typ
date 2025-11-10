= Complete Reference

Comprehensive reference for app designers.

== Configuration File Structure

Complete YAML structure with all options:

```yaml
app:
  name: String
  version: String
  error_handling:
    show_error_details: Boolean
    default_error_message: String
    retry_enabled: Boolean
  loading:
    show_skeleton: Boolean
    spinner_type: "circular" | "linear"
    timeout_seconds: Integer

grist:
  base_url: String
  api_key: String
  document_id: String

auth:
  users_table: String
  users_table_schema:
    email_field: String
    password_field: String
    role_field: String
    active_field: String
  session:
    timeout_minutes: Integer
    remember_me: Boolean
    auto_logout_on_timeout: Boolean
  login_page:
    title: String
    logo: String (asset path)
    background_image: String (asset path)
    welcome_text: String

theme:
  primary_color: String (hex)
  secondary_color: String (hex)
  drawer_background: String (hex)
  drawer_text_color: String (hex)
  error_color: String (hex)
  success_color: String (hex)

navigation:
  drawer_header:
    title: String
    subtitle: String
    background_image: String (asset path)
  drawer_footer:
    show_user_info: Boolean
    show_logout_button: Boolean
    logout_confirmation: Boolean

pages:
  - # See page types below
```

== Page Type: Front

```yaml
- id: String (unique)
  type: "front"
  title: String
  menu:
    label: String
    icon: String (Material Icon name)
    order: Integer
    visible: Boolean
  content:
    text: String
    image: String (asset path)
    alignment: "left" | "center" | "right"
  visible_if: String (expression)
```

== Page Type: Data Master

```yaml
- id: String (unique)
  type: "data_master"
  title: String
  menu:
    label: String
    icon: String
    order: Integer
    visible: Boolean
  grist:
    table: String
    record_number:
      enabled: Boolean
      column_label: String
      sortable: Boolean
      keep_original_after_filter: Boolean
    columns:
      - name: String
        label: String
        visible: Boolean
        sortable: Boolean
        searchable: Boolean
        width: Integer
        format: "text" | "integer" | "currency" | "datetime"
        visible_if: String
    enable_search: Boolean
    enable_filter: Boolean
    pagination:
      enabled: Boolean
      page_size: Integer
    on_row_click:
      navigate_to: String (page ID)
      pass_param: String (field name)
  visible_if: String
```

== Page Type: Data Detail

```yaml
- id: String (unique)
  type: "data_detail"
  title: String
  menu:
    visible: Boolean
  grist:
    table: String
    record_id_param: String
    form:
      layout: "single_column" | "two_column"
      fields:
        - name: String
          label: String
          type: "text" | "integer" | "numeric" | "datetime" | "boolean"
          readonly: Boolean
          visible: Boolean
          visible_if: String
          multiline: Boolean
          validators:
            - type: "required" | "email" | "integer" | "numeric" | "range" | "minLength" | "maxLength" | "regex"
              message: String
              # For range:
              min: Number
              max: Number
              # For length:
              value: Integer
              # For regex:
              pattern: String
          format:
            type: "currency" | "datetime"
            # For currency:
            currency: String
            decimals: Integer
            # For datetime:
            pattern: String
      back_button:
        enabled: Boolean
        label: String
        navigate_to: String (page ID)
  visible_if: String
```

== Page Type: Admin Dashboard

```yaml
- id: String (unique)
  type: "admin_dashboard"
  title: String
  menu:
    label: String
    icon: String
    order: Integer
  widgets:
    - type: "active_users"
      title: String
      refresh_interval: Integer (seconds)
      show_columns: [String]

    - type: "database_summary"
      title: String
      grist_tables: [String]
      display:
        show_table_names: Boolean
        show_record_counts: Boolean
        show_last_modified: Boolean
        sortable: Boolean
        sort_by: String
      refresh_interval: Integer

    - type: "system_info"
      title: String
      show: [String]
  visible_if: String
```

== Expression Syntax

Used in `visible_if` conditions.

=== Variables

- `user.email` - String
- `user.role` - String
- `user.active` - Boolean
- Any other field from Users table

=== Operators

- `==` - Equals
- `!=` - Not equals
- `>` - Greater than
- `<` - Less than
- `>=` - Greater or equal
- `<=` - Less or equal
- `OR` - Logical OR
- `AND` - Logical AND

=== Examples

```yaml
visible_if: "user.role == 'admin'"
visible_if: "user.active == true"
visible_if: "user.role == 'admin' OR user.role == 'manager'"
visible_if: "(user.role == 'admin' OR user.role == 'hr') AND user.active == true"
```

== Material Icons Reference

Common icons for menu items. Full list: https://fonts.google.com/icons

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Icon*], [*Name*],
  [🏠], [`home`],
  [📦], [`inventory`],
  [👥], [`people`],
  [⚙️], [`settings`],
  [👤], [`person`],
  [📊], [`dashboard`],
  [📈], [`analytics`],
  [🛒], [`shopping_cart`],
  [🧾], [`receipt`],
  [💰], [`attach_money`],
  [📅], [`calendar_today`],
  [📁], [`folder`],
  [📝], [`edit`],
  [🗑️], [`delete`],
  [➕], [`add`],
  [🔍], [`search`],
  [📤], [`upload`],
  [📥], [`download`],
)

== Validator Types Reference

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Type*], [*Parameters*], [*Description*],
  [`required`], [`message`], [Field cannot be empty],
  [`email`], [`message`], [Valid email format: user@domain.com],
  [`integer`], [`message`], [Whole number (no decimals)],
  [`numeric`], [`message`], [Any number (integer or decimal)],
  [`range`], [`min`, `max`, `message`], [Number between min and max],
  [`minLength`], [`value`, `message`], [Minimum text length],
  [`maxLength`], [`value`, `message`], [Maximum text length],
  [`regex`], [`pattern`, `message`], [Custom regular expression],
)

== Format Types Reference

=== Currency

```yaml
format:
  type: "currency"
  currency: "EUR"  # ISO currency code
  decimals: 2      # Decimal places
```

Supported currencies: EUR, USD, GBP, JPY, CHF, CAD, AUD, etc.

=== DateTime

```yaml
format:
  type: "datetime"
  pattern: "dd/MM/yyyy HH:mm"
```

Common patterns:
- `dd/MM/yyyy` → 31/12/2025
- `yyyy-MM-dd` → 2025-12-31
- `HH:mm:ss` → 14:30:00
- `dd/MM/yyyy HH:mm` → 31/12/2025 14:30
- `EEEE, dd MMMM yyyy` → Monday, 31 December 2025

== Best Practices Summary

=== Security
- Use environment variables for API keys
- Never commit secrets to Git
- Use `.gitignore` for `.env` files
- Restrict admin pages with `visible_if`

=== Performance
- Enable pagination for large datasets
- Use appropriate page sizes (10-50)
- Limit searchable columns
- Minimize visible columns in master views

=== Maintainability
- Use descriptive IDs and labels
- Comment complex configurations
- Version control YAML files
- Document custom patterns

=== User Experience
- Provide clear validation messages
- Use appropriate field types
- Enable search and filter
- Use meaningful icons
- Organize menu logically

== Version History

*v0.1.0* (Current)
- Read-only data views
- Basic authentication
- Master-detail navigation
- Field validation
- Conditional visibility
- Admin dashboard
- Theme customization

*Planned Features*
- Editable forms (CRUD operations)
- Custom action buttons
- File upload support
- Offline mode
- Export functionality
- Advanced filtering
- Custom validators

== Additional Resources

- YAML Schema Documentation: `yaml-schema.typ`
- Design Patterns: `design-patterns.typ`
- Troubleshooting Guide: `troubleshooting.typ`
- Quick Start Guide: `quickstart.typ`
- Grist API Docs: https://support.getgrist.com/api/
- Material Icons: https://fonts.google.com/icons
- YAML Validators: https://www.yamllint.com/
