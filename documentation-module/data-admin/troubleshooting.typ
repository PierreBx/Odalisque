= Troubleshooting

== Introduction

This guide provides solutions to common problems encountered in FlutterGristAPI data administration, including backup failures, corruption issues, recovery problems, and system errors.

#info_box(type: "info")[
  *Troubleshooting Approach*

  1. *Identify* - Determine the exact problem
  2. *Isolate* - Narrow down the cause
  3. *Fix* - Apply appropriate solution
  4. *Verify* - Confirm resolution
  5. *Document* - Record for future reference
]

== Backup Issues

=== Backup Script Fails

#troubleshooting_table((
  (
    issue: "Permission denied error",
    solution: "Run with sudo: `sudo /opt/scripts/backup.sh daily`. Check script ownership: `ls -l /opt/scripts/backup.sh`. Should be owned by root with execute permissions (755).",
    priority: "high"
  ),
  (
    issue: "Backup directory not found",
    solution: "Create backup directories: `sudo mkdir -p /opt/backups/{daily,weekly,monthly,temp}`. Verify with: `ls -ld /opt/backups/*`",
    priority: "high"
  ),
  (
    issue: "Command not found: pigz",
    solution: "Install parallel gzip: `sudo apt-get install pigz` or edit backup.sh to use standard gzip instead.",
    priority: "low"
  ),
))

*Detailed Solutions*:

**Permission Issues**:
```bash
# Check script permissions
ls -l /opt/scripts/backup.sh

# Fix permissions
sudo chmod 755 /opt/scripts/backup.sh
sudo chown root:root /opt/scripts/backup.sh

# Verify backup directory permissions
sudo chown -R root:root /opt/backups
sudo chmod 750 /opt/backups
```

**Missing Dependencies**:
```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y rsync tar gzip pigz

# Verify installations
which rsync tar gzip pigz
```

=== Backup Disk Full

#troubleshooting_table((
  (
    issue: "No space left on device",
    solution: "Run cleanup: `sudo /opt/scripts/backup.sh cleanup`. Check disk: `df -h /opt/backups`. Move old backups to external storage or cloud.",
    priority: "high"
  ),
  (
    issue: "Backup directory at 95% capacity",
    solution: "Immediate cleanup: `find /opt/backups -name '*.tar.gz' -mtime +14 -delete`. Adjust retention policy in backup config.",
    priority: "high"
  ),
))

*Emergency Disk Space Recovery*:
```bash
# Check current usage
df -h /opt/backups

# Find largest backups
find /opt/backups -name "*.tar.gz" -type f -printf '%s %p\n' |
  sort -rn | head -10 |
  while read size path; do
    echo "$(numfmt --to=iec-i --suffix=B $size) - $path"
  done

# Remove old daily backups (keep last 3 days)
find /opt/backups/daily -name "*.tar.gz" -mtime +3 -delete

# Move to external storage
sudo rsync -av --remove-source-files \
  /opt/backups/monthly/ \
  /mnt/external/backups/monthly/

# Verify space freed
df -h /opt/backups
```

=== Backup Takes Too Long

#troubleshooting_table((
  (
    issue: "Backup exceeds 1 hour",
    solution: "Use pigz for parallel compression. Exclude unnecessary files. Consider incremental backups. Check disk I/O with `iostat`.",
    priority: "medium"
  ),
  (
    issue: "Backup causes system slowdown",
    solution: "Lower process priority: `nice -n 19 /opt/scripts/backup.sh daily`. Schedule during off-hours. Limit disk I/O with `ionice`.",
    priority: "medium"
  ),
))

*Performance Optimization*:
```bash
# Run backup with lower priority
sudo nice -n 19 ionice -c 3 /opt/scripts/backup.sh daily

# Exclude large temporary files
tar -czf backup.tar.gz \
  --exclude='*.log' \
  --exclude='*.tmp' \
  --exclude='cache/*' \
  /opt/grist/data

# Use incremental backup
rsync -av --link-dest=/opt/backups/current \
  /opt/grist/data/ \
  /opt/backups/incremental/$(date +%Y%m%d)/

# Monitor backup performance
time sudo /opt/scripts/backup.sh daily
```

=== Checksum Verification Fails

