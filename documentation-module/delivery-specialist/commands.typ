// Common CI/CD Commands and Operations
#import "../common/styles.typ": *

= Command Reference

== Concourse Commands

=== Fly CLI Setup

#command_table((
  (
    command: "fly --version",
    description: "Check Fly CLI version",
    example: "fly --version"
  ),
  (
    command: "fly -t TARGET login",
    description: "Login to Concourse instance",
    example: "fly -t local login -c http://localhost:8080"
  ),
  (
    command: "fly targets",
    description: "List all configured Concourse targets",
    example: "fly targets"
  ),
  (
    command: "fly -t TARGET sync",
    description: "Sync Fly CLI version with Concourse",
    example: "fly -t local sync"
  ),
))

=== Pipeline Management

#command_table((
  (
    command: "fly -t TARGET pipelines",
    description: "List all pipelines",
    example: "fly -t local pipelines"
  ),
  (
    command: "fly -t TARGET set-pipeline",
    description: "Create or update pipeline from YAML file",
    example: "fly -t local set-pipeline -p flutter-grist -c pipeline.yml"
  ),
  (
    command: "fly -t TARGET get-pipeline",
    description: "Download pipeline configuration",
    example: "fly -t local get-pipeline -p flutter-grist > backup.yml"
  ),
  (
    command: "fly -t TARGET pause-pipeline",
    description: "Pause (disable) a pipeline",
    example: "fly -t local pause-pipeline -p flutter-grist"
  ),
  (
    command: "fly -t TARGET unpause-pipeline",
    description: "Unpause (enable) a pipeline",
    example: "fly -t local unpause-pipeline -p flutter-grist"
  ),
  (
    command: "fly -t TARGET destroy-pipeline",
    description: "Delete a pipeline permanently",
    example: "fly -t local destroy-pipeline -p flutter-grist"
  ),
))

=== Job Operations

#command_table((
  (
    command: "fly -t TARGET jobs",
    description: "List jobs in a pipeline",
    example: "fly -t local jobs -p flutter-grist"
  ),
  (
    command: "fly -t TARGET trigger-job",
    description: "Manually trigger a job",
    example: "fly -t local trigger-job -j flutter-grist/deploy-production"
  ),
  (
    command: "fly -t TARGET watch",
    description: "Watch job execution in real-time",
    example: "fly -t local watch -j flutter-grist/quality-checks"
  ),
  (
    command: "fly -t TARGET builds",
    description: "List builds for a job",
    example: "fly -t local builds -j flutter-grist/deploy-production"
  ),
  (
    command: "fly -t TARGET abort-build",
    description: "Abort a running build",
    example: "fly -t local abort-build -j flutter-grist/deploy-production -b 42"
  ),
  (
    command: "fly -t TARGET pause-job",
    description: "Pause (disable) a specific job",
    example: "fly -t local pause-job -j flutter-grist/deploy-production"
  ),
))

=== Resource Operations

#command_table((
  (
    command: "fly -t TARGET resources",
    description: "List resources in a pipeline",
    example: "fly -t local resources -p flutter-grist"
  ),
  (
    command: "fly -t TARGET check-resource",
    description: "Force check for new resource versions",
    example: "fly -t local check-resource -r flutter-grist/source-code"
  ),
  (
    command: "fly -t TARGET resource-versions",
    description: "List versions of a resource",
    example: "fly -t local resource-versions -r flutter-grist/source-code"
  ),
  (
    command: "fly -t TARGET pin-resource",
    description: "Pin resource to a specific version",
    example: "fly -t local pin-resource -r flutter-grist/source-code -v ref:abc123"
  ),
  (
    command: "fly -t TARGET unpin-resource",
    description: "Unpin a resource",
    example: "fly -t local unpin-resource -r flutter-grist/source-code"
  ),
))

=== Build Logs and Debugging

#command_table((
  (
    command: "fly -t TARGET watch -b BUILD_ID",
    description: "Watch a specific build by ID",
    example: "fly -t local watch -b 123"
  ),
  (
    command: "fly -t TARGET intercept",
    description: "Hijack into a running or failed build container",
    example: "fly -t local intercept -j flutter-grist/quality-checks"
  ),
  (
    command: "fly -t TARGET execute",
    description: "Execute a task locally (without pipeline)",
    example: "fly -t local execute -c task.yml"
  ),
))

=== Pipeline Validation

#command_table((
  (
    command: "fly validate-pipeline",
    description: "Validate pipeline YAML syntax (offline)",
    example: "fly validate-pipeline -c pipeline.yml"
  ),
  (
    command: "fly format-pipeline",
    description: "Format pipeline YAML consistently",
    example: "fly format-pipeline -c pipeline.yml"
  ),
))

