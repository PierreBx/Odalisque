# Daily Usage Guide

This guide covers the typical daily workflow for developing with Flutter Grist Widgets.

## Morning Routine - Starting Your Dev Environment

### 1. Start Grist Server

```bash
# Navigate to project directory
cd flutterGristAPI

# Start Grist (if not already running)
./docker-test.sh grist-start
```

**Output:**
```
✓ Grist started at http://localhost:8484
```

### 2. Verify Grist is Running

Open your browser and navigate to:
```
http://localhost:8484
```

You should see your Grist documents.

### 3. Check Docker Status (Optional)

```bash
# See all running containers
docker ps

# Should show:
# - grist_server (port 8484)
```

## Development Workflow

### Making Code Changes

1. **Edit files** on your host machine using your favorite IDE:
   - VS Code
   - Android Studio
   - IntelliJ IDEA
   - Any text editor

2. **Files are automatically synced** to the Docker container (live mounting)

### Running Tests After Changes

#### Quick Test (Recommended)

```bash
# Run both analysis and tests
./docker-test.sh all
```

**Expected output:**
```
Running Code Analysis...
✓ Code Analysis passed

Running Unit Tests...
✓ Unit Tests passed

✓ All tests passed!
```

#### Individual Commands

```bash
# Run only code analysis
./docker-test.sh analyze

# Run only unit tests
./docker-test.sh test

# Open interactive shell for manual testing
./docker-test.sh shell
```

### Working with Grist Data

#### Viewing Grist Logs

```bash
# Follow Grist logs in real-time
./docker-test.sh grist-logs

# Press Ctrl+C to exit
```

#### Restarting Grist

```bash
# If Grist becomes unresponsive or you need to reload configuration
./docker-test.sh grist-restart
```

#### Backing Up Grist Data

```bash
# Create a timestamped backup of all Grist data
tar -czf grist-backup-$(date +%Y%m%d-%H%M%S).tar.gz grist-data/

# Example output: grist-backup-20250109-143022.tar.gz
```

**💡 Tip:** Create backups before major changes or at the end of each day.

## Common Development Tasks

### Task 1: Adding a New Feature

```bash
# 1. Edit your code in lib/src/

# 2. Run analysis to check for errors
./docker-test.sh analyze

# 3. Write tests in test/

# 4. Run all tests
./docker-test.sh all

# 5. Commit if tests pass
git add .
git commit -m "Add new feature"
git push
```

### Task 2: Fixing a Bug

```bash
# 1. Reproduce the bug

# 2. Write a test that fails (demonstrates the bug)
# Edit test files in test/

# 3. Run tests to confirm failure
./docker-test.sh test

# 4. Fix the code in lib/src/

# 5. Run tests to confirm fix
./docker-test.sh all

# 6. Commit the fix
git add .
git commit -m "Fix: description of bug fixed"
git push
```

### Task 3: Updating Dependencies

```bash
# 1. Edit pubspec.yaml on your host machine

# 2. Open shell in container
./docker-test.sh shell

# 3. Inside the container:
flutter pub get
flutter pub upgrade

# 4. Exit shell (Ctrl+D or type 'exit')

# 5. Run tests to ensure everything still works
./docker-test.sh all
```

### Task 4: Adding New Grist Tables

```bash
# 1. Open Grist UI
# http://localhost:8484

# 2. Navigate to your document

# 3. Click "Add New" → "Add Table"

# 4. Define columns and data types

# 5. Update your YAML configuration if needed

# 6. Test with your Flutter app
```

### Task 5: Testing Specific Test Files

```bash
# Open shell
./docker-test.sh shell

# Inside container, run specific test file:
flutter test test/utils/validators_test.dart

# Or run tests matching a pattern:
flutter test --name="email validator"

# Exit when done
exit
```

## Debugging

### Interactive Debugging Session

```bash
# 1. Open shell
./docker-test.sh shell

# 2. Inside container, you can:

# Run analysis with verbose output
flutter analyze --verbose

# Run tests with verbose output
flutter test --reporter expanded

# Check Flutter doctor
flutter doctor -v

# List dependencies
flutter pub deps

# Clean and rebuild
flutter clean
flutter pub get

# 3. Exit shell
exit
```

### Checking Service Status

```bash
# Check if Grist container is running
docker ps | grep grist

# Check Grist container health
docker inspect grist_server | grep -A 10 State

# View all container logs
docker-compose logs

# View last 50 lines of Grist logs
docker-compose logs --tail=50 grist
```

### Common Issues and Quick Fixes

