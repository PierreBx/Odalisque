= Quick Start Guide

== Introduction

This guide will help you set up your first backup system for FlutterGristAPI within 30 minutes. You'll learn how to configure automated backups, verify their integrity, and perform a test restore.

#info_box(type: "info")[
  *What You'll Accomplish*

  - Deploy the backup role using Ansible
  - Create your first manual backup
  - Verify backup integrity
  - Perform a test restore
  - Set up automated backup schedule
  - Configure monitoring and alerts
]

== Prerequisites Checklist

Before starting, ensure you have:

- [ ] SSH access to the production server
- [ ] `sudo` or `root` privileges
- [ ] Ansible installed on your local machine
- [ ] FlutterGristAPI deployed and running
- [ ] At least 10GB free disk space for backups
- [ ] Basic familiarity with command line

== Step 1: Initial Assessment

=== Identify What to Back Up

First, verify the Grist data directory location:

```bash
# SSH to the server
ssh user@your-server

# Check Grist container configuration
docker inspect grist_server | grep -A 5 Mounts

# Typical output shows:
# /opt/grist/data -> /opt/grist/data
```

Common data locations:
- Grist data: `/opt/grist/data/`
- App config: `/opt/flutter_grist_app/config/`
- Nginx config: `/etc/nginx/`
- SSL certificates: `/etc/letsencrypt/`

=== Check Available Storage

```bash
# Check disk space
df -h /opt/backups

# If /opt/backups doesn't exist, check root
df -h /

# Recommended: At least 3x the size of data to back up
```

#info_box(type: "warning")[
  *Storage Planning*

  Estimate required backup storage:
  - Get current data size: `du -sh /opt/grist/data`
  - Multiply by 3 (for daily, weekly, monthly backups)
  - Add 20% buffer
  - Example: 2GB data → 7.2GB backup storage needed
]

== Step 2: Deploy Backup System

=== Configure Inventory

Edit your Ansible inventory file:

```yaml
# deployment-module/inventory/group_vars/production.yml

# Backup configuration
backup_base_dir: /opt/backups
backup_retention_daily: 7      # Keep 7 daily backups
backup_retention_weekly: 28    # Keep 4 weekly backups
backup_retention_monthly: 90   # Keep 3 monthly backups

# Backup schedule (2 AM daily)
backup_cron_hour: "2"
backup_cron_minute: "0"

# Data directories
grist_data_dir: /opt/grist/data
app_config_dir: /opt/flutter_grist_app/config
```

=== Add Backup Role to Playbook

Edit your configuration playbook:

```yaml
# deployment-module/playbooks/configure_server.yml

- hosts: production
  become: yes
  roles:
    - common
    - security
    - docker
    - monitoring
    - backup        # Add this line
    - ssl
    - app_environment
```

=== Deploy the Backup System

Run the Ansible playbook:

```bash
# From your local machine
cd flutterGristAPI/deployment-module

# Deploy backup configuration
ansible-playbook -i inventory/hosts.yml \
  playbooks/configure_server.yml \
  --tags backup

# Expected output:
# PLAY [production] **********
# TASK [backup : Create backup directories] ****** ok
# TASK [backup : Install backup script] *********** ok
# TASK [backup : Install restore script] ********** ok
# TASK [backup : Configure backup cron jobs] ****** ok
# PLAY RECAP *************************************
# production: ok=8 changed=4
```

=== Verify Deployment

SSH to the server and verify installation:

```bash
# Check backup scripts
ls -l /opt/scripts/backup.sh
ls -l /opt/scripts/restore.sh

# Check backup directories
ls -ld /opt/backups/{daily,weekly,monthly,temp}

# Check cron jobs
sudo crontab -l | grep backup

# Should show:
# 0 2 * * * /opt/scripts/backup.sh daily >> /var/log/backup.log 2>&1
# 0 2 * * 0 /opt/scripts/backup.sh weekly >> /var/log/backup.log 2>&1
# 0 2 1 * * /opt/scripts/backup.sh monthly >> /var/log/backup.log 2>&1
```

== Step 3: Create Your First Backup

=== Manual Backup Execution

Create your first backup manually to verify everything works:

```bash
# SSH to the server
ssh user@your-server

# Run manual backup (as root)
sudo /opt/scripts/backup.sh daily

# Expected output:
# [2025-11-10 10:30:00] ==========================================
# [2025-11-10 10:30:00] Starting daily backup
# [2025-11-10 10:30:00] ==========================================
# [2025-11-10 10:30:01] Backing up Grist data...
# [SUCCESS] Grist data backed up
# [2025-11-10 10:30:02] Backing up application configuration...
# [SUCCESS] Application config backed up
# [2025-11-10 10:30:02] Backing up Nginx configuration...
# [SUCCESS] Nginx config backed up
# [2025-11-10 10:30:03] Backing up SSL certificates...
# [SUCCESS] SSL certificates backed up
# [2025-11-10 10:30:04] Creating compressed archive...
# [2025-11-10 10:30:10] Calculating checksum...
# [SUCCESS] Backup completed: /opt/backups/daily/flutter_grist_backup_daily_20251110_103000.tar.gz
# [2025-11-10 10:30:10] Backup size: 1.2G
# [2025-11-10 10:30:10] Checksum: /opt/backups/daily/flutter_grist_backup_daily_20251110_103000.tar.gz.sha256
# [2025-11-10 10:30:10] ==========================================
# [2025-11-10 10:30:11] Verifying backup integrity...
# [SUCCESS] Backup verification passed
# [SUCCESS] Archive integrity verified
```

=== Check Backup Files

Verify the backup was created:

```bash
# List backup files
ls -lh /opt/backups/daily/

# Output:
# -rw-r--r-- 1 root root 1.2G Nov 10 10:30 flutter_grist_backup_daily_20251110_103000.tar.gz
# -rw-r--r-- 1 root root  134 Nov 10 10:30 flutter_grist_backup_daily_20251110_103000.tar.gz.sha256

# View backup metadata
cd /opt/backups/daily
cat flutter_grist_backup_daily_20251110_103000.tar.gz.sha256
```

=== Inspect Backup Contents

Examine what's inside the backup without extracting:

```bash
# List contents
tar -tzf /opt/backups/daily/flutter_grist_backup_*.tar.gz | head -20

# Expected structure:
# flutter_grist_backup_daily_20251110_103000/
# flutter_grist_backup_daily_20251110_103000/backup_metadata.txt
# flutter_grist_backup_daily_20251110_103000/grist_data/
# flutter_grist_backup_daily_20251110_103000/grist_data/docs/
# flutter_grist_backup_daily_20251110_103000/app_config/
# flutter_grist_backup_daily_20251110_103000/nginx_config/
# flutter_grist_backup_daily_20251110_103000/ssl_certs/
```

== Step 4: Verify Backup Integrity

=== Checksum Verification

Verify the backup hasn't been corrupted:

```bash
# Navigate to backup directory
cd /opt/backups/daily

# Verify checksum
sha256sum -c flutter_grist_backup_daily_*.tar.gz.sha256

# Expected output:
# flutter_grist_backup_daily_20251110_103000.tar.gz: OK
```

=== Archive Integrity Test

Test that the archive can be extracted:

```bash
# Test extraction (doesn't actually extract)
tar -tzf flutter_grist_backup_daily_*.tar.gz > /dev/null

# If successful, no output
echo $?
# Expected: 0 (success)
```

=== View Backup Metadata

Examine backup metadata:

```bash
# Extract just the metadata file
tar -xzf flutter_grist_backup_daily_*.tar.gz \
  --to-stdout \
  "*/backup_metadata.txt"

# Expected output:
# Backup Type: daily
# Backup Date: Sun Nov 10 10:30:00 UTC 2025
# Hostname: production-server
# OS: Linux 5.15.0-92-generic
# Backup Script Version: 1.0
```

== Step 5: Perform Test Restore

#info_box(type: "warning")[
  *Important: Test in Safe Environment*

  For your first restore test, consider using a test environment or VM. Never test restores on production unless necessary.
]

=== Create Test Environment (Optional)

If you have a test server:

```bash
# Copy backup to test server
scp /opt/backups/daily/flutter_grist_backup_*.tar.gz* \
  user@test-server:/tmp/
```

=== List Available Backups

