# Quick Start Guide

This guide walks you through the complete first-time setup of the FlutterGristAPI development environment using Docker.

> **Note**: **Estimated Time:** 15-20 minutes
>
> Prerequisites: Docker Desktop or Docker Engine with Compose V2 installed

## Pre-Flight Checklist

Before beginning, verify you have:

| Requirement | Description | Status |
| --- | --- | --- |
| Docker | Version 20.10+ with Compose V2 | □ |
| Git | Version 2.30+ | □ |
| Disk Space | 20+ GB free | □ |
| RAM | 4+ GB available | □ |
| Network | Internet access for downloads | □ |

*Verify Docker Installation:*

```bash
# Check Docker version
docker --version
# Should show: Docker version 20.10.x or higher

# Check Docker Compose (V2)
docker compose version
# Should show: Docker Compose version v2.x.x
```

## Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/flutterGristAPI.git
cd flutterGristAPI

# Verify project structure
ls -la
# Expected: docker-compose.yml, docker-test.sh, .env.example
```

> **Note**: **All commands must be run from the project root directory** unless otherwise specified.

## Step 2: Environment Configuration

### 2.1 Create Environment File

```bash
# Copy the example environment file
cp .env.example .env
```

### 2.2 Generate Secure Session Secret

The `GRIST_SESSION_SECRET` is critical for session security. Generate a strong random value:

*Option 1: Using OpenSSL (Recommended)*
```bash
# Linux/macOS
openssl rand -hex 32
```

*Option 2: Using Python*
```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

*Option 3: Manual Generation*

Use a password manager or create a random 64-character string.

### 2.3 Edit Environment File

Open `.env` in your text editor:

```bash
nano .env
# or
vim .env
# or
code .env  # VS Code
```

Update the configuration:

```bash
# Grist Configuration
GRIST_SESSION_SECRET=<paste-your-generated-secret-here>
GRIST_APP_HOME_URL=http://localhost:8484

# Optional: Set after creating API key
# GRIST_API_KEY=your-api-key-here
```

> **Danger**: **Security Warning**
>
> - Never commit `.env` file to version control
> - Use a unique secret for production environments
> - Keep secrets secure and rotate them periodically

## Step 3: Start Grist Server

```bash
# Start Grist in detached mode
./docker-test.sh grist-start
```

*Expected Output:*
```
Flutter Docker Test Runner
================================
Starting Grist server...
✓ Grist started at http://localhost:8484
```

### Verify Grist is Running

```bash
# Check container status
docker ps

# Expected output:
# CONTAINER ID   IMAGE                  STATUS   PORTS                    NAMES
# abc123...      gristlabs/grist:latest Up       0.0.0.0:8484->8484/tcp  grist_server
```

Access Grist web interface: Open http://localhost:8484 in your browser.

## Step 4: Initial Grist Configuration

### 4.1 Create Your First Document

1. Open http://localhost:8484 in your browser
2. Click *"Add New"* → *"Create Empty Document"*
3. Name it (e.g., "FlutterGristApp Database")

### 4.2 Create Users Table

Create a table named *"Users"* with the following columns:

| Column Name | Type | Description |
| --- | --- | --- |
| email | Text | User email address (unique identifier) |
| password_hash | Text | Bcrypt hashed password |
| role | Text | User role (admin, user, etc.) |
| active | Toggle | Account active status |

### 4.3 Add Test User

Add a test user to the Users table:

- *Email:* `test@example.com`
- *Password Hash:*
  ```
  $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
  ```
  (This is the bcrypt hash for password: `password123`)
- *Role:* `admin`
- *Active:* ✓ (checked)

> **Warning**: **Test Credentials**
>
> Username: `test@example.com`
>
> Password: `password123`
>
> Change these credentials in production!

### 4.4 Generate API Key

1. Click your profile icon (top right corner)
2. Select *"Profile Settings"*
3. Navigate to *"API"* section
4. Click *"Create"* to generate a new API key
5. **Copy and save this key** - you'll need it later

> **Note**: **Save Your API Key**
>
> The API key is displayed only once. Store it securely.
>
> You can optionally add it to `.env`:
> ```bash
> GRIST_API_KEY=your-generated-api-key-here
> ```

### 4.5 Get Document ID

Look at the browser URL:

```
http://localhost:8484/doc/ABC123xyz456
                            ^^^^^^^^^^^^
                            Your Document ID
```

Copy this Document ID - you'll need it for app configuration.

## Step 5: Build Flutter Docker Image

```bash
# Build the Flutter development image
./docker-test.sh build
```

*This will:*
- Download Flutter SDK 3.16.0
- Install all project dependencies
- Cache Flutter packages

> **Warning**: **First Build Takes Time**
>
> The initial build may take 5-10 minutes depending on your internet connection and system performance.
>
> Subsequent builds will be much faster due to Docker layer caching.

*Expected Output:*
```
Building Docker image...
[+] Building 234.5s (12/12) FINISHED
...
✓ Build complete
```

## Step 6: Run Tests

```bash
# Run code analysis and unit tests
./docker-test.sh all
```

*Expected Output:*
```
Running full test suite...

Running: Code Analysis
--------------------------------
Analyzing flutter_grist_widgets...
No issues found!
✓ Code Analysis completed successfully

Running: Unit Tests
--------------------------------
00:04 +77: All tests passed!
✓ Unit Tests completed successfully

================================
✓ All tests passed!
```

### Test Breakdown

