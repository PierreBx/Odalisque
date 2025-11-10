# Docker Setup and Configuration

This chapter provides comprehensive documentation for the Docker infrastructure powering FlutterGristAPI.

# FlutterGristAPI Docker Architecture

## Overview

The FlutterGristAPI project uses Docker Compose to orchestrate multiple services in an isolated, reproducible environment.

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────┐
│                    Docker Host                             │
│                                                            │
│  ┌──────────────────┐        ┌──────────────────┐        │
│  │  Grist Service   │◄──────►│ Flutter Service  │        │
│  │  Port: 8484      │  HTTP  │  Dev/Test/Shell  │        │
│  │  Image: gristlabs│        │  Custom Image    │        │
│  └────────┬─────────┘        └────────┬─────────┘        │
│           │                           │                   │
│           │  ┌────────────────────────┘                   │
│           │  │                                            │
│  ┌────────▼──▼──────────────────────────────┐            │
│  │     Docker Network: grist-network         │            │
│  │            Driver: bridge                 │            │
│  └───────────────────────────────────────────┘            │
│                                                            │
│  ┌─────────────────────────────────────────────┐          │
│  │            Persistent Volumes                │          │
│  │  • ./grist-module/grist-data:/persist       │          │
│  │  • ./flutter-module:/app (live mount)       │          │
│  │  • flutter_pub_cache (named volume)         │          │
│  └─────────────────────────────────────────────┘          │
│                                                            │
│  Host Access:                                             │
│  • http://localhost:8484 → Grist Web UI                   │
└────────────────────────────────────────────────────────────┘
```

## docker-compose.yml Analysis

The complete service configuration:

```yaml
version: '3.8'

