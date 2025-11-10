# Common Commands & API Reference

This section provides quick reference for common Grist operations and API calls. Bookmark this page for daily use!

## Environment Setup

Before using these commands, set environment variables:

```bash
# Set these in your shell profile (~/.bashrc, ~/.zshrc)
export GRIST_API_KEY="your_api_key_here"
export GRIST_BASE_URL="https://docs.getgrist.com"
export GRIST_DOC_ID="your_document_id"
```

Or create a configuration file:

```bash
# ~/.grist_config
GRIST_API_KEY="your_api_key_here"
GRIST_BASE_URL="https://docs.getgrist.com"
GRIST_DOC_ID="your_document_id"
```

Load before using commands:
```bash
source ~/.grist_config
```

## Document Operations

### Get Document Info

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID
```

*Response:*
```json
{
  "id": "your_doc_id",
  "name": "MyFlutterApp",
  "access": "owners",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-11-10T09:00:00.000Z"
}
```

### List All Tables

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables
```

*Response:*
```json
{
  "tables": [
    {
      "id": "Users",
      "fields": {...}
    },
    {
      "id": "Products",
      "fields": {...}
    }
  ]
}
```

### Get Table Schema

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/columns
```

*Response:*
```json
{
  "columns": [
    {
      "id": "email",
      "fields": {
        "type": "Text",
        "label": "Email"
      }
    },
    {
      "id": "role",
      "fields": {
        "type": "Choice",
        "label": "Role"
      }
    }
  ]
}
```

## Record Operations - Users Table

### Create User

*Command:*
```bash
curl -X POST \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "email": "user@example.com",
          "password_hash": "$2b$12$abcd...",
          "role": "user",
          "active": true,
          "full_name": "John Doe"
        }
      }
    ]
  }'
```

*Response:*
```json
{
  "records": [
    {
      "id": 42,
      "fields": {
        "email": "user@example.com",
        "role": "user",
        "active": true,
        "full_name": "John Doe"
      }
    }
  ]
}
```

### Get All Users

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records
```

*With limit:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?limit=10"
```

### Get User by Email

*Command:*
```bash
# Filter: {"email":["user@example.com"]}
# URL-encoded: %7B%22email%22%3A%5B%22user%40example.com%22%5D%7D

curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=%7B%22email%22%3A%5B%22user%40example.com%22%5D%7D"
```

*Helper function to encode filters:*
```bash
# encode_filter.sh
#!/bin/bash
FILTER="$1"
echo -n "$FILTER" | jq -sRr @uri
```

*Usage:*
```bash
ENCODED=$(./encode_filter.sh '{"email":["user@example.com"]}')
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=$ENCODED"
```

### Get Active Users Only

*Command:*
```bash
# Filter: {"active":[true]}
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=%7B%22active%22%3A%5Btrue%5D%7D"
```

### Get Users by Role

*Command:*
```bash
# Filter: {"role":["admin"]}
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=%7B%22role%22%3A%5B%22admin%22%5D%7D"
```

### Get Single User by ID

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records/42
```

### Update User

*Command:*
```bash
curl -X PATCH \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 42,
        "fields": {
          "role": "manager",
          "full_name": "John Doe (Manager)"
        }
      }
    ]
  }'
```

### Deactivate User

*Command:*
```bash
curl -X PATCH \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 42,
        "fields": {
          "active": false
        }
      }
    ]
  }'
```

### Delete User

*Command:*
```bash
curl -X DELETE \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [42]
  }'
```

> **Warning**: *Deletion is permanent*: Consider deactivating users instead of deleting them to preserve data integrity and history.

## Record Operations - Generic Table

Replace `TableName` with your table name (e.g., Products, Orders, etc.):

### Create Record

*Command:*
```bash
curl -X POST \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "field1": "value1",
          "field2": "value2"
        }
      }
    ]
  }'
```

### Get All Records

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records
```

### Get Record by ID

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records/123
```

### Update Record

*Command:*
```bash
curl -X PATCH \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 123,
        "fields": {
          "field1": "new_value"
        }
      }
    ]
  }'
```

### Delete Record

*Command:*
```bash
curl -X DELETE \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [123]
  }'
```

## Bulk Operations

### Bulk Create (Multiple Records)

*Command:*
```bash
curl -X POST \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {"fields": {"name": "Product A", "price": 10.99}},
      {"fields": {"name": "Product B", "price": 20.99}},
      {"fields": {"name": "Product C", "price": 30.99}}
    ]
  }'
```

### Bulk Update (Multiple Records)

*Command:*
```bash
curl -X PATCH \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {"id": 10, "fields": {"active": false}},
      {"id": 11, "fields": {"active": false}},
      {"id": 12, "fields": {"active": false}}
    ]
  }'
```

### Bulk Delete (Multiple Records)

*Command:*
```bash
curl -X DELETE \
  $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [10, 11, 12, 13, 14]
  }'
```

## Filtering and Pagination

### Filter by Single Field

*Get products in "Electronics" category:*
```bash
# Filter: {"category":["Electronics"]}
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Products/records?filter=%7B%22category%22%3A%5B%22Electronics%22%5D%7D"
```

### Filter by Multiple Fields

*Get active admin users:*
```bash
# Filter: {"role":["admin"],"active":[true]}
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=%7B%22role%22%3A%5B%22admin%22%5D%2C%22active%22%3A%5Btrue%5D%7D"
```

### Limit Results

*Get first 50 records:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?limit=50"
```

### Pagination (Limit + Offset)

*Get records 51-100:*
```bash
# Using limit and offset (if supported by Grist version)
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?limit=50"
```

*For manual pagination, keep track of last ID and filter accordingly.*

### Sort Results

*Note: Grist API doesn't directly support sorting in the URL. Sort via web interface or retrieve all records and sort in your script.*

## Useful Helper Scripts

### Pretty Print JSON Response

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     | jq '.'
```

