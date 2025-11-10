// Schema Management for Grist Managers

#import "../common/styles.typ": *

= Schema Management

Schema management is at the core of the Grist Manager's responsibilities. A well-designed schema ensures data integrity, performance, and maintainability.

== Understanding Grist Data Types

Grist supports several column types, each suited for different kinds of data:

=== Text
The most flexible type for string data.

*Best for:*
- Names, descriptions, addresses
- Email addresses (before Grist added Email type)
- Free-form text input
- Short or long text content

*Configuration options:*
- None required - just select "Text" as the column type

*Example usage:*
```json
{
  "full_name": "John Doe",
  "bio": "Software developer and coffee enthusiast",
  "address": "123 Main St, Anytown, USA"
}
```

#info_box(type: "info")[
  *Text columns* can store up to 32,000 characters. For longer content, consider splitting into multiple records or using an external storage solution.
]

=== Numeric
For numbers (integers or decimals).

*Best for:*
- Prices, quantities, measurements
- Counters, IDs (when not using built-in record IDs)
- Percentages, ratios
- Currency values

*Configuration options:*
- *Number Format*: Choose decimal places (0-10)
- *Currency*: Enable currency formatting with symbol
- *Percentage*: Display as percentage
- *Scientific*: For very large or small numbers

*Example usage:*
```json
{
  "price": 29.99,
  "quantity": 100,
  "discount_percent": 15.5,
  "weight_kg": 2.5
}
```

#info_box(type: "warning")[
  *Currency Precision*: For financial calculations, use at least 2 decimal places. For cryptocurrencies or precise measurements, use more decimal places as needed.
]

=== Integer
A specialized numeric type for whole numbers only.

*Best for:*
- Counters, votes, ratings
- Age, years
- Quantities that can't be fractional

*Configuration options:*
- Similar to Numeric but without decimal places

*Example usage:*
```json
{
  "age": 35,
  "stock_count": 250,
  "rating": 4
}
```

=== Date
For calendar dates without time information.

*Best for:*
- Birthdays, anniversaries
- Due dates, deadlines
- Event dates

*Configuration options:*
- *Date Format*: Choose how dates display (MM/DD/YYYY, DD/MM/YYYY, etc.)

*Example usage:*
```json
{
  "birth_date": "1990-05-15",
  "due_date": "2024-12-31"
}
```

#info_box(type: "info")[
  *Date format in API*: Dates are always sent/received in ISO format (YYYY-MM-DD) via the API, regardless of display format in the UI.
]

=== DateTime
For timestamps with both date and time.

*Best for:*
- Created/updated timestamps
- Scheduled events
- Login times
- Transaction timestamps

*Configuration options:*
- *Date Format*: How dates display
- *Time Format*: 12-hour or 24-hour
- *Timezone*: Set default timezone

*Example usage:*
```json
{
  "created_at": "2024-11-10T14:30:00.000Z",
  "last_login": "2024-11-10T09:15:22.000Z"
}
```

#info_box(type: "warning")[
  *Timezones*: Always store times in UTC in the database. Convert to local time zones in your application UI. The API sends/receives times in ISO 8601 format with timezone.
]

=== Toggle
Boolean true/false values.

*Best for:*
- Active/inactive status
- Yes/no questions
- Feature flags
- Permissions (enabled/disabled)

*Configuration options:*
- None required - displays as a checkbox

*Example usage:*
```json
{
  "active": true,
  "is_verified": false,
  "has_subscribed": true
}
```

#info_box(type: "info")[
  *Default values*: Toggle columns default to `false` when no value is set. Explicitly set important flags during record creation.
]

=== Choice
Single selection from a predefined list.

*Best for:*
- Status fields (pending, approved, rejected)
- Categories (electronics, clothing, books)
- Priority levels (low, medium, high)
- User roles (admin, manager, user)

*Configuration options:*
- *Choices*: List of allowed values
- *Colors*: Assign colors to each choice for visual distinction

