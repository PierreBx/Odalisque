# User Management

Managing users is one of the most critical responsibilities of a Grist Manager. The Users table is the foundation of authentication and authorization in FlutterGristAPI applications.

## Users Table Requirements

FlutterGristAPI requires a specific Users table structure for authentication to work:

### Required Columns

| Column | Type | Description | Example |
| --- | --- | --- | --- |
| email | Text | User's login email address (must be unique) | user@example.com |
| password_hash | Text | Hashed password using bcrypt or Argon2 | $2b$12$abc...xyz |
| role | Text or Choice | User's role for authorization | admin`, `manager`, `user |
| active | Toggle | Whether user can log in | true` or `false |

> **Danger**: *Critical Security Rule*: NEVER store plain-text passwords in the `password_hash` column. Always use properly hashed passwords. FlutterGristAPI handles this automatically when creating users through the API.

### Recommended Additional Columns

| Column | Type | Description |
| --- | --- | --- |
| full_name | Text | User's display name for the application UI |
| created_at | DateTime | When the user account was created |
| updated_at | DateTime | When the user record was last modified |
| last_login | DateTime | When the user last successfully logged in |
| phone | Text | Contact phone number (optional) |
| profile_picture | Attachments | User's avatar or profile photo |
| email_verified | Toggle | Whether email address has been verified |
| two_factor_enabled | Toggle | Whether 2FA is enabled for this user |
| notes | Text | Admin notes about the user (not visible to user) |

### Example Users Table Structure

Your complete Users table might look like this:

```
+----+------------------+------------------+--------+--------+--------------+
| ID | email            | password_hash    | role   | active | full_name    |
+----+------------------+------------------+--------+--------+--------------+
| 1  | admin@app.com    | $2b$12$LQv3c... | admin  | true   | Admin User   |
| 2  | john@example.com | $2b$12$9kFxP... | user   | true   | John Doe     |
| 3  | jane@example.com | $2b$12$XpLm2... | manager| true   | Jane Smith   |
| 4  | old@example.com  | $2b$12$Yzq8n... | user   | false  | Old User     |
+----+------------------+------------------+--------+--------+--------------+
```

## Adding Users

### Method 1: Via Grist Web Interface (Manual)

For adding users manually (e.g., initial admin user):

1. *Open your Grist document*
   - Navigate to the Users table

2. *Click "+ Add Row"*
   - A new empty row appears

3. *Fill in required fields:*
   - *email*: Enter the user's email address
   - *password_hash*: Enter a pre-hashed password (see hashing section below)
   - *role*: Select or type the user's role
   - *active*: Check the toggle to enable the account
   - *full_name*: (Optional) Enter the user's display name

4. *Press Enter or click outside*
   - The record is saved immediately

> **Warning**: *Manual password hashing*: When adding users manually via the web interface, you must hash passwords yourself before entering them. See the "Password Hashing" section below.

### Method 2: Via API (Programmatic)

For adding users programmatically (recommended for applications):

*Using curl:*

```bash
curl -X POST \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "email": "newuser@example.com",
          "password_hash": "$2b$12$abcdefghijklmnopqrstuvwxyz",
          "role": "user",
          "active": true,
          "full_name": "New User",
          "created_at": "2024-11-10T14:30:00.000Z"
        }
      }
    ]
  }'
```

*Response (success):*
```json
{
  "records": [
    {
      "id": 5,
      "fields": {
        "email": "newuser@example.com",
        "password_hash": "$2b$12$abcdefghijklmnopqrstuvwxyz",
        "role": "user",
        "active": true,
        "full_name": "New User",
        "created_at": "2024-11-10T14:30:00.000Z"
      }
    }
  ]
}
```

### Method 3: Via FlutterGristAPI (Application)

The FlutterGristAPI library provides user management functions:

*In your Dart/Flutter application:*

```dart
import 'package:flutter_grist_api/flutter_grist_api.dart';

final grist = GristAPI(
  baseUrl: 'https://docs.getgrist.com',
  apiKey: 'your_api_key',
  documentId: 'your_doc_id',
);

final newUser = await grist.createUser(
  email: 'newuser@example.com',
  password: 'SecurePassword123!',  // Plain text - will be hashed automatically
  role: 'user',
  fullName: 'New User',
);

print('Created user with ID: ${newUser['id']}');
```

> **Success**: *Automatic hashing*: FlutterGristAPI automatically hashes passwords using bcrypt when you call `createUser()`. You provide the plain-text password, and the library handles hashing before storing it in Grist.

## Password Hashing

### Why Hash Passwords?

Password hashing is essential for security:

- *Protects users* if the database is compromised
- *One-way function*: Can't reverse a hash to get the password
- *Salted*: Each hash is unique even for the same password
- *Industry standard*: Required by security best practices and regulations

> **Danger**: *Never store plain-text passwords*. Even in development/testing environments, use proper password hashing. It's a fundamental security requirement.

### Hashing Algorithms

Recommended algorithms for password hashing:

*bcrypt (Recommended):*
- Industry standard for password hashing
- Built-in salt generation
- Adaptive: can increase complexity over time
- Widely supported in most languages

*Argon2 (Also good):*
- Winner of Password Hashing Competition
- More modern than bcrypt
- Better resistance to certain attacks
- Less widely supported (but growing)

*Don't use:*
- MD5 (broken, insecure)
- SHA-1 (deprecated)
- SHA-256 without salt (not designed for passwords)
- Plain SHA-256/SHA-512 (too fast, allows brute force)

### Generating Password Hashes

#### Using Online Tools (For Testing Only)

For initial testing or creating test users:

1. Visit bcrypt generators like:
   - https://bcrypt-generator.com/
   - https://www.browserling.com/tools/bcrypt

2. Enter your password
3. Select rounds (12 is recommended)
4. Copy the generated hash
5. Paste into the `password_hash` field in Grist

*Example:*
- Password: `password123`
- Hash: `$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU7t8dVXLWVu`

> **Warning**: *Testing only*: Online hash generators are fine for development but never use them for production passwords. Use server-side hashing in your application.

#### Using Command Line (Python)

If you have Python installed:

```bash
python3 -c "import bcrypt; print(bcrypt.hashpw(b'your_password', bcrypt.gensalt(rounds=12)).decode())"
```

Replace `your_password` with the actual password.

#### Using Node.js

```bash
node -e "const bcrypt = require('bcryptjs'); console.log(bcrypt.hashSync('your_password', 12));"
```

(Requires bcryptjs: `npm install -g bcryptjs`)

### Verifying Password Hashes

To verify a password against a hash (for testing):

*Python:*
```python
import bcrypt

password = b"password123"
hash = b"$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU7t8dVXLWVu"

if bcrypt.checkpw(password, hash):
    print("Password matches!")
else:
    print("Password does not match.")
```

*Node.js:*
```javascript
const bcrypt = require('bcryptjs');

const password = 'password123';
const hash = '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5NU7t8dVXLWVu';

if (bcrypt.compareSync(password, hash)) {
  console.log('Password matches!');
} else {
  console.log('Password does not match.');
}
```

## User Roles

Roles define what users can do in your application. Design a role system that fits your needs:

### Common Role Patterns

#### Simple Two-Tier

```
- admin: Full system access
- user: Basic access
```

Use when you have simple permission needs.

#### Three-Tier (Recommended)

```
- admin: Full system access, user management, configuration
- manager: Elevated access, can manage content and some users
- user: Basic access to their own data
```

Balances flexibility and simplicity.

#### Multi-Tier Organization

```
- super_admin: Platform-wide access
- org_admin: Organization-level admin
- manager: Department or team manager
- staff: Employee with extended access
- user: Basic end user
- guest: Read-only or trial access
```

Use for complex organizations or multi-tenant applications.

### Setting Up Roles as Choice Column

For better data integrity, make `role` a Choice column:

1. *Open Users table column settings*
   - Click on the `role` column header
   - Select "Column Options"

2. *Change type to Choice*
   - Change "Column Type" from Text to Choice

3. *Add your role values:*
   - Click "Add Choice"
   - Enter role name: `admin`
   - Assign a color (e.g., red for admin)
   - Repeat for: `manager`, `user`, etc.

4. *Save changes*

Now users can only select from predefined roles, preventing typos like "admn" or "usr".

### Role-Based Access in Applications

While Grist stores the roles, your application enforces what each role can do:

*In your Flutter app:*

```dart

if (currentUser.role == 'admin') {
  // Show admin-only features
  showUserManagementScreen();
} else if (currentUser.role == 'manager') {
  // Show manager features
  showContentManagementScreen();
} else {
  // Show basic user features
  showUserDashboard();
}
```

> **Note**: *Grist Access Rules* can also restrict data access at the database level based on roles. See the "Access Control" section below.

## Activating and Deactivating Users

Use the `active` column to control user access without deleting accounts:

### Deactivating a User

*Via Web Interface:*
1. Find the user in the Users table
2. Uncheck the `active` toggle
3. User can no longer log in

*Via API:*

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 4,
        "fields": {
          "active": false
        }
      }
    ]
  }'
```

### Why Deactivate Instead of Delete?

*Advantages of deactivation:*
- Preserves data integrity (references to this user still work)
- Maintains audit trail and history
- Can be reactivated if needed
- Associated records (orders, posts, etc.) remain linked

*When to delete:*
- User explicitly requests account deletion (GDPR, etc.)
- Test accounts that are no longer needed
- Cleaning up after testing

### Bulk Deactivation

To deactivate multiple users at once:

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
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

## Updating User Information

### Update Email Address

> **Warning**: *Changing email*: Since email is used for login, changing it will affect how the user logs in. Communicate this to the user before changing.

*Via API:*

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 5,
        "fields": {
          "email": "newemail@example.com"
        }
      }
    ]
  }'
```

### Update User Role

*Promote user to manager:*

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 5,
        "fields": {
          "role": "manager"
        }
      }
    ]
  }'
