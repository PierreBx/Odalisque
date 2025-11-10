# Development Workflow

This guide covers the day-to-day development workflow for Flutter developers working on the FlutterGristAPI library.

## Daily Workflow Overview

```
1. Start Grist → 2. Pull Latest Changes → 3. Create Branch
           ↓
4. Write Code → 5. Write Tests → 6. Run Tests
           ↓
7. Run Analysis → 8. Commit → 9. Push → 10. Create PR
```

## Morning Setup

### Start Your Development Environment

```bash
# Terminal 1 - Main development
cd ~/flutterGristAPI/flutter-module

# Terminal 2 - Testing
cd ~/flutterGristAPI/grist-module

# Start Grist
./docker-test.sh grist-start

# Verify Grist is running
curl http://localhost:8484
```

### Pull Latest Changes

```bash
# Terminal 1
cd ~/flutterGristAPI
git checkout main
git pull origin main

# Update dependencies if needed
cd flutter-module
flutter pub get
```

### Check System Status

```bash
# Verify Flutter
flutter doctor

# Check what's changed
git log --oneline --graph --all -10

# Check for any issues
cd ../grist-module
./docker-test.sh analyze
```

## Feature Development Workflow

### 1. Create Feature Branch

```bash
cd ~/flutterGristAPI

# Create branch with descriptive name
git checkout -b feature/add-url-validator

# Or for bug fixes
git checkout -b fix/validator-null-handling

# Or for refactoring
git checkout -b refactor/extract-theme-utils
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code improvements
- `test/` - Test additions
- `docs/` - Documentation updates

### 2. Write Code

Edit files in `flutter-module/lib/src/`:

```bash
# Open in your editor
code flutter-module/lib/src/utils/validators.dart

# Or use your preferred editor
nano flutter-module/lib/src/utils/validators.dart
```

> **Note**: Follow the existing code style. The project uses `flutter format` for consistent formatting.

### 3. Write Tests

*IMPORTANT*: Write tests as you code, not after.

```bash
# Open test file
code flutter-module/test/utils/validators_test.dart
```

Test-driven development (TDD) approach:
```
1. Write a failing test
2. Write code to make it pass
3. Refactor
4. Repeat
```

Example test:
```dart
test('url validator accepts valid URLs', () {
  final validator = FieldValidator(
    type: 'url',
    message: 'Invalid URL',
  );

  // Valid URLs should pass
  expect(validator.validate('https://example.com'), null);
  expect(validator.validate('http://test.org'), null);

  // Invalid URLs should fail
  expect(validator.validate('not-a-url'), isNotNull);
  expect(validator.validate(''), isNotNull);
});
```

### 4. Run Tests Frequently

Run tests after each significant change:

```bash
# Terminal 2 (in grist-module)

# Run all tests
./docker-test.sh test

# Or for faster iteration, use shell
./docker-test.sh shell

# Inside shell, run specific test
flutter test test/utils/validators_test.dart

# Run with verbose output
flutter test --reporter expanded

# Watch mode (re-run on changes) - in shell
while true; do
  clear
  flutter test test/utils/validators_test.dart
  sleep 2
done
```

### 5. Run Code Analysis

Check for code quality issues:

```bash
# Run analyzer
./docker-test.sh analyze

# If issues found, fix them
# Then run again

# Format code
cd ../flutter-module
flutter format lib/ test/

# Check if formatting is needed
flutter format --set-exit-if-changed lib/ test/
```

### 6. Manual Testing (if needed)

For widget changes, test visually:

```bash
# If you have an example app
cd flutter-module/example
flutter run -d chrome  # Web
flutter run -d linux   # Desktop
flutter run            # Default device

# Make changes and use hot reload (press 'r')
```

### 7. Commit Your Changes

```bash
# Check what changed
git status
git diff

# Stage specific files
git add lib/src/utils/validators.dart
git add test/utils/validators_test.dart

# Or stage all changes
git add .

# Commit with descriptive message
git commit -m "feat: add URL validator with tests"
```

Commit message format:
```
<type>: <short description>

