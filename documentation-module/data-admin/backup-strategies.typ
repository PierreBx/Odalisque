= Backup Strategies

== Introduction

A comprehensive backup strategy is essential for protecting FlutterGristAPI data against various failure scenarios. This guide covers backup methodologies, scheduling, retention policies, automation techniques, and optimization strategies.

== Backup Strategy Framework

=== The 3-2-1 Backup Rule

#info_box(type: "info")[
  *The Gold Standard of Backup Strategy*

  - *3* copies of data (1 primary + 2 backups)
  - *2* different storage media types
  - *1* copy stored off-site

  Example:
  - Primary: Grist data on server SSD
  - Backup 1: Local backups on server HDD
  - Backup 2: Cloud storage (S3, Azure, etc.)
]

=== Backup Types Comparison

#table(
  columns: (auto, 1fr, 1fr, 1fr, 1fr),
  align: (left, left, left, left, left),
  [*Type*], [*Speed*], [*Storage*], [*Restore Time*], [*Use Case*],
  [Full], [Slow], [High], [Fast], [Weekly/Monthly],
  [Incremental], [Fast], [Low], [Slow], [Daily/Hourly],
  [Differential], [Medium], [Medium], [Medium], [Daily],
  [Snapshot], [Very Fast], [Low], [Very Fast], [Continuous],
)

== Full Backup Strategy

=== When to Use Full Backups

Full backups create a complete copy of all data:
- Weekly baseline backups
- Monthly archival backups
- Before major system changes
- For long-term retention
- For off-site storage

=== Full Backup Implementation

*Basic Full Backup Script*

```bash
#!/bin/bash
# full-backup.sh - Complete system backup

BACKUP_DIR="/opt/backups/full"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="full_backup_${TIMESTAMP}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup all Grist data
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" \
  --exclude='/opt/grist/data/tmp' \
  --exclude='/opt/grist/data/cache' \
  /opt/grist/data \
  /opt/flutter_grist_app/config \
  /etc/nginx \
  /etc/letsencrypt

# Generate checksum
cd "$BACKUP_DIR"
sha256sum "${BACKUP_NAME}.tar.gz" > "${BACKUP_NAME}.tar.gz.sha256"

# Create metadata
cat > "${BACKUP_NAME}.metadata.json" << EOF
{
  "backup_type": "full",
  "timestamp": "${TIMESTAMP}",
  "hostname": "$(hostname)",
  "size_bytes": $(stat -c%s "${BACKUP_NAME}.tar.gz"),
  "checksum_file": "${BACKUP_NAME}.tar.gz.sha256"
}
EOF

echo "Full backup completed: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
```

=== Optimizing Full Backups

*1. Parallel Compression*

Use `pigz` for faster compression:

```bash
# Install pigz
sudo apt-get install pigz

# Use in backup
tar -c /opt/grist/data | pigz > backup.tar.gz

# Typically 3-4x faster than gzip
```

*2. Exclude Unnecessary Files*

```bash
tar -czf backup.tar.gz \
  --exclude='*.log' \
  --exclude='*.tmp' \
  --exclude='cache/*' \
  --exclude='temp/*' \
  --exclude='.git/*' \
  /opt/grist/data
```

*3. Split Large Archives*

```bash
# Split into 2GB chunks
tar -czf - /opt/grist/data | split -b 2G - backup.tar.gz.part_

# Reconstruct
cat backup.tar.gz.part_* > backup.tar.gz
```

== Incremental Backup Strategy

=== Understanding Incremental Backups

Incremental backups only save files changed since the *last backup* (any type):

```
Day 1: Full backup (10 GB)
Day 2: Incremental (500 MB) - changes since Day 1
Day 3: Incremental (300 MB) - changes since Day 2
Day 4: Incremental (450 MB) - changes since Day 3
```

*Restore requires*: Full backup + ALL incremental backups in sequence

=== Incremental Backup with rsync

```bash
#!/bin/bash
# incremental-backup.sh

BACKUP_BASE="/opt/backups/incremental"
CURRENT_BACKUP="${BACKUP_BASE}/current"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SNAPSHOT_DIR="${BACKUP_BASE}/snapshots/${TIMESTAMP}"

# Create snapshot directory
mkdir -p "${SNAPSHOT_DIR}"

# Perform incremental backup using rsync
rsync -av \
  --link-dest="${CURRENT_BACKUP}" \
  /opt/grist/data/ \
  "${SNAPSHOT_DIR}/"

# Update current symlink
rm -f "${CURRENT_BACKUP}"
ln -s "${SNAPSHOT_DIR}" "${CURRENT_BACKUP}"

echo "Incremental backup: ${SNAPSHOT_DIR}"
echo "Space used: $(du -sh ${SNAPSHOT_DIR} | cut -f1)"
```

