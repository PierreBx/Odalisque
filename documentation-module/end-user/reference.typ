// End User Reference Guide - FlutterGristAPI
// Complete feature reference and comprehensive documentation

#import "../common/styles.typ": *

= Complete Feature Reference

This comprehensive reference guide documents all features available to end users of FlutterGristAPI applications. Use this as your complete guide to understanding every aspect of the application.

== Application Overview

=== What is FlutterGristAPI?

FlutterGristAPI is a system that generates mobile and desktop applications from database configurations. Your app is specifically designed to:

- Display data from your organization's database (Grist)
- Provide secure access through login authentication
- Enable searching, sorting, and viewing data
- Work across multiple devices (phones, tablets, computers)
- Maintain role-based security and permissions

=== Version Information

*Current Version: 0.1.0*

#info_box(type: "warning")[
  **Version 0.1.0 - Read-Only Features**

  The current version provides *read-only* access to data. You can:
  - ✓ View all authorized data
  - ✓ Search and filter records
  - ✓ Sort and paginate through results
  - ✓ Navigate between master and detail views

  You *cannot* currently:
  - ✗ Edit existing records
  - ✗ Create new records
  - ✗ Delete records
  - ✗ Upload files or attachments
  - ✗ Export data (planned for future versions)

  These features are planned for future releases.
]

=== Supported Platforms

Your app works on:

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Platform*], [*Minimum Version*], [*Notes*],

  [iOS], [iOS 12+], [iPhone and iPad supported],
  [Android], [Android 5.0+], [Phones and tablets],
  [Web], [Modern browsers], [Chrome, Safari, Firefox, Edge],
  [Desktop], [Chrome browser], [Responsive web interface],
)

== Authentication System

=== User Accounts

Every user has an account with these attributes:

/ Email Address: Your unique identifier and username
  - Format: `username@domain.com`
  - Case-insensitive (usually)
  - Cannot be changed by end users

/ Password: Secret credential for authentication
  - Case-sensitive
  - Minimum length varies (typically 6-8 characters)
  - Should be strong and unique
  - Must be reset by administrator

/ Role: Determines your permissions
  - Examples: User, Manager, Admin
  - Controls what data and features you can access
  - Assigned by administrator

/ Active Status: Whether your account can log in
  - Active accounts can log in
  - Inactive accounts are locked
  - Administrators control activation

=== Login Process

The authentication flow:

```
┌─────────────────────────────────────┐
│  1. Open App                        │
│     ↓                               │
│  2. Enter Email & Password          │
│     ↓                               │
│  3. Tap Login                       │
│     ↓                               │
│  4. System Validates:               │
│     • Email exists?                 │
│     • Password correct?             │
│     • Account active?               │
│     • Role permissions?             │
│     ↓                               │
│  5. Success: Navigate to Home       │
│     OR                              │
│  6. Error: Show error message       │
└─────────────────────────────────────┘
```

*Login Validation Rules:*

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Check*], [*Success*], [*Failure*],

  [Email format], [Valid email syntax], ["Invalid email format"],
  [Email exists], [Found in database], ["User not found"],
  [Password match], [Correct password], ["Invalid password"],
  [Account active], [Active = true], ["Account disabled"],
  [Role valid], [Has assigned role], ["Permission denied"],
)

=== Session Management

Once logged in, your session:

- *Lasts*: 30 minutes of activity (default)
- *Extends*: Each interaction resets the timer
- *Expires*: After 30 minutes of inactivity
- *Secure*: Tokens are encrypted and secure

*Session Lifecycle:*

```
Login → Session Created (30 min timer)
  ↓
  ├─ User Active → Timer Resets → Continue Session
  ├─ User Inactive 30 min → Session Expires → Force Logout
  └─ User Logs Out → Session Destroyed → Return to Login
```

#info_box(type: "info")[
  **Staying Logged In**

  Any interaction with the app resets the inactivity timer:
  - Tapping buttons
  - Scrolling
  - Searching
  - Navigating between pages

  Simply viewing a page without interaction will not reset the timer.
]

=== Security Features

Your account is protected by:

1. *Password Hashing*
   - Passwords are never stored in plain text
   - Uses bcrypt encryption
   - Cannot be reversed or recovered

2. *Session Tokens*
   - Encrypted authentication tokens
   - Transmitted securely
   - Automatically expire

3. *Role-Based Access Control*
   - Only see data authorized for your role
   - Prevents unauthorized access
   - Enforced at server level

4. *Automatic Logout*
   - Inactivity timeout
   - Prevents unauthorized access to unattended devices
   - Can be manually triggered anytime

5. *Secure Communications*
   - Data encrypted in transit (HTTPS)
   - Secure API communications
   - Protected against eavesdropping

== Navigation System

=== Application Structure

The app uses a hierarchical navigation model:

```
┌─────────────────────────────────────┐
│          Login Page                 │
└─────────┬───────────────────────────┘
          ↓
┌─────────────────────────────────────┐
│       Home / Welcome Page           │ ← Starting point after login
├─────────────────────────────────────┤
│   Drawer Menu (☰)                   │
│   • Home                            │
│   • Section 1 (e.g., Products)     │
│   • Section 2 (e.g., Customers)    │
│   • Section 3 (e.g., Orders)       │
│   • Settings                        │
│   • About                           │
│   • Logout                          │
└─────────┬───────────────────────────┘
          ↓ (Tap any section)
┌─────────────────────────────────────┐
│      Master Page (List View)        │ ← Shows table of records
│   • Search, Sort, Paginate          │
│   • Displays multiple records       │
└─────────┬───────────────────────────┘
          ↓ (Tap a row)
┌─────────────────────────────────────┐
│     Detail Page (Single Record)     │ ← Shows one complete record
│   • All fields displayed            │
│   • Back button returns to list     │
└─────────────────────────────────────┘
```

=== Drawer Menu

The permanent navigation drawer provides:

*Structure:*

```
┌─────────────────────────────┐
│ ┌─────────────────────────┐ │
│ │  USER PROFILE SECTION   │ │
│ │  👤 Name                │ │
│ │     email@company.com   │ │
│ │     Role: [Your Role]   │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │  NAVIGATION ITEMS       │ │
│ │  🏠 Home                │ │
│ │  📄 Page 1              │ │
│ │  📄 Page 2              │ │
│ │  📄 Page 3              │ │
│ │  ⚙️  Settings           │ │
│ │  ℹ️  About              │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │  ACTIONS                │ │
│ │  🚪 Logout              │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

*Opening Methods:*

1. Tap menu icon (☰) in top-left
2. Swipe from left edge (mobile)
3. Keyboard shortcut: Alt+M or Cmd+M (desktop)

*Closing Methods:*

1. Tap outside the drawer
2. Swipe drawer to the left (mobile)
3. Tap any menu item (auto-closes)
4. Press Esc key (desktop)

=== Page Types

Your app contains different types of pages:

==== Front Pages (Static Content)

/ Purpose: Display static information, welcome messages, instructions
/ Features:
  - Text content
  - Images
  - No database interaction
  - Quick to load

/ Examples: Home page, About page, Help page

/ User Actions: Read content, navigate away

==== Data Master Pages (Table Lists)

/ Purpose: Display lists of records from database tables
/ Features:
  - Tabular data display
  - Search functionality
  - Sort by columns
  - Pagination
  - Click rows to view details

/ Examples: Products list, Customers list, Orders list

/ User Actions: Browse, search, sort, navigate to details

==== Data Detail Pages (Single Record)

/ Purpose: Display complete information about one record
/ Features:
  - All fields visible
  - Form-like layout
  - Read-only display
  - Back button to return

/ Examples: Product details, Customer profile, Order information

/ User Actions: Read information, return to list

==== Admin Dashboard Pages

/ Purpose: Display system statistics and metrics (Admin users only)
/ Features:
  - Active users count
  - Database statistics
  - System information
  - Real-time updates

/ Examples: Admin dashboard, Reports page

/ User Actions: Monitor system, view metrics

=== Navigation Patterns

==== Master-Detail Navigation

The most common pattern:

```
1. Start at Master Page (List)
   ↓
2. Tap a Row
   ↓
3. Navigate to Detail Page (Single Record)
   ↓
4. View Information
   ↓
5. Tap Back Button
   ↓
6. Return to Master Page (List)
```

*State Preservation:*
- Your scroll position is maintained
- Search filters remain active
- Sort order is preserved
- Page number stays the same

==== Menu Navigation

Switching between major sections:

```
1. Open Drawer Menu (☰)
   ↓
2. Current Section Highlighted
   ↓
3. Tap Different Section
   ↓
4. Drawer Closes Automatically
   ↓
5. New Section Loads
   ↓
6. Previous Section State Cleared
```

==== Back Navigation

How the back button works:

*Navigation Stack:*
```
Home → Products List → Product Detail
 ↑         ↑               ↑
 |         |               | You are here
 |         |               |
 |         ← Back          ← Back takes you here
 |
 ← Back
