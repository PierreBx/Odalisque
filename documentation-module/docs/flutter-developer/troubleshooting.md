# Troubleshooting Guide

Solutions to common problems encountered during Flutter development.

## Build Errors

### Error: Package Not Found

*Symptom:*
```
Error: Could not resolve the package 'package_name' in 'pubspec.yaml'.
```

*Solution:*
```bash
# 1. Verify package name in pubspec.yaml
# 2. Get dependencies
flutter pub get

# 3. If still failing, repair cache
flutter pub cache repair

# 4. Try again
flutter pub get
```

### Error: Version Conflict

*Symptom:*
```
Because package_a depends on package_b ^1.0.0 and package_c depends on
package_b ^2.0.0, package_a is incompatible with package_c.
```

*Solution:*
```bash
# 1. Check dependency tree
flutter pub deps

# 2. Update conflicting packages
flutter pub upgrade package_b

# 3. If unresolvable, use dependency_overrides in pubspec.yaml
dependency_overrides:
  package_b: ^2.0.0
```

### Error: Build Failed

*Symptom:*
```
Compiler message:
Error: Method not found: 'someMethod'.
```

*Solution:*
```bash
# 1. Clean build artifacts
flutter clean

# 2. Get dependencies again
flutter pub get

# 3. Check for breaking changes in dependencies
flutter pub outdated

# 4. Fix code to match API changes
```

## Test Failures

### Tests Pass Locally But Fail in CI

*Symptom:*
Tests pass on your machine but fail in Docker/CI.

*Solution:*
```bash
# 1. Test in Docker locally
cd grist-module
./docker-test.sh build
./docker-test.sh test

# 2. Check for environment differences
# - Timezone assumptions
# - Missing test fixtures

# 3. Verify Docker image is up to date
./docker-test.sh build --no-cache
```

### Test Timeout

*Symptom:*
```
Test timed out after 30 seconds.
```

*Solution:*
```dart

testWidgets('my test', (tester) async {
  // ...
}, timeout: Timeout(Duration(seconds: 60)));

void main() {
  setUp(() {
    // Set timeout for all tests
  });
}
```

```bash
# Or use command line
flutter test --timeout=60s
```

### Flaky Tests

*Symptom:*
Tests pass sometimes, fail other times.

*Solution:*
```dart

await Future.delayed(Duration(milliseconds: 100));

await tester.pumpAndSettle();

```

### Mock Not Working

*Symptom:*
```
MissingStubError: 'fetchRecords'
No stub was found which matches the arguments of this method call
```

*Solution:*
```dart

class MockGristService extends Mock implements GristService {}

void main() {
  late MockGristService mockService;

  setUp(() {
    mockService = MockGristService();
  });

  test('test name', () async {
    // Setup mock BEFORE using it
    when(mockService.fetchRecords(any))
        .thenAnswer((_) async => []);

    // Now use it
    final result = await mockService.fetchRecords('Users');
    expect(result, isEmpty);
  });
}
```

## Dependency Issues

### Error: Incompatible Dart SDK

*Symptom:*
```
The current Dart SDK version is 3.0.0.
Because package requires SDK version >=3.1.0, version solving failed.
```

*Solution:*
```bash
# Update Flutter (includes Dart)
flutter upgrade

# Or install specific version
flutter downgrade

# Check version
flutter --version
```

### Error: Package Requires Higher Flutter Version

*Symptom:*
```
Because package requires Flutter SDK version >=3.10.0 and
Flutter SDK version is 3.0.0, version solving failed.
```

*Solution:*
```bash
# Update Flutter
flutter upgrade

# If you can't upgrade, use older package version
# Edit pubspec.yaml
dependencies:
  package_name: ^1.0.0  # Older version compatible with your Flutter
```

### Error: Platform Not Supported

*Symptom:*
```
Error: Unsupported operation: Platform._operatingSystem
```

*Solution:*
```dart

import 'dart:io' show Platform;

if (!kIsWeb && Platform.isLinux) {
  // Linux-specific code
}
```

## Docker Issues

### Docker Permission Denied

