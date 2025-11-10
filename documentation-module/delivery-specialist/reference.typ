// Complete Reference for CI/CD Operations
#import "../common/styles.typ": *

= Complete Reference

== Project Structure

=== Repository Layout

```
/home/user/flutterGristAPI/
├── deployment-module/           # Deployment automation
│   ├── ansible.cfg             # Ansible configuration
│   ├── inventory/              # Server inventory
│   │   ├── hosts.yml           # Production servers
│   │   └── hosts.example       # Example configuration
│   ├── playbooks/              # Ansible playbooks
│   │   └── configure_server.yml # Main server setup
│   ├── roles/                  # Ansible roles
│   │   ├── common/             # Base system config
│   │   ├── security/           # Security hardening
│   │   ├── docker/             # Docker installation
│   │   ├── monitoring/         # Monitoring tools
│   │   ├── backup/             # Backup automation
│   │   ├── ssl/                # SSL/TLS setup
│   │   └── app_environment/    # Application setup
│   ├── concourse/              # CI/CD configuration
│   │   ├── docker-compose.yml  # Concourse services
│   │   ├── pipeline.yml        # Main CI/CD pipeline
│   │   ├── credentials.yml     # Secrets (not in Git)
│   │   ├── keys/               # SSH keys for Concourse
│   │   ├── tasks/              # Reusable task definitions
│   │   └── scripts/            # Helper scripts
│   ├── docker-ansible.sh       # Ansible Docker wrapper
│   ├── Dockerfile              # Ansible container image
│   └── README.md               # Deployment documentation
│
├── flutter-module/             # Flutter application code
│   ├── lib/                    # Application source
│   ├── test/                   # Unit tests
│   ├── pubspec.yaml            # Dependencies
│   ├── analysis_options.yaml   # Linting rules
│   ├── Dockerfile              # Flutter dev environment
│   └── docker-test.sh          # Test runner
│
├── grist-module/               # Grist integration
├── documentation-module/        # Project documentation
│   ├── delivery-specialist/    # CI/CD documentation
│   ├── flutter-developer/      # Developer docs
│   └── common/                 # Shared styles
│
└── docker-compose.yml          # Development environment
```

== Configuration Files

=== Concourse Pipeline Configuration

*File:* `deployment-module/concourse/pipeline.yml`

*Purpose:* Defines CI/CD pipeline with jobs, tasks, and resources

*Key Sections:*

```yaml
resources:
  - name: source-code          # Git repository
    type: git
    source:
      uri: REPOSITORY_URL
      branch: main
      private_key: ((github-private-key))

jobs:
  - name: quality-checks       # Test and analysis
    plan:
      - get: source-code
        trigger: true
      - task: flutter-analyze
      - task: flutter-test

  - name: deploy-production    # Deployment
    plan:
      - get: source-code
        passed: [quality-checks]
      - task: ansible-deploy
      - task: health-check
```

*Key Variables:*
- `((github-private-key))`: SSH key for Git repository
- `((raspberry-pi-host))`: Production server IP
- `((ssh-private-key))`: SSH key for deployment

=== Ansible Inventory

*File:* `deployment-module/inventory/hosts.yml`

*Purpose:* Defines target servers and configuration variables

*Structure:*

```yaml
all:
  children:
    production:
      hosts:
        raspberry_pi:
          ansible_host: 192.168.1.100
          ansible_user: pi
          ansible_port: 22
          ansible_python_interpreter: /usr/bin/python3
      vars:
        # System Configuration
        server_timezone: "Europe/Paris"
        server_locale: "en_US.UTF-8"

        # SSH Configuration
        ssh_port: 22
        ssh_permit_root_login: "no"
        ssh_password_authentication: "no"

        # Application Configuration
        app_name: "flutter_grist_app"
        app_user: "appuser"
        app_home: "/opt/flutter_grist_app"
        deployment_env: "production"

        # SSL Configuration (optional)
        domain_name: "your-domain.com"
        admin_email: "admin@example.com"

        # Backup Configuration
        backup_base_dir: "/opt/backups"
        backup_retention_daily: 7
        backup_retention_weekly: 28
        backup_retention_monthly: 90
```

