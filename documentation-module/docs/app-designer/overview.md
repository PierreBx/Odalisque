# Overview

## Role Description

The *App Designer* (also known as YAML Configuration Manager) is responsible for designing and configuring FlutterGristAPI applications without writing code. You create complete Flutter applications by describing their structure, behavior, and data connections in a YAML configuration file.

## Responsibilities

- Designing application structure and navigation
- Configuring pages (data tables, forms, dashboards)
- Defining field validation rules and visibility conditions
- Setting up authentication and user roles
- Customizing app theme and branding
- Aligning application schema with Grist table structures
- Testing and iterating on app configurations

## Prerequisites

Before you begin, you should:

| Requirement | Description |
| --- | --- |
| Grist Access | Access to the Grist instance and document you'll connect to |
| Grist API Key | Generated from Grist profile settings |
| Document ID | The unique ID of your Grist document |
| Basic YAML | Understanding of YAML syntax and structure |
| Flutter Basics | Basic understanding of Flutter app structure (helpful but not required) |

## Key Concepts

### YAML-Driven Development

Instead of writing Dart/Flutter code, you write a declarative YAML file that describes:

- *What pages exist* in your app
- *What data* each page displays from Grist
- *How users navigate* between pages
- *Who can see what* based on roles and conditions
- *How data is validated* and formatted

The FlutterGristAPI library reads this YAML file and automatically generates a complete Flutter application.

### Application Structure

Every FlutterGristAPI application consists of:

**Configuration Layer**: YAML files defining app structure
**Authentication**: User login tied to Grist Users table
**Navigation**: Drawer menu with role-based visibility
**Pages**: Front pages (static), Data Master (tables), Data Detail (forms), Admin Dashboard
**Data Layer**: Automatic integration with Grist API

### Page Types

| Type | Purpose | Use Case |
| --- | --- | --- |
| front | Static content pages with text and images | Welcome screen, about page, help |
| data_master | Tabular view of Grist table with search/sort/pagination | Product list, customer directory |
| data_detail | Form view of a single record with validation | Product details, customer profile |
| admin_dashboard | System statistics and monitoring | Active users, database stats |

## Schema Alignment

> **Warning**: *Critical:* Your YAML configuration must match your Grist schema. Column names, data types, and table references in your YAML must exactly match what exists in Grist, or the app will fail to load data.

### Schema Synchronization Workflow

1. *Design Grist Schema First*
   - Create tables with appropriate columns and types
   - Set up relationships between tables
   - Add sample data for testing

2. *Map to YAML Configuration*
   - Reference exact table names
   - Use exact column names (case-sensitive)
   - Match data types appropriately

3. *Test and Iterate*
   - Run the app
   - Check for schema errors in logs
   - Adjust configuration as needed

## Typical Workflow

```
1. Access Grist → Create/review table schema
2. Create YAML config file → Define app structure
3. Configure pages → Map to Grist tables
4. Set up navigation → Define menu items
5. Add validation rules → Ensure data quality
6. Configure visibility → Control access by role
7. Test application → Verify functionality
8. Deploy → Make available to users
```

## Best Practices

### Organization
- Keep configuration files in version control (Git)
- Use environment variables for sensitive data (API keys)
- Comment your YAML for complex configurations
- Organize page definitions logically

### Naming Conventions
- Use descriptive page IDs (e.g., `products_master`, `customer_detail`)
- Use clear labels for menu items
- Choose appropriate Material Icons for navigation

### Performance
- Enable pagination for large datasets
- Use appropriate page sizes (10-50 records)
- Limit the number of columns in master views
- Cache-friendly configurations

### Security
- Use `visible_if` to restrict sensitive pages
- Validate all form inputs
- Use role-based access control
- Never commit API keys to version control

## Tools and Resources

| Tool | Purpose |
| --- | --- |
| Text Editor | VS Code, Sublime Text, or any editor with YAML support |
| YAML Validator | Online validators to check syntax |
| Grist Web UI | For schema design and data management |
| Material Icons | https://fonts.google.com/icons for icon names |
| Flutter DevTools | For debugging generated apps (optional) |

## Success Metrics

You'll know you're effective when:

- ✅ Your YAML configurations are valid and error-free
- ✅ Apps load data correctly from Grist
- ✅ Navigation and page flow work as expected
- ✅ Validation rules catch invalid data
- ✅ Users can accomplish their tasks efficiently
- ✅ Configuration changes are quick and don't break existing functionality
