= Command Reference

== Introduction

This comprehensive command reference covers all essential operations for FlutterGristAPI data administration, including backup operations, restore procedures, data validation, and system maintenance.

== Backup Commands

=== Create Backups

#command_table((
  (
    command: "/opt/scripts/backup.sh daily",
    description: "Create a daily backup with 7-day retention",
    example: "sudo /opt/scripts/backup.sh daily"
  ),
  (
    command: "/opt/scripts/backup.sh weekly",
    description: "Create a weekly backup with 28-day retention",
    example: "sudo /opt/scripts/backup.sh weekly"
  ),
  (
    command: "/opt/scripts/backup.sh monthly",
    description: "Create a monthly backup with 90-day retention",
    example: "sudo /opt/scripts/backup.sh monthly"
  ),
))

*Manual backup with custom name*:
```bash
# Create timestamped backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
tar -czf /opt/backups/manual/backup_${TIMESTAMP}.tar.gz \
  /opt/grist/data \
  /opt/flutter_grist_app/config

# Generate checksum
cd /opt/backups/manual
sha256sum backup_${TIMESTAMP}.tar.gz > backup_${TIMESTAMP}.tar.gz.sha256
```

=== View Backup Information

#command_table((
  (
    command: "/opt/scripts/backup.sh stats",
    description: "Display backup statistics and summary",
    example: "sudo /opt/scripts/backup.sh stats"
  ),
  (
    command: "/opt/scripts/restore.sh --list",
    description: "List all available backups with dates and sizes",
    example: "sudo /opt/scripts/restore.sh --list"
  ),
))

*List backups with details*:
```bash
# List all backups sorted by date
find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' |
  sort -rn |
  while read timestamp path; do
    date=$(date -d "@${timestamp}" "+%Y-%m-%d %H:%M:%S")
    size=$(du -h "$path" | cut -f1)
    echo "$date - $(basename $path) ($size)"
  done

# Count backups by type
echo "Daily: $(find /opt/backups/daily -name "*.tar.gz" | wc -l)"
echo "Weekly: $(find /opt/backups/weekly -name "*.tar.gz" | wc -l)"
echo "Monthly: $(find /opt/backups/monthly -name "*.tar.gz" | wc -l)"

# Check disk usage
du -sh /opt/backups/*
```

=== Verify Backups

#command_table((
  (
    command: "sha256sum -c <file>.sha256",
    description: "Verify backup checksum integrity",
    example: "sha256sum -c backup.tar.gz.sha256"
  ),
  (
    command: "tar -tzf <file>.tar.gz",
    description: "Test archive integrity without extracting",
    example: "tar -tzf backup.tar.gz | head -20"
  ),
))

*Comprehensive backup verification*:
```bash
#!/bin/bash
# Verify specific backup

BACKUP="$1"

# Check file exists
if [ ! -f "$BACKUP" ]; then
    echo "Error: Backup file not found"
    exit 1
fi

# Verify checksum
echo "Checking checksum..."
cd "$(dirname $BACKUP)"
if sha256sum -c "$(basename ${BACKUP}.sha256)" --quiet; then
    echo "✓ Checksum OK"
else
    echo "✗ Checksum FAILED"
    exit 1
fi

# Test archive
echo "Testing archive integrity..."
if tar -tzf "$BACKUP" > /dev/null 2>&1; then
    echo "✓ Archive OK"
else
    echo "✗ Archive CORRUPTED"
    exit 1
fi

# Check size
SIZE=$(stat -c%s "$BACKUP")
if [ $SIZE -gt 1000000 ]; then
    echo "✓ Size OK: $(numfmt --to=iec-i --suffix=B $SIZE)"
else
    echo "⚠ Size suspicious: $(numfmt --to=iec-i --suffix=B $SIZE)"
fi

echo "Verification complete"
```

=== Cleanup Old Backups