== Docker Compose Commands (Concourse)

=== Service Management

#command_table((
  (
    command: "docker-compose up -d",
    description: "Start Concourse services in background",
    example: "docker-compose up -d"
  ),
  (
    command: "docker-compose down",
    description: "Stop and remove Concourse services",
    example: "docker-compose down"
  ),
  (
    command: "docker-compose restart",
    description: "Restart all services",
    example: "docker-compose restart"
  ),
  (
    command: "docker-compose ps",
    description: "List running services",
    example: "docker-compose ps"
  ),
  (
    command: "docker-compose logs -f",
    description: "Follow logs from all services",
    example: "docker-compose logs -f concourse-worker"
  ),
))

=== Service Health

#command_table((
  (
    command: "docker-compose exec SERVICE sh",
    description: "Open shell in service container",
    example: "docker-compose exec concourse-worker sh"
  ),
  (
    command: "docker-compose top",
    description: "Display running processes",
    example: "docker-compose top"
  ),
  (
    command: "docker stats",
    description: "Show container resource usage",
    example: "docker stats"
  ),
))

=== Cleanup and Maintenance

#command_table((
  (
    command: "docker-compose down -v",
    description: "Stop services and remove volumes (full reset)",
    example: "docker-compose down -v"
  ),
  (
    command: "docker system prune",
    description: "Remove unused Docker data",
    example: "docker system prune -f"
  ),
  (
    command: "docker volume prune",
    description: "Remove unused volumes",
    example: "docker volume prune -f"
  ),
))

== Ansible Commands

=== Using docker-ansible.sh Wrapper

#command_table((
  (
    command: "./docker-ansible.sh build",
    description: "Build Ansible Docker image",
    example: "./docker-ansible.sh build"
  ),
  (
    command: "./docker-ansible.sh ping",
    description: "Test connectivity to all hosts",
    example: "./docker-ansible.sh ping"
  ),
  (
    command: "./docker-ansible.sh PLAYBOOK",
    description: "Run a playbook using Docker",
    example: "./docker-ansible.sh playbooks/configure_server.yml"
  ),
  (
    command: "./docker-ansible.sh shell",
    description: "Open interactive shell in Ansible container",
    example: "./docker-ansible.sh shell"
  ),
  (
    command: "./docker-ansible.sh help",
    description: "Show help and usage",
    example: "./docker-ansible.sh help"
  ),
))

=== Playbook Execution

#command_table((
  (
    command: "ansible-playbook PLAYBOOK",
    description: "Run a playbook (local Ansible)",
    example: "ansible-playbook playbooks/configure_server.yml"
  ),
  (
    command: "ansible-playbook PLAYBOOK --check",
    description: "Dry run without making changes",
    example: "ansible-playbook playbooks/configure_server.yml --check"
  ),
  (
    command: "ansible-playbook PLAYBOOK --diff",
    description: "Show file differences",
    example: "ansible-playbook playbooks/configure_server.yml --diff"
  ),
  (
    command: "ansible-playbook PLAYBOOK --tags TAG",
    description: "Run only tasks with specific tags",
    example: "ansible-playbook playbooks/configure_server.yml --tags docker"
  ),
  (
    command: "ansible-playbook PLAYBOOK -v",
    description: "Verbose output (-v, -vv, -vvv for more detail)",
    example: "ansible-playbook playbooks/configure_server.yml -vv"
  ),
))

=== Ad-Hoc Commands

#command_table((
  (
    command: "ansible all -m ping",
    description: "Ping all hosts",
    example: "ansible all -m ping"
  ),
  (
    command: "ansible all -a COMMAND",
    description: "Run shell command on all hosts",
    example: "ansible all -a 'uptime'"
  ),
  (
    command: "ansible HOST -m MODULE",
    description: "Run specific module on host",
    example: "ansible raspberry_pi -m setup"
  ),
  (
    command: "ansible-inventory --list",
    description: "Display parsed inventory",
    example: "ansible-inventory -i inventory/hosts.yml --list"
  ),
))

=== Ansible Vault (Secrets Management)

#command_table((
  (
    command: "ansible-vault create FILE",
    description: "Create encrypted file",
    example: "ansible-vault create secrets.yml"
  ),
  (
    command: "ansible-vault edit FILE",
    description: "Edit encrypted file",
    example: "ansible-vault edit secrets.yml"
  ),
  (
    command: "ansible-vault encrypt FILE",
    description: "Encrypt existing file",
    example: "ansible-vault encrypt credentials.yml"
  ),
  (
    command: "ansible-vault decrypt FILE",
    description: "Decrypt file",
    example: "ansible-vault decrypt credentials.yml"
  ),
  (
    command: "ansible-playbook --ask-vault-pass",
    description: "Run playbook with vault password prompt",
    example: "ansible-playbook playbooks/configure_server.yml --ask-vault-pass"
  ),
))