services:
  # Grist service - self-hosted spreadsheet database
  grist:
    image: gristlabs/grist:latest
    container_name: grist_server
    ports:
      - "8484:8484"
    volumes:
      - ./grist-module/grist-data:/persist
    environment:
      - GRIST_SESSION_SECRET=${GRIST_SESSION_SECRET}
      - GRIST_SINGLE_ORG=docs
      - APP_HOME_URL=${GRIST_APP_HOME_URL:-http://localhost:8484}
      - GRIST_SANDBOX_FLAVOR=unsandboxed
    restart: unless-stopped
    networks:
      - grist-network

  # Flutter development environment
  flutter:
    build:
      context: ./flutter-module
      dockerfile: Dockerfile
    container_name: flutter_dev
    volumes:
      - ./flutter-module:/app
      - flutter_pub_cache:/home/flutterdev/.pub-cache
    working_dir: /app
    stdin_open: true
    tty: true
    command: /bin/bash
    networks:
      - grist-network

  # Flutter test runner
  flutter-test:
    build:
      context: ./flutter-module
      dockerfile: Dockerfile
    container_name: flutter_test
    volumes:
      - ./flutter-module:/app
      - flutter_pub_cache:/home/flutterdev/.pub-cache
    working_dir: /app
    command: flutter test --reporter expanded
    networks:
      - grist-network

  # Flutter analyzer
  flutter-analyze:
    build:
      context: ./flutter-module
      dockerfile: Dockerfile
    container_name: flutter_analyze
    volumes:
      - ./flutter-module:/app
      - flutter_pub_cache:/home/flutterdev/.pub-cache
    working_dir: /app
    command: flutter analyze
    networks:
      - grist-network

volumes:
  flutter_pub_cache:

networks:
  grist-network:
    driver: bridge
```

## Service Breakdown

### Grist Service

*Purpose:* Self-hosted spreadsheet database server

*Configuration Details:*

| Parameter | Description |
| --- | --- |
| image | Uses official `gristlabs/grist:latest` from Docker Hub |
| container_name | Fixed name: `grist_server` for easy reference |
| ports | Maps host port 8484 to container port 8484 |
| volumes | Mounts `./grist-module/grist-data` to `/persist` for data persistence |
| restart | unless-stopped` - auto-restart except when manually stopped |

*Environment Variables:*

- `GRIST_SESSION_SECRET`: Encryption key for session cookies (from `.env`)
- `GRIST_SINGLE_ORG`: Organization name (fixed to "docs")
- `APP_HOME_URL`: Public URL for Grist instance
- `GRIST_SANDBOX_FLAVOR`: Security sandboxing mode (unsandboxed for dev)

> **Warning**: **Production Note**
>
> For production deployments:
> - Use `GRIST_SANDBOX_FLAVOR=gvisor` for better security
> - Set a strong, unique `GRIST_SESSION_SECRET`
> - Configure `APP_HOME_URL` to your actual domain

### Flutter Services

*Three variants for different purposes:*

#### 1. flutter (Interactive Development)

```yaml
flutter:
  command: /bin/bash
  stdin_open: true
  tty: true
```

- Interactive shell for manual testing
- Access via: `./docker-test.sh shell`
- Persistent session (keeps running)

#### 2. flutter-test (Automated Testing)

```yaml
flutter-test:
  command: flutter test --reporter expanded
```

- Runs unit tests automatically
- Exits after completion
- Used by: `./docker-test.sh test`

#### 3. flutter-analyze (Static Analysis)

```yaml
flutter-analyze:
  command: flutter analyze
```

- Runs Flutter static analysis
- Checks for code issues
- Used by: `./docker-test.sh analyze`

## Network Configuration

### grist-network (Bridge Network)

```yaml
networks:
  grist-network:
    driver: bridge
```

*Purpose:* Enables inter-container communication

*Features:*
- Containers can reach each other by service name
- Isolated from other Docker networks
- DNS resolution built-in
- Port mapping for host access

*Example Usage:*

```bash
# Inside flutter container, access Grist:
curl http://grist:8484/api/...

# From host machine:
curl http://localhost:8484/api/...
```

### Network Inspection

```bash
# View network details
docker network inspect grist-network

# List connected containers
docker network inspect grist-network \
  --format '{{range .Containers}}{{.Name}} {{end}}'

# Test connectivity between containers
docker exec flutter_dev ping grist
```

## Volume Management

### Volume Types

#### 1. Bind Mount (Host Directory)

```yaml
volumes:
  - ./grist-module/grist-data:/persist
  - ./flutter-module:/app
```

*Characteristics:*
- Maps host directory to container path
- Changes sync in real-time
- Persists after container removal
- Visible on host filesystem

*Use Cases:*
- Grist data persistence
- Live code editing
- Configuration files

#### 2. Named Volume (Docker-Managed)

```yaml
volumes:
  flutter_pub_cache:
```

*Characteristics:*
- Managed by Docker
- Not directly accessible on host
- Better performance on macOS/Windows
- Survives container removal

*Use Cases:*
- Dependency caches
- Temporary storage
- Performance-critical data

### Volume Operations

```bash
# List all volumes
docker volume ls

# Inspect flutter_pub_cache
docker volume inspect flutter_pub_cache

# View volume contents
docker run --rm -v flutter_pub_cache:/data alpine ls -la /data

# Backup volume
docker run --rm \
  -v flutter_pub_cache:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/pub-cache-backup.tar.gz -C /source .

# Restore volume
docker run --rm \
  -v flutter_pub_cache:/target \
  -v $(pwd):/backup \
  alpine tar xzf /backup/pub-cache-backup.tar.gz -C /target

# Remove volume (DANGER!)
docker volume rm flutter_pub_cache
```

> **Danger**: **Data Loss Warning**
>
> Removing volumes with `docker volume rm` or `docker-compose down -v` permanently deletes data. Always backup first!

### Grist Data Directory

```
grist-module/grist-data/
├── README.md              # Documentation (committed)
├── landing.grist          # Database files (gitignored)
├── orgs/                  # Organization data
└── [other .grist files]   # User documents
```

*Important Operations:*

```bash
# Check data size
du -sh grist-module/grist-data/

# Backup Grist data
tar -czf grist-backup-$(date +%Y%m%d).tar.gz \
  grist-module/grist-data/

# Restore from backup
tar -xzf grist-backup-20250110.tar.gz

# Set correct permissions (if needed)
chown -R $USER:$USER grist-module/grist-data/
```

## Environment Variable Management

### .env File Structure

```bash
# Required
GRIST_SESSION_SECRET=<64-character-hex-string>

# Optional with defaults
GRIST_APP_HOME_URL=http://localhost:8484
USER_ID=1000
GROUP_ID=1000
```

### Variable Precedence

1. Shell environment variables (highest priority)
2. `.env` file variables
3. Default values in docker-compose.yml (lowest priority)

*Example:*

```yaml
environment:
  - GRIST_SESSION_SECRET=${GRIST_SESSION_SECRET:-default-value}
                                                  └── fallback if not set
```

### Security Best Practices

> **Danger**: **Environment Security**
>
> - Never commit `.env` to version control
> - Use different secrets for dev/staging/production
> - Rotate secrets regularly
> - Use strong random values (32+ bytes)
> - Restrict file permissions: `chmod 600 .env`

*Generate secure secrets:*

```bash
# 256-bit random hex (recommended)
openssl rand -hex 32

# Base64-encoded random bytes
openssl rand -base64 32

# Using Python
python3 -c "import secrets; print(secrets.token_hex(32))"
```

## Container Lifecycle Management

### Starting Services

```bash
# Start Grist only
docker-compose up -d grist

# Start all services
docker-compose up -d

# Start with rebuild
docker-compose up -d --build

# Start and view logs
docker-compose up grist  # No -d flag for logs
```

### Stopping Services

```bash
# Stop all services (preserves data)
docker-compose stop

# Stop specific service
docker-compose stop grist

# Stop and remove containers (preserves volumes)
docker-compose down

# Stop, remove containers AND volumes (DANGER!)
docker-compose down -v
```

> **Warning**: **Data Preservation**
>
> - `docker-compose stop`: Stops containers, keeps everything
> - `docker-compose down`: Removes containers, keeps volumes
> - `docker-compose down -v`: Removes containers AND volumes (data loss!)
>
> Always use `stop` or `down` (without `-v`) for normal operations.

### Restarting Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart grist

# Restart with new configuration
docker-compose down && docker-compose up -d
```

### Viewing Service Status

```bash
# List running services
docker-compose ps

# Detailed service info
docker-compose ps -a  # Show all (including stopped)

# View resource usage
docker stats

# View specific container stats
docker stats grist_server
```

## Log Management

### Viewing Logs

```bash
# All services, follow mode
docker-compose logs -f

# Specific service
docker-compose logs -f grist

# Last 50 lines
docker-compose logs --tail=50 grist

# Timestamp prefixes
docker-compose logs -t grist

# Since specific time
docker-compose logs --since 2025-01-10T10:00:00 grist
```

### Log Configuration

Docker Compose log driver configuration:

```yaml
services:
  grist:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

This configuration:
- Uses JSON file driver (default)
- Limits log files to 10 MB each
- Keeps maximum 3 log files
- Total max size: 30 MB per service

### Log Rotation

```bash
# View log file locations
docker inspect grist_server \
  --format='{{.LogPath}}'

# Manually rotate logs
docker-compose restart grist  # Triggers rotation

# Clear all logs for a container (CAUTION!)
truncate -s 0 $(docker inspect grist_server \
  --format='{{.LogPath}}')
```

## Building Custom Images

### Flutter Dockerfile

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    ca-certificates gnupg

# Install Flutter SDK
ENV FLUTTER_VERSION=3.16.0
ENV FLUTTER_ROOT=/opt/flutter
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git ${FLUTTER_ROOT}

# Add Flutter to PATH
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"

# Pre-download dependencies
RUN flutter precache
RUN flutter doctor

# Create non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} flutterdev && \
    useradd -m -u ${USER_ID} -g flutterdev flutterdev

USER flutterdev
WORKDIR /app

CMD ["/bin/bash"]
```

### Building Images

```bash
# Build all services
docker-compose build

# Build specific service
docker-compose build flutter

# Build with no cache (clean build)
docker-compose build --no-cache

# Build with custom build args
docker-compose build --build-arg USER_ID=$(id -u) flutter
```

### Image Management

```bash
# List images
docker images

# Remove unused images
docker image prune

# Remove all unused images
docker image prune -a

# View image layers
docker history flutter_dev

# Check image size
docker images flutter_dev --format "{{.Size}}"
```

## Performance Optimization

### Build Performance

*Layer Caching:*

```dockerfile
# ✓ Good: Dependencies cached separately
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .

# ✗ Bad: Everything rebuilds on code change
COPY . .
RUN flutter pub get
```

*Multi-stage Builds:*

```dockerfile
# Build stage
FROM flutter-sdk AS builder
COPY . /app
RUN flutter build web

# Runtime stage
FROM nginx:alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
```

### Runtime Performance

*Resource Limits:*

```yaml
services:
  grist:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

*Volume Performance:*

- Use named volumes for better performance on macOS/Windows
- Avoid bind mounts for large dependency directories
- Use `:delegated` or `:cached` on macOS for better sync performance

```yaml
volumes:
  - ./code:/app:delegated  # Faster on macOS
```

## Health Checks

### Adding Health Checks

```yaml
services:
  grist:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8484/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Monitoring Health

```bash
# Check health status
docker ps --filter "name=grist_server" \
  --format "table {{.Names}}\t{{.Status}}"

# Detailed health info
docker inspect grist_server \
  --format='{{.State.Health.Status}}'

# View health check logs
docker inspect grist_server \
  --format='{{range .State.Health.Log}}{{.Output}}{{end}}'
```

## Advanced Networking

### Multiple Networks

```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

services:
  grist:
    networks:
      - backend

  flutter:
    networks:
      - frontend
      - backend
```

### Custom Network Configuration

```yaml
networks:
  grist-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
          gateway: 172.28.0.1
```

### Port Mapping

```yaml
ports:
  # host:container
  - "8484:8484"           # Standard mapping
  - "127.0.0.1:8484:8484" # Bind to localhost only
  - "8484-8486:8484"      # Range mapping
```

---

## Helper Script: docker-test.sh

### Script Analysis

The `docker-test.sh` script provides convenient wrappers around Docker Compose commands:

*Key Features:*
- Colored output for better readability
- Error checking and validation
- Simplified command syntax
- Automatic exit code handling

### Available Commands

[Command table - see original for details],
  (
    command: "./docker-test.sh grist-stop",
    description: "Stop Grist server",
    example: "docker-compose stop grist"
  ),
  (
    command: "./docker-test.sh grist-restart",
    description: "Restart Grist server",
    example: "docker-compose restart grist"
  ),
  (
    command: "./docker-test.sh grist-logs",
    description: "Follow Grist server logs",
    example: "docker-compose logs -f grist"
  ),
  (
    command: "./docker-test.sh test",
    description: "Run Flutter unit tests",
    example: "docker-compose run --rm flutter-test"
  ),
  (
    command: "./docker-test.sh analyze",
    description: "Run Flutter code analysis",
    example: "docker-compose run --rm flutter-analyze"
  ),
  (
    command: "./docker-test.sh shell",
    description: "Open interactive Flutter shell",
    example: "docker-compose run --rm flutter /bin/bash"
  ),
  (
    command: "./docker-test.sh all",
    description: "Run analysis and tests",
    example: "Sequential: analyze then test"
  ),
  (
    command: "./docker-test.sh start-all",
    description: "Start all services",
    example: "docker-compose up -d"
  ),
  (
    command: "./docker-test.sh stop-all",
    description: "Stop all services",
    example: "docker-compose stop"
  ),
  (
    command: "./docker-test.sh build",
    description: "Build Docker images",
    example: "docker-compose build"
  ),
  (
    command: "./docker-test.sh clean",
    description: "Remove containers and volumes",
    example: "docker-compose down -v && docker system prune -f"
  ),
))

## Troubleshooting Docker Issues

### Container Won't Start

```bash
# Check logs for errors
docker-compose logs grist

# Inspect container configuration
docker inspect grist_server

# Check port availability
lsof -i :8484  # macOS/Linux
netstat -ano | findstr :8484  # Windows
```

### Volume Permission Issues

```bash
# Fix permissions for bind mounts
sudo chown -R $USER:$USER grist-module/grist-data/

# Use USER_ID and GROUP_ID for custom user mapping
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
docker-compose up -d
```

### Network Connectivity Issues

```bash
# Test container network
docker exec flutter_dev ping grist

# Inspect network
docker network inspect grist-network

# Recreate network
docker-compose down
docker network rm grist-network
docker-compose up -d
```

### Disk Space Issues

```bash
# Check Docker disk usage
docker system df

# Clean up unused resources
docker system prune -a --volumes

# Remove specific images
docker rmi $(docker images -q -f "dangling=true")
```

> **Note**: For more troubleshooting guidance, see `troubleshooting.typ`
