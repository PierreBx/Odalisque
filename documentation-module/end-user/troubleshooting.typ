// End User Troubleshooting Guide - FlutterGristAPI
// Common issues, solutions, and error messages

#import "../common/styles.typ": *

= Troubleshooting Guide

This guide helps you resolve common issues you may encounter while using the FlutterGristAPI application. Issues are organized by category for easy reference.

== Quick Troubleshooting Checklist

Before diving into specific issues, try these quick fixes:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*#*], [*Quick Fix*],
  [1], [Check your internet connection],
  [2], [Close and reopen the app],
  [3], [Refresh the page (F5 or pull down on mobile)],
  [4], [Clear your browser cache (web version)],
  [5], [Make sure you're using the latest app version],
  [6], [Try logging out and logging back in],
)

#info_box(type: "info")[
  **When to Contact Support**

  If none of the solutions in this guide work, contact your system administrator or IT support. Include:
  - What you were doing when the problem occurred
  - The exact error message (if any)
  - Screenshots if possible
  - Your device type and operating system
]

== Login Issues

=== Cannot Log In - Incorrect Password

*Symptoms:*
- Error message: "Invalid email or password"
- Unable to access the app after entering credentials
- Password field clears after attempting login

*Possible Causes:*

#troubleshooting_table((
  (
    issue: "Typing error or caps lock is on",
    solution: [
      - Check that Caps Lock is OFF
      - Retype password carefully
      - Passwords are case-sensitive
      - Watch for extra spaces before or after
    ],
    priority: "high"
  ),
  (
    issue: "Wrong password or forgotten password",
    solution: [
      - Contact your administrator to reset password
      - Request temporary password
      - Never share your password with others
    ],
    priority: "high"
  ),
  (
    issue: "Account not yet activated",
    solution: [
      - Verify with administrator that account is active
      - Check that administrator completed setup
      - Wait for activation email if required
    ],
    priority: "medium"
  ),
))

#info_box(type: "warning")[
  **Security Lockout**

  After several failed login attempts, your account may be temporarily locked for security. Wait 15-30 minutes before trying again, or contact your administrator.
]

=== Cannot Log In - Invalid Email

*Symptoms:*
- Error message: "Invalid email format"
- Error message: "User not found"
- Login button doesn't activate

*Solutions:*

1. *Check Email Format*
   - Must include @ symbol
   - Must have domain (e.g., .com, .org)
   - Example: `user@company.com`

2. *Verify Correct Email*
   - Use exactly the email provided by administrator
   - Check for typos
   - Case usually doesn't matter for email

3. *Account May Not Exist*
   - Contact administrator to create account
   - Verify you're using the correct app instance

=== App Keeps Logging Me Out

*Symptoms:*
- Automatically returned to login screen
- "Session expired" message
- Must log in again frequently

*Causes and Solutions:*

#troubleshooting_table((
  (
    issue: "Automatic timeout after inactivity",
    solution: [
      - Default: 30 minutes of inactivity triggers logout
      - This is a security feature
      - Simply log in again when you return
      - Stay active in the app to maintain session
    ],
    priority: "low"
  ),
  (
    issue: "Poor internet connection",
    solution: [
      - Check your WiFi or mobile data
      - Move closer to WiFi router
      - Switch between WiFi and mobile data
      - Restart your router if needed
    ],
    priority: "high"
  ),
  (
    issue: "App update or server maintenance",
    solution: [
      - Server updates may force logout
      - This is temporary and normal
      - Log in again after maintenance completes
      - Contact administrator for maintenance schedule
    ],
    priority: "medium"
  ),
))

=== Login Page Won't Load

*Symptoms:*
- Blank screen
- "Cannot connect to server" error
- Loading indicator spins indefinitely

*Solutions:*

1. *Check Internet Connection*
   ```
   - Open another website or app
   - Verify internet is working
   - Try switching from WiFi to mobile data or vice versa
   - Restart your WiFi router
   ```

2. *Check Server Status*
   ```
   - Ask colleagues if they can access the app
   - Contact administrator about server status
   - Check for scheduled maintenance
   ```

3. *Clear App Cache*
   - *Mobile*: Settings > Apps > [App Name] > Clear Cache
   - *Web*: Ctrl+Shift+Delete > Clear browsing data
   - Restart the app after clearing cache

