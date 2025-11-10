# Troubleshooting Guide

## Pipeline Failures

### Test Failures

[Table content - see original for details],
  (
    issue: [Flutter test timeout],
    solution: [
      Increase timeout in test: `test('name', () async {...}, timeout: Timeout(Duration(minutes: 5)))`. Check for infinite loops or deadlocks. Use `flutter test --verbose` for details.
    ],
    priority: "medium"
  ),
  (
    issue: [Coverage check fails below threshold],
    solution: [
      Generate coverage report: `flutter test --coverage`. Review uncovered files: `genhtml coverage/lcov.info -o coverage/html`. Add tests for critical paths. Adjust threshold in pipeline.yml if needed (MIN_COVERAGE variable).
    ],
    priority: "medium"
  ),
  (
    issue: [Flaky tests failing intermittently],
    solution: [
      Identify flaky test pattern. Add proper async handling: `await tester.pumpAndSettle()`. Use mocks for external dependencies. Add retry logic or mark as `@Tags(['flaky'])`. Run multiple times: `flutter test --repeat 10`.
    ],
    priority: "high"
  ),
))

### Build Failures

[Table content - see original for details]. Format code: `dart format .`.
    ],
    priority: "medium"
  ),
  (
    issue: [Dependency resolution fails],
    solution: [
      Clear cache: `flutter clean && flutter pub get`. Check pubspec.yaml for version conflicts. Update dependencies: `flutter pub upgrade`. Use `flutter pub deps` to view dependency tree. Check for platform-specific dependencies.
    ],
    priority: "high"
  ),
  (
    issue: [Docker build fails pulling Flutter image],
    solution: [
      Check Docker Hub status. Verify internet connectivity. Try alternative registry. Build image locally: `docker build -t flutter-dev flutter-module/`. Check proxy settings if behind firewall.
    ],
    priority: "high"
  ),
  (
    issue: [Out of disk space during build],
    solution: [
      Clean Docker: `docker system prune -af`. Remove old images: `docker image prune -a`. Check disk space: `df -h`. Increase Docker disk allocation. Clean Flutter cache: `flutter clean`.
    ],
    priority: "high"
  ),
))

### Secrets Scanning Failures

[Table content - see original for details],
  (
    issue: [Real secret detected in history],
    solution: [
      DO NOT just add to .gitleaksignore! Rotate the compromised credential immediately. Remove from Git history: `git filter-branch` or BFG Repo-Cleaner. Force push (coordinate with team). Update credential in secure location.
    ],
    priority: "high"
  ),
  (
    issue: [Gitleaks binary download fails],
    solution: [
      Check GitHub API rate limits. Download manually and add to Docker image. Use alternative download URL. Check corporate firewall/proxy settings. Cache binary in container image.
    ],
    priority: "low"
  ),
))

## Concourse Issues

### Service Startup Problems

[Table content - see original for details],
  (
    issue: [Worker not registering with web],
    solution: [
      Check worker logs: `docker-compose logs concourse-worker`. Verify keys match between web and worker. Ensure TSA_HOST is correct in docker-compose.yml. Restart worker: `docker-compose restart concourse-worker`. Check network connectivity.
    ],
    priority: "high"
  ),
  (
    issue: [Database connection errors],
    solution: [
      Check PostgreSQL: `docker-compose logs concourse-db`. Verify database credentials in docker-compose.yml. Ensure db is ready before web starts (depends_on). Check disk space. Reset database: `docker-compose down -v && docker-compose up -d`.
    ],
    priority: "high"
  ),
  (
    issue: [Permission denied errors in worker],
    solution: [
      Worker needs privileged mode for Docker-in-Docker. Check docker-compose.yml: `privileged: true`. Verify Docker socket mount: `/var/run/docker.sock`. Check file permissions on keys directory.
    ],
    priority: "high"
  ),
))

### Pipeline Execution Issues

