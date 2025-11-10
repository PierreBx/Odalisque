# Flutter Grist Widgets - Docker Setup

This document explains how to run Grist and test the Flutter Grist Widgets library using Docker.

## Overview

This Docker setup provides a complete development and testing environment with:
- **Grist Server**: Self-hosted spreadsheet-database running at http://localhost:8484
- **Flutter Testing**: Containerized Flutter SDK for running tests and analysis
- **Data Persistence**: Grist data stored in `./grist-data` directory on your host machine

## Prerequisites

- Docker installed ([Get Docker](https://docs.docker.com/get-docker/))
  - Docker Compose V2 is built into Docker Desktop and modern Docker CLI
  - This project uses `docker compose` commands (not the legacy `docker-compose`)

## Quick Start

**All Docker commands must be run from the project root directory.**

### 1. Set Up Environment (First Time Only)

```bash
# Copy environment template
cp .env.example .env

# Edit .env and set a secure session secret
# GRIST_SESSION_SECRET=your-random-secret-here
```

### 2. Start Grist Server

```bash
./docker-test.sh grist-start
```

Grist will be available at **http://localhost:8484**

**Note**: Your Grist data is stored in the `./grist-module/grist-data` directory and persists between container restarts.

### 3. Build Flutter Docker Image

```bash
./docker-test.sh build
```

### 4. Run Flutter Tests

```bash
./docker-test.sh all
```

## Grist Setup and Configuration

### Starting Grist for the First Time

1. **Start Grist server:**
   ```bash
   ./docker-test.sh grist-start
   ```

2. **Access Grist UI:** Open http://localhost:8484 in your browser

3. **Create your first document:**
   - Click "Add New" to create a Grist document
   - Set up your tables (e.g., Users table with email, password_hash, role fields)

4. **Generate API Key:**
   - Click your profile icon → Profile Settings
   - Go to "API" section
   - Click "Create API Key"
   - **Save this key** - you'll need it for your Flutter app configuration

5. **Update your app YAML configuration:**
   ```yaml
   grist:
     base_url: "http://grist:8484"  # Use "grist" hostname within Docker network
     document_id: "your-document-id-here"
     api_key: "your-api-key-here"
     users_table: "Users"
   ```

### Grist Data Directory Structure

```
grist-data/
├── README.md           # Documentation (committed to git)
└── [Grist files]       # .grist documents and data (gitignored)
```

**Important:** The `grist-data` directory contains your database files and is excluded from git (except the README). Back it up regularly!

## Quick Start (Alternative - All Services)

Start everything (Grist + Flutter) at once:

```bash
# Copy environment file
cp .env.example .env

# Start all services
./docker-test.sh start-all

# Build Flutter image and run tests
./docker-test.sh build
./docker-test.sh all
```

## Available Commands

### Using the Helper Script

```bash
./docker-test.sh <command>
```

**Flutter Commands:**
- `test` - Run unit tests
- `analyze` - Run Flutter analyzer (check for errors)
- `shell` - Open interactive bash shell in container
- `all` - Run both analyze and test
- `build` - Build the Flutter Docker image

**Grist Commands:**
- `grist-start` - Start Grist server (available at http://localhost:8484)
- `grist-stop` - Stop Grist server
- `grist-restart` - Restart Grist server
- `grist-logs` - View Grist server logs (follow mode)

**System Commands:**
- `start-all` - Start all services (Grist + Flutter)
- `stop-all` - Stop all services
- `clean` - Remove Docker containers and volumes (WARNING: This will delete Grist data!)

### Using Docker Compose Directly

**Grist:**
```bash
# Start Grist
docker-compose up -d grist

# Stop Grist
docker-compose stop grist

# View Grist logs
docker-compose logs -f grist

# Restart Grist
docker-compose restart grist
```

**Flutter:**
```bash
# Run tests
docker-compose run --rm flutter-test

# Run analysis
docker-compose run --rm flutter-analyze

# Interactive shell
docker-compose run --rm flutter-shell /bin/bash
```

**All Services:**
```bash
# Start everything
docker-compose up -d

# Stop everything
docker-compose stop

# Remove everything (including volumes)
docker-compose down -v
```

## Manual Testing Inside Container

Open an interactive shell:

```bash
./docker-test.sh shell
```

Then run commands manually:

```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run specific test file
flutter test test/utils/validators_test.dart

# Run analysis
flutter analyze

# Check Flutter installation
flutter doctor

# Run tests with verbose output
flutter test --reporter expanded

# Format code
dart format .

# Check for outdated packages
flutter pub outdated
```

## Expected Output

### Successful Test Run

```
✓ All tests passed!
```

### Test Details

The test suite includes:
- **46 tests** for field validators
- **24 tests** for expression evaluator
- **7 tests** for password hashing
- **Total: 77 unit tests**

### Successful Analysis

```
Analyzing flutter_grist_widgets...
No issues found!
```

## Troubleshooting

### Grist Issues

**Problem:** Grist container won't start

**Solution:**
```bash
# Check Grist logs
./docker-test.sh grist-logs

# Ensure .env file exists
cp .env.example .env

# Restart Grist
./docker-test.sh grist-restart
```

**Problem:** Cannot access Grist at http://localhost:8484

**Solution:**
```bash
# Check if Grist is running
docker ps | grep grist

# If not running, start it
./docker-test.sh grist-start

# Check port is not in use
lsof -i :8484  # macOS/Linux
netstat -ano | findstr :8484  # Windows
```

**Problem:** Grist data lost after `docker-compose down -v`

**Solution:**
The `-v` flag removes volumes. Never use it unless you want to delete all data!
Use `./docker-test.sh stop-all` instead to preserve data.

**Backup your Grist data:**
```bash
# Create backup
tar -czf grist-backup-$(date +%Y%m%d).tar.gz grist-data/

# Restore from backup
tar -xzf grist-backup-YYYYMMDD.tar.gz
```

**Problem:** "Connection refused" when Flutter app tries to reach Grist

**Solution:**
Make sure you're using the correct URL:
- Inside Docker network: `http://grist:8484`
- From host machine: `http://localhost:8484`

### Docker Build Issues

**Problem:** Build fails or takes too long

**Solution:**
```bash
# Clean everything and rebuild
./docker-test.sh clean
docker-compose build --no-cache
```

### Permission Issues

**Problem:** Permission denied errors

**Solution:**
```bash
chmod +x docker-test.sh
sudo chown -R $USER:$USER .
```

### Dependency Issues

**Problem:** Package resolution errors

**Solution:**
```bash
# Open shell and update dependencies
./docker-test.sh shell

# Inside container:
flutter pub get
flutter pub upgrade
```

### Memory Issues

**Problem:** Container runs out of memory

**Solution:**
Increase Docker memory limit in Docker Desktop settings (recommend 4GB+)

## Testing Individual Features

### Test Validators

```bash
docker-compose run --rm flutter-shell flutter test test/utils/validators_test.dart
```

### Test Expression Evaluator

```bash
docker-compose run --rm flutter-shell flutter test test/utils/expression_evaluator_test.dart
```

### Test Password Hashing

```bash
docker-compose run --rm flutter-shell flutter test test/services/grist_service_test.dart
```

## Development Workflow

### Complete Setup Workflow

**First Time Setup:**

1. **Initialize environment:**
   ```bash
   cp .env.example .env
   # Edit .env to set GRIST_SESSION_SECRET
   ```

2. **Start Grist:**
   ```bash
   ./docker-test.sh grist-start
   ```

3. **Configure Grist:**
   - Open http://localhost:8484
   - Create a new document
   - Set up your tables (Users, Products, etc.)
   - Generate an API key (Profile Settings → API)

4. **Build Flutter environment:**
   ```bash
   ./docker-test.sh build
   ```

5. **Run tests:**
   ```bash
   ./docker-test.sh all
   ```

### Daily Development Workflow

1. **Start Grist (if not running):**
   ```bash
   ./docker-test.sh grist-start
   ```

2. **Make code changes** on your host machine

3. **Run tests:**
   ```bash
   ./docker-test.sh all
   ```

4. **Fix issues** if tests fail

5. **Commit changes:**
   ```bash
   git add .
   git commit -m "Your message"
   git push
   ```

6. **Stop services when done:**
   ```bash
   ./docker-test.sh stop-all
   ```

### Testing Your Flutter App Against Grist

Your Flutter app YAML configuration should use the Docker network hostname:

```yaml
grist:
  base_url: "http://grist:8484"  # Use "grist" not "localhost"
  document_id: "YOUR_DOCUMENT_ID"
  api_key: "YOUR_API_KEY"
  users_table: "Users"
```

**Note:** Use `grist:8484` when your Flutter app runs inside Docker, and `localhost:8484` when testing locally outside Docker.

## Volumes

The Docker setup uses volumes for:
- **Grist Data:** `./grist-data` mounted to `/persist` in Grist container (persists Grist documents)
- **Flutter Code:** `.` mounted to `/app` in Flutter containers (live code sync)
- **Pub Cache:** Named volume `flutter-pub-cache` to avoid re-downloading packages

## Environment Variables

**Grist Variables (set in .env):**
- `GRIST_SESSION_SECRET` - Session encryption key (required)
- `GRIST_APP_HOME_URL` - Public URL for Grist (default: http://localhost:8484)

**Flutter Variables (in Dockerfile):**
- `FLUTTER_ROOT=/opt/flutter` - Flutter SDK location
- `FLUTTER_VERSION=3.16.0` - Flutter version (configurable in Dockerfile)

## Cleaning Up

Remove all Docker resources:

```bash
./docker-test.sh clean
```

Or manually:

```bash
docker-compose down -v
docker system prune -f
```

## Next Steps

1. **Run the tests:** `./docker-test.sh all`
2. **Fix any errors** that appear
3. **Test new features** by adding more test files
4. **Create example app** to manually test widgets

## Known Limitations

- **No GUI:** Can't run `flutter run` (no graphical environment)
- **Tests only:** Suitable for unit/widget tests, not integration tests
- **Web/Mobile:** Can't test on actual devices or browsers

## Alternative: Testing with GUI

If you need to test the actual UI:

1. Install Flutter locally on your host machine
2. Run `flutter run -d chrome` for web testing
3. Or connect a device/emulator and run `flutter run`

## Support

If you encounter issues:
1. Check the error messages carefully
2. Ensure Docker is running
3. Try rebuilding: `docker-compose build --no-cache`
4. Check Docker logs: `docker-compose logs`

## Summary

**Complete development environment:**

```bash
# First time setup
cp .env.example .env
./docker-test.sh grist-start       # Start Grist at http://localhost:8484
./docker-test.sh build              # Build Flutter image

# Daily workflow
./docker-test.sh grist-start        # Start Grist (if not running)
# Make code changes...
./docker-test.sh all                # Run tests

# When done
./docker-test.sh stop-all           # Stop everything
```

**This Docker environment provides:**
- ✅ Grist server with persistent data storage
- ✅ Flutter testing without local installation
- ✅ Isolated, reproducible development environment
- ✅ Complete integration testing capability

Access Grist at: **http://localhost:8484** 🎉