<optional longer description>

<optional footer>
```

Types:
- `feat:` - New feature
- `fix:` - Bug fix
- `test:` - Add/update tests
- `refactor:` - Code refactoring
- `docs:` - Documentation
- `style:` - Formatting
- `chore:` - Maintenance

Examples:
```bash
git commit -m "feat: add URL validator"
git commit -m "fix: handle null values in email validator"
git commit -m "test: add edge cases for range validator"
git commit -m "refactor: extract validation logic to helper"
git commit -m "docs: update validator documentation"
```

### 8. Push to Remote

```bash
# Push branch to remote
git push origin feature/add-url-validator

# If branch doesn't exist yet
git push -u origin feature/add-url-validator
```

### 9. Create Pull Request

```bash
# Option 1: Using GitHub CLI (if installed)
gh pr create --title "Add URL validator" --body "Implements URL validation for form fields"

# Option 2: Via GitHub web interface
# Go to GitHub repository
# Click "Pull requests" → "New pull request"
# Select your branch
# Fill in title and description
```

Pull request template:
```markdown
## Description
Brief description of changes

## Changes Made
- Added URL validator to validators.dart
- Added comprehensive tests
- Updated documentation

## Testing
- All existing tests pass
- New tests added for URL validation
- Tested manually with example app

## Checklist
- [x] Tests pass locally
- [x] Code follows style guidelines
- [x] Documentation updated
- [x] No breaking changes
```

## Testing Workflow

### Running Tests

```bash
# Run all tests
cd grist-module
./docker-test.sh test

# Run specific test file
./docker-test.sh shell
flutter test test/utils/validators_test.dart

# Run specific test by name
flutter test --name="email validator"

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Test Organization

```
test/
├── services/
│   └── grist_service_test.dart      # Service tests
├── utils/
│   ├── validators_test.dart         # Validator tests
│   └── expression_evaluator_test.dart
└── widgets/
    └── grist_table_widget_test.dart  # Widget tests
```

### Writing Good Tests

```dart

group('URL Validator', () {
  test('accepts valid HTTPS URLs', () {
    // Arrange
    final validator = FieldValidator(type: 'url');

    // Act
    final result = validator.validate('https://example.com');

    // Assert
    expect(result, null);
  });

  test('rejects invalid URLs', () {
    final validator = FieldValidator(type: 'url');
    expect(validator.validate('not-a-url'), isNotNull);
  });

  test('handles null values gracefully', () {
    final validator = FieldValidator(type: 'url');
    expect(validator.validate(null), null);
  });
});
```

### Test Coverage Goals

- *Overall coverage*: 70% minimum
- *New code*: 90% coverage for new features
- *Critical paths*: 100% coverage for validators, auth, API calls

```bash
# Check coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# Coverage should be in the summary output
```

## Code Review Workflow

### Before Requesting Review

Checklist:
```bash
# 1. All tests pass
./docker-test.sh test

# 2. Code analysis passes
./docker-test.sh analyze

# 3. Code is formatted
cd ../flutter-module
flutter format lib/ test/

# 4. Documentation is updated
# - Update CHANGELOG.md
# - Update README.md if needed
# - Add doc comments to public APIs

# 5. Commit messages are clear
git log --oneline origin/main..HEAD
```

### Requesting Review

```bash
# Push latest changes
git push origin feature/add-url-validator

# Create PR (if not already created)
gh pr create

# Request reviewers
gh pr edit --add-reviewer teammate1,teammate2

# Add labels
gh pr edit --add-label "enhancement"
```

### Responding to Feedback

```bash
# Pull latest from your branch
git pull origin feature/add-url-validator

# Make requested changes
# ... edit files ...

# Run tests
cd ../grist-module
./docker-test.sh all

# Commit changes
git add .
git commit -m "fix: address review feedback"

# Push updates
git push origin feature/add-url-validator

# Respond to comments on GitHub
```

### After Approval

