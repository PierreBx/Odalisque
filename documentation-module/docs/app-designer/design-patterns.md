# Design Patterns

Common application patterns and best practices for YAML configuration.

## Master-Detail Pattern

The most common pattern: a list view that navigates to a detail view.

### Structure

```
Products Master (Table) → Product Detail (Form)
Customers Master (Table) → Customer Detail (Form)
Orders Master (Table) → Order Detail (Form)
```

### Implementation

```yaml
pages:
  # Master page - list of items
  - id: "products_master"
    type: "data_master"
    grist:
      table: "Products"
      on_row_click:
        navigate_to: "products_detail"
        pass_param: "id"

  # Detail page - single item
  - id: "products_detail"
    type: "data_detail"
    menu:
      visible: false  # Hide from menu
    grist:
      table: "Products"
      record_id_param: "id"
      form:
        back_button:
          enabled: true
          navigate_to: "products_master"
```

## Dashboard Pattern

A landing page with key metrics and quick access to common functions.

```yaml
- id: "dashboard"
  type: "admin_dashboard"
  menu:
    label: "Dashboard"
    icon: "dashboard"
    order: 1
  widgets:
    - type: "database_summary"
      grist_tables:
        - "Products"
        - "Orders"
        - "Customers"
    - type: "active_users"
```

## Multi-Level Navigation Pattern

Organize related pages into logical groups using menu ordering.

```yaml
pages:
  - id: "orders"
    menu:
      label: "Orders"
      order: 10

  - id: "invoices"
    menu:
      label: "Invoices"
      order: 11

  - id: "products"
    menu:
      label: "Products"
      order: 20

  - id: "suppliers"
    menu:
      label: "Suppliers"
      order: 21
```

## Role-Based Access Pattern

Different views for different user roles.

```yaml
pages:
  # Everyone can see
  - id: "home"
    visible_if: "true"

  # Only managers and admins
  - id: "reports"
    visible_if: "user.role == 'manager' OR user.role == 'admin'"

  # Only admins
  - id: "admin_dashboard"
    visible_if: "user.role == 'admin'"

  # Only active users
  - id: "data"
    visible_if: "user.active == true"
```

## Read-Only Display Pattern

For current version (v0.1.0), all forms are read-only. Design patterns for display:

```yaml
form:
  fields:
    - name: "id"
      readonly: true  # Always set readonly for now

    - name: "created_at"
      type: "datetime"
      readonly: true
      format:
        type: "datetime"
        pattern: "dd/MM/yyyy HH:mm"

    - name: "price"
      type: "numeric"
      readonly: true
      format:
        type: "currency"
        currency: "EUR"
```

## Search and Filter Pattern

Enable powerful search on master pages.

```yaml
grist:
  enable_search: true
  enable_filter: true

  columns:
    - name: "name"
      searchable: true  # Include in search

    - name: "sku"
      searchable: true

    - name: "id"
      searchable: false  # Exclude from search
```

## Pagination Pattern

Handle large datasets efficiently.

```yaml
grist:
  pagination:
    enabled: true
    page_size: 25  # Adjust based on data complexity

  # For very large datasets
  #   page_size: 50
  # For complex records
  #   page_size: 10
```

## Validation Pattern

Layer multiple validations for robust data quality.

```yaml
fields:
  - name: "email"
    validators:
      - type: "required"
      - type: "email"
      - type: "regex"
        pattern: "^[a-z0-9._%+-]+@company\\.com$"
        message: "Must use company email"

  - name: "price"
    validators:
      - type: "required"
      - type: "numeric"
      - type: "range"
        min: 0
        max: 999999
        message: "Invalid price"
```

## Best Practices

### Keep It Simple
- Start with basic configuration
- Add complexity only when needed
- Test each change incrementally

### Use Descriptive IDs
```yaml
# Good
- id: "products_master"
- id: "customer_detail"
- id: "admin_users"

# Bad
- id: "page1"
- id: "p2"
- id: "details"
```

### Organize Menu Logically
```yaml
# Use order numbers in groups of 10
- order: 10  # First section
- order: 11
- order: 20  # Second section
- order: 21
- order: 90  # Admin section
- order: 91
```

### Environment-Specific Configs
```yaml
# Development
grist:
  base_url: "http://localhost:8484"
  api_key: "${DEV_GRIST_API_KEY}"

# Production
grist:
  base_url: "https://grist.company.com"
  api_key: "${PROD_GRIST_API_KEY}"
```

### Version Control
- Commit YAML files to Git
- Use `.env` files for secrets (add to `.gitignore`)
- Document configuration changes in commit messages
- Tag releases

## Anti-Patterns (Things to Avoid)

> **Danger**: *Don't hardcode secrets*
> ```yaml
> # BAD
> api_key: "abc123secret456"
>
> # GOOD
> api_key: "${GRIST_API_KEY}"
> ```

> **Danger**: *Don't use inconsistent naming*
> ```yaml
> # BAD - mixing conventions
> - id: "ProductsMaster"
> - id: "customer-detail"
> - id: "admin_Users"
>
> # GOOD - consistent snake_case
> - id: "products_master"
> - id: "customer_detail"
> - id: "admin_users"
> ```

> **Danger**: *Don't create overly complex visibility rules*
> ```yaml
> # BAD - hard to maintain
> visible_if: "(user.role == 'admin' OR (user.role == 'manager' AND user.department == 'sales')) AND user.active == true AND user.certified == true"
>
> # GOOD - simpler logic
> visible_if: "user.role == 'admin' OR user.role == 'manager'"
> ```