This creates hard links for unchanged files, saving space.

=== Incremental Backup with tar

```bash
#!/bin/bash
# tar-incremental.sh

BACKUP_DIR="/opt/backups/incremental"
SNAPSHOT_FILE="${BACKUP_DIR}/snapshot.snar"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# First backup creates snapshot
if [ ! -f "$SNAPSHOT_FILE" ]; then
    # Level 0 (full) backup
    tar -czf "${BACKUP_DIR}/level0_${TIMESTAMP}.tar.gz" \
      --listed-incremental="${SNAPSHOT_FILE}" \
      /opt/grist/data
else
    # Level 1 (incremental) backup
    tar -czf "${BACKUP_DIR}/level1_${TIMESTAMP}.tar.gz" \
      --listed-incremental="${SNAPSHOT_FILE}" \
      /opt/grist/data
fi
```

*Restore Process*:
```bash
# Restore level 0 (full)
tar -xzf level0_20251101.tar.gz -C /restore/path

# Restore all level 1 (incremental) in order
tar -xzf level1_20251102.tar.gz -C /restore/path
tar -xzf level1_20251103.tar.gz -C /restore/path
```

== Differential Backup Strategy

=== Understanding Differential Backups

Differential backups save files changed since the *last full backup*:

```
Day 1: Full backup (10 GB)
Day 2: Differential (500 MB) - changes since Day 1
Day 3: Differential (800 MB) - changes since Day 1
Day 4: Differential (1.2 GB) - changes since Day 1
```

*Restore requires*: Full backup + Latest differential only

=== Differential Backup Implementation

```bash
#!/bin/bash
# differential-backup.sh

BACKUP_BASE="/opt/backups"
FULL_BACKUP_DIR="${BACKUP_BASE}/full"
DIFF_BACKUP_DIR="${BACKUP_BASE}/differential"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Find latest full backup
LATEST_FULL=$(ls -t ${FULL_BACKUP_DIR}/*.tar.gz | head -1)
FULL_TIMESTAMP=$(stat -c %Y "$LATEST_FULL")

# Find files modified since full backup
DIFF_LIST="/tmp/diff_files_${TIMESTAMP}.txt"
find /opt/grist/data -type f -newermt "@${FULL_TIMESTAMP}" > "$DIFF_LIST"

# Create differential backup
tar -czf "${DIFF_BACKUP_DIR}/diff_${TIMESTAMP}.tar.gz" \
  -T "$DIFF_LIST"

# Cleanup
rm "$DIFF_LIST"

echo "Differential backup completed"
echo "Files backed up: $(cat $DIFF_LIST | wc -l)"
```

=== Choosing Between Incremental and Differential

#table(
  columns: (auto, 1fr, 1fr),
  align: (left, left, left),
  [*Factor*], [*Incremental*], [*Differential*],
  [Backup speed], [Fastest], [Medium],
  [Backup size], [Smallest], [Medium],
  [Restore speed], [Slowest], [Fast],
  [Restore complexity], [High (all backups needed)], [Low (full + latest)],
  [Best for], [Frequent backups (hourly)], [Daily backups],
)

== Retention Policies

=== Retention Policy Framework

A well-designed retention policy balances data protection with storage costs.

*Common Retention Schedule*

```
Daily backups:   7 days   (1 week)
Weekly backups:  28 days  (4 weeks)
Monthly backups: 90 days  (3 months)
Quarterly:       1 year   (4 quarters)
Yearly:          7 years  (compliance)
```

=== Grandfather-Father-Son (GFS) Scheme

```
Son (Daily):     Monday - Saturday (6 backups)
Father (Weekly): Sundays (4-5 backups per month)
Grandfather:     Last Sunday of month (12 backups per year)
```

*Implementation*:

```bash
#!/bin/bash
# gfs-backup.sh

DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday
DAY_OF_MONTH=$(date +%d)
LAST_DAY_OF_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)

if [ "$DAY_OF_MONTH" = "$LAST_DAY_OF_MONTH" ]; then
    # Grandfather (monthly)
    /opt/scripts/backup.sh monthly
elif [ "$DAY_OF_WEEK" = "7" ]; then
    # Father (weekly)
    /opt/scripts/backup.sh weekly
else
    # Son (daily)
    /opt/scripts/backup.sh daily
fi
```

