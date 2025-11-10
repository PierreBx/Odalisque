# Command Reference

Complete reference guide for all Docker, DevOps, and system administration commands used in FlutterGristAPI.

## Quick Reference Card

### Daily Commands

[Command table - see original for details],
  (
    command: "./docker-test.sh all",
    description: "Run tests and analysis",
    example: ""
  ),
  (
    command: "./docker-test.sh grist-logs",
    description: "View Grist logs",
    example: ""
  ),
  (
    command: "docker ps",
    description: "List running containers",
    example: ""
  ),
  (
    command: "docker-compose restart grist",
    description: "Restart Grist service",
    example: ""
  ),
))

### Emergency Commands

[Command table - see original for details],
  (
    command: "docker-compose logs -f grist",
    description: "Debug with live logs",
    example: ""
  ),
  (
    command: "docker stats",
    description: "Check resource usage",
    example: ""
  ),
  (
    command: "docker system df",
    description: "Check disk space",
    example: ""
  ),
))

## Helper Script Commands

The `docker-test.sh` script provides convenient wrappers for common operations.

### Grist Management

*Start Grist Server*

```bash
./docker-test.sh grist-start
```

- Starts Grist in detached mode
- Accessible at http://localhost:8484
- Data persisted in `grist-module/grist-data/`

*Stop Grist Server*

```bash
./docker-test.sh grist-stop
```

- Gracefully stops Grist container
- Preserves all data
- Container can be restarted

*Restart Grist Server*

```bash
./docker-test.sh grist-restart
```

- Stops and starts Grist
- Useful after configuration changes
- Applies new environment variables

*View Grist Logs*

```bash
./docker-test.sh grist-logs
```

- Follows logs in real-time
- Press Ctrl+C to exit
- Shows all Grist output

### Flutter Testing

*Run Unit Tests*

```bash
./docker-test.sh test
```

- Runs all Flutter unit tests
- Uses `flutter test --reporter expanded`
- Exit code 0 = success, non-zero = failure

*Run Code Analysis*

```bash
./docker-test.sh analyze
```

- Runs Flutter static analysis
- Checks for errors and warnings
- Uses `flutter analyze`

*Run All Tests*

```bash
./docker-test.sh all
```

- Runs analysis first, then tests
- Sequential execution
- Exits with failure if either fails

*Open Interactive Shell*

```bash
./docker-test.sh shell
```

- Opens bash shell in Flutter container
- Full access to Flutter SDK
- Manual test execution
- Type `exit` to leave

Example session:

```bash
./docker-test.sh shell

# Inside container:
flutter test
flutter analyze
flutter pub get
flutter doctor
exit
```

### System Management

*Start All Services*

```bash
./docker-test.sh start-all
```

- Starts Grist and all Flutter services
- Equivalent to `docker-compose up -d`
- Services run in background

*Stop All Services*

```bash
./docker-test.sh stop-all
```

- Stops all running services
- Preserves data and containers
- Clean shutdown

*Build Docker Images*

```bash
./docker-test.sh build
```

- Builds Flutter Docker image
- Downloads Flutter SDK
- Installs dependencies
- First build takes 5-10 minutes

*Clean Everything*

```bash
./docker-test.sh clean
```

> **Danger**: **DANGER: Data Loss**
>
> This command removes all containers and volumes, including Grist data!
>
> Always backup before running this command.

- Runs `docker-compose down -v`
- Runs `docker system prune -f`
- Deletes all data
- Use with extreme caution

## Docker Compose Commands

### Service Management

*Start Services*

```bash
# Start all services in background
docker-compose up -d

# Start specific service
docker-compose up -d grist

# Start with logs (foreground)
docker-compose up grist

# Start and rebuild
docker-compose up -d --build

# Force recreate containers
docker-compose up -d --force-recreate
```

*Stop Services*

```bash
# Stop all services (preserves containers)
docker-compose stop

# Stop specific service
docker-compose stop grist

# Stop with timeout (seconds)
docker-compose stop -t 30 grist
```

*Restart Services*

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart grist

# Restart with timeout
docker-compose restart -t 10 grist
```

*Remove Services*

```bash
# Stop and remove containers (preserves volumes)
docker-compose down

# Remove containers and volumes (DATA LOSS!)
docker-compose down -v

