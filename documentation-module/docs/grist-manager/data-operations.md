# Data Operations

As a Grist Manager, you'll frequently need to import, export, transform, and validate data. This section covers essential data operations.

## Importing Data

### Import from CSV

CSV is the most common format for importing data:

#### Via Web Interface

1. *Prepare your CSV file*
   - Ensure headers match your column names
   - Clean data (remove extra spaces, special characters)
   - Save with UTF-8 encoding

2. *Open target table in Grist*
   - Navigate to the table where you want to import

3. *Click the three-dot menu* (top-right)
   - Select "Import from file"

4. *Choose your CSV file*
   - Browse and select your CSV

5. *Map columns*
   - Grist will attempt to auto-map based on header names
   - Verify each mapping is correct
   - Unmapped columns can be skipped or mapped manually

6. *Choose import mode:*
   - *Add new records*: Append to existing data
   - *Replace all data*: Delete existing, import new
   - *Update matching records*: Update based on a key column

7. *Click "Import"*
   - Review the preview
   - Confirm import

*Example CSV for Products:*
```csv
name,description,price,stock_quantity,category,active
Widget A,High-quality widget,29.99,100,Electronics,true
Widget B,Budget widget,19.99,250,Electronics,true
Gadget X,Premium gadget,99.99,50,Gadgets,true
```

#### Via API (Advanced)

For programmatic imports, use the API to create records:

```bash
# Read CSV and convert to JSON (example using jq)
# Then POST to Grist

curl -X POST \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "name": "Widget A",
          "description": "High-quality widget",
          "price": 29.99,
          "stock_quantity": 100,
          "category": "Electronics",
          "active": true
        }
      }
    ]
  }'
```

> **Note**: *Batch imports*: For large datasets, split into batches of 100-500 records per API request for optimal performance and to avoid timeouts.

### Import from Excel

Grist supports importing Excel (.xlsx) files:

1. *Save Excel sheet or export to CSV*
   - If using Excel directly: File → Save As → CSV UTF-8

2. *Follow CSV import steps above*

3. *Alternatively*, import Excel directly:
   - Use Grist's "Import from file" feature
   - Select your .xlsx file
   - Choose which sheet to import
   - Map columns as with CSV

*Excel Tips:*
- Remove formulas before importing (copy → paste values)
- Ensure date columns are formatted consistently
- Check for merged cells (can cause issues)
- Remove empty rows/columns

### Import from Another Grist Document

To copy data between Grist documents:

1. *Open source document*
   - Navigate to the table you want to copy

2. *Select all records*
   - Click the top-left cell to select all
   - Or manually select specific records

3. *Copy records* (Ctrl+C or Cmd+C)

4. *Open destination document*
   - Navigate to target table

5. *Paste records* (Ctrl+V or Cmd+V)
   - Records are inserted as new rows

> **Warning**: *Schema compatibility*: Destination table must have compatible columns (same names and types) for paste to work correctly.

### Import from External Database

For migrating from PostgreSQL, MySQL, MongoDB, etc.:

1. *Export from source database to CSV*

   *PostgreSQL:*
   ```sql
   COPY users TO '/tmp/users.csv' WITH CSV HEADER;
   ```

   *MySQL:*
   ```sql
   SELECT * INTO OUTFILE '/tmp/users.csv'
   FIELDS TERMINATED BY ','
   ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   FROM users;
   ```

2. *Transform data as needed*
   - Hash passwords if migrating users
   - Convert date formats
   - Map foreign keys to Grist references

3. *Import CSV into Grist* (see CSV import above)

### Import Validation

After importing, always verify:

- [ ] Record count matches expected
- [ ] No duplicate records (if uniqueness matters)
- [ ] Data types are correct (numbers as numbers, not text)
- [ ] Dates formatted correctly
- [ ] Boolean values are true/false (not "yes"/"no" text)
- [ ] References link correctly
- [ ] Required fields are populated
- [ ] No unexpected null/empty values