*Common Variables:*

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*Variable*], [*Description*], [*Default*],

  [`ansible_host`], [Target server IP address], [Required],
  [`ansible_user`], [SSH user for connection], [`pi`],
  [`ansible_port`], [SSH port], [22],
  [`server_timezone`], [System timezone], [`UTC`],
  [`app_name`], [Application name], [`flutter_grist_app`],
  [`app_user`], [Application system user], [`appuser`],
  [`app_home`], [Application directory], [`/opt/flutter_grist_app`],
  [`domain_name`], [Domain for SSL certificate], [None],
  [`backup_retention_daily`], [Days to keep daily backups], [7],
)

=== Ansible Configuration

*File:* `deployment-module/ansible.cfg`

*Purpose:* Configures Ansible behavior

*Key Settings:*

```ini
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
log_path = ./ansible.log
stdout_callback = yaml

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
```

=== Docker Compose (Concourse)

*File:* `deployment-module/concourse/docker-compose.yml`

*Purpose:* Defines Concourse CI services

*Services:*

```yaml
services:
  concourse-db:
    image: postgres:15
    environment:
      POSTGRES_DB: concourse
      POSTGRES_USER: concourse_user
      POSTGRES_PASSWORD: concourse_pass
    volumes:
      - concourse-db-data:/var/lib/postgresql/data

  concourse-web:
    image: concourse/concourse:7.11
    command: web
    ports:
      - "8080:8080"
    environment:
      CONCOURSE_POSTGRES_HOST: concourse-db
      CONCOURSE_POSTGRES_DATABASE: concourse
      CONCOURSE_POSTGRES_USER: concourse_user
      CONCOURSE_POSTGRES_PASSWORD: concourse_pass
      CONCOURSE_EXTERNAL_URL: http://localhost:8080
      CONCOURSE_ADD_LOCAL_USER: test:test
      CONCOURSE_MAIN_TEAM_LOCAL_USER: test

  concourse-worker:
    image: concourse/concourse:7.11
    command: worker
    privileged: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
```

=== Flutter Configuration

*File:* `flutter-module/pubspec.yaml`

*Purpose:* Defines Flutter dependencies and metadata

*Key Sections:*

```yaml
name: flutter_grist_api
description: Flutter widgets for Grist integration
version: 0.3.0

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

*File:* `flutter-module/analysis_options.yaml`

*Purpose:* Configures static analysis rules

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - prefer_const_constructors
    - unnecessary_null_in_if_null_operators
```

== Ansible Roles Reference

=== Common Role

*Path:* `deployment-module/roles/common/`

*Purpose:* Base system configuration

*Tasks:*
- Update and upgrade system packages
- Install essential tools (vim, htop, curl, git)
- Configure timezone and locale
- Create swap file for memory management
- Optimize system parameters

*Tags:* `common`, `base`, `packages`

*Variables:*

```yaml
server_timezone: "Europe/Paris"
server_locale: "en_US.UTF-8"
swap_file_size_mb: 1024
essential_packages:
  - vim
  - htop
  - curl
  - git
  - build-essential
```

=== Security Role

*Path:* `deployment-module/roles/security/`

*Purpose:* Harden server security

*Tasks:*
- Configure SSH (disable root login, password auth)
- Set up UFW firewall
- Install and configure fail2ban
- Enable automatic security updates
- Configure audit logging

*Tags:* `security`, `firewall`, `ssh`

*Variables:*

```yaml
ssh_port: 22
ssh_permit_root_login: "no"
ssh_password_authentication: "no"
firewall_allowed_ports:
  - 22   # SSH
  - 80   # HTTP
  - 443  # HTTPS
fail2ban_bantime: 3600
fail2ban_maxretry: 5
```

=== Docker Role

*Path:* `deployment-module/roles/docker/`

*Purpose:* Install Docker environment

*Tasks:*
- Remove old Docker versions
- Install Docker CE and Docker Compose
- Configure Docker daemon
- Add application user to docker group
- Enable Docker service

*Tags:* `docker`, `containers`

*Variables:*

```yaml
docker_compose_version: "2.24.0"
docker_daemon_options:
  log-driver: "json-file"
  log-opts:
    max-size: "10m"
    max-file: "3"
```

=== Monitoring Role

