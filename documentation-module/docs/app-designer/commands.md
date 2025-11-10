# Common Commands & Actions

Quick reference for daily app designer tasks.

## YAML Configuration Tasks

[Command table - see original for details],
  (
    command: "Test configuration",
    description: "Run app with configuration",
    example: "flutter run"
  ),
  (
    command: "Check Grist connection",
    description: "Verify API access to Grist",
    example: "curl -H \"Authorization: Bearer API_KEY\" GRIST_URL/api/docs/DOC_ID"
  ),
))

## Grist Management Tasks

[Command table - see original for details],
  (
    command: "Generate API key",
    description: "Create new API key in Grist",
    example: "Profile Settings → API → Create"
  ),
  (
    command: "Get Document ID",
    description: "Find document ID from URL",
    example: "URL: .../doc/ABC123xyz → ID: ABC123xyz"
  ),
  (
    command: "View table schema",
    description: "Check table structure in Grist",
    example: "Open table → Right sidebar → Table schema"
  ),
))

## Configuration Workflow

### 1. Initial Setup
```bash
# Create configuration file
touch app_config.yaml

# Set environment variables
export GRIST_API_KEY="your_key"
export GRIST_DOC_ID="your_doc_id"

# Edit configuration
code app_config.yaml  # or your preferred editor
```

### 2. Iterative Development
```bash
# Make changes to YAML
# Run app to test
flutter run

# Check logs for errors
# Adjust configuration
# Repeat
```

### 3. Schema Changes
```bash
# Update Grist schema in web UI
# Update YAML configuration to match
# Test application
# Commit changes
git add app_config.yaml
git commit -m "Update schema for new fields"
```

## Common Configuration Snippets

### Add a New Page
```yaml
pages:
  - id: "new_page_id"
    type: "data_master"
    title: "Page Title"
    menu:
      label: "Menu Label"
      icon: "icon_name"
      order: 10
    grist:
      table: "TableName"
      columns:
        - name: "column1"
          label: "Column 1"
          visible: true
```

### Add Field Validation
```yaml
validators:
  - type: "required"
    message: "This field is required"
  - type: "email"
    message: "Invalid email format"
```

### Add Conditional Visibility
```yaml
visible_if: "user.role == 'admin'"
```

### Configure Pagination
```yaml
pagination:
  enabled: true
  page_size: 20
```

## Testing Checklist

After making configuration changes, verify:

- ✅ YAML syntax is valid (no parsing errors)
- ✅ App launches without errors
- ✅ All pages appear in navigation menu
- ✅ Data loads correctly from Grist tables
- ✅ Navigation between pages works
- ✅ Visibility rules work as expected
- ✅ Validation rules trigger appropriately
- ✅ Formatting displays correctly (currency, dates)

## Debugging Configuration Issues

[Table content - see original for details],
  (
    issue: "Page doesn't appear in menu",
    solution: "Check menu.visible is not false. Verify visible_if condition.",
    priority: "medium"
  ),
  (
    issue: "Data not loading",
    solution: "Verify table name matches Grist exactly (case-sensitive). Check API key permissions.",
    priority: "high"
  ),
  (
    issue: "Columns missing",
    solution: "Check column names match Grist schema. Set visible: true.",
    priority: "medium"
  ),
  (
    issue: "Navigation not working",
    solution: "Verify navigate_to references valid page ID. Check page IDs are unique.",
    priority: "medium"
  ),
))

## Environment Variables

Common environment variables for configuration:

```bash
# Grist connection
export GRIST_API_KEY="your_api_key"
export GRIST_BASE_URL="https://docs.getgrist.com"
export GRIST_DOC_ID="your_document_id"

# Application
export APP_ENV="development"  # or "production"
export APP_DEBUG="true"
```

## Quick Reference: Page Types

| Type | Use When |
| --- | --- |
| front | Need static content (welcome, about, help) |
| data_master | Need to display table/list of records |
| data_detail | Need to show single record details |
| admin_dashboard | Need system monitoring/stats |

## Quick Reference: Field Types

| Type | Use For |
| --- | --- |
| text | Names, descriptions, short text |
| integer | IDs, quantities, whole numbers |
| numeric | Prices, measurements, decimals |
| datetime | Timestamps, dates |
| boolean | Yes/no, active/inactive, flags |

## Quick Reference: Common Icons

```yaml
icon: "home"              # Home page
icon: "inventory"         # Products
icon: "people"            # Users/customers
icon: "shopping_cart"     # Orders
icon: "admin_panel_settings"  # Admin
icon: "settings"          # Settings
icon: "dashboard"         # Dashboard
icon: "analytics"         # Reports
```

See https://fonts.google.com/icons for full icon list.