== Git Commands for CI/CD

=== Branch Management

#command_table((
  (
    command: "git status",
    description: "Show working tree status",
    example: "git status"
  ),
  (
    command: "git checkout -b BRANCH",
    description: "Create and switch to new branch",
    example: "git checkout -b feature/new-widget"
  ),
  (
    command: "git push origin BRANCH",
    description: "Push branch to remote (triggers CI)",
    example: "git push origin main"
  ),
  (
    command: "git merge BRANCH",
    description: "Merge branch into current branch",
    example: "git merge feature/new-widget"
  ),
))

=== Tagging Releases

#command_table((
  (
    command: "git tag -a VERSION -m MSG",
    description: "Create annotated tag for release",
    example: "git tag -a v0.3.0 -m 'Release 0.3.0'"
  ),
  (
    command: "git push --tags",
    description: "Push tags to remote",
    example: "git push origin --tags"
  ),
  (
    command: "git tag -l",
    description: "List all tags",
    example: "git tag -l"
  ),
  (
    command: "git describe --tags",
    description: "Show most recent tag",
    example: "git describe --tags"
  ),
))

=== Viewing History

#command_table((
  (
    command: "git log --oneline",
    description: "Show commit history (compact)",
    example: "git log --oneline -10"
  ),
  (
    command: "git log --graph",
    description: "Show branch graph",
    example: "git log --graph --oneline --all"
  ),
  (
    command: "git diff",
    description: "Show changes not yet staged",
    example: "git diff"
  ),
  (
    command: "git show COMMIT",
    description: "Show commit details",
    example: "git show abc123"
  ),
))

== Testing Commands

=== Flutter Testing

#command_table((
  (
    command: "flutter test",
    description: "Run all tests",
    example: "flutter test"
  ),
  (
    command: "flutter test --coverage",
    description: "Run tests and generate coverage",
    example: "flutter test --coverage"
  ),
  (
    command: "flutter test FILE",
    description: "Run specific test file",
    example: "flutter test test/validators/email_validator_test.dart"
  ),
  (
    command: "flutter analyze",
    description: "Run static analysis",
    example: "flutter analyze --no-fatal-infos"
  ),
  (
    command: "./docker-test.sh test",
    description: "Run tests in Docker (same as CI)",
    example: "./docker-test.sh test"
  ),
))

=== Coverage Analysis

#command_table((
  (
    command: "lcov --summary FILE",
    description: "Show coverage summary",
    example: "lcov --summary coverage/lcov.info"
  ),
  (
    command: "genhtml LCOV -o DIR",
    description: "Generate HTML coverage report",
    example: "genhtml coverage/lcov.info -o coverage/html"
  ),
))

=== Secrets Scanning

#command_table((
  (
    command: "gitleaks detect",
    description: "Scan for secrets in repository",
    example: "gitleaks detect --source . --verbose"
  ),
  (
    command: "gitleaks detect --log-level",
    description: "Scan with specific log level",
    example: "gitleaks detect --log-level debug"
  ),
))

== Deployment Commands

=== On Raspberry Pi

#command_table((
  (
    command: "docker ps",
    description: "List running containers",
    example: "docker ps"
  ),
  (
    command: "docker-compose up -d",
    description: "Start application containers",
    example: "docker-compose up -d"
  ),
  (
    command: "docker-compose pull",
    description: "Pull latest images",
    example: "docker-compose pull"
  ),
  (
    command: "docker-compose logs -f",
    description: "Follow application logs",
    example: "docker-compose logs -f flutter-app"
  ),
  (
    command: "docker-compose restart",
    description: "Restart application",
    example: "docker-compose restart"
  ),
))

=== System Monitoring

#command_table((
  (
    command: "sudo systemctl status nginx",
    description: "Check nginx status",
    example: "sudo systemctl status nginx"
  ),
  (
    command: "sudo ufw status",
    description: "Check firewall status",
    example: "sudo ufw status"
  ),
  (
    command: "df -h",
    description: "Check disk space",
    example: "df -h"
  ),
  (
    command: "free -h",
    description: "Check memory usage",
    example: "free -h"
  ),
  (
    command: "/opt/monitoring/health_check.sh",
    description: "Run comprehensive health check",
    example: "sudo /opt/monitoring/health_check.sh"
  ),
))

