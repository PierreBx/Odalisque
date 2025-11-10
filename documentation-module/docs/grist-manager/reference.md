# Complete Reference

This section provides comprehensive reference information for Grist Managers working with FlutterGristAPI.

## Grist API Endpoints

### Base URL Structure

```
https://{grist-instance}/api/{resource}
```

Examples:
- Hosted: `https://docs.getgrist.com/api/...`
- Self-hosted: `https://grist.yourcompany.com/api/...`

### Authentication

All API requests require Bearer token authentication:

```
Authorization: Bearer YOUR_API_KEY
```

### Document Endpoints

#### GET /api/docs/{docId}

Get document metadata.

*Response:*
```json
{
  "id": "doc_id",
  "name": "Document Name",
  "access": "owners",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-11-10T14:30:00.000Z",
  "isPinned": false,
  "urlId": "doc_id",
  "workspace": {...}
}
```

#### GET /api/docs/{docId}/tables

List all tables in a document.

*Response:*
```json
{
  "tables": [
    {
      "id": "Users",
      "fields": {
        "email": {...},
        "password_hash": {...},
        "role": {...}
      }
    }
  ]
}
```

#### GET /api/docs/{docId}/download

Download entire document (requires appropriate permissions).

*Response:* Binary SQLite database file

### Table Endpoints

#### GET /api/docs/{docId}/tables/{tableId}/columns

Get table schema (all columns).

*Response:*
```json
{
  "columns": [
    {
      "id": "email",
      "fields": {
        "colRef": 1,
        "label": "Email",
        "type": "Text",
        "widgetOptions": "",
        "isFormula": false,
        "formula": ""
      }
    }
  ]
}
```

### Record Endpoints

#### GET /api/docs/{docId}/tables/{tableId}/records

Fetch all records from a table.

*Query Parameters:*
- `limit`: Maximum number of records (e.g., `?limit=100`)
- `filter`: JSON filter object (URL-encoded)

*Example with filter:*
```bash
GET /api/docs/DOC_ID/tables/Users/records?filter=%7B%22active%22%3A%5Btrue%5D%7D
# Filter: {"active":[true]}
```

*Response:*
```json
{
  "records": [
    {
      "id": 1,
      "fields": {
        "email": "user@example.com",
        "role": "user",
        "active": true
      }
    }
  ]
}
```

#### GET /api/docs/{docId}/tables/{tableId}/records/{recordId}

Fetch a single record by ID.

*Response:*
```json
{
  "id": 42,
  "fields": {
    "email": "user@example.com",
    "role": "admin"
  }
}
```

#### POST /api/docs/{docId}/tables/{tableId}/records

Create one or more records.

*Request Body:*
```json
{
  "records": [
    {
      "fields": {
        "email": "newuser@example.com",
        "password_hash": "$2b$12$...",
        "role": "user",
        "active": true
      }
    }
  ]
}
```

*Response:*
```json
{
  "records": [
    {
      "id": 43,
      "fields": {...}
    }
  ]
}
```

#### PATCH /api/docs/{docId}/tables/{tableId}/records

Update one or more records.

*Request Body:*
```json
{
  "records": [
    {
      "id": 42,
      "fields": {
        "role": "manager"
      }
    }
  ]
}
```

*Response:*
```json
{
  "records": [
    {
      "id": 42,
      "fields": {...}
    }
  ]
}
```

#### DELETE /api/docs/{docId}/tables/{tableId}/records

Delete one or more records.

*Request Body:*
```json
{
  "records": [42, 43, 44]
}
```

*Response:*
```json
{
  "records": [42, 43, 44]
}
```

## Data Types Reference

### Text

*Grist type:* `Text`

*API representation:* JSON string

