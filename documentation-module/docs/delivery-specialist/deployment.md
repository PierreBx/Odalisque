# Deployment Management

## Deployment Architecture

The FlutterGristAPI project uses a hybrid deployment approach combining Ansible for infrastructure management and Docker for application deployment.

### Two-Phase Deployment Model

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: Infrastructure Configuration (Ansible)            │
│  - System packages and settings                             │
│  - Security hardening (SSH, firewall, fail2ban)             │
│  - Docker installation                                       │
│  - Monitoring and backup setup                              │
│  - SSL/TLS configuration                                     │
│  - nginx reverse proxy                                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2: Application Deployment (Docker Compose)           │
│  - Pull latest Docker images                                │
│  - Update docker-compose.yml                                │
│  - Restart containers with new versions                     │
│  - Verify health checks                                      │
└─────────────────────────────────────────────────────────────┘
```

## Ansible-Based Infrastructure Deployment

### Deployment Roles

The deployment is organized into Ansible roles, each responsible for a specific aspect:

| Role | Purpose | Tags |
| --- | --- | --- |
| common | Base system configuration, packages, timezone, locale, swap | common`, `base |
| security | SSH hardening, UFW firewall, fail2ban, automatic updates | security |
| docker | Docker CE installation, Docker Compose, daemon configuration | docker`, `containers |
| monitoring | System health checks, log rotation, monitoring scripts | monitoring |
| backup | Automated backup schedules, backup verification, restore scripts | backup |
| ssl | Let's Encrypt SSL/TLS, auto-renewal, certificate monitoring | ssl |
| app_environment | Application user, directories, nginx, environment files | app`, `environment |

### Running Full Infrastructure Deployment

#### Docker-Based Ansible (Recommended)

```bash
cd /home/user/flutterGristAPI/deployment-module/

# Build Ansible Docker image (one-time)
./docker-ansible.sh build

# Test connectivity
./docker-ansible.sh ping

# Full configuration (all roles)
./docker-ansible.sh playbooks/configure_server.yml

# Dry run to preview changes
./docker-ansible.sh playbooks/configure_server.yml --check --diff

# Verbose output for debugging
./docker-ansible.sh playbooks/configure_server.yml -vv
```

#### Local Ansible Installation

```bash
cd /home/user/flutterGristAPI/deployment-module/

# Install Ansible (if not already installed)
# Ubuntu/Debian:
sudo apt install ansible
# macOS:
brew install ansible

# Run deployment
ansible-playbook playbooks/configure_server.yml

# With specific inventory
ansible-playbook -i inventory/hosts.yml playbooks/configure_server.yml
```

### Selective Role Deployment

Deploy only specific roles using tags:

```bash
# Security updates only
./docker-ansible.sh playbooks/configure_server.yml --tags security

# Docker and application environment
./docker-ansible.sh playbooks/configure_server.yml --tags docker,app

# SSL certificate renewal
./docker-ansible.sh playbooks/configure_server.yml --tags ssl

# Backup configuration updates
./docker-ansible.sh playbooks/configure_server.yml --tags backup
```

### Configuration Variables

Key variables to customize in `inventory/hosts.yml`:

```yaml
all:
  children:
    production:
      hosts:
        raspberry_pi:
          ansible_host: 192.168.1.100
          ansible_user: pi
      vars:
        # System Configuration
        server_timezone: "Europe/Paris"
        server_locale: "en_US.UTF-8"

        # SSH Configuration
        ssh_port: 22
        ssh_permit_root_login: "no"
        ssh_password_authentication: "no"

        # Application Settings
        app_name: "flutter_grist_app"
        app_user: "appuser"
        app_home: "/opt/flutter_grist_app"
        deployment_env: "production"

        domain_name: "your-domain.com"
        admin_email: "admin@example.com"

        # Backup Settings
        backup_base_dir: "/opt/backups"
        backup_retention_daily: 7
        backup_retention_weekly: 28
        backup_retention_monthly: 90
```

## Deployment Strategies

### Rolling Updates (Current Strategy)

The default deployment strategy for FlutterGristAPI:

*Process:*
1. Pull new Docker images
2. Stop old containers gracefully
3. Start new containers with updated images
4. Run health checks

*Advantages:*
- ✅ Simple implementation
- ✅ Works well for single-server deployments
- ✅ Minimal downtime (< 10 seconds)
- ✅ Easy rollback

*Disadvantages:*
- ❌ Brief service interruption
- ❌ No traffic during transition

*Implementation:*
```bash
# On Raspberry Pi
cd /opt/flutter_grist_app/
docker-compose pull
docker-compose up -d --force-recreate
```

### Zero-Downtime Deployment (Future Enhancement)

For production environments requiring continuous availability:

*Strategy: Blue-Green Deployment*

```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (nginx)                     │
└───────────┬───────────────────────────────┬─────────────────┘
            │                               │
            ▼                               ▼
┌─────────────────────────┐   ┌─────────────────────────────┐
│  BLUE Environment        │   │  GREEN Environment          │
│  (Currently Active)      │   │  (New Version Staging)      │
│                          │   │                             │
│  flutter-app:v1.0        │   │  flutter-app:v1.1           │
│  grist:latest            │   │  grist:latest               │
└─────────────────────────┘   └─────────────────────────────┘

