# Disaster Recovery

## Introduction

Disaster recovery (DR) planning ensures business continuity when catastrophic failures occur. This guide covers recovery procedures, objectives, testing protocols, and runbooks for FlutterGristAPI applications.

> **Danger**: *Critical Information*
>
> Disaster recovery is not just about technology—it's about ensuring your organization can continue operations during and after a disaster. Plan, test, and update your DR procedures regularly.

## Disaster Recovery Objectives

### Recovery Time Objective (RTO)

Maximum acceptable downtime after a disaster:

| System Tier | RTO | Description |
| --- | --- | --- |
| Critical | < 1 hour | Revenue-impacting systems |
| Important | < 4 hours | Business operations |
| Standard | < 24 hours | Supporting systems |
| Low Priority | < 1 week | Archival, reporting |

*FlutterGristAPI Typical RTO*: 2-4 hours for full production recovery

### Recovery Point Objective (RPO)

Maximum acceptable data loss:

| Data Type | RPO | Backup Frequency |
| --- | --- | --- |
| Financial | < 15 min | Continuous replication |
| Transactional | < 1 hour | Hourly backups |
| User data | < 4 hours | Every 4 hours |
| Configuration | < 24 hours | Daily backups |

*FlutterGristAPI Typical RPO*: 24 hours (daily backups)

### Calculating Objectives

```
RTO Calculation:
  Detection time (15 min)
+ Decision time (15 min)
+ Recovery time (2 hours)
+ Verification time (30 min)
# Total RTO: 3 hours

RPO Calculation:
  Last backup: 2:00 AM
  Failure time: 1:00 PM
  Data loss: 11 hours of changes
  RPO met if target is ≥ 11 hours
```

## Disaster Scenarios

### Scenario 1: Server Hardware Failure

*Impact*: Complete server unavailability

*Detection*:
- Server monitoring alerts
- Application unreachable
- SSH connection fails

*Recovery Steps*:
1. Verify failure (attempt restart)
2. Provision new server
3. Deploy base configuration (Ansible)
4. Restore from latest backup
5. Update DNS/routing
6. Verify functionality
7. Monitor for issues

*Estimated RTO*: 4-6 hours

### Scenario 2: Data Corruption

*Impact*: Grist data corrupted or deleted

*Detection*:
- Users report data issues
- Integrity checks fail
- Application errors

*Recovery Steps*:
1. Stop Grist to prevent further corruption
2. Backup corrupted data (for analysis)
3. Identify last known good backup
4. Restore data from backup
5. Run integrity checks
6. Restart services
7. Verify data quality

*Estimated RTO*: 1-2 hours

### Scenario 3: Ransomware Attack

*Impact*: Data encrypted, systems locked

*Detection*:
- Files with .encrypted extension
- Ransom notes
- Service failures

*Recovery Steps*:
1. **DO NOT** pay ransom
2. Isolate infected systems (disconnect network)
3. Identify infection vector
4. Wipe and reinstall OS
5. Restore from clean, pre-infection backup
6. Scan restored data
7. Implement additional security measures

*Estimated RTO*: 8-24 hours

### Scenario 4: Natural Disaster (Site Loss)

*Impact*: Complete datacenter unavailable

*Detection*:
- Physical location access lost
- All systems unreachable
- News reports

*Recovery Steps*:
1. Activate disaster recovery site
2. Provision new infrastructure (cloud/alternate datacenter)
3. Restore from off-site backups
4. Update DNS to new location
5. Verify services
6. Communicate with stakeholders

*Estimated RTO*: 12-48 hours

### Scenario 5: Accidental Deletion

*Impact*: Table or document accidentally deleted

*Detection*:
- User reports missing data
- Document not found errors

*Recovery Steps*:
1. Identify what was deleted and when
2. Find appropriate backup (before deletion)
3. Extract specific data from backup
4. Restore only affected components
5. Verify restoration
6. Document incident

*Estimated RTO*: 30 minutes - 2 hours

## Recovery Procedures

### Full System Recovery

*Complete server rebuild and data restoration*