```bash
# Merge PR (usually via GitHub web interface)
# Select "Squash and merge" for clean history

# After merge, clean up
git checkout main
git pull origin main
git branch -d feature/add-url-validator

# Delete remote branch
git push origin --delete feature/add-url-validator
```

## Bug Fix Workflow

### 1. Reproduce the Bug

```bash
# Create bug fix branch
git checkout -b fix/validator-crash-on-empty-string

# Write a test that demonstrates the bug
# This test should FAIL initially
```

Example:
```dart
test('validator does not crash on empty string', () {
  final validator = FieldValidator(type: 'email');
  // This should not throw
  expect(() => validator.validate(''), returnsNormally);
});
```

### 2. Fix the Bug

```bash
# Edit the code to fix the bug
nano lib/src/utils/validators.dart

# Run the test again - should PASS now
flutter test test/utils/validators_test.dart
```

### 3. Add Regression Tests

Add multiple tests to ensure the bug doesn't come back:

```dart
group('Email Validator Edge Cases', () {
  test('handles empty string', () { /* ... */ });
  test('handles whitespace only', () { /* ... */ });
  test('handles very long strings', () { /* ... */ });
  test('handles special characters', () { /* ... */ });
});
```

### 4. Commit and Push

```bash
git add .
git commit -m "fix: handle empty strings in email validator

- Add null check before regex matching
- Add regression tests for edge cases
- Fixes #123"

git push origin fix/validator-crash-on-empty-string
```

## Refactoring Workflow

### Safe Refactoring Steps

```
1. Ensure tests exist and pass
2. Make small, incremental changes
3. Run tests after each change
4. Commit frequently
5. Document why, not just what
```

Example refactoring workflow:

```bash
# 1. Create branch
git checkout -b refactor/extract-validator-helpers

# 2. Run tests (should all pass)
./docker-test.sh test

# 3. Extract method
# Before:
#   Inline validation logic in multiple places
# After:
#   Extracted to _validatePattern() helper

# 4. Run tests again (should still pass)
./docker-test.sh test

# 5. Commit
git commit -m "refactor: extract pattern validation to helper method"

# 6. Continue refactoring in small steps
# 7. Run tests after each step
# 8. Commit each successful step
```

### Refactoring Checklist

- [ ] All existing tests still pass
- [ ] No behavior changes (unless intentional)
- [ ] Code is more readable/maintainable
- [ ] No performance regressions
- [ ] Documentation updated

## Dependency Management

### Adding Dependencies

```bash
# Edit pubspec.yaml
cd flutter-module
nano pubspec.yaml

# Add dependency
# dependencies:
#   new_package: ^1.0.0

# Get dependencies
flutter pub get

# Verify tests still pass
cd ../grist-module
./docker-test.sh test
```

### Updating Dependencies

```bash
# Check for outdated packages
flutter pub outdated

# Update all dependencies
flutter pub upgrade

# Or update specific package
flutter pub upgrade http

# Run tests to ensure nothing broke
cd ../grist-module
./docker-test.sh all
```

> **Warning**: Always test after updating dependencies. Breaking changes in dependencies can cause issues.

### Security Updates

```bash
# Check for security vulnerabilities
flutter pub outdated --mode=null-safety

# Update vulnerable packages
flutter pub upgrade

# Rebuild Docker image with updated deps
cd ../grist-module
./docker-test.sh build
```

## Git Best Practices

### Branch Management

```bash
# Always work in feature branches
git checkout -b feature/my-feature

# Keep branches short-lived (< 1 week)
# Merge or rebase frequently

# Clean up merged branches
git branch -d feature/my-feature
git remote prune origin
```

### Commit Best Practices

```
# Commit frequently
# Each commit should be a logical unit of work
# Commit messages should be clear and descriptive

# Good commits:
git commit -m "feat: add email validation"
git commit -m "test: add email validator tests"
git commit -m "refactor: simplify validation logic"

# Bad commits:
git commit -m "WIP"
git commit -m "fixed stuff"
git commit -m "asdf"
```

### Rebasing

