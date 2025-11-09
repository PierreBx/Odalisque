# Grist Module

This module contains persistent data storage for Grist documents.

## Contents

- **grist-data/** - Persistent Grist data directory
  - All Grist documents (.grist files)
  - User data and configuration
  - **gitignored** except for README.md

## Purpose

Provides persistent storage for Grist server data that survives container restarts.

## Data Persistence

The `grist-data/` directory is mounted into the Grist Docker container at `/persist`.

**Important:**
- This directory contains ALL your Grist documents
- It is excluded from git (except the README.md)
- Always back it up regularly!

## Backup Grist Data

From the project root:

```bash
# Create timestamped backup
tar -czf grist-backup-$(date +%Y%m%d-%H%M%S).tar.gz grist-module/grist-data/

# Example: grist-backup-20250109-143022.tar.gz
```

## Restore Grist Data

```bash
# Extract backup (from project root)
tar -xzf grist-backup-YYYYMMDD-HHMMSS.tar.gz
```

## Docker Configuration

Docker configuration is now at the **project root**:
- `../docker-compose.yml` - Service definitions
- `../docker-test.sh` - Helper scripts
- `../.env` - Environment variables

The Grist service in docker-compose.yml mounts this directory:
```yaml
volumes:
  - ./grist-module/grist-data:/persist
```

## Grist Commands

All commands run from the **project root**:

```bash
# Start Grist server
./docker-test.sh grist-start

# Stop Grist server
./docker-test.sh grist-stop

# View logs
./docker-test.sh grist-logs

# Restart Grist
./docker-test.sh grist-restart
```

## Access Grist

Once started, access Grist at: **http://localhost:8484**

## Documentation

For complete Grist setup and usage:
- **../documentation-module/QUICKSTART.md** - First-time setup
- **../documentation-module/DAILY_USAGE.md** - Daily workflow
- **../documentation-module/README_DOCKER.md** - Docker details