```

*Stack Behavior:*
- Each forward navigation adds to stack
- Back button pops from stack
- Bottom of stack is Home page
- Can't go back beyond login/home

== Data Viewing Features

=== Table Display

Data master pages show information in tabular format:

*Standard Table Structure:*

#table(
  columns: (auto, auto, 1fr, auto, auto),
  align: (left, left, left, left, left),
  [*#*], [*Column 1*], [*Column 2*], [*Column 3*], [*Actions*],
  [1], [Value A1], [Value B1], [Value C1], [›],
  [2], [Value A2], [Value B2], [Value C2], [›],
  [3], [Value A3], [Value B3], [Value C3], [›],
)

*Column Types:*

#table(
  columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Type*], [*Display*], [*Example*],

  [Record Number], [Sequential integer], [1, 2, 3, ...],
  [Text], [String value], [Product Name],
  [Numeric], [Formatted number], [1,234.56],
  [Currency], [With currency symbol], [$99.99],
  [Date], [Formatted date], [2025-11-10],
  [Boolean], [Yes/No or ✓/✗], [Active: ✓],
  [Reference], [Linked value], [→ Related Item],
)

=== Record Number Column

Every table includes a record number column (#):

*Purpose:*
- Provides easy reference
- Sequential numbering (1, 2, 3...)
- Independent of database ID
- Easy to communicate ("Check record 42")

*Behavior:*

#table(
  columns: (1fr, 1fr),
  align: (left, left),
  [*Action*], [*Record Numbers*],

  [Initial Load], [1, 2, 3, 4, 5...],
  [Sort by Name], [3, 1, 5, 2, 4... (records reorder)],
  [Search/Filter], [1, 2, 3... (renumbered for visible records)],
  [Pagination], [Continues across pages (21, 22, 23 on page 2)],
)

*Configuration:*
- Always visible (first column)
- May be labeled "N°", "#", "No.", or "Record"
- Configured by app designer
- Usually sortable

=== Field Types and Display

Different data types display differently:

==== Text Fields

/ Display: Plain text, left-aligned
/ Examples: Names, descriptions, addresses
/ Behavior:
  - Long text may wrap to multiple lines (detail view)
  - May be truncated in table view
  - Full text visible in detail view

==== Numeric Fields

/ Display: Right-aligned, formatted with separators
/ Examples: Quantities, IDs, measurements
/ Format: 1,234.56 or 1.234,56 (locale-dependent)
/ Behavior:
  - Sorts numerically (not alphabetically)
  - May show decimal places
  - Negative numbers may show in red or with minus sign

==== Currency Fields

/ Display: Currency symbol + formatted number
/ Examples: Prices, costs, revenue
/ Format: $1,234.56 or €1.234,56 or ¥1,234
/ Behavior:
  - Currency symbol based on configuration
  - Always shows two decimal places (typically)
  - Aligned for easy comparison

==== Date and Time Fields

/ Display: Formatted based on locale
/ Examples: Order dates, created dates, modified dates
/ Formats:
  - US: 11/10/2025 or Nov 10, 2025
  - ISO: 2025-11-10
  - Time: 14:30:00 or 2:30 PM
/ Behavior:
  - Sorts chronologically
  - May show relative time ("2 days ago")
  - Timezone may affect display

==== Boolean/Toggle Fields

/ Display: Yes/No, True/False, ✓/✗, or icons
/ Examples: Active status, enabled features, flags
/ Format:
  - Checkmark (✓) for true
  - X or empty for false
  - May use colors (green/red)
/ Behavior:
  - Clear visual indication
  - Sorts with true values first or last

==== Reference Fields

/ Display: Links to related records
/ Examples: Customer name in Orders table
/ Format: "→ Customer Name" or just "Customer Name"
/ Behavior:
  - May be clickable (not in v0.1.0)
  - Shows value from related table
  - Useful for understanding relationships

=== Detail View Layout

When viewing a single record:

*Layout Pattern:*

```
┌─────────────────────────────────────┐
│ ← Back        [Record Title]        │
├─────────────────────────────────────┤
│  Record Number: 42                  │
│                                     │
│  Section: Basic Information         │
│  ┌───────────────────────────────┐ │
│  │ Field Name:    Value          │ │
│  │ Another Field: Another Value  │ │
│  │ Date Field:    2025-11-10     │ │
│  └───────────────────────────────┘ │
│                                     │
│  Section: Additional Details        │
│  ┌───────────────────────────────┐ │
│  │ Long Text Field:              │ │
│  │ This is a longer text that    │ │
│  │ spans multiple lines and      │ │
│  │ provides detailed information.│ │
│  └───────────────────────────────┘ │
│                                     │
│  Section: Related Information       │
│  ┌───────────────────────────────┐ │
│  │ Related Field: Value          │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

*Layout Principles:*

1. *Clear Labels*: Each field has a descriptive label
2. *Organized Sections*: Related fields grouped together
3. *Readable Format*: Appropriate spacing and font sizes
4. *Scrollable*: Scroll down for more fields
5. *Consistent*: Same layout pattern across all detail pages

=== Conditional Visibility

Some fields may be visible only to certain roles:

*Example Scenario:*