```bash
#!/bin/bash
# full-system-recovery.sh

set -e

echo "=========================================="
echo "FlutterGristAPI Full System Recovery"
echo "=========================================="

# Step 1: Verify new server
echo "[1/7] Verifying server environment..."
if ! command -v ansible &> /dev/null; then
    echo "Error: Ansible not installed"
    exit 1
fi

# Step 2: Configure base system
echo "[2/7] Deploying base configuration..."
cd /path/to/flutterGristAPI/deployment-module
ansible-playbook -i inventory/hosts.yml \
    playbooks/configure_server.yml

# Step 3: Stop services
echo "[3/7] Stopping services..."
ssh production "docker stop grist_server || true"
ssh production "systemctl stop nginx || true"

# Step 4: Identify latest backup
echo "[4/7] Identifying latest backup..."
LATEST_BACKUP=$(ssh production "ls -t /opt/backups/*/*.tar.gz | head -1")
echo "Latest backup: $LATEST_BACKUP"

# Step 5: Restore data
echo "[5/7] Restoring from backup..."
ssh production "sudo /opt/scripts/restore.sh $LATEST_BACKUP"

# Step 6: Verify services
echo "[6/7] Verifying services..."
sleep 10
ssh production "docker ps | grep grist_server"
ssh production "systemctl status nginx"
ssh production "curl -f http://localhost:8484 > /dev/null"

# Step 7: Run integrity checks
echo "[7/7] Running integrity checks..."
ssh production "python3 /opt/scripts/scan-corruption.py /opt/grist/data"

echo "=========================================="
echo "Recovery completed successfully!"
echo "=========================================="
echo "Next steps:"
echo "  1. Verify application functionality"
echo "  2. Test user access"
echo "  3. Review logs for issues"
echo "  4. Document incident"
```

### Selective Data Recovery

*Restore specific tables or documents*

```bash
#!/bin/bash
# selective-recovery.sh

BACKUP_FILE="$1"
TABLE_TO_RESTORE="$2"
TEMP_DIR="/tmp/selective-restore-$$"

echo "Restoring table: $TABLE_TO_RESTORE"
echo "From backup: $BACKUP_FILE"

# Extract backup
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

# Find Grist document
GRIST_DOC=$(find "$TEMP_DIR" -name "*.grist" -type f | head -1)

if [ -z "$GRIST_DOC" ]; then
    echo "Error: No Grist document found in backup"
    exit 1
fi

# Export specific table
sqlite3 "$GRIST_DOC" << EOF
.headers on
.mode csv
.output /tmp/${TABLE_TO_RESTORE}.csv
SELECT * FROM ${TABLE_TO_RESTORE};
EOF

echo "Table exported to: /tmp/${TABLE_TO_RESTORE}.csv"
echo "Import this into Grist manually or via API"

# Cleanup
rm -rf "$TEMP_DIR"
```

### Point-in-Time Recovery

*Restore to specific date/time*

```bash
#!/bin/bash
# point-in-time-recovery.sh

TARGET_DATE="$1"  # Format: YYYY-MM-DD
TARGET_TIME="$2"  # Format: HH:MM (optional)

echo "Finding backup closest to: $TARGET_DATE $TARGET_TIME"

# Find all backups
BACKUPS=$(find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' | sort -n)

# Convert target to timestamp
if [ -n "$TARGET_TIME" ]; then
    TARGET_TIMESTAMP=$(date -d "$TARGET_DATE $TARGET_TIME" +%s)
else
    TARGET_TIMESTAMP=$(date -d "$TARGET_DATE" +%s)
fi

# Find closest backup before target time
CLOSEST_BACKUP=""
MIN_DIFF=999999999

while read TIMESTAMP BACKUP; do
    DIFF=$((TARGET_TIMESTAMP - ${TIMESTAMP%.*}))

    # Only consider backups before target time
    if [ $DIFF -ge 0 ] && [ $DIFF -lt $MIN_DIFF ]; then
        MIN_DIFF=$DIFF
        CLOSEST_BACKUP="$BACKUP"
    fi
done <<< "$BACKUPS"

if [ -z "$CLOSEST_BACKUP" ]; then
    echo "No suitable backup found"
    exit 1
fi

BACKUP_DATE=$(date -d "@$(stat -c %Y "$CLOSEST_BACKUP")" "+%Y-%m-%d %H:%M:%S")
echo "Found backup from: $BACKUP_DATE"
echo "Backup file: $CLOSEST_BACKUP"

# Restore
/opt/scripts/restore.sh "$CLOSEST_BACKUP"
```

## Testing Recovery

### Quarterly DR Drill

> **Warning**: *Untested DR Plans Fail*
>
> Schedule quarterly disaster recovery drills. Document results and improve procedures based on findings.