## Exporting Data

### Export to CSV

#### Via Web Interface

1. *Open the table to export*

2. *Click the three-dot menu* (top-right)

3. *Select "Export" → "Export table to CSV"*

4. *Save the file*
   - Choose location
   - File will be named: `TableName.csv`

*The exported CSV includes:*
- All visible columns
- Current filters applied (if any)
- Current sort order

> **Note**: *Filtering before export*: Apply filters to export only specific records. For example, filter `active = true` to export only active users.

#### Via API

To export programmatically:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
     > users_export.json
```

This exports to JSON. To convert to CSV, use a tool like `jq`:

```bash
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
     | jq -r '.records[] | [.id, .fields.email, .fields.role, .fields.active] | @csv' \
     > users.csv
```

### Export Entire Document

To export all tables and structure:

1. *Open document menu* (top-left, click document name)

2. *Select "Download"*

3. *Choose format:*
   - *SQLite*: Complete database file (recommended for backups)
   - *Excel*: All tables in separate sheets
   - *CSV*: ZIP file containing CSVs for each table

> **Success**: *Best practice*: Export entire document as SQLite regularly for backups. Store in secure, versioned location.

### Scheduled Exports (Using External Tools)

For automated daily/weekly backups:

*Using cron + curl (Linux):*

```bash
#!/bin/bash
# backup_grist.sh

DATE=$(date +%Y-%m-%d)
DOC_ID="your_doc_id"
API_KEY="your_api_key"
BACKUP_DIR="/backups/grist"

# Export Users table
curl -H "Authorization: Bearer $API_KEY" \
     "https://docs.getgrist.com/api/docs/$DOC_ID/tables/Users/records" \
     > "$BACKUP_DIR/users_$DATE.json"

# Export Products table
curl -H "Authorization: Bearer $API_KEY" \
     "https://docs.getgrist.com/api/docs/$DOC_ID/tables/Products/records" \
     > "$BACKUP_DIR/products_$DATE.json"

echo "Backup completed: $DATE"
```

*Add to crontab:*
```bash
# Run daily at 2 AM
0 2 * * * /path/to/backup_grist.sh
```

## Bulk Operations

### Bulk Create

Add multiple records in one API call:

```bash
curl -X POST \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {"fields": {"name": "Product A", "price": 10.99}},
      {"fields": {"name": "Product B", "price": 20.99}},
      {"fields": {"name": "Product C", "price": 30.99}}
    ]
  }'
```

*Performance tip:* Batch 100-500 records per request for optimal speed.

### Bulk Update

Update multiple records at once:

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {"id": 10, "fields": {"active": false}},
      {"id": 11, "fields": {"active": false}},
      {"id": 12, "fields": {"active": false}}
    ]
  }'
```

*Use case examples:*
- Deactivate all products in a discontinued category
- Update prices across multiple products
- Mark all old orders as "archived"

### Bulk Delete

Delete multiple records:

```bash
curl -X DELETE \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Products/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [100, 101, 102, 103]
  }'
```

> **Danger**: *Permanent deletion*: Deleted records cannot be recovered unless you have a backup. Consider using an `active` flag instead of deleting.

### Bulk Update via Web Interface

1. *Select multiple rows*
   - Click first row
   - Hold Shift, click last row
   - Or Ctrl/Cmd-click individual rows

2. *Right-click selected rows*

3. *Choose action:*
   - *Copy*: Copy selected records
   - *Paste*: Paste into another table
   - *Delete*: Remove selected records
   - *Duplicate*: Create copies

4. *For bulk field updates:*
   - Select rows
   - Use copy-paste to update a specific column across all selected rows

## Data Validation

### Using Formulas for Validation

Create validation rules using formula columns:

#### Example: Email Format Validation

Add a validation column `email_valid`:

```python
import re
email_pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$'
bool(re.match(email_pattern, $email or ''))
```

This returns `true` if email format is valid, `false` otherwise.