| Problem | Command | Notes |
|---------|---------|-------|
| Grist not responding | `./docker-test.sh grist-restart` | Restarts Grist container |
| Tests failing unexpectedly | `./docker-test.sh build` then `./docker-test.sh all` | Rebuilds container |
| Port 8484 in use | `docker ps` then `docker stop <container>` | Stop conflicting container |
| Need to clear cache | `docker-compose down -v` | ⚠️ This deletes Grist data! |
| Code changes not reflected | Restart container or rebuild | Files should sync automatically |

## Working with Grist API

### Testing API Endpoints Manually

```bash
# Get your API key from Grist UI (Profile → API)

# Example: Fetch all records from Users table
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:8484/api/docs/YOUR_DOC_ID/tables/Users/records

# Example: Add a new record
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"records":[{"fields":{"email":"new@example.com","role":"user"}}]}' \
  http://localhost:8484/api/docs/YOUR_DOC_ID/tables/Users/records
```

### Viewing API Documentation

Grist API documentation: https://support.getgrist.com/api/

## Git Workflow

### Typical Daily Commits

```bash
# 1. Check status
git status

# 2. View changes
git diff

# 3. Stage changes
git add .

# 4. Commit with descriptive message
git commit -m "feat: add pagination to data tables"

# 5. Push to remote
git push

# Alternative: Stage and commit in one step
git commit -am "fix: resolve sorting issue in GristTableWidget"
```

### Commit Message Conventions

Use conventional commits for clarity:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `style:` - Code style changes (formatting)
- `chore:` - Maintenance tasks

**Examples:**
```bash
git commit -m "feat: add file upload widget with drag & drop"
git commit -m "fix: correct bcrypt password validation"
git commit -m "test: add unit tests for validators"
git commit -m "docs: update API usage examples"
```

## End of Day Routine

### Before Shutting Down

```bash
# 1. Run final tests
./docker-test.sh all

# 2. Commit your work
git add .
git commit -m "Your commit message"
git push

# 3. Backup Grist data (optional but recommended)
tar -czf grist-backup-$(date +%Y%m%d).tar.gz grist-data/

# 4. Stop services (keeps data)
./docker-test.sh stop-all
```

**Output:**
```
✓ All services stopped
```

### If You Want to Keep Grist Running

```bash
# Just stop Flutter containers, leave Grist running
docker stop flutter_grist_widgets_test
docker stop flutter_grist_widgets_analyze
docker stop flutter_grist_widgets_shell

# Or do nothing - Grist can run 24/7
```

## Weekly Maintenance

### Once a Week

```bash
# Update Docker images
docker-compose pull

# Rebuild Flutter container with latest dependencies
./docker-test.sh build

# Clean up unused Docker resources
docker system prune -f

# Backup Grist data to external location
cp -r grist-data/ ~/backups/grist-data-$(date +%Y%m%d)/
```

## Performance Tips

### Speed Up Test Runs

```bash
# Run specific test suites instead of all tests
./docker-test.sh shell
flutter test test/utils/  # Only test utils
flutter test test/services/  # Only test services
exit
```

### Keep Flutter Container Running

```bash
# Instead of starting/stopping containers, keep shell open:
./docker-test.sh shell

# Inside shell, run commands as needed:
flutter test
flutter analyze
# etc...

# This avoids container startup overhead
```

### Monitor Resource Usage

```bash
# Check Docker resource usage
docker stats

# Check Grist memory usage
docker stats grist_server

# See container sizes
docker ps -s
```

## Cheat Sheet - Quick Reference

**Note:** Run all docker-test.sh commands from the project root directory.

```bash
# START
./docker-test.sh grist-start       # Start Grist
./docker-test.sh build              # Build Flutter (first time only)

# DEVELOP
# Edit code in flutter-module/ with your IDE
./docker-test.sh analyze            # Check for errors
./docker-test.sh test               # Run tests
./docker-test.sh all                # Run both

# DEBUG
./docker-test.sh shell              # Interactive shell
./docker-test.sh grist-logs         # View Grist logs

# GIT (from project root)
cd ..                               # Back to root
git status                          # Check changes
git add .                           # Stage changes
git commit -m "message"             # Commit
git push                            # Push to remote

# MAINTENANCE
./docker-test.sh grist-restart          # Restart Grist
tar -czf backup.tar.gz grist-module/grist-data/  # Backup data

# END
./docker-test.sh stop-all           # Stop everything
```

## Getting Help

- 📖 **Detailed Docker docs:** README_DOCKER.md
- 📖 **First time setup:** QUICKSTART.md
- 🐛 **Report issues:** GitHub Issues
- 📚 **Grist API docs:** https://support.getgrist.com/api/
- 💬 **Flutter docs:** https://flutter.dev/docs

## Next Steps

- Review the library documentation in README.md
- Explore example configurations in example/
- Check out the test files to understand expected behavior
- Experiment with creating new widgets and pages

Happy coding! 🚀
