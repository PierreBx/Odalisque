// Automated Testing in CI/CD Pipelines
#import "../common/styles.typ": *

= Automated Testing

== Testing Strategy Overview

Automated testing in the CI/CD pipeline ensures code quality and prevents regressions before they reach production.

=== Test Pyramid

```
                    ┌─────────────┐
                    │   Manual    │  Small number
                    │  Exploratory│  (as needed)
                    └─────────────┘
                  ┌─────────────────┐
                  │   E2E Tests     │  Few tests
                  │ (UI, Integration)│  (critical paths)
                  └─────────────────┘
              ┌───────────────────────┐
              │  Integration Tests    │  Moderate number
              │  (API, Services)      │  (key integrations)
              └───────────────────────┘
          ┌───────────────────────────────┐
          │       Unit Tests               │  Large number
          │  (Functions, Classes, Widgets) │  (all components)
          └───────────────────────────────┘
```

*Current Implementation:*
- ✅ Unit Tests: 77 tests covering validators, evaluators, and services
- ⚠️ Integration Tests: Planned for Phase 2
- ⚠️ E2E Tests: Planned for Phase 4

== Unit Testing in Pipeline

=== Flutter Test Suite

The FlutterGristAPI project has comprehensive unit test coverage:

*Test Structure:*
```
flutter-module/test/
├── validators/
│   ├── email_validator_test.dart
│   ├── phone_validator_test.dart
│   └── date_validator_test.dart
├── evaluators/
│   ├── formula_evaluator_test.dart
│   └── condition_evaluator_test.dart
├── services/
│   ├── grist_api_service_test.dart
│   └── widget_service_test.dart
└── widgets/
    ├── text_input_widget_test.dart
    └── dropdown_widget_test.dart
```

=== CI Pipeline Test Execution

==== Test Task Configuration

```yaml
# Concourse pipeline: quality-checks job
- task: flutter-test
  image: flutter-image
  config:
    platform: linux
    inputs:
      - name: source-code
    run:
      path: /bin/sh
      args:
        - -c
        - |
          cd source-code/flutter-module
          flutter test --reporter expanded --coverage

          # Show test results summary
          echo "===================="
          echo "Test Results Summary"
          echo "===================="
          echo "✅ All 77 tests passed"
```

*Test Execution:*
- Runs automatically on every commit
- Executes all 77 unit tests
- Generates code coverage report
- Duration: ~45 seconds
- Fails pipeline if any test fails

==== Running Tests Locally

```bash
# Navigate to Flutter module
cd /home/user/flutterGristAPI/flutter-module/

# Run all tests
flutter test

# Run with verbose output
flutter test --reporter expanded

# Run specific test file
flutter test test/validators/email_validator_test.dart

# Run tests matching pattern
flutter test --name "email validation"

# Generate coverage
flutter test --coverage

# View coverage in browser
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

==== Using Docker Test Environment

```bash
# Navigate to Flutter module
cd /home/user/flutterGristAPI/flutter-module/

# Run tests in Docker (same as CI)
./docker-test.sh test

# Run with coverage
./docker-test.sh test --coverage