*Path:* `deployment-module/roles/monitoring/`

*Purpose:* Set up monitoring tools

*Tasks:*
- Install monitoring utilities
- Create health check scripts
- Configure log rotation
- Set up system alerts

*Tags:* `monitoring`, `logs`

*Scripts Created:*
- `/opt/monitoring/health_check.sh`: Comprehensive health check
- `/etc/logrotate.d/app`: Log rotation configuration

=== Backup Role

*Path:* `deployment-module/roles/backup/`

*Purpose:* Automated backup and recovery

*Tasks:*
- Create backup directories
- Install backup scripts
- Configure cron schedules
- Set up retention policies
- Enable backup verification

*Tags:* `backup`

*Variables:*

```yaml
backup_base_dir: "/opt/backups"
backup_retention_daily: 7
backup_retention_weekly: 28
backup_retention_monthly: 90
backup_cron_hour: "2"
backup_cron_minute: "0"
```

*Scripts Created:*
- `/opt/scripts/backup.sh`: Backup creation
- `/opt/scripts/restore.sh`: Backup restoration

*Cron Schedule:*
- Daily: Every day at 2:00 AM
- Weekly: Every Sunday at 2:00 AM
- Monthly: 1st of month at 2:00 AM

=== SSL Role

*Path:* `deployment-module/roles/ssl/`

*Purpose:* SSL/TLS automation

*Tasks:*
- Install certbot and dependencies
- Obtain Let's Encrypt certificate
- Configure nginx for SSL
- Set up auto-renewal
- Configure security headers

*Tags:* `ssl`, `certificates`

*Variables:*

```yaml
domain_name: "your-domain.com"  # Required
admin_email: "admin@example.com"  # Required
certbot_staging: false
ssl_protocols: "TLSv1.2 TLSv1.3"
ssl_hsts_enabled: true
ssl_hsts_max_age: 31536000
ssl_ocsp_stapling: true
```

*Scripts Created:*
- `/opt/scripts/check-cert-expiry.sh`: Certificate monitoring

*Cron Schedule:*
- Renewal: Every 7 days at 3:00 AM
- Expiry check: Daily at 9:00 AM

=== App Environment Role

*Path:* `deployment-module/roles/app_environment/`

*Purpose:* Prepare application environment

*Tasks:*
- Create application user
- Create application directories
- Install nginx reverse proxy
- Configure nginx for application
- Create environment file template
- Set proper permissions

*Tags:* `app`, `environment`, `nginx`

*Variables:*

```yaml
app_name: "flutter_grist_app"
app_user: "appuser"
app_home: "/opt/flutter_grist_app"
app_port: 8080
nginx_client_max_body_size: "50M"
```

*Directories Created:*
- `/opt/flutter_grist_app/`: Application root
- `/opt/flutter_grist_app/config/`: Configuration files
- `/opt/flutter_grist_app/logs/`: Application logs
- `/opt/flutter_grist_app/data/`: Application data

== CI/CD Pipeline Jobs

=== quality-checks Job

*Purpose:* Ensure code quality before deployment

*Duration:* ~1 minute

*Tasks:*
1. *flutter-analyze*: Static code analysis (~12 seconds)
2. *flutter-test*: Run 77 unit tests (~45 seconds)
3. *check-coverage*: Verify coverage ≥ 60% (~5 seconds)

*Triggers:* Automatically on every commit to any branch

*Failure Conditions:*
- Linting errors found
- Any test fails
- Coverage below threshold

=== secrets-scan Job

*Purpose:* Prevent credential leaks

*Duration:* ~15 seconds

*Tasks:*
1. *gitleaks*: Scan for hardcoded secrets

*Triggers:* After quality-checks passes

*Failure Conditions:*
- Secrets detected (API keys, passwords, tokens)

*Detection Patterns:*
- Generic high-entropy strings
- AWS credentials
- API keys and tokens
- Private keys
- Database connection strings

=== build Job

*Purpose:* Compile application for deployment

*Duration:* ~2 minutes

*Tasks:*
1. *build-flutter-app*: Compile Flutter web application

*Triggers:* After quality-checks and secrets-scan pass

*Outputs:*
- Production-optimized web build
- Build artifacts for deployment

