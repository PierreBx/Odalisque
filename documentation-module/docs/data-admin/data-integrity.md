# Data Integrity

## Introduction

Data integrity ensures that data remains accurate, consistent, and reliable throughout its lifecycle. This guide covers validation techniques, consistency checks, referential integrity, corruption detection, and data quality monitoring for FlutterGristAPI applications.

## Data Integrity Fundamentals

### Integrity Dimensions

> **Note**: *Four Pillars of Data Integrity*
>
> 1. *Accuracy* - Data correctly represents reality
> 2. *Consistency* - Data is uniform across systems
> 3. *Completeness* - All required data is present
> 4. *Validity* - Data conforms to defined rules

### Integrity Levels

*Physical Integrity*
- Hardware-level data protection
- File system consistency
- Storage device health
- Checksum verification

*Logical Integrity*
- Data type correctness
- Format validation
- Range constraints
- Business rule compliance

*Entity Integrity*
- Unique identification
- Primary key constraints
- Record completeness

*Referential Integrity*
- Foreign key relationships
- Cross-table consistency
- Cascade rules

## Grist Data Model

### SQLite Database Structure

Grist documents are SQLite databases:

```
Document.grist (SQLite database)
├── _grist_Tables         # Table metadata
├── _grist_Tables_column  # Column definitions
├── _grist_ACLRules       # Access control
├── _grist_Attachments    # File references
├── Table1                # User data table 1
├── Table2                # User data table 2
└── ...                   # Additional tables
```

### Inspecting Grist Data

*Open Grist document with SQLite*:

```bash
# Copy Grist document (don't modify live data)
cp /opt/grist/data/docs/mydoc.grist /tmp/mydoc.grist

# Open with sqlite3
sqlite3 /tmp/mydoc.grist

# List all tables
.tables

# Show table schema
.schema Table1

# View table data
SELECT * FROM Table1 LIMIT 10;

# Exit
.quit
```

*Understanding Grist Schema*:

```sql
-- View table metadata
SELECT id, tableId FROM _grist_Tables;

-- View column definitions
SELECT id, parentId, colId, type, isFormula
FROM _grist_Tables_column
WHERE parentId = 1;  -- Table ID

-- Check for foreign key relationships
SELECT * FROM _grist_Tables_column
WHERE type LIKE 'Ref:%';
```

## Validation Strategies

### Type Validation

Ensure data matches expected types:

```bash
#!/bin/bash
# validate-types.sh

GRIST_DOC="/tmp/mydoc.grist"

sqlite3 "$GRIST_DOC" << 'EOF'
-- Check for invalid numeric values in numeric columns
SELECT 'Invalid numeric values found' as issue,
       COUNT(*) as count
FROM Table1
WHERE typeof(age) != 'integer'
  AND age IS NOT NULL;

-- Check for invalid dates
SELECT 'Invalid dates found' as issue,
       COUNT(*) as count
FROM Table1
WHERE date(created_at) IS NULL
  AND created_at IS NOT NULL;

-- Check email format
SELECT 'Invalid email format' as issue,
       COUNT(*) as count
FROM Table1
WHERE email NOT LIKE '%_@__%.__%'
  AND email IS NOT NULL;
EOF
```

### Range Validation

Check values fall within acceptable ranges:

```bash
#!/bin/bash
# validate-ranges.sh

sqlite3 "$GRIST_DOC" << 'EOF'
-- Check age ranges
SELECT 'Age out of range' as issue,
       id, age
FROM Table1
WHERE age < 0 OR age > 120;

-- Check date ranges
SELECT 'Future dates found' as issue,
       id, event_date
FROM Events
WHERE date(event_date) > date('now');

-- Check negative amounts
SELECT 'Negative amounts found' as issue,
       id, amount
FROM Transactions
WHERE amount < 0
  AND transaction_type = 'payment';
EOF
```

### Completeness Validation

Ensure required fields are populated:

```bash
#!/bin/bash
# validate-completeness.sh

sqlite3 "$GRIST_DOC" << 'EOF'
-- Check for NULL values in required fields
SELECT 'Missing email' as issue,
       id
FROM Users
WHERE email IS NULL OR email = '';

-- Check for empty required relationships
SELECT 'Missing user reference' as issue,
       id
FROM Orders
WHERE user_id IS NULL;

-- Check for incomplete records
SELECT 'Incomplete profiles' as issue,
       COUNT(*) as count
FROM UserProfiles
WHERE first_name IS NULL
   OR last_name IS NULL
   OR email IS NULL;
EOF
```

### Format Validation

Validate data format patterns:

```python
#!/usr/bin/env python3
# validate-formats.py

import sqlite3
import re

def validate_formats(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Email format validation
    cursor.execute("SELECT id, email FROM Users WHERE email IS NOT NULL")
    email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

    invalid_emails = []
    for row in cursor.fetchall():
        user_id, email = row
        if not re.match(email_pattern, email):
            invalid_emails.append((user_id, email))

    if invalid_emails:
        print(f"Found {len(invalid_emails)} invalid emails:")
        for user_id, email in invalid_emails[:10]:
            print(f"  User {user_id}: {email}")

    # Phone number validation
    cursor.execute("SELECT id, phone FROM Users WHERE phone IS NOT NULL")
    phone_pattern = r'^\+?1?\d{9,15}$'

    invalid_phones = []
    for row in cursor.fetchall():
        user_id, phone = row
        if not re.match(phone_pattern, phone):
            invalid_phones.append((user_id, phone))

    if invalid_phones:
        print(f"Found {len(invalid_phones)} invalid phone numbers")

    conn.close()

if __name__ == "__main__":
    validate_formats("/tmp/mydoc.grist")
```

## Consistency Checks

### Cross-Table Consistency

Verify related data is consistent across tables:

```sql
-- Check referential integrity
-- Find orders with non-existent users
SELECT 'Orphaned orders' as issue,
       COUNT(*) as count
FROM Orders o
LEFT JOIN Users u ON o.user_id = u.id
WHERE u.id IS NULL;

-- Check bidirectional relationships
-- Users with orders but no order count
SELECT 'Inconsistent order count' as issue,
       u.id,
       u.order_count,
       COUNT(o.id) as actual_count
FROM Users u
LEFT JOIN Orders o ON u.id = o.user_id
GROUP BY u.id
HAVING u.order_count != COUNT(o.id);

-- Check date consistency
-- Orders before user creation
SELECT 'Order before user' as issue,
       o.id as order_id,
       o.created_at as order_date,
       u.created_at as user_date
FROM Orders o
JOIN Users u ON o.user_id = u.id
WHERE date(o.created_at) < date(u.created_at);
```

### Aggregate Consistency

Verify calculated fields match actual values:

```sql
-- Check invoice totals
SELECT 'Invoice total mismatch' as issue,
       i.id,
       i.total as stored_total,
       SUM(li.quantity * li.price) as calculated_total
FROM Invoices i
JOIN LineItems li ON i.id = li.invoice_id
GROUP BY i.id
HAVING ABS(i.total - SUM(li.quantity * li.price)) > 0.01;

-- Check inventory counts
SELECT 'Inventory mismatch' as issue,
       p.id,
       p.stock_count as stored_count,
       (p.initial_stock +
        COALESCE(received.total, 0) -
        COALESCE(sold.total, 0)) as calculated_count
FROM Products p
LEFT JOIN (
    SELECT product_id, SUM(quantity) as total
    FROM Receipts
    GROUP BY product_id
) received ON p.id = received.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) as total
    FROM Sales
    GROUP BY product_id
) sold ON p.id = sold.product_id
WHERE p.stock_count != (p.initial_stock +
    COALESCE(received.total, 0) -
    COALESCE(sold.total, 0));
```

### Duplicate Detection

Find and report duplicate records:

```sql
-- Find duplicate emails
SELECT email,
       COUNT(*) as count,
       GROUP_CONCAT(id) as user_ids
FROM Users
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;

-- Find duplicate records (same data, different ID)
SELECT u1.id as id1,
       u2.id as id2,
       u1.email
FROM Users u1
JOIN Users u2 ON u1.email = u2.email
    AND u1.first_name = u2.first_name
    AND u1.last_name = u2.last_name
    AND u1.id < u2.id;

-- Find near-duplicates (fuzzy matching with Levenshtein)
-- Requires SQLite extension
```

## Referential Integrity

### Understanding Grist References

Grist supports reference columns (`Ref` type):

```
Table: Orders
Columns:
  - id (Integer)
  - user_id (Ref:Users)  # Reference to Users table
  - product_id (Ref:Products)
  - quantity (Integer)
```

### Checking Reference Integrity

```bash
#!/bin/bash
# check-references.sh

GRIST_DOC="$1"

sqlite3 "$GRIST_DOC" << 'EOF'
-- Get all reference columns
SELECT t.tableId,
       c.colId,
       c.type as ref_type
FROM _grist_Tables_column c
JOIN _grist_Tables t ON c.parentId = t.id
WHERE c.type LIKE 'Ref:%';
EOF

# Then manually check each reference
```

### Fixing Broken References

```python
#!/usr/bin/env python3
# fix-broken-refs.py

import sqlite3
import sys

def find_broken_references(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Get reference columns
    cursor.execute("""
        SELECT t.tableId, c.colId, c.type
        FROM _grist_Tables_column c
        JOIN _grist_Tables t ON c.parentId = t.id
        WHERE c.type LIKE 'Ref:%'
    """)

    broken_refs = []

    for table, column, ref_type in cursor.fetchall():
        # Parse reference type: "Ref:TargetTable"
        target_table = ref_type.split(':')[1]

        # Check for broken references
        query = f"""
            SELECT COUNT(*)
            FROM {table} t
            LEFT JOIN {target_table} ref ON t.{column} = ref.id
            WHERE t.{column} IS NOT NULL
              AND ref.id IS NULL
        """

        try:
            cursor.execute(query)
            count = cursor.fetchone()[0]
            if count > 0:
                broken_refs.append({
                    'table': table,
                    'column': column,
                    'target': target_table,
                    'count': count
                })
        except sqlite3.Error as e:
            print(f"Error checking {table}.{column}: {e}")

    conn.close()
    return broken_refs

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: fix-broken-refs.py <grist-doc.grist>")
        sys.exit(1)

    broken = find_broken_references(sys.argv[1])

    if broken:
        print("Broken references found:")
        for ref in broken:
            print(f"  {ref['table']}.{ref['column']} -> {ref['target']}: "
                  f"{ref['count']} broken references")
    else:
        print("No broken references found")
```

## Corruption Detection

### File System Corruption

Check for file system issues:

```bash
#!/bin/bash
# check-filesystem.sh

GRIST_DATA_DIR="/opt/grist/data"

# Check file system errors
dmesg | grep -i "error\|corrupt"

# Run file system check (unmount first!)
# sudo umount /opt/grist
# sudo fsck -n /dev/sdX  # Read-only check

# Check for inode errors
df -i "$GRIST_DATA_DIR"

# Find corrupted files
find "$GRIST_DATA_DIR" -type f -exec file {} \; | grep -i corrupt
```

### SQLite Database Integrity

Check SQLite database health:

```bash
#!/bin/bash
# check-sqlite-integrity.sh

DOCS_DIR="/opt/grist/data/docs"

for doc in "$DOCS_DIR"/*.grist; do
    echo "Checking: $(basename $doc)"

    # Integrity check
    sqlite3 "$doc" "PRAGMA integrity_check;" | \
        grep -v "^ok$" && \
        echo "  ⚠ Issues found" || \
        echo "  ✓ OK"

    # Foreign key check
    sqlite3 "$doc" "PRAGMA foreign_key_check;" | \
        head -5 && \
        echo "  ⚠ Foreign key issues" || \
        echo "  ✓ Foreign keys OK"

    # Quick check
    sqlite3 "$doc" "PRAGMA quick_check;" | \
        grep -v "^ok$"
done
```

### Automated Corruption Scanning

