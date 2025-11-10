// CI/CD Pipeline Configuration and Management
#import "../common/styles.typ": *

= CI/CD Pipeline Configuration

== Concourse Architecture

Concourse CI is a container-based, scalable CI/CD system that treats pipelines as code.

=== Core Concepts

==== Resources
Resources represent external inputs and outputs for your pipeline:
- *git*: Source code repositories
- *docker-image*: Docker container images
- *time*: Triggers based on time intervals
- *s3*: Artifacts stored in S3-compatible storage

==== Jobs
Jobs are the building blocks of your pipeline. Each job consists of a plan with steps.

==== Tasks
Tasks are individual units of work executed in Docker containers. They:
- Run in isolation
- Have explicit inputs and outputs
- Are reproducible and cacheable

==== Pipelines
Pipelines orchestrate resources, jobs, and tasks into a complete CI/CD workflow.

=== FlutterGristAPI Pipeline Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    SOURCE CODE CHANGES                        │
│                   (Git Push to GitHub)                        │
└─────────────────────┬────────────────────────────────────────┘
                      │
                      ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB: quality-checks                                          │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: flutter-analyze                               │    │
│  │  - Check code style and quality                      │    │
│  │  - Enforce linting rules                             │    │
│  │  - Duration: ~12 seconds                             │    │
│  └──────────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: flutter-test                                  │    │
│  │  - Run 77 unit tests                                 │    │
│  │  - Generate coverage report                          │    │
│  │  - Duration: ~45 seconds                             │    │
│  └──────────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: check-coverage                                │    │
│  │  - Verify coverage >= 60%                            │    │
│  │  - Fail if below threshold                           │    │
│  │  - Duration: ~5 seconds                              │    │
│  └──────────────────────────────────────────────────────┘    │
└─────────────────────┬────────────────────────────────────────┘
                      │ PASSED
                      ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB: secrets-scan                                            │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: gitleaks                                      │    │
│  │  - Scan for hardcoded secrets                        │    │
│  │  - Check API keys, passwords, tokens                 │    │
│  │  - Duration: ~15 seconds                             │    │
│  └──────────────────────────────────────────────────────┘    │
└─────────────────────┬────────────────────────────────────────┘
                      │ PASSED
                      ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB: build                                                   │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: build-flutter-app                             │    │
│  │  - Compile Flutter web application                   │    │
│  │  - Create production artifacts                       │    │
│  │  - Duration: ~2 minutes                              │    │
│  └──────────────────────────────────────────────────────┘    │
└─────────────────────┬────────────────────────────────────────┘
                      │ PASSED (main branch only)
                      ▼
┌──────────────────────────────────────────────────────────────┐
│  JOB: deploy-production                                       │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: ansible-deploy                                │    │
│  │  - Connect to Raspberry Pi via SSH                   │    │
│  │  - Run Ansible playbooks                             │    │
│  │  - Deploy Docker containers                          │    │
│  │  - Duration: ~3-5 minutes                            │    │
│  └──────────────────────────────────────────────────────┘    │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: health-check                                  │    │
│  │  - Verify services are running                       │    │
│  │  - Test HTTP endpoints                               │    │
│  │  - Run system health scripts                         │    │
│  └──────────────────────────────────────────────────────┘    │
│             │ FAILED?                                         │
│             ▼                                                 │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  TASK: rollback (on_failure)                         │    │
│  │  - Revert to previous deployment                     │    │
│  │  - Restore Docker images                             │    │
│  │  - Notify team                                       │    │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

== Pipeline Configuration

=== Main Pipeline File

Location: `deployment-module/concourse/pipeline.yml`

```yaml
resources:
  - name: source-code
    type: git
    icon: github
    source:
      uri: https://github.com/PierreBx/flutterGristAPI.git
      branch: main
      private_key: ((github-private-key))

  - name: flutter-image
    type: docker-image
    source:
      repository: flutter-dev
      tag: latest

  - name: ansible-image
    type: docker-image
    source:
      repository: ansible-deploy
      tag: latest

jobs:
  - name: quality-checks
    public: true
    plan:
      - get: source-code
        trigger: true  # Auto-run on commits

      - in_parallel:
        - task: flutter-analyze
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
                  flutter analyze --no-fatal-infos

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
```

== Resource Types

=== Git Resource

Monitors a Git repository for changes and triggers builds:

```yaml
- name: source-code
  type: git
  source:
    uri: https://github.com/PierreBx/flutterGristAPI.git
    branch: main
    private_key: ((github-private-key))
    ignore_paths:  # Optional: ignore documentation changes
      - "*.md"
      - "docs/**"
```

*Parameters:*
- `uri`: Repository URL (HTTPS or SSH)
- `branch`: Branch to monitor (default: main)
- `private_key`: SSH key for private repositories
- `ignore_paths`: Don't trigger builds for these changes