#command_table((
  (
    command: "/opt/scripts/backup.sh cleanup",
    description: "Remove backups older than retention period",
    example: "sudo /opt/scripts/backup.sh cleanup"
  ),
))

*Manual cleanup*:
```bash
# Remove daily backups older than 7 days
find /opt/backups/daily -name "*.tar.gz" -mtime +7 -delete
find /opt/backups/daily -name "*.sha256" -mtime +7 -delete

# Remove weekly backups older than 28 days
find /opt/backups/weekly -name "*.tar.gz" -mtime +28 -delete

# Remove monthly backups older than 90 days
find /opt/backups/monthly -name "*.tar.gz" -mtime +90 -delete

# Show space freed
echo "Cleanup complete. Current usage:"
du -sh /opt/backups/*
```

== Restore Commands

=== Basic Restore

#command_table((
  (
    command: "/opt/scripts/restore.sh --latest",
    description: "Restore from the most recent backup",
    example: "sudo /opt/scripts/restore.sh --latest"
  ),
  (
    command: "/opt/scripts/restore.sh <file>",
    description: "Restore from specific backup file",
    example: "sudo /opt/scripts/restore.sh /opt/backups/daily/backup.tar.gz"
  ),
))

*Non-interactive restore*:
```bash
# Auto-confirm restore (use with caution!)
echo "yes" | sudo /opt/scripts/restore.sh --latest

# Restore to alternate location
BACKUP="/opt/backups/daily/backup.tar.gz"
RESTORE_DIR="/tmp/restore"

mkdir -p "$RESTORE_DIR"
tar -xzf "$BACKUP" -C "$RESTORE_DIR"
echo "Restored to: $RESTORE_DIR"
```

=== Selective Restore

*Extract specific files from backup*:
```bash
# List contents
tar -tzf backup.tar.gz | grep "grist_data"

# Extract only Grist data
tar -xzf backup.tar.gz \
  --wildcards "*/grist_data/*" \
  -C /tmp/

# Extract specific document
tar -xzf backup.tar.gz \
  --wildcards "*/grist_data/docs/mydoc.grist" \
  -C /tmp/

# Extract configuration only
tar -xzf backup.tar.gz \
  --wildcards "*/app_config/*" \
  -C /tmp/
```

*Restore single table from Grist document*:
```bash
#!/bin/bash
# restore-table.sh

BACKUP="$1"
TABLE="$2"
OUTPUT="/tmp/${TABLE}.csv"

# Extract backup
TEMP="/tmp/restore-$$"
mkdir -p "$TEMP"
tar -xzf "$BACKUP" -C "$TEMP"

# Find Grist document
GRIST_DOC=$(find "$TEMP" -name "*.grist" | head -1)

# Export table
sqlite3 "$GRIST_DOC" << EOF
.headers on
.mode csv
.output $OUTPUT
SELECT * FROM $TABLE;
EOF

echo "Table exported to: $OUTPUT"
rm -rf "$TEMP"
```

== Data Integrity Commands

=== SQLite Database Operations

#command_table((
  (
    command: "sqlite3 <file> 'PRAGMA integrity_check;'",
    description: "Check SQLite database integrity",
    example: "sqlite3 mydoc.grist 'PRAGMA integrity_check;'"
  ),
  (
    command: "sqlite3 <file> 'PRAGMA quick_check;'",
    description: "Quick database health check",
    example: "sqlite3 mydoc.grist 'PRAGMA quick_check;'"
  ),
  (
    command: "sqlite3 <file> '.schema'",
    description: "Display database schema",
    example: "sqlite3 mydoc.grist '.schema Table1'"
  ),
))

*Common SQLite operations*:
```bash
# Open Grist document
sqlite3 /opt/grist/data/docs/mydoc.grist

# Interactive SQLite commands:
.tables                    # List all tables
.schema Table1             # Show table structure
.headers on                # Enable column headers
.mode column               # Pretty print output

# Queries:
SELECT COUNT(*) FROM Users;
SELECT * FROM _grist_Tables;

# Export table to CSV:
.mode csv
.output /tmp/export.csv
SELECT * FROM Users;
.quit
```

