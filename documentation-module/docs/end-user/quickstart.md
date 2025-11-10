# Quickstart Guide

This guide will walk you through using the FlutterGristAPI application for the first time. Follow these steps to get started quickly and confidently.

## Before You Begin

Make sure you have:

- *Login Credentials*: Your administrator should have provided you with:
  - Email address (used as your username)
  - Temporary or permanent password
- *App Access*: The app installed on your device or access to the web version
- *Device*: A smartphone, tablet, or computer

> **Note**: **First Time User?**
>
> If you don't have login credentials yet, contact your system administrator or IT department. They will create your account and send you your login information.

## Step 1: Launch the Application

### On Mobile (iOS/Android)

1. Find the app icon on your home screen
2. Tap the icon to open the app
3. Wait for the login screen to appear

### On Desktop/Web

1. Open your web browser
2. Navigate to the URL provided by your administrator
3. The login page will load automatically

> **Warning**: **Bookmark the Login Page**
>
> Save the web address in your browser's bookmarks for easy access in the future.

## Step 2: First-Time Login

The login screen is simple and straightforward:

```
┌─────────────────────────────────────┐
│                                     │
│     🏢 Welcome to [App Name]       │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Email                         │ │
│  │ your.email@company.com        │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ Password                      │ │
│  │ ●●●●●●●●                      │ │
│  └───────────────────────────────┘ │
│                                     │
│         [ Login ]                   │
│                                     │
└─────────────────────────────────────┘
```

### Login Steps:

1. *Tap/Click* the "Email" field
2. *Type* your email address exactly as provided
   - Example: `john.smith@company.com`
   - Be careful with spelling and capitalization

3. *Tap/Click* the "Password" field
4. *Type* your password
   - The password is case-sensitive (uppercase and lowercase matter)
   - You'll see dots (●●●) instead of characters for security

5. *Tap/Click* the "Login" button

### What Happens Next:

- The app validates your credentials
- A loading indicator shows while you're being logged in
- If successful, you'll see the home screen
- If there's an error, you'll see a message (see Troubleshooting section)

> **Warning**: **Password Best Practices**
>
> - Never share your password with anyone
> - Use a strong, unique password
> - Change your password if you suspect it's been compromised
> - The app may automatically log you out after a period of inactivity for security

## Step 3: Understanding the Home Screen

After successful login, you'll see the main interface:

```
┌─────────────────────────────────────┐
│ ☰  Home                    🔍       │
├─────────────────────────────────────┤
│                                     │
│     Welcome, John!                  │
│                                     │
│     You have access to:             │
│     • Products                      │
│     • Customers                     │
│     • Orders                        │
│     • Reports                       │
│                                     │
│     Tap the menu (☰) to navigate.  │
│                                     │
└─────────────────────────────────────┘
```

*Key Elements:*

- *Menu Icon (☰)*: Top-left corner - opens navigation drawer
- *Page Title*: Center - shows current page name
- *Search Icon (🔍)*: Top-right corner - opens search functionality
- *Content Area*: Main area - displays information

## Step 4: Opening the Navigation Menu

The navigation menu gives you access to all sections of the app:

### How to Open the Menu:

*Method 1 (Tap):*
1. Tap the menu icon (☰) in the top-left corner

*Method 2 (Swipe - Mobile Only):*
1. Swipe from the left edge of the screen toward the right

### The Navigation Drawer:

```
┌─────────────────────────────┐
│  👤 John Smith             │
│     john.smith@company.com │
│     Role: User             │
├─────────────────────────────┤
│  🏠 Home                   │
│  📦 Products               │
│  👥 Customers              │
│  📋 Orders                 │
│  📊 Reports                │
│  ℹ️  About                 │
├─────────────────────────────┤
│  🚪 Logout                 │
└─────────────────────────────┘
```

*The menu shows:*

- *Your Profile* at the top:
  - Your name
  - Your email address
  - Your role (User, Manager, Admin, etc.)

- *Navigation Items* in the middle:
  - All sections you can access
  - Icons help identify each section
  - Tap any item to navigate there

- *Logout Button* at the bottom:
  - Tap to safely log out of the app

## Step 5: Viewing Data

Let's view some data by navigating to a section:

### Example: Viewing Products

1. *Open* the navigation menu (tap ☰)
2. *Tap* "Products" in the menu
3. *See* a list of products displayed in a table

The table view looks like this:

| # | Product Name | Category | Price |
| --- | --- | --- | --- |
| 1 | Laptop Pro 15 | Electronics | $1,299 |
| 2 | Office Chair | Furniture | $299 |
| 3 | Wireless Mouse | Electronics | $29 |
| 4 | Desk Lamp | Furniture | $49 |
| 5 | USB Cable | Electronics | $9 |

### Understanding the Table:

- *# Column*: Sequential record number (for easy reference)
- *Data Columns*: Information about each item
- *Rows*: Each row is one record/item
- *Scrolling*: Swipe up/down (mobile) or scroll (desktop) to see more

### Pagination:

At the bottom of the table, you'll see:

```
[< Previous]  Page 1 of 5  [Next >]
```

- *Next Button*: See the next page of results
- *Previous Button*: Return to the previous page
- *Page Indicator*: Shows current page and total pages

## Step 6: Searching for Data