#### Example: Price Range Validation

Add a validation column `price_valid`:

```python
$price > 0 and $price < 10000
```

#### Example: Required Field Check

Add a validation column `is_complete`:

```python
bool($name) and bool($email) and bool($role)
```

Returns `true` only if all required fields are filled.

### Conditional Formatting

Highlight invalid data visually:

1. *Add conditional formatting rule*
   - Select the column to format
   - Click column options
   - Add formula for when to apply formatting

2. *Example: Highlight invalid emails*
   - Select `email` column
   - Add condition: `not $email_valid`
   - Set background color to red

> **Note**: *Validation columns*: Add hidden validation columns to check data integrity. Filter by `is_complete = false` to find invalid records.

### Data Cleaning Tasks

#### Remove Duplicate Records

1. *Export data to CSV*
2. *Use a script or tool to deduplicate*

   *Python example:*
   ```python
   import pandas as pd

   # Read CSV
   df = pd.read_csv('users.csv')

   # Remove duplicates based on email
   df_clean = df.drop_duplicates(subset=['email'], keep='first')

   # Save cleaned data
   df_clean.to_csv('users_clean.csv', index=False)
   ```

3. *Re-import cleaned data*

#### Normalize Text Fields

*Common issues:*
- Extra whitespace: " John Doe "
- Inconsistent capitalization: "john doe", "JOHN DOE"
- Special characters: "John\nDoe"

*Fix using formulas:*

```python
# Trim whitespace
$name.strip()

# Title case for names
$name.strip().title()

# Lowercase for emails
$email.strip().lower()
```

Convert formula to data after fixing:
1. Formula calculates correct value
2. Copy column
3. Paste as values over original column
4. Delete formula column

#### Fix Date Formats

If dates imported as text:

1. *Create new DateTime column*: `date_fixed`
2. *Add formula to parse text dates:*

```python
import datetime
try:
  # Attempt to parse various formats
  datetime.datetime.strptime($date_text, '%Y-%m-%d')
except:
  None
```

3. *Convert to data*
4. *Replace original column*

## Working with Formulas

### Types of Formula Columns

#### Calculated Fields

Compute values from other columns:

*Full name from first and last:*
```python
($first_name or '') + ' ' + ($last_name or '')
```

*Discount price:*
```python
$price * (1 - $discount_percent / 100)
```

*Days since creation:*
```python
import datetime
(datetime.date.today() - $created_at.date()).days
```

#### Lookup Values from Other Tables

Reference data in related tables:

*Get user's email from user_id reference:*
```python
$user_id.email if $user_id else None
```

*Count user's orders:*
```python
len(Orders.lookupRecords(user_id=$id))
```

*Sum of order totals:*
```python
sum(Orders.lookupRecords(user_id=$id).total_amount)
```

#### Conditional Logic

Implement business rules:

*Status badge:*
```python
{
  'pending': '🟡 Pending',
  'approved': '🟢 Approved',
  'rejected': '🔴 Rejected',
  'cancelled': '⚫ Cancelled'
}.get($status, $status)
```

*Tax calculation (conditional rate):*
```python
if $country == 'USA':
  $price * 0.07  # 7% US tax
elif $country == 'UK':
  $price * 0.20  # 20% VAT
else:
  $price * 0.15  # Default 15%
```

### Formula Best Practices

1. *Handle None/null values:*
   ```python
   ($field or 0) + 10  # Use 0 if field is empty
   ```

2. *Use conditional expressions:*
   ```python
   'Yes' if $active else 'No'
   ```

3. *Import modules at top:*
   ```python
   import datetime
   import re
   # Then use them
   ```

4. *Test with sample data first*

5. *Document complex formulas* in a notes field or documentation

### Converting Formulas to Data

When you want to "freeze" calculated values:

1. *Select column with formula*
2. *Click column header → "Convert column to data"*
3. *Confirm*

The calculated values become static data and can now be edited manually.

