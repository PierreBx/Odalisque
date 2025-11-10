# Quickstart Guide

This quickstart will guide you through setting up your first Grist document for FlutterGristAPI in about 30 minutes.

## Prerequisites

Before you begin, ensure you have:

- [x] Access to a Grist instance (https://docs.getgrist.com or self-hosted)
- [x] A Grist account with permission to create documents
- [x] Basic understanding of databases (tables, columns, records)
- [x] A web browser (Chrome, Firefox, Safari, or Edge)

> **Note**: *New to Grist?* You can create a free account at https://docs.getgrist.com. For production use, consider self-hosting Grist (see the DevOps documentation).

## Step 1: Create a New Grist Document

1. *Log in to Grist*
   - Navigate to your Grist instance (e.g., https://docs.getgrist.com)
   - Sign in with your credentials

2. *Create a New Document*
   - Click the "+ Add New" button (usually in the top-left or sidebar)
   - Select "Create empty document"
   - Name your document: "MyFlutterApp" (or your app's name)
   - Click "Create"

3. *Note the Document ID*
   - Look at the URL in your browser. It will look like:
     ```
     https://docs.getgrist.com/doc/your_document_id_here
     ```
   - Copy the document ID (the part after `/doc/`)
   - Save it securely - you'll need it for API configuration

> **Warning**: *Document ID is sensitive!* Anyone with your document ID and API key can access your data. Keep both secure and never commit them to version control.

## Step 2: Create the Users Table

FlutterGristAPI requires a `Users` table for authentication. Let's create it:

### Create the Table

1. In your new Grist document, you'll see "Table1" by default
2. Click on the table name and rename it to "Users"
3. Or create a new table: Click "+ Add New" → "Add Page" → "Table" → Name it "Users"

### Add Required Columns

Remove the default columns and add these required columns:

| Column Name | Type | Required | Configuration |
| --- | --- | --- | --- |
| email | Text | ✓ | This will be the unique identifier for login |
| password_hash | Text | ✓ | Stores hashed passwords (never plain text) |
| role | Text | ✓ | User role: 'admin', 'manager', 'user', etc. |
| active | Toggle | ✓ | Whether the user account is active |

*To add each column:*

1. Click the "+" button in the column header area
2. Enter the column name (e.g., "email")
3. Select the column type from the dropdown
4. Click outside or press Enter to save

*For the `email` column, make it unique:*
1. Click on the column header → "Column Options"
2. Scroll down to "Formula" section
3. While we can't enforce uniqueness directly in Grist's free tier, document this requirement
4. Applications should check for duplicate emails before creating users

### Add Optional Columns

These columns are optional but recommended:

| Column Name | Type | Description |
| --- | --- | --- |
| full_name | Text | User's display name for the UI |
| created_at | DateTime | When the account was created |
| last_login | DateTime | When the user last logged in |
| phone | Text | Optional contact number |
| notes | Text | Admin notes about the user |

Your Users table should now look like this:

```
+----+-------------------+---------------+--------+--------+-------------+
| ID | email             | password_hash | role   | active | full_name   |
+----+-------------------+---------------+--------+--------+-------------+
|    |                   |               |        |        |             |
+----+-------------------+---------------+--------+--------+-------------+
```

## Step 3: Create Your First Test User

Let's add a test user manually to verify the structure:

1. *Click "+ Add Row"* at the bottom of the Users table

2. *Fill in the test user data:*
   - *email*: `test@example.com`
   - *password_hash*: `$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU7t8dVXLWVu`
     (This is a bcrypt hash of "password123" - for testing only!)
   - *role*: `admin`
   - *active*: `true` (check the toggle)
   - *full_name*: `Test User`

3. *Press Enter* or click outside to save

> **Danger**: *Security Warning*: Never use "password123" or simple passwords in production! This is a test example only. In production, passwords should be strong and hashed by your application using bcrypt or Argon2.

## Step 4: Generate an API Key

To allow FlutterGristAPI to access your Grist document, you need an API key:

1. *Open Profile Settings*
   - Click your profile icon (top-right corner)
   - Select "Profile Settings" from the dropdown

2. *Navigate to API Section*
   - Find the "API" section in the settings panel
   - You'll see a list of existing API keys (if any)

3. *Create New API Key*
   - Click "Create API Key" button
   - Give it a descriptive name: "MyFlutterApp Production"
   - Click "Create"

4. *Copy the API Key*
   - The API key will be displayed once (you can't see it again!)
   - Copy it immediately and store it securely
   - Recommended: Use a password manager or environment variable

Example API key format:
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

> **Warning**: *API Key Security*:
> - Never share your API key in public repositories
> - Never commit API keys to Git
> - Use environment variables in your configuration
> - Create separate API keys for dev/staging/production
> - Revoke and regenerate keys if compromised

## Step 5: Test API Access

Let's verify that your API key and document setup work correctly using curl:

### Test 1: Fetch Document Metadata

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://docs.getgrist.com/api/docs/YOUR_DOC_ID
```

Replace `YOUR_API_KEY` and `YOUR_DOC_ID` with your actual values.

*Expected response:*
```json
{
  "id": "your_doc_id",
  "name": "MyFlutterApp",
  "access": "owners",
  "createdAt": "2024-01-15T10:30:00.000Z",
  ...
}
```

### Test 2: List Tables

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables
```

*Expected response:*
```json
{
  "tables": [
    {
      "id": "Users",
      "fields": {
        "email": {...},
        "password_hash": {...},
        "role": {...},
        "active": {...}
      }
    }
  ]
}
```

### Test 3: Fetch Users

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records
```

*Expected response:*
```json
{
  "records": [
    {
      "id": 1,
      "fields": {
        "email": "test@example.com",
        "password_hash": "$2b$12$...",
        "role": "admin",
        "active": true,
        "full_name": "Test User"
      }
    }
  ]
}
```

> **Success**: *Success!* If all three tests return valid JSON responses, your Grist document is properly configured for FlutterGristAPI.

## Step 6: Configure FlutterGristAPI

Now configure your FlutterGristAPI application to connect to Grist:

Example configuration file (`config.yaml`):

```yaml
grist:
  base_url: "https://docs.getgrist.com"
  api_key: "${GRIST_API_KEY}"  # Set in environment variable
  document_id: "your_doc_id_here"
  timeout: 30

# Set the environment variable
# export GRIST_API_KEY="your_actual_api_key"
```

## Step 7: Create Additional Tables (Optional)

Depending on your application, you might need additional tables. Here are some common examples:

### Products Table

For e-commerce or inventory apps:

| Column | Type | Description |
| --- | --- | --- |
| name | Text | Product name |
| description | Text | Product description |
| price | Numeric | Product price |
| stock_quantity | Numeric | Available inventory |
| category | Choice | Product category |
| active | Toggle | Whether product is visible |
| created_at | DateTime | When product was added |

### Orders Table

For tracking customer orders:

| Column | Type | Description |
| --- | --- | --- |
| user_id | Reference → Users | Link to the user who placed the order |
| order_date | DateTime | When order was placed |
| status | Choice | pending, processing, shipped, delivered, cancelled |
| total_amount | Numeric | Total order value |
| shipping_address | Text | Delivery address |
| notes | Text | Special instructions |

### To create a new table:

1. Click "+ Add New" → "Add Page"
2. Select "Table"
3. Name your table (e.g., "Products")
4. Add columns as needed
5. Test with sample data

## Step 8: Set Up Access Rules (Optional)

For production environments, configure access rules to protect sensitive data:

1. *Open Access Rules*
   - Click the share button (top-right)
   - Select "Access Rules"

2. *Create User-Level Rules*
   - Example: Users can only see their own orders
   - Example: Only admins can modify the Users table

3. *Test Access Rules*
   - Create a test user with limited permissions
   - Log in as that user and verify restrictions work

> **Note**: *Access Rules are advanced*: For initial development, you can skip this step. Revisit it before deploying to production.

## Verification Checklist

Before moving forward, verify:

- [x] Grist document is created with a valid document ID
- [x] Users table exists with required columns (email, password_hash, role, active)
- [x] At least one test user is added to the Users table
- [x] API key is generated and stored securely
- [x] API tests with curl return successful responses
- [x] FlutterGristAPI configuration file is set up
- [x] Additional tables are created as needed (optional)
- [x] Access rules are configured for production (optional)

## Next Steps

Congratulations! Your Grist document is ready for FlutterGristAPI. Here's what to do next:

1. *Explore Schema Management*
   - Read the "Schema Management" section to learn best practices for table design
   - Understand data types and relationships
   - Plan for schema evolution

2. *Master User Management*
   - Learn how to add users programmatically
   - Understand password hashing
   - Implement role-based access

3. *Learn Data Operations*
   - Import existing user data
   - Export data for backups
   - Use bulk operations for efficiency

4. *Coordinate with Flutter Developer*
   - Share the document ID and API key (securely!)
   - Provide schema documentation
   - Coordinate on field names and data types

5. *Set Up Development Environment*
   - Create separate Grist documents for dev/staging/production
   - Use separate API keys for each environment
   - Document the differences between environments

## Troubleshooting Quick Tips

*Can't create a document?*
- Check if you're logged in
- Verify you have permission to create documents
- Check if you've reached your plan's document limit

*API tests failing?*
- Verify API key is correct (no extra spaces)
- Check document ID is accurate
- Ensure API key has access to the document
- Confirm Grist instance URL is correct

*Users table not working?*
- Verify column names are exactly: `email`, `password_hash`, `role`, `active`
- Check column types match requirements
- Ensure at least one user record exists

*Need help?*
- Check the "Troubleshooting" section of this documentation
- Review Grist's official documentation: https://support.getgrist.com
- Ask in the FlutterGristAPI community

> **Success**: *You're ready!* You've successfully set up your first Grist document for FlutterGristAPI. The rest of this documentation will help you master advanced database management techniques.