*Examples:*
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "description": "Software developer"
}
```

*Validation:*
- Maximum length: 32,000 characters
- Can contain any Unicode characters
- Empty string is valid (unless required by app)

*Common uses:*
- Names, emails, descriptions
- Short and long text content
- Free-form input

### Numeric

*Grist type:* `Numeric`

*API representation:* JSON number

*Examples:*
```json
{
  "price": 29.99,
  "quantity": 100,
  "discount": 0.15,
  "rating": 4.5
}
```

*Validation:*
- JavaScript number precision (IEEE 754)
- Can be integer or decimal
- Scientific notation supported: `1.5e10`

*Configuration options:*
- Decimal places (0-10)
- Currency symbol
- Thousands separator
- Percentage display

*Common uses:*
- Prices, quantities, measurements
- Ratings, scores
- Financial calculations

### Integer

*Grist type:* `Int`

*API representation:* JSON number (whole numbers only)

*Examples:*
```json
{
  "age": 35,
  "count": 150,
  "year": 2024
}
```

*Validation:*
- Whole numbers only (no decimals)
- Range: -2^53 to 2^53 (JavaScript safe integer)

*Common uses:*
- Counters, quantities
- Age, year values
- Votes, ratings (whole numbers)

### Date

*Grist type:* `Date`

*API representation:* ISO 8601 date string (`YYYY-MM-DD`)

*Examples:*
```json
{
  "birth_date": "1990-05-15",
  "due_date": "2024-12-31",
  "event_date": "2024-11-10"
}
```

*Format:*
- API input/output: `YYYY-MM-DD`
- Display format configurable in Grist UI

*Common uses:*
- Birthdays, anniversaries
- Due dates, deadlines
- Event dates (without time)

### DateTime

*Grist type:* `DateTime`

*API representation:* ISO 8601 datetime string with timezone

*Examples:*
```json
{
  "created_at": "2024-11-10T14:30:00.000Z",
  "last_login": "2024-11-10T09:15:22.500Z",
  "scheduled_time": "2024-12-25T00:00:00.000Z"
}
```

*Format:*
- Must include time: `YYYY-MM-DDTHH:MM:SS.sssZ`
- Timezone: `Z` for UTC, or `+HH:MM` / `-HH:MM`
- Milliseconds optional but recommended

*Timezone handling:*
- Always store in UTC (`.000Z`)
- Convert to local time in application

*Common uses:*
- Created/updated timestamps
- Login times
- Scheduled events with time

### Toggle

*Grist type:* `Bool`

*API representation:* JSON boolean

*Examples:*
```json
{
  "active": true,
  "is_verified": false,
  "has_accepted_terms": true
}
```

*Values:*
- `true` or `false` (not strings)
- Default: `false` if not specified

*Display:*
- Checkbox in Grist UI
- Can customize labels (e.g., "Yes"/"No")

*Common uses:*
- Active/inactive status
- Feature flags
- Boolean settings
- Permissions

### Choice

*Grist type:* `Choice`

*API representation:* JSON string (must match a defined choice)

*Examples:*
```json
{
  "status": "pending",
  "priority": "high",
  "category": "electronics"
}
```

*Configuration:*
- Define allowed values in Grist
- Assign colors to choices
- Values are case-sensitive

*Validation:*
- Must be one of the predefined choices
- Empty string or null if optional

*Common uses:*
- Status fields (pending, approved, rejected)
- Priority levels (low, medium, high)
- Categories, types

### Choice List

*Grist type:* `ChoiceList`

*API representation:* JSON array of strings

*Examples:*
```json
{
  "tags": ["urgent", "customer-facing", "bug"],
  "skills": ["python", "javascript", "sql"],
  "features": ["login", "profile", "settings"]
}
```

*Configuration:*
- Same as Choice (predefined values)
- Order doesn't matter

*Common uses:*
- Tags, labels
- Multiple categories
- Multiple selections

### Reference

*Grist type:* `Ref:{TableName}`

*API representation:* JSON number (record ID) or null

*Examples:*
```json
{
  "user_id": 42,
  "category_id": 5,
  "parent_id": null
}
```

*Configuration:*
- Target table: Which table to reference
- Show column: Which field to display (e.g., `email` instead of ID)

*API behavior:*
- Send/receive numeric record ID
- Display value not included (use formula or join)

*Common uses:*
- Foreign keys
- Relationships between tables
- User associations

### Reference List

*Grist type:* `RefList:{TableName}`

*API representation:* JSON array of numbers (record IDs)

*Examples:*
```json
{
  "assigned_users": [5, 12, 18],
  "related_products": [101, 102, 103],
  "tags": []
}
```

*Configuration:*
- Same as Reference

*Common uses:*
- Many-to-many relationships
- Multiple assignees
- Multiple categories/tags

### Attachments

*Grist type:* `Attachments`

*API representation:* JSON array of attachment objects

*Examples:*
```json
{
  "documents": [
    {
      "fileName": "report.pdf",
      "fileSize": 123456,
      "url": "https://docs.getgrist.com/attachments/...",
      "fileIdent": "abc123"
    }
  ]
}
```

*Properties:*
- `fileName`: Original filename
- `fileSize`: Size in bytes
- `url`: Download URL (requires authentication)
- `fileIdent`: Unique identifier

*Uploading:*
- Upload via web interface
- API upload support varies by Grist version

*Common uses:*
- Document uploads
- Images (profile pictures, product photos)
- File attachments

## FlutterGristAPI Users Table Specification

### Required Schema

For FlutterGristAPI authentication to work, the Users table MUST have this exact structure:

| Column | Type | Required | Description |
| --- | --- | --- | --- |
| email | Text | ✓ | User's email address for login. Must be unique. Used as username. |
| password_hash | Text | ✓ | Bcrypt or Argon2 hash of user's password. Never store plain text. FlutterGristAPI handles hashing automatically. |
| role | Text or Choice | ✓ | User's role for authorization. Common values: 'admin', 'manager', 'user'. Case-sensitive. |
| active | Toggle | ✓ | Whether user account is active. Must be `true` for login to work. Use `false` to disable accounts. |

### Recommended Additional Columns

| Column | Type | Purpose |
| --- | --- | --- |
| full_name | Text | Display name for UI. More friendly than email. |
| created_at | DateTime | Account creation timestamp. Useful for analytics and auditing. |
| updated_at | DateTime | Last profile update. Track when user info changes. |
| last_login | DateTime | Most recent successful login. Monitor inactive accounts. |
| phone | Text | Contact phone number. Optional contact method. |
| profile_picture | Attachments | User avatar image. Enhances UI experience. |
| email_verified | Toggle | Email verification status. Security feature. |
| two_factor_enabled | Toggle | 2FA status. Additional security layer. |
| notes | Text | Admin notes about user. Not visible to user. |

### Password Hash Requirements

*Format:* Bcrypt hash

*Structure:*
```
$2b$12$abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQR
```

*Components:*
- `$2b$`: Bcrypt version identifier
- `12`: Cost factor (rounds). 12 is recommended.
- Remaining 53 characters: Salt and hash

*Length:* Exactly 60 characters

*Generation:*
```python
import bcrypt
hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
```

*Verification:*
```python
import bcrypt
is_valid = bcrypt.checkpw(password.encode(), hash.encode())
```

> **Danger**: *Security Critical*: Never store passwords as plain text or use weak hashing like MD5/SHA-1. Always use bcrypt or Argon2 with appropriate cost factors.

## Formula Reference

Grist formulas use Python syntax. Here are common patterns for Grist Managers:

### Basic Operators

```python
# Arithmetic
$price * $quantity
$total - $discount
$amount / $count
$base_price * 1.1  # 10% markup