```bash
# List all available backups
sudo /opt/scripts/restore.sh --list

# Output:
# ==========================================
# Available Backups
# ==========================================
#
# Daily backups:
#   2025-11-10 10:30:00 - flutter_grist_backup_daily_20251110_103000.tar.gz (1.2G)
#   2025-11-09 02:00:00 - flutter_grist_backup_daily_20251109_020000.tar.gz (1.1G)
#
# Weekly backups:
#   2025-11-03 02:00:00 - flutter_grist_backup_weekly_20251103_020000.tar.gz (1.0G)
#
# Monthly backups:
#   2025-11-01 02:00:00 - flutter_grist_backup_monthly_20251101_020000.tar.gz (989M)
```

=== Restore Latest Backup

#info_box(type: "danger")[
  *Production Warning*

  This will stop services and replace data. Only proceed if you're testing or recovering from a disaster.
]

```bash
# Restore from latest backup
sudo /opt/scripts/restore.sh --latest

# Output:
# ==========================================
# Starting restore from: flutter_grist_backup_daily_20251110_103000.tar.gz
# ==========================================
# Verifying backup before restore...
# [SUCCESS] Checksum verification passed
# [SUCCESS] Archive integrity verified
# [WARNING] This will replace existing data!
# Are you sure you want to continue? (yes/no): yes
# Extracting backup...
#
# Backup metadata:
#   Backup Type: daily
#   Backup Date: Sun Nov 10 10:30:00 UTC 2025
#   Hostname: production-server
#
# Stopping services...
# Restoring Grist data...
# [SUCCESS] Grist data restored
# Restoring application configuration...
# [SUCCESS] Application config restored
# Restoring Nginx configuration...
# [SUCCESS] Nginx config restored
# Restoring SSL certificates...
# [SUCCESS] SSL certificates restored
# Restarting services...
# ==========================================
# [SUCCESS] Restore completed successfully!
# ==========================================
```

=== Verify Restoration

After restore, verify all services are running:

```bash
# Check Grist container
docker ps | grep grist
# Should show: grist_server running

# Check Nginx
systemctl status nginx
# Should show: active (running)

# Check Grist accessibility
curl http://localhost:8484
# Should return HTML response

# Check data
docker exec grist_server ls -l /persist/docs/
# Should list your Grist documents
```

== Step 6: Configure Monitoring

=== Set Up Log Monitoring

Create a simple monitoring script:

```bash
# Create monitoring script
sudo tee /opt/scripts/check-backup-health.sh > /dev/null << 'EOF'
#!/bin/bash
# Check backup health

BACKUP_DIR="/opt/backups"
LOG_FILE="/var/log/backup.log"
MAX_AGE_HOURS=25  # Alert if no backup in 25 hours

# Check last backup time
LATEST=$(find $BACKUP_DIR -name "*.tar.gz" -type f -printf '%T@ %p\n' |
         sort -n | tail -1 | cut -d' ' -f2-)

if [ -z "$LATEST" ]; then
    echo "ERROR: No backups found!"
    exit 1
fi

# Calculate age in hours
LATEST_TIME=$(stat -c %Y "$LATEST")
CURRENT_TIME=$(date +%s)
AGE_HOURS=$(( ($CURRENT_TIME - $LATEST_TIME) / 3600 ))

if [ $AGE_HOURS -gt $MAX_AGE_HOURS ]; then
    echo "WARNING: Latest backup is $AGE_HOURS hours old!"
    exit 1
fi

# Check for recent failures in log
FAILURES=$(grep -c "ERROR" $LOG_FILE | tail -100)
if [ $FAILURES -gt 0 ]; then
    echo "WARNING: Found $FAILURES errors in recent logs"
    exit 1
fi

echo "OK: Latest backup is $AGE_HOURS hours old"
exit 0
EOF

# Make executable
sudo chmod +x /opt/scripts/check-backup-health.sh

# Test it
sudo /opt/scripts/check-backup-health.sh
```

=== Schedule Health Checks

Add health check to crontab:

```bash
# Edit crontab
sudo crontab -e

# Add health check (runs every 6 hours)
0 */6 * * * /opt/scripts/check-backup-health.sh || echo "Backup health check failed!" | mail -s "Backup Alert" admin@example.com
```

=== View Backup Logs

Monitor backup operations:

```bash
# View recent backup logs
sudo tail -f /var/log/backup.log

# View backup statistics
sudo /opt/scripts/backup.sh stats

# Output:
# ==========================================
# Backup Statistics
# ==========================================
# Daily backups:
#   Count: 7
#   Total size: 8.1G
#   Latest: flutter_grist_backup_daily_20251110_103000.tar.gz
# Weekly backups:
#   Count: 4
#   Total size: 4.2G
#   Latest: flutter_grist_backup_weekly_20251103_020000.tar.gz
# Monthly backups:
#   Count: 3
#   Total size: 2.8G
#   Latest: flutter_grist_backup_monthly_20251101_020000.tar.gz
# ==========================================
```