[Table content - see original for details].
    ],
    priority: "medium"
  ),
  (
    issue: [Task fails with "image not found"],
    solution: [
      Verify image exists: `docker images`. Build image if needed. Check image_resource in task config. Ensure Docker registry is accessible. Use full image path including registry.
    ],
    priority: "high"
  ),
  (
    issue: [Credentials not available in task],
    solution: [
      Check credentials.yml has variable. Verify pipeline loaded with `-l credentials.yml`. Use correct syntax: `((variable-name))`. Check params section in task config. View pipeline config: `fly -t local get-pipeline -p PIPELINE`.
    ],
    priority: "high"
  ),
  (
    issue: [Task timeout with no output],
    solution: [
      Increase timeout in task config. Check if task is hanging (infinite loop, waiting for input). Use `fly -t local intercept` to debug interactively. Add verbose output to task script. Check for deadlocks in code.
    ],
    priority: "medium"
  ),
))

### Resource Issues

[Table content - see original for details],
  (
    issue: [SSH authentication fails for Git resource],
    solution: [
      Verify private key in credentials.yml. Check key format (BEGIN RSA PRIVATE KEY). Ensure no passphrase on key. Test SSH manually: `ssh -T git@github.com`. Add host key to known_hosts if needed.
    ],
    priority: "high"
  ),
  (
    issue: [Resource check fails with rate limit],
    solution: [
      GitHub API rate limit reached. Add personal access token to resource config. Wait for rate limit reset (1 hour). Use webhook for instant updates instead of polling. Cache resource checks.
    ],
    priority: "low"
  ),
))

## Deployment Issues

### Ansible Connection Problems

[Table content - see original for details],
  (
    issue: [Ansible times out waiting for response],
    solution: [
      Increase timeout in ansible.cfg: `timeout = 60`. Check network latency: `ping 192.168.1.100`. Verify Pi not under heavy load: `ssh pi@192.168.1.100 'top'`. Check firewall not blocking connection.
    ],
    priority: "medium"
  ),
  (
    issue: [Permission denied (sudo required)],
    solution: [
      Ensure user has sudo privileges: `ssh pi@192.168.1.100 'sudo -l'`. Add NOPASSWD to sudoers: `pi ALL=(ALL) NOPASSWD:ALL`. Use `become: yes` in playbook. Check become_method in ansible.cfg.
    ],
    priority: "high"
  ),
  (
    issue: [Ansible variables not substituted],
    solution: [
      Check variable name spelling. Verify variable defined in inventory/hosts.yml or group_vars. Use correct Jinja2 syntax: `{{ variable }}`. Test with debug: `- debug: var=variable_name`. Check variable scope (host, group, global).
    ],
    priority: "medium"
  ),
))

### Docker Deployment Issues

[Table content - see original for details],
  (
    issue: [Image architecture mismatch (ARM vs x86)],
    solution: [
      Build for correct architecture: `docker buildx build --platform linux/arm64`. Use multi-arch images from Docker Hub. Check image manifest: `docker manifest inspect IMAGE`. Ensure Raspberry Pi architecture matches: `uname -m`.
    ],
    priority: "high"
  ),
  (
    issue: [Environment variables not loaded],
    solution: [
      Check .env file exists in correct location. Verify docker-compose.yml references env_file. Use `docker-compose config` to see final config. SSH and check: `docker exec CONTAINER env`. Ensure correct format (NO quotes unless needed).
    ],
    priority: "medium"
  ),
  (
    issue: [Volume mount permissions error],
    solution: [
      Check directory ownership: `ls -la /opt/flutter_grist_app`. Fix permissions: `sudo chown -R appuser:appuser /opt/flutter_grist_app`. Verify user in docker-compose.yml matches system user. Use named volumes instead of bind mounts if possible.
    ],
    priority: "medium"
  ),
))

### Health Check Failures