#troubleshooting_table((
  (
    issue: "Checksum mismatch detected",
    solution: "Backup may be corrupted. Do NOT use for restore. Delete corrupted backup. Create new backup immediately. Check disk health with `smartctl`.",
    priority: "high"
  ),
  (
    issue: "Checksum file missing",
    solution: "Regenerate checksum: `cd /opt/backups/daily && sha256sum backup.tar.gz > backup.tar.gz.sha256`",
    priority: "low"
  ),
))

*Handling Corrupted Backups*:
```bash
# Verify all recent backups
for backup in /opt/backups/daily/*.tar.gz; do
    echo "Checking: $(basename $backup)"
    cd "$(dirname $backup)"
    if sha256sum -c "$(basename $backup).sha256" --quiet; then
        echo "  ✓ OK"
    else
        echo "  ✗ FAILED - Moving to quarantine"
        sudo mkdir -p /opt/backups/corrupted
        sudo mv "$backup" "$backup.sha256" /opt/backups/corrupted/
    fi
done

# Create immediate backup
sudo /opt/scripts/backup.sh daily

# Check disk health
sudo smartctl -H /dev/sda
```

== Restore Issues

=== Restore Fails to Start

#troubleshooting_table((
  (
    issue: "Must be run as root",
    solution: "Use sudo: `sudo /opt/scripts/restore.sh --latest`",
    priority: "high"
  ),
  (
    issue: "Backup file not found",
    solution: "Verify path: `ls -l /opt/backups/*/`. List available: `/opt/scripts/restore.sh --list`",
    priority: "high"
  ),
  (
    issue: "Archive extraction fails",
    solution: "Backup corrupted. Try different backup. Check with: `tar -tzf backup.tar.gz`",
    priority: "high"
  ),
))

*Restore Diagnostics*:
```bash
# Verify backup exists and is readable
BACKUP="/opt/backups/daily/backup_20251110.tar.gz"
ls -lh "$BACKUP"

# Test backup integrity
tar -tzf "$BACKUP" > /dev/null && echo "OK" || echo "CORRUPTED"

# Verify checksum
cd "$(dirname $BACKUP)"
sha256sum -c "$(basename $BACKUP).sha256"

# Check available space for extraction
BACKUP_SIZE=$(stat -c%s "$BACKUP")
AVAILABLE=$(df --output=avail /tmp | tail -1)
if [ $((BACKUP_SIZE * 2)) -lt $((AVAILABLE * 1024)) ]; then
    echo "✓ Sufficient space"
else
    echo "✗ Insufficient space"
fi
```

=== Services Won't Start After Restore

#troubleshooting_table((
  (
    issue: "Grist container won't start",
    solution: "Check logs: `docker logs grist_server`. Verify data permissions: `sudo chown -R 1000:1000 /opt/grist/data`. Restart: `docker restart grist_server`",
    priority: "high"
  ),
  (
    issue: "Nginx configuration error",
    solution: "Test config: `sudo nginx -t`. Check restored config: `ls -l /etc/nginx/`. Restore just config: extract from backup manually.",
    priority: "high"
  ),
))

*Service Recovery*:
```bash
# Check Grist container status
docker ps -a | grep grist_server

# View Grist logs
docker logs grist_server --tail 50

# Fix data permissions
sudo chown -R 1000:1000 /opt/grist/data
sudo chmod -R 755 /opt/grist/data

# Restart Grist
docker restart grist_server
sleep 5
docker ps | grep grist_server

# Check Nginx config
sudo nginx -t

# View Nginx error log
sudo tail -50 /var/log/nginx/error.log

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```

=== Data Missing After Restore

#troubleshooting_table((
  (
    issue: "Recent changes not in restored data",
    solution: "Expected - data from backup time only. Check RPO. If unacceptable, review backup frequency.",
    priority: "medium"
  ),
  (
    issue: "Specific documents missing",
    solution: "Check if documents existed at backup time. Verify backup contents: `tar -tzf backup.tar.gz | grep .grist`. Try earlier backup.",
    priority: "high"
  ),
))