To quickly find what you're looking for:

### Using Search:

1. *Tap* the search icon (🔍) in the top-right corner
2. A search bar appears at the top
3. *Type* what you're looking for
   - Example: Type "laptop" to find laptop products
4. Results filter automatically as you type
5. *Clear* the search to see all results again

> **Note**: **Search Tips**
>
> - Search is case-insensitive (finds "Laptop", "laptop", or "LAPTOP")
> - Search looks through all visible columns
> - Use partial words (search "lap" to find "laptop")
> - Clear the search box to reset the view

## Step 7: Viewing Record Details

To see complete information about an item:

### Steps:

1. Find the item in the list
2. *Tap/Click* anywhere on that row
3. The detail page opens showing all information

### Detail Page Example:

```
┌─────────────────────────────────────┐
│ ← Back        Product Details       │
├─────────────────────────────────────┤
│                                     │
│  Record #: 1                        │
│                                     │
│  Product Name:                      │
│  Laptop Pro 15                      │
│                                     │
│  Category:                          │
│  Electronics                        │
│                                     │
│  Price:                             │
│  $1,299.00                          │
│                                     │
│  Description:                       │
│  High-performance laptop with       │
│  15-inch display, perfect for       │
│  professional work and creativity.  │
│                                     │
│  Stock Status:                      │
│  In Stock (23 units)                │
│                                     │
└─────────────────────────────────────┘
```

### Returning to the List:

- *Tap* the back button (← Back) at the top
- *Or swipe* from the left edge (mobile)
- *Or press* the back button on Android devices

## Step 8: Sorting Data

To organize data by a specific column:

### Steps:

1. Look at the column headers in the table
2. *Tap/Click* the column header you want to sort by
3. The data reorganizes:
   - *First tap*: Ascending order (A→Z, 0→9, old→new)
   - *Second tap*: Descending order (Z→A, 9→0, new→old)
   - *Third tap*: Original order

### Example: Sorting Products by Price

```
Before: (Original Order)
#  Name              Price
1  Laptop Pro 15     $1,299
2  Office Chair      $299
3  Wireless Mouse    $29

After: (Sorted by Price, Ascending)
#  Name              Price
3  Wireless Mouse    $29
2  Office Chair      $299
1  Laptop Pro 15     $1,299
```

> **Note**: **Sort Indicators**
>
> Some apps show a small arrow (↑ or ↓) next to the column header to indicate the current sort direction.

## Step 9: Working with Multiple Sections

Your app likely has several sections in the navigation menu:

### Common Section Types:

**Master Pages**: Lists of records (Products, Customers, Orders)
  - Display tables of data
  - Support search, sort, and pagination
  - Tap any row to see details

**Static Pages**: Informational content (Home, About, Help)
  - Display text and images
  - Provide guidance or information
  - No data interaction needed

**Dashboard Pages**: Summary and statistics (Reports, Admin Dashboard)
  - Show charts, graphs, and metrics
  - Provide quick insights
  - May require manager or admin role

### Navigating Between Sections:

1. *Open* the navigation menu (☰)
2. *Tap* the section you want to view
3. The menu closes automatically
4. The new section loads

## Step 10: Logging Out

When you're finished using the app:

### Logout Steps:

1. *Open* the navigation menu (☰)
2. *Scroll* to the bottom if needed
3. *Tap* "Logout" button
4. Confirm if prompted
5. You'll return to the login screen

> **Warning**: **Always Logout on Shared Devices**
>
> If you're using a shared computer or public device, always log out when finished to protect your account security.

### Automatic Logout:

The app may automatically log you out after a period of inactivity (usually 30 minutes). This is a security feature to protect your data. Simply log in again when you return.

## Common First-Time Questions

### "Can I edit the data I see?"

In version 0.1.0, the app is read-only. You can view and search data but cannot edit, create, or delete records. This functionality is planned for future versions.

### "Why can't I see certain menu items?"

Your user role determines what you can access. If you need access to additional sections, contact your administrator.

### "The app logged me out. Why?"

The app automatically logs you out after 30 minutes of inactivity for security. This protects your data if you forget to log out.

### "Can I use the app offline?"

Currently, the app requires an internet connection. Offline support is planned for future versions.

### "How do I change my password?"

Contact your system administrator to reset your password. User-initiated password changes may be available in future versions.

### "Can I access the app from multiple devices?"

Yes! Use the same login credentials on your phone, tablet, and computer. Your data is synchronized automatically.

## Next Steps

Now that you know the basics:

### Learn More:

- *commands.typ*: Complete guide to all user actions (search, filter, navigate)
- *reference.typ*: Comprehensive reference for all features
- *troubleshooting.typ*: Solutions to common problems

### Practice:

1. Navigate to each section in your app
2. Try searching for different items
3. Practice sorting by different columns
4. Open several detail pages
5. Get comfortable with the interface

### Get Help:

- Check the troubleshooting guide for common issues
- Contact your system administrator for account issues
- Ask colleagues who are experienced users
- Refer to this documentation anytime

---

> **Success**: **Congratulations!**
>
> You've completed the quickstart guide and are ready to use the app. Continue to *commands.typ* for detailed information about all available actions, or jump to *troubleshooting.typ* if you encounter any issues.
