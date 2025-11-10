#import "../common/styles.typ": *

#apply_standard_styles()

#doc_header(
  "Flutter Developer Quickstart",
  subtitle: "Get Your Development Environment Ready",
  version: "0.3.0"
)

= Quick Start Guide

This guide will help you set up your Flutter development environment and make your first contribution to the FlutterGristAPI library.

== Prerequisites Check

Before starting, ensure you have:

```bash
# Check Flutter installation
flutter --version
# Expected: Flutter 3.0.0 or higher

# Check Dart
dart --version
# Expected: Dart 3.0.0 or higher

# Check Git
git --version

# Check Docker (required for Grist and testing)
docker --version
docker-compose --version
```

#info_box(type: "warning")[
  If any of these commands fail, install the missing tools before proceeding.
]

== Step 1: Install Required Tools

=== Install Flutter

==== Linux/macOS
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor

# Run Flutter doctor to install any missing dependencies
flutter doctor --android-licenses  # If developing for Android
```

==== Windows
```powershell
# Download from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify
flutter doctor
```

=== Install Docker

==== Linux
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose

# Add user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

==== macOS
```bash
# Download Docker Desktop from
# https://www.docker.com/products/docker-desktop
# Install and start Docker Desktop
```

==== Windows
```powershell
# Download Docker Desktop from
# https://www.docker.com/products/docker-desktop
# Install and start Docker Desktop
# Enable WSL2 backend if prompted
```

=== Install IDE

==== VS Code (Recommended)
```bash
# Download from https://code.visualstudio.com/

# Install extensions:
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

==== Android Studio
```bash
# Download from https://developer.android.com/studio
# Install Flutter and Dart plugins via:
# Preferences → Plugins → Browse Repositories
```

== Step 2: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/flutterGristAPI.git
cd flutterGristAPI

# Explore the structure
ls -la
# You should see:
# - flutter-module/   (Flutter library code)
# - grist-module/     (Grist database)
# - documentation-module/
# - deployment-module/
```

== Step 3: Set Up Flutter Module

```bash
# Navigate to Flutter module
cd flutter-module

# Get dependencies
flutter pub get

# Expected output:
# Running "flutter pub get" in flutter-module...
# Resolving dependencies...
# Got dependencies!
```

=== Verify Installation

```bash
# Check for any issues
flutter doctor -v

# Run analysis
flutter analyze

# Expected output:
# Analyzing flutter-module...
# No issues found!
```

== Step 4: Set Up Grist Development Environment

```bash
# Navigate to grist-module
cd ../grist-module

# Start Grist server
./docker-test.sh grist-start

# Expected output:
# ✓ Grist started at http://localhost:8484
```

=== Verify Grist is Running

```bash
# Open browser to http://localhost:8484
# You should see Grist interface

# Or check with curl
curl http://localhost:8484
```

== Step 5: Build Docker Test Environment

The project uses Docker for consistent testing:

```bash
# Still in grist-module directory
./docker-test.sh build

# This builds a Docker container with Flutter and all dependencies
# First build takes 5-10 minutes
```

== Step 6: Run Your First Tests

```bash
# Run code analysis
./docker-test.sh analyze

# Expected output:
# Running Code Analysis...
# ✓ Code Analysis passed

# Run unit tests
./docker-test.sh test

# Expected output:
# Running Unit Tests...
# All tests passed!
# 77 tests passed

# Run both
./docker-test.sh all
```

#info_box(type: "success")[
  If all tests pass, your environment is correctly set up!
]

== Step 7: Open Project in IDE

=== VS Code
```bash
# From project root
code .

# Or open flutter-module specifically
code flutter-module/
```

The project includes VS Code configuration in `.vscode/`:
- Recommended extensions
- Debug configurations
- Code snippets

=== Android Studio
```bash
# Open Android Studio
# File → Open → Select flutterGristAPI/flutter-module/
```

== Step 8: Explore the Codebase

=== Key Files to Review

```bash
# Main library export (see what's public)
cat flutter-module/lib/flutter_grist_widgets.dart