*Use cases:*
- Price calculations that shouldn't change after order placement
- One-time data transformations
- Performance optimization (complex formulas can slow down large tables)

## Data Integrity Checks

### Regular Audits

Perform these checks regularly:

#### Check for Null Required Fields

*Users table:*
- Filter where `email` is empty
- Filter where `password_hash` is empty
- Filter where `role` is empty

*Products table:*
- Filter where `name` is empty
- Filter where `price` is 0 or empty

#### Check for Duplicates

*Find duplicate emails:*
1. Export to CSV
2. Use spreadsheet or script to find duplicates
3. Resolve in Grist

*Prevention:* Application should check for duplicates before creating records.

#### Verify References

*Find broken references:*
- Records with `user_id` referencing deleted users
- Products referencing non-existent categories

*Solution:* Use Reference columns (not text IDs) to maintain referential integrity automatically.

#### Check Data Ranges

*Invalid values to look for:*
- Negative prices
- Dates in the future (for birth_date)
- Quantities below zero
- Invalid email formats

Create validation columns (as described above) to automatically flag these.

### Data Consistency Rules

Establish and enforce rules:

| Rule | Implementation | Check Method |
| --- | --- | --- |
| Unique emails | Application validates before insert | Export and check for duplicates |
| Valid email format | Validation formula column | Filter where `email_valid = false |
| Active users have login info | Formula: `not $active or ($password_hash and $email) | Filter where validation fails |
| Prices are positive | Application/formula validation | Filter where `price <= 0 |
| References exist | Use Reference columns | Check for blank references |

## Performance Considerations

### Optimizing Large Tables

When tables grow large (10,000+ records):

#### 1. Use Filters and Limits

Don't fetch all records via API:

```bash
# Fetch only first 100 records
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Orders/records?limit=100"
```

```bash
# Fetch records with filter
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Orders/records?filter=%7B%22status%22%3A%5B%22pending%22%5D%7D"
```

#### 2. Archive Old Data

Move old records to archive tables:

*Create `Orders_Archive` table*
- Same structure as `Orders`

*Move old orders:*
1. Filter Orders where `created_at < 2023-01-01`
2. Copy filtered records
3. Paste into `Orders_Archive`
4. Delete from `Orders` (after verifying archive)

#### 3. Minimize Complex Formulas

- Complex formulas slow down large tables
- Convert formulas to data when possible
- Use simpler formulas or calculate in application

#### 4. Batch Operations

- Import/update in batches of 100-500
- Don't send 10,000 records in one API call
- Use pagination for exports

> **Note**: *Grist performance*: Self-hosted Grist can handle larger datasets better with proper hardware. Consider hosting requirements for large databases.

## Backup Strategies

### Manual Backups

*Before major changes:*
1. Export entire document as SQLite
2. Save with descriptive name: `myapp_backup_2024-11-10.grist`
3. Store securely (external drive, cloud storage)

### Automated Backups

*Daily backup script:*

```bash
#!/bin/bash
# daily_backup.sh

DATE=$(date +%Y-%m-%d)
BACKUP_DIR="/backups/grist"
DOC_ID="your_doc_id"

# Download document (requires Grist API)
curl -H "Authorization: Bearer YOUR_API_KEY" \
     "https://docs.getgrist.com/api/docs/$DOC_ID/download" \
     -o "$BACKUP_DIR/backup_$DATE.grist"

# Keep only last 30 days
find $BACKUP_DIR -name "backup_*.grist" -mtime +30 -delete

echo "Backup completed: $DATE"
```

*Schedule with cron:*
```bash
0 1 * * * /path/to/daily_backup.sh
```

### Version Control for Schemas

Track schema changes:

1. *Export document structure*
2. *Commit to Git repository*
3. *Document changes in commit messages*
4. *Tag releases*

This provides a history of schema evolution.

> **Success**: *Backup golden rule*: Test your backups by restoring them. A backup you can't restore is worthless.