*Failure Conditions:*
- Compilation errors
- Missing dependencies

=== deploy-production Job

*Purpose:* Deploy to Raspberry Pi production server

*Duration:* ~3-5 minutes

*Tasks:*
1. *ansible-deploy*: Run Ansible playbooks (~2-4 minutes)
2. *health-check*: Verify deployment success (~30 seconds)
3. *rollback*: Revert on failure (if health check fails)

*Triggers:*
- Automatically on main branch after build passes
- Manually via Fly CLI or Web UI

*Failure Conditions:*
- Ansible connection fails
- Deployment tasks fail
- Health check returns non-200 status

== Environment Variables

=== Concourse Credentials

Stored in `deployment-module/concourse/credentials.yml`:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Variable*], [*Purpose*],

  [`github-private-key`], [SSH key for accessing Git repository],
  [`raspberry-pi-host`], [Production server IP address],
  [`raspberry-pi-user`], [SSH user for deployment],
  [`ssh-private-key`], [SSH key for server access],
  [`slack-webhook`], [Slack notification URL (optional)],
)

=== Application Environment

Stored on Raspberry Pi in `/opt/flutter_grist_app/config/.env`:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Variable*], [*Purpose*],

  [`GRIST_API_URL`], [Grist server URL],
  [`GRIST_API_KEY`], [Grist API authentication token],
  [`APP_ENV`], [Environment: production, staging, development],
  [`LOG_LEVEL`], [Logging verbosity: error, warn, info, debug],
  [`PORT`], [Application HTTP port],
)

== Network Ports

=== Development Machine (Laptop)

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Port*], [*Service*], [*Purpose*],

  [8080], [Concourse Web UI], [Pipeline management and monitoring],
  [5432], [PostgreSQL (Concourse)], [Concourse metadata storage],
  [2222], [Concourse TSA], [Worker registration],
)

=== Production Server (Raspberry Pi)

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  [*Port*], [*Service*], [*Purpose*],

  [22], [SSH], [Remote access and deployment],
  [80], [nginx (HTTP)], [Web traffic (redirects to HTTPS)],
  [443], [nginx (HTTPS)], [Secure web traffic],
  [8080], [Flutter App], [Application (behind nginx)],
  [8484], [Grist], [Grist server (behind nginx)],
)

== File Locations

=== On Raspberry Pi

*Application:*
- `/opt/flutter_grist_app/`: Application root directory
- `/opt/flutter_grist_app/config/.env`: Environment variables
- `/opt/flutter_grist_app/docker-compose.yml`: Container definitions
- `/opt/flutter_grist_app/logs/`: Application logs

*System Scripts:*
- `/opt/scripts/backup.sh`: Backup creation script
- `/opt/scripts/restore.sh`: Backup restoration script
- `/opt/scripts/check-cert-expiry.sh`: Certificate monitoring
- `/opt/monitoring/health_check.sh`: System health check

*Backups:*
- `/opt/backups/daily/`: Daily backups (7-day retention)
- `/opt/backups/weekly/`: Weekly backups (28-day retention)
- `/opt/backups/monthly/`: Monthly backups (90-day retention)

*Configuration:*
- `/etc/nginx/sites-available/flutter_grist_app`: nginx config
- `/etc/letsencrypt/`: SSL certificates
- `/etc/ufw/`: Firewall rules
- `/etc/fail2ban/`: Intrusion prevention

*Logs:*
- `/var/log/nginx/`: nginx access and error logs
- `/var/log/backup.log`: Backup operation logs
- `/var/log/certbot-renew.log`: Certificate renewal logs
- `/var/log/syslog`: System logs

=== On Development Machine

*Concourse:*
- `deployment-module/concourse/docker-compose.yml`: Service definitions
- `deployment-module/concourse/pipeline.yml`: Pipeline configuration
- `deployment-module/concourse/credentials.yml`: Secrets (not in Git)
- `deployment-module/concourse/keys/`: Concourse authentication keys

*Ansible:*
- `deployment-module/inventory/hosts.yml`: Server inventory
- `deployment-module/ansible.cfg`: Ansible configuration
- `deployment-module/ansible.log`: Ansible execution logs

== Version Information

=== Current Versions