# Remove containers, volumes, and images
docker-compose down -v --rmi all

# Force remove
docker-compose down -v --remove-orphans
```

### Service Information

*List Services*

```bash
# List running services
docker-compose ps

# List all services (including stopped)
docker-compose ps -a

# Show only service names
docker-compose ps --services

# Filtered output
docker-compose ps grist
```

*Service Logs*

```bash
# View all logs
docker-compose logs

# Follow logs (real-time)
docker-compose logs -f

# Specific service logs
docker-compose logs -f grist

# Last N lines
docker-compose logs --tail=50 grist

# Logs with timestamps
docker-compose logs -t grist

# Logs since time
docker-compose logs --since 2025-01-10T10:00:00 grist
docker-compose logs --since 1h grist
docker-compose logs --since 30m grist

# Multiple services
docker-compose logs -f grist flutter
```

*Execute Commands in Services*

```bash
# Run command in service
docker-compose exec grist bash

# Run as specific user
docker-compose exec -u root grist bash

# Non-interactive command
docker-compose exec grist ls -la /persist

# Run new container
docker-compose run --rm flutter bash

# Run without dependencies
docker-compose run --no-deps flutter flutter test
```

### Building and Images

*Build Services*

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build flutter

# Build with no cache (clean build)
docker-compose build --no-cache

# Build with custom build args
docker-compose build --build-arg USER_ID=1000 flutter

# Parallel build
docker-compose build --parallel

# Pull latest base images first
docker-compose build --pull
```

*Pull Images*

```bash
# Pull all images
docker-compose pull

# Pull specific service
docker-compose pull grist

# Pull quietly
docker-compose pull -q
```

### Configuration Validation

*Validate Configuration*

```bash
# Validate docker-compose.yml syntax
docker-compose config

# Quiet validation (only errors)
docker-compose config -q

# Show resolved configuration
docker-compose config --services

# Show resolved volumes
docker-compose config --volumes
```

## Docker Commands

### Container Management

*List Containers*

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Custom format
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Filter containers
docker ps --filter "name=grist"
docker ps --filter "status=running"
docker ps --filter "expose=8484"

# Show container sizes
docker ps -s

# Show last N containers
docker ps -n 5
```

*Start/Stop Containers*

```bash
# Start container
docker start grist_server

# Stop container (graceful)
docker stop grist_server

# Stop container (forced, 5s timeout)
docker stop -t 5 grist_server

# Restart container
docker restart grist_server

# Pause container
docker pause grist_server

# Unpause container
docker unpause grist_server

# Kill container (immediate)
docker kill grist_server
```

*Remove Containers*

```bash
# Remove stopped container
docker rm grist_server

# Force remove running container
docker rm -f grist_server

# Remove all stopped containers
docker container prune

# Remove with filter
docker container prune --filter "until=24h"
```

*Container Information*

```bash
# Inspect container
docker inspect grist_server

# Show specific field
docker inspect grist_server --format='{{.State.Status}}'

# Show resource usage
docker stats grist_server

# Show processes
docker top grist_server

# Show port mappings
docker port grist_server

# Show logs
docker logs grist_server
docker logs -f grist_server
docker logs --tail=100 grist_server
```

*Execute Commands*

```bash
# Interactive shell
docker exec -it grist_server bash

# Run single command
docker exec grist_server ls -la /persist

# Run as specific user
docker exec -u root grist_server apt-get update

# Run with environment variable
docker exec -e DEBUG=true grist_server printenv
```

### Image Management

*List Images*

```bash
# List all images
docker images

# List with digests
docker images --digests

# List specific image
docker images gristlabs/grist

# Custom format
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Filter images
docker images --filter "dangling=true"
docker images --filter "before=gristlabs/grist:latest"
```

*Build Images*

```bash
# Build from Dockerfile
docker build -t myimage:tag .

# Build with no cache
docker build --no-cache -t myimage:tag .

# Build with build args
docker build --build-arg VERSION=1.0 -t myimage:tag .

# Build from specific Dockerfile
docker build -f Dockerfile.prod -t myimage:tag .

# Build and squash layers
docker build --squash -t myimage:tag .
```

*Pull/Push Images*

```bash
# Pull image
docker pull gristlabs/grist:latest

# Pull specific version
docker pull gristlabs/grist:1.0.0