```python
#!/usr/bin/env python3
# scan-corruption.py

import sqlite3
import os
import sys
from pathlib import Path

def check_database_integrity(db_path):
    """Comprehensive database integrity check"""
    issues = []

    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        # 1. Integrity check
        cursor.execute("PRAGMA integrity_check")
        result = cursor.fetchone()[0]
        if result != "ok":
            issues.append(f"Integrity check failed: {result}")

        # 2. Foreign key check
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA foreign_key_check")
        fk_issues = cursor.fetchall()
        if fk_issues:
            issues.append(f"Foreign key violations: {len(fk_issues)}")

        # 3. Check for NULL in system tables
        cursor.execute("""
            SELECT COUNT(*)
            FROM _grist_Tables
            WHERE tableId IS NULL
        """)
        if cursor.fetchone()[0] > 0:
            issues.append("NULL values in system tables")

        # 4. Check for orphaned attachments
        cursor.execute("""
            SELECT COUNT(*)
            FROM _grist_Attachments a
            LEFT JOIN _grist_Tables_column c ON a.id = c.id
            WHERE c.id IS NULL
        """)
        orphaned = cursor.fetchone()[0]
        if orphaned > 0:
            issues.append(f"{orphaned} orphaned attachments")

        conn.close()

    except sqlite3.Error as e:
        issues.append(f"Database error: {e}")

    return issues

def scan_all_documents(data_dir):
    """Scan all Grist documents for corruption"""
    docs_dir = Path(data_dir) / "docs"

    if not docs_dir.exists():
        print(f"Error: {docs_dir} does not exist")
        return

    print(f"Scanning Grist documents in {docs_dir}...")
    print("=" * 60)

    total_docs = 0
    corrupted_docs = 0

    for doc_file in docs_dir.glob("*.grist"):
        total_docs += 1
        print(f"\nChecking: {doc_file.name}")

        issues = check_database_integrity(doc_file)

        if issues:
            corrupted_docs += 1
            print("  ⚠ ISSUES FOUND:")
            for issue in issues:
                print(f"    - {issue}")
        else:
            print("  ✓ OK")

    print("\n" + "=" * 60)
    print(f"Summary: {corrupted_docs}/{total_docs} documents have issues")

    return corrupted_docs == 0

if __name__ == "__main__":
    data_dir = sys.argv[1] if len(sys.argv) > 1 else "/opt/grist/data"
    success = scan_all_documents(data_dir)
    sys.exit(0 if success else 1)
```

## Data Quality Monitoring

### Quality Metrics

Define and track data quality metrics:

```python
#!/usr/bin/env python3
# quality-metrics.py

import sqlite3
from datetime import datetime

def calculate_quality_metrics(db_path):
    """Calculate data quality metrics"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    metrics = {}

    # 1. Completeness - % of non-NULL values
    cursor.execute("""
        SELECT
            COUNT(*) as total,
            COUNT(email) as has_email,
            COUNT(phone) as has_phone,
            COUNT(address) as has_address
        FROM Users
    """)
    row = cursor.fetchone()
    total = row[0]
    if total > 0:
        metrics['completeness'] = {
            'email': (row[1] / total) * 100,
            'phone': (row[2] / total) * 100,
            'address': (row[3] / total) * 100,
        }

    # 2. Validity - % of valid format
    cursor.execute("""
        SELECT COUNT(*) FROM Users
        WHERE email LIKE '%_@__%.__%'
    """)
    valid_emails = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM Users WHERE email IS NOT NULL")
    total_emails = cursor.fetchone()[0]
    if total_emails > 0:
        metrics['validity'] = {
            'email': (valid_emails / total_emails) * 100
        }

    # 3. Consistency - % matching relationships
    cursor.execute("""
        SELECT COUNT(*) FROM Orders o
        JOIN Users u ON o.user_id = u.id
    """)
    consistent_orders = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM Orders")
    total_orders = cursor.fetchone()[0]
    if total_orders > 0:
        metrics['consistency'] = {
            'orders': (consistent_orders / total_orders) * 100
        }

    # 4. Timeliness - % of recent updates
    cursor.execute("""
        SELECT COUNT(*) FROM Users
        WHERE datetime(last_updated) > datetime('now', '-30 days')
    """)
    recent_updates = cursor.fetchone()[0]
    if total > 0:
        metrics['timeliness'] = {
            'recent_updates': (recent_updates / total) * 100
        }

    conn.close()
    return metrics

def generate_quality_report(metrics):
    """Generate HTML quality report"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    html = f"""
    <html>
    <head><title>Data Quality Report</title></head>
    <body>
        <h1>Data Quality Report</h1>
        <p>Generated: {timestamp}</p>

        <h2>Completeness</h2>
        <ul>
    """

    for field, score in metrics.get('completeness', {}).items():
        status = "✓" if score >= 95 else "⚠" if score >= 80 else "✗"
        html += f"<li>{status} {field}: {score:.1f}%</li>\n"

    html += """
        </ul>
        <h2>Validity</h2>
        <ul>
    """

    for field, score in metrics.get('validity', {}).items():
        status = "✓" if score >= 95 else "⚠" if score >= 80 else "✗"
        html += f"<li>{status} {field}: {score:.1f}%</li>\n"

    html += """
        </ul>
    </body>
    </html>
    """

    with open('/var/www/html/quality-report.html', 'w') as f:
        f.write(html)

    print(f"Report generated: /var/www/html/quality-report.html")

if __name__ == "__main__":
    metrics = calculate_quality_metrics("/tmp/mydoc.grist")
    print("Quality Metrics:")
    for category, scores in metrics.items():
        print(f"\n{category.upper()}:")
        for field, score in scores.items():
            print(f"  {field}: {score:.1f}%")

    generate_quality_report(metrics)
```

### Continuous Monitoring

Set up automated quality monitoring:

```bash
#!/bin/bash
# monitor-quality.sh

GRIST_DATA="/opt/grist/data"
METRICS_LOG="/var/log/grist-quality-metrics.log"

# Run quality checks
python3 /opt/scripts/quality-metrics.py "$GRIST_DATA" >> "$METRICS_LOG"

# Alert on quality degradation
QUALITY_SCORE=$(tail -1 "$METRICS_LOG" | grep -oP 'score: \K[0-9.]+')

if (( $(echo "$QUALITY_SCORE < 80" | bc -l) )); then
    echo "Data quality alert: Score = $QUALITY_SCORE%" | \
        mail -s "Data Quality Alert" admin@example.com
fi
```

Schedule with cron:
```cron
# Daily quality monitoring at 6 AM
0 6 * * * /opt/scripts/monitor-quality.sh
```

## Data Repair Procedures

### Fixing NULL Values

```sql
-- Set default values for NULLs
UPDATE Users
SET country = 'Unknown'
WHERE country IS NULL;

-- Copy from related records
UPDATE Orders
SET shipping_address = (
    SELECT address FROM Users WHERE Users.id = Orders.user_id
)
WHERE shipping_address IS NULL;
```

### Removing Duplicates

```sql
-- Delete duplicate emails, keep oldest
DELETE FROM Users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM Users
    GROUP BY email
);
```

### Repairing Checksums

```bash
#!/bin/bash
# repair-checksums.sh

# Regenerate checksums for all backups
for backup in /opt/backups/*/*.tar.gz; do
    echo "Regenerating checksum: $backup"
    cd "$(dirname $backup)"
    sha256sum "$(basename $backup)" > "$(basename $backup).sha256"
done
```

## Best Practices

> **Success**: *Data Integrity Best Practices*
>
> 1. *Validate on Entry* - Catch issues before data is saved
> 2. *Regular Scans* - Daily corruption and consistency checks
> 3. *Automated Alerts* - Immediate notification of issues
> 4. *Document Rules* - Clear data validation rules
> 5. *Audit Logging* - Track all data modifications
> 6. *Backup Before Repair* - Always backup before fixing
> 7. *Test in Staging* - Verify repairs in test environment
> 8. *Monitor Trends* - Track quality metrics over time
