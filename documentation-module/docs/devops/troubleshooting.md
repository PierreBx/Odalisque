# Troubleshooting Guide

Comprehensive guide to diagnosing and resolving common issues with FlutterGristAPI infrastructure.

## General Troubleshooting Approach

### Step-by-Step Methodology

1. *Identify the Problem*
   - What's not working?
   - When did it start?
   - What changed recently?

2. *Gather Information*
   - Check container status
   - Review logs
   - Check resource usage
   - Test connectivity

3. *Isolate the Cause*
   - Test components individually
   - Eliminate possibilities
   - Reproduce the issue

4. *Apply Solution*
   - Start with simple fixes
   - Test after each change
   - Document the solution

5. *Prevent Recurrence*
   - Address root cause
   - Update documentation
   - Implement monitoring

### Essential Diagnostic Commands

```bash
# Quick system check
docker ps -a                           # Container status
docker-compose logs --tail=50 grist    # Recent logs
docker stats --no-stream               # Resource usage
curl -I http://localhost:8484          # Service availability
df -h                                  # Disk space
```

## Container Issues

### Container Won't Start

[Table content - see original for details],
  (
    issue: "Container stuck in 'Restarting' state",
    solution: "Stop restart loop: `docker stop container_name`. Check logs for crash reason. Fix issue, then start again.",
    priority: "high"
  ),
  (
    issue: "'Port already in use' error",
    solution: "Find process: `lsof -i :8484` (Mac/Linux) or `netstat -ano | findstr :8484` (Windows). Kill process or change port.",
    priority: "high"
  ),
  (
    issue: "Container starts but immediately exits with code 137",
    solution: "OOM (Out of Memory) killed. Increase Docker memory limit or reduce container memory usage.",
    priority: "high"
  ),
))

*Detailed Solutions:*

#### Exit Code 137 (OOM Kill)

```bash
# Check Docker memory limits
docker info | grep -i memory

# Increase container memory limit
# Edit docker-compose.yml:
services:
  grist:
    deploy:
      resources:
        limits:
          memory: 2G

# Apply changes
docker-compose up -d --force-recreate
```

#### Port Conflict

```bash
# Find process using port 8484
lsof -i :8484  # macOS/Linux

# Example output:
# COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
# node    12345 user   20u  IPv4 0x1234      0t0  TCP *:8484

# Kill the process
kill 12345

# Or stop the Docker container
docker ps | grep 8484
docker stop container_id

# Alternative: Change port in docker-compose.yml
ports:
  - "8485:8484"  # Use 8485 on host instead
```

#### Missing Environment Variables

```bash
# Check if .env exists
ls -la .env

# If missing, create from template
cp .env.example .env

# Verify required variables
cat .env | grep GRIST_SESSION_SECRET

# If empty, generate secret
echo "GRIST_SESSION_SECRET=$(openssl rand -hex 32)" >> .env

# Restart services
docker-compose restart
```

### Container Performance Issues

[Table content - see original for details],
  (
    issue: "Container using excessive memory",
    solution: "Check with `docker stats`. May need to increase limits or optimize application. Check for memory leaks.",
    priority: "medium"
  ),
  (
    issue: "Container very slow to respond",
    solution: "Check host resources. Verify no I/O bottleneck. Check network connectivity. Review container logs.",
    priority: "medium"
  ),
))

*Detailed Solutions:*

#### High CPU Usage

```bash
# Check CPU usage
docker stats --no-stream grist_server

# View processes in container
docker top grist_server

# Check for CPU-intensive operations in logs
docker logs --tail=100 grist_server | grep -i "slow\|timeout"

# Set CPU limits
# docker-compose.yml:
deploy:
  resources:
    limits:
      cpus: '2.0'
```

#### High Memory Usage

```bash
# Check memory usage over time
watch -n 5 'docker stats --no-stream grist_server'

# Check memory details
docker stats --no-stream grist_server \
  --format "{{.MemUsage}} / {{.MemPerc}}"

# Restart container to free memory
docker-compose restart grist

# If problem persists, increase memory limit
# docker-compose.yml:
deploy:
  resources:
    limits:
      memory: 4G
```

## Grist-Specific Issues

### Cannot Access Grist UI

[Table content - see original for details],
  (
    issue: "Grist loads but shows error page",
    solution: "Check Grist logs: `docker-compose logs grist`. Common: database corruption, permission issues.",
    priority: "high"
  ),
  (
    issue: "'Connection refused' from Flutter app",
    solution: "Use correct URL: `http://grist:8484` inside Docker, `http://localhost:8484` from host.",
    priority: "high"
  ),
))

