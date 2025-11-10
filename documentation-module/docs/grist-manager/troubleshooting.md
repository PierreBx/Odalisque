# Troubleshooting Guide

This section helps you diagnose and resolve common issues encountered when managing Grist databases for FlutterGristAPI.

## API Connection Issues

### Error: 401 Unauthorized

*Symptoms:*
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing API key"
}
```

*Possible causes:*
- API key is incorrect or expired
- API key not included in request header
- API key has extra spaces or characters

*Solutions:*

1. *Verify API key:*
   ```bash
   echo $GRIST_API_KEY
   # Should output your key without extra spaces
   ```

2. *Check header format:*
   ```bash
   # Correct format:
   curl -H "Authorization: Bearer YOUR_API_KEY" ...

   # Not: "Bearer: YOUR_API_KEY"
   # Not: "Token YOUR_API_KEY"
   ```

3. *Regenerate API key:*
   - Go to Grist → Profile Settings → API
   - Revoke old key
   - Create new key
   - Update environment variable

4. *Test with simple request:*
   ```bash
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        https://docs.getgrist.com/api/orgs
   ```

> **Warning**: *Security*: Never share API keys in error reports or public forums. Regenerate if accidentally exposed.

### Error: 403 Forbidden

*Symptoms:*
```json
{
  "error": "Forbidden",
  "message": "Access denied"
}
```

*Possible causes:*
- API key doesn't have access to the document
- Document permissions don't allow API access
- Trying to access a document that doesn't exist

*Solutions:*

1. *Check document access:*
   - Open Grist web interface
   - Navigate to the document
   - Click Share button
   - Verify your account has "Owner" or "Editor" access

2. *Verify document ID:*
   ```bash
   # Check URL: https://docs.getgrist.com/doc/YOUR_DOC_ID
   # Make sure YOUR_DOC_ID matches what's in your config
   echo $GRIST_DOC_ID
   ```

3. *Test with a different document:*
   - Create a test document
   - Note its ID
   - Try API call with test document

### Error: 404 Not Found

*Symptoms:*
```json
{
  "error": "Not Found",
  "message": "Document not found"
}
```

*Possible causes:*
- Document ID is incorrect
- Document was deleted
- Table name is wrong

*Solutions:*

1. *Verify document exists:*
   - Open Grist web interface
   - Look for the document in your workspace

2. *Check document ID:*
   ```bash
   # From URL: https://docs.getgrist.com/doc/abcd1234efgh5678
   # Document ID is: abcd1234efgh5678
   ```

3. *List accessible documents:*
   ```bash
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        https://docs.getgrist.com/api/orgs/$ORG_ID/workspaces
   ```

4. *Check table name:*
   ```bash
   # List all tables in document
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables

   # Table names are case-sensitive: "Users" ≠ "users"
   ```

### Error: Connection Timeout

*Symptoms:*
- Request hangs and eventually times out
- No response after 30+ seconds

*Possible causes:*
- Grist server is down
- Network connectivity issues
- Firewall blocking requests
- Very large response taking too long

*Solutions:*

1. *Check Grist status:*
   - Visit https://status.getgrist.com (for hosted Grist)
   - Or check your self-hosted server status

2. *Test basic connectivity:*
   ```bash
   ping docs.getgrist.com
   curl -I https://docs.getgrist.com
   ```

3. *Check firewall/proxy:*
   ```bash
   # Test with verbose output
   curl -v -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID
   ```

4. *Reduce response size:*
   ```bash
   # Add limit parameter for large tables
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?limit=10"
   ```

5. *Increase timeout:*
   ```bash
   curl --max-time 60 \
        -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records
   ```

## Schema Issues

### Users Table Not Working with FlutterGristAPI

*Symptoms:*
- Authentication fails
- Error: "Users table not found" or "Invalid user schema"

*Required Users table structure:*

| Column | Type | Required |
| --- | --- | --- |
| email | Text | ✓ |
| password_hash | Text | ✓ |
| role | Text or Choice | ✓ |
| active | Toggle | ✓ |

*Solutions:*

1. *Verify table name:*
   - Must be exactly "Users" (capital U)
   - Not "User", "users", or "USERS"

2. *Check column names:*
   ```bash
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/columns
   ```

   Required columns must exist with exact names

3. *Verify column types:*
   - `email`: Text (not Email type)
   - `password_hash`: Text
   - `role`: Text or Choice
   - `active`: Toggle (not Text with "true"/"false")

4. *Check for data:*
   ```bash
   # Ensure at least one user exists
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records
   ```

### Column Type Mismatch

*Symptoms:*
```json
{
  "error": "Invalid value for column type",
  "details": "Expected Numeric, got Text"
}
```

*Possible causes:*
- Trying to insert text into a numeric column
- Date format doesn't match expected format
- Boolean value sent as string

*Solutions:*

1. *Check data types in request:*
   ```json
   // Correct:
   {"price": 29.99}           // Number, not string
   {"active": true}           // Boolean, not "true"
   {"created_at": "2024-11-10T14:30:00.000Z"}  // ISO date

   // Incorrect:
   {"price": "29.99"}         // String
   {"active": "true"}         // String
   {"created_at": "11/10/2024"}  // Wrong format
   ```

2. *Fix column types in Grist:*
   - Open table in web interface
   - Click column header → Column Options
   - Change to correct type
   - Existing data will attempt to convert (may lose data)

3. *Clean data before import:*
   - Convert strings to numbers: `parseFloat("29.99")`
   - Parse dates: `new Date("2024-11-10").toISOString()`
   - Convert booleans: `value === "true"` or `!!value`

### Reference Column Not Working

*Symptoms:*
- Can't set reference value
- Reference displays as number instead of referenced value
- Error: "Referenced record not found"

*Solutions:*

1. *Verify target table exists:*
   ```bash
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables
   ```

2. *Check reference configuration:*
   - Open column options in Grist
   - Verify "Reference" type
   - Check target table is correct
   - Verify "Show Column" is set

3. *Use record ID, not display value:*
   ```json
   // Correct:
   {"user_id": 42}            // Record ID from Users table

   // Incorrect:
   {"user_id": "john@example.com"}  // Email address (display value)
   ```

4. *Ensure referenced record exists:*
   ```bash
   # Check if user with ID 42 exists
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records/42
   ```

## Data Issues

### Duplicate Records

*Symptoms:*
- Same email appears multiple times in Users table
- Duplicate product names
- Multiple identical records

*Solutions:*

1. *Find duplicates via export:*
   ```bash
   # Export to CSV
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
        | jq -r '.records[] | .fields.email' | sort | uniq -d
   ```

2. *Delete duplicates via web interface:*
   - Filter table by duplicated value
   - Sort by ID (keep oldest or newest)
   - Select and delete unwanted duplicates

3. *Prevent future duplicates in application:*
   ```dart
   // Check for existing email before creating user
   final existing = await grist.findUserByEmail(email);
   if (existing != null) {
     throw Exception('User with this email already exists');
   }
   ```

### Invalid Password Hashes

*Symptoms:*
- Users can't log in despite correct password
- Error: "Invalid password hash"

*Solutions:*

1. *Verify hash format:*
   ```bash
   # Bcrypt hash starts with $2b$ or $2a$
   # Length: 60 characters
   # Example: $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU7t8dVXLWVu
   ```

2. *Check for truncated hashes:*
   - Grist Text columns can hold 32,000 characters
   - Hash should be 60 characters
   - If shorter, column might have been truncated during import

3. *Test hash with known password:*
   ```python
   import bcrypt

   hash = b"$2b$12$..."  # Hash from database
   password = b"test_password"

   if bcrypt.checkpw(password, hash):
       print("Hash is valid")
   else:
       print("Hash is invalid")
   ```

4. *Regenerate hash if invalid:*
   ```bash
   # Generate new hash
   NEW_HASH=$(python3 -c "import bcrypt; print(bcrypt.hashpw(b'new_password', bcrypt.gensalt(rounds=12)).decode())")

   # Update in Grist
   curl -X PATCH \
     $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
     -H "Authorization: Bearer $GRIST_API_KEY" \
     -H "Content-Type: application/json" \
     -d "{\"records\":[{\"id\":42,\"fields\":{\"password_hash\":\"$NEW_HASH\"}}]}"
   ```

### Missing or Null Values

*Symptoms:*
- Required fields are empty
- Application crashes due to null values
- Data integrity errors

*Solutions:*

1. *Find records with missing values:*
   ```bash
   # Via web interface:
   # - Add filter: "email" is empty
   # - Review and fix records
   ```

2. *Add validation formulas:*
   ```python
   # Add column "is_valid"
   bool($email) and bool($password_hash) and bool($role)
   ```

3. *Filter invalid records:*
   - Filter where `is_valid = false`
   - Fix or delete invalid records

4. *Prevent in application:*
   ```dart
   // Validate before sending to Grist
   if (email.isEmpty || passwordHash.isEmpty || role.isEmpty) {
     throw ValidationException('Required fields missing');
   }
   ```

### Date/Time Issues

*Symptoms:*
- Dates display incorrectly
- Timezone problems
- Date parsing errors

*Solutions:*

1. *Use ISO 8601 format:*
   ```json
   // Correct:
   {"created_at": "2024-11-10T14:30:00.000Z"}

   // Incorrect:
   {"created_at": "11/10/2024"}
   {"created_at": "2024-11-10"}  // Missing time
   ```

2. *Always use UTC:*
   ```dart
   // Flutter/Dart
   final now = DateTime.now().toUtc().toIso8601String();
   ```

3. *Fix existing date columns:*
   - Create new DateTime column
   - Add formula to parse old format
   - Convert formula to data
   - Delete old column

## Performance Issues

### Slow API Responses

*Symptoms:*
- API calls take 5+ seconds
- Application feels sluggish
- Timeouts on mobile devices

*Solutions:*

1. *Use pagination:*
   ```bash
   # Instead of fetching all records:
   curl "$GRIST_BASE_URL/.../tables/Orders/records"

   # Fetch in batches:
   curl "$GRIST_BASE_URL/.../tables/Orders/records?limit=100"
   ```

2. *Apply filters:*
   ```bash
   # Only fetch what you need
   curl "$GRIST_BASE_URL/.../tables/Orders/records?filter=%7B%22status%22%3A%5B%22pending%22%5D%7D"
   ```

3. *Optimize formulas:*
   - Convert complex formula columns to data
   - Simplify calculations
   - Move logic to application when possible

4. *Archive old data:*
   - Move old records to separate archive table
   - Keep main tables smaller and faster

5. *Cache in application:*
   ```dart
   // Cache frequently accessed data
   final cachedUsers = await cache.get('users') ?? await fetchUsers();
   ```

### Large Database Size

*Symptoms:*
- Document becomes slow to open
- Exports take a long time
- Storage limits reached

*Solutions:*

1. *Check document size:*
   - Export as SQLite
   - Check file size

2. *Archive old records:*
   - Create archive tables
   - Move records older than X months
   - Keep main tables lean

3. *Optimize attachments:*
   - Attachments consume significant space
   - Consider external storage (S3, Cloudinary)
   - Compress images before uploading

4. *Clean up test data:*
   ```bash
   # Delete test records
   # Filter for test emails, old records, etc.
   ```

## Import/Export Issues

### CSV Import Fails

*Symptoms:*
- Import appears to succeed but no data appears
- Error: "Invalid CSV format"
- Data appears in wrong columns

*Solutions:*

1. *Check CSV encoding:*
   - Must be UTF-8
   - Not UTF-16, ISO-8859-1, or other encodings

   ```bash
   iconv -f ISO-8859-1 -t UTF-8 input.csv > output.csv
   ```

2. *Verify CSV structure:*
   - First row must be headers
   - Headers must match column names exactly
   - No extra commas or special characters in headers

3. *Check for delimiter issues:*
   - Standard CSV uses commas
   - Some systems use semicolons or tabs
   - Open in text editor to verify

4. *Remove problematic characters:*
   - Line breaks within fields (use quotes)
   - Special characters
   - Null bytes

5. *Simplify and retry:*
   - Import 10 rows first as a test
   - Gradually increase batch size

### Export Contains Unexpected Data

*Symptoms:*
- Exported CSV has wrong values
- Reference columns show IDs instead of names
- Calculated columns missing

*Solutions:*

1. *Reference columns:*
   - Grist exports the ID by default
   - Displayed value (email, name) not exported
   - Solution: Create formula columns with referenced values

   ```python
   # In Orders table, add column "user_email"
   $user_id.email if $user_id else None
   ```

2. *Formula columns:*
   - Convert formulas to data before exporting
   - Column → "Convert column to data"

3. *Hidden columns:*
   - Unhide columns before export
   - Column options → Uncheck "Hide column"

## Authentication Issues

### Users Can't Log In

*Symptoms:*
- Correct credentials but login fails
- Error: "Invalid email or password"

*Troubleshooting checklist:*

1. *Verify user exists:*
   ```bash
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        "$GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records?filter=%7B%22email%22%3A%5B%22user@example.com%22%5D%7D"
   ```

2. *Check user is active:*
   ```json
   // Response should have:
   {
     "fields": {
       "active": true  // Must be true
     }
   }
   ```

3. *Verify password hash:*
   - Should be 60 characters
   - Should start with `$2b$` or `$2a$`

4. *Test password hash:*
   ```python
   import bcrypt

   password = b"user_password"
   hash_from_db = b"$2b$12$..."

   if bcrypt.checkpw(password, hash_from_db):
       print("Password is correct")
   else:
       print("Password is incorrect - hash may be invalid")
   ```

5. *Check email case sensitivity:*
   - Database: `John@Example.com`
   - Login attempt: `john@example.com`
   - Solution: Normalize to lowercase in app

   ```dart
   final normalizedEmail = email.trim().toLowerCase();
   ```

### Role-Based Access Not Working

*Symptoms:*
- All users have same permissions regardless of role
- Admin users can't access admin features

*Solutions:*

1. *Verify role values:*
   ```bash
   # Check what roles exist
   curl -H "Authorization: Bearer $GRIST_API_KEY" \
        $GRIST_BASE_URL/api/docs/$GRIST_DOC_ID/tables/Users/records \
        | jq '.records[].fields.role' | sort | uniq
   ```

2. *Check for typos:*
   - "admin" vs "Admin" vs "ADMIN"
   - Extra spaces: "admin " vs "admin"

3. *Standardize roles:*
   - Make `role` a Choice column
   - Predefined values: admin, manager, user
   - Prevents typos

4. *Verify app logic:*
   ```dart
   // Case-insensitive comparison
   if (user.role.toLowerCase() == 'admin') {
     // Grant admin access
   }
   ```

## Grist Web Interface Issues

### Can't See Document

*Solutions:*
1. Check if you're logged into correct account
2. Verify document wasn't deleted
3. Check workspace permissions
4. Contact workspace owner for access

### Changes Not Saving

*Solutions:*
1. Check internet connection
2. Look for error messages in browser console (F12)
3. Refresh page and retry
4. Try different browser
5. Clear browser cache

### Formula Errors

*Symptoms:*
```
Error: NameError: name 'fieldname' is not defined
```

*Solutions:*
1. Check column name spelling
2. Use `$column_name` syntax for current record
3. Verify referenced table exists
4. Check Python syntax (formulas use Python)

## Getting Help

When you need additional support:

### Information to Gather

Before seeking help, collect:

1. *Error messages* (exact text)
2. *API response* (if API issue)
3. *Request details* (method, URL, headers, body)
4. *Grist document structure* (table/column names)
5. *Steps to reproduce*

### Grist Community Resources

- *Official Docs*: https://support.getgrist.com
- *Community Forum*: https://community.getgrist.com
- *GitHub Issues*: https://github.com/gristlabs/grist-core/issues
- *Discord*: Grist community Discord server

### FlutterGristAPI Support

- *Documentation*: Check other sections of this guide
- *GitHub*: FlutterGristAPI repository issues
- *Community*: FlutterGristAPI community channels

> **Note**: *Pro Tip*: Before posting questions, search existing issues and forum posts. Many common problems have already been solved!

## Preventive Measures

Avoid issues before they happen:

### Regular Maintenance

- [ ] Weekly backup of Grist documents
- [ ] Monthly review of user accounts (deactivate old accounts)
- [ ] Quarterly data integrity checks
- [ ] Annual schema review and optimization

### Best Practices

- [ ] Test all changes in development environment first
- [ ] Document schema changes
- [ ] Use version control for scripts
- [ ] Monitor API usage and performance
- [ ] Keep API keys secure and rotated

### Monitoring

Set up alerts for:
- Failed login attempts (potential security issue)
- API errors (application problems)
- Unusually high API usage (performance or abuse)
- Large data imports (verify intentional)

> **Success**: *Prevention is better than cure*: Many issues can be avoided with proper planning, testing, and documentation.