4. *Check URL (Web Version)*
   ```
   - Verify you're using the correct URL
   - Check for typos in the address
   - Try accessing from bookmark
   - Contact administrator for correct URL
   ```

== Data Viewing Issues

=== Cannot See Data / Empty Lists

*Symptoms:*
- Lists appear empty
- "No records found" message
- Tables show headers but no rows

*Causes and Solutions:*

#troubleshooting_table((
  (
    issue: "Active search filter",
    solution: [
      - Check if search bar is active
      - Clear search by tapping X in search bar
      - Make sure search field is empty
      - Try different search terms
    ],
    priority: "high"
  ),
  (
    issue: "No data exists yet",
    solution: [
      - The table may genuinely be empty
      - Contact administrator to add data
      - Check if this is expected for new setup
    ],
    priority: "low"
  ),
  (
    issue: "Permission/role restrictions",
    solution: [
      - Your role may not have access to this data
      - Contact administrator to check permissions
      - Verify you need access to this section
    ],
    priority: "medium"
  ),
  (
    issue: "Connection issue",
    solution: [
      - Data failed to load from server
      - Pull down to refresh (mobile)
      - Press F5 to reload (desktop)
      - Check internet connection
    ],
    priority: "high"
  ),
))

=== Data Not Updating / Stale Data

*Symptoms:*
- Seeing old information
- Changes made by others not visible
- Data doesn't match what colleagues see

*Solutions:*

1. *Refresh the View*
   - *Mobile*: Pull down from the top of the screen
   - *Desktop*: Press F5 or click refresh button
   - *All*: Navigate away and back to the section

2. *Check Connection*
   - Verify stable internet connection
   - Poor connection can cause caching
   - Switch to stronger WiFi if available

3. *Clear Cache*
   - Close and reopen the app
   - Clear browser cache (web version)
   - Force stop and restart (mobile app)

4. *Verify Data Change*
   - Confirm with colleague that change was saved
   - Check if change is visible to others
   - Contact administrator if issue persists

=== Cannot View Record Details

*Symptoms:*
- Tapping a row does nothing
- Detail page doesn't open
- Error when trying to view details

*Solutions:*

#troubleshooting_table((
  (
    issue: "Tapping wrong area",
    solution: [
      - Tap anywhere on the row, not just one column
      - Avoid tapping column headers (they sort instead)
      - Try tapping the record number column
    ],
    priority: "low"
  ),
  (
    issue: "Detail page not configured",
    solution: [
      - Some tables may not have detail views
      - This is configured by app designer
      - All information may be visible in the table
    ],
    priority: "low"
  ),
  (
    issue: "Loading error",
    solution: [
      - Wait a moment and try again
      - Refresh the page
      - Check internet connection
      - Try a different record
    ],
    priority: "high"
  ),
))

=== Columns Are Cut Off / Not Visible

*Symptoms:*
- Cannot see all columns
- Data appears truncated
- Horizontal scrolling doesn't work

*Solutions:*

1. *Scroll Horizontally*
   - *Mobile*: Swipe left/right on the table
   - *Desktop*: Use mouse wheel while hovering over table
   - Some tables are wider than the screen

2. *Rotate Device*
   - *Mobile*: Switch to landscape mode
   - Provides more horizontal space
   - Better view of wide tables

3. *Zoom Out*
   - *Mobile*: Pinch to zoom out
   - *Desktop*: Ctrl + Minus key (Ctrl + -)
   - Fits more content on screen

4. *Check Configuration*
   - Some columns may be hidden by design
   - Contact administrator to request visible columns
   - Essential columns should be visible

== Search and Filter Issues

=== Search Not Working

*Symptoms:*
- Search returns no results
- All records still visible after searching
- Search bar doesn't accept input

*Solutions:*

#troubleshooting_table((
  (
    issue: "Search term too specific",
    solution: [
      - Try broader search terms
      - Use partial words ("lap" instead of "laptop")
      - Check for typos in search term
      - Remove special characters
    ],
    priority: "medium"
  ),
  (
    issue: "Case or format mismatch",
    solution: [
      - Search should be case-insensitive
      - Try different capitalization
      - Remove extra spaces
      - Try searching for numbers instead of formatted values
    ],
    priority: "low"
  ),
  (
    issue: "Searching in wrong column",
    solution: [
      - Search looks through all visible columns
      - Hidden columns are not searched
      - Try different search terms that might appear in visible columns
    ],
    priority: "medium"
  ),
  (
    issue: "Search functionality disabled",
    solution: [
      - Try using the search icon again
      - Refresh the page
      - Log out and back in
      - Contact administrator if persistent
    ],
    priority: "high"
  ),
))