*Detailed Solutions:*

#### Grist Not Responding

```bash
# Step 1: Check if container is running
docker ps | grep grist

# If not running:
./docker-test.sh grist-start

# Step 2: Check logs for errors
docker-compose logs --tail=50 grist

# Step 3: Test connectivity
curl -v http://localhost:8484

# Step 4: Check firewall (Linux)
sudo ufw status
sudo iptables -L | grep 8484

# Step 5: Restart Grist
./docker-test.sh grist-restart
```

#### Grist Shows Error Page

```bash
# Check Grist logs for specific error
docker-compose logs grist | tail -50

# Common errors and solutions:

# Error: "Cannot read property 'id' of undefined"
# Solution: Database corruption, restore from backup

# Error: "EACCES: permission denied"
# Solution: Fix permissions
sudo chown -R 1000:1000 grist-module/grist-data/

# Error: "ENOSPC: no space left on device"
# Solution: Free disk space
df -h
docker system prune -a
```

#### Network Configuration Issues

```bash
# From host machine (browser, curl):
curl http://localhost:8484

# From Flutter container:
docker exec flutter_dev curl http://grist:8484

# Check Docker network
docker network inspect grist-network

# Verify Grist is on correct network
docker inspect grist_server \
  --format='{{range $net, $conf := .NetworkSettings.Networks}}{{$net}}{{end}}'

# Reconnect to network if needed
docker network disconnect grist-network grist_server
docker network connect grist-network grist_server
docker-compose restart grist
```

### Grist Data Issues

[Table content - see original for details],
  (
    issue: "Cannot save changes in Grist",
    solution: "Check permissions: `ls -la grist-module/grist-data/`. Fix with: `sudo chown -R $USER:$USER grist-module/grist-data/`",
    priority: "high"
  ),
  (
    issue: "Grist documents corrupted",
    solution: "Stop Grist. Restore from backup. Check disk for errors. Verify disk space available.",
    priority: "high"
  ),
))

*Detailed Solutions:*

#### Data Loss Prevention

```bash
# Check if data directory exists and has content
ls -la grist-module/grist-data/

# Verify volume mount
docker inspect grist_server | grep -A 10 Mounts

# Expected output should show:
# "Source": "/path/to/grist-module/grist-data"
# "Destination": "/persist"

# If mount is missing, check docker-compose.yml:
volumes:
  - ./grist-module/grist-data:/persist

# Recreate container with correct mount
docker-compose up -d --force-recreate grist
```

#### Permission Problems

```bash
# Check current permissions
ls -ld grist-module/grist-data/

# Fix owner (replace 1000 with your user ID)
sudo chown -R 1000:1000 grist-module/grist-data/

# Fix permissions
chmod -R 755 grist-module/grist-data/

# Verify Grist can write
docker exec grist_server touch /persist/test.txt
docker exec grist_server rm /persist/test.txt

# If still failing, check SELinux (RHEL/CentOS)
sudo chcon -Rt svirt_sandbox_file_t grist-module/grist-data/
```

#### Data Recovery

```bash
# Stop Grist
./docker-test.sh grist-stop

# List available backups
ls -lh grist-backup-*.tar.gz

# Restore from backup
tar -xzf grist-backup-20250110.tar.gz

# Verify data restored
ls -la grist-module/grist-data/

# Start Grist
./docker-test.sh grist-start

# Verify in UI
curl http://localhost:8484
```

## Flutter/Testing Issues

### Build Failures

[Table content - see original for details],
  (
    issue: "Flutter SDK download fails",
    solution: "Check internet connection. Try different mirror. Build with `--build-arg FLUTTER_VERSION=3.16.0`",
    priority: "medium"
  ),
  (
    issue: "'pub get' fails in Docker",
    solution: "Delete pub cache volume: `docker volume rm flutter_pub_cache`. Rebuild: `./docker-test.sh build`",
    priority: "medium"
  ),
))

*Detailed Solutions:*

#### Clean Build

```bash
# Remove old build cache
docker builder prune -a -f

# Remove old images
docker rmi $(docker images -q flutter_dev)

# Remove pub cache volume
docker volume rm flutter_pub_cache

# Clean rebuild
docker-compose build --no-cache --pull

# Verify build
./docker-test.sh build
```

### Test Failures