*Example usage:*
```json
{
  "status": "pending",
  "priority": "high",
  "category": "electronics"
}
```

*Setting up choices:*
1. Select "Choice" as column type
2. Click "Add Choice" for each option
3. Type the choice value (e.g., "pending")
4. Optionally assign a color
5. Repeat for all choices

#info_box(type: "warning")[
  *Changing choices*: If you rename or remove a choice, existing records with that value may display incorrectly. Plan your choice lists carefully!
]

=== Choice List
Multiple selections from a predefined list.

*Best for:*
- Tags, labels
- Multiple categories
- Feature lists
- Multiple skills or interests

*Configuration options:*
- Same as Choice, but allows selecting multiple values

*Example usage:*
```json
{
  "tags": ["urgent", "customer-facing", "bug"],
  "skills": ["python", "javascript", "sql"]
}
```

=== Reference
Links to records in another table (foreign key).

*Best for:*
- Relationships between tables
- User association (order belongs to user)
- Category references
- Parent-child relationships

*Configuration options:*
- *Target Table*: Which table to reference
- *Show Column*: Which column to display from the target table

*Example usage:*
```json
{
  "user_id": 5,  // References record ID 5 in Users table
  "category_id": 12  // References record ID 12 in Categories table
}
```

*Setting up references:*
1. Select "Reference" as column type
2. Choose the target table (e.g., "Users")
3. Choose which column to show (e.g., "email" instead of ID)
4. Save the column

#info_box(type: "success")[
  *Best Practice*: Always use Reference columns instead of storing IDs as text. References maintain data integrity and enable automatic updates if the referenced record changes.
]

=== Reference List
Links to multiple records in another table.

*Best for:*
- Many-to-many relationships
- Multiple assignees
- Product collections
- Multiple categories per item

*Configuration options:*
- Same as Reference, but allows selecting multiple records

*Example usage:*
```json
{
  "assigned_users": [5, 12, 18],  // Multiple user IDs
  "tags": [2, 7, 9, 15]  // Multiple tag IDs
}
```

=== Attachments
For uploading files and images.

*Best for:*
- Document uploads
- Profile pictures
- Product images
- PDF files, spreadsheets

*Configuration options:*
- None required - displays file upload interface

*Example usage:*
```json
{
  "profile_picture": [
    {
      "filename": "avatar.png",
      "url": "https://...",
      "size": 45678
    }
  ]
}
```

#info_box(type: "warning")[
  *File storage*: Attachments consume storage space. Monitor your Grist plan's storage limits. Consider external storage (S3, Cloudinary) for large files or many attachments.
]

== Designing Tables

=== Table Naming Conventions

Choose clear, consistent names for tables:

*Recommended patterns:*
- *Pascal Case*: `Users`, `OrderItems`, `ProductCategories`
- *Plural nouns*: Tables contain multiple records
- *Descriptive*: Name reflects content (avoid abbreviations)

*Examples:*
- ✓ `Users`, `Products`, `Orders`
- ✓ `CustomerReviews`, `ShippingAddresses`
- ✗ `usr`, `prod`, `ord` (too abbreviated)
- ✗ `User`, `Product` (singular - less clear)

=== Column Naming Conventions

*Recommended patterns:*
- *snake_case*: `full_name`, `created_at`, `email_address`
- *Descriptive*: Clear purpose without ambiguity
- *Consistent*: Use same patterns across all tables

*Standard column names:*
- `id`: The built-in record ID (automatic)
- `created_at`: When record was created (DateTime)
- `updated_at`: When record was last modified (DateTime)
- `active`: Whether record is active (Toggle)
- `{entity}_id`: Reference to another table (e.g., `user_id`, `category_id`)

*Examples:*
- ✓ `email`, `password_hash`, `full_name`, `order_date`
- ✓ `total_amount`, `is_verified`, `user_id`
- ✗ `e`, `pw`, `nm` (too short)
- ✗ `EmailAddress`, `PasswordHash` (inconsistent with snake_case)

