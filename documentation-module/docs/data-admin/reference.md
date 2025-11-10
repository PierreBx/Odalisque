# Reference Guide

## Introduction

This comprehensive reference guide provides detailed technical information for FlutterGristAPI data administration, including configuration files, directory structures, backup formats, API references, and system specifications.

## Directory Structure

### Standard Directory Layout

```
/opt/
├── grist/
│   └── data/                      # Grist data root
│       ├── docs/                  # Grist documents (SQLite files)
│       │   ├── doc1.grist
│       │   ├── doc2.grist
│       │   └── ...
│       ├── plugins/               # Custom plugins
│       ├── uploads/               # File attachments
│       └── snapshots/             # Document history
│
├── flutter_grist_app/
│   ├── config/                    # Application configuration
│   │   ├── app.conf
│   │   └── credentials.yml
│   └── logs/                      # Application logs
│
├── backups/                       # Backup storage
│   ├── daily/                     # Daily backups (7 days)
│   ├── weekly/                    # Weekly backups (28 days)
│   ├── monthly/                   # Monthly backups (90 days)
│   └── temp/                      # Temporary extraction
│
└── scripts/                       # Maintenance scripts
    ├── backup.sh                  # Backup script
    ├── restore.sh                 # Restore script
    ├── check-backup-health.sh     # Health monitoring
    └── verify-backups.sh          # Integrity verification

/etc/
├── nginx/                         # Nginx web server
│   ├── nginx.conf
│   ├── sites-available/
│   └── sites-enabled/
│
├── letsencrypt/                   # SSL certificates
│   ├── live/
│   ├── archive/
│   └── renewal/
│
└── backup.conf                    # Backup configuration

/var/log/
├── backup.log                     # Backup operations log
├── backup-verification.log        # Verification results
├── nginx/                         # Web server logs
└── grist/                         # Application logs
```

### Important File Locations

| Component | Location | Critical |
| --- | --- | --- |
| Grist data | /opt/grist/data | ✓ |
| App config | /opt/flutter_grist_app/config | ✓ |
| Backups | /opt/backups | ✓ |
| Backup scripts | /opt/scripts | ✓ |
| SSL certs | /etc/letsencrypt | ✓ |
| Nginx config | /etc/nginx | Backup logs |
| /var/log/backup.log |  |  |

## Configuration Files

### Backup Configuration

*File*: `/etc/backup.conf`

```bash
# Backup base directory
BACKUP_BASE_DIR="/opt/backups"

# Retention periods (in days)
RETENTION_DAILY=7
RETENTION_WEEKLY=28
RETENTION_MONTHLY=90

# Source directories
GRIST_DATA_DIR="/opt/grist/data"
APP_CONFIG_DIR="/opt/flutter_grist_app/config"
NGINX_CONFIG_DIR="/etc/nginx"
SSL_CERT_DIR="/etc/letsencrypt"

# Remote backup (optional)
REMOTE_BACKUP_ENABLED=false
REMOTE_BACKUP_USER="backup"
REMOTE_BACKUP_HOST="backup.example.com"
REMOTE_BACKUP_PATH="/backups/grist"

# Cloud backup (optional)
CLOUD_BACKUP_ENABLED=false
CLOUD_BACKUP_REMOTE="s3-backup"
CLOUD_BACKUP_BUCKET="my-backups"

# Notification
NOTIFY_EMAIL="admin@example.com"
NOTIFY_ON_SUCCESS=false
NOTIFY_ON_FAILURE=true

# Compression
USE_PIGZ=true
COMPRESSION_LEVEL=6

# Verification
VERIFY_AFTER_BACKUP=true
```

### Ansible Variables

*File*: `deployment-module/inventory/group_vars/production.yml`

```yaml
---
# Backup configuration
backup_base_dir: /opt/backups
backup_retention_daily: 7
backup_retention_weekly: 28
backup_retention_monthly: 90

# Backup schedule (cron format)
backup_cron_hour: "2"
backup_cron_minute: "0"

# Data directories
grist_data_dir: /opt/grist/data
app_config_dir: /opt/flutter_grist_app/config

# Remote backup (optional)
remote_backup_enabled: false
remote_backup_user: backup
remote_backup_host: backup.example.com
remote_backup_path: /backups/grist

# Cloud backup (optional)
cloud_backup_enabled: false
cloud_backup_remote: s3-backup
cloud_backup_bucket: my-backups

# Monitoring
backup_monitoring_enabled: true
backup_alert_email: admin@example.com
```

### Cron Schedule Format