# Configuration models
cat flutter-module/lib/src/config/app_config.dart

# Main app widget
cat flutter-module/lib/src/grist_app.dart

# Grist API service
cat flutter-module/lib/src/services/grist_service.dart

# Authentication provider
cat flutter-module/lib/src/providers/auth_provider.dart
```

=== Directory Overview

```
flutter-module/lib/src/
├── config/          # YAML parsing and config models
├── models/          # Data models
├── pages/           # Page widgets (7 page types)
├── providers/       # State management
├── services/        # Grist API client
├── utils/           # Validators, evaluators, themes
└── widgets/         # Reusable UI components
```

== Step 9: Make Your First Change

Let's make a simple change to understand the workflow:

=== Create a Feature Branch

```bash
cd flutterGristAPI
git checkout -b feature/my-first-contribution
```

=== Make a Small Change

Example: Add a new validator type

```bash
# Edit the validators file
nano flutter-module/lib/src/utils/validators.dart

# Or open in your IDE
code flutter-module/lib/src/utils/validators.dart
```

Add a new validator (example):
```dart
String? _validateUrl(dynamic value) {
  if (value == null) return null;

  final stringValue = value.toString();
  final urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b',
  );

  if (!urlRegex.hasMatch(stringValue)) {
    return message ?? 'Invalid URL';
  }
  return null;
}
```

=== Write a Test

```bash
# Edit test file
nano flutter-module/test/utils/validators_test.dart
```

Add test:
```dart
test('url validator accepts valid URLs', () {
  final validator = FieldValidator(type: 'url');
  expect(validator.validate('https://example.com'), null);
  expect(validator.validate('http://test.org'), null);
  expect(validator.validate('invalid'), isNotNull);
});
```

=== Run Tests

```bash
# Navigate to grist-module
cd grist-module

# Run tests
./docker-test.sh test

# If test fails, fix it and run again
```

=== Run Analysis

```bash
# Check code quality
./docker-test.sh analyze

# Fix any issues reported
```

=== Commit Your Change

```bash
cd ..
git add flutter-module/lib/src/utils/validators.dart
git add flutter-module/test/utils/validators_test.dart
git commit -m "feat: add URL validator"
```

== Step 10: Interactive Development

For faster iteration, use the interactive shell:

```bash
cd grist-module

# Open interactive shell in Docker container
./docker-test.sh shell

# Now you're inside the container with Flutter
# You can run commands directly:
flutter test
flutter analyze
flutter pub get

# Run specific test file
flutter test test/utils/validators_test.dart

# Run with verbose output
flutter test --reporter expanded

# Exit shell
exit
```

== Common First-Time Issues

#troubleshooting_table((
  (
    issue: "Flutter not found",
    solution: "Add Flutter to PATH. Run `flutter doctor` to verify.",
    priority: "high"
  ),
  (
    issue: "Docker permission denied",
    solution: "Add user to docker group: `sudo usermod -aG docker $USER`, then logout/login.",
    priority: "high"
  ),
  (
    issue: "Port 8484 already in use",
    solution: "Stop existing Grist: `docker stop grist_server` or use different port.",
    priority: "medium"
  ),
  (
    issue: "flutter pub get fails",
    solution: "Check internet connection. Try `flutter pub cache repair`.",
    priority: "medium"
  ),
  (
    issue: "Tests fail on first run",
    solution: "Ensure Grist is running. Check docker-test.sh build completed successfully.",
    priority: "medium"
  ),
  (
    issue: "IDE doesn't recognize Flutter",
    solution: "Install Flutter/Dart plugins. Restart IDE. Run `flutter doctor`.",
    priority: "low"
  ),
))

== Useful Commands Reference

=== Flutter Commands

```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean

# Run analyzer
flutter analyze

# Run tests
flutter test

