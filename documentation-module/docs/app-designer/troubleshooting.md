# Troubleshooting

Common issues and solutions for app designers.

## Configuration Issues

[Table content - see original for details]. Ensure quotes are balanced.",
    priority: "high"
  ),
  (
    issue: "Environment variable not resolved",
    solution: "Verify variable is exported: `echo $GRIST_API_KEY`. Use correct syntax: `${VAR_NAME}`. Restart terminal/IDE after setting.",
    priority: "high"
  ),
  (
    issue: "Page doesn't appear in navigation",
    solution: "Check menu.visible is not false. Verify visible_if evaluates to true. Ensure page ID is unique.",
    priority: "medium"
  ),
  (
    issue: "Icon not displaying",
    solution: "Verify icon name is valid Material Icon. Check spelling (case-sensitive). Use underscores: `admin_panel_settings` not `admin-panel-settings`.",
    priority: "low"
  ),
))

## Grist Connection Issues

[Table content - see original for details]. Ensure document_id is correct.",
    priority: "high"
  ),
  (
    issue: "Authentication fails - 401 Unauthorized",
    solution: "API key is invalid or expired. Generate new key from Grist Profile Settings → API.",
    priority: "high"
  ),
  (
    issue: "Document not found - 404 error",
    solution: "Document ID is incorrect. Check URL in Grist: /doc/YOUR_DOC_ID. Verify API key has access to document.",
    priority: "high"
  ),
  (
    issue: "Table not found error",
    solution: "Table name in YAML doesn't match Grist (case-sensitive). Check spelling. Verify table exists in document.",
    priority: "medium"
  ),
  (
    issue: "Column not found error",
    solution: "Column name doesn't match Grist schema exactly. Check spelling and case. Verify column exists in table.",
    priority: "medium"
  ),
))

## Data Display Issues

[Table content - see original for details],
  (
    issue: "Detail page shows empty form",
    solution: "Verify record ID is passed correctly via on_row_click. Check record_id_param matches parameter name. Ensure record exists in Grist.",
    priority: "medium"
  ),
  (
    issue: "Search not working",
    solution: "Verify enable_search: true. Ensure columns have searchable: true. Check that columns contain searchable data types.",
    priority: "medium"
  ),
  (
    issue: "Sorting doesn't work",
    solution: "Set sortable: true on column. Verify data type is sortable (text, integer, numeric, datetime).",
    priority: "low"
  ),
  (
    issue: "Pagination shows wrong count",
    solution: "Check page_size setting. Verify Grist data hasn't changed. Clear app cache and reload.",
    priority: "low"
  ),
))

## Schema Alignment Issues

[Table content - see original for details],
  (
    issue: "Validation always fails",
    solution: "Check validator configuration. Verify field type supports validator. Test with simpler validation first.",
    priority: "medium"
  ),
  (
    issue: "Format not applying",
    solution: "Verify format.type is correct for field type. Currency requires numeric type. Datetime requires datetime type.",
    priority: "medium"
  ),
  (
    issue: "Reference column not displaying",
    solution: "Reference columns need special handling. For v0.1.0, display the ID. Future versions will support reference resolution.",
    priority: "low"
  ),
))

## Navigation Issues

[Table content - see original for details]. Ensure target page exists in pages array. Check page IDs are unique.",
    priority: "high"
  ),
  (
    issue: "Parameters not passed between pages",
    solution: "Verify pass_param matches record field name. Check record_id_param in target page. Ensure parameter exists in source record.",
    priority: "medium"
  ),
  (
    issue: "Back button not working",
    solution: "Verify navigate_to in back_button config. Ensure target page ID is valid. Check back_button.enabled: true.",
    priority: "medium"
  ),
  (
    issue: "Drawer menu not showing pages",
    solution: "Check menu.visible is not false. Verify visible_if condition. Ensure menu.label is set.",
    priority: "medium"
  ),
))

## User Access Issues

[Table content - see original for details],
  (
    issue: "User sees pages they shouldn't",
    solution: "Check visible_if conditions. Verify user.role value. Test with different user roles. Clear session and re-login.",
    priority: "high"
  ),
  (
    issue: "Admin dashboard not visible to admin",
    solution: "Check visible_if: 'user.role == \"admin\"'. Verify user's role field exactly matches 'admin' (case-sensitive). Check quotes in YAML.",
    priority: "medium"
  ),
))

## Validation Issues

[Table content - see original for details].",
    priority: "medium"
  ),
  (
    issue: "Regex validation always fails",
    solution: "Test regex pattern separately. Escape special characters. Use raw strings. Example: '^[A-Z]+$' for uppercase only.",
    priority: "medium"
  ),
  (
    issue: "Email validation accepts invalid emails",
    solution: "Add custom regex for stricter validation. email validator is basic - augment with regex for domain restrictions.",
    priority: "low"
  ),
  (
    issue: "Range validation not working",
    solution: "Ensure field type is integer or numeric. Check min/max values are correct type. Verify value is within range.",
    priority: "low"
  ),
))

## Performance Issues

[Table content - see original for details],
  (
    issue: "Search is slow",
    solution: "Limit searchable columns to essential fields only. Enable pagination. Consider Grist performance optimization.",
    priority: "low"
  ),
  (
    issue: "App feels sluggish",
    solution: "Reduce page_size for complex pages. Minimize number of validators. Optimize Grist queries. Check network latency.",
    priority: "low"
  ),
))

## Debugging Strategies

### Enable Debug Mode

```yaml
app:
  error_handling:
    show_error_details: true
```

This shows full stack traces and API errors.

### Check Browser Console

For web apps:
1. Open browser DevTools (F12)
2. Check Console tab for errors
3. Check Network tab for API calls
4. Look for failed requests or errors

### Verify API Calls Manually

Test Grist API directly:

```bash
# List all records
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://docs.getgrist.com/api/docs/DOC_ID/tables/TABLE_NAME/records

# Get specific record
curl -H "Authorization: Bearer YOUR_API_KEY" \
  https://docs.getgrist.com/api/docs/DOC_ID/tables/TABLE_NAME/records/123
```

### Simplify Configuration

When debugging:
1. Start with minimal config
2. Add features one at a time
3. Test after each addition
4. Isolate the problematic section

### Check Logs

```bash
# Flutter app logs
flutter run --verbose

# Check for YAML parsing errors
# Check for API connection errors
# Look for schema mismatches
```

## Getting Help

If you're still stuck:

> **Note**: *Before Asking for Help:*
>
> 1. Check this troubleshooting guide
> 2. Verify YAML syntax is valid
> 3. Test Grist API connection manually
> 4. Try with minimal configuration
> 5. Check recent changes in Git
> 6. Review error messages carefully
>
> *When Asking for Help:*
>
> - Describe what you're trying to do
> - Include relevant YAML configuration (remove sensitive data!)
> - Share error messages (full stack trace)
> - Mention what you've already tried
> - Specify versions (Flutter, FlutterGristAPI, Grist)

## Common Fixes Checklist

When something isn't working, try these in order:

- ✅ Validate YAML syntax
- ✅ Check environment variables are set
- ✅ Verify Grist connection with curl
- ✅ Confirm table and column names match exactly
- ✅ Check visible_if conditions
- ✅ Clear app cache and rebuild
- ✅ Review recent configuration changes
- ✅ Test with simpler configuration
- ✅ Check browser/app console for errors
- ✅ Restart development server