=== Docker Image Resource

Tracks Docker images for use in tasks:

```yaml
- name: flutter-image
  type: docker-image
  source:
    repository: flutter-dev
    tag: latest
```

*Common Uses:*
- Build environment images (Flutter, Node.js, Python)
- Deployment tool images (Ansible, Terraform)
- Testing framework images

=== Time Resource

Trigger builds on a schedule:

```yaml
- name: nightly
  type: time
  source:
    interval: 24h
    start: 2:00 AM
    stop: 3:00 AM
    location: Europe/Paris
```

== Job Configuration

=== Quality Checks Job

This job ensures code quality before proceeding:

```yaml
- name: quality-checks
  public: true
  plan:
    - get: source-code
      trigger: true

    # Run tasks in parallel for speed
    - in_parallel:
      - task: flutter-analyze
        config: { ... }

      - task: flutter-test
        config: { ... }

      - task: check-coverage
        config: { ... }
```

*Key Features:*
- Runs automatically on every commit (`trigger: true`)
- Parallel execution saves time (~1 minute vs 2+ minutes sequential)
- Must pass before downstream jobs run

=== Secrets Scanning Job

Prevents accidental credential commits:

```yaml
- name: secrets-scan
  public: true
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
```

#info_box(type: "warning")[
  *Security Critical*: This job will fail the pipeline if secrets are detected. Never commit real credentials to version control.
]

=== Build Job

Compiles the application for deployment:

```yaml
- name: build
  public: true
  plan:
    - get: source-code
      passed: [quality-checks, secrets-scan]
      trigger: true

    - task: build-flutter-app
      image: flutter-image
      config:
        platform: linux
        inputs:
          - name: source-code
        outputs:
          - name: build-output
        run:
          path: /bin/sh
          args:
            - -c
            - |
              cd source-code/flutter-module
              flutter build web --release
              cp -r build/web ../build-output/
```

*Key Features:*
- Only runs after quality checks and secrets scan pass
- Produces build artifacts as outputs
- Uses optimized release mode

=== Deployment Job

Deploys to production:

```yaml
- name: deploy-production
  public: true
  plan:
    - get: source-code
      passed: [build]
      trigger: true  # Auto-deploy on main branch

    - task: ansible-deploy
      image: ansible-image
      params:
        RASPBERRY_PI_HOST: ((raspberry-pi-host))
        RASPBERRY_PI_USER: ((raspberry-pi-user))
        SSH_PRIVATE_KEY: ((ssh-private-key))
      config:
        platform: linux
        inputs:
          - name: source-code
        run:
          path: /bin/sh
          args:
            - -c
            - |
              # Setup SSH
              mkdir -p ~/.ssh
              echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
              chmod 600 ~/.ssh/id_rsa
              ssh-keyscan $RASPBERRY_PI_HOST >> ~/.ssh/known_hosts

              # Deploy with Ansible
              cd source-code/deployment-module
              ansible-playbook playbooks/configure_server.yml \
                -i inventory/hosts.yml \
                --tags app

    - task: health-check
      params:
        RASPBERRY_PI_HOST: ((raspberry-pi-host))
      config:
        platform: linux
        run:
          path: /bin/sh
          args:
            - -c
            - |
              HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
                http://$RASPBERRY_PI_HOST/health)

              if [ "$HTTP_STATUS" = "200" ]; then
                echo "✅ Health check passed"
                exit 0
              else
                echo "❌ Health check failed (HTTP $HTTP_STATUS)"
                exit 1
              fi

      on_failure:
        task: rollback
        config:
          # Rollback configuration here
```

== Task Definitions

=== External Task Files

For better organization, tasks can be defined in separate files:

```
deployment-module/concourse/tasks/
├── flutter-analyze.yml
├── flutter-test.yml
├── ansible-deploy.yml
└── health-check.yml
```

Referenced in pipeline:
```yaml
- task: flutter-analyze
  file: source-code/deployment-module/concourse/tasks/flutter-analyze.yml
```

=== Task Structure

```yaml
# tasks/flutter-analyze.yml
platform: linux

image_resource:
  type: docker-image
  source:
    repository: flutter-dev
    tag: latest

inputs:
  - name: source-code

run:
  path: /bin/sh
  args:
    - -c
    - |
      cd source-code/flutter-module
      flutter analyze --no-fatal-infos
```

== Credentials Management

=== Credentials File

Location: `deployment-module/concourse/credentials.yml`