# Comparison
$price > 100
$quantity >= $minimum_stock
$status == "approved"
$date < NOW()

# Logical
$active and $verified
$is_admin or $is_manager
not $deleted

# String operations
$first_name + " " + $last_name
$email.lower()
$text.strip()
len($description)
```

### Conditional Expressions

```python
# If-else
"Active" if $active else "Inactive"

# Ternary with conditions
"High" if $price > 100 else "Medium" if $price > 50 else "Low"

# Null handling
$value if $value else 0
$name or "Unknown"
```

### Date/Time Functions

```python
import datetime

# Current date/time
NOW()  # Current datetime
TODAY()  # Current date (no time)

# Date arithmetic
$due_date - datetime.timedelta(days=7)  # 7 days before due
$created_at + datetime.timedelta(hours=24)  # 24 hours after

# Date components
$date.year
$date.month
$date.day
$datetime.hour
$datetime.minute

# Days between dates
(TODAY() - $start_date).days

# Format dates
$date.strftime('%Y-%m-%d')
$datetime.strftime('%Y-%m-%d %H:%M:%S')
```

### Lookups and References

```python
# Get referenced value
$user_id.email  # Email from referenced user
$category_id.name  # Name from referenced category

# Lookup records
Users.lookupOne(email=$email)  # Find one user by email
Orders.lookupRecords(user_id=$id)  # Find all orders for this user

# Count related records
len(Orders.lookupRecords(user_id=$id))

# Sum related records
sum(OrderItems.lookupRecords(order_id=$id).amount)

# Filter and count
len([o for o in Orders.lookupRecords(user_id=$id) if o.status == "completed"])
```

### String Functions

```python
# Case conversion
$text.upper()  # UPPERCASE
$text.lower()  # lowercase
$text.title()  # Title Case

