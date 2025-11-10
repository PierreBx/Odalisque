# Command Reference

Quick reference for all commands you'll need during development.

## Docker Test Commands

All Docker commands should be run from the `grist-module/` directory.

[Command table - see original for details],
  (
    command: "./docker-test.sh grist-stop",
    description: "Stop Grist server",
    example: "./docker-test.sh grist-stop"
  ),
  (
    command: "./docker-test.sh grist-restart",
    description: "Restart Grist server",
    example: "./docker-test.sh grist-restart"
  ),
  (
    command: "./docker-test.sh grist-logs",
    description: "View Grist server logs (Ctrl+C to exit)",
    example: "./docker-test.sh grist-logs"
  ),
  (
    command: "./docker-test.sh build",
    description: "Build Flutter test Docker image",
    example: "./docker-test.sh build"
  ),
  (
    command: "./docker-test.sh analyze",
    description: "Run Flutter code analysis",
    example: "./docker-test.sh analyze"
  ),
  (
    command: "./docker-test.sh test",
    description: "Run all unit tests",
    example: "./docker-test.sh test"
  ),
  (
    command: "./docker-test.sh all",
    description: "Run analysis and tests",
    example: "./docker-test.sh all"
  ),
  (
    command: "./docker-test.sh shell",
    description: "Open interactive shell in container",
    example: "./docker-test.sh shell"
  ),
  (
    command: "./docker-test.sh stop-all",
    description: "Stop all containers",
    example: "./docker-test.sh stop-all"
  ),
))

## Flutter Commands

Run these from `flutter-module/` directory or inside Docker shell.

### Package Management

[Command table - see original for details],
  (
    command: "flutter pub upgrade",
    description: "Update all dependencies to latest versions",
    example: "flutter pub upgrade"
  ),
  (
    command: "flutter pub upgrade <package>",
    description: "Update specific package",
    example: "flutter pub upgrade provider"
  ),
  (
    command: "flutter pub outdated",
    description: "Show outdated dependencies",
    example: "flutter pub outdated"
  ),
  (
    command: "flutter pub cache repair",
    description: "Repair package cache",
    example: "flutter pub cache repair"
  ),
  (
    command: "flutter pub deps",
    description: "Show dependency tree",
    example: "flutter pub deps"
  ),
))

### Code Analysis

[Command table - see original for details],
  (
    command: "flutter analyze --verbose",
    description: "Run analysis with detailed output",
    example: "flutter analyze --verbose"
  ),
  (
    command: "flutter analyze lib/src/",
    description: "Analyze specific directory",
    example: "flutter analyze lib/src/"
  ),
  (
    command: "dart analyze",
    description: "Run Dart analyzer (alternative)",
    example: "dart analyze"
  ),
))

### Testing

[Command table - see original for details],
  (
    command: "flutter test <file>",
    description: "Run specific test file",
    example: "flutter test test/utils/validators_test.dart"
  ),
  (
    command: "flutter test --name=<pattern>",
    description: "Run tests matching name pattern",
    example: "flutter test --name=\"email validator\""
  ),
  (
    command: "flutter test --reporter expanded",
    description: "Run tests with verbose output",
    example: "flutter test --reporter expanded"
  ),
  (
    command: "flutter test --coverage",
    description: "Generate coverage report",
    example: "flutter test --coverage"
  ),
  (
    command: "flutter test --update-goldens",
    description: "Update golden test files",
    example: "flutter test --update-goldens"
  ),
  (
    command: "flutter test test/utils/",
    description: "Run all tests in directory",
    example: "flutter test test/utils/"
  ),
))

### Code Formatting

[Command table - see original for details],
  (
    command: "flutter format <file>",
    description: "Format specific file",
    example: "flutter format lib/src/utils/validators.dart"
  ),
  (
    command: "flutter format --set-exit-if-changed lib/",
    description: "Check if formatting needed (CI)",
    example: "flutter format --set-exit-if-changed lib/"
  ),
  (
    command: "dart format lib/ test/",
    description: "Alternative format command",
    example: "dart format lib/ test/"
  ),
))

### Build & Clean

[Command table - see original for details],
  (
    command: "flutter pub get",
    description: "Re-download dependencies after clean",
    example: "flutter pub get"
  ),
))

### Documentation

[Command table - see original for details],
  (
    command: "dart doc --output=docs",
    description: "Generate docs to specific directory",
    example: "dart doc --output=docs"
  ),
))

### System Information

[Command table - see original for details],
  (
    command: "flutter doctor -v",
    description: "Verbose system information",
    example: "flutter doctor -v"
  ),
  (
    command: "flutter --version",
    description: "Show Flutter version",
    example: "flutter --version"
  ),
  (
    command: "dart --version",
    description: "Show Dart version",
    example: "dart --version"
  ),
))

## Git Commands

### Basic Workflow