*Symptom:*
```
Got permission denied while trying to connect to the Docker daemon socket
```

*Solution:*
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login for changes to take effect
# Or run:
newgrp docker

# Test
docker ps
```

### Docker Out of Space

*Symptom:*
```
no space left on device
```

*Solution:*
```bash
# Clean up Docker
docker system prune -af

# Remove unused volumes
docker volume prune

# Check disk usage
docker system df

# If still low, clean old images
docker rmi $(docker images -f "dangling=true" -q)
```

### Container Won't Start

*Symptom:*
```
Error response from daemon: driver failed programming external
connectivity on endpoint
```

*Solution:*
```bash
# 1. Check if port is in use
netstat -tulpn | grep 8484

# 2. Stop conflicting service
docker stop grist_server

# 3. Restart Docker daemon
sudo systemctl restart docker

# 4. Try again
./docker-test.sh grist-start
```

### Docker Build Fails

*Symptom:*
```
ERROR [internal] load metadata for docker.io/library/ubuntu:20.04
```

*Solution:*
```bash
# 1. Check internet connection
ping google.com

# 2. Restart Docker daemon
sudo systemctl restart docker

# 3. Clear Docker cache
docker builder prune -af

# 4. Try building again
./docker-test.sh build --no-cache
```

## Grist Issues

### Cannot Connect to Grist

*Symptom:*
```
Exception: Failed to fetch records from Users: 000
```

*Solution:*
```bash
# 1. Check if Grist is running
curl http://localhost:8484

# 2. Check Grist logs
./docker-test.sh grist-logs

# 3. Restart Grist
./docker-test.sh grist-restart

# 4. Verify API key and document ID in config
```

### Authentication Fails

*Symptom:*
```
Authentication failed: Invalid credentials
```

*Solution:*
```bash
# 1. Verify password hash in Grist
# The password_hash field should contain bcrypt hash

# 2. Generate correct hash
./docker-test.sh shell
# Inside shell:
dart
import 'package:bcrypt/bcrypt.dart';
print(BCrypt.hashpw('password123', BCrypt.gensalt()));
# Copy hash to Grist

# 3. Ensure Users table schema matches config
# Check column names: email, password_hash, role, active
```

### API Returns 404

*Symptom:*
```
Failed to fetch records from Products: 404
```

*Solution:*
```bash
# 1. Verify table exists in Grist
# Open http://localhost:8484

# 2. Check table name spelling (case-sensitive)

# 3. Verify document ID is correct

# 4. Test API directly
curl -H "Authorization: Bearer YOUR_API_KEY" \
  http://localhost:8484/api/docs/DOC_ID/tables
```

### Slow Grist Response

*Symptom:*
Grist API calls take several seconds.

*Solution:*
```bash
# 1. Check Grist resource usage
docker stats grist_server

# 2. Increase Docker resources
# Edit docker-compose.yml:
services:
  grist:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2'

# 3. Restart Grist
./docker-test.sh grist-restart

# 4. Consider adding caching in your code
```

## Git Issues

### Merge Conflict

*Symptom:*
```
CONFLICT (content): Merge conflict in lib/src/utils/validators.dart
```

*Solution:*
```bash
# 1. View conflicted files
git status

# 2. Edit conflicted files
# Look for conflict markers:
# <<<<<<< HEAD
# Your changes
# =======
# Their changes
# >>>>>>> branch-name

# 3. Resolve conflicts manually
code lib/src/utils/validators.dart

# 4. Mark as resolved
git add lib/src/utils/validators.dart

# 5. Complete merge
git commit
```

### Cannot Push - Rejected

*Symptom:*
```
! [rejected]        main -> main (non-fast-forward)
```

*Solution:*
```bash
# Option 1: Pull and merge
git pull origin main
# Resolve any conflicts
git push

# Option 2: Rebase
git pull --rebase origin main
# Resolve any conflicts
git push

# Option 3: Force push (use with caution!)
# Only for feature branches
git push --force-with-lease origin feature-branch
```

### Accidentally Committed Large File

*Symptom:*
```
remote: error: File huge_file.bin is 100 MB; this exceeds
GitHub's file size limit of 100 MB
```

*Solution:*
```bash
# Remove from last commit
git rm --cached huge_file.bin
git commit --amend --no-edit
git push --force-with-lease