*DR Drill Procedure*:

```bash
#!/bin/bash
# dr-drill.sh - Disaster Recovery Drill

DRILL_DATE=$(date +%Y-%m-%d)
DRILL_LOG="/var/log/dr-drill-${DRILL_DATE}.log"

exec 1> >(tee -a "$DRILL_LOG")
exec 2>&1

echo "=========================================="
echo "Disaster Recovery Drill"
echo "Date: $DRILL_DATE"
echo "=========================================="

# Simulate disaster scenario
SCENARIO="Data corruption detected"
echo "Scenario: $SCENARIO"

# Track timing
START_TIME=$(date +%s)

# Step 1: Detection
echo "[Detection Phase]"
DETECT_START=$(date +%s)
echo "  Simulating issue detection..."
sleep 5  # Simulate detection time
DETECT_END=$(date +%s)
DETECT_TIME=$((DETECT_END - DETECT_START))
echo "  Detection time: ${DETECT_TIME}s"

# Step 2: Decision
echo "[Decision Phase]"
DECISION_START=$(date +%s)
echo "  Reviewing backup availability..."
/opt/scripts/restore.sh --list > /dev/null
DECISION_END=$(date +%s)
DECISION_TIME=$((DECISION_END - DECISION_START))
echo "  Decision time: ${DECISION_TIME}s"

# Step 3: Recovery (to test environment)
echo "[Recovery Phase]"
RECOVERY_START=$(date +%s)
echo "  Restoring to test environment..."
# Perform actual restore to test server
ssh test-server "sudo /opt/scripts/restore.sh --latest"
RECOVERY_END=$(date +%s)
RECOVERY_TIME=$((RECOVERY_END - RECOVERY_START))
echo "  Recovery time: ${RECOVERY_TIME}s"

# Step 4: Verification
echo "[Verification Phase]"
VERIFY_START=$(date +%s)
echo "  Verifying restored data..."
ssh test-server "docker ps | grep grist_server"
ssh test-server "curl -f http://localhost:8484 > /dev/null"
ssh test-server "python3 /opt/scripts/scan-corruption.py /opt/grist/data"
VERIFY_END=$(date +%s)
VERIFY_TIME=$((VERIFY_END - VERIFY_START))
echo "  Verification time: ${VERIFY_TIME}s"

# Calculate total RTO
END_TIME=$(date +%s)
TOTAL_RTO=$((END_TIME - START_TIME))
TOTAL_RTO_MIN=$((TOTAL_RTO / 60))

echo "=========================================="
echo "Drill Results:"
echo "  Detection:    ${DETECT_TIME}s"
echo "  Decision:     ${DECISION_TIME}s"
echo "  Recovery:     ${RECOVERY_TIME}s ($((RECOVERY_TIME / 60)) min)"
echo "  Verification: ${VERIFY_TIME}s"
echo "  TOTAL RTO:    ${TOTAL_RTO}s (${TOTAL_RTO_MIN} min)"
echo "=========================================="

# Check if RTO met
TARGET_RTO=14400  # 4 hours in seconds
if [ $TOTAL_RTO -le $TARGET_RTO ]; then
    echo "✓ RTO objective MET (< 4 hours)"
else
    echo "✗ RTO objective MISSED (> 4 hours)"
fi

echo ""
echo "Drill log saved: $DRILL_LOG"
echo "Please review and update DR procedures as needed"
```

Schedule quarterly:
```cron
# Quarterly DR drill (Jan 15, Apr 15, Jul 15, Oct 15 at 9 AM)
0 9 15 1,4,7,10 * /opt/scripts/dr-drill.sh | mail -s "DR Drill Results" admin@example.com
```

### Backup Restore Testing

*Monthly backup integrity and restore test*:

```bash
#!/bin/bash
# monthly-restore-test.sh

TEST_DIR="/tmp/restore-test-$(date +%Y%m%d)"
LATEST_BACKUP=$(find /opt/backups -name "*.tar.gz" -type f -printf '%T@ %p\n' |
                sort -rn | head -1 | cut -d' ' -f2-)

echo "Testing restore of: $LATEST_BACKUP"

# Create test directory
mkdir -p "$TEST_DIR"

# Extract and verify
tar -xzf "$LATEST_BACKUP" -C "$TEST_DIR"

# Check contents
REQUIRED_FILES=(
    "grist_data"
    "app_config"
    "backup_metadata.txt"
)

PASS=true
for FILE in "${REQUIRED_FILES[@]}"; do
    if find "$TEST_DIR" -name "$FILE" -type d,f | grep -q .; then
        echo "✓ Found: $FILE"
    else
        echo "✗ Missing: $FILE"
        PASS=false
    fi
done

# Cleanup
rm -rf "$TEST_DIR"

if [ "$PASS" = true ]; then
    echo "✓ Restore test PASSED"
    exit 0
else
    echo "✗ Restore test FAILED"
    exit 1
fi
```

## Recovery Runbooks

### Runbook Template

```markdown
# Runbook: [Disaster Scenario]

## Overview
- **Scenario**: [Description]
- **Impact**: [Systems/data affected]
- **RTO**: [Target recovery time]
- **RPO**: [Acceptable data loss]

## Detection
- **Symptoms**: [How to identify]
- **Monitoring alerts**: [Relevant alerts]
- **Verification steps**: [Confirm it's this scenario]

## Response Team
- **Incident Commander**: [Name/Role]
- **Technical Lead**: [Name/Role]
- **Communication Lead**: [Name/Role]
- **Stakeholders**: [Who to notify]

## Prerequisites
- [ ] Access to backup server
- [ ] Access to cloud accounts
- [ ] Ansible configured
- [ ] Emergency contact list
- [ ] Off-site backup credentials

## Recovery Procedure

### Phase 1: Assessment (Target: 15 minutes)
1. Confirm disaster scenario
2. Assess extent of damage
3. Identify last known good state
4. Notify stakeholders
5. Activate DR team

### Phase 2: Containment (Target: 30 minutes)
1. Isolate affected systems
2. Prevent further damage
3. Document current state
4. Preserve evidence (if security incident)

### Phase 3: Recovery (Target: 2 hours)
1. [Specific recovery steps]
2. ...
3. ...

### Phase 4: Verification (Target: 30 minutes)
1. Test system functionality
2. Verify data integrity
3. Check user access
4. Monitor for issues

### Phase 5: Normalization (Target: 1 hour)
1. Update documentation
2. Communicate status
3. Monitor stability
4. Begin post-incident review

## Rollback Procedure
If recovery fails:
1. [Rollback steps]
2. ...

## Verification Checklist
- [ ] Grist server responding
- [ ] Nginx serving requests
- [ ] SSL certificates valid
- [ ] Data integrity checks pass
- [ ] User logins working
- [ ] API endpoints responding
- [ ] Backups resuming normally

## Post-Recovery
- [ ] Incident report completed
- [ ] Lessons learned documented
- [ ] DR plan updated
- [ ] Team debriefing scheduled

## Contacts
- **On-call Admin**: [Phone/Email]
- **Backup Admin**: [Phone/Email]
- **Management**: [Phone/Email]
- **Hosting Provider**: [Phone/Email]

## Related Documents
- Backup procedures: /docs/backup-strategies.md
- Configuration playbooks: /deployment-module/playbooks/
- Network diagrams: /docs/architecture.md
```

### Runbook: Server Hardware Failure