[Command table - see original for details],
  (
    command: "git diff",
    description: "Show unstaged changes",
    example: "git diff"
  ),
  (
    command: "git diff --staged",
    description: "Show staged changes",
    example: "git diff --staged"
  ),
  (
    command: "git add <files>",
    description: "Stage specific files",
    example: "git add lib/src/utils/validators.dart"
  ),
  (
    command: "git add .",
    description: "Stage all changes",
    example: "git add ."
  ),
  (
    command: "git commit -m \"message\"",
    description: "Commit staged changes",
    example: "git commit -m \"feat: add URL validator\""
  ),
  (
    command: "git commit -am \"message\"",
    description: "Stage and commit tracked files",
    example: "git commit -am \"fix: handle null in validator\""
  ),
  (
    command: "git push",
    description: "Push commits to remote",
    example: "git push"
  ),
  (
    command: "git push -u origin <branch>",
    description: "Push and set upstream branch",
    example: "git push -u origin feature/my-feature"
  ),
))

### Branching

[Command table - see original for details],
  (
    command: "git branch -a",
    description: "List all branches (including remote)",
    example: "git branch -a"
  ),
  (
    command: "git checkout -b <branch>",
    description: "Create and switch to new branch",
    example: "git checkout -b feature/url-validator"
  ),
  (
    command: "git checkout <branch>",
    description: "Switch to existing branch",
    example: "git checkout main"
  ),
  (
    command: "git branch -d <branch>",
    description: "Delete local branch",
    example: "git branch -d feature/old-feature"
  ),
  (
    command: "git push origin --delete <branch>",
    description: "Delete remote branch",
    example: "git push origin --delete feature/old-feature"
  ),
))

### History & Logs

[Command table - see original for details],
  (
    command: "git log --oneline",
    description: "Show compact commit history",
    example: "git log --oneline"
  ),
  (
    command: "git log --oneline --graph",
    description: "Show commit history with graph",
    example: "git log --oneline --graph --all"
  ),
  (
    command: "git log --since=\"2 weeks ago\"",
    description: "Show recent commits",
    example: "git log --since=\"2 weeks ago\""
  ),
  (
    command: "git show <commit>",
    description: "Show commit details",
    example: "git show abc123"
  ),
))

### Synchronizing

[Command table - see original for details],
  (
    command: "git pull origin main",
    description: "Pull from specific branch",
    example: "git pull origin main"
  ),
  (
    command: "git fetch",
    description: "Download remote changes",
    example: "git fetch"
  ),
  (
    command: "git merge <branch>",
    description: "Merge branch into current",
    example: "git merge main"
  ),
  (
    command: "git rebase <branch>",
    description: "Rebase current branch onto another",
    example: "git rebase main"
  ),
))

### Undoing Changes

[Command table - see original for details],
  (
    command: "git restore --staged <file>",
    description: "Unstage file",
    example: "git restore --staged lib/src/utils/validators.dart"
  ),
  (
    command: "git reset HEAD~1",
    description: "Undo last commit (keep changes)",
    example: "git reset HEAD~1"
  ),
  (
    command: "git reset --hard HEAD~1",
    description: "Undo last commit (discard changes)",
    example: "git reset --hard HEAD~1"
  ),
  (
    command: "git clean -fd",
    description: "Remove untracked files and directories",
    example: "git clean -fd"
  ),
))

### Stashing

[Command table - see original for details],
  (
    command: "git stash save \"message\"",
    description: "Stash with message",
    example: "git stash save \"WIP: validator changes\""
  ),
  (
    command: "git stash list",
    description: "List all stashes",
    example: "git stash list"
  ),
  (
    command: "git stash pop",
    description: "Apply and remove latest stash",
    example: "git stash pop"
  ),
  (
    command: "git stash apply",
    description: "Apply latest stash (keep it)",
    example: "git stash apply"
  ),
  (
    command: "git stash drop",
    description: "Remove latest stash",
    example: "git stash drop"
  ),
))

## Docker Commands

Basic Docker commands for troubleshooting.

[Command table - see original for details],
  (
    command: "docker ps -a",
    description: "List all containers",
    example: "docker ps -a"
  ),
  (
    command: "docker logs <container>",
    description: "View container logs",
    example: "docker logs grist_server"
  ),
  (
    command: "docker logs -f <container>",
    description: "Follow container logs",
    example: "docker logs -f grist_server"
  ),
  (
    command: "docker stop <container>",
    description: "Stop container",
    example: "docker stop grist_server"
  ),
  (
    command: "docker rm <container>",
    description: "Remove container",
    example: "docker rm grist_server"
  ),
  (
    command: "docker images",
    description: "List Docker images",
    example: "docker images"
  ),
  (
    command: "docker rmi <image>",
    description: "Remove Docker image",
    example: "docker rmi flutter_test"
  ),
  (
    command: "docker system prune",
    description: "Clean up unused resources",
    example: "docker system prune -f"
  ),
))

### Docker Compose

[Command table - see original for details],
  (
    command: "docker-compose down",
    description: "Stop and remove containers",
    example: "docker-compose down"
  ),
  (
    command: "docker-compose logs",
    description: "View logs from all services",
    example: "docker-compose logs"
  ),
  (
    command: "docker-compose ps",
    description: "List running services",
    example: "docker-compose ps"
  ),
  (
    command: "docker-compose restart <service>",
    description: "Restart specific service",
    example: "docker-compose restart grist"
  ),
))