=== Cannot Clear Search

*Symptoms:*
- X button in search doesn't work
- Cannot remove search filter
- Stuck viewing filtered results

*Solutions:*

1. *Multiple Clear Methods*
   ```
   - Tap the X button in search bar
   - Delete all text using backspace
   - Tap search icon again to close
   - Refresh the page
   ```

2. *Force Reset*
   ```
   - Navigate to a different section
   - Return to the original section
   - Search filter will be cleared
   ```

3. *Restart App*
   ```
   - Close the app completely
   - Reopen the app
   - Navigate to the section again
   ```

=== Sort Not Working

*Symptoms:*
- Clicking column header doesn't sort
- Data remains in same order
- No sort indicator appears

*Solutions:*

1. *Check Column Sortability*
   - Not all columns may be sortable
   - Try clicking other column headers
   - Contact administrator if needed columns aren't sortable

2. *Multiple Clicks*
   - Try clicking the header 2-3 times
   - Cycle through: ascending → descending → original

3. *Clear Other Filters*
   - Clear any active searches
   - Refresh the view
   - Try sorting again

4. *Technical Issue*
   - Refresh the page
   - Close and reopen app
   - Contact support if persistent

== Navigation Issues

=== Back Button Doesn't Work

*Symptoms:*
- Cannot return to previous screen
- Stuck on detail page
- Back button appears disabled

*Solutions:*

#troubleshooting_table((
  (
    issue: "Already at top of navigation stack",
    solution: [
      - You may be at the home screen already
      - Use menu to navigate instead
      - Back button only works after navigating forward
    ],
    priority: "low"
  ),
  (
    issue: "Alternative back methods",
    solution: [
      - Use device back button (Android)
      - Use browser back button (Web)
      - Swipe from left edge (iOS)
      - Use menu to navigate to different section
    ],
    priority: "medium"
  ),
  (
    issue: "App frozen or unresponsive",
    solution: [
      - Wait a moment for app to respond
      - Close and reopen app
      - Restart device if necessary
    ],
    priority: "high"
  ),
))

=== Menu Won't Open

*Symptoms:*
- Tapping menu icon does nothing
- Swipe gesture doesn't work
- Menu is stuck closed

*Solutions:*

1. *Try All Methods*
   - Tap menu icon (☰)
   - Swipe from left edge (mobile)
   - Press Alt+M or Cmd+M (desktop)

2. *App State Issue*
   - Close and reopen the app
   - Refresh the page
   - Log out and back in

3. *Screen Position*
   - Make sure you're swiping from the very edge
   - Start swipe outside the screen area
   - Swipe firmly and quickly

4. *Technical Glitch*
   - Restart your device
   - Update the app if update available
   - Contact support if persistent

=== Wrong Page Opens

*Symptoms:*
- Clicking a menu item opens different page
- Detail page shows wrong record
- Navigation is unpredictable

*Solutions:*

1. *Clear App Cache*
   - Close the app completely
   - Clear app cache (mobile) or browser cache (web)
   - Reopen and try again

2. *Slow Connection*
   - Tap may have registered twice
   - Wait for page to fully load before tapping
   - Ensure stable internet connection

3. *App Bug*
   - Report to administrator with details
   - Note which items cause the issue
   - Use alternative navigation temporarily

== Performance Issues

=== App Is Slow / Laggy

*Symptoms:*
- Delays when tapping buttons
- Slow scrolling
- Pages take long to load
- Stuttering animations

*Solutions:*