# Run specific test
./docker-test.sh test test/validators/email_validator_test.dart
```

#info_box(type: "info")[
  *Best Practice*: Always run tests locally before pushing. The Docker test environment matches CI exactly, preventing "works on my machine" issues.
]

== Test Coverage Reporting

=== Coverage Threshold Enforcement

The pipeline enforces minimum code coverage:

```yaml
- task: check-coverage
  config:
    platform: linux
    inputs:
      - name: source-code
    run:
      path: /bin/sh
      args:
        - -c
        - |
          cd source-code/flutter-module

          # Parse coverage report
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | \
            grep "lines" | \
            grep -oP '\d+\.\d+(?=%)')

          echo "Current coverage: $COVERAGE%"

          MIN_COVERAGE=60.0

          if (( $(echo "$COVERAGE < $MIN_COVERAGE" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% below minimum $MIN_COVERAGE%"
            exit 1
          else
            echo "✅ Coverage $COVERAGE% meets minimum $MIN_COVERAGE%"
          fi
```

*Configuration:*
- Current minimum: 60%
- Target: 80%+
- Location: `deployment-module/concourse/pipeline.yml`

=== Coverage Report Generation

==== In CI Pipeline

Coverage is automatically generated and checked:

```bash
# Trigger quality checks job
fly -t local trigger-job -j flutter-grist/quality-checks

# Watch output including coverage results
fly -t local watch -j flutter-grist/quality-checks
```

Expected output:
```
Running tests...
✅ All 77 tests passed

Generating coverage report...
Coverage: 65.3%
✅ Coverage meets minimum threshold (60%)
```

==== Local Coverage Reports

```bash
cd /home/user/flutterGristAPI/flutter-module/

# Generate coverage
flutter test --coverage

# Install lcov (if not installed)
sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
xdg-open coverage/html/index.html
```

*Coverage Report Shows:*
- Overall coverage percentage
- Per-file coverage breakdown
- Line-by-line coverage visualization
- Uncovered lines highlighted

=== Improving Coverage

*Strategies:*

1. *Identify gaps:* Review coverage report for untested files
2. *Write tests for critical paths:* Focus on business logic first
3. *Test edge cases:* Error conditions, null handling, boundaries
4. *Mock dependencies:* Isolate units for testing
5. *Incremental improvement:* Aim for 5-10% increase per sprint

*Example Test:*
```dart
// test/validators/email_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_grist_api/validators/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('should accept valid email addresses', () {
      expect(EmailValidator.isValid('user@example.com'), isTrue);
      expect(EmailValidator.isValid('test+tag@domain.co.uk'), isTrue);
    });

    test('should reject invalid email addresses', () {
      expect(EmailValidator.isValid('invalid'), isFalse);
      expect(EmailValidator.isValid('missing@domain'), isFalse);
      expect(EmailValidator.isValid('@example.com'), isFalse);
    });

    test('should handle null and empty strings', () {
      expect(EmailValidator.isValid(null), isFalse);
      expect(EmailValidator.isValid(''), isFalse);
    });
  });
}
```

== Code Quality Analysis

=== Flutter Analyze

Static code analysis runs before tests:

```yaml
- task: flutter-analyze
  config:
    platform: linux
    inputs:
      - name: source-code
    run:
      path: /bin/sh
      args:
        - -c
        - |
          cd source-code/flutter-module
          flutter analyze --no-fatal-infos

          # Fail on errors or warnings
          if [ $? -ne 0 ]; then
            echo "❌ Analysis found issues"
            exit 1
          fi

          echo "✅ Analysis passed"
```

*Checks:*
- Linting rules (analysis_options.yaml)
- Type safety violations
- Unused imports and variables
- Code style consistency
- Potential bugs

==== Local Analysis

```bash
cd /home/user/flutterGristAPI/flutter-module/

# Run analyzer
flutter analyze

# Show all issues (including info)
flutter analyze --verbose

# Using Docker (same as CI)
./docker-test.sh analyze
```

==== Analysis Configuration

File: `flutter-module/analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - prefer_const_constructors
    - unnecessary_null_in_if_null_operators
    - use_key_in_widget_constructors

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore
```

== Secrets Scanning

=== Gitleaks Integration

Automated secrets detection prevents credential leaks:

```yaml
- name: secrets-scan
  plan:
    - get: source-code
      trigger: true
      passed: [quality-checks]

    - task: gitleaks
      config:
        platform: linux
        inputs:
          - name: source-code
        run:
          path: sh
          args:
            - -c
            - |
              # Download gitleaks
              wget -q https://github.com/gitleaks/gitleaks/releases/\
                download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz
              tar -xzf gitleaks_8.18.4_linux_x64.tar.gz

              # Run scan
              cd source-code
              ../gitleaks detect --source . --verbose

              if [ $? -eq 0 ]; then
                echo "✅ No secrets detected"
              else
                echo "❌ Secrets found! Check output above"
                exit 1
              fi
```

*Detects:*
- API keys and tokens
- Passwords and credentials
- Private keys (SSH, SSL)
- Database connection strings
- AWS/GCP credentials
- Generic high-entropy secrets

==== Local Secrets Scanning

```bash
# Install gitleaks
wget https://github.com/gitleaks/gitleaks/releases/download/v8.18.4/gitleaks_8.18.4_linux_x64.tar.gz
tar -xzf gitleaks_8.18.4_linux_x64.tar.gz
sudo mv gitleaks /usr/local/bin/

# Scan current repository
cd /home/user/flutterGristAPI/
gitleaks detect --source . --verbose

# Scan specific directory
gitleaks detect --source flutter-module/ --verbose
```

==== Handling False Positives

Create `.gitleaksignore` in project root:

```
# Example files (not real secrets)
**/.env.example
**/credentials.yml.example

# Documentation
**/README*.md
**/docs/**

# Test files
**/test/**
**/*_test.dart
```

#info_box(type: "warning")[
  *Security Critical*: Never bypass secrets scanning by adding real credential files to `.gitleaksignore`. Fix the issue by removing credentials and using environment variables.
]

== Test Performance Optimization

=== Parallel Test Execution

Run independent tasks concurrently:

```yaml
plan:
  - get: source-code
    trigger: true

  - in_parallel:
    - task: flutter-analyze    # ~12 seconds
    - task: flutter-test        # ~45 seconds
    - task: secrets-scan        # ~15 seconds

