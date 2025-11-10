## Docker Basics

  Docker is a containerization platform that packages applications and their dependencies into isolated containers.

### Core Concepts

#### Containers
  Lightweight, standalone packages that include:
  - Application code
  - Runtime environment
  - System libraries
  - Dependencies

  Containers are:
  - *Isolated*: Run independently without affecting the host
  - *Portable*: Run consistently across different environments
  - *Efficient*: Share the host OS kernel, lighter than VMs

#### Images
  Templates used to create containers:
  - Built from a `Dockerfile`
  - Stored in registries (Docker Hub, private registries)
  - Versioned with tags (e.g., `gristlabs/grist:latest`)

#### Volumes
  Persistent storage for containers:
  - Data survives container restarts and deletions
  - Can be shared between containers
  - Backed up independently

#### Networks
  Communication channels between containers:
  - Containers can communicate by name
  - Isolated from external networks by default
  - Can expose ports to the host

### Docker Commands Reference

  [Command table - see original for details],
    (
      command: "docker images",
      description: "List available images",
      example: "docker images"
    ),
    (
      command: "docker run",
      description: "Create and start a container",
      example: "docker run -d -p 8484:8484 gristlabs/grist"
    ),
    (
      command: "docker stop",
      description: "Stop a running container",
      example: "docker stop container_name"
    ),
    (
      command: "docker logs",
      description: "View container logs",
      example: "docker logs -f container_name"
    ),
    (
      command: "docker exec",
      description: "Execute command in container",
      example: "docker exec -it container_name bash"
    ),
    (
      command: "docker volume ls",
      description: "List volumes",
      example: "docker volume ls"
    ),
    (
      command: "docker network ls",
      description: "List networks",
      example: "docker network ls"
    ),
  ))

### Docker Compose

  Docker Compose is a tool for defining and running multi-container applications using a YAML file.

#### Basic Structure

  ```yaml
  version: '3.8'

  services:
    service_name:
      image: image_name:tag
      ports:
        - "host_port:container_port"
      volumes:
        - host_path:container_path
      environment:
        - VAR_NAME=value
      depends_on:
        - other_service

  volumes:
    volume_name:

  networks:
    network_name:
  ```

#### Docker Compose Commands

  [Command table - see original for details],
    (
      command: "docker-compose down",
      description: "Stop and remove all services",
      example: "docker-compose down -v"
    ),
    (
      command: "docker-compose ps",
      description: "List running services",
      example: "docker-compose ps"
    ),
    (
      command: "docker-compose logs",
      description: "View service logs",
      example: "docker-compose logs -f service_name"
    ),
    (
      command: "docker-compose build",
      description: "Build service images",
      example: "docker-compose build --no-cache"
    ),
    (
      command: "docker-compose restart",
      description: "Restart services",
      example: "docker-compose restart service_name"
    ),
  ))

### FlutterGristAPI Docker Setup

  The FlutterGristAPI project uses Docker Compose to orchestrate multiple services:

  ```yaml
  version: '3.8'

  services:
    grist:
      image: gristlabs/grist
      container_name: fluttergrist-grist
      ports:
        - "8484:8484"
      volumes:
        - ./grist-module/grist-data:/persist
      environment:
        - GRIST_SESSION_SECRET=${GRIST_SESSION_SECRET}
        - GRIST_SINGLE_ORG=fluttergrist
      restart: unless-stopped

    flutter-app:
      build:
        context: ./flutter-module
        dockerfile: Dockerfile
      container_name: fluttergrist-app
      ports:
        - "8080:8080"
      depends_on:
        - grist
      environment:
        - GRIST_URL=http://grist:8484
        - GRIST_API_KEY=${GRIST_API_KEY}
      restart: unless-stopped

  volumes:
    grist-data:

  networks:
    default:
      name: fluttergrist-network
  ```

### Best Practices

#### Security
  - Never include secrets in Dockerfiles or docker-compose.yml
  - Use environment variables or Docker secrets
  - Run containers as non-root users when possible
  - Keep images updated to patch vulnerabilities

#### Performance
  - Use `.dockerignore` to exclude unnecessary files
  - Leverage build caching with proper layer ordering
  - Use multi-stage builds to reduce image size
  - Clean up unused images and containers regularly

#### Data Management
  - Always use named volumes for important data
  - Back up volumes regularly
  - Mount configuration files as read-only when possible
  - Use volume drivers for production storage

#### Logging
  - Configure log rotation to prevent disk fill
  - Use structured logging (JSON format)
  - Centralize logs for multi-container apps
  - Set appropriate log levels (debug, info, warn, error)

### Troubleshooting

  [Table content - see original for details],
    (
      issue: "Cannot connect to container",
      solution: "Verify port mapping with `docker ps`. Check firewall rules and network configuration.",
      priority: "high"
    ),
    (
      issue: "Data lost after restart",
      solution: "Ensure volumes are properly configured. Check volume mounts with `docker volume inspect`.",
      priority: "high"
    ),
    (
      issue: "Out of disk space",
      solution: "Clean up with `docker system prune -a --volumes`. Review and remove unused images.",
      priority: "medium"
    ),
    (
      issue: "Slow build times",
      solution: "Optimize Dockerfile layer caching. Use `.dockerignore`. Consider multi-stage builds.",
      priority: "low"
    ),
  ))

## Docker Compose File Reference

### Service Configuration Options

  ```yaml
  services:
    service_name:
      # Image to use
      image: image_name:tag

      # Build from Dockerfile
      build:
        context: ./path
        dockerfile: Dockerfile
        args:
          - BUILD_ARG=value

      # Container name
      container_name: custom_name

      # Port mapping
      ports:
        - "host:container"
        - "8080:80"

      # Volume mounting
      volumes:
        - ./host/path:/container/path
        - named_volume:/data

      # Environment variables
      environment:
        - VAR_NAME=value
        - OTHER_VAR=${HOST_ENV_VAR}

      # Environment file
      env_file:
        - .env

      # Networking
      networks:
        - network_name

      # Dependencies
      depends_on:
        - other_service

      # Restart policy
      restart: unless-stopped  # or always, on-failure, no

      # Resource limits
      deploy:
        resources:
          limits:
            cpus: '0.5'
            memory: 512M

      # Health check
      healthcheck:
        test: ["CMD", "curl", "-f", "http://localhost"]
        interval: 30s
        timeout: 10s
        retries: 3
  ```