```bash
# Keep your branch up to date
git checkout feature/my-feature

# Option 1: Merge main into your branch
git merge main

# Option 2: Rebase onto main (cleaner history)
git rebase main

# Resolve conflicts if any
# Then continue
git rebase --continue

# Force push after rebase (be careful!)
git push --force-with-lease origin feature/my-feature
```

> **Warning**: Only force push to your own feature branches, never to main or shared branches.

## Continuous Integration

The project uses Concourse CI for automated testing:

```
On push to any branch:
1. Run flutter analyze
2. Run flutter test
3. Check formatting
4. Build documentation

On pull request:
1. All above checks
2. Check PR title format
3. Check for breaking changes

On merge to main:
1. All above checks
2. Build release artifacts
3. Publish documentation
4. Update changelog
```

### CI Troubleshooting

If CI fails:

```bash
# 1. Pull the changes that failed
git pull origin feature/my-feature

# 2. Run the same checks locally
cd grist-module
./docker-test.sh all

# 3. Fix issues
# 4. Push fixes
git push origin feature/my-feature

# CI will re-run automatically
```

## Performance Profiling

### When to Profile

Profile when:
- Adding data-heavy features
- Noticing slow performance
- Before releasing new version

```bash
# Run with profiling
flutter run --profile

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### Memory Leaks

```dart

@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

## Documentation

### API Documentation

Document all public APIs:

```dart

String? _validateEmail(dynamic value) {
  // Implementation
}
```

### Update Documentation Files

When adding features:
- Update `CHANGELOG.md`
- Update `README.md`
- Update relevant `.typ` documentation files
- Add examples if needed

## End of Day Routine

```bash
# 1. Commit any work in progress
git add .
git commit -m "WIP: working on URL validator"
git push origin feature/add-url-validator

# 2. Clean up
flutter clean

# 3. Stop services (optional)
cd grist-module
./docker-test.sh stop-all

# 4. Note any blockers or TODOs for tomorrow
```

## Weekly Maintenance

Once a week:

```bash
# Update dependencies
cd flutter-module
flutter pub upgrade

# Clean Docker
cd ../grist-module
docker system prune -f

# Review open PRs
gh pr list

# Update documentation
# Review and update any outdated docs
```

## Productivity Tips

### Shell Aliases

Add to `.bashrc` or `.zshrc`:

```bash
# Flutter shortcuts
alias ftest='flutter test'
alias fanalyze='flutter analyze'
alias fformat='flutter format lib/ test/'
alias fpubget='flutter pub get'

# Git shortcuts
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph'
alias gp='git push'

# Docker test shortcuts
alias dtest='cd ~/flutterGristAPI/grist-module && ./docker-test.sh test'
alias danalyze='cd ~/flutterGristAPI/grist-module && ./docker-test.sh analyze'
alias dall='cd ~/flutterGristAPI/grist-module && ./docker-test.sh all'
```

### Editor Snippets

Create code snippets for common patterns (VS Code example):

```json
{
  "Flutter Test": {
    "prefix": "ftest",
    "body": [
      "test('$1', () {",
      "  // Arrange",
      "  $2",
      "  ",
      "  // Act",
      "  $3",
      "  ",
      "  // Assert",
      "  expect($4, $5);",
      "});"
    ]
  }
}
```

### Watch Script

Auto-run tests on file changes:

```bash
#!/bin/bash
# watch-tests.sh
while inotifywait -r -e modify lib/ test/; do
  clear
  flutter test
done
```

## Summary

Key points for efficient development:

1. *Start with tests* - Write tests first or alongside code
2. *Commit frequently* - Small, logical commits
3. *Run tests often* - Catch issues early
4. *Keep branches short* - Merge frequently
5. *Review your own code* - Before requesting review
6. *Document as you go* - Don't leave it for later
7. *Use tools* - Leverage IDE features and scripts
8. *Stay organized* - Clean workspace, clear commits

> **Success**: Following this workflow will help you be productive and maintain high code quality in the FlutterGristAPI project.