=== Regulatory Compliance Retention

Different data types may have different legal requirements:

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Data Type*], [*Retention*], [*Regulation*],
  [Financial records], [7 years], [Tax law],
  [Employee data], [7 years], [EEOC],
  [Medical records], [6 years], [HIPAA],
  [Customer PII], [As long as needed], [GDPR],
  [Email archives], [3-7 years], [Company policy],
)

=== Automated Retention Cleanup

```bash
#!/bin/bash
# cleanup-old-backups.sh

BACKUP_BASE="/opt/backups"

# Daily: keep 7 days
find "${BACKUP_BASE}/daily" -name "*.tar.gz" -mtime +7 -delete
find "${BACKUP_BASE}/daily" -name "*.sha256" -mtime +7 -delete

# Weekly: keep 28 days
find "${BACKUP_BASE}/weekly" -name "*.tar.gz" -mtime +28 -delete
find "${BACKUP_BASE}/weekly" -name "*.sha256" -mtime +28 -delete

# Monthly: keep 90 days
find "${BACKUP_BASE}/monthly" -name "*.tar.gz" -mtime +90 -delete
find "${BACKUP_BASE}/monthly" -name "*.sha256" -mtime +90 -delete

# Log cleanup actions
echo "[$(date)] Backup cleanup completed" >> /var/log/backup-cleanup.log
```

Schedule with cron:
```
0 3 * * * /opt/scripts/cleanup-old-backups.sh
```

== Backup Automation

=== Cron-Based Scheduling

*Basic Cron Schedule*:

```cron
# /etc/cron.d/grist-backups

# Daily backups at 2:00 AM
0 2 * * * root /opt/scripts/backup.sh daily >> /var/log/backup.log 2>&1

# Weekly backups every Sunday at 2:00 AM
0 2 * * 0 root /opt/scripts/backup.sh weekly >> /var/log/backup.log 2>&1

# Monthly backups on the 1st at 2:00 AM
0 2 1 * * root /opt/scripts/backup.sh monthly >> /var/log/backup.log 2>&1

# Cleanup old backups at 3:00 AM daily
0 3 * * * root /opt/scripts/cleanup-old-backups.sh
```

*Advanced Cron Schedule*:

```cron
# Hourly incremental backups (business hours only)
0 9-17 * * 1-5 root /opt/scripts/incremental-backup.sh

# Full backup every Sunday at 1:00 AM
0 1 * * 0 root /opt/scripts/full-backup.sh

# Off-site sync every 6 hours
0 */6 * * * root /opt/scripts/sync-to-offsite.sh

# Backup verification daily at 4:00 AM
0 4 * * * root /opt/scripts/verify-backups.sh

# Health check every 2 hours
0 */2 * * * root /opt/scripts/backup-health-check.sh
```

=== Systemd Timer-Based Scheduling

More robust than cron, with better logging and dependencies.

*Create service file*:

```ini
# /etc/systemd/system/grist-backup.service

[Unit]
Description=Grist Backup Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/opt/scripts/backup.sh daily
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

*Create timer file*:

```ini
# /etc/systemd/system/grist-backup.timer

[Unit]
Description=Grist Backup Timer
Requires=grist-backup.service

[Timer]
OnCalendar=daily
OnCalendar=02:00
Persistent=true

[Install]
WantedBy=timers.target
```

*Enable and start*:

```bash
sudo systemctl daemon-reload
sudo systemctl enable grist-backup.timer
sudo systemctl start grist-backup.timer

# Check status
sudo systemctl list-timers grist-backup.timer

# View logs
sudo journalctl -u grist-backup.service
```

=== Event-Driven Backups

Trigger backups on specific events:

*Pre-deployment backup*:

```bash
#!/bin/bash
# pre-deploy-hook.sh

echo "Creating pre-deployment backup..."
/opt/scripts/backup.sh pre-deployment

if [ $? -eq 0 ]; then
    echo "Backup successful, proceeding with deployment"
    exit 0
else
    echo "Backup failed, aborting deployment"
    exit 1
fi
```

*Post-update backup*:

```bash
# After Grist upgrade
docker stop grist_server
/opt/scripts/backup.sh post-upgrade
docker start grist_server
```

== Off-Site Backup Strategies

=== Remote Server Backups

*Using rsync over SSH*:

```bash
#!/bin/bash
# sync-to-remote.sh