### Save Response to File

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     > users_backup.json
```

### Count Total Records

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     | jq '.records | length'
```

### Extract Specific Fields

*Get only emails and roles:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     | jq '.records[] | {email: .fields.email, role: .fields.role}'
```

### Convert JSON to CSV

*Command:*
```bash
curl -H "Authorization: Bearer $GRIST_API_KEY" \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     | jq -r '.records[] | [.id, .fields.email, .fields.role, .fields.active] | @csv' \
     > users.csv
```

## Complete Script Examples

### Backup All Tables

*Script: `backup_all_tables.sh`*

```bash
#!/bin/bash

# Configuration
source ~/.grist_config

DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_DIR="./backups/$DATE"
mkdir -p "$BACKUP_DIR"

# Get list of tables
TABLES=$(curl -s -H "Authorization: Bearer $GRIST_API_KEY" \
              "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables" \
              | jq -r '.tables[].id')

# Backup each table
for TABLE in $TABLES; do
    echo "Backing up table: $TABLE"
    curl -s -H "Authorization: Bearer $GRIST_API_KEY" \
         "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/$TABLE/records" \
         > "$BACKUP_DIR/${TABLE}.json"
done

echo "Backup completed: $BACKUP_DIR"
```

### Find User by Email

*Script: `find_user.sh`*

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./find_user.sh email@example.com"
    exit 1
fi

source ~/.grist_config

EMAIL="$1"
FILTER=$(echo "{\"email\":[\"$EMAIL\"]}" | jq -sRr @uri)

curl -s -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=$FILTER" \
     | jq '.records[]'
```

*Usage:*
```bash
./find_user.sh john@example.com
```

### Create User from Command Line

*Script: `create_user.sh`*

```bash
#!/bin/bash

if [ $# -lt 4 ]; then
    echo "Usage: ./create_user.sh email password role full_name"
    exit 1
fi

source ~/.grist_config

EMAIL="$1"
PASSWORD="$2"
ROLE="$3"
FULL_NAME="$4"

# Hash password using Python bcrypt
PASSWORD_HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'$PASSWORD', bcrypt.gensalt(rounds=12)).decode())")

# Create user
curl -X POST \
  "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records" \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"records\": [
      {
        \"fields\": {
          \"email\": \"$EMAIL\",
          \"password_hash\": \"$PASSWORD_HASH\",
          \"role\": \"$ROLE\",
          \"active\": true,
          \"full_name\": \"$FULL_NAME\"
        }
      }
    ]
  }" | jq '.'
```

*Usage:*
```bash
./create_user.sh "john@example.com" "SecurePass123" "user" "John Doe"
```

### Deactivate Multiple Users

*Script: `deactivate_users.sh`*

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./deactivate_users.sh user_id1 user_id2 user_id3"
    exit 1
fi

source ~/.grist_config

# Build records array
RECORDS=""
for USER_ID in "$@"; do
    if [ -n "$RECORDS" ]; then
        RECORDS="$RECORDS,"
    fi
    RECORDS="$RECORDS{\"id\":$USER_ID,\"fields\":{\"active\":false}}"
done

curl -X PATCH \
  "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records" \
  -H "Authorization: Bearer $GRIST_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"records\":[$RECORDS]}" | jq '.'
```

*Usage:*
```bash
./deactivate_users.sh 42 43 44
```

### Export to CSV

*Script: `export_table_csv.sh`*

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: ./export_table_csv.sh TableName"
    exit 1
fi

source ~/.grist_config

TABLE_NAME="$1"
OUTPUT_FILE="${TABLE_NAME}_$(date +%Y-%m-%d).csv"

curl -s -H "Authorization: Bearer $GRIST_API_KEY" \
     "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/$TABLE_NAME/records" \
     | jq -r '
       # Get all field names
       (.records[0].fields | keys_unsorted) as $cols |

       # Header row
       $cols,

       # Data rows
       (.records[] | [.fields[]] | @csv)
     ' > "$OUTPUT_FILE"

echo "Exported to: $OUTPUT_FILE"
```

*Usage:*
```bash
./export_table_csv.sh Users
```

## API Response Codes

| Code | Status | Meaning |
| --- | --- | --- |
| 200 | OK | Request successful |
| 201 | Created | Record created successfully |
| 204 | No Content | Delete successful, no content returned |
| 400 | Bad Request | Invalid request format or parameters |
| 401 | Unauthorized | Missing or invalid API key |
| 403 | Forbidden | API key doesn't have permission |
| 404 | Not Found | Document or table doesn't exist |
| 422 | Unprocessable Entity | Invalid data (e.g., wrong type) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Grist server error |

> **Note**: *Error Handling*: Always check the HTTP status code. On error, the response body usually contains a helpful error message in JSON format.

## Quick Reference Card

Keep this handy for daily operations:

| Operation | Command |
| --- | --- |
| List tables | bash
  curl -H "Authorization: Bearer $GRIST_API_KEY" \
       $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables |
| Get all records | bash
  curl -H "Authorization: Bearer $GRIST_API_KEY" \
       $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records |
| Create record | bash
  curl -X POST \
    $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
    -H "Authorization: Bearer $GRIST_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"records":[{"fields":{...}}]}' |
| Update record | bash
  curl -X PATCH \
    $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
    -H "Authorization: Bearer $GRIST_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"records":[{"id":123,"fields":{...}}]}' |
| Delete record | bash
  curl -X DELETE \
    $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/TableName/records \
    -H "Authorization: Bearer $GRIST_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"records":[123]}' |

> **Success**: *Pro Tip*: Save frequently used commands as shell functions in your `.bashrc` or create wrapper scripts for common operations.
