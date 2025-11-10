# Commands and Actions

This guide covers all the actions you can perform as an end user of the FlutterGristAPI application. Each section provides detailed instructions for common tasks.

## Navigation Commands

### Opening the Navigation Menu

The navigation menu is your primary tool for moving between sections of the app.

*Methods:*

| Method | How To | Platform |
| --- | --- | --- |
| Menu Icon | Tap the ☰ icon in the top-left corner | All |
| Swipe Gesture | Swipe from the left edge toward the right | Mobile |
| Keyboard | Press Alt + M (or Cmd + M on Mac) | Desktop |

*What You'll See:*

- Your profile information at the top
- List of all available sections
- Logout button at the bottom

> **Note**: **Quick Tip**
>
> On mobile devices, swipe gestures are often faster than tapping the menu icon. Practice the swipe gesture from the left edge for quick access.

### Navigating to a Section

To move to a different section of the app:

1. Open the navigation menu (☰)
2. Scan the list of available sections
3. Tap the section you want to visit
4. The menu closes and the new section loads

*Example Sections:*
- Home
- Products
- Customers
- Orders
- Reports
- Settings
- About

### Using the Back Button

To return to the previous screen:

*Methods:*

| Method | How To | Platform |
| --- | --- | --- |
| Back Button | Tap "← Back" at the top-left | All |
| Swipe Gesture | Swipe from left edge toward right | iOS |
| Device Button | Press the back button | Android |
| Browser | Click browser's back button | Web |
| Keyboard | Press Backspace or Esc | Desktop |

*When to Use Back:*
- After viewing a detail page, return to the list
- After opening a section, return to the previous section
- After an error, return to working screen

### Returning to Home

To quickly return to the home screen from anywhere:

1. Open the navigation menu (☰)
2. Tap "Home" at the top of the menu
3. Or navigate using your device's home gesture/button

## Viewing Data

### Browsing Table Lists

When viewing a master page (list of records):

*What You See:*

| # | Name | Description | Status |
| --- | --- | --- | --- |
| 1 | Item One | First item in the list | Active |
| 2 | Item Two | Second item in the list | Pending |
| 3 | Item Three | Third item in the list | Active |

*How to Browse:*

- *Scroll*: Swipe up/down (mobile) or use mouse wheel/trackpad (desktop)
- *View*: See all columns by scrolling horizontally if needed
- *Select*: Tap any row to view its details

### Viewing Record Details

To see complete information about a specific record:

1. Find the record in the table
2. Tap/click anywhere on that row
3. The detail page opens

*Detail Page Features:*

```
┌─────────────────────────────────────┐
│ ← Back        Record Details        │
├─────────────────────────────────────┤
│  Record Number: 42                  │
│                                     │
│  Field Name:        Value           │
│  Another Field:     Another Value   │
│  Long Text Field:                   │
│  This is a longer text that may     │
│  span multiple lines for better     │
│  readability.                       │
│                                     │
│  Date Field:        2025-11-10      │
│  Numeric Field:     1,234.56        │
│                                     │
└─────────────────────────────────────┘
```

*Reading Details:*

- Each field has a clear label
- Values are displayed next to their labels
- Long text values span multiple lines
- Dates, numbers, and text are formatted appropriately
- Scroll down to see all fields if the record has many

### Understanding Record Numbers

Each record has two identifiers:

**Record Number**: A simple, sequential number (1, 2, 3, ...)
  - Displayed in the # column
  - Easy to remember and reference
  - Stays consistent after filtering
  - Use this when discussing records with colleagues

**Internal ID**: A technical identifier
  - Usually hidden from view
  - Used by the system internally
  - Not meant for end users

*Example Usage:*
"Please review record number 27" is clearer than referencing a complex ID.

## Search Operations

### Opening Search

To activate the search functionality:

*Methods:*

| Method | How To | Platform |
| --- | --- | --- |
| Search Icon | Tap the 🔍 icon in top-right corner | All |
| Keyboard | Press Ctrl + F (or Cmd + F on Mac) | Desktop |

### Performing a Basic Search

To search for specific information:

1. Open the search function (tap 🔍)
2. A search bar appears at the top
3. Type your search term
4. Results filter automatically as you type
5. The table shows only matching records

*Search Example:*

```
Search for: "laptop"

Before Search (All Records):
#  Name              Category
1  Laptop Pro 15     Electronics
2  Office Chair      Furniture
3  Wireless Mouse    Electronics
4  Desktop PC        Electronics

After Search (Filtered):
#  Name              Category
1  Laptop Pro 15     Electronics
```

### Search Behavior

Understanding how search works:

**Case-Insensitive**: Searches find results regardless of capitalization
  - "laptop", "Laptop", and "LAPTOP" all find the same results

**Multi-Column**: Search looks through all visible columns
  - Searching "electronics" finds records where ANY column contains that word

**Real-Time**: Results update as you type
  - No need to press Enter or a Search button