The test suite includes:
- *46 tests* - Field validators
- *24 tests* - Expression evaluator
- *7 tests* - Password hashing
- *Total: 77 unit tests*

## Step 7: Verify Installation

### 7.1 Check All Services

```bash
# View all containers
docker ps

# Expected: grist_server running on port 8484
```

### 7.2 Access Grist UI

Open http://localhost:8484 - you should see your Grist document.

### 7.3 Check Logs

```bash
# View Grist logs (press Ctrl+C to exit)
./docker-test.sh grist-logs
```

Look for any errors or warnings.

### 7.4 Verify Data Persistence

```bash
# Check that grist-data directory exists
ls -la grist-module/grist-data/

# Should show .grist files and directories
```

## Setup Complete! ✓

> **Success**: **Congratulations!** Your FlutterGristAPI environment is ready.
>
> You now have:
> - ✓ Grist server running at http://localhost:8484
> - ✓ Flutter development environment configured
> - ✓ Test user created (test@example.com)
> - ✓ API key generated
> - ✓ All tests passing
> - ✓ Data persistence enabled

## Quick Reference

### Start/Stop Services

```bash
# Start Grist
./docker-test.sh grist-start

# Start all services
./docker-test.sh start-all

# Stop all services
./docker-test.sh stop-all
```

### Run Tests

```bash
# Run all tests
./docker-test.sh all

# Run only unit tests
./docker-test.sh test

# Run only code analysis
./docker-test.sh analyze
```

### View Logs

```bash
# Follow Grist logs
./docker-test.sh grist-logs

# View all service logs
docker-compose logs -f
```

### Access Shell

```bash
# Open Flutter development shell
./docker-test.sh shell

# Inside shell, you can run:
flutter test
flutter analyze
flutter pub get
```

## Next Steps

Now that your environment is set up, you can:

1. *Review Daily Workflow*
   - Learn how to manage services day-to-day
   - See `DAILY_USAGE.md` or explore daily operations

2. *Configure Your Application*
   - Create YAML configuration with your Document ID and API key
   - Test authentication and data access

3. *Explore Docker Setup*
   - Read `docker-setup.typ` for comprehensive Docker documentation
   - Learn about networks, volumes, and advanced configuration

4. *Implement Security*
   - Read `security.typ` for production security practices
   - Set up SSL/TLS, secrets management, and security scanning

5. *Set Up Monitoring*
   - Read `monitoring.typ` for logging and observability
   - Configure health checks and alerts

## Troubleshooting Quick Fixes

### Port 8484 Already in Use

```bash
# Find what's using the port
lsof -i :8484  # macOS/Linux
netstat -ano | findstr :8484  # Windows

# Stop the conflicting service
docker stop $(docker ps -q --filter "publish=8484")
```

### Cannot Access Grist UI

```bash
# Restart Grist
./docker-test.sh grist-restart

# Check logs for errors
./docker-test.sh grist-logs
```

### Docker Build Fails

```bash
# Clean Docker cache
docker system prune -a -f

# Rebuild without cache
docker-compose build --no-cache
```

### Tests Fail

```bash
# Update dependencies
./docker-test.sh shell
flutter pub get
flutter pub upgrade
exit

# Run tests again
./docker-test.sh all
```

### Permission Denied on docker-test.sh

```bash
# Make script executable
chmod +x docker-test.sh
```

---

> **Note**: **Need More Help?**
>
> - Comprehensive issues: See `troubleshooting.typ`
> - Docker deep dive: See `docker-setup.typ`
> - Command reference: See `commands.typ`

## Configuration Files Reference

### .env File Template

```bash
# Grist Configuration
GRIST_SESSION_SECRET=<64-char-random-hex>
GRIST_APP_HOME_URL=http://localhost:8484

# Optional: API Key (set after creating in Grist UI)
# GRIST_API_KEY=<your-api-key>

# Optional: User ID mapping (for Linux)
# USER_ID=1000
# GROUP_ID=1000
```

### docker-compose.yml Services

- *grist*: Database server (port 8484)
- *flutter*: Interactive development shell
- *flutter-test*: Automated test runner
- *flutter-analyze*: Static code analysis

### docker-test.sh Commands

```bash
# Grist Management
grist-start      # Start Grist server
grist-stop       # Stop Grist server
grist-restart    # Restart Grist server
grist-logs       # View Grist logs

# Testing
test             # Run unit tests
analyze          # Run code analysis
all              # Run analyze + test
shell            # Open interactive shell

# System
start-all        # Start all services
stop-all         # Stop all services
build            # Build Docker images
clean            # Remove all containers and volumes
```

## Important Directories

| Directory | Purpose |
| --- | --- |
| grist-module/grist-data/ | CRITICAL**: Grist database files (gitignored) |
| flutter-module/ | Flutter application source code |
| deployment-module/ | Production deployment configuration |
| documentation-module/ | Project documentation |
| .env | Environment variables (gitignored, never commit!) |

> **Danger**: **Data Safety**
>
> The `grist-module/grist-data/` directory contains all your Grist documents and data.
>
> - **Never delete** without a backup
> - **Never commit** to git (already gitignored)
> - **Always backup** before major operations

## Backup Your Data

Create your first backup:

```bash
# Create timestamped backup
tar -czf grist-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  grist-module/grist-data/

# Verify backup was created
ls -lh grist-backup-*.tar.gz
```

Schedule regular backups in your workflow!