## GitHub CLI Commands

Using GitHub CLI (`gh`) for pull requests and issues.

### Pull Requests

[Command table - see original for details],
  (
    command: "gh pr create --title \"Title\" --body \"Body\"",
    description: "Create PR with title and body",
    example: "gh pr create --title \"Add validator\" --body \"Adds URL validator\""
  ),
  (
    command: "gh pr list",
    description: "List pull requests",
    example: "gh pr list"
  ),
  (
    command: "gh pr view <number>",
    description: "View pull request details",
    example: "gh pr view 42"
  ),
  (
    command: "gh pr checkout <number>",
    description: "Checkout PR branch locally",
    example: "gh pr checkout 42"
  ),
  (
    command: "gh pr review <number>",
    description: "Review pull request",
    example: "gh pr review 42 --approve"
  ),
))

### Issues

[Command table - see original for details],
  (
    command: "gh issue create",
    description: "Create new issue",
    example: "gh issue create"
  ),
  (
    command: "gh issue view <number>",
    description: "View issue details",
    example: "gh issue view 123"
  ),
  (
    command: "gh issue close <number>",
    description: "Close issue",
    example: "gh issue close 123"
  ),
))

## Testing Commands

### Coverage Reports

```bash
# Generate coverage
flutter test --coverage

# Convert to HTML (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# View in browser
open coverage/html/index.html    # macOS
xdg-open coverage/html/index.html # Linux
start coverage/html/index.html   # Windows
```

### Watch Mode

```bash
# Run tests continuously on changes (in shell)
while true; do
  clear
  flutter test test/utils/validators_test.dart
  inotifywait -r -e modify lib/ test/
done
```

### Test Specific Files

```bash
# Test validators
flutter test test/utils/validators_test.dart

# Test services
flutter test test/services/

# Test widgets
flutter test test/widgets/

# Test specific test
flutter test --name="email validator accepts valid emails"
```

## Useful One-Liners

### Find Files

```bash
# Find all Dart files
find lib/ -name "*.dart"

# Count lines of code
find lib/ -name "*.dart" | xargs wc -l

# Find TODO comments
grep -r "TODO" lib/
```

### Git Shortcuts

```bash
# Show files changed in last commit
git diff-tree --no-commit-id --name-only -r HEAD

# Undo last commit message
git commit --amend -m "New message"

# Show blame for file
git blame lib/src/utils/validators.dart

# Show who changed line
git log -S "pattern" --source --all
```

### Docker Shortcuts

```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# See container IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' grist_server
```

## Command Aliases

Add these to `~/.bashrc` or `~/.zshrc` for productivity:

```bash
# Flutter aliases
alias ftest='flutter test'
alias fanalyze='flutter analyze'
alias fformat='flutter format lib/ test/'
alias fclean='flutter clean && flutter pub get'
alias fpubget='flutter pub get'
alias fpubup='flutter pub upgrade'

# Git aliases
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --all'
alias gp='git push'
alias gc='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpl='git pull'

# Docker test aliases
alias dt='cd ~/flutterGristAPI/grist-module && ./docker-test.sh test'
alias da='cd ~/flutterGristAPI/grist-module && ./docker-test.sh analyze'
alias dall='cd ~/flutterGristAPI/grist-module && ./docker-test.sh all'
alias dshell='cd ~/flutterGristAPI/grist-module && ./docker-test.sh shell'

# Shortcuts
alias grist='cd ~/flutterGristAPI/grist-module'
alias flutter-dev='cd ~/flutterGristAPI/flutter-module'
```

## Command Examples

### Complete Feature Development

```bash
# 1. Start environment
cd ~/flutterGristAPI/grist-module
./docker-test.sh grist-start

# 2. Create branch
cd ..
git checkout -b feature/url-validator

# 3. Edit code
cd flutter-module
code lib/src/utils/validators.dart

# 4. Write tests
code test/utils/validators_test.dart

# 5. Run tests
cd ../grist-module
./docker-test.sh test

# 6. Run analysis
./docker-test.sh analyze

# 7. Format code
cd ../flutter-module
flutter format lib/ test/

# 8. Commit
git add .
git commit -m "feat: add URL validator"

# 9. Push
git push -u origin feature/url-validator

# 10. Create PR
gh pr create
```

### Quick Test Iteration

```bash
# Open shell for faster iteration
cd grist-module
./docker-test.sh shell

# Inside shell
flutter test test/utils/validators_test.dart
# Edit code...
flutter test test/utils/validators_test.dart
# Repeat...

exit
```

### Update Dependencies

```bash
cd flutter-module

# Check outdated
flutter pub outdated

# Update all
flutter pub upgrade

# Run tests
cd ../grist-module
./docker-test.sh all

# If tests pass, commit
git add pubspec.lock
git commit -m "chore: update dependencies"
git push
```

> **Note**: Bookmark this page for quick reference to all commands you'll need during development!