*Check all Grist documents*:
```bash
# Check integrity of all documents
for doc in /opt/grist/data/docs/*.grist; do
    echo "Checking: $(basename $doc)"
    sqlite3 "$doc" "PRAGMA integrity_check;" |
        grep -v "^ok$" && echo "  ⚠ Issues" || echo "  ✓ OK"
done

# Check foreign keys
for doc in /opt/grist/data/docs/*.grist; do
    echo "Checking: $(basename $doc)"
    sqlite3 "$doc" "PRAGMA foreign_key_check;" |
        head -5 && echo "  ⚠ FK issues" || echo "  ✓ FK OK"
done
```

=== Data Validation

*Run data validation checks*:
```bash
# Check for NULL values in required fields
sqlite3 /tmp/mydoc.grist << 'EOF'
SELECT 'Missing emails' as issue, COUNT(*) as count
FROM Users WHERE email IS NULL;

SELECT 'Missing names' as issue, COUNT(*) as count
FROM Users WHERE first_name IS NULL OR last_name IS NULL;
EOF

# Check data types
sqlite3 /tmp/mydoc.grist << 'EOF'
SELECT 'Invalid types' as issue,
       id, typeof(age) as actual_type
FROM Users
WHERE typeof(age) != 'integer'
  AND age IS NOT NULL;
EOF

# Check duplicates
sqlite3 /tmp/mydoc.grist << 'EOF'
SELECT email, COUNT(*) as count
FROM Users
GROUP BY email
HAVING COUNT(*) > 1;
EOF
```

=== Corruption Detection

```bash
#!/bin/bash
# detect-corruption.sh

GRIST_DATA="/opt/grist/data"

echo "Scanning for corruption..."

# Check file system
echo "Checking file system..."
dmesg | grep -i "error\|corrupt" | tail -10

# Check Grist documents
echo "Checking Grist documents..."
for doc in "$GRIST_DATA/docs"/*.grist; do
    if [ -f "$doc" ]; then
        # File command check
        file "$doc" | grep -q "SQLite" || echo "⚠ $doc: Not a valid SQLite file"

        # Integrity check
        result=$(sqlite3 "$doc" "PRAGMA integrity_check;" 2>&1)
        if [ "$result" != "ok" ]; then
            echo "⚠ $doc: $result"
        fi
    fi
done

echo "Scan complete"
```

== System Maintenance Commands

=== Disk Management

#command_table((
  (
    command: "df -h /opt/backups",
    description: "Check backup disk space usage",
    example: "df -h /opt/backups"
  ),
  (
    command: "du -sh /opt/grist/data",
    description: "Check Grist data directory size",
    example: "du -sh /opt/grist/data"
  ),
  (
    command: "ncdu /opt/backups",
    description: "Interactive disk usage analyzer",
    example: "sudo apt install ncdu && ncdu /opt/backups"
  ),
))

*Disk space analysis*:
```bash
# Check space by backup type
du -sh /opt/backups/*

# Find largest backups
find /opt/backups -name "*.tar.gz" -type f -printf '%s %p\n' |
  sort -rn |
  head -10 |
  while read size path; do
    echo "$(numfmt --to=iec-i --suffix=B $size) - $(basename $path)"
  done

# Check inode usage
df -i /opt/backups

# Find old backups consuming space
find /opt/backups -name "*.tar.gz" -mtime +90 -ls
```

=== Log Management

#command_table((
  (
    command: "tail -f /var/log/backup.log",
    description: "Follow backup logs in real-time",
    example: "sudo tail -f /var/log/backup.log"
  ),
  (
    command: "grep ERROR /var/log/backup.log",
    description: "Search for errors in backup logs",
    example: "sudo grep ERROR /var/log/backup.log | tail -20"
  ),
  (
    command: "journalctl -u grist-backup.service",
    description: "View systemd service logs",
    example: "sudo journalctl -u grist-backup.service -f"
  ),
))