*Verify Restored Data*:
```bash
# List restored Grist documents
ls -lh /opt/grist/data/docs/

# Check document integrity
for doc in /opt/grist/data/docs/*.grist; do
    echo "Checking: $(basename $doc)"
    sqlite3 "$doc" "PRAGMA integrity_check;" |
        grep -v "^ok$" && echo "  ⚠ Issues" || echo "  ✓ OK"
done

# Compare with backup contents
BACKUP="/opt/backups/daily/latest.tar.gz"
echo "Documents in backup:"
tar -tzf "$BACKUP" | grep "\.grist$"

# Check backup metadata
tar -xzOf "$BACKUP" "*/backup_metadata.txt"
```

== Data Corruption Issues

=== SQLite Database Corrupted

#troubleshooting_table((
  (
    issue: "PRAGMA integrity_check fails",
    solution: "Restore from latest backup. If no backup, try: `sqlite3 corrupt.grist '.recover' | sqlite3 recovered.grist`. Backup corrupted file first for analysis.",
    priority: "high"
  ),
  (
    issue: "Database disk image is malformed",
    solution: "Critical corruption. Restore from backup immediately. Do not attempt repair on production data.",
    priority: "high"
  ),
))

*Corruption Recovery Attempts*:
```bash
# Backup corrupted database
cp /opt/grist/data/docs/corrupt.grist \
   /opt/grist/data/docs/corrupt.grist.backup

# Attempt recovery (SQLite 3.40+)
sqlite3 corrupt.grist ".recover" | sqlite3 recovered.grist

# Verify recovered database
sqlite3 recovered.grist "PRAGMA integrity_check;"

# If recovery successful, replace
if [ $? -eq 0 ]; then
    sudo docker stop grist_server
    mv /opt/grist/data/docs/corrupt.grist /tmp/
    mv recovered.grist /opt/grist/data/docs/recovered.grist
    sudo chown 1000:1000 /opt/grist/data/docs/recovered.grist
    sudo docker start grist_server
fi

# If recovery fails, restore from backup
sudo /opt/scripts/restore.sh --latest
```

=== Partial Data Loss

#troubleshooting_table((
  (
    issue: "Some records missing from tables",
    solution: "Check Grist history/snapshots if enabled. Restore specific table from backup. Export from backup: `sqlite3 backup.grist '.dump TableName' > table.sql`",
    priority: "high"
  ),
  (
    issue: "Attachments missing",
    solution: "Check `/opt/grist/data/uploads/`. Restore uploads directory from backup: extract only uploads folder.",
    priority: "medium"
  ),
))

*Restore Specific Data*:
```bash
# Extract table from backup
BACKUP="/opt/backups/daily/backup.tar.gz"
TABLE="Users"

# Extract backup
TEMP="/tmp/restore-$$"
mkdir -p "$TEMP"
tar -xzf "$BACKUP" -C "$TEMP"

# Find Grist document
GRIST_DOC=$(find "$TEMP" -name "*.grist" | head -1)

# Export table as SQL
sqlite3 "$GRIST_DOC" ".dump $TABLE" > /tmp/${TABLE}.sql

# Or export as CSV
sqlite3 "$GRIST_DOC" << EOF
.headers on
.mode csv
.output /tmp/${TABLE}.csv
SELECT * FROM $TABLE;
EOF

echo "Table exported. Import manually through Grist UI or API."
rm -rf "$TEMP"
```

=== Foreign Key Violations

#troubleshooting_table((
  (
    issue: "Foreign key check fails",
    solution: "Identify broken references: `PRAGMA foreign_key_check;`. Restore referential integrity or restore from backup.",
    priority: "medium"
  ),
))

*Fix Foreign Keys*:
```bash
# Check for violations
sqlite3 /opt/grist/data/docs/mydoc.grist << 'EOF'
PRAGMA foreign_key_check;
EOF

# Find broken references
sqlite3 /opt/grist/data/docs/mydoc.grist << 'EOF'
-- Example: Find orders with non-existent users
SELECT o.id, o.user_id
FROM Orders o
LEFT JOIN Users u ON o.user_id = u.id
WHERE u.id IS NULL;
EOF

# Fix: Set to NULL or delete
sqlite3 /opt/grist/data/docs/mydoc.grist << 'EOF'
-- Option 1: Set to NULL
UPDATE Orders SET user_id = NULL
WHERE user_id NOT IN (SELECT id FROM Users);

-- Option 2: Delete orphaned records
DELETE FROM Orders
WHERE user_id NOT IN (SELECT id FROM Users);
EOF
```