Deployment Process:
1. Deploy to GREEN (inactive)
2. Run health checks on GREEN
3. Switch traffic from BLUE → GREEN
4. Keep BLUE running for quick rollback
5. After verification, update BLUE
```

*Implementation:*
```yaml
# docker-compose.blue.yml
services:
  flutter-app-blue:
    image: flutter-app:v1.0
    container_name: flutter-blue
    ports:
      - "8080:80"

# docker-compose.green.yml
services:
  flutter-app-green:
    image: flutter-app:v1.1
    container_name: flutter-green
    ports:
      - "8081:80"
```

### Canary Deployment (Advanced)

Gradually roll out changes to a subset of users:

*Process:*
1. Deploy new version to 10% of servers
2. Monitor metrics and errors
3. Gradually increase to 25%, 50%, 100%
4. Rollback if issues detected

*Use Cases:*
- High-risk changes
- Large user bases
- Performance-sensitive applications

## Release Management

### Versioning Strategy

FlutterGristAPI uses semantic versioning (SemVer):

```
MAJOR.MINOR.PATCH

Example: 0.3.0
- MAJOR: Breaking API changes (0 → 1)
- MINOR: New features, backwards compatible (2 → 3)
- PATCH: Bug fixes, no new features (0 → 1)
```

### Git Branching Strategy

```
main (production)
  ↑
  │ merge after testing
  │
develop (integration)
  ↑
  │ feature branches merge here
  │
feature/new-widget
feature/fix-bug
hotfix/critical-issue (directly to main)
```

### Release Process

#### Standard Release

```bash
# 1. Create release branch
git checkout -b release/v0.3.0 develop

# 2. Update version numbers
vim flutter-module/pubspec.yaml  # version: 0.3.0

# 3. Run final tests
cd flutter-module
flutter test
flutter analyze

# 4. Commit version bump
git add pubspec.yaml
git commit -m "Bump version to 0.3.0"

# 5. Merge to main
git checkout main
git merge release/v0.3.0

# 6. Tag release
git tag -a v0.3.0 -m "Release version 0.3.0"
git push origin main --tags

# 7. Merge back to develop
git checkout develop
git merge release/v0.3.0
git push origin develop

# 8. CI/CD automatically deploys to production
```

#### Hotfix Release

For critical production bugs:

```bash
# 1. Create hotfix from main
git checkout -b hotfix/critical-bug main

# 2. Fix the issue
# ... make changes ...

# 3. Test thoroughly
flutter test

# 4. Bump patch version
vim pubspec.yaml  # 0.3.0 → 0.3.1

# 5. Merge to main
git checkout main
git merge hotfix/critical-bug
git tag -a v0.3.1 -m "Hotfix: Critical bug"
git push origin main --tags

# 6. Merge to develop
git checkout develop
git merge hotfix/critical-bug
git push origin develop
```

### Automated Deployment Triggers

#### Main Branch Deployment

```yaml
# Concourse pipeline automatically deploys main branch
- name: deploy-production
  plan:
    - get: source-code
      trigger: true  # Auto-deploy on main
      passed: [build, quality-checks]
```

When you push to main:
1. Quality checks run (analyze + test)
2. Secrets scan runs
3. Application builds
4. Deployment to production (if all pass)
5. Health checks verify deployment

#### Manual Deployment

```bash
# Trigger deployment manually via Fly CLI
fly -t local trigger-job -j flutter-grist/deploy-production

# Watch deployment progress
fly -t local watch -j flutter-grist/deploy-production

# Or use Web UI
# Navigate to http://localhost:8080
# Click deploy-production job
# Press '+' button
```

## Rollback Procedures

### Automatic Rollback

The pipeline includes automatic rollback on health check failure:

```yaml
- task: health-check
  on_failure:
    task: rollback
    config:
      platform: linux
      params:
        PREVIOUS_VERSION: ((previous-version))
      run:
        path: /bin/sh
        args:
          - -c
          - |
            echo "Health check failed! Rolling back..."
            ssh $RASPBERRY_PI_USER@$RASPBERRY_PI_HOST \
              'cd /opt/flutter_grist_app && \
               docker-compose down && \
               git checkout HEAD~1 && \
               docker-compose up -d'
```

### Manual Rollback

#### Method 1: Docker Image Rollback

```bash
# SSH to Raspberry Pi
ssh appuser@192.168.1.100

cd /opt/flutter_grist_app/

# View container history
docker ps -a

# Rollback to previous image
docker-compose down
docker tag flutter-app:latest flutter-app:rollback-backup
docker tag flutter-app:previous flutter-app:latest
docker-compose up -d

# Verify
docker ps
curl http://localhost/health
```

#### Method 2: Git-Based Rollback

```bash
# SSH to Raspberry Pi
ssh appuser@192.168.1.100

cd /opt/flutter_grist_app/

# View recent commits
git log --oneline -5