*Log analysis*:
```bash
# Show backup failures
grep "FAILED\|ERROR" /var/log/backup.log

# Count backup operations by date
awk '/Starting.*backup/ {print $1}' /var/log/backup.log | sort | uniq -c

# Show backup duration trends
grep "Backup completed" /var/log/backup.log |
  grep -oP '\d+\.\d+G' |
  tail -10

# Analyze backup sizes over time
grep "Backup size:" /var/log/backup.log |
  awk '{print $1, $2, $NF}' |
  tail -20

# Check for recent errors
tail -100 /var/log/backup.log | grep -i error
```

=== Service Management

#command_table((
  (
    command: "docker ps | grep grist",
    description: "Check Grist container status",
    example: "docker ps | grep grist"
  ),
  (
    command: "docker logs grist_server",
    description: "View Grist container logs",
    example: "docker logs grist_server --tail 50"
  ),
  (
    command: "systemctl status nginx",
    description: "Check Nginx service status",
    example: "systemctl status nginx"
  ),
))

*Service operations*:
```bash
# Restart services
sudo docker restart grist_server
sudo systemctl restart nginx

# Check service health
docker inspect grist_server | grep -A 5 State
systemctl is-active nginx

# View resource usage
docker stats grist_server --no-stream

# Check ports
sudo netstat -tlnp | grep -E '8484|80|443'
```

=== Cron Job Management

#command_table((
  (
    command: "crontab -l",
    description: "List scheduled backup jobs",
    example: "sudo crontab -l | grep backup"
  ),
  (
    command: "crontab -e",
    description: "Edit cron schedule",
    example: "sudo crontab -e"
  ),
))

*Cron operations*:
```bash
# View backup schedule
sudo crontab -l | grep backup

# Test cron job manually
sudo /opt/scripts/backup.sh daily

# Check cron execution
grep CRON /var/log/syslog | grep backup | tail -10

# Verify next execution time
# (requires 'at' package)
echo "*/5 * * * * test" | crontab -
echo "Current time: $(date)"
echo "Next run: Check /var/log/syslog in 5 minutes"
crontab -r  # Remove test
```

== Monitoring Commands

=== Health Checks

```bash
#!/bin/bash
# health-check.sh

echo "FlutterGristAPI Health Check"
echo "============================"

# Check Grist
if docker ps | grep -q grist_server; then
    echo "✓ Grist container running"
else
    echo "✗ Grist container NOT running"
fi

# Check Nginx
if systemctl is-active --quiet nginx; then
    echo "✓ Nginx active"
else
    echo "✗ Nginx NOT active"
fi

# Check disk space
DISK_USAGE=$(df -h /opt/grist/data | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -lt 80 ]; then
    echo "✓ Disk usage OK: ${DISK_USAGE}%"
else
    echo "⚠ Disk usage high: ${DISK_USAGE}%"
fi

# Check latest backup
LATEST=$(find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' |
         sort -rn | head -1)
if [ -n "$LATEST" ]; then
    BACKUP_AGE=$(( ($(date +%s) - ${LATEST%% *}) / 3600 ))
    if [ $BACKUP_AGE -lt 25 ]; then
        echo "✓ Latest backup: ${BACKUP_AGE} hours ago"
    else
        echo "⚠ Latest backup: ${BACKUP_AGE} hours ago (OLD)"
    fi
else
    echo "✗ No backups found"
fi

# Check data integrity
ERRORS=$(sqlite3 /opt/grist/data/docs/*.grist "PRAGMA quick_check;" 2>&1 |
         grep -v "^ok$" | wc -l)
if [ $ERRORS -eq 0 ]; then
    echo "✓ Data integrity OK"
else
    echo "⚠ Data integrity issues: $ERRORS"
fi
```