#table(
  columns: (1fr, auto, auto, auto),
  align: (left, center, center, center),
  [*Field*], [*User*], [*Manager*], [*Admin*],

  [Name], [✓], [✓], [✓],
  [Email], [✓], [✓], [✓],
  [Phone], [✓], [✓], [✓],
  [Salary], [✗], [✓], [✓],
  [Social Security], [✗], [✗], [✓],
  [Performance Review], [✗], [✓], [✓],
)

*Behavior:*
- Fields you can't see simply don't appear
- No indication that hidden fields exist
- Configured by app designer
- Based on your role

== Search Functionality

=== Basic Search

*How Search Works:*

```
1. Tap Search Icon (🔍)
   ↓
2. Search Bar Appears at Top
   ↓
3. Type Search Term
   ↓
4. Results Filter in Real-Time
   ↓
5. Table Shows Only Matching Records
   ↓
6. Clear Search to Show All Records
```

=== Search Behavior

*Matching Rules:*

#table(
  columns: (1fr, 1fr, 1fr),
  align: (left, left, left),
  [*Rule*], [*Example*], [*Matches*],

  [Case-insensitive], ["laptop"], ["Laptop", "LAPTOP", "laptop"],
  [Partial matching], ["lap"], ["laptop", "overlap", "laprobe"],
  [Multi-column], ["electronics"], [Any column containing "electronics"],
  [Word boundaries], ["lap"], ["laptop" but not "clap" typically],
  [Numbers], ["123"], ["123", "1234", "$123.00"],
)

*What is Searched:*

- All visible columns in the table
- Text fields
- Numeric fields (as text)
- Date fields (as formatted strings)
- Boolean fields (may match "Yes", "No", "True", "False")

*What is NOT Searched:*

- Hidden columns
- Columns not displayed in the table
- Data in detail view only
- Related tables or records

=== Search Examples

*Example 1: Finding by Name*

```
Data:
#  Product Name       Category
1  Laptop Pro 15      Electronics
2  Office Chair       Furniture
3  Wireless Mouse     Electronics

Search: "laptop"
Results: Record 1 only

Search: "pro"
Results: Record 1 only

Search: "electr"
Results: Records 1 and 3
```

*Example 2: Finding by Number*

```
Data:
#  Order ID    Amount     Date
1  ORD-2025-001  $150.00   2025-11-01
2  ORD-2025-002  $250.00   2025-11-02
3  ORD-2024-003  $350.00   2024-12-15

Search: "2025"
Results: Records 1 and 2 (matches order ID and date)

Search: "250"
Results: Records 2 and 3 (matches amount)

Search: "002"
Results: Record 2 only
```

*Example 3: Finding by Multiple Attributes*

```
Search: "electronics"
Results: All records where ANY column contains "electronics"

Search: "2025 laptop"
Results: May return no results (looks for exact phrase)
Better: Search "laptop" first, then "2025" to narrow down
```

=== Search Tips

*For Best Results:*

1. *Start Broad*
   - Begin with general terms
   - Narrow down if too many results

2. *Use Distinctive Terms*
   - Search for unique identifiers
   - Use specific product codes or IDs

3. *Try Partial Words*
   - "elec" instead of "electronics"
   - "cust" instead of "customer"

4. *Use Numbers*
   - Search by order numbers
   - Search by prices
   - Search by dates (year, month)

5. *Clear Between Searches*
   - Clear previous search before new one
   - Avoid confusion with multiple filters

#info_box(type: "info")[
  **Advanced Search Coming Soon**

  Future versions may include:
  - Search specific columns only
  - Multiple search terms (AND/OR logic)
  - Date range filtering
  - Numeric range filtering (e.g., price $100-$500)
  - Saved searches
]

== Sort Functionality

=== How Sorting Works

*Sort Process:*

```
1. Identify Column to Sort
   ↓
2. Tap/Click Column Header
   ↓
3. First Tap: Ascending Order
   ↓
4. Second Tap: Descending Order
   ↓
5. Third Tap: Original Order
   ↓
6. Cycle Repeats
```

=== Sort Orders

*Ascending Order (A→Z, 0→9, Old→New):*

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Data Type*], [*Sort Order*], [*Example*],

  [Text], [Alphabetical A to Z], [Apple, Banana, Cherry],
  [Numbers], [Smallest to largest], [1, 10, 100, 1000],
  [Dates], [Oldest to newest], [2023-01-01, 2024-01-01, 2025-01-01],
  [Currency], [Lowest to highest], [$10, $100, $1000],
  [Boolean], [False then True], [No, No, Yes, Yes],
)

*Descending Order (Z→A, 9→0, New→Old):*

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Data Type*], [*Sort Order*], [*Example*],

  [Text], [Alphabetical Z to A], [Cherry, Banana, Apple],
  [Numbers], [Largest to smallest], [1000, 100, 10, 1],
  [Dates], [Newest to oldest], [2025-01-01, 2024-01-01, 2023-01-01],
  [Currency], [Highest to lowest], [$1000, $100, $10],
  [Boolean], [True then False], [Yes, Yes, No, No],
)