**Partial Matching**: Searches match partial words
  - "lap" will find "laptop"
  - "elec" will find "electronics"

### Advanced Search Techniques

*Tips for Better Searches:*

| Goal | Search For | Why |
| --- | --- | --- |
| Find exact match | Complete word or phrase | More precise results |
| Find multiple items | More general term | Category or common attribute |
| Find by number | Part of a number | Price, ID, quantity |
| Find by date | Year, month, or day | Time-based filtering |

*Examples:*

```
Goal: Find all products priced around $299
Search: "299"
Result: Shows products with $299 in any field

Goal: Find all customers in California
Search: "California" or "CA"
Result: Shows customers with CA in any field

Goal: Find orders from 2024
Search: "2024"
Result: Shows orders with 2024 in any field
```

### Clearing Search Results

To return to viewing all records:

*Methods:*

1. *Clear Button*: Tap the X in the search bar
2. *Backspace*: Delete all characters from the search
3. *Close Search*: Tap the search icon (🔍) again

The full list of records reappears.

## Sorting Operations

### Basic Sorting

To organize records by a specific column:

1. Look at the column headers in the table
2. Tap/click the header of the column you want to sort by
3. Observe the sort indicator (if shown)

*Sort Cycle:*

```
Click 1: Ascending Order (A→Z, 0→9, old→new)
Click 2: Descending Order (Z→A, 9→0, new→old)
Click 3: Original Order (as initially loaded)
```

### Sort Examples

*Sorting by Name (Alphabetically):*

| # | Product Name |
| --- | --- |
| 3 | Calculator |
| 1 | Laptop Pro 15 |
| 4 | Mouse Pad |
| 2 | Office Chair |

*Sorting by Price (Numerically):*

| # | Product Name | Price |
| --- | --- | --- |
| 3 | USB Cable | $9 |
| 4 | Wireless Mouse | $29 |
| 2 | Office Chair | $299 |
| 1 | Laptop Pro 15 | $1,299 |

### Understanding Sort Indicators

Some apps show visual indicators for sorting:

| Indicator | Meaning |
| --- | --- |
| ↑ or ▲ | Sorted ascending (low to high) |
| ↓ or ▼ | Sorted descending (high to low) |
| No arrow | Not sorted by this column |

### Multi-Column Considerations

*Important Notes:*

- Only one column can be sorted at a time
- Sorting a new column replaces the previous sort
- Search results can also be sorted
- Record numbers don't change when sorting (they're just reordered)

> **Note**: **Combining Search and Sort**
>
> You can search for specific records and then sort the results. For example:
> 1. Search for "electronics"
> 2. Sort by price
> 3. See electronics products ordered by price

## Pagination Commands

### Understanding Pagination

When there are many records, they're divided into pages to improve performance:

```
[< Previous]  Page 2 of 8  [Next >]
```

*Components:*

- *Previous Button*: Go to the previous page
- *Page Indicator*: Shows current page and total
- *Next Button*: Go to the next page

### Navigating Pages

*To go to the next page:*
1. Scroll to the bottom of the table
2. Tap/click the "Next >" button
3. The next page of records loads

*To go to the previous page:*
1. Scroll to the bottom of the table
2. Tap/click the "< Previous" button
3. The previous page of records loads

*Button States:*

- *Enabled*: Dark text, clickable
- *Disabled*: Gray text, not clickable
  - "Previous" is disabled on page 1
  - "Next" is disabled on the last page

### Page Size

The number of records per page is typically:
- *Mobile*: 10-20 records per page
- *Desktop*: 20-50 records per page

This is configured by your administrator and cannot be changed by end users.

### Finding Specific Records Across Pages

*Strategy 1: Use Search*
1. Search for the record instead of browsing pages
2. Faster than manual pagination

*Strategy 2: Sort First*
1. Sort by a relevant column
2. Estimate which page the record is on
3. Navigate to that approximate page

*Strategy 3: Note Record Numbers*
1. Remember the record number
2. Estimate: Record 250 is likely on page 13 (if 20 per page)

## Viewing Actions

### Refreshing Data

To update the view with the latest data:

*Methods:*

| Method | How To | Platform |
| --- | --- | --- |
| Pull to Refresh | Pull down from top of screen | Mobile |
| Refresh Button | Tap refresh icon if available | All |
| Keyboard | Press F5 or Ctrl+R | Desktop |
| Navigate Away | Switch sections and return | All |

> **Warning**: **Refresh Caution**
>
> Refreshing may reset your current position, sort order, and search filters. Use it only when you need to ensure you're viewing the latest data.

### Zooming (Mobile)

On mobile devices, you may need to zoom for better readability:

*To Zoom In:*
- *Pinch Out*: Place two fingers on screen and spread apart
- *Double Tap*: Quickly tap twice on text or tables

*To Zoom Out:*
- *Pinch In*: Place two fingers on screen and bring together
- *Double Tap*: Double tap again to return to normal size