=== Performance Monitoring

```bash
# Monitor backup performance
time sudo /opt/scripts/backup.sh daily

# Monitor disk I/O during backup
iostat -x 5 &  # Update every 5 seconds
sudo /opt/scripts/backup.sh daily
killall iostat

# Monitor network during remote sync
iftop -i eth0 &
rsync -avz /opt/backups/ remote:/backups/
killall iftop

# Check system load
uptime
top -b -n 1 | head -20
```

== Automation Scripts

=== Weekly Report

```bash
#!/bin/bash
# weekly-backup-report.sh

REPORT="/tmp/backup-report-$(date +%Y%m%d).txt"

cat > "$REPORT" << EOF
FlutterGristAPI Backup Report
Generated: $(date)
======================================

BACKUP SUMMARY
--------------
EOF

# Backup counts
echo "Daily backups: $(find /opt/backups/daily -name '*.tar.gz' | wc -l)" >> "$REPORT"
echo "Weekly backups: $(find /opt/backups/weekly -name '*.tar.gz' | wc -l)" >> "$REPORT"
echo "Monthly backups: $(find /opt/backups/monthly -name '*.tar.gz' | wc -l)" >> "$REPORT"
echo "" >> "$REPORT"

# Storage usage
echo "STORAGE USAGE" >> "$REPORT"
echo "-------------" >> "$REPORT"
du -sh /opt/backups/* >> "$REPORT"
echo "" >> "$REPORT"

# Recent failures
echo "RECENT ISSUES" >> "$REPORT"
echo "-------------" >> "$REPORT"
grep -i "error\|fail" /var/log/backup.log | tail -5 >> "$REPORT"
echo "" >> "$REPORT"

# Email report
mail -s "Weekly Backup Report" admin@example.com < "$REPORT"
```

=== Automated Verification

```bash
#!/bin/bash
# daily-verification.sh

# Verify yesterday's backups
YESTERDAY=$(date -d "yesterday" +%Y%m%d)
BACKUPS=$(find /opt/backups -name "*${YESTERDAY}*.tar.gz")

for BACKUP in $BACKUPS; do
    echo "Verifying: $(basename $BACKUP)"

    # Checksum
    cd "$(dirname $BACKUP)"
    sha256sum -c "$(basename $BACKUP).sha256" --quiet || \
        echo "ALERT: Checksum failed for $BACKUP" | \
        mail -s "Backup Verification Failed" admin@example.com

    # Archive integrity
    tar -tzf "$BACKUP" > /dev/null 2>&1 || \
        echo "ALERT: Archive corrupted: $BACKUP" | \
        mail -s "Backup Corruption Detected" admin@example.com
done
```

== Quick Reference Card

```
DAILY OPERATIONS
────────────────
Check status:      /opt/scripts/backup.sh stats
View backups:      /opt/scripts/restore.sh --list
Manual backup:     /opt/scripts/backup.sh daily
View logs:         tail -f /var/log/backup.log

DATA VERIFICATION
─────────────────
Check integrity:   sqlite3 <file> "PRAGMA integrity_check;"
Verify backup:     sha256sum -c backup.tar.gz.sha256
Test archive:      tar -tzf backup.tar.gz

RECOVERY
────────
Restore latest:    /opt/scripts/restore.sh --latest
Restore specific:  /opt/scripts/restore.sh <file>
List backups:      /opt/scripts/restore.sh --list

MAINTENANCE
───────────
Check disk:        df -h /opt/backups
Clean old:         /opt/scripts/backup.sh cleanup
Check services:    docker ps && systemctl status nginx

EMERGENCY
─────────
Quick health:      docker ps | grep grist
Check last backup: find /opt/backups -name "*.tar.gz" | tail -1
Emergency restore: sudo /opt/scripts/restore.sh --latest
```