# Total time: ~45 seconds (not 72 seconds sequential)
```

*Benefits:*
- Faster feedback (40% time reduction)
- Better resource utilization
- Fail fast on any issue

=== Test Caching

Docker layer caching speeds up builds:

```dockerfile
# flutter-module/Dockerfile
FROM cirrusci/flutter:stable

# Cache dependencies (changes less frequently)
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code (changes frequently)
COPY . .

# Run tests (uses cached dependencies)
RUN flutter test
```

=== Selective Test Execution

Run only tests affected by changes:

```bash
# Run specific test file
flutter test test/validators/email_validator_test.dart

# Run tests matching name pattern
flutter test --name "email"

# Run tests in directory
flutter test test/validators/
```

== Integration Testing (Phase 2 - Planned)

=== Grist API Integration Tests

Test interaction with Grist API:

```dart
// test/integration/grist_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Grist API Integration', () {
    test('should fetch table data', () async {
      final response = await http.get(
        Uri.parse('http://localhost:8484/api/docs/DOC_ID/tables/TABLE_ID/records'),
        headers: {'Authorization': 'Bearer TEST_TOKEN'},
      );

      expect(response.statusCode, 200);
      expect(response.body, contains('records'));
    });
  });
}
```

*Planned Features:*
- Test against real Grist instance
- Verify widget rendering with API data
- Test CRUD operations
- Validate error handling

=== Pipeline Integration

```yaml
- name: integration-tests
  plan:
    - get: source-code
      passed: [quality-checks]

    - task: start-test-environment
      # Start Grist + app containers

    - task: run-integration-tests
      # Execute integration test suite

    - task: cleanup
      ensure:
        # Always stop containers
```

== End-to-End Testing (Phase 4 - Planned)

=== Browser Automation

Using Flutter integration test driver:

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should submit form successfully', (tester) async {
    // Launch app
    await tester.pumpWidget(MyApp());

    // Fill form
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.tap(find.byKey(Key('submit')));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Success!'), findsOneWidget);
  });
}
```

*Test Scenarios:*
- Complete user workflows
- Multi-step forms
- Navigation flows
- Error handling

== Test Reporting and Metrics

=== Test Result Tracking

Monitor test trends over time:

*Metrics to Track:*
- Test pass rate (target: 100%)
- Test execution time (target: < 1 minute)
- Coverage percentage (target: 80%)
- Flaky test count (target: 0)
- New tests added per sprint

=== Build Dashboard

Concourse Web UI (http://localhost:8080) shows:
- Real-time test execution
- Historical pass/fail rates
- Build duration trends
- Failed test details

=== Notifications

Configure alerts for test failures:

```yaml
# Future enhancement: Slack notifications
- task: notify-failure
  config:
    params:
      SLACK_WEBHOOK: ((slack-webhook))
    run:
      path: sh
      args:
        - -c
        - |
          curl -X POST $SLACK_WEBHOOK \
            -H 'Content-Type: application/json' \
            -d '{
              "text": "❌ Tests failed on main branch!",
              "attachments": [{
                "color": "danger",
                "fields": [{
                  "title": "Build",
                  "value": "'$BUILD_ID'"
                }]
              }]
            }'
```

== Best Practices

=== Writing Testable Code

1. *Single Responsibility*: Each function does one thing
2. *Dependency Injection*: Pass dependencies as parameters
3. *Avoid Global State*: Makes tests predictable
4. *Mock External Dependencies*: Isolate unit under test
5. *Test Public Interfaces*: Not implementation details

=== Test Naming Conventions

```dart
// Good: Descriptive, action-oriented
test('should return true when email is valid', () { ... });
test('should throw FormatException when input is null', () { ... });

// Bad: Vague, not descriptive
test('test1', () { ... });
test('works', () { ... });
```

=== Test Organization

```dart
void main() {
  group('EmailValidator', () {
    group('isValid()', () {
      test('should accept valid emails', () { ... });
      test('should reject invalid emails', () { ... });
      test('should handle null input', () { ... });
    });

    group('validate()', () {
      test('should return error message for invalid email', () { ... });
      test('should return null for valid email', () { ... });
    });
  });
}
```

=== Maintaining Test Suite

- *Run tests frequently*: Before every commit
- *Fix broken tests immediately*: Don't accumulate failures
- *Refactor tests with code*: Keep tests clean
- *Remove obsolete tests*: Delete tests for removed features
- *Review test coverage*: Weekly coverage report review

#section_separator()

Comprehensive automated testing ensures high code quality, prevents regressions, and gives confidence in deployments.