```
# │ │ │ │ │
# * * * * * command to execute

# Examples:
0 2 * * *        # Daily at 2:00 AM
0 2 * * 0        # Every Sunday at 2:00 AM
0 2 1 * *        # 1st of month at 2:00 AM
*/30 * * * *     # Every 30 minutes
0 */4 * * *      # Every 4 hours
0 2 * * 1-5      # Weekdays at 2:00 AM
0 2 1,15 * *     # 1st and 15th at 2:00 AM
```

## Backup Archive Format

### Archive Structure

```
flutter_grist_backup_daily_20251110_020000.tar.gz
├── backup_metadata.txt          # Backup information
├── grist_data/                  # Grist data directory
│   ├── docs/                    # Grist documents
│   │   ├── doc1.grist
│   │   └── doc2.grist
│   ├── plugins/
│   ├── uploads/
│   └── snapshots/
├── app_config/                  # Application config
│   ├── app.conf
│   └── credentials.yml
├── nginx_config/                # Nginx configuration
│   ├── nginx.conf
│   ├── sites-available/
│   └── sites-enabled/
└── ssl_certs/                   # SSL certificates
    ├── live/
    ├── archive/
    └── renewal/
```

### Metadata File Format

*File*: `backup_metadata.txt`

```
Backup Type: daily
Backup Date: Sun Nov 10 02:00:00 UTC 2025
Hostname: production-server
OS: Linux 5.15.0-92-generic
Backup Script Version: 1.0
Total Size: 1234567890 bytes
Compression: gzip level 6
Source Directories:
  - /opt/grist/data
  - /opt/flutter_grist_app/config
  - /etc/nginx
  - /etc/letsencrypt
Checksum Algorithm: SHA256
```

### Checksum File Format

*File*: `backup.tar.gz.sha256`

```
a1b2c3d4e5f6...  flutter_grist_backup_daily_20251110_020000.tar.gz
```

Verify with: `sha256sum -c backup.tar.gz.sha256`

## Grist SQLite Schema

### System Tables

| Table | Purpose |
| --- | --- |
| _grist_Tables | Table metadata and definitions |
| _grist_Tables_column | Column definitions and types |
| _grist_DocInfo | Document information |
| _grist_ACLRules | Access control rules |
| _grist_ACLResources | ACL resources |
| _grist_Attachments | File attachment references |
| _grist_Cells | Cell metadata and comments |
| _grist_Views | View definitions |
| _grist_Pages | Page layout configuration |

### Querying Grist Metadata

```sql
-- List all user tables
SELECT id, tableId, primaryViewId
FROM _grist_Tables
WHERE tableId NOT LIKE '_grist_%';

-- List columns for a table
SELECT
    c.colId,
    c.type,
    c.isFormula,
    c.formula
FROM _grist_Tables_column c
JOIN _grist_Tables t ON c.parentId = t.id
WHERE t.tableId = 'Users';

-- Count records in all tables
SELECT
    tableId,
    (SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=tableId) as record_count
FROM _grist_Tables
WHERE tableId NOT LIKE '_grist_%';

-- Find reference columns
SELECT
    t.tableId,
    c.colId,
    c.type as ref_type
FROM _grist_Tables_column c
JOIN _grist_Tables t ON c.parentId = t.id
WHERE c.type LIKE 'Ref:%';

-- Check document size
SELECT page_count * page_size as size_bytes
FROM pragma_page_count(), pragma_page_size();
```

### Column Types

| Type | Description | SQLite Type |
| --- | --- | --- |
| Text | Text string | TEXT |
| Numeric | Number | REAL |
| Int | Integer | INTEGER |
| Bool | Boolean | INTEGER (0/1) |
| Date | Date only | REAL (timestamp) |
| DateTime | Date and time | REAL (timestamp) |
| Ref:Table | Reference to Table | INTEGER (row ID) |
| RefList:Table | List of references | TEXT (JSON array) |
| Attachments | File attachments | TEXT (JSON array) |
| Choice | Single choice | TEXT |
| ChoiceList | Multiple choices | TEXT (JSON array) |

## Recovery Time Objectives (RTO) Matrix

| Scenario | RTO | Recovery Steps | Tested |
| --- | --- | --- | --- |
| Server failure | 4-6 hrs | Provision → Deploy → Restore | Quarterly |
| Data corruption | 1-2 hrs | Stop → Restore → Verify | Quarterly |
| Accidental deletion | 30 min | Extract → Import | Monthly |
| Ransomware | 8-24 hrs | Rebuild → Restore clean backup | Annually |
| Site disaster | 12-48 hrs | Activate DR site → Restore | Annually |