[Table content - see original for details],
  (
    issue: [Health check times out],
    solution: [
      Increase timeout in health check task. Check if application is slow to start. Verify nginx is running: `sudo systemctl status nginx`. Check firewall: `sudo ufw status`. Test from Pi locally first: `curl localhost/health`.
    ],
    priority: "high"
  ),
  (
    issue: [SSL certificate validation fails],
    solution: [
      Check certificate validity: `sudo certbot certificates`. Test with curl: `curl -v https://domain.com/health`. Renew if expired: `sudo certbot renew`. Check nginx SSL config: `sudo nginx -t`. Verify certificate paths in nginx config.
    ],
    priority: "medium"
  ),
))

## SSL/TLS Issues

### Certificate Problems

[Table content - see original for details]. Use `--dry-run` for testing. Check rate limits: https://letsencrypt.org/docs/rate-limits/.
    ],
    priority: "medium"
  ),
  (
    issue: [ACME challenge fails],
    solution: [
      Verify domain DNS points to server: `nslookup domain.com`. Ensure port 80 open: `sudo ufw allow 80`. Check nginx serving /.well-known/acme-challenge/. Stop other services using port 80. Verify domain is not on blacklist.
    ],
    priority: "high"
  ),
  (
    issue: [Certificate auto-renewal fails],
    solution: [
      Check cron job exists: `sudo crontab -l`. Review renewal logs: `sudo tail -f /var/log/certbot-renew.log`. Test renewal: `sudo certbot renew --dry-run`. Ensure nginx reload succeeds after renewal. Check disk space.
    ],
    priority: "high"
  ),
  (
    issue: [nginx fails to start with SSL config],
    solution: [
      Test config: `sudo nginx -t`. Verify certificate paths exist: `ls -la /etc/letsencrypt/live/DOMAIN/`. Check certificate and key match: `sudo openssl x509 -noout -modulus -in cert.pem | openssl md5`. Fix permissions: `sudo chmod 644 cert.pem`.
    ],
    priority: "high"
  ),
))

## Backup and Recovery Issues

### Backup Failures

[Table content - see original for details],
  (
    issue: [Backup disk full],
    solution: [
      Check disk space: `df -h /opt/backups/`. Remove old backups: `sudo /opt/scripts/backup.sh cleanup`. Reduce retention period in config. Use external storage or remote backup. Exclude large unnecessary data.
    ],
    priority: "high"
  ),
  (
    issue: [Backup verification fails (checksum mismatch)],
    solution: [
      Backup file corrupted during creation. Check disk health: `sudo smartctl -a /dev/sda`. Retry backup. Test write performance. Consider backup to multiple locations. Check for bit rot.
    ],
    priority: "high"
  ),
  (
    issue: [Remote backup sync fails],
    solution: [
      Test SSH connectivity: `ssh backup@remote-host`. Verify SSH keys: `ssh-copy-id backup@remote-host`. Check network connectivity. Verify remote disk space. Check rsync/scp command syntax in backup script.
    ],
    priority: "medium"
  ),
))

### Restore Issues

[Table content - see original for details],
  (
    issue: [Restored application won't start],
    solution: [
      Check Docker logs: `docker-compose logs`. Verify all files restored: `ls -la /opt/flutter_grist_app/`. Check file permissions: `sudo chown -R appuser:appuser /opt/flutter_grist_app/`. Restart services: `docker-compose restart`. Verify environment variables.
    ],
    priority: "high"
  ),
  (
    issue: [Database restore incomplete],
    solution: [
      Verify backup integrity before restore. Check Grist data directory: `ls -la /opt/grist/data/`. Stop Grist before restore: `docker-compose stop grist`. Restore again. Check Grist logs: `docker-compose logs grist`.
    ],
    priority: "high"
  ),
))

## Performance Issues

### Slow Pipeline Execution