#troubleshooting_table((
  (
    issue: "Poor internet connection",
    solution: [
      - Check WiFi signal strength
      - Switch to mobile data or different WiFi
      - Move closer to router
      - Restart router if needed
    ],
    priority: "high"
  ),
  (
    issue: "Device memory/resources",
    solution: [
      - Close other apps running in background
      - Restart your device
      - Free up device storage space
      - Update operating system
    ],
    priority: "medium"
  ),
  (
    issue: "Large dataset",
    solution: [
      - Use search to narrow results
      - Sort data before browsing
      - Navigate by pages instead of scrolling
      - This is expected with thousands of records
    ],
    priority: "low"
  ),
  (
    issue: "Server load",
    solution: [
      - Many users accessing simultaneously
      - Wait for off-peak hours
      - Contact administrator about server capacity
    ],
    priority: "medium"
  ),
))

=== Page Won't Load / Infinite Loading

*Symptoms:*
- Loading spinner never stops
- Page stays blank
- "Loading..." message persists

*Solutions:*

1. *Wait Appropriately*
   - Large datasets may take 10-30 seconds
   - Don't tap repeatedly while loading
   - Look for progress indicators

2. *Force Refresh*
   - Pull down to refresh (mobile)
   - Press F5 (desktop)
   - Navigate away and back

3. *Check Connection*
   - Verify internet is working
   - Test in other apps or websites
   - Switch connection type

4. *Clear and Retry*
   - Close app completely
   - Clear cache
   - Reopen and try again

5. *Report Timeout*
   - If loading exceeds 60 seconds, it's likely an error
   - Contact administrator
   - Provide details about which page/data

=== App Crashes or Freezes

*Symptoms:*
- App closes unexpectedly
- Screen becomes unresponsive
- Must force quit the app

*Solutions:*

1. *Immediate Actions*
   ```
   - Force quit the app
   - Wait 10 seconds
   - Reopen the app
   - Try your action again
   ```

2. *Device Issues*
   ```
   - Restart your device
   - Update operating system
   - Free up storage space (need at least 1GB free)
   - Check for app updates
   ```

3. *Specific Action Causes Crash*
   ```
   - Note what you were doing
   - Try different approach
   - Report to administrator with:
     - What you were doing
     - Which record/page
     - How consistently it crashes
   ```

4. *Persistent Crashes*
   ```
   - Uninstall and reinstall app (mobile)
   - Clear all browser data (web)
   - Use different device temporarily
   - Contact support immediately
   ```

== Display and UI Issues

=== Text Is Too Small / Hard to Read

*Symptoms:*
- Cannot read text clearly
- Must strain to see information
- Font size uncomfortable

*Solutions:*

1. *Device Settings*
   - *iOS*: Settings > Display & Brightness > Text Size
   - *Android*: Settings > Display > Font Size
   - *Windows*: Settings > Ease of Access > Display
   - *Mac*: System Preferences > Accessibility > Display

2. *Browser Zoom (Web)*
   - Ctrl + Plus (Ctrl +) to zoom in
   - Ctrl + Minus (Ctrl -) to zoom out
   - Ctrl + 0 to reset to 100%

3. *Mobile Zoom*
   - Pinch to zoom in/out
   - Double-tap to zoom
   - Some sections may not zoom well

4. *Request Accessibility*
   - Contact administrator
   - May be able to adjust app settings
   - Describe your accessibility needs

=== Buttons Not Working

*Symptoms:*
- Tapping buttons has no effect
- Buttons appear grayed out
- Cannot activate features

*Solutions:*

#troubleshooting_table((
  (
    issue: "Button is disabled",
    solution: [
      - Gray or faded buttons are disabled
      - Not all features available to all roles
      - May require different context (e.g., must select item first)
    ],
    priority: "low"
  ),
  (
    issue: "Touch screen issue",
    solution: [
      - Clean your screen
      - Remove screen protector temporarily
      - Try with stylus or different finger
      - Test touch in other apps
    ],
    priority: "medium"
  ),
  (
    issue: "App not responding",
    solution: [
      - Wait a few seconds
      - Refresh the page
      - Close and reopen app
      - Restart device
    ],
    priority: "high"
  ),
))

=== Images Not Loading

*Symptoms:*
- Broken image icons
- Blank spaces where images should be
- "Image not found" messages

*Solutions:*

1. *Connection Issue*
   - Images require good internet connection
   - Wait for connection to stabilize
   - Refresh the page

2. *Missing Images*
   - Images may not be uploaded yet
   - Contact administrator
   - This may be expected

3. *Browser/Cache Issue*
   - Clear browser cache
   - Hard refresh (Ctrl+Shift+R)
   - Try different browser