```bash
#!/bin/bash
# runbook-hardware-failure.sh

cat << 'EOF'
╔═══════════════════════════════════════════╗
║  RUNBOOK: SERVER HARDWARE FAILURE         ║
║  RTO: 4-6 hours | RPO: 24 hours          ║
╚═══════════════════════════════════════════╝

PHASE 1: ASSESSMENT (Target: 15 min)
─────────────────────────────────────
□ Verify server is truly down
  └─ Ping: ping production-server
  └─ SSH: ssh user@production-server
  └─ Console: Check cloud provider console

□ Check monitoring alerts
  └─ Review alert history
  └─ Check related systems

□ Notify stakeholders
  └─ Email: Send status email
  └─ Slack: Post in #incidents

PHASE 2: CONTAINMENT (Target: 30 min)
──────────────────────────────────────
□ Update DNS (if needed)
  └─ Set maintenance page
  └─ Update status page

□ Preserve state information
  └─ Screenshot cloud console
  └─ Save logs (if accessible)

PHASE 3: RECOVERY (Target: 2-3 hours)
──────────────────────────────────────
□ Provision new server
  └─ Cloud provider: Launch new instance
  └─ Same specs: 4 CPU, 8GB RAM, 100GB disk
  └─ Same region: [Region]
  └─ SSH keys: Deploy authorized_keys

□ Configure base system
  └─ cd flutterGristAPI/deployment-module
  └─ Update inventory with new IP
  └─ Run: ansible-playbook -i inventory/hosts.yml \
           playbooks/configure_server.yml

□ Restore from backup
  └─ SSH to new server
  └─ Run: sudo /opt/scripts/restore.sh --latest
  └─ Confirm restore successful

□ Update DNS
  └─ Point domain to new IP
  └─ Wait for propagation (5-30 min)

PHASE 4: VERIFICATION (Target: 30 min)
───────────────────────────────────────
□ Test services
  └─ Grist: curl https://yourdomain.com
  └─ Login: Test user authentication
  └─ API: curl API endpoints

□ Verify data
  └─ Check recent documents
  └─ Run: python3 /opt/scripts/scan-corruption.py

□ Monitor logs
  └─ tail -f /var/log/nginx/error.log
  └─ docker logs grist_server

PHASE 5: NORMALIZATION (Target: 1 hour)
────────────────────────────────────────
□ Resume backups
  └─ Verify cron jobs: crontab -l
  └─ Test manual backup: /opt/scripts/backup.sh daily

□ Update documentation
  └─ Document new server IP
  └─ Update network diagrams
  └─ Record configuration changes

□ Communicate resolution
  └─ Send all-clear email
  └─ Update status page
  └─ Post in #incidents

□ Schedule post-mortem
  └─ Within 48 hours
  └─ Invite: DR team + stakeholders

CONTACTS
────────
On-call Admin:  [Your contact]
Cloud Provider: [Support number]
DNS Provider:   [Support number]

ROLLBACK
────────
If recovery fails, restore to previous server
or contact [Escalation contact]

EOF
```

## Communication Plan

### Stakeholder Matrix

| Stakeholder | Role | Notify When | Method |
| --- | --- | --- | --- |
| Executive Team | Decision makers | Immediate | Phone + Email |
| IT Team | Recovery team | Immediate | Slack + SMS |
| End Users | Customers | Within 30 min | Email + Status page |
| Vendors | Service providers | As needed | Email + Phone |

### Status Updates

*Update frequency during incident*:
- First 30 minutes: Every 15 minutes
- Next 2 hours: Every 30 minutes
- After 2 hours: Hourly
- Resolution: Final summary

*Template*:

```
Subject: [INCIDENT] FlutterGristAPI - [Status]

Status: [In Progress / Resolved]
Impact: [Description]
Started: [Time]
ETA: [Estimated recovery time]

Current Actions:
- [Action 1]
- [Action 2]

Next Update: [Time]

For questions, contact: [Name] at [Contact]
```

## Post-Incident Review

### Post-Mortem Template

```markdown
# Incident Post-Mortem

## Incident Summary
- **Date**: [YYYY-MM-DD]
- **Duration**: [X hours]
- **Severity**: [Critical/High/Medium/Low]
- **Impact**: [Users affected, data lost]

## Timeline
| Time | Event |
|------|-------|
| 13:00 | Issue detected |
| 13:15 | Team notified |
| 13:30 | Recovery started |
| 15:00 | Service restored |
| 15:30 | Verified stable |

## Root Cause
[Detailed analysis of what caused the incident]

## What Went Well
- [Positive aspect 1]
- [Positive aspect 2]

## What Went Wrong
- [Issue 1]
- [Issue 2]

## Action Items
| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| [Action 1] | [Name] | [Date] | [ ] |
| [Action 2] | [Name] | [Date] | [ ] |

## Lessons Learned
[Key takeaways and improvements]
```

## Best Practices

> **Success**: *Disaster Recovery Best Practices*
>
> 1. *Document Everything* - Runbooks, contacts, procedures
> 2. *Test Regularly* - Quarterly DR drills minimum
> 3. *Automate Recovery* - Scripts for common scenarios
> 4. *Multiple Backups* - On-site, off-site, cloud
> 5. *Clear Communication* - Stakeholder notification plan
> 6. *Assign Roles* - Everyone knows their responsibilities
> 7. *Review and Update* - After every incident
> 8. *Train Team* - Everyone knows basic procedures
> 9. *Monitor RTO/RPO* - Track if objectives are met
> 10. *Keep It Simple* - Complex plans fail under pressure