=== Sort Indicators

Visual cues for current sort:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Indicator*], [*Meaning*],

  [Column Name ↑], [Sorted ascending],
  [Column Name ↓], [Sorted descending],
  [Column Name], [Not sorted (or original order)],
  [Bold column name], [May indicate active sort],
  [Different color], [May highlight sorted column],
)

*Note:* Visual indicators vary by app design.

=== Sorting with Search

*Combination Behavior:*

```
Scenario 1: Search Then Sort
1. Search for "electronics"
2. Results: 5 matching records
3. Sort by price
4. Result: 5 records sorted by price

Scenario 2: Sort Then Search
1. Sort by name (A-Z)
2. Search for "electronics"
3. Result: Matching records still sorted by name

Recommendation: Search first, then sort results
```

=== Sorting Limitations

*Current Limitations (v0.1.0):*

- Only one column sortable at a time
- No multi-level sorting (e.g., sort by category, then by price)
- Sort applies to current page only (or all results, depending on configuration)
- Cannot save sort preferences

*Planned Features:*
- Multi-level sorting
- Default sort preferences
- Sort persistence across sessions

== Pagination System

=== How Pagination Works

Large datasets are divided into pages for performance:

*Pagination Control:*

```
┌─────────────────────────────────────┐
│  [< Previous]  Page 3 of 10  [Next >]  │
│     ↑             ↑            ↑      │
│     |             |            |      │
│  Go back    Current page   Go forward│
└─────────────────────────────────────┘
```

*Components:*

1. *Previous Button*
   - Enabled on pages 2+
   - Disabled on page 1
   - Loads previous set of records

2. *Page Indicator*
   - Shows current page number
   - Shows total pages
   - Format: "Page X of Y"

3. *Next Button*
   - Enabled on pages before last
   - Disabled on last page
   - Loads next set of records

=== Page Size

Records per page varies by platform:

#table(
  columns: (auto, auto, 1fr),
  align: (left, center, left),
  [*Platform*], [*Typical Size*], [*Reason*],

  [Mobile Phone], [10-15], [Smaller screen, less scrolling],
  [Tablet], [20-25], [Medium screen],
  [Desktop], [25-50], [Large screen, more visible],
  [Web Browser], [20-50], [Depends on window size],
)

*Note:* Page size is configured by app designer and cannot be changed by end users.

=== Navigation Strategies

*Finding Specific Record:*

*Strategy 1: Calculate Page*
```
If each page has 20 records:
- Record 1-20: Page 1
- Record 21-40: Page 2
- Record 41-60: Page 3
- etc.

To find record 127:
127 ÷ 20 = 6.35 → Page 7
```

*Strategy 2: Sort First*
```
1. Sort by relevant column
2. Estimate position
3. Navigate to approximate page
```

*Strategy 3: Use Search*
```
1. Search for the record
2. Ignore pagination - search shows all matches
3. Much faster than manual navigation
```

=== Pagination with Filters

*Behavior:*

```
Original Data: 1000 records → 50 pages

After Search: 50 matching records → 3 pages
- Pagination recalculates
- Page numbers start over (Page 1 of 3)
- Clear search to return to full pagination

After Sort: 1000 records → 50 pages
- Pagination stays same
- Records reordered within pages
```

== User Interface Elements

=== Top Bar

The top bar appears on every page:

```
┌─────────────────────────────────────┐
│ ☰  Page Title              🔍  ⋮   │
│ ↑      ↑                   ↑   ↑   │
│ |      |                   |   |   │
│ Menu  Page name         Search More│
└─────────────────────────────────────┘
```

*Elements:*

/ Menu Icon (☰): Opens navigation drawer
/ Page Title: Shows current page name
/ Search Icon (🔍): Opens/closes search functionality
/ More Icon (⋮): Additional options (if available)

=== Bottom Bar / Footer

May contain:

- Pagination controls
- Record count ("Showing 1-20 of 500")
- Action buttons
- Status information

*Example:*
```
┌─────────────────────────────────────┐
│  Showing 21-40 of 127 records       │
│  [< Previous]  Page 2 of 7  [Next >]  │
└─────────────────────────────────────┘
```

=== Buttons and Controls

*Standard Buttons:*

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*Button*], [*Purpose*], [*Location*],

  [← Back], [Return to previous page], [Top-left],
  [Login], [Authenticate user], [Login page],
  [Logout], [End session], [Drawer menu],
  [🔍 Search], [Open search], [Top-right],
  [Next >], [Next page], [Bottom],
  [< Previous], [Previous page], [Bottom],
  [✓ OK], [Confirm action], [Dialogs],
  [✗ Cancel], [Cancel action], [Dialogs],
)