# Trimming
$text.strip()  # Remove leading/trailing whitespace
$text.lstrip()  # Remove leading whitespace
$text.rstrip()  # Remove trailing whitespace

# Searching
$email.startswith("admin")
$text.endswith(".com")
"@" in $email

# Replacing
$text.replace("old", "new")

# Splitting
$full_name.split(" ")  # Split by space
```

### Math Functions

```python
import math

# Rounding
round($price, 2)  # Round to 2 decimal places
math.floor($value)  # Round down
math.ceil($value)  # Round up

# Min/Max
max($price1, $price2, $price3)
min($value1, $value2)

# Absolute value
abs($difference)

# Power
math.pow($base, $exponent)
$number ** 2  # Square

# Square root
math.sqrt($value)
```

### List Operations

```python
# Length
len($tags)

# Membership
"urgent" in $tags

# Join
", ".join($tags)

# Filter
[x for x in $items if x > 10]

# Map
[x * 2 for x in $numbers]

# Sum
sum($numbers)

# Max/Min of list
max($values)
min($values)
```

### Validation Formulas

```python
# Email validation
import re
bool(re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', $email or ''))

# Required fields check
bool($field1) and bool($field2) and bool($field3)

# Range validation
$price > 0 and $price < 10000

# Length validation
len($password_hash) == 60  # Bcrypt hash length

# Reference validation
$user_id is not None and $user_id.active
```

### Common Calculated Fields

```python
# Full name
($first_name or '') + ' ' + ($last_name or '')

# Age from birth date
import datetime
today = datetime.date.today()
age = today.year - $birth_date.year
age = age - ((today.month, today.day) < ($birth_date.month, $birth_date.day))
age

# Days until deadline
($due_date - TODAY()).days if $due_date else None

# Order total
sum(OrderItems.lookupRecords(order_id=$id).amount)

# Discount price
$price * (1 - $discount_percent / 100)

# Status badge
{
  'pending': '🟡 Pending',
  'approved': '🟢 Approved',
  'rejected': '🔴 Rejected'
}.get($status, $status)
```

## HTTP Response Codes

| Code | Status | Description |
| --- | --- | --- |
| 200 | OK | Request successful. Data returned in response body. |
| 201 | Created | Record(s) created successfully. New record data returned. |
| 204 | No Content | Request successful (usually DELETE). No response body. |
| 400 | Bad Request | Malformed request. Check JSON syntax and structure. |
| 401 | Unauthorized | Missing, invalid, or expired API key. |
| 403 | Forbidden | Valid API key but insufficient permissions. |
| 404 | Not Found | Document, table, or record doesn't exist. |
| 422 | Unprocessable Entity | Invalid data type or constraint violation. |
| 429 | Too Many Requests | Rate limit exceeded. Retry after delay. |
| 500 | Internal Server Error | Grist server error. Retry or report bug. |
| 502 | Bad Gateway | Proxy/gateway error. Check Grist server status. |
| 503 | Service Unavailable | Grist temporarily unavailable. Retry later. |

## Environment Variables

Recommended environment variables for Grist Manager scripts:

```bash
# Grist instance URL
export GRIST_BASE_URL="https://docs.getgrist.com"

# API authentication
export GRIST_API_KEY="your_api_key_here"

# Document ID
export GRIST_DOC_ID="your_document_id"

# Optional: Organization ID
export GRIST_ORG_ID="your_org_id"

# Optional: Workspace ID
export GRIST_WORKSPACE_ID="your_workspace_id"
```

Store in `~/.bashrc`, `~/.zshrc`, or load from config file:

```bash
# Load from config
source ~/.grist_config
```

> **Warning**: *Security*: Never commit API keys to version control. Use environment variables or secure secret management.

## Common Patterns

### User Authentication Flow

1. *User attempts login* with email and password
2. *App queries Grist* for user by email
3. *App receives* user record with password hash
4. *App verifies* password against hash using bcrypt
5. *If valid and active=true*, grant access
6. *If invalid or active=false*, deny access

### Role-Based Authorization

```dart

if (user.role == 'admin') {
  // Full access
} else if (user.role == 'manager') {
  // Limited admin access
} else {
  // Basic user access
}
```

### Data Validation Pattern

1. *Add validation formula column* (e.g., `is_valid`)
2. *Formula checks* all required fields and constraints
3. *Filter by* `is_valid = false` to find invalid records
4. *Fix or remove* invalid records
5. *Application validates* before sending to Grist

### Safe Schema Migration

1. *Create new column* with desired type
2. *Add formula* to migrate data: `$old_column`
3. *Convert formula to data*
4. *Update app* to use new column
5. *Test thoroughly* in staging
6. *Deploy to production*
7. *After confirmation*, delete old column

## Performance Tips

| Tip | Implementation |
| --- | --- |
| Use filters | Fetch only needed records: `?filter={"active":[true]} |
| Limit results | Add limit parameter: `?limit=100 |
| Cache frequently accessed data | Cache in app memory/storage, refresh periodically |
| Batch operations | Create/update/delete multiple records in one API call |
| Archive old data | Move old records to archive tables |
| Convert formulas to data | Freeze calculated values for better performance |
| Use appropriate data types | Toggle, not Text for booleans. Numeric, not Text for numbers. |
| Minimize complex formulas | Move complex logic to application when possible |

## Security Checklist

- [ ] API keys stored in environment variables (not code)
- [ ] Separate API keys for dev/staging/production
- [ ] Passwords always hashed (bcrypt/Argon2)
- [ ] Users table has `active` flag for account control
- [ ] Regular audit of admin users
- [ ] Access rules configured (if using)
- [ ] HTTPS used for all API calls (not HTTP)
- [ ] API key rotation schedule (quarterly/annually)
- [ ] Backups stored securely
- [ ] Sensitive data not committed to version control

## Limits and Quotas

Grist hosted service typical limits (check current plan):

| Resource | Limit | Notes |
| --- | --- | --- |
| Document size | Varies by plan | Free tier: limited, paid: larger |
| API rate limit | ~100 req/min | Per API key, may vary |
| Attachment storage | Varies by plan | Counts toward total storage |
| Users per document | Unlimited | Performance may degrade with many users |
| Tables per document | Unlimited | Practical limit ~100 tables |
| Records per table | Unlimited | Performance degrades >100,000 records |
| Columns per table | ~500 | Practical limit, performance consideration |

Self-hosted Grist: Limits depend on your infrastructure.

## Useful Regular Expressions

For validation formulas:

```python
import re

# Email validation
re.match(r'^[\w\.-]+@[\w\.-]+\.\w+$', $email)

# Phone (US format)
re.match(r'^\d{3}-\d{3}-\d{4}$', $phone)

# URL validation
re.match(r'^https?://[\w\.-]+\.\w+', $url)

# Postal code (US ZIP)
re.match(r'^\d{5}(-\d{4})?$', $zip)

# Alphanumeric only
re.match(r'^[a-zA-Z0-9]+$', $code)
```

## Glossary

| Term | Definition |
| --- | --- |
| API Key | Authentication token for accessing Grist API programmatically |
| bcrypt | Password hashing algorithm. Industry standard for secure password storage |
| Choice Column | Column type with predefined list of allowed values (dropdown) |
| Document | Top-level Grist container, similar to a database. Contains multiple tables |
| Document ID | Unique identifier for a Grist document, found in URL |
| Field | A value in a record. Synonym for column value |
| Formula Column | Column with calculated values based on Python formula |
| Password Hash | One-way encrypted representation of a password. Cannot be reversed |
| Record | A single row in a table. Contains values for each column |
| Record ID | Unique numeric identifier for a record. Auto-generated by Grist |
| Reference Column | Column that links to records in another table (foreign key) |
| Role | User permission level (e.g., admin, manager, user) |
| Schema | Structure of database: tables, columns, types, relationships |
| Table | Collection of records with defined columns. Similar to database table |
| Toggle Column | Boolean column type (true/false, yes/no) |

## Additional Resources

*Official Grist Resources:*
- Grist Documentation: https://support.getgrist.com
- Grist API Reference: https://support.getgrist.com/api
- Grist Community: https://community.getgrist.com
- Grist GitHub: https://github.com/gristlabs/grist-core

*FlutterGristAPI Resources:*
- Project repository and documentation
- Community forums and Discord
- Example applications
- Issue tracker for bugs and features

*Learning Resources:*
- Python basics (for formulas)
- Database design principles
- REST API concepts
- bcrypt and password security
- JSON format and structure

> **Success**: *Bookmark this reference*: Keep it handy for quick lookups while managing your Grist databases!