# Push image (requires authentication)
docker push myrepo/myimage:tag

# Pull all tags
docker pull -a gristlabs/grist
```

*Remove Images*

```bash
# Remove image
docker rmi gristlabs/grist:latest

# Force remove
docker rmi -f gristlabs/grist:latest

# Remove all dangling images
docker image prune

# Remove all unused images
docker image prune -a

# Remove images older than 24h
docker image prune -a --filter "until=24h"
```

*Image Information*

```bash
# Inspect image
docker inspect gristlabs/grist:latest

# Show image history
docker history gristlabs/grist:latest

# Show image layers
docker history --no-trunc gristlabs/grist:latest
```

### Volume Management

*List Volumes*

```bash
# List all volumes
docker volume ls

# Filter volumes
docker volume ls --filter "dangling=true"
docker volume ls --filter "name=flutter"
```

*Create Volumes*

```bash
# Create volume
docker volume create myvolume

# Create with driver
docker volume create --driver local myvolume

# Create with options
docker volume create --opt type=tmpfs myvolume
```

*Inspect Volumes*

```bash
# Inspect volume
docker volume inspect flutter_pub_cache

# Show mount point
docker volume inspect flutter_pub_cache \
  --format='{{.Mountpoint}}'
```

*Remove Volumes*

```bash
# Remove volume
docker volume rm flutter_pub_cache

# Remove all unused volumes
docker volume prune

# Remove with filter
docker volume prune --filter "label=temporary"
```

*Backup/Restore Volumes*

```bash
# Backup volume to tar
docker run --rm \
  -v flutter_pub_cache:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz -C /source .

# Restore volume from tar
docker run --rm \
  -v flutter_pub_cache:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/volume-backup.tar.gz -C /target
```

### Network Management

*List Networks*

```bash
# List all networks
docker network ls

# Custom format
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# Filter networks
docker network ls --filter "driver=bridge"
```

*Create Networks*

```bash
# Create bridge network
docker network create mynetwork

# Create with subnet
docker network create --subnet=172.20.0.0/16 mynetwork

# Create with gateway
docker network create --gateway=172.20.0.1 mynetwork
```

*Inspect Networks*

```bash
# Inspect network
docker network inspect grist-network

# Show connected containers
docker network inspect grist-network \
  --format='{{range .Containers}}{{.Name}} {{end}}'
```

*Connect/Disconnect*

```bash
# Connect container to network
docker network connect grist-network mycontainer

# Disconnect container
docker network disconnect grist-network mycontainer
```

*Remove Networks*

```bash
# Remove network
docker network rm mynetwork

# Remove all unused networks
docker network prune
```

### System Commands

*System Information*

```bash
# Show Docker version
docker version

# Show system info
docker info

# Show disk usage
docker system df

# Detailed disk usage
docker system df -v
```

*System Cleanup*

```bash
# Remove unused data
docker system prune

# Remove all unused data (including volumes)
docker system prune -a --volumes

# Remove with filter
docker system prune --filter "until=24h"

# Show what would be removed (dry run)
docker system prune --dry-run
```

*Events Monitoring*

```bash
# Watch all events
docker events

# Filter events
docker events --filter "type=container"
docker events --filter "event=start"
docker events --filter "container=grist_server"

# Since/Until time
docker events --since 1h
docker events --until 2025-01-10T12:00:00
```

## Backup and Restore Commands

### Grist Data Backup

*Create Backup*

```bash
# Simple tar backup
tar -czf grist-backup-$(date +%Y%m%d).tar.gz \
  grist-module/grist-data/

# Backup with timestamp
tar -czf grist-backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  grist-module/grist-data/

# Backup with verification
tar -czvf grist-backup.tar.gz grist-module/grist-data/

# Exclude specific files
tar -czf grist-backup.tar.gz \
  --exclude='*.tmp' \
  grist-module/grist-data/
```

*Encrypted Backup*

```bash
# GPG encryption
tar -czf - grist-module/grist-data/ | \
  gpg --symmetric --cipher-algo AES256 \
  -o grist-backup-$(date +%Y%m%d).tar.gz.gpg

# OpenSSL encryption
tar -czf - grist-module/grist-data/ | \
  openssl enc -aes-256-cbc -salt \
  -out grist-backup-$(date +%Y%m%d).tar.gz.enc