*Button States:*

/ Enabled: Normal colors, clickable
/ Disabled: Grayed out, not clickable
/ Active: Highlighted, currently selected
/ Loading: Spinner or progress indicator

=== Icons Reference

Common icons and their meanings:

#table(
  columns: (auto, 1fr),
  align: (center, left),
  [*Icon*], [*Meaning*],

  [☰], [Menu / Navigation drawer],
  [🔍], [Search],
  [🏠], [Home],
  [📦], [Products / Items],
  [👥], [People / Customers],
  [📋], [Lists / Orders],
  [📊], [Reports / Analytics],
  [⚙️], [Settings],
  [ℹ️], [Information / About],
  [🚪], [Logout],
  [←], [Back / Return],
  [→], [Forward / Navigate to],
  [↑], [Sort ascending],
  [↓], [Sort descending],
  [✓], [Yes / Confirmed / Success],
  [✗], [No / Canceled / Error],
  [⋮], [More options],
  [+], [Add / Create (future version)],
  [✎], [Edit (future version)],
  [🗑], [Delete (future version)],
  [↻], [Refresh],
  [⬇], [Download / Export (future version)],
)

=== Loading States

When data is loading:

*Indicators:*

1. *Spinner*: Circular animation
2. *Progress Bar*: Horizontal bar filling
3. *Skeleton Screens*: Gray placeholder boxes
4. *Loading Text*: "Loading..." message

*Where You See Them:*

- After login, while loading home page
- When navigating to new section
- When opening detail page
- After searching or sorting
- When refreshing data

*Typical Duration:*

- Fast connection: 1-3 seconds
- Normal connection: 3-10 seconds
- Slow connection: 10-30 seconds
- If > 60 seconds: Likely an error (see Troubleshooting)

=== Error States

When something goes wrong:

*Error Presentation:*

```
┌─────────────────────────────────────┐
│              ⚠️                      │
│         Error Message               │
│                                     │
│  Brief explanation of what went     │
│  wrong and what you can do about it.│
│                                     │
│        [Try Again] [Cancel]         │
└─────────────────────────────────────┘
```

*Common Patterns:*

- Red text or red banner
- Warning icon (⚠️) or error icon (✗)
- Explanation of the error
- Suggested action
- Buttons to retry or cancel

=== Empty States

When no data exists:

```
┌─────────────────────────────────────┐
│                                     │
│          📭                         │
│      No Records Found               │
│                                     │
│  Try adjusting your search or       │
│  contact your administrator.        │
│                                     │
└─────────────────────────────────────┘
```

*Scenarios:*

- Table has no records yet
- Search returns no matches
- No records match your filter
- Permission restrictions hide all data

== Mobile-Specific Features

=== Touch Gestures

*Supported Gestures:*

#table(
  columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Gesture*], [*Action*], [*Result*],

  [Tap], [Quick press and release], [Select item, activate button],
  [Long Press], [Press and hold], [May show contextual menu (future)],
  [Swipe Left], [Horizontal drag left], [May show actions (future)],
  [Swipe Right], [Horizontal drag right], [May open menu from edge],
  [Swipe Up/Down], [Vertical drag], [Scroll content],
  [Pull Down], [Drag down from top], [Refresh data],
  [Pinch Out], [Two fingers apart], [Zoom in],
  [Pinch In], [Two fingers together], [Zoom out],
  [Double Tap], [Two quick taps], [Zoom or select (context-dependent)],
)

=== Device Orientation

*Portrait Mode (Vertical):*

- Default orientation
- Better for scrolling lists
- Narrower view of tables
- May stack columns vertically
- Easier one-handed use

*Landscape Mode (Horizontal):*

- Rotate device 90 degrees
- Wider view of tables
- See more columns at once
- Better for data-heavy pages
- Requires two-handed use

*App Behavior:*

- Automatically adapts to orientation
- Layout adjusts responsively
- No need to restart app
- May hide/show different elements

=== Mobile Browser Considerations

If using web version on mobile:

1. *Address Bar*
   - May hide when scrolling down
   - Creates more screen space
   - Reappears when scrolling up

2. *Zoom Controls*
   - Browser zoom affects layout
   - May make text more readable
   - Can cause horizontal scrolling
   - Reset zoom if layout breaks

3. *Tabs*
   - Opening in new tab requires new login
   - Sessions are per-tab
   - Closing tab ends session (usually)

4. *Bookmarks*
   - Save direct links to pages
   - Will require login each time
   - Useful for quick access

== Desktop-Specific Features

=== Keyboard Shortcuts

