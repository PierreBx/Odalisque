## Understanding Grist

  Grist is an open-source spreadsheet-database hybrid that combines the familiarity of spreadsheets with the power of databases. It provides:

  - *Structured data storage* with tables, columns, and relationships
  - *RESTful API* for programmatic access to data
  - *Web interface* for manual data management
  - *Access control* with user permissions and sharing
  - *Formula support* similar to Excel/Google Sheets

### Key Concepts

#### Documents
  A Grist document is the top-level container, similar to a database. Each document has:
  - Unique document ID (found in URL)
  - Multiple tables
  - Access permissions
  - API endpoint: `https://your-grist-instance/api/docs/{docId}`

#### Tables
  Tables store structured data in rows and columns:
  - Each table has a unique name
  - Contains records (rows) and columns (fields)
  - Can have relationships to other tables
  - Example: `Products`, `Customers`, `Orders`

#### Records
  Individual data entries in a table:
  - Each record has a unique numeric ID
  - Contains values for each column
  - Accessed via API: `/api/docs/{docId}/tables/{tableName}/records`

#### Columns
  Define the structure and data types:
  - *Text*: String values
  - *Numeric*: Integer or decimal numbers
  - *Date/DateTime*: Temporal values
  - *Toggle*: Boolean (true/false)
  - *Reference*: Link to records in another table
  - *Choice*: Dropdown with predefined options

### Grist API Basics

#### Authentication
  Grist uses API keys for authentication:

  ```bash
  curl -H "Authorization: Bearer YOUR_API_KEY" \
       https://docs.getgrist.com/api/docs/YOUR_DOC_ID
  ```

  To generate an API key:
  1. Log into Grist web interface
  2. Click your profile (top-right)
  3. Select "Profile Settings"
  4. Navigate to "API" section
  5. Click "Create API Key"
  6. Copy and store securely

#### Common API Operations

  *Fetch all records from a table:*
  ```bash
  GET /api/docs/{docId}/tables/{tableName}/records
  ```

  *Fetch a single record:*
  ```bash
  GET /api/docs/{docId}/tables/{tableName}/records/{recordId}
  ```

  *Create a new record:*
  ```bash
  POST /api/docs/{docId}/tables/{tableName}/records
  Content-Type: application/json

  {
    "records": [
      {
        "fields": {
          "name": "Product A",
          "price": 29.99
        }
      }
    ]
  }
  ```

  *Update a record:*
  ```bash
  PATCH /api/docs/{docId}/tables/{tableName}/records
  Content-Type: application/json

  {
    "records": [
      {
        "id": 123,
        "fields": {
          "price": 24.99
        }
      }
    ]
  }
  ```

  *Delete a record:*
  ```bash
  DELETE /api/docs/{docId}/tables/{tableName}/records
  Content-Type: application/json

  {
    "records": [123, 124, 125]
  }
  ```

### Required: Users Table

  FlutterGristAPI requires a *Users* table for authentication. The table must have these columns:



| Column | Type | Required | Description |
| --- | --- | --- | --- |
| email | Text | Yes | User's login email (must be unique) |
| password_hash | Text | Yes | Hashed password (never plain text!) |
| role | Text | Yes | User role: admin, manager, user, etc. |
| active | Toggle | Yes | Whether user can log in (true/false) |
| full_name | Text | No | User's display name |
| created_at | DateTime | No | Account creation timestamp |

  > **Warning**: *Security Warning:* Never store plain-text passwords in Grist. Always use hashed passwords (bcrypt, Argon2, etc.). The FlutterGristAPI library handles password hashing automatically during user creation.

### Grist Self-Hosting

  For production deployments, you can self-host Grist:

  *Using Docker:*
  ```bash
  docker run -p 8484:8484 \
             -v grist-data:/persist \
             gristlabs/grist
  ```

  *Using Docker Compose:*
  ```yaml
  version: '3'
  services:
    grist:
      image: gristlabs/grist
      ports:
        - "8484:8484"
      volumes:
        - ./grist-data:/persist
      environment:
        - GRIST_SESSION_SECRET=your-secret-here
  ```

### Best Practices



| Practice | Recommendation |
| --- | --- |
| API Keys | Store in environment variables, never commit to Git |
| Table Design | Use clear, descriptive table and column names |
| Data Types | Choose appropriate column types to ensure data integrity |
| Relationships | Use Reference columns for linking tables |
| Backups | Regularly export Grist documents or use volume backups |
| Testing | Use separate Grist documents for dev/staging/production |

## Grist Connection Configuration

  In your YAML configuration, specify Grist connection details:

  ```yaml
  grist:
    base_url: "https://docs.getgrist.com"  # Or your self-hosted URL
    api_key: "${GRIST_API_KEY}"             # Use environment variable
    document_id: "your_document_id"         # Found in Grist URL

    # Optional settings
    timeout: 30                              # API timeout in seconds
    retry_attempts: 3                        # Number of retry attempts
    cache_ttl: 300                          # Cache time-to-live in seconds
  ```

  > **Note**: *Environment Variables:* Use `${VAR_NAME}` syntax in YAML to reference environment variables. This keeps sensitive data out of version control.