[Table content - see original for details],
  (
    issue: "Tests hang or timeout",
    solution: "Increase timeout in test. Check container resources. Review test logs for blocking operations.",
    priority: "low"
  ),
  (
    issue: "'flutter: command not found'",
    solution: "Flutter not in PATH. Rebuild container: `./docker-test.sh build`",
    priority: "high"
  ),
))

*Detailed Solutions:*

#### Test Environment Issues

```bash
# Verify Flutter installation
docker exec flutter_dev flutter --version

# Check pub dependencies
docker exec flutter_dev flutter pub get

# Run tests with verbose output
docker exec flutter_dev flutter test --reporter=expanded

# Check for test-specific errors
docker exec flutter_dev flutter test --verbose

# Clear test cache
docker exec flutter_dev flutter clean
docker exec flutter_dev flutter pub get
docker exec flutter_dev flutter test
```

## Docker System Issues

### Disk Space Issues

[Table content - see original for details],
  (
    issue: "Docker using too much disk space",
    solution: "Check: `docker system df -v`. Remove unused: `docker system prune -a`. Consider cleanup automation.",
    priority: "medium"
  ),
  (
    issue: "Grist data growing too large",
    solution: "Archive old documents. Export and delete unused data. Increase disk allocation.",
    priority: "medium"
  ),
))

*Detailed Solutions:*

#### Disk Space Recovery

```bash
# Check current usage
docker system df

# Detailed breakdown
docker system df -v

# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes (CAUTION!)
docker volume prune -f

# Remove unused networks
docker network prune -f

# Full cleanup (except running containers)
docker system prune -a --volumes -f

# Check host disk space
df -h

# Find large files
du -sh grist-module/grist-data/*
```

#### Prevent Disk Space Issues

```bash
# Set log rotation in docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"

# Schedule regular cleanup (cron)
# Add to crontab: crontab -e
# Run daily at 2 AM:
0 2 * * * docker system prune -f

# Monitor disk usage
watch -n 60 'df -h | grep -E "(Filesystem|/$)"'
```

### Docker Daemon Issues

[Table content - see original for details] or check Docker Desktop. Restart if needed.",
    priority: "high"
  ),
  (
    issue: "'permission denied' for Docker commands",
    solution: "Add user to docker group: `sudo usermod -aG docker $USER`. Log out and back in.",
    priority: "high"
  ),
  (
    issue: "Docker commands very slow",
    solution: "Restart Docker daemon. Check host resources. Prune old data. Check for stuck containers.",
    priority: "medium"
  ),
))

*Detailed Solutions:*

#### Docker Not Running

```bash
# Linux: Check Docker status
sudo systemctl status docker

# Linux: Start Docker
sudo systemctl start docker

# Linux: Enable on boot
sudo systemctl enable docker

# macOS/Windows: Open Docker Desktop
open -a Docker  # macOS

# Verify Docker is running
docker info
```

#### Permission Issues

```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER

# Log out and back in for group to take effect
# Or use:
newgrp docker

# Verify group membership
groups | grep docker

# Test Docker command
docker ps
```

## Network Issues

### Connectivity Problems

[Table content - see original for details],
  (
    issue: "Container cannot reach internet",
    solution: "Check Docker DNS: `docker exec container_name ping 8.8.8.8`. Check host network. Restart Docker.",
    priority: "high"
  ),
  (
    issue: "Cannot access container from host",
    solution: "Check port mapping: `docker port container_name`. Verify firewall not blocking. Check bind address.",
    priority: "medium"
  ),
))

*Detailed Solutions:*

#### Inter-Container Communication

```bash
# Check containers are on same network
docker network inspect grist-network | grep Name

# Expected output should show both:
# "Name": "grist_server"
# "Name": "flutter_dev"

# Test connectivity
docker exec flutter_dev ping -c 3 grist

# Test with curl
docker exec flutter_dev curl -I http://grist:8484

# If fails, reconnect containers
docker-compose down
docker-compose up -d
```

#### DNS Resolution Issues

```bash
# Test DNS inside container
docker exec grist_server nslookup google.com

# Check Docker DNS configuration
docker inspect grist_server | grep -A 3 Dns

# Test with different DNS
docker run --rm --dns 8.8.8.8 alpine ping -c 3 google.com

# Configure custom DNS in docker-compose.yml
services:
  grist:
    dns:
      - 8.8.8.8
      - 8.8.4.4
```

## Environment Configuration Issues

### .env File Problems