# Run specific test
flutter test test/utils/validators_test.dart

# Run with coverage
flutter test --coverage

# Format code
flutter format lib/ test/

# Show outdated packages
flutter pub outdated
```

=== Docker Test Commands

```bash
# From grist-module directory

# Start Grist
./docker-test.sh grist-start

# Stop Grist
./docker-test.sh grist-stop

# Restart Grist
./docker-test.sh grist-restart

# View Grist logs
./docker-test.sh grist-logs

# Build test container
./docker-test.sh build

# Run analysis
./docker-test.sh analyze

# Run tests
./docker-test.sh test

# Run both
./docker-test.sh all

# Open interactive shell
./docker-test.sh shell

# Stop all containers
./docker-test.sh stop-all
```

=== Git Commands

```bash
# Create feature branch
git checkout -b feature/my-feature

# Check status
git status

# View changes
git diff

# Stage changes
git add .

# Commit
git commit -m "feat: add new feature"

# Push to remote
git push origin feature/my-feature

# Pull latest changes
git pull origin main

# View commit history
git log --oneline
```

== Development Environment Tips

=== Terminal Setup

Keep multiple terminals open:

*Terminal 1* - Code directory
```bash
cd flutterGristAPI/flutter-module
# For editing and git commands
```

*Terminal 2* - Testing
```bash
cd flutterGristAPI/grist-module
# For running ./docker-test.sh commands
```

*Terminal 3* - Grist logs (optional)
```bash
cd flutterGristAPI/grist-module
./docker-test.sh grist-logs
# Watch Grist API calls in real-time
```

=== IDE Configuration

==== VS Code Settings

Create `.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "[dart]": {
    "editor.tabSize": 2,
    "editor.rulers": [80]
  }
}
```

==== Useful VS Code Shortcuts

- `Ctrl+Shift+P` - Command palette
- `F5` - Start debugging
- `Ctrl+.` - Quick fix
- `Alt+Shift+F` - Format document
- `Ctrl+Shift+I` - Organize imports

=== Hot Reload Workflow

When developing widgets:

```bash
# In one terminal, run example app with hot reload
cd flutter-module/example
flutter run

# Make changes to widgets
# Press 'r' to hot reload
# Press 'R' to hot restart
```

== Next Steps

Now that your environment is set up:

1. *Read architecture.typ* - Understand the codebase structure
2. *Review api-reference.typ* - Learn the public APIs
3. *Study extending.typ* - Learn how to add features
4. *Check GitHub issues* - Find a good first issue to work on
5. *Read existing tests* - Understand testing patterns
6. *Join discussions* - Participate in GitHub discussions

== Verification Checklist

Before starting development, verify:

```bash
# ✓ Flutter installed and working
flutter doctor

# ✓ Dependencies installed
cd flutter-module && flutter pub get

# ✓ Grist running
curl http://localhost:8484

# ✓ Docker tests working
cd ../grist-module && ./docker-test.sh all

# ✓ IDE configured with Flutter plugin

# ✓ Git configured
git config user.name
git config user.email

# ✓ Can create branch
git checkout -b test-branch && git checkout main
```

#info_box(type: "success")[
  All set! You're ready to start contributing to FlutterGristAPI. Check out the architecture documentation next to understand how everything fits together.
]

== Getting Help

If you encounter issues:

1. Check `troubleshooting.typ` for common problems
2. Search GitHub issues for similar problems
3. Ask in GitHub discussions
4. Review Flutter documentation: https://flutter.dev/docs
5. Check Docker troubleshooting: https://docs.docker.com/

== Additional Resources

- *Flutter DevTools*: https://flutter.dev/docs/development/tools/devtools
- *Dart Style Guide*: https://dart.dev/guides/language/effective-dart/style
- *Provider Documentation*: https://pub.dev/packages/provider
- *Testing Flutter Apps*: https://flutter.dev/docs/testing
- *Grist API Reference*: https://support.getgrist.com/api/