== Backup and Recovery Commands

=== Backup Operations

#command_table((
  (
    command: "/opt/scripts/backup.sh TYPE",
    description: "Create backup (daily/weekly/monthly)",
    example: "sudo /opt/scripts/backup.sh daily"
  ),
  (
    command: "/opt/scripts/backup.sh stats",
    description: "Show backup statistics",
    example: "sudo /opt/scripts/backup.sh stats"
  ),
  (
    command: "ls -lh /opt/backups/",
    description: "List available backups",
    example: "ls -lh /opt/backups/daily/"
  ),
))

=== Restore Operations

#command_table((
  (
    command: "/opt/scripts/restore.sh --list",
    description: "List available backups",
    example: "sudo /opt/scripts/restore.sh --list"
  ),
  (
    command: "/opt/scripts/restore.sh --latest",
    description: "Restore from latest backup",
    example: "sudo /opt/scripts/restore.sh --latest"
  ),
  (
    command: "/opt/scripts/restore.sh FILE",
    description: "Restore from specific backup file",
    example: "sudo /opt/scripts/restore.sh /opt/backups/daily/backup_20250110.tar.gz"
  ),
))

== SSL/TLS Commands

=== Certificate Management

#command_table((
  (
    command: "sudo certbot renew",
    description: "Renew SSL certificates",
    example: "sudo certbot renew"
  ),
  (
    command: "sudo certbot renew --dry-run",
    description: "Test certificate renewal",
    example: "sudo certbot renew --dry-run"
  ),
  (
    command: "sudo certbot certificates",
    description: "List all certificates",
    example: "sudo certbot certificates"
  ),
  (
    command: "/opt/scripts/check-cert-expiry.sh",
    description: "Check certificate expiration",
    example: "sudo /opt/scripts/check-cert-expiry.sh your-domain.com"
  ),
))

=== Nginx Operations

#command_table((
  (
    command: "sudo nginx -t",
    description: "Test nginx configuration",
    example: "sudo nginx -t"
  ),
  (
    command: "sudo systemctl reload nginx",
    description: "Reload nginx config (no downtime)",
    example: "sudo systemctl reload nginx"
  ),
  (
    command: "sudo systemctl restart nginx",
    description: "Restart nginx",
    example: "sudo systemctl restart nginx"
  ),
  (
    command: "sudo tail -f /var/log/nginx/error.log",
    description: "Follow nginx error logs",
    example: "sudo tail -f /var/log/nginx/error.log"
  ),
))

== Quick Command Workflows

=== Deploy Pipeline Changes

```bash
# 1. Edit pipeline
vim deployment-module/concourse/pipeline.yml

# 2. Validate syntax
fly validate-pipeline -c deployment-module/concourse/pipeline.yml

# 3. Update pipeline in Concourse
fly -t local set-pipeline -p flutter-grist \
  -c deployment-module/concourse/pipeline.yml \
  -l deployment-module/concourse/credentials.yml

# 4. Unpause if paused
fly -t local unpause-pipeline -p flutter-grist
```

=== Trigger Full Deployment

```bash
# 1. Trigger quality checks
fly -t local trigger-job -j flutter-grist/quality-checks

# 2. Watch progress
fly -t local watch -j flutter-grist/quality-checks

# 3. If passed, trigger deployment
fly -t local trigger-job -j flutter-grist/deploy-production

# 4. Watch deployment
fly -t local watch -j flutter-grist/deploy-production
```

=== Debug Failed Build

```bash
# 1. List recent builds
fly -t local builds -j flutter-grist/quality-checks

# 2. Watch failed build logs
fly -t local watch -b BUILD_ID

# 3. Hijack into failed container
fly -t local intercept -j flutter-grist/quality-checks

# 4. Debug interactively in container
cd source-code/flutter-module
flutter test
```

=== Emergency Rollback

```bash
# 1. SSH to Raspberry Pi
ssh appuser@192.168.1.100

# 2. View recent commits
cd /opt/flutter_grist_app
git log --oneline -5

# 3. Rollback to previous version
git checkout HEAD~1

# 4. Restart services
docker-compose down
docker-compose up -d

# 5. Verify
curl http://localhost/health
```

=== Check System Health

```bash
# On laptop - check CI/CD
docker-compose ps
fly -t local pipelines

# On Raspberry Pi - check production
ssh appuser@192.168.1.100
docker ps
sudo systemctl status nginx
sudo /opt/monitoring/health_check.sh
```

#section_separator()

Keep this reference handy for quick command lookups during your daily CI/CD operations.