[Table content - see original for details],
  (
    issue: "Secrets exposed in logs",
    solution: "Never log environment variables. Use Docker secrets in production. Sanitize log output.",
    priority: "high"
  ),
  (
    issue: "'GRIST_SESSION_SECRET not set' error",
    solution: "Check .env exists and has GRIST_SESSION_SECRET. Generate with: `openssl rand -hex 32`",
    priority: "high"
  ),
))

*Detailed Solutions:*

#### .env File Debugging

```bash
# Check .env exists
ls -la .env

# View .env content (CAUTION: Contains secrets!)
cat .env

# Verify format (no spaces around =)
# CORRECT: VAR=value
# WRONG:   VAR = value

# Test variable loading
docker-compose config | grep GRIST_SESSION_SECRET

# If not showing, check .env location
# Must be in same directory as docker-compose.yml

# Restart services to apply changes
docker-compose restart
```

## Backup and Recovery Issues

### Backup Failures

[Table content - see original for details],
  (
    issue: "Cannot restore from backup",
    solution: "Verify backup integrity: `tar -tzf backup.tar.gz`. Check backup not corrupted. Verify correct paths.",
    priority: "high"
  ),
  (
    issue: "Backup too large or slow",
    solution: "Exclude temporary files. Use compression. Consider incremental backups. Archive old data.",
    priority: "low"
  ),
))

*Detailed Solutions:*

#### Verify Backup Integrity

```bash
# Test backup can be read
tar -tzf grist-backup-20250110.tar.gz | head

# Extract to temporary location
mkdir /tmp/backup-test
tar -xzf grist-backup-20250110.tar.gz -C /tmp/backup-test

# Verify contents
ls -la /tmp/backup-test/

# Compare sizes
du -sh grist-module/grist-data/
du -sh /tmp/backup-test/grist-module/grist-data/

# Clean up
rm -rf /tmp/backup-test
```

## Performance Optimization

### Slow Performance

[Table content - see original for details],
  (
    issue: "Slow I/O operations",
    solution: "Check disk performance: `iostat`. Use SSD if possible. Check for disk errors: `dmesg | grep error`",
    priority: "medium"
  ),
  (
    issue: "Network latency",
    solution: "Test with `ping`, `curl`. Check network driver. Consider host networking mode for testing.",
    priority: "low"
  ),
))

## Emergency Recovery Procedures

### Complete System Failure

If everything is broken:

```bash
# 1. Stop all services
docker-compose down

# 2. Backup current state (if possible)
tar -czf emergency-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  grist-module/grist-data/ .env

# 3. Remove all containers and images
docker system prune -a -f

# 4. Rebuild from scratch
./docker-test.sh build

# 5. Start services
./docker-test.sh start-all

# 6. Verify functionality
curl http://localhost:8484

# 7. Restore data if needed
tar -xzf grist-backup-YYYYMMDD.tar.gz
```

### Data Corruption Recovery

```bash
# 1. Stop Grist immediately
./docker-test.sh grist-stop

# 2. Backup corrupted data
mv grist-module/grist-data grist-module/grist-data.corrupted

# 3. Restore from latest good backup
tar -xzf grist-backup-20250109.tar.gz

# 4. Start Grist
./docker-test.sh grist-start

# 5. Verify in UI
curl http://localhost:8484

# 6. Test full functionality

# 7. Archive corrupted data for analysis
tar -czf corrupted-data-$(date +%Y%m%d).tar.gz \
  grist-module/grist-data.corrupted
```

## Getting Additional Help

### Information to Gather

When seeking help, collect:

```bash
# System information
docker version
docker-compose version
uname -a

# Container status
docker ps -a

# Recent logs (last 100 lines)
docker-compose logs --tail=100 > logs.txt

# Resource usage
docker stats --no-stream > stats.txt

# Docker system info
docker system df -v > disk-usage.txt

# Network configuration
docker network inspect grist-network > network.json

# Compress and share
tar -czf debug-info-$(date +%Y%m%d).tar.gz \
  logs.txt stats.txt disk-usage.txt network.json
```

### Support Channels

1. *Check Documentation*
   - README.md
   - DEVOPS_ENHANCEMENTS.md
   - This troubleshooting guide

2. *Search Issues*
   - GitHub Issues
   - Docker Forums
   - Stack Overflow

3. *Contact Support*
   - Create GitHub Issue
   - Include debug information
   - Describe steps to reproduce

---

> **Success**: **Prevention is Better than Cure**
>
> - Regular backups (daily minimum)
> - Monitor resource usage
> - Keep software updated
> - Document changes
> - Test in development first
> - Have rollback plan ready
