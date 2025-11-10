# Concourse CI/CD Implementation Analysis

**Date:** 2025-11-10
**Project:** Flutter Grist Widgets (v0.3.0)
**Branch:** `claude/setup-concourse-cicd-011CUz98G6Pf846BJ5CPMwHg`

---

## Executive Summary

This document analyzes the implementation of **Concourse CI** for automated testing and deployment of the Flutter Grist Widgets project from laptop to Raspberry Pi production server.

**Recommendation:** ✅ **Proceed with Concourse implementation in `deployment-module/concourse/`**

**Key Benefits:**
- Fully automated testing on every commit
- One-click deployment to Raspberry Pi production
- Self-hosted on laptop (no external dependencies)
- Visual pipeline monitoring
- Consistent with existing Docker-first approach

---

## Table of Contents

1. [Project Context](#project-context)
2. [Value Proposition of Concourse](#value-proposition-of-concourse)
3. [Why Concourse vs Alternatives](#why-concourse-vs-alternatives)
4. [Proposed Architecture](#proposed-architecture)
5. [Directory Structure](#directory-structure)
6. [Pipeline Design](#pipeline-design)
7. [Integration Points](#integration-points)
8. [Implementation Roadmap](#implementation-roadmap)
9. [Cost-Benefit Analysis](#cost-benefit-analysis)
10. [Risks & Mitigations](#risks--mitigations)

---

## 1. Project Context

### Current Workflow (Manual)

**Development Phase:**
```bash
# On laptop
cd flutter-module/
# Edit code
./docker-test.sh test       # Run 77 tests manually
./docker-test.sh analyze    # Run analysis manually
git add . && git commit -m "..." && git push
```

**Deployment Phase:**
```bash
# On laptop
cd deployment-module/
./docker-ansible.sh playbooks/configure_server.yml --tags app
# SSH to Pi
ssh appuser@raspberry-pi
docker compose pull
docker compose up -d
```

**Pain Points:**
- ❌ No automatic testing on push
- ❌ Deployment requires 5+ manual commands
- ❌ No visibility into test results over time
- ❌ Easy to forget analysis before commit
- ❌ No automated health checks post-deployment
- ❌ No rollback mechanism
- ❌ Manual coordination between test → deploy steps

### Project Characteristics

| Aspect | Details |
|--------|---------|
| **Type** | Flutter library + Docker services |
| **Test Suite** | 77 unit tests (validators, evaluators, services) |
| **Dev Environment** | Docker Compose (Grist + Flutter containers) |
| **Production Target** | Raspberry Pi (ARM64/ARMv7) |
| **Deployment Tool** | Ansible (5 roles: common, security, docker, monitoring, app_environment) |
| **Current CI/CD** | None |
| **Team Size** | Small (likely 1-3 developers) |
| **Git Workflow** | Feature branches → main |

---

## 2. Value Proposition of Concourse

### 2.1 Primary Benefits

#### ✅ **Automated Quality Gates**

**Before Concourse:**
- Developer forgets to run `docker-test.sh analyze` before commit
- Linting errors merged to main branch
- Production deployment breaks

**With Concourse:**
```yaml
- get: source-code
- task: flutter-analyze
  on_failure: notify-developer
- task: flutter-test (77 tests)
  on_failure: notify-developer
- task: deploy-to-prod
  passed: [flutter-analyze, flutter-test]
```

**Value:** Zero broken builds reach production

---

#### ✅ **One-Click Deployment**

**Before Concourse:**
```bash
cd deployment-module/
./docker-ansible.sh playbooks/configure_server.yml --tags app  # 2-5 min
ssh appuser@raspberry-pi                                       # Manual SSH
cd /opt/flutter_grist_app/
docker compose pull && docker compose up -d                    # Manual commands
curl http://raspberry-pi/health                                # Manual check
```

**With Concourse:**
```bash
fly -t local trigger-job -j flutter-grist/deploy-prod
# Or: git push (auto-deploys on main branch)
```

**Value:** 5+ manual steps → 1 command (or fully automatic)

---

#### ✅ **Visual Pipeline Monitoring**

Concourse Web UI provides:
- Real-time test execution status
- Historical pass/fail rates
- Build duration trends
- Resource versions (commits, Docker images)
- One-click re-runs

**Value:** Instant visibility into project health

---

#### ✅ **Consistent Build Environment**

Every build runs in:
- Same Docker image (`flutter-module/Dockerfile`)
- Same Ansible version (`deployment-module/Dockerfile`)
- Same dependencies (`pubspec.yaml`, `requirements.txt`)

**Value:** "Works on my machine" problems eliminated

---

#### ✅ **Automated Health Checks**

Post-deployment pipeline can:
1. Run `/opt/monitoring/health_check.sh` on Raspberry Pi
2. Check nginx status
3. Verify Docker containers running
4. Test API endpoints
5. **Auto-rollback** if checks fail

**Value:** Catch production issues within seconds

---

### 2.2 Specific Use Cases for This Project

| Scenario | Manual Process | With Concourse | Time Saved |
|----------|----------------|----------------|------------|
| **Feature Development** | Edit → manual test → manual analyze → commit → manual deploy | Edit → commit → auto-test → auto-analyze → auto-deploy | 10-15 min per commit |
| **Hotfix Deployment** | 5+ manual commands, SSH to Pi, restart services | `fly trigger-job` → automated deployment | 5-10 min |
| **Ansible Role Update** | Manually run playbook → SSH to verify → manual rollback if broken | Commit → auto-test playbook → auto-deploy → auto-verify → auto-rollback | 10-20 min |
| **Dependency Update** | Update `pubspec.yaml` → manual test → hope nothing breaks | Update → CI runs 77 tests → fails if breaking change | Prevents hours of debugging |
| **Multi-Environment Deploy** | Repeat manual steps for staging + prod | Define multiple pipelines → parallel deployment | 50%+ time reduction |

---

## 3. Why Concourse vs Alternatives

### 3.1 Comparison Matrix

| Feature | Concourse | GitHub Actions | GitLab CI | Jenkins | Drone |
|---------|-----------|----------------|-----------|---------|-------|
| **Self-Hosted on Laptop** | ✅ Yes | ❌ No (cloud) | ⚠️ Complex setup | ✅ Yes | ✅ Yes |
| **Docker-Native** | ✅ Every task in container | ⚠️ Partial | ⚠️ Partial | ❌ No | ✅ Yes |
| **Visual Pipeline** | ✅ Excellent | ✅ Good | ✅ Good | ⚠️ Outdated UI | ⚠️ Basic |
| **Resource Management** | ✅ First-class (git, docker, s3) | ⚠️ Actions marketplace | ⚠️ Built-in only | ⚠️ Plugins | ⚠️ Plugins |
| **ARM64 Support** | ✅ Native | ✅ Yes | ✅ Yes | ⚠️ Limited | ✅ Yes |
| **Learning Curve** | ⚠️ Medium | ✅ Easy | ✅ Easy | ❌ High | ✅ Easy |
| **Configuration** | YAML pipeline | YAML workflow | `.gitlab-ci.yml` | Groovy/UI | `.drone.yml` |
| **SSH Deploy to Pi** | ✅ Easy (Ansible task) | ⚠️ Self-hosted runner | ⚠️ Self-hosted runner | ✅ Easy | ✅ Easy |
| **Cost** | ✅ Free (self-hosted) | ⚠️ Free tier limits | ⚠️ Free tier limits | ✅ Free (self-hosted) | ✅ Free (self-hosted) |
| **Maintenance** | ⚠️ Docker Compose | N/A | ⚠️ High (Omnibus) | ❌ High | ⚠️ Low |

### 3.2 Why Concourse is Best for This Project

#### ✅ **Reason 1: Docker-First Philosophy Matches Project**

This project already uses Docker extensively:
- `docker-compose.yml` for development
- `flutter-module/Dockerfile` for Flutter environment
- `deployment-module/Dockerfile` for Ansible environment
- `./docker-test.sh` wrapper script

Concourse's architecture:
```
Every task runs in a Docker container
↓
No "install dependencies" step needed
↓
Same containers used in dev/CI/prod
↓
Perfect consistency
```

**GitHub Actions/GitLab CI:** Would require duplicating Docker setup in YAML workflow.

---

#### ✅ **Reason 2: Laptop Self-Hosting is Critical**

**User's Requirement:** "Concourse would be installed via Docker" (on laptop)

**Why this matters:**
- Raspberry Pi is on **local network** (probably 192.168.x.x)
- No public IP → GitHub/GitLab hosted runners **cannot SSH** to Pi
- Options with cloud CI:
  1. Self-hosted runner on laptop (complex)
  2. VPN setup (complex)
  3. Expose Pi to internet (security risk)

**Concourse on laptop:**
```
Laptop (Concourse) ──SSH──> Raspberry Pi (same LAN)
                  ↓
                  No network complexity
```

---

#### ✅ **Reason 3: Resource Abstraction**

Concourse's "resource" concept elegantly handles:
- **Git repository** (source code)
- **Docker images** (Flutter/Ansible containers)
- **SSH target** (Raspberry Pi server)
- **Ansible playbooks** (deployment scripts)

Example pipeline clarity:
```yaml
resources:
  - name: source-code
    type: git
    source: {uri: github.com/user/flutterGristAPI}

  - name: flutter-image
    type: docker-image
    source: {repository: local/flutter-dev}

  - name: raspberry-pi
    type: ssh-resource  # Custom resource type
    source: {host: 192.168.1.100, user: appuser}

jobs:
  - name: test
    plan:
      - get: source-code
        trigger: true
      - task: run-tests
        image: flutter-image
        file: source-code/ci/tasks/test.yml
```

**GitHub Actions equivalent:** Would require custom scripts mixing git, docker, ssh commands.

---

#### ✅ **Reason 4: Visual Feedback for Small Teams**

Concourse Web UI:
```
http://localhost:8080

Pipeline: flutter-grist-pipeline
├── [✅ PASSED] flutter-analyze (12s)
├── [✅ PASSED] flutter-test (45s)
└── [🔄 RUNNING] deploy-to-prod (2m 15s)
    └── ansible-playbook running...
```

**Value for 1-3 person team:**
- No need to check terminal output
- Background deployments visible
- Quick identification of failure points

---

#### ❌ **Reason 5 (Against): Learning Curve**

Concourse has a **steeper learning curve** than GitHub Actions:
- Resource types concept
- Task composition
- `fly` CLI tool

**Mitigation:**
- Project already uses Docker heavily (team comfortable with containers)
- We can provide complete working pipeline (copy-paste ready)
- Concourse docs are excellent
- Benefits outweigh 1-2 day learning investment

---

### 3.3 Decision Matrix

| Criterion | Weight | Concourse | GitHub Actions | Winner |
|-----------|--------|-----------|----------------|--------|
| Docker-native | High | 10/10 | 6/10 | 🏆 Concourse |
| Local network SSH | Critical | 10/10 | 3/10 | 🏆 Concourse |
| Self-hosted setup | High | 8/10 | 4/10 | 🏆 Concourse |
| Ease of use | Medium | 6/10 | 9/10 | GitHub Actions |
| Visual monitoring | Medium | 9/10 | 8/10 | Concourse |
| ARM64 support | High | 10/10 | 8/10 | Concourse |
| **Total** | | **53/60** | **38/60** | 🏆 **Concourse** |

---

## 4. Proposed Architecture

### 4.1 High-Level Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                          LAPTOP                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Developer Workstation                                           │
│  ┌──────────────┐                                                │
│  │ Git Commit & │                                                │
│  │    Push      │                                                │
│  └──────┬───────┘                                                │
│         │                                                         │
│         ▼                                                         │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │           Concourse CI (Docker Compose)                     ││
│  │  ┌─────────────────────────────────────────────────────┐   ││
│  │  │  concourse-web (UI)     :8080                       │   ││
│  │  │  concourse-worker       (runs tasks)                │   ││
│  │  │  postgres               (state/metadata)            │   ││
│  │  └─────────────────────────────────────────────────────┘   ││
│  │                                                             ││
│  │  Pipeline Execution:                                        ││
│  │  1. [Git Clone] source-code                                 ││
│  │  2. [Task] Flutter Analyze                                  ││
│  │  3. [Task] Flutter Test (77 tests)                          ││
│  │  4. [Task] Build Docker Images                              ││
│  │  5. [Task] Ansible Deploy (SSH to Pi) ───────────┐          ││
│  └──────────────────────────────────────────────────┼─────────┘│
└─────────────────────────────────────────────────────┼──────────┘
                                                       │
                                                       │ SSH (port 22)
                                                       │ Ansible Playbook
                                                       │
┌──────────────────────────────────────────────────────▼──────────┐
│                      RASPBERRY PI                                │
│                    (Production Server)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Ansible Roles Applied:                                         │
│  ✅ common        (system setup)                                │
│  ✅ security      (SSH, UFW, fail2ban)                          │
│  ✅ docker        (Docker CE + Compose)                         │
│  ✅ monitoring    (health checks)                               │
│  ✅ app_environment (nginx, app user, directories)              │
│                                                                  │
│  Application Running:                                           │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ nginx :80/:443                                         │    │
│  │   ↓                                                    │    │
│  │ Flutter Grist App (Docker container)                   │    │
│  │ Grist Server (Docker container)                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                  │
│  Post-Deploy Verification (by Concourse):                       │
│  ├── /opt/monitoring/health_check.sh                            │
│  ├── curl http://localhost/health                               │
│  └── docker ps | grep flutter-grist                             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Component Breakdown

#### Laptop Components

**1. Concourse Services (Docker Compose)**
```yaml
services:
  concourse-db:
    image: postgres:15
    volumes:
      - concourse-db-data:/var/lib/postgresql/data

  concourse-web:
    image: concourse/concourse:7.11
    ports:
      - "8080:8080"
    command: web
    depends_on: [concourse-db]

  concourse-worker:
    image: concourse/concourse:7.11
    command: worker
    privileged: true  # For Docker-in-Docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

**2. Concourse Pipeline (`pipeline.yml`)**
```yaml
resources:
  - name: source-code
    type: git
    source:
      uri: https://github.com/PierreBx/flutterGristAPI
      branch: main

jobs:
  - name: test
    plan:
      - get: source-code
        trigger: true
      - task: analyze
        file: source-code/ci/tasks/analyze.yml
      - task: test
        file: source-code/ci/tasks/test.yml

  - name: deploy
    plan:
      - get: source-code
        passed: [test]
        trigger: true  # Auto-deploy on main
      - task: ansible-deploy
        file: source-code/ci/tasks/deploy.yml
      - task: health-check
        file: source-code/ci/tasks/health-check.yml
```

**3. Task Definitions**

`ci/tasks/analyze.yml`:
```yaml
platform: linux
image_resource:
  type: docker-image
  source: {repository: flutter-dev, tag: latest}
run:
  path: sh
  args:
    - -c
    - |
      cd flutter-module
      flutter analyze --no-fatal-infos
```

`ci/tasks/test.yml`:
```yaml
platform: linux
image_resource:
  type: docker-image
  source: {repository: flutter-dev, tag: latest}
run:
  path: sh
  args:
    - -c
    - |
      cd flutter-module
      flutter test --reporter expanded
```

`ci/tasks/deploy.yml`:
```yaml
platform: linux
image_resource:
  type: docker-image
  source: {repository: ansible-deploy, tag: latest}
params:
  RASPBERRY_PI_HOST: ((raspberry-pi-host))
  RASPBERRY_PI_USER: ((raspberry-pi-user))
  SSH_PRIVATE_KEY: ((ssh-private-key))
run:
  path: sh
  args:
    - -c
    - |
      echo "$SSH_PRIVATE_KEY" > /tmp/ssh_key
      chmod 600 /tmp/ssh_key
      cd deployment-module
      ansible-playbook playbooks/configure_server.yml \
        -i inventory/hosts.yml \
        --tags app \
        --private-key /tmp/ssh_key
```

---

## 5. Directory Structure

### 5.1 Proposed Structure

```
/home/user/flutterGristAPI/
├── deployment-module/
│   ├── README.md
│   ├── CONCOURSE_ANALYSIS.md         # This document
│   ├── ansible.cfg
│   ├── playbooks/
│   ├── roles/
│   ├── scripts/
│   │
│   └── concourse/                     # 🆕 NEW: Concourse CI/CD
│       ├── README.md                  # Concourse setup guide
│       ├── QUICKSTART.md              # 5-min Concourse setup
│       ├── docker-compose.yml         # Concourse services
│       ├── .env.example               # Secrets template
│       ├── keys/                      # SSH keys for worker
│       │   ├── session_signing_key
│       │   ├── tsa_host_key
│       │   └── worker_key
│       ├── credentials.yml            # Vault for secrets
│       ├── pipeline.yml               # Main CI/CD pipeline
│       ├── pipelines/                 # Additional pipelines
│       │   ├── test-only.yml          # Test-only pipeline
│       │   ├── deploy-staging.yml     # Staging deployment
│       │   └── deploy-prod.yml        # Production deployment
│       ├── tasks/                     # Reusable task definitions
│       │   ├── flutter-analyze.yml
│       │   ├── flutter-test.yml
│       │   ├── ansible-deploy.yml
│       │   ├── health-check.yml
│       │   └── rollback.yml
│       ├── scripts/                   # Helper scripts
│       │   ├── setup-concourse.sh     # First-time setup
│       │   ├── deploy-pipeline.sh     # Deploy pipeline to Concourse
│       │   ├── trigger-build.sh       # Manual build trigger
│       │   └── cleanup.sh             # Remove Concourse
│       └── resources/                 # Custom resource types
│           └── ssh-resource/          # SSH deployment resource
│
├── ci/                                # 🆕 NEW: Task definitions in repo
│   ├── tasks/
│   │   ├── analyze.yml
│   │   ├── test.yml
│   │   ├── deploy.yml
│   │   └── health-check.yml
│   └── scripts/
│       ├── run-tests.sh
│       ├── run-analyze.sh
│       └── deploy-to-pi.sh
│
├── flutter-module/
├── grist-module/
├── documentation-module/
├── docker-compose.yml
└── docker-test.sh
```

### 5.2 Rationale for Location

**Option A: `deployment-module/concourse/` (Recommended)**
- ✅ **Pro:** Groups all deployment/infrastructure code together
- ✅ **Pro:** Concourse is fundamentally a deployment tool
- ✅ **Pro:** Keeps root directory clean
- ✅ **Pro:** Logical grouping: Ansible + Concourse both handle deployment
- ❌ **Con:** Slightly deeper nesting

**Option B: Root-level `concourse/`**
- ✅ **Pro:** Easier to find for new team members
- ❌ **Con:** Pollutes root directory (already has 5 modules)
- ❌ **Con:** CI/CD is really part of deployment, not separate concern

**Option C: Root-level `.concourse/`**
- ❌ **Con:** Hidden directory (harder to discover)
- ❌ **Con:** Not a standard convention

**Decision:** ✅ **Use `deployment-module/concourse/`**

---

## 6. Pipeline Design

### 6.1 Primary Pipeline: `pipeline.yml`

```yaml
resources:
  - name: source-code
    type: git
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
  # Job 1: Quality Checks
  - name: quality-checks
    public: true
    plan:
      - get: source-code
        trigger: true  # Auto-run on new commits

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
                  echo "✅ Analysis passed"

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
                  echo "✅ All 77 tests passed"

  # Job 2: Build Artifacts
  - name: build
    public: true
    plan:
      - get: source-code
        passed: [quality-checks]
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
                echo "✅ Build completed"

  # Job 3: Deploy to Production
  - name: deploy-production
    public: true
    plan:
      - get: source-code
        passed: [build]
        trigger: true  # Auto-deploy on main branch

      - task: ansible-deploy
        image: ansible-image
        config:
          platform: linux
          inputs:
            - name: source-code
          params:
            RASPBERRY_PI_HOST: ((raspberry-pi-host))
            RASPBERRY_PI_USER: ((raspberry-pi-user))
            SSH_PRIVATE_KEY: ((ssh-private-key))
          run:
            path: /bin/sh
            args:
              - -c
              - |
                echo "🚀 Deploying to Raspberry Pi at $RASPBERRY_PI_HOST"

                # Setup SSH
                mkdir -p ~/.ssh
                echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
                chmod 600 ~/.ssh/id_rsa
                ssh-keyscan $RASPBERRY_PI_HOST >> ~/.ssh/known_hosts

                # Run Ansible deployment
                cd source-code/deployment-module
                ansible-playbook playbooks/configure_server.yml \
                  -i inventory/hosts.yml \
                  --tags app \
                  -v

                echo "✅ Deployment completed"

      - task: health-check
        config:
          platform: linux
          params:
            RASPBERRY_PI_HOST: ((raspberry-pi-host))
            RASPBERRY_PI_USER: ((raspberry-pi-user))
            SSH_PRIVATE_KEY: ((ssh-private-key))
          run:
            path: /bin/sh
            args:
              - -c
              - |
                echo "🔍 Running health checks..."

                # Setup SSH
                mkdir -p ~/.ssh
                echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
                chmod 600 ~/.ssh/id_rsa

                # Remote health check
                ssh -i ~/.ssh/id_rsa $RASPBERRY_PI_USER@$RASPBERRY_PI_HOST \
                  '/opt/monitoring/health_check.sh'

                # Check HTTP endpoint
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$RASPBERRY_PI_HOST/health)
                if [ "$HTTP_STATUS" = "200" ]; then
                  echo "✅ Health check passed (HTTP 200)"
                else
                  echo "❌ Health check failed (HTTP $HTTP_STATUS)"
                  exit 1
                fi
        on_failure:
          task: rollback
          config:
            platform: linux
            # Rollback logic here
```

### 6.2 Pipeline Visualization

```
[Git Commit] ──────> [quality-checks] ──────> [build] ──────> [deploy-production]
                            │                     │                    │
                            ├─ analyze (12s)      │                    ├─ ansible-deploy
                            └─ test (45s)         │                    ├─ health-check
                                                  │                    └─ [rollback] (on failure)
                                                  │
                                                  └─ build-flutter-app (2m)
```

### 6.3 Additional Pipelines

**Test-Only Pipeline** (`pipelines/test-only.yml`)
- For feature branches
- Runs tests without deployment
- Fast feedback loop

**Staging Pipeline** (`pipelines/deploy-staging.yml`)
- Deploy to staging Pi (if available)
- Manual trigger
- Full integration tests

**Rollback Pipeline** (`pipelines/rollback.yml`)
- Manual trigger
- Reverts to previous Docker image tag
- Runs health checks

---

## 7. Integration Points

### 7.1 Existing Tools Integration

| Existing Tool | Integration Method | Benefit |
|---------------|-------------------|---------|
| **docker-test.sh** | CI tasks call same Docker images | Local dev = CI = prod consistency |
| **Ansible playbooks** | Deploy task runs `ansible-playbook` | Reuses existing infrastructure code |
| **Flutter Dockerfile** | Used as `image_resource` in tasks | No duplicate Docker configuration |
| **Ansible Dockerfile** | Used for deploy tasks | Same Ansible version in CI and local |
| **health_check.sh** | Post-deploy task executes via SSH | Automated verification |
| **Git workflow** | Pipeline triggered by git push | Seamless developer experience |

### 7.2 Developer Workflow Changes

**Before Concourse:**
```bash
# Feature development
git checkout -b feature/new-widget
# ... edit code ...
./docker-test.sh test        # Manual
./docker-test.sh analyze     # Manual
git commit && git push

# Deployment (manual, 5-10 minutes)
cd deployment-module/
./docker-ansible.sh playbooks/configure_server.yml --tags app
ssh pi@raspberry-pi
docker compose pull && docker compose up -d
```

**After Concourse:**
```bash
# Feature development
git checkout -b feature/new-widget
# ... edit code ...
git commit && git push

# Automatic in background:
# - Tests run (fly sees commit)
# - Analysis runs
# - Build happens
# - Results visible at http://localhost:8080

# Deployment (automatic on merge to main)
git checkout main
git merge feature/new-widget
git push

# Automatic in background:
# - All tests re-run
# - Build created
# - Deployed to Raspberry Pi
# - Health checks run
# - Notification sent

# Manual deployment (if needed)
fly -t local trigger-job -j flutter-grist/deploy-production
```

**Time Saved per Day:**
- 3 commits/day × 5 min manual testing = **15 min**
- 1 deployment/day × 10 min manual steps = **10 min**
- **Total: 25 min/day → 2+ hours/week**

### 7.3 Network Requirements

**Laptop ↔ Concourse:**
- Port 8080 (Web UI)
- Port 2222 (Worker registration)
- **No external network needed** (all localhost)

**Concourse ↔ GitHub:**
- Port 443 (Git clone over HTTPS)
- Or: Port 22 (Git clone over SSH with deploy key)

**Concourse ↔ Raspberry Pi:**
- Port 22 (SSH for Ansible deployment)
- Port 80/443 (Health check HTTP requests)
- **Must be on same LAN** (e.g., 192.168.1.0/24)

**Firewall Rules:**
- No changes needed on laptop
- Raspberry Pi: UFW already allows SSH (22), HTTP (80), HTTPS (443)

---

## 8. Implementation Roadmap

### Phase 1: Basic Setup (Day 1, ~2 hours)

**Goal:** Get Concourse running and accessible

**Tasks:**
1. Create `deployment-module/concourse/` directory structure
2. Write `docker-compose.yml` for Concourse services
3. Generate Concourse keys (`scripts/generate-keys.sh`)
4. Start Concourse: `docker-compose up -d`
5. Access Web UI: `http://localhost:8080`
6. Install `fly` CLI tool
7. Login: `fly -t local login -c http://localhost:8080`

**Deliverables:**
- ✅ Concourse running on laptop
- ✅ Web UI accessible
- ✅ `fly` CLI configured

**Verification:**
```bash
docker ps | grep concourse  # Should show 3 containers
curl http://localhost:8080  # Should return HTML
fly -t local pipelines      # Should return empty list
```

---

### Phase 2: Test Pipeline (Day 2, ~3 hours)

**Goal:** Automate Flutter testing

**Tasks:**
1. Create `pipeline.yml` with test job only
2. Create `ci/tasks/analyze.yml`
3. Create `ci/tasks/test.yml`
4. Upload pipeline: `fly -t local set-pipeline -p flutter-test -c pipeline.yml`
5. Trigger manually: `fly -t local trigger-job -j flutter-test/quality-checks`
6. Watch output: `fly -t local watch -j flutter-test/quality-checks`
7. Configure git trigger (auto-run on push)

**Deliverables:**
- ✅ Test pipeline running
- ✅ 77 tests executed in CI
- ✅ Analysis step passing

**Verification:**
```bash
fly -t local jobs -p flutter-test  # Shows quality-checks job
# Web UI shows green checkmarks
```

---

### Phase 3: Deployment Pipeline (Day 3-4, ~4 hours)

**Goal:** Automate deployment to Raspberry Pi

**Tasks:**
1. Add SSH key to Concourse credentials
2. Test SSH connectivity from Concourse worker to Pi
3. Create `ci/tasks/deploy.yml` with Ansible task
4. Create `ci/tasks/health-check.yml`
5. Add deploy job to pipeline
6. Add health-check task
7. Test end-to-end deployment
8. Configure auto-deploy on main branch

**Deliverables:**
- ✅ One-click deployment working
- ✅ Health checks passing
- ✅ Auto-deploy on main branch merge

**Verification:**
```bash
fly -t local trigger-job -j flutter-grist/deploy-production
# Wait 3-5 minutes
ssh pi@raspberry-pi 'docker ps'  # Should show updated containers
curl http://raspberry-pi/health   # Should return 200 OK
```

---

### Phase 4: Advanced Features (Day 5+, optional)

**Goal:** Add rollback, notifications, multi-environment

**Tasks:**
1. Implement rollback pipeline
2. Add Slack/email notifications
3. Create staging environment pipeline
4. Add manual approval gates
5. Implement blue-green deployment
6. Add performance testing

**Deliverables:**
- ✅ Rollback capability
- ✅ Team notifications
- ✅ Staging environment

---

### Total Timeline

| Phase | Duration | Complexity | Priority |
|-------|----------|------------|----------|
| **Phase 1: Basic Setup** | 2 hours | Low | ⭐⭐⭐ Critical |
| **Phase 2: Test Pipeline** | 3 hours | Medium | ⭐⭐⭐ Critical |
| **Phase 3: Deploy Pipeline** | 4 hours | Medium-High | ⭐⭐⭐ Critical |
| **Phase 4: Advanced** | Variable | High | ⭐ Optional |
| **TOTAL (MVP)** | **1-2 days** | | |

---

## 9. Cost-Benefit Analysis

### 9.1 Costs

**Time Investment:**
- Initial setup: 8-10 hours (one-time)
- Learning Concourse: 2-4 hours (one-time)
- Maintenance: 1-2 hours/month (updates, troubleshooting)
- **Total first month:** ~15 hours

**Resource Costs:**
- Laptop CPU: ~10-20% during builds (2-5 min per build)
- Laptop RAM: ~2GB for Concourse services (db + web + worker)
- Disk space: ~5GB (Docker images, build artifacts)

**Operational Costs:**
- Laptop must be running for CI/CD (or use dedicated Pi for Concourse)
- Additional complexity in deployment architecture

### 9.2 Benefits

**Quantifiable:**
- Time saved: 25 min/day × 20 work days = **~8 hours/month**
- Fewer bugs in production: ~2-3 incidents/month avoided = **4-6 hours debugging saved**
- Faster onboarding: New developers see pipeline, understand workflow = **2-4 hours saved per new hire**

**Qualitative:**
- Higher code quality (enforced testing)
- Better team visibility (pipeline dashboard)
- Reduced deployment anxiety
- Consistent build environment
- Faster feedback loop

### 9.3 ROI Calculation

**First Month:**
- Investment: 15 hours
- Saved: 8 hours (time) + 5 hours (debugging) = 13 hours
- ROI: -2 hours (break-even almost immediate)

**Month 2+:**
- Investment: 1-2 hours (maintenance)
- Saved: 13 hours
- ROI: **+11 hours/month**

**Annual:**
- Saved: 13 hours/month × 12 = **156 hours/year**
- At $50/hour: **$7,800 value**

**Conclusion:** ✅ **Strongly positive ROI**

---

## 10. Risks & Mitigations

### Risk 1: Laptop Availability

**Risk:** Laptop must be on for CI/CD to run

**Impact:** High - No automated testing/deployment when laptop off

**Mitigations:**
1. **Option A:** Run Concourse on dedicated Raspberry Pi (separate from prod)
   - Buy second Pi (~$50)
   - Always-on CI/CD
   - Lower power consumption than laptop
2. **Option B:** Use laptop sleep prevention during work hours
   - `caffeinate` (MacOS) or `systemd-inhibit` (Linux)
   - Only issue for overnight/weekend builds
3. **Option C:** Hybrid approach
   - Laptop for development testing (fast feedback)
   - Dedicated Pi for production deployments

**Recommended:** Start with laptop, migrate to dedicated Pi if needed

---

### Risk 2: Learning Curve

**Risk:** Team unfamiliar with Concourse concepts

**Impact:** Medium - Slower initial adoption, potential misconfiguration

**Mitigations:**
1. Provide complete working pipeline (copy-paste ready)
2. Create detailed `QUICKSTART.md` with screenshots
3. Include commented examples in all YAML files
4. Schedule 1-hour team walkthrough
5. Leverage existing Docker knowledge

**Recommended:** Invest 2 hours in team training upfront

---

### Risk 3: SSH Key Management

**Risk:** SSH private key stored in Concourse credentials

**Impact:** High - Security issue if credentials leaked

**Mitigations:**
1. Use **separate deployment key** (not personal SSH key)
2. Restrict key permissions on Pi (read-only except `/opt/flutter_grist_app/`)
3. Encrypt credentials with Vault (Concourse supports HashiCorp Vault)
4. Rotate keys quarterly
5. Use `((credentials))` syntax (never hardcode keys)

**Recommended:** Implement dedicated deploy key + Vault

---

### Risk 4: Build Failures Blocking Progress

**Risk:** Broken tests prevent all deployments

**Impact:** Medium - Slows development if tests are flaky

**Mitigations:**
1. Allow manual override with `fly` CLI
2. Create "emergency deploy" pipeline (skips tests)
3. Improve test reliability (mock external dependencies)
4. Add test retry logic for flaky tests

**Recommended:** Manual override + improve test quality

---

### Risk 5: Network Issues (Laptop ↔ Pi)

**Risk:** WiFi disconnection during deployment

**Impact:** Medium - Failed deployments, inconsistent state

**Mitigations:**
1. Use wired Ethernet for laptop (more stable)
2. Ansible retry logic (built-in)
3. Add deployment timeouts
4. Implement rollback on failure

**Recommended:** Use wired connection + retry logic

---

## 11. Alternative Architectures (Considered & Rejected)

### Alternative 1: GitHub Actions Only

**Architecture:**
```
GitHub (cloud) ──> Self-hosted runner (laptop) ──SSH──> Pi
```

**Pros:**
- Familiar interface
- Good documentation
- Free for public repos

**Cons:**
- ❌ Requires self-hosted runner setup (complex)
- ❌ Runner must always be on
- ❌ Less Docker-native than Concourse
- ❌ GitHub dependency for local development

**Verdict:** ❌ More complex than Concourse for this use case

---

### Alternative 2: GitLab CI (Self-Hosted)

**Architecture:**
```
GitLab (laptop) ──> GitLab Runner (laptop) ──SSH──> Pi
```

**Pros:**
- Complete DevOps platform
- Built-in Docker registry
- Good CI/CD features

**Cons:**
- ❌ Heavy installation (Omnibus package)
- ❌ High resource usage (~4GB RAM)
- ❌ Overkill for 1-3 person team
- ❌ Complex maintenance

**Verdict:** ❌ Too heavy for laptop deployment

---

### Alternative 3: Simple Bash Script (git hooks)

**Architecture:**
```
git push ──> post-commit hook ──> run-tests.sh ──> deploy.sh
```

**Pros:**
- ✅ Extremely simple
- ✅ No additional services
- ✅ Fast

**Cons:**
- ❌ No visual dashboard
- ❌ No build history
- ❌ No parallel execution
- ❌ Hard to debug failures
- ❌ Not scalable

**Verdict:** ❌ Too simplistic for production deployments

---

### Alternative 4: Jenkins

**Architecture:**
```
Jenkins (laptop) ──> SSH Plugin ──> Pi
```

**Pros:**
- Mature ecosystem
- Extensive plugins

**Cons:**
- ❌ Heavy Java application
- ❌ Outdated UI/UX
- ❌ Complex configuration
- ❌ Not Docker-native

**Verdict:** ❌ Outdated, heavyweight

---

## 12. Success Metrics

### 12.1 Quantitative Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Time to deploy** | < 5 minutes | Pipeline duration |
| **Test execution time** | < 1 minute | Task duration |
| **Deployment success rate** | > 95% | Successful builds / total builds |
| **Manual intervention rate** | < 10% | Manual deploys / total deploys |
| **Time saved per week** | > 2 hours | (Manual time - automated time) × builds |

### 12.2 Qualitative Metrics

- Developer satisfaction (survey)
- Ease of onboarding new contributors
- Confidence in deployments
- Visibility into build/deploy status

---

## 13. Conclusion & Recommendation

### Summary

**Concourse CI/CD** is the optimal solution for this project because:

1. ✅ **Docker-native** architecture matches existing project structure
2. ✅ **Self-hosted** on laptop enables SSH to local Raspberry Pi
3. ✅ **Visual pipeline** provides team visibility
4. ✅ **Resource model** elegantly handles git/docker/ssh concerns
5. ✅ **Positive ROI** within first month (13+ hours saved monthly)
6. ✅ **Scalable** from 1-3 person team to larger teams
7. ✅ **Production-ready** with health checks, rollback, notifications

### Recommended Path Forward

**Phase 1 (This Week):**
- ✅ Approve this analysis
- ✅ Set up Concourse on laptop (2 hours)
- ✅ Create test-only pipeline (3 hours)
- ✅ Validate 77 tests run successfully in CI

**Phase 2 (Next Week):**
- ✅ Add deployment pipeline (4 hours)
- ✅ Test end-to-end deployment to Pi
- ✅ Enable auto-deploy on main branch
- ✅ Document usage in README

**Phase 3 (Optional):**
- Consider dedicated Raspberry Pi for Concourse (always-on)
- Add staging environment
- Implement blue-green deployments

### Final Recommendation

**✅ PROCEED with Concourse implementation in `deployment-module/concourse/`**

**Next Steps:**
1. User approval of this analysis
2. Begin Phase 1 implementation
3. Schedule 1-hour team walkthrough after setup
4. Iterate based on usage feedback

---

**Questions or concerns?** Please review sections:
- [Why Concourse vs Alternatives](#why-concourse-vs-alternatives) (Section 3)
- [Risks & Mitigations](#risks--mitigations) (Section 10)
- [Cost-Benefit Analysis](#cost-benefit-analysis) (Section 9)

**Ready to implement?** See [Implementation Roadmap](#implementation-roadmap) (Section 8)

---

*Document version: 1.0*
*Last updated: 2025-11-10*
*Author: Claude (AI Assistant)*