== System Issues

=== Insufficient Memory

#troubleshooting_table((
  (
    issue: "Out of memory during backup",
    solution: "Stop non-essential services. Increase swap: `sudo swapon --show`. Use streaming compression: `tar -c dir | gzip > backup.tar.gz`",
    priority: "high"
  ),
  (
    issue: "Docker container OOM killed",
    solution: "Increase container memory limit. Check: `docker inspect grist_server | grep Memory`. Adjust in docker-compose.yml.",
    priority: "high"
  ),
))

*Memory Management*:
```bash
# Check current memory usage
free -h

# Check swap
sudo swapon --show

# Add temporary swap (4GB)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Monitor memory during backup
watch -n 5 'free -h'

# Check Docker memory limits
docker inspect grist_server | grep -A 5 Memory

# Adjust Docker memory limit
# Edit docker-compose.yml:
# services:
#   grist:
#     mem_limit: 2g
#     memswap_limit: 4g
```

=== Network Timeout During Remote Backup

#troubleshooting_table((
  (
    issue: "rsync timeout to remote server",
    solution: "Check network: `ping remote-server`. Test SSH: `ssh remote-server`. Increase timeout: `rsync --timeout=300`. Use screen/tmux for long transfers.",
    priority: "medium"
  ),
  (
    issue: "Cloud upload fails",
    solution: "Check credentials. Test connection: `aws s3 ls` or `rclone ls remote:`. Split large files. Use resumable uploads.",
    priority: "medium"
  ),
))

*Network Troubleshooting*:
```bash
# Test remote connectivity
ping -c 4 remote-server
traceroute remote-server

# Test SSH
ssh -v user@remote-server "echo 'Connected'"

# Test bandwidth
# Install iperf: sudo apt-get install iperf3
# On remote: iperf3 -s
# On local: iperf3 -c remote-server

# Rsync with increased timeout and progress
rsync -avz --timeout=600 --progress \
  /opt/backups/daily/ \
  remote:/backups/

# Use screen for long transfers
screen -S backup-sync
rsync -avz /opt/backups/ remote:/backups/
# Ctrl+A, D to detach
# screen -r backup-sync to reattach
```

=== Cron Job Not Running

#troubleshooting_table((
  (
    issue: "Scheduled backup not executing",
    solution: "Check cron service: `systemctl status cron`. Verify crontab: `sudo crontab -l`. Check syslog: `grep CRON /var/log/syslog | tail -20`",
    priority: "high"
  ),
  (
    issue: "Backup script runs but fails silently",
    solution: "Add logging: `command >> /var/log/backup.log 2>&1`. Check permissions. Verify PATH in cron. Add `MAILTO=admin@example.com` to crontab.",
    priority: "medium"
  ),
))

*Cron Debugging*:
```bash
# Check cron service
systemctl status cron

# View crontab
sudo crontab -l

# Check cron execution logs
grep CRON /var/log/syslog | grep backup | tail -20

# Test backup script manually
sudo /opt/scripts/backup.sh daily

# Add debugging to crontab
sudo crontab -e

# Add these lines:
# SHELL=/bin/bash
# PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# MAILTO=admin@example.com
#
# 0 2 * * * /opt/scripts/backup.sh daily >> /var/log/backup-cron.log 2>&1

# Monitor next execution
tail -f /var/log/backup-cron.log
```

== Monitoring and Alerts

=== No Backup Alerts Received

#troubleshooting_table((
  (
    issue: "Not receiving backup failure emails",
    solution: "Test mail: `echo 'Test' | mail -s 'Test' admin@example.com`. Install mailutils: `sudo apt-get install mailutils`. Configure SMTP relay.",
    priority: "medium"
  ),
  (
    issue: "Backup succeeds but no success notification",
    solution: "Success emails usually not sent to reduce noise. Add explicit notification in backup script if needed.",
    priority: "low"
  ),
))