```

### Reset Password

To reset a user's password, you need to generate a new hash:

1. *Generate new password hash*
   - Use bcrypt to hash the new password
   - Example hash: `$2b$12$newHashValue...`

2. *Update via API:*

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 5,
        "fields": {
          "password_hash": "$2b$12$newHashValue..."
        }
      }
    ]
  }'
```

> **Note**: *Password reset flow*: Typically, password resets should be handled by your application, not manually by Grist Managers. The app should generate a reset token, email it to the user, and let them set a new password through the app.

## Importing Users in Bulk

For migrating existing users or onboarding many users at once:

### Prepare CSV File

Create a CSV file with user data:

```csv
email,password_hash,role,active,full_name
john@example.com,$2b$12$abc...,user,true,John Doe
jane@example.com,$2b$12$def...,manager,true,Jane Smith
bob@example.com,$2b$12$ghi...,user,true,Bob Johnson
```

> **Warning**: *Hash passwords first*: Before importing, ensure all passwords in the CSV are already hashed. Never import plain-text passwords.

### Import via Grist Web Interface

1. *Open Users table*
2. *Click the three-dot menu* (top-right of table)
3. *Select "Import from file"*
4. *Choose your CSV file*
5. *Map columns*:
   - CSV `email` → Users `email`
   - CSV `password_hash` → Users `password_hash`
   - CSV `role` → Users `role`
   - CSV `active` → Users `active`
   - CSV `full_name` → Users `full_name`
6. *Click "Import"*

### Import via API

For very large imports or automated imports:

```bash
curl -X POST \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "email": "user1@example.com",
          "password_hash": "$2b$12$...",
          "role": "user",
          "active": true,
          "full_name": "User One"
        }
      },
      {
        "fields": {
          "email": "user2@example.com",
          "password_hash": "$2b$12$...",
          "role": "user",
          "active": true,
          "full_name": "User Two"
        }
      }
    ]
  }'
```

*For large datasets*, split into batches of 100-500 records per API call for better performance.

## User Queries and Filtering

### Find User by Email

```bash
curl -X GET \
  "https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records?filter=%7B%22email%22%3A%5B%22john%40example.com%22%5D%7D" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

The filter is URL-encoded JSON: `{"email":["john@example.com"]}`

### Find All Active Admin Users

```bash
curl -X GET \
  "https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records?filter=%7B%22role%22%3A%5B%22admin%22%5D%2C%22active%22%3A%5Btrue%5D%7D" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

Filter: `{"role":["admin"],"active":[true]}`

### List All Inactive Users

```bash
curl -X GET \
  "https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records?filter=%7B%22active%22%3A%5Bfalse%5D%7D" \
  -H "Authorization: Bearer YOUR_API_KEY"
```

## Security Best Practices

### 1. Email Uniqueness

Ensure each email is used only once:

- Check for existing email before creating user
- Handle duplicate email errors gracefully in your app
- Consider making email lowercase before storing

### 2. Strong Password Requirements

Enforce in your application (not Grist):

- Minimum length (e.g., 8 characters)
- Mix of uppercase, lowercase, numbers, symbols
- Reject common/weak passwords
- Prevent reuse of recent passwords

### 3. API Key Protection

- Never expose API keys in client-side code
- Use environment variables for API keys
- Rotate API keys periodically
- Use separate keys for different environments

### 4. Audit Logging

Track user-related activities:

- Add `created_at` timestamp when user is created
- Update `updated_at` when user record changes
- Track `last_login` for activity monitoring
- Log role changes and who made them

### 5. Regular Security Audits

- Review active users monthly
- Check for unusual role assignments
- Verify that ex-employees are deactivated
- Audit who has admin access
- Remove test accounts from production

## Common User Management Tasks

### Task: Add First Admin User

```bash
curl -X POST \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "fields": {
          "email": "admin@yourdomain.com",
          "password_hash": "$2b$12$...",
          "role": "admin",
          "active": true,
          "full_name": "System Administrator",
          "created_at": "2024-11-10T00:00:00.000Z"
        }
      }
    ]
  }'
```

### Task: Promote User to Manager

1. Find the user's ID
2. Update their role:

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 12,
        "fields": {
          "role": "manager"
        }
      }
    ]
  }'
```

### Task: Lock Out Suspicious User

```bash
curl -X PATCH \
  https://docs.getgrist.com/api/docs/YOUR_DOC_ID/tables/Users/records \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "records": [
      {
        "id": 25,
        "fields": {
          "active": false,
          "notes": "Locked due to suspicious activity - 2024-11-10"
        }
      }
    ]
  }'
```

### Task: Clean Up Test Users

Use the web interface to filter and delete:

1. Open Users table
2. Click filter icon
3. Filter where `email` contains "test" or "@test.com"
4. Select all matching rows
5. Right-click → Delete rows

> **Warning**: *Deleting users*: This removes the record permanently. If any other tables reference this user (e.g., Orders.user_id), those references will break. Consider deactivating instead.