Full reference of desktop shortcuts:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Shortcut*], [*Action*],

  [Ctrl + F (or Cmd + F)], [Open search],
  [Esc], [Close search, go back, close dialog],
  [Alt + M (or Cmd + M)], [Open/close navigation menu],
  [F5], [Refresh page / Reload data],
  [Ctrl + R (or Cmd + R)], [Refresh page / Reload data],
  [Backspace], [Go back to previous page],
  [Tab], [Move to next interactive element],
  [Shift + Tab], [Move to previous interactive element],
  [Enter], [Activate button or link],
  [Space], [Activate button or scroll down],
  [Arrow Keys], [Navigate through tables or lists],
  [Home], [Scroll to top of page],
  [End], [Scroll to bottom of page],
  [Page Up], [Scroll up one screen],
  [Page Down], [Scroll down one screen],
  [Ctrl + + (or Cmd + +)], [Zoom in],
  [Ctrl + - (or Cmd + -)], [Zoom out],
  [Ctrl + 0 (or Cmd + 0)], [Reset zoom to 100%],
)

*Note:* Some shortcuts may vary by browser and operating system.

=== Mouse Interactions

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Action*], [*Result*],

  [Left Click], [Select, activate, navigate],
  [Right Click], [Context menu (browser default)],
  [Double Click], [May zoom or select text],
  [Scroll Wheel], [Scroll page up/down],
  [Shift + Scroll], [Scroll horizontally (in tables)],
  [Ctrl + Scroll], [Zoom in/out],
  [Hover], [May show tooltips or highlights],
  [Click and Drag], [Select text, pan images],
)

=== Browser Features

*Useful Browser Functions:*

1. *Bookmarks*
   - Save frequently visited pages
   - Quick access to specific sections
   - Organize in folders

2. *Browser History*
   - Use back/forward buttons
   - Navigate through previous pages
   - Faster than menu navigation

3. *Multiple Windows/Tabs*
   - Open app in multiple tabs
   - Each requires separate login
   - Sessions are independent

4. *Print Preview*
   - Browser print function (Ctrl+P)
   - May allow printing detail pages
   - Some pages may not print well

5. *Find in Page*
   - Browser find function (Ctrl+F)
   - Different from app search
   - Searches visible page content only

=== Screen Size Considerations

The app adapts to different screen sizes:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Screen Size*], [*App Behavior*],

  [Small (< 768px)], [Mobile layout, touch-optimized],
  [Medium (768-1024px)], [Tablet layout, mixed interactions],
  [Large (> 1024px)], [Desktop layout, mouse-optimized],
  [Very Large (> 1920px)], [Maximum width, centered content],
)

*Resizing Window:*

- App adjusts in real-time
- May switch between layouts
- Content remains accessible
- No need to refresh

== Role-Based Features

=== User Role

*Standard user access includes:*

✓ View all standard data tables
✓ Search and filter data
✓ Sort by all columns
✓ View record details
✓ Navigate between pages
✓ Access front pages (Home, About)

✗ Admin-only features hidden
✗ Manager-only reports hidden
✗ Sensitive fields hidden

*Typical Sections:*
- Home
- Main data tables (Products, Customers, etc.)
- About/Help pages

=== Manager Role

*Manager access includes all User features plus:*

✓ Additional data tables
✓ Reporting and analytics pages
✓ Team or department data
✓ Extended field visibility

✗ Admin dashboard hidden
✗ System configuration hidden

*Additional Sections:*
- Reports
- Analytics
- Team management views

=== Admin Role

*Admin access includes all Manager features plus:*

✓ Admin dashboard
✓ System information
✓ User management views
✓ All fields visible
✓ Complete data access

*Admin-Only Sections:*

==== Admin Dashboard