```

*Restore Backup*

```bash
# Restore from tar
tar -xzf grist-backup-20250110.tar.gz

# Restore from GPG
gpg --decrypt grist-backup-20250110.tar.gz.gpg | tar -xzf -

# Restore from OpenSSL
openssl enc -aes-256-cbc -d \
  -in grist-backup-20250110.tar.gz.enc | tar -xzf -

# Restore to specific location
tar -xzf grist-backup-20250110.tar.gz -C /path/to/restore/
```

### Volume Backup

```bash
# Backup Docker volume
docker run --rm \
  -v flutter_pub_cache:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/volume-backup.tar.gz -C /data .

# Restore Docker volume
docker run --rm \
  -v flutter_pub_cache:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/volume-backup.tar.gz"
```

## Monitoring Commands

### Resource Monitoring

```bash
# Real-time stats
docker stats

# Single snapshot
docker stats --no-stream

# Specific container
docker stats grist_server

# Custom format
docker stats --format \
  "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# CPU usage only
docker stats --no-stream --format "{{.CPUPerc}}"
```

### Health Checks

```bash
# Check container health
docker inspect grist_server \
  --format='{{.State.Health.Status}}'

# View health check logs
docker inspect grist_server \
  --format='{{range .State.Health.Log}}{{.Output}}{{end}}'

# Check restart count
docker inspect grist_server \
  --format='{{.RestartCount}}'
```

### Log Analysis

```bash
# Error logs only
docker logs grist_server 2>&1 | grep -i error

# Count errors
docker logs grist_server 2>&1 | grep -c error

# Unique errors
docker logs grist_server 2>&1 | grep error | sort -u

# Logs with context (5 lines before/after)
docker logs grist_server 2>&1 | grep -B 5 -A 5 error
```

## Git Commands for DevOps

### Repository Management

```bash
# Clone repository
git clone https://github.com/yourusername/flutterGristAPI.git

# Update repository
git pull origin main

# Check status
git status

# View changes
git diff

# View commit history
git log --oneline --graph --all
```

### Branch Management

```bash
# Create branch
git checkout -b feature/my-feature

# Switch branch
git checkout main

# List branches
git branch -a

# Delete branch
git branch -d feature/my-feature

# Push branch
git push origin feature/my-feature
```

### Stashing

```bash
# Stash changes
git stash

# List stashes
git stash list

# Apply stash
git stash apply

# Pop stash
git stash pop

# Clear stash
git stash clear
```

## Troubleshooting Commands

### Debug Container Issues

```bash
# Check container logs
docker logs --tail=100 grist_server

# Check container processes
docker top grist_server

# Check container resources
docker stats --no-stream grist_server

# Inspect container
docker inspect grist_server | jq .

# Check exit code
docker inspect grist_server --format='{{.State.ExitCode}}'
```

### Network Debugging

```bash
# Test connectivity
docker exec grist_server ping -c 3 google.com

# Check DNS
docker exec grist_server nslookup google.com

# Check open ports
docker exec grist_server netstat -tulpn

# Curl test
docker exec grist_server curl -I http://localhost:8484
```

### Permission Issues

```bash
# Check file permissions
ls -la grist-module/grist-data/

# Fix permissions
sudo chown -R $USER:$USER grist-module/grist-data/
chmod -R 755 grist-module/grist-data/

# Check container user
docker exec grist_server whoami
docker exec grist_server id
```

## Useful Aliases

Add to your `.bashrc` or `.zshrc`:

```bash
# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dlog='docker logs -f'
alias dex='docker exec -it'
alias din='docker inspect'
alias dimg='docker images'
alias dnet='docker network ls'
alias dvol='docker volume ls'

# Docker Compose aliases
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dcrestart='docker-compose restart'
alias dclog='docker-compose logs -f'
alias dcps='docker-compose ps'

# Project-specific aliases
alias grist-start='./docker-test.sh grist-start'
alias grist-stop='./docker-test.sh grist-stop'
alias grist-logs='./docker-test.sh grist-logs'
alias flutter-test='./docker-test.sh all'
```

Reload shell:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

---

> **Note**: **Pro Tip: Command History**
>
> Use `history | grep docker` to find previously used Docker commands quickly.
>
> Press Ctrl+R to search command history interactively.