# Remove from history
git filter-branch --index-filter \
  'git rm --cached --ignore-unmatch huge_file.bin' HEAD

# Add to .gitignore
echo "huge_file.bin" >> .gitignore
git add .gitignore
git commit -m "Add file to gitignore"
```

### Detached HEAD State

*Symptom:*
```
You are in 'detached HEAD' state.
```

*Solution:*
```bash
# Create branch from current state
git checkout -b temp-branch

# Or return to main branch
git checkout main
```

## IDE Issues

### VS Code: Dart Extension Not Working

*Symptom:*
Dart files have no syntax highlighting, no autocomplete.

*Solution:*
```bash
# 1. Install Dart extension
code --install-extension Dart-Code.dart-code

# 2. Reload window
# Cmd+Shift+P (Mac) or Ctrl+Shift+P (Win/Linux)
# Type: "Reload Window"

# 3. Check Flutter SDK path in settings
# File → Preferences → Settings
# Search: "dart.flutterSdkPath"
# Set to your Flutter installation

# 4. Restart VS Code
```

### Android Studio: Flutter Plugin Issues

*Symptom:*
Flutter commands not available in Android Studio.

*Solution:*
```bash
# 1. Install Flutter plugin
# File → Settings → Plugins → Browse Repositories
# Search "Flutter" → Install

# 2. Restart Android Studio

# 3. Configure Flutter SDK path
# File → Settings → Languages & Frameworks → Flutter
# Set Flutter SDK path

# 4. Invalidate caches and restart
# File → Invalidate Caches / Restart
```

### Autocomplete Not Working

*Symptom:*
No code completion suggestions.

*Solution:*
```bash
# 1. Run pub get
flutter pub get

# 2. Restart Dart Analysis Server
# VS Code: Cmd+Shift+P → "Dart: Restart Analysis Server"
# Android Studio: File → Invalidate Caches

# 3. Check analysis_options.yaml for errors

# 4. Delete .dart_tool/ and retry
rm -rf .dart_tool/
flutter pub get
```

## Runtime Issues

### Provider Not Found

*Symptom:*
```
Error: Could not find the correct Provider<GristService> above this
Widget
```

*Solution:*
```dart

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<GristService>(create: (_) => GristService(...)),
      ],
      child: MyApp(),  // Provider must wrap widgets that use it
    ),
  );
}

final service = Provider.of<GristService>(context, listen: false);
```

### setState Called After Dispose

*Symptom:*
```
setState() called after dispose()
```

*Solution:*
```dart
class _MyPageState extends State<MyPage> {
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await fetchData();
    if (_mounted) {  // Check before setState
      setState(() {
        _data = data;
      });
    }
  }
}
```

### Memory Leak

*Symptom:*
App memory usage grows over time.

*Solution:*
```dart

class _MyPageState extends State<MyPage> {
  late TextEditingController _controller;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _subscription = stream.listen(...);
  }

  @override
  void dispose() {
    _controller.dispose();  // Dispose controller
    _subscription.cancel();  // Cancel subscription
    super.dispose();
  }
}
```

## Analysis Issues

### Analysis Server Crashes

*Symptom:*
```
The Dart analysis server has terminated.
```

*Solution:*
```bash
# 1. Restart analysis server
# VS Code: Cmd+Shift+P → "Dart: Restart Analysis Server"

# 2. Clear cache
rm -rf .dart_tool/
flutter clean
flutter pub get

# 3. Check for corrupted files
flutter analyze

# 4. If persists, report bug with logs from:
# ~/.dartServer/.analysis-driver/
```

### Linter Errors

*Symptom:*
Unexpected lint warnings or errors.

*Solution:*
```bash
# 1. Check analysis_options.yaml
# Ensure it matches project standards

# 2. Run analyzer
flutter analyze

# 3. Fix issues or suppress specific rules
# In analysis_options.yaml:
linter:
  rules:
    - rule_name: false  # Disable specific rule