```
┌─────────────────────────────────────┐
│       Admin Dashboard               │
├─────────────────────────────────────┤
│  Active Users                       │
│  ┌───────────────────────────────┐ │
│  │  Currently logged in: 5       │ │
│  │  • John Doe (2 min ago)      │ │
│  │  • Jane Smith (5 min ago)    │ │
│  │  • ...                       │ │
│  └───────────────────────────────┘ │
│                                     │
│  Database Statistics                │
│  ┌───────────────────────────────┐ │
│  │  Total Records: 1,234         │ │
│  │  Tables: 8                    │ │
│  │  Last Updated: 2 min ago      │ │
│  └───────────────────────────────┘ │
│                                     │
│  System Information                 │
│  ┌───────────────────────────────┐ │
│  │  Server Status: Online        │ │
│  │  Version: 0.1.0               │ │
│  │  Uptime: 7 days               │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

== Accessibility Features

=== For Vision Impairment

1. *Text Size Adjustment*
   - Use device text size settings
   - Browser zoom (Ctrl + +/-)
   - High contrast mode support

2. *Screen Reader Support*
   - Compatible with iOS VoiceOver
   - Compatible with Android TalkBack
   - Semantic HTML for web version

3. *Color Contrast*
   - High contrast text and backgrounds
   - Important information not color-only
   - Clear focus indicators

=== For Motor Impairment

1. *Large Touch Targets*
   - Buttons sized for easy tapping
   - Adequate spacing between elements
   - No precise targeting required

2. *Keyboard Navigation*
   - Full keyboard support on desktop
   - Tab through all interactive elements
   - No mouse-only features

3. *Gesture Alternatives*
   - Button alternatives for gestures
   - No complex multi-finger gestures required
   - Simple, standard interactions

=== For Cognitive Accessibility

1. *Clear Language*
   - Simple, straightforward labels
   - Consistent terminology
   - Descriptive error messages

2. *Consistent Layout*
   - Predictable navigation
   - Similar pages have similar layout
   - Standard patterns used throughout

3. *Progressive Disclosure*
   - Information presented gradually
   - Not overwhelming
   - Clear hierarchy

== Data Privacy and Security

=== What Data is Stored

*On Server:*
- All database records
- User accounts and passwords (encrypted)
- Session information
- Access logs

*On Your Device:*
- Session token (temporary)
- Minimal cache data
- No passwords stored locally
- Automatically cleared on logout

=== Data Protection

Your data is protected by:

1. *Encryption in Transit*
   - HTTPS/SSL encryption
   - Secure API communications
   - Protected from eavesdropping

2. *Encryption at Rest*
   - Passwords hashed with bcrypt
   - Secure database storage
   - Regular backups

3. *Access Control*
   - Role-based permissions
   - Session-based authentication
   - Automatic session expiration

4. *Audit Trail*
   - Login/logout tracked
   - Access logged
   - Administrators can review activity

=== Privacy Best Practices

*Protect Your Account:*

1. Never share your password
2. Don't write down passwords
3. Use strong, unique passwords
4. Log out on shared devices
5. Report suspicious activity
6. Don't share your session with others

*Protect Sensitive Data:*

1. Don't take screenshots of sensitive info
2. Don't email or text sensitive data
3. Lock your device when not in use
4. Be aware of who can see your screen
5. Follow your organization's data policies

== Future Features (Roadmap)

Features planned for future versions:

=== Version 0.2.0 (Planned)

*Editing Capabilities:*
- Edit existing records
- Form validation
- Save changes
- Cancel/discard changes

*Data Entry:*
- Create new records
- Fill out forms
- Submit new data
- Validation before saving

*Delete Operations:*
- Delete records (with confirmation)
- Bulk delete (select multiple)
- Undo delete (recovery period)

=== Version 0.3.0 (Planned)

*Advanced Search:*
- Search specific columns
- Multiple search terms (AND/OR)
- Date range filters
- Numeric range filters
- Saved searches

*Export Features:*
- Export to CSV
- Export to PDF
- Export selected records
- Email export results

*Offline Support:*
- View cached data offline
- Queue changes for later sync
- Offline indicator
- Auto-sync when online

=== Version 0.4.0 (Planned)

*Attachments:*
- Upload files
- View images
- Download attachments
- Manage file storage

*Custom Actions:*
- Custom buttons
- Workflow actions
- Batch operations
- Automated tasks

*Enhanced UI:*
- Customizable dashboard
- Widget system
- Dark mode
- Theme options

== Getting More Help

=== Documentation Resources

1. *This Reference Guide*
   - Complete feature documentation
   - Bookmark for quick reference

2. *Quickstart Guide* (`quickstart.typ`)
   - Step-by-step first-time setup
   - Basic tasks walkthrough

3. *Commands Guide* (`commands.typ`)
   - Detailed action instructions
   - Task-specific guidance

4. *Troubleshooting Guide* (`troubleshooting.typ`)
   - Common problems and solutions
   - Error message reference

=== Support Channels

1. *System Administrator*
   - Account issues
   - Permission requests
   - Password resets
   - Technical problems

2. *IT Department*
   - App installation
   - Device compatibility
   - Network issues
   - Security concerns

3. *Training Resources*
   - User training sessions
   - Video tutorials (if available)
   - Practice environment (if available)

4. *Peer Support*
   - Ask experienced colleagues
   - Share tips and tricks
   - Learn shortcuts
   - Discuss workflows

=== Feedback and Suggestions

Your feedback helps improve the app:

*What to Share:*
- Feature requests
- Usability issues
- Confusing elements
- Workflow suggestions
- Bug reports

*How to Share:*
- Contact your administrator
- Participate in user surveys
- Attend user feedback sessions
- Document specific issues with screenshots

#section_separator()

#info_box(type: "success")[
  **You're Now an Expert!**

  You've completed the comprehensive end user reference guide. You now understand all features available in FlutterGristAPI applications. Bookmark this guide for future reference and enjoy using the app!

  For quick help, refer to:
  - *quickstart.typ* for basics
  - *commands.typ* for actions
  - *troubleshooting.typ* for problems
]