REMOTE_USER="backup"
REMOTE_HOST="backup.example.com"
REMOTE_PATH="/backups/grist"
LOCAL_BACKUP_DIR="/opt/backups"

# Sync backups to remote server
rsync -avz --delete \
  -e "ssh -i /root/.ssh/backup_key" \
  "${LOCAL_BACKUP_DIR}/" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo "Remote sync completed"
```

*Using SCP*:

```bash
#!/bin/bash
# copy-to-remote.sh

BACKUP_FILE="/opt/backups/daily/$(ls -t /opt/backups/daily/*.tar.gz | head -1)"
REMOTE_USER="backup"
REMOTE_HOST="backup.example.com"
REMOTE_PATH="/backups/grist/"

scp -i /root/.ssh/backup_key \
  "$BACKUP_FILE" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
```

=== Cloud Storage Backups

*Amazon S3*:

```bash
#!/bin/bash
# sync-to-s3.sh

BUCKET="my-grist-backups"
BACKUP_DIR="/opt/backups"

# Install AWS CLI first:
# sudo apt-get install awscli

# Configure credentials:
# aws configure

# Sync to S3
aws s3 sync "${BACKUP_DIR}" "s3://${BUCKET}/backups/" \
  --storage-class STANDARD_IA \
  --delete

# Lifecycle policy (set in AWS console):
# - Transition to Glacier after 30 days
# - Delete after 365 days
```

*Google Cloud Storage*:

```bash
#!/bin/bash
# sync-to-gcs.sh

BUCKET="gs://my-grist-backups"
BACKUP_DIR="/opt/backups"

# Install gsutil first:
# curl https://sdk.cloud.google.com | bash

# Sync to GCS
gsutil -m rsync -r -d "${BACKUP_DIR}" "${BUCKET}/backups/"

# Set lifecycle policy
cat > lifecycle.json << EOF
{
  "rule": [{
    "action": {"type": "Delete"},
    "condition": {"age": 365}
  }, {
    "action": {
      "type": "SetStorageClass",
      "storageClass": "NEARLINE"
    },
    "condition": {"age": 30}
  }]
}
EOF

gsutil lifecycle set lifecycle.json "${BUCKET}"
```

*Using rclone (universal)*:

```bash
#!/bin/bash
# sync-with-rclone.sh

# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure remote (interactive)
rclone config

# Sync to cloud (works with S3, GCS, Azure, Dropbox, etc.)
rclone sync /opt/backups remote:grist-backups \
  --progress \
  --transfers 4 \
  --checkers 8

# Automated restore test
rclone ls remote:grist-backups
```

== Backup Encryption

=== GPG Encryption

*Encrypt backups*:

```bash
#!/bin/bash
# encrypt-backup.sh

BACKUP_FILE="$1"
GPG_RECIPIENT="backup@example.com"

# Encrypt
gpg --encrypt \
  --recipient "$GPG_RECIPIENT" \
  --output "${BACKUP_FILE}.gpg" \
  "$BACKUP_FILE"

# Remove unencrypted backup
rm "$BACKUP_FILE"

# Verify encryption
gpg --list-packets "${BACKUP_FILE}.gpg" > /dev/null && \
  echo "Encryption verified"
```

*Decrypt for restore*:

```bash
# Decrypt backup
gpg --decrypt backup.tar.gz.gpg > backup.tar.gz

# Extract
tar -xzf backup.tar.gz
```

=== OpenSSL Encryption

```bash
# Generate encryption key (do once, store securely)
openssl rand -base64 32 > /root/.backup_key
chmod 600 /root/.backup_key

# Encrypt backup
openssl enc -aes-256-cbc \
  -salt \
  -in backup.tar.gz \
  -out backup.tar.gz.enc \
  -pass file:/root/.backup_key

# Decrypt backup
openssl enc -d -aes-256-cbc \
  -in backup.tar.gz.enc \
  -out backup.tar.gz \
  -pass file:/root/.backup_key
```

== Backup Verification

=== Automated Verification Script

```bash
#!/bin/bash
# verify-backups.sh