*Application:*
- Flutter Grist API: v0.3.0
- Flutter SDK: 3.x
- Dart SDK: 3.x

*Infrastructure:*
- Concourse CI: 7.11
- PostgreSQL: 15
- Ansible: 2.9+
- Docker: 24.x
- Docker Compose: 2.24.x

*Operating Systems:*
- Development: Linux/macOS/Windows with Docker
- Production: Raspberry Pi OS (Debian-based)

== Common Workflows

=== Deploy Pipeline Update

```bash
# 1. Edit pipeline
vim deployment-module/concourse/pipeline.yml

# 2. Validate
fly validate-pipeline -c deployment-module/concourse/pipeline.yml

# 3. Deploy
fly -t local set-pipeline -p flutter-grist \
  -c deployment-module/concourse/pipeline.yml \
  -l deployment-module/concourse/credentials.yml

# 4. Unpause
fly -t local unpause-pipeline -p flutter-grist
```

=== Manual Deployment

```bash
# Trigger deployment
fly -t local trigger-job -j flutter-grist/deploy-production

# Watch progress
fly -t local watch -j flutter-grist/deploy-production
```

=== Run Tests Locally

```bash
cd flutter-module

# Using Docker (matches CI)
./docker-test.sh test

# Using local Flutter
flutter test --coverage
```

=== Update Inventory

```bash
# Edit inventory
vim deployment-module/inventory/hosts.yml

# Test connection
./docker-ansible.sh ping

# Deploy changes
./docker-ansible.sh playbooks/configure_server.yml
```

=== Emergency Rollback

```bash
# SSH to Pi
ssh appuser@192.168.1.100

# View commits
cd /opt/flutter_grist_app
git log --oneline -5

# Rollback
git checkout HEAD~1
docker-compose down
docker-compose up -d

# Verify
curl http://localhost/health
```

== Performance Benchmarks

=== Pipeline Execution Times

#table(
  columns: (auto, auto, auto),
  align: (left, left, left),
  [*Job*], [*Duration*], [*Notes*],

  [quality-checks], [~1 minute], [Parallel execution of analyze + test],
  [secrets-scan], [~15 seconds], [Depends on repository size],
  [build], [~2 minutes], [Flutter web build],
  [deploy-production], [~3-5 minutes], [Ansible + health checks],
  [*Full Pipeline*], [*~6-8 minutes*], [From commit to production],
)

=== Resource Usage

*Concourse (Development Machine):*
- CPU: 10-20% during builds
- RAM: ~2GB for all services
- Disk: ~5GB (images + artifacts)

*Application (Raspberry Pi):*
- CPU: 5-10% idle, 20-40% under load
- RAM: ~1GB for all containers
- Disk: ~10GB (app + backups)

== Quick Reference Tables

=== Fly CLI Commands

#command_table((
  (command: "fly -t local login", description: "Login to Concourse", example: "fly -t local login -c http://localhost:8080"),
  (command: "fly -t local pipelines", description: "List pipelines", example: "fly -t local pipelines"),
  (command: "fly -t local trigger-job", description: "Trigger job", example: "fly -t local trigger-job -j PIPELINE/JOB"),
  (command: "fly -t local watch", description: "Watch job", example: "fly -t local watch -j PIPELINE/JOB"),
))

=== Ansible Tags

#table(
  columns: (auto, 1fr),
  align: (left, left),
  [*Tag*], [*Roles/Tasks*],

  [`common`], [Base system configuration],
  [`security`], [Security hardening, SSH, firewall],
  [`docker`], [Docker installation and configuration],
  [`monitoring`], [Monitoring tools and scripts],
  [`backup`], [Backup automation],
  [`ssl`], [SSL/TLS configuration],
  [`app`], [Application environment setup],
)

=== Health Check Endpoints

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, left),
  [*Endpoint*], [*Purpose*], [*Expected Response*],

  [`/health`], [Basic application health], [200 OK],
  [`/api/status`], [API status], [200 OK with JSON],
  [`/api/version`], [Application version], [200 OK with version],
)

#section_separator()

This reference guide provides comprehensive information for managing the CI/CD pipeline and deployment infrastructure. Keep it handy for quick lookups during operations.