# Rollback to previous commit
git checkout HEAD~1

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d
```

#### Method 3: Backup Restore

If both Docker and Git rollback fail:

```bash
# SSH to Raspberry Pi
ssh appuser@192.168.1.100

# List available backups
sudo /opt/scripts/restore.sh --list

# Restore from latest backup before deployment
sudo /opt/scripts/restore.sh /opt/backups/daily/flutter_grist_backup_daily_20250110_020000.tar.gz

# Verify restoration
docker ps
sudo systemctl status nginx
```

### Rollback Verification

After any rollback:

```bash
# 1. Check Docker containers
docker ps
docker logs flutter-app

# 2. Test HTTP endpoints
curl http://localhost/health
curl http://localhost/api/status

# 3. Run health check script
sudo /opt/monitoring/health_check.sh

# 4. Check application logs
docker-compose logs -f

# 5. Verify user functionality
# Test critical user workflows manually
```

## Post-Deployment Procedures

### Health Check Verification

```bash
# Automated health check (run by CI/CD)
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
  http://raspberry-pi/health)

if [ "$HTTP_STATUS" = "200" ]; then
  echo "✅ Deployment successful"
else
  echo "❌ Deployment failed"
  exit 1
fi
```

### Manual Verification Steps

After deployment, verify:

```bash
# 1. SSH to production server
ssh appuser@192.168.1.100

# 2. Check all services running
docker ps
# Expected: flutter-app, grist, nginx

# 3. Verify nginx
sudo systemctl status nginx
curl -I http://localhost

# 4. Check SSL certificate (if configured)
sudo /opt/scripts/check-cert-expiry.sh your-domain.com

# 5. Test application endpoints
curl http://localhost/api/health
curl http://localhost/api/version

# 6. Check logs for errors
docker-compose logs --tail=100 flutter-app
sudo tail -f /var/log/nginx/error.log

# 7. Run comprehensive health check
sudo /opt/monitoring/health_check.sh
```

### Monitoring Post-Deployment

Monitor these metrics for 1-2 hours after deployment:

- *HTTP Status Codes*: Should be mostly 200s
- *Response Times*: Should be consistent with pre-deployment
- *Error Rates*: Should not increase
- *Resource Usage*: CPU, memory, disk
- *Container Health*: All containers running

## Deployment Automation Scripts

### Helper Script: docker-ansible.sh

Location: `/home/user/flutterGristAPI/deployment-module/docker-ansible.sh`

```bash
# Build Ansible Docker image
./docker-ansible.sh build

# Test connectivity
./docker-ansible.sh ping

# Run playbook
./docker-ansible.sh playbooks/configure_server.yml

# Run with tags
./docker-ansible.sh playbooks/configure_server.yml --tags docker

# Dry run
./docker-ansible.sh playbooks/configure_server.yml --check

# Interactive shell
./docker-ansible.sh shell

# Help
./docker-ansible.sh help
```

### Custom Deployment Script

Create a custom script for your workflow:

```bash
#!/bin/bash
# deploy.sh - Custom deployment script

set -e  # Exit on error

ENVIRONMENT=$1
TAG=${2:-latest}

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: ./deploy.sh <environment> [tag]"
  exit 1
fi

echo "🚀 Deploying to $ENVIRONMENT with tag $TAG"

# Run Ansible deployment
cd deployment-module
./docker-ansible.sh playbooks/configure_server.yml \
  --tags app \
  --extra-vars "docker_tag=$TAG"

# Wait for deployment
sleep 10

# Run health checks
echo "🔍 Running health checks..."
if curl -f http://raspberry-pi/health; then
  echo "✅ Deployment successful!"
else
  echo "❌ Health check failed!"
  exit 1
fi
```

## Troubleshooting Deployments

[Table content - see original for details],
  (
    issue: [Docker containers won't start],
    solution: [Check logs: `docker-compose logs`. Verify image pulled successfully: `docker images`. Check disk space: `df -h`.],
    priority: "high"
  ),
  (
    issue: [nginx fails to start after deployment],
    solution: [Test configuration: `sudo nginx -t`. Check port 80/443 not in use: `sudo lsof -i :80`. Review nginx logs: `sudo journalctl -u nginx`.],
    priority: "high"
  ),
  (
    issue: [Health checks fail post-deployment],
    solution: [Check application logs: `docker-compose logs`. Verify database connectivity. Check environment variables. Test endpoints manually: `curl -v http://localhost/health`.],
    priority: "high"
  ),
  (
    issue: [SSL certificate not renewing],
    solution: [Check certbot logs: `sudo tail -f /var/log/certbot-renew.log`. Verify domain DNS points to server. Check ports 80/443 open. Test manual renewal: `sudo certbot renew --dry-run`.],
    priority: "medium"
  ),
  (
    issue: [Backup restore incomplete],
    solution: [Verify backup integrity: `sudo /opt/scripts/backup.sh stats`. Check available disk space. Review restore logs. Try older backup if current is corrupted.],
    priority: "medium"
  ),
))

---

Effective deployment management ensures reliable, repeatable, and safe releases to production with minimal downtime and quick recovery options.