*Reset Zoom:*
- Double tap with two fingers
- Or adjust to fit screen automatically

### Landscape vs Portrait (Mobile)

Rotate your device for different views:

/ Portrait Mode (Vertical):
  - Better for scrolling long lists
  - Narrower tables may stack columns
  - Easier one-handed use

/ Landscape Mode (Horizontal):
  - See more columns at once
  - Better for wide tables
  - Easier to read lengthy text

The app automatically adjusts to your device orientation.

## User Profile Actions

### Viewing Your Profile

To see your account information:

1. Open the navigation menu (☰)
2. Look at the top section
3. See your profile details:
   - Your name
   - Your email address
   - Your role

*Example:*

```
┌─────────────────────────────┐
│  👤 Jane Doe               │
│     jane.doe@company.com   │
│     Role: Manager          │
├─────────────────────────────┤
```

### Understanding Your Role

Your role determines what you can see and do:

| Role | Access Level |
| --- | --- |
| User | - View standard data tables
    - Search and filter records
    - View own profile |
| Manager | - All User permissions, plus:
    - Access to additional reports
    - View team data
    - Access to analytics |
| Admin | - All Manager permissions, plus:
    - View system information
    - Access admin dashboard
    - See all users and roles |

If you need different permissions, contact your system administrator.

## Logout Actions

### Logging Out

To safely end your session:

1. Open the navigation menu (☰)
2. Scroll to the bottom
3. Tap "Logout"
4. Confirm if prompted
5. You're returned to the login screen

*What Happens:*
- Your session is terminated
- Your credentials are cleared
- You must log in again to access the app
- Your data remains safe and unchanged

### When to Logout

*Always logout when:*
- Using a shared or public device
- Finished for the day
- Leaving your device unattended
- Switching users

*Optional to logout when:*
- Using your personal device
- Returning soon
- The device is secure

The app will automatically log you out after 30 minutes of inactivity.

> **Warning**: **Security Best Practice**
>
> Always log out when using the app on:
> - Public computers (libraries, internet cafes)
> - Shared workstations
> - Borrowed devices
> - Any untrusted device

## Keyboard Shortcuts (Desktop)

For faster navigation on desktop computers:

| Shortcut | Action |
| --- | --- |
| Ctrl + F (Cmd + F) | Open search |
| Esc | Close search or go back |
| Alt + M (Cmd + M) | Open/close menu |
| F5 or Ctrl + R | Refresh page |
| Backspace | Go back |
| Tab | Move to next field or button |
| Shift + Tab | Move to previous field or button |
| Enter | Activate selected button or link |
| Arrow Keys | Navigate through tables |

*Note:* Keyboard shortcuts may vary by browser and operating system.

## Common Task Workflows

### Task: Find a Specific Customer

```
1. Open menu (☰)
2. Navigate to "Customers"
3. Open search (🔍)
4. Type customer name or email
5. Tap the matching record
6. View customer details
7. Tap back (←) when done
```

### Task: View Recent Orders

```
1. Open menu (☰)
2. Navigate to "Orders"
3. Tap "Date" column header twice (sort newest first)
4. Browse the most recent orders
5. Tap any order to see details
```

### Task: Find Products Under $50

```
1. Open menu (☰)
2. Navigate to "Products"
3. Tap "Price" column header (sort ascending)
4. Browse the lowest-priced items
5. Products under $50 appear first
```

### Task: Export or Print (If Available)

Some apps may include export or print functionality:

```
1. Navigate to the data you want to export
2. Look for export icon (📥) or print icon (🖨️)
3. Tap the icon
4. Choose format (PDF, CSV, etc.)
5. Confirm and download/print
```

*Note:* Export and print features are planned for future versions.

## Tips for Efficient Usage

### Speed Tips

1. *Use Search Instead of Browsing*
   - Faster to search than scroll through pages
   - Be specific with search terms

2. *Learn Keyboard Shortcuts*
   - Desktop users save time with shortcuts
   - Practice common shortcuts daily

3. *Master Swipe Gestures*
   - Mobile users benefit from gesture navigation
   - Faster than tapping buttons

4. *Sort Before Browsing*
   - Organize data before reading
   - Find patterns more easily

5. *Bookmark Frequent Sections*
   - Use browser bookmarks for common pages
   - Quick access to your most-used sections

### Organization Tips

1. *Use Consistent Search Terms*
   - Standardize how you search
   - Makes finding data faster over time

2. *Note Record Numbers*
   - Write down important record numbers
   - Easy reference for discussions

3. *Know Your Data Structure*
   - Understand what each section contains
   - Navigate more confidently

4. *Combine Search and Sort*
   - Search to narrow results
   - Sort to organize matches

---

> **Success**: **Master the Basics**
>
> Practice these commands regularly to become proficient. Continue to *reference.typ* for comprehensive feature documentation or *troubleshooting.typ* if you encounter issues.