## Recovery Point Objectives (RPO) Matrix

| Data Type | RPO | Backup Strategy |
| --- | --- | --- |
| Financial transactions | < 1 hour | Hourly incremental |
| User data | < 4 hours | 4-hourly backups |
| Documents | < 24 hours | Daily backups |
| Configuration | < 24 hours | Daily backups |
| System state | < 7 days | Weekly backups |

## Backup Size Estimates

| Data Type | Raw Size | Compressed | Notes |
| --- | --- | --- | --- |
| Grist documents | 100-500 MB | 30-150 MB | SQLite databases |
| Attachments | 1-10 GB | 0.9-9 GB | Already compressed (images, PDFs) |
| Configuration | 1-10 MB | 0.3-3 MB | Text files |
| Nginx config | 1-5 MB | 0.3-2 MB | Text files |
| SSL certificates | 5-10 MB | 1-3 MB | Binary files |
| Total estimate | 1-15 GB | 0.5-7 GB | Compression ratio: ~50% |

## Performance Benchmarks

### Backup Performance

| Data Size | gzip | pigz | Notes |
| --- | --- | --- | --- |
| 1 GB | ~3 min | ~1 min | 4 CPU cores |
| 5 GB | ~15 min | ~5 min | 4 CPU cores |
| 10 GB | ~30 min | ~10 min | 4 CPU cores |
| 50 GB | ~150 min | ~50 min | 4 CPU cores |

### Restore Performance

| Backup Size | Extract Time | Notes |
| --- | --- | --- |
| 1 GB | ~2 min | Local SSD |
| 5 GB | ~10 min | Local SSD |
| 10 GB | ~20 min | Local SSD |
| 50 GB | ~100 min | Local SSD |

### Network Transfer Rates

| Connection | Transfer Rate | 10 GB Backup |
| --- | --- | --- |
| 1 Gbps LAN | ~100 MB/s | ~2 min |
| 100 Mbps LAN | ~10 MB/s | ~17 min |
| 100 Mbps Internet | ~5 MB/s | ~35 min |
| 10 Mbps Internet | ~1 MB/s | ~3 hours |

## Retention Policy Calculator

Calculate required storage:

```
Daily backups:   Backup_Size × Daily_Retention
Weekly backups:  Backup_Size × (Weekly_Retention / 7)
Monthly backups: Backup_Size × (Monthly_Retention / 30)

Example (1 GB backup, 7/28/90 retention):
Daily:   1 GB × 7 = 7 GB
Weekly:  1 GB × 4 = 4 GB
Monthly: 1 GB × 3 = 3 GB
Total:   14 GB

Add 20% buffer: 14 GB × 1.2 = 16.8 GB required
```

## Exit Codes

Standard exit codes used by backup/restore scripts:

| Code | Meaning |
| --- | --- |
| 0 | Success |
| 1 | General error |
| 2 | Misuse of command |
| 126 | Command cannot execute |
| 127 | Command not found |
| 130 | Script terminated by Ctrl+C |
| 255 | Exit status out of range |

## Environment Variables

Variables used in backup/restore operations:

```bash
# Backup configuration
BACKUP_BASE_DIR="/opt/backups"
BACKUP_TYPE="daily"
TIMESTAMP="20251110_020000"

# Paths
GRIST_DATA_DIR="/opt/grist/data"
APP_CONFIG_DIR="/opt/flutter_grist_app/config"

# Retention
RETENTION_DAILY="7"
RETENTION_WEEKLY="28"
RETENTION_MONTHLY="90"

# Compression
USE_PIGZ="true"
COMPRESSION_LEVEL="6"

# Notification
NOTIFY_EMAIL="admin@example.com"
```

## API Reference

### Backup Script API

```bash
/opt/scripts/backup.sh [COMMAND]

Commands:
  daily       Create daily backup
  weekly      Create weekly backup
  monthly     Create monthly backup
  cleanup     Remove old backups
  stats       Show backup statistics

Exit Codes:
  0   Success
  1   Backup failed
  2   Invalid command
```

### Restore Script API

```bash
/opt/scripts/restore.sh [OPTIONS] [BACKUP_FILE]

Options:
  --list      List available backups
  --latest    Restore latest backup
  <file>      Restore specific backup

Exit Codes:
  0   Restore successful
  1   Restore failed
  2   Backup file not found
  3   User cancelled
```

## Regular Maintenance Schedule

### Daily Tasks

- [ ] Review backup logs: `tail -50 /var/log/backup.log`
- [ ] Check disk space: `df -h /opt/backups`
- [ ] Verify services: `docker ps && systemctl status nginx`