=== Layout Looks Wrong / Broken

*Symptoms:*
- Elements overlapping
- Text cut off
- Strange spacing or alignment
- UI appears corrupted

*Solutions:*

1. *Screen Size Issue*
   - Rotate device (mobile)
   - Adjust window size (desktop)
   - Try different device

2. *Browser Compatibility*
   - Use Chrome, Safari, or Firefox
   - Update browser to latest version
   - Avoid old or unsupported browsers

3. *Zoom Level*
   - Reset zoom to 100% (Ctrl+0)
   - Don't zoom beyond 150%

4. *Report Bug*
   - Take screenshot
   - Send to administrator
   - Include device and browser info

== Error Messages

=== "Session Expired"

*Meaning:* You've been logged out due to inactivity.

*Solution:*
1. Tap "OK" on the error message
2. Log in again with your credentials
3. Return to what you were doing
4. Stay active to prevent auto-logout (30 minutes)

=== "Network Error" / "Cannot Connect to Server"

*Meaning:* Lost connection to the server.

*Solutions:*
1. Check your internet connection
2. Wait a moment and try again
3. Refresh the page
4. Contact administrator if server is down

=== "Permission Denied" / "Access Denied"

*Meaning:* Your role doesn't have access to this feature.

*Solutions:*
1. Verify you need access to this feature
2. Contact administrator to:
   - Upgrade your role
   - Grant specific permissions
   - Explain which features you need
3. Use alternative methods to accomplish your goal

=== "Invalid Request" / "Bad Request"

*Meaning:* Something went wrong with your request.

*Solutions:*
1. Try the action again
2. Refresh the page
3. Clear cache and try again
4. If persistent, contact administrator with:
   - What you were trying to do
   - Step-by-step reproduction
   - Screenshot of error

=== "Server Error" / "Internal Server Error"

*Meaning:* Problem on the server side, not your device.

*Solutions:*
1. Wait a few minutes and try again
2. Contact administrator to report server issue
3. Try again later
4. Use different section of app if needed

=== "Data Not Found" / "Record Not Found"

*Meaning:* The record you requested doesn't exist or was deleted.

*Solutions:*
1. Verify the record number or identifier
2. Search for the record
3. It may have been deleted by administrator
4. Return to the list and select a different record

== Getting Additional Help

=== Before Contacting Support

Gather this information:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Item*], [*How to Find*],

  [Device Type], [iPhone, Android phone, Windows PC, Mac, etc.],
  [Operating System], [iOS 17, Android 13, Windows 11, macOS 14, etc.],
  [App Version], [Check app settings or about page],
  [Error Message], [Take screenshot or write down exact message],
  [Steps to Reproduce], [Write down what you did before the error],
  [Frequency], [Does it happen every time? Randomly?],
)

=== Contacting Your Administrator

Include in your message:

1. *Subject Line*: Brief description of issue
   - Example: "Cannot view customer details - Record Not Found error"

2. *Description*:
   - What you were trying to do
   - What actually happened
   - What you expected to happen

3. *Details*:
   - Device and operating system
   - Screenshots or photos
   - Error messages
   - When it first occurred

4. *Impact*:
   - Can you work around it?
   - Is it blocking your work?
   - How urgently do you need resolution?

*Example Support Request:*

```
Subject: Cannot Login - Invalid Password Error

Hi [Administrator],

I'm unable to log into the app. When I enter my
credentials, I get an "Invalid email or password" error.

Details:
- Device: iPhone 13, iOS 17.2
- Email I'm using: jane.doe@company.com
- Started happening: This morning (Nov 10)
- I've tried: Restarting app, checking caps lock

I've successfully logged in before with these credentials.
Could you please check if my account is active?

This is blocking my work. I need to check customer
information today.

Thanks,
Jane
```

=== Emergency Contact

For urgent issues that prevent work:

1. Contact your direct supervisor
2. Try alternate device or method
3. Document issue for administrator
4. Use temporary workaround if available

#section_separator()

#info_box(type: "success")[
  **Most Issues Are Simple**

  95% of issues can be resolved by:
  1. Checking internet connection
  2. Refreshing the page
  3. Closing and reopening the app
  4. Logging out and back in

  If these don't work, this guide and your administrator are here to help!
]