[Table content - see original for details]` for one-time setup. Consider splitting test suite.
    ],
    priority: "medium"
  ),
  (
    issue: [Docker builds are slow],
    solution: [
      Use layer caching effectively. Put dependencies before code in Dockerfile. Use `.dockerignore` to exclude unnecessary files. Pre-build base images. Use BuildKit: `DOCKER_BUILDKIT=1`. Consider multi-stage builds.
    ],
    priority: "low"
  ),
  (
    issue: [Ansible playbook runs slowly],
    solution: [
      Use pipelining: `pipelining = True` in ansible.cfg. Enable ControlPersist for SSH. Run only necessary roles with --tags. Reduce gathering_facts overhead. Use async tasks for long-running operations. Optimize task conditions.
    ],
    priority: "low"
  ),
  (
    issue: [Concourse worker under heavy load],
    solution: [
      Check container resources: `docker stats`. Limit parallel jobs in pipeline. Increase worker resources in docker-compose.yml. Add another worker container. Monitor CPU/memory usage. Clean up old build artifacts.
    ],
    priority: "medium"
  ),
))

## Debugging Techniques

### Interactive Debugging

#### Hijack into Failed Build

```bash
# Intercept a running or failed build
fly -t local intercept -j flutter-grist/quality-checks

# Once inside container:
cd source-code/flutter-module
flutter test --verbose
flutter analyze

# Exit when done
exit
```

#### Execute Task Locally

```bash
# Run a task without full pipeline
fly -t local execute \
  -c deployment-module/concourse/tasks/flutter-test.yml \
  -i source-code=/home/user/flutterGristAPI/

# Watch output
# Debug issues locally before pipeline
```

#### SSH Debug on Raspberry Pi

```bash
# Connect with verbose SSH
ssh -v pi@192.168.1.100

# Once connected:
# Check Docker
docker ps -a
docker-compose logs -f

# Check nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log

# Check system
sudo systemctl status
df -h
free -h
top
```

### Log Analysis

#### Concourse Logs

```bash
# View specific service logs
docker-compose logs -f concourse-web
docker-compose logs -f concourse-worker

# View build logs
fly -t local watch -j PIPELINE/JOB -b BUILD_ID

# Download logs
fly -t local watch -j PIPELINE/JOB > build.log
```

#### Application Logs

```bash
# On Raspberry Pi
ssh appuser@192.168.1.100

# Docker container logs
docker logs flutter-app --tail=100 -f
docker-compose logs --tail=100 -f

# System logs
sudo journalctl -u nginx -n 50
sudo journalctl -xe
tail -f /var/log/syslog
```

#### Ansible Logs

```bash
# Verbose Ansible execution
./docker-ansible.sh playbooks/configure_server.yml -vvv

# Check Ansible log file
cat deployment-module/ansible.log

# Debug specific task
ansible-playbook playbooks/configure_server.yml --step
```

### Common Debugging Commands

```bash
# Check Concourse connectivity
curl http://localhost:8080/api/v1/info

# Test Ansible connection
./docker-ansible.sh ping -vvv

# Verify Docker health
docker info
docker ps -a
docker stats

# Check network connectivity
ping 192.168.1.100
traceroute 192.168.1.100
netstat -tuln | grep 8080

# Monitor system resources
htop
iotop
vmstat 1
```

## Getting Help

### Internal Resources

1. *Documentation*: `/home/user/flutterGristAPI/documentation-module/`
2. *Ansible Defaults*: `deployment-module/roles/*/defaults/main.yml`
3. *Pipeline Config*: `deployment-module/concourse/pipeline.yml`
4. *Source Analysis*: `deployment-module/CONCOURSE_ANALYSIS.md`

### External Resources

- *Concourse Docs*: https://concourse-ci.org/docs.html
- *Ansible Docs*: https://docs.ansible.com/
- *Flutter Testing*: https://flutter.dev/docs/testing
- *Docker Troubleshooting*: https://docs.docker.com/config/daemon/

### Reporting Issues

When reporting issues, include:

1. *Error message*: Full error output
2. *Steps to reproduce*: Exact commands run
3. *Environment*: OS, versions, configuration
4. *Logs*: Relevant log excerpts
5. *Expected vs actual*: What should happen vs what happened

> **Note**: *Pro Tip*: Most issues can be resolved by checking logs, verifying configuration, and testing components individually. Start with the simplest explanation and work up to complex issues.

---

Remember: Troubleshooting is a skill that improves with practice. Document solutions when you find them!