### Weekly Tasks

- [ ] Review backup statistics: `/opt/scripts/backup.sh stats`
- [ ] Check backup integrity: `sha256sum -c latest.tar.gz.sha256`
- [ ] Review error logs: `grep ERROR /var/log/backup.log`
- [ ] Update documentation

### Monthly Tasks

- [ ] Test restore procedure: `sudo /opt/scripts/restore.sh --latest` (test env)
- [ ] Review disk space trends
- [ ] Update retention policies if needed
- [ ] Review and update runbooks
- [ ] Generate monthly report

### Quarterly Tasks

- [ ] Full disaster recovery drill
- [ ] Review and update RTO/RPO
- [ ] Test off-site backup retrieval
- [ ] Review team access and permissions
- [ ] Update emergency contact list
- [ ] Security audit of backup system

### Annual Tasks

- [ ] Comprehensive DR plan review
- [ ] Update all documentation
- [ ] Review backup encryption keys
- [ ] Evaluate new backup technologies
- [ ] Update disaster recovery contracts
- [ ] Full team training session

## Compliance Requirements

### GDPR (General Data Protection Regulation)

- Backup retention must not exceed data retention policy
- Encrypted backups for personal data
- Documented data processing procedures
- Right to be forgotten: Remove from backups
- Breach notification within 72 hours

### HIPAA (Health Insurance Portability and Accountability Act)

- Encrypted backups (at rest and in transit)
- Access controls and audit logs
- Retention: 6 years minimum
- Disaster recovery plan required
- Regular security assessments

### SOX (Sarbanes-Oxley Act)

- Financial records: 7 years retention
- Tamper-proof backup storage
- Documented change control
- Regular restore testing
- Audit trail of all access

### ISO 27001

- Information security management
- Risk assessment documentation
- Incident response procedures
- Regular security training
- Continuous monitoring

## Glossary of Terms

| Term | Definition |
| --- | --- |
| Backup | Copy of data stored separately for recovery purposes |
| RTO | Recovery Time Objective - Maximum acceptable downtime |
| RPO | Recovery Point Objective - Maximum acceptable data loss |
| Full Backup | Complete copy of all data |
| Incremental | Backup of changes since last backup of any type |
| Differential | Backup of changes since last full backup |
| Checksum | Hash value for verifying data integrity |
| Retention | How long backups are kept before deletion |
| GFS | Grandfather-Father-Son backup rotation scheme |
| 3-2-1 Rule | 3 copies, 2 media types, 1 off-site |
| Snapshot | Point-in-time copy of data |
| Archive | Long-term storage of data |
| Corruption | Data damage making it unusable |
| Integrity | Assurance that data is accurate and unaltered |
| Disaster | Event causing significant data loss or downtime |

## Resources and References

### Official Documentation

- Grist Documentation: https://support.getgrist.com/
- Grist API Reference: https://support.getgrist.com/api/
- SQLite Documentation: https://www.sqlite.org/docs.html
- Ansible Documentation: https://docs.ansible.com/

### Backup Tools

- rsync: https://rsync.samba.org/
- tar: https://www.gnu.org/software/tar/
- pigz: https://zlib.net/pigz/
- rclone: https://rclone.org/

### Monitoring & Alerting

- Prometheus: https://prometheus.io/
- Grafana: https://grafana.com/
- Nagios: https://www.nagios.org/
- Zabbix: https://www.zabbix.com/

### Cloud Storage Providers

- Amazon S3: https://aws.amazon.com/s3/
- Google Cloud Storage: https://cloud.google.com/storage
- Azure Blob Storage: https://azure.microsoft.com/services/storage/blobs/
- Backblaze B2: https://www.backblaze.com/b2/

### Community Resources

- Grist Community Forum: https://community.getgrist.com/
- Stack Overflow: https://stackoverflow.com/questions/tagged/grist
- GitHub Issues: https://github.com/gristlabs/grist-core/issues

## Version History

| Version | Date | Changes |
| --- | --- | --- |
| 0.1.0 | 2025-11-10 | Initial documentation release |

## Contact Information

*Data Administration Team*
- Email: data-admin@example.com
- On-call: +1-555-0100
- Slack: #data-admin

*Emergency Contacts*
- Incident Commander: [Name] - [Phone]
- Technical Lead: [Name] - [Phone]
- Management: [Name] - [Phone]

*Vendor Support*
- Hosting Provider: [Company] - [Phone] - [Portal URL]
- Cloud Storage: [Company] - [Phone] - [Portal URL]
- DNS Provider: [Company] - [Phone] - [Portal URL]

---