=== Required vs Optional Columns

Consider which columns are required for a valid record:

*Required columns* (should always have a value):
- Unique identifiers (email, username)
- Status fields (active, order_status)
- Essential relationships (user_id for orders)
- Core attributes (product_name, price)

*Optional columns* (can be empty):
- Additional details (middle_name, notes)
- Timestamps that are set later (completed_at, last_login)
- Optional relationships (assigned_user)

#info_box(type: "info")[
  *Grist doesn't enforce required fields* at the database level. You must validate required fields in your application before sending data to Grist.
]

=== Schema Design Patterns

==== One-to-Many Relationships

When one record relates to many others (e.g., one user has many orders):

*Users table:*
- `id` (automatic)
- `email`
- `full_name`

*Orders table:*
- `id` (automatic)
- `user_id` (Reference → Users)
- `order_date`
- `total_amount`

*In Grist:*
1. Create Users table first
2. Create Orders table
3. Add `user_id` column as Reference type
4. Select Users as the target table
5. Choose `email` or `full_name` as the display column

==== Many-to-Many Relationships

When multiple records relate to multiple others (e.g., students and courses):

*Students table:*
- `id`, `name`, `email`

*Courses table:*
- `id`, `course_name`, `credits`

*Enrollments table* (junction table):
- `id` (automatic)
- `student_id` (Reference → Students)
- `course_id` (Reference → Courses)
- `enrolled_date` (DateTime)
- `grade` (Text, optional)

*In Grist:*
1. Create Students and Courses tables
2. Create Enrollments junction table
3. Add Reference columns for both student_id and course_id

==== Self-Referencing Relationships

When records relate to other records in the same table (e.g., employee hierarchy):

*Employees table:*
- `id` (automatic)
- `name`
- `email`
- `manager_id` (Reference → Employees)
- `department`

The `manager_id` references another record in the same Employees table.

== Schema Evolution Strategies

Applications evolve, and so must schemas. Handle changes carefully:

=== Adding New Columns

*Safe operations:*
- Add optional columns anytime
- Add columns with default values
- Add new Choice options

*Steps:*
1. Add the column in Grist
2. Set default value if needed (use formulas)
3. Update application to use new column
4. Deploy changes

#info_box(type: "success")[
  *Backward compatible*: Adding optional columns won't break existing applications that don't yet use them.
]

=== Modifying Existing Columns

*Risky operations:*
- Changing column type (Text → Numeric)
- Renaming columns
- Removing Choice options that are in use

*Safe approach:*
1. Create new column with desired type/name
2. Migrate data from old column to new (see Data Operations section)
3. Update application to use new column
4. Test thoroughly
5. Optionally delete old column after confirming app works

*Example: Renaming `user_name` to `full_name`:*
1. Add new column `full_name` (Text)
2. In Grist, add formula to `full_name`: `$user_name`
3. Convert formula to data (copy values, remove formula)
4. Update app to use `full_name`
5. Once confirmed working, delete `user_name`

=== Removing Columns

*Before removing a column:*
1. Ensure no applications reference it
2. Export data backup (in case you need to restore)
3. Remove from least critical environment first (dev)
4. Test applications thoroughly
5. Remove from production last

#info_box(type: "danger")[
  *Breaking changes*: Removing columns or changing types can break applications. Always coordinate with Flutter Developers and use staging environments.
]

=== Adding New Tables

*Safe and straightforward:*
1. Design table structure
2. Create table in Grist
3. Add sample/test data
4. Document the schema
5. Inform Flutter Developers
6. They update app to use new table

No risk to existing functionality since it's additive.

== Calculated Columns and Formulas

Grist supports calculated columns using Python-like formulas:

=== Formula Basics

*Syntax:*
- Reference current record's column: `$column_name`
- Reference another table: `TableName.lookupOne(field=$field)`
- Use Python functions: `len()`, `sum()`, `max()`, etc.