```yaml
# GitHub Access
github-private-key: |
  -----BEGIN RSA PRIVATE KEY-----
  (SSH private key content)
  -----END RSA PRIVATE KEY-----

# Raspberry Pi Access
raspberry-pi-host: "192.168.1.100"
raspberry-pi-user: "appuser"
ssh-private-key: |
  -----BEGIN RSA PRIVATE KEY-----
  (SSH private key content)
  -----END RSA PRIVATE KEY-----

# Optional: Notification credentials
slack-webhook: "https://hooks.slack.com/services/XXX/YYY/ZZZ"
email-smtp-server: "smtp.gmail.com:587"
email-username: "ci@example.com"
email-password: "app-specific-password"
```

=== Using Credentials in Pipeline

Reference credentials with `((variable-name))` syntax:

```yaml
params:
  RASPBERRY_PI_HOST: ((raspberry-pi-host))
  SSH_PRIVATE_KEY: ((ssh-private-key))
```

=== Setting Credentials

```bash
# Method 1: Load from file
fly -t local set-pipeline \
  -p flutter-grist \
  -c pipeline.yml \
  -l credentials.yml

# Method 2: Interactive
fly -t local set-pipeline \
  -p flutter-grist \
  -c pipeline.yml \
  -v raspberry-pi-host=192.168.1.100

# Method 3: Environment variables
export RASPBERRY_PI_HOST=192.168.1.100
fly -t local set-pipeline \
  -p flutter-grist \
  -c pipeline.yml
```

#info_box(type: "danger")[
  *Never commit credentials.yml to version control!* Always keep it in `.gitignore`.
]

== Pipeline Management

=== Deploying Pipelines

```bash
# Set a new pipeline
fly -t local set-pipeline -p NAME -c pipeline.yml

# Update existing pipeline
fly -t local set-pipeline -p NAME -c pipeline.yml

# Unpause (enable) a pipeline
fly -t local unpause-pipeline -p NAME

# Pause (disable) a pipeline
fly -t local pause-pipeline -p NAME
```

=== Managing Jobs

```bash
# Trigger a job manually
fly -t local trigger-job -j PIPELINE/JOB

# Watch job execution
fly -t local watch -j PIPELINE/JOB

# View job history
fly -t local builds -j PIPELINE/JOB

# Abort a running build
fly -t local abort-build -j PIPELINE/JOB -b BUILD_NUMBER
```

=== Pipeline Inspection

```bash
# List all pipelines
fly -t local pipelines

# Get pipeline configuration
fly -t local get-pipeline -p NAME

# View jobs in pipeline
fly -t local jobs -p NAME

# Check resource versions
fly -t local resources -p NAME
```

== Advanced Features

=== Parallel Execution

Run multiple tasks simultaneously:

```yaml
plan:
  - get: source-code
  - in_parallel:
    - task: unit-tests
    - task: integration-tests
    - task: linting
    - task: security-scan
```

=== Serial Groups

Ensure jobs don't run concurrently:

```yaml
jobs:
  - name: deploy-staging
    serial: true
    serial_groups: [deployment]

  - name: deploy-production
    serial: true
    serial_groups: [deployment]
```

=== Try Steps

Continue even if a step fails:

```yaml
plan:
  - get: source-code
  - try:
      task: flaky-test
  - task: always-runs
```

=== Conditional Execution

```yaml
plan:
  - get: source-code
  - task: test
    on_success:
      task: notify-success
    on_failure:
      task: notify-failure
    ensure:
      task: cleanup  # Always runs
```

== Monitoring and Debugging

=== Web UI

Access at http://localhost:8080

*Features:*
- Real-time build status
- Build history and logs
- Resource versions
- Pipeline visualization
- Manual job triggers

=== Build Logs

```bash
# Follow build output
fly -t local watch -j PIPELINE/JOB

# Download logs for offline viewing
fly -t local watch -j PIPELINE/JOB > build.log
```

=== Resource Checking

```bash
# Force check for new versions
fly -t local check-resource -r PIPELINE/RESOURCE

# List resource versions
fly -t local resource-versions -r PIPELINE/RESOURCE
```

=== Pipeline Validation

```bash
# Validate pipeline syntax before deploying
fly validate-pipeline -c pipeline.yml
```

== Performance Optimization

=== Caching Dependencies

Use Docker layer caching:

```dockerfile
# In your Flutter Dockerfile
FROM cirrusci/flutter:stable

# Copy pubspec first (changes less frequently)
COPY pubspec.* /app/
WORKDIR /app
RUN flutter pub get

# Then copy source code (changes frequently)
COPY . /app/
```

=== Artifact Reuse

Pass build outputs between jobs:

```yaml
- task: build
  outputs:
    - name: artifacts

- task: deploy
  inputs:
    - name: artifacts  # Reuse from previous task
```

=== Resource Version Pinning

Pin specific versions for reproducibility:

```yaml
- get: source-code
  version: {ref: abc123def}  # Specific commit
```

#section_separator()

This comprehensive pipeline ensures code quality, security, and reliable deployments to your Raspberry Pi production environment.