== Step 7: Test Automated Backups

=== Trigger Scheduled Backup

Wait for the scheduled backup (2 AM by default) or adjust cron timing for immediate test:

```bash
# Temporarily modify cron for immediate test
sudo crontab -e

# Change to run in 5 minutes from now
# If current time is 14:23, set to:
28 14 * * * /opt/scripts/backup.sh daily >> /var/log/backup.log 2>&1

# Save and exit

# Wait 5 minutes, then check log
sudo tail -f /var/log/backup.log
```

=== Verify Automatic Cleanup

The backup system automatically cleans old backups based on retention policies:

```bash
# Create several test backups to test cleanup
for i in {1..10}; do
    sudo /opt/scripts/backup.sh daily
    sleep 2
done

# Run cleanup
sudo /opt/scripts/backup.sh cleanup

# Check remaining backups
ls -lh /opt/backups/daily/

# Should only show backups within retention period (7 days)
```

== Step 8: Document Your Setup

Create a local documentation file:

```bash
# Create documentation
sudo tee /opt/backups/README.txt > /dev/null << 'EOF'
FlutterGristAPI Backup System
==============================

Backup Schedule:
- Daily: 2:00 AM (kept for 7 days)
- Weekly: Sunday 2:00 AM (kept for 28 days)
- Monthly: 1st of month 2:00 AM (kept for 90 days)

Backup Location: /opt/backups/

Manual Operations:
- Create backup: sudo /opt/scripts/backup.sh daily
- List backups: sudo /opt/scripts/restore.sh --list
- Restore latest: sudo /opt/scripts/restore.sh --latest
- View stats: sudo /opt/scripts/backup.sh stats
- View logs: sudo tail -f /var/log/backup.log

Important Notes:
- All backups include checksums for verification
- Backups are automatically cleaned based on retention policy
- Test restores quarterly
- Monitor /var/log/backup.log for issues

Last Updated: $(date)
Administrator: YOUR_NAME
Contact: YOUR_EMAIL
EOF
```

== Quick Reference

=== Daily Operations

```bash
# Check backup status
sudo /opt/scripts/backup.sh stats

# View recent logs
sudo tail -50 /var/log/backup.log

# Check disk space
df -h /opt/backups

# Verify latest backup
cd /opt/backups/daily
sha256sum -c $(ls -t *.sha256 | head -1)
```

=== Emergency Recovery

```bash
# If data is lost:
sudo /opt/scripts/restore.sh --latest

# If specific backup needed:
sudo /opt/scripts/restore.sh --list
sudo /opt/scripts/restore.sh /path/to/backup.tar.gz
```

=== Troubleshooting

```bash
# Backup failed?
sudo tail -100 /var/log/backup.log | grep ERROR

# Disk full?
df -h /opt/backups
sudo /opt/scripts/backup.sh cleanup

# Service not restarting?
sudo systemctl status nginx
sudo docker ps -a | grep grist
```

== Success Checklist

Verify you've completed all steps:

- [x] Backup system deployed via Ansible
- [x] First manual backup created successfully
- [x] Backup integrity verified (checksum + archive test)
- [x] Test restore performed
- [x] Automated backups scheduled (cron)
- [x] Backup logs reviewed
- [x] Monitoring configured
- [x] Documentation created
- [x] Emergency procedures understood

#info_box(type: "success")[
  *Congratulations!*

  Your backup system is now operational. Your data is protected with automated daily, weekly, and monthly backups.

  *Next Steps:*
  - Review the Backup Strategies guide for advanced configurations
  - Read the Disaster Recovery guide to plan for incidents
  - Schedule quarterly restore tests
  - Consider implementing off-site backups
]

== What's Next?

Continue your learning with these guides:

- *Backup Strategies* - Learn advanced backup techniques, incremental backups, and optimization
- *Disaster Recovery* - Develop comprehensive DR plans and runbooks
- *Data Integrity* - Implement data validation and quality checks
- *Commands Reference* - Complete command documentation
- *Troubleshooting* - Resolve common backup issues