=== Common Formula Patterns

==== Full Name from First and Last

In Users table with `first_name` and `last_name`:

```python
$first_name + " " + $last_name
```

Or handling missing values:

```python
" ".join(filter(None, [$first_name, $last_name]))
```

==== Age from Birth Date

```python
import datetime
today = datetime.date.today()
birth = $birth_date
age = today.year - birth.year
age = age - ((today.month, today.day) < (birth.month, birth.day))
age
```

==== Order Total from Line Items

In Orders table, sum all related OrderItems:

```python
sum(OrderItems.lookupRecords(order_id=$id).amount)
```

==== Status Badge with Color

Return styled status text:

```python
status_colors = {
  "pending": "🟡 Pending",
  "approved": "🟢 Approved",
  "rejected": "🔴 Rejected"
}
status_colors.get($status, $status)
```

==== Days Until Deadline

```python
import datetime
if $due_date:
  delta = $due_date - datetime.date.today()
  return delta.days
else:
  return None
```

=== Formula vs Data Columns

*Formula columns:*
- Automatically calculated
- Update when source data changes
- Can't be edited manually
- Not stored (computed on-the-fly)

*Data columns:*
- Store actual values
- Can be edited manually
- Persist in database

*Converting formula to data:*
1. Create column with formula
2. Let it calculate values
3. Click column → "Convert column to data"
4. Values are copied, formula removed

This is useful for one-time calculations or when you need to edit calculated values manually.

== Best Practices

=== 1. Keep It Normalized

Avoid duplicating data across tables:

*Bad: Duplicate user data in Orders*
```
Orders:
- user_email
- user_name
- user_phone
- order_date
- amount
```

*Good: Reference Users table*
```
Orders:
- user_id (Reference → Users)
- order_date
- amount

Users:
- email
- full_name
- phone
```

=== 2. Use Appropriate Types

Choose the most specific type:

- Don't use Text for booleans → Use Toggle
- Don't use Text for categories → Use Choice
- Don't use Text for numbers → Use Numeric
- Don't use Text for dates → Use Date/DateTime

=== 3. Plan for Growth

Consider future needs:

- Add `created_at` and `updated_at` to important tables
- Include `active` or `deleted` toggle instead of deleting records
- Leave room for additional fields
- Think about reporting and analytics needs

=== 4. Document Your Schema

Maintain a data dictionary:

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, left, left, left),
  [*Table*], [*Column*], [*Type*], [*Description*],
  [Users], [email], [Text], [User's login email (unique)],
  [Users], [password_hash], [Text], [Bcrypt hash of password],
  [Users], [role], [Choice], [User role: admin, manager, user],
  [Orders], [user_id], [Reference], [Link to Users table],
  [Orders], [status], [Choice], [Order status: pending, shipped, delivered],
)

Share this with your team and keep it updated.

=== 5. Use Staging Environments

Never test schema changes in production:

- *Development*: Experiment freely
- *Staging*: Test with production-like data
- *Production*: Deploy only after thorough testing

Create separate Grist documents for each environment.

=== 6. Version Control Schema

Track schema changes:

- Document what changed and when
- Note who made the change
- Record why the change was needed
- Link to related application changes

Consider keeping a "Schema Changelog" table in Grist itself.

== Schema Review Checklist

Before deploying a schema to production:

- [ ] All table names follow naming conventions
- [ ] All column names are descriptive and consistent
- [ ] Appropriate data types selected for each column
- [ ] Required columns identified (documented)
- [ ] Relationships use Reference columns (not text IDs)
- [ ] No unnecessary data duplication
- [ ] Formulas tested and working correctly
- [ ] Sample data added for testing
- [ ] Schema documented (data dictionary)
- [ ] Flutter Developers informed of schema
- [ ] Tested in staging environment
- [ ] Backup created before production deployment

#info_box(type: "success")[
  *Schema quality* directly impacts application reliability and maintainability. Take time to design it well upfront!
]