# 4. Or use ignore comments in code

problematicCode();

```

## Performance Issues

### Slow Test Execution

*Symptom:*
Tests take several minutes to run.

*Solution:*
```bash
# 1. Run specific tests instead of all
flutter test test/utils/validators_test.dart

# 2. Use --concurrency flag
flutter test --concurrency=1  # Or higher number

# 3. Skip expensive tests in development
test('expensive test', () {
  // ...
}, skip: 'Slow test, run only in CI');

# 4. Profile tests
flutter test --reporter=json > test_results.json
# Analyze which tests are slow
```

### High Memory Usage During Build

*Symptom:*
Docker build uses too much memory.

*Solution:*
```bash
# 1. Increase Docker memory limit
# Docker Desktop → Settings → Resources → Memory

# 2. Clean up before building
flutter clean
docker system prune -af

# 3. Build with fewer resources
docker build --memory=2g --cpus=2 .

# 4. Use multi-stage builds to reduce image size
```

## Common Error Messages

[Table content - see original for details],
  (
    issue: "Version conflict",
    solution: "Update conflicting packages with `flutter pub upgrade`",
    priority: "high"
  ),
  (
    issue: "Docker permission denied",
    solution: "Add user to docker group: `sudo usermod -aG docker $USER`",
    priority: "high"
  ),
  (
    issue: "Grist connection failed",
    solution: "Ensure Grist is running: `./docker-test.sh grist-start`",
    priority: "high"
  ),
  (
    issue: "Provider not found",
    solution: "Ensure Provider is above widget in tree, use listen: false",
    priority: "high"
  ),
  (
    issue: "Tests timeout",
    solution: "Increase timeout with --timeout flag or Timeout() in test",
    priority: "medium"
  ),
  (
    issue: "Merge conflict",
    solution: "Manually resolve conflicts in files, then `git add` and commit",
    priority: "medium"
  ),
  (
    issue: "Analysis server crash",
    solution: "Restart analysis server and clear .dart_tool/ directory",
    priority: "medium"
  ),
  (
    issue: "setState after dispose",
    solution: "Check widget mounted state before calling setState()",
    priority: "low"
  ),
  (
    issue: "Slow tests",
    solution: "Run specific tests or use --concurrency flag",
    priority: "low"
  ),
))

## Getting More Help

If you can't find a solution here:

### 1. Check Logs

```bash
# Flutter logs
flutter analyze --verbose

# Docker logs
./docker-test.sh grist-logs
docker logs grist_server

# Git logs
git log --all --decorate --oneline --graph
```

### 2. Search Issues

```bash
# Search GitHub issues
gh issue list --search "error message"

# Or visit
# https://github.com/yourusername/flutterGristAPI/issues
```

### 3. Ask for Help

```bash
# Create new issue
gh issue create --title "Problem description"

# Or post in discussions
# https://github.com/yourusername/flutterGristAPI/discussions
```

### 4. Debug Yourself

```bash
# Enable verbose output
flutter analyze --verbose
flutter test --verbose

# Use debugger
# Add breakpoints in VS Code and press F5

# Print debugging
print('Debug: $variable');

# Use assert
assert(condition, 'Expected condition to be true');
```

### 5. External Resources

- *Flutter Issues*: https://github.com/flutter/flutter/issues
- *Dart Issues*: https://github.com/dart-lang/sdk/issues
- *Stack Overflow*: https://stackoverflow.com/questions/tagged/flutter
- *Flutter Discord*: https://discord.gg/flutter
- *Grist Support*: https://support.getgrist.com/

## Preventive Measures

Avoid common issues:

```bash
# Run tests before committing
./docker-test.sh all

# Keep dependencies updated
flutter pub outdated
flutter pub upgrade

# Clean build regularly
flutter clean

# Format code
flutter format lib/ test/

# Check analysis
flutter analyze

# Update Flutter
flutter upgrade
```

> **Success**: Most issues can be resolved by cleaning build artifacts, updating dependencies, and carefully reading error messages. Don't hesitate to ask for help if stuck!