*Configure Email Alerts*:
```bash
# Install mail utilities
sudo apt-get install mailutils

# Test email
echo "Test message" | mail -s "Test Subject" admin@example.com

# Configure postfix for relay (if not done)
sudo dpkg-reconfigure postfix

# Add notification to backup script
# Edit /opt/scripts/backup.sh, add at end:
if [ $? -eq 0 ]; then
    echo "Backup completed successfully" |
        mail -s "Backup Success" admin@example.com
else
    echo "Backup FAILED" |
        mail -s "Backup FAILED - Action Required" admin@example.com
fi
```

=== Monitoring Not Updating

#troubleshooting_table((
  (
    issue: "Backup statistics not updating",
    solution: "Run manually: `/opt/scripts/backup.sh stats`. Check if log rotation deleted logs. Verify backup files exist: `ls -lh /opt/backups/daily/`",
    priority: "low"
  ),
))

## Common Error Messages

=== Error: "tar: Cannot stat: No such file or directory"

*Cause*: Source directory doesn't exist or path is incorrect

*Solution*:
```bash
# Verify paths in backup script
grep -n "tar.*czf" /opt/scripts/backup.sh

# Check if directories exist
ls -ld /opt/grist/data
ls -ld /opt/flutter_grist_app/config

# Create missing directories
sudo mkdir -p /opt/flutter_grist_app/config
```

=== Error: "gzip: stdin: not in gzip format"

*Cause*: Archive is corrupted or not gzip compressed

*Solution*:
```bash
# Verify file type
file backup.tar.gz

# If not gzip, try different decompression
tar -xf backup.tar  # uncompressed
tar -xjf backup.tar.bz2  # bzip2
tar -xJf backup.tar.xz  # xz

# Check archive integrity
gzip -t backup.tar.gz
```

=== Error: "Docker: Cannot connect to the Docker daemon"

*Cause*: Docker service not running or permission issue

*Solution*:
```bash
# Check Docker status
systemctl status docker

# Start Docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in for group change to take effect

# Verify
docker ps
```

== Preventive Measures

#info_box(type: "success")[
  *Prevent Future Issues*

  1. *Regular Testing* - Test backups and restores quarterly
  2. *Monitoring* - Set up automated health checks
  3. *Documentation* - Keep runbooks updated
  4. *Capacity Planning* - Monitor disk space trends
  5. *Log Review* - Check logs weekly for warnings
  6. *Automation* - Automate routine tasks
  7. *Validation* - Verify backups after creation
  8. *Updates* - Keep systems and scripts updated
]

=== Automated Health Checks

```bash
#!/bin/bash
# daily-health-check.sh

ISSUES=0

# Check disk space
DISK_USAGE=$(df -h /opt/backups | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "WARNING: Backup disk at ${DISK_USAGE}%"
    ISSUES=$((ISSUES + 1))
fi

# Check latest backup age
LATEST=$(find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' |
         sort -rn | head -1 | cut -d' ' -f1)
AGE=$(( ($(date +%s) - ${LATEST%.*}) / 3600 ))
if [ $AGE -gt 25 ]; then
    echo "WARNING: Latest backup is $AGE hours old"
    ISSUES=$((ISSUES + 1))
fi

# Check services
if ! docker ps | grep -q grist_server; then
    echo "ERROR: Grist not running"
    ISSUES=$((ISSUES + 1))
fi

# Report
if [ $ISSUES -gt 0 ]; then
    echo "$ISSUES issues found - sending alert"
    # Send notification
fi

exit $ISSUES
```

Schedule daily:
```cron
0 8 * * * /opt/scripts/daily-health-check.sh || mail -s "Health Check Alert" admin@example.com
```

== Getting Help

If you can't resolve an issue:

1. *Check logs*: `/var/log/backup.log`, `docker logs grist_server`
2. *Review documentation*: This guide and related references
3. *Search community*: Grist forums, Stack Overflow
4. *Contact support*: Provide logs and error messages
5. *Escalate*: Follow your organization's incident response plan

*Information to Collect*:

```bash
# System info
uname -a
df -h
free -h

# Service status
docker ps -a
systemctl status nginx

# Recent logs
tail -100 /var/log/backup.log
docker logs grist_server --tail 50

# Backup status
ls -lh /opt/backups/daily/ | tail -10
/opt/scripts/backup.sh stats
```