BACKUP_DIR="/opt/backups"
LOG_FILE="/var/log/backup-verification.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Verify all backups from last 7 days
find "$BACKUP_DIR" -name "*.tar.gz" -mtime -7 | while read BACKUP; do
    log "Verifying: $BACKUP"

    # Check checksum
    if [ -f "${BACKUP}.sha256" ]; then
        cd "$(dirname $BACKUP)"
        if sha256sum -c "$(basename ${BACKUP}.sha256)" --quiet; then
            log "  ✓ Checksum OK"
        else
            log "  ✗ Checksum FAILED"
            continue
        fi
    fi

    # Test archive integrity
    if tar -tzf "$BACKUP" > /dev/null 2>&1; then
        log "  ✓ Archive integrity OK"
    else
        log "  ✗ Archive CORRUPTED"
        continue
    fi

    # Check size
    SIZE=$(stat -c%s "$BACKUP")
    if [ $SIZE -gt 1000000 ]; then  # > 1MB
        log "  ✓ Size OK: $(numfmt --to=iec-i --suffix=B $SIZE)"
    else
        log "  ✗ Size suspicious: $(numfmt --to=iec-i --suffix=B $SIZE)"
    fi
done

log "Verification completed"
```

=== Restore Testing

#info_box(type: "warning")[
  *Critical: Test Your Restores*

  A backup is only as good as your ability to restore it. Schedule regular restore tests.
]

*Quarterly Restore Test Procedure*:

```bash
#!/bin/bash
# test-restore.sh

TEST_DIR="/tmp/restore-test-$(date +%Y%m%d)"
LATEST_BACKUP=$(find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' |
                sort -rn | head -1 | cut -d' ' -f2-)

echo "Testing restore of: $LATEST_BACKUP"

# Create test directory
mkdir -p "$TEST_DIR"

# Extract backup
tar -xzf "$LATEST_BACKUP" -C "$TEST_DIR"

# Verify critical files exist
EXPECTED_FILES=(
    "grist_data/docs"
    "app_config"
    "backup_metadata.txt"
)

for FILE in "${EXPECTED_FILES[@]}"; do
    if [ -e "$TEST_DIR"/*/"$FILE" ]; then
        echo "✓ Found: $FILE"
    else
        echo "✗ Missing: $FILE"
        exit 1
    fi
done

# Cleanup
rm -rf "$TEST_DIR"

echo "Restore test PASSED"
```

Schedule quarterly:
```cron
# Quarterly restore test (Jan 1, Apr 1, Jul 1, Oct 1 at 5 AM)
0 5 1 1,4,7,10 * /opt/scripts/test-restore.sh | mail -s "Quarterly Restore Test" admin@example.com
```

== Performance Optimization

=== Compression Comparison

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, center, center, left),
  [*Tool*], [*Speed*], [*Ratio*], [*CPU*], [*Notes*],
  [`gzip`], [Medium], [Medium], [Medium], [Standard, widely compatible],
  [`pigz`], [Fast], [Medium], [High], [Parallel gzip, 3-4x faster],
  [`bzip2`], [Slow], [High], [High], [Better compression, slower],
  [`xz`], [Very Slow], [Very High], [Very High], [Best compression],
  [`lz4`], [Very Fast], [Low], [Low], [Fast backups, larger files],
  [`zstd`], [Fast], [High], [Medium], [Best balance, modern],
)

*Recommendation*: Use `pigz` for daily backups, `zstd` for archival.

=== Network Optimization

*Bandwidth throttling*:

```bash
# Limit rsync to 10 MB/s
rsync --bwlimit=10000 backup.tar.gz remote:/backups/

# Limit with trickle
trickle -d 10000 rsync backup.tar.gz remote:/backups/
```

*Compression during transfer*:

```bash
# Compress during transfer, decompress on arrival
tar -czf - /opt/grist/data | ssh remote "cat > backup.tar.gz"

# Or use rsync compression
rsync -avz /opt/backups/ remote:/backups/
```

== Best Practices Summary

#info_box(type: "success")[
  *Backup Strategy Best Practices*

  1. *3-2-1 Rule*: 3 copies, 2 media types, 1 off-site
  2. *Automate Everything*: Never rely on manual backups
  3. *Verify All Backups*: Checksum + integrity test
  4. *Test Restores*: Quarterly restore drills
  5. *Monitor Continuously*: Alert on failures
  6. *Encrypt Sensitive Data*: Especially off-site backups
  7. *Document Procedures*: Runbooks for recovery
  8. *Optimize for RTO/RPO*: Match strategy to requirements
  9. *Version Your Backups*: Keep multiple generations
  10. *Plan for Growth*: Scale storage with data growth
]
