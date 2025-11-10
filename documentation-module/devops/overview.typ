// DevOps Overview - FlutterGristAPI
// Role description, responsibilities, prerequisites, and key concepts

#import "../common/styles.typ": *

= DevOps Role Overview

This documentation is designed for DevOps engineers, system administrators, and infrastructure specialists responsible for deploying, managing, and maintaining the FlutterGristAPI infrastructure.

== Role Description

As a DevOps engineer for FlutterGristAPI, you are responsible for:

- Managing containerized infrastructure using Docker and Docker Compose
- Deploying and maintaining the Grist database server
- Ensuring high availability and performance of the application
- Implementing security best practices and SSL/TLS encryption
- Monitoring system health and performance metrics
- Managing backups and disaster recovery procedures
- Troubleshooting infrastructure and deployment issues
- Automating deployment and operational tasks

== Target Audience

This guide is for personnel with:

- Experience with Linux system administration
- Understanding of containerization concepts (Docker)
- Familiarity with networking, DNS, and SSL/TLS
- Knowledge of command-line tools and scripting
- Understanding of CI/CD principles

#info_box(type: "info")[
  **Not a DevOps Expert?**

  If you're new to DevOps or containerization, we recommend starting with the Docker fundamentals section in the *docker-setup.typ* chapter.
]

== Key Responsibilities

=== 1. Infrastructure Management

*Primary Tasks:*
- Deploy and configure Docker containers
- Manage Docker networks and volumes
- Configure environment variables and secrets
- Scale services based on demand
- Monitor resource usage (CPU, memory, disk, network)

*Tools Used:*
- Docker & Docker Compose
- Helper script: `docker-test.sh`
- System monitoring tools

=== 2. Security Management

*Primary Tasks:*
- Implement SSL/TLS certificates (Let's Encrypt)
- Manage secrets and sensitive data
- Configure firewall rules and network security
- Scan for security vulnerabilities
- Apply security patches and updates
- Implement HTTPS redirection and security headers

*Tools Used:*
- Gitleaks for secrets scanning
- Let's Encrypt / Certbot for SSL certificates
- Nginx for reverse proxy and SSL termination

=== 3. Backup & Recovery

*Primary Tasks:*
- Schedule automated backups (daily, weekly, monthly)
- Verify backup integrity with checksums
- Test restoration procedures
- Manage backup retention policies
- Archive critical data off-site

*What's Backed Up:*
- Grist database data (`grist-data/`)
- Application configuration files
- Nginx configuration
- SSL certificates

=== 4. Monitoring & Logging

*Primary Tasks:*
- Monitor service health and availability
- Analyze logs for errors and warnings
- Set up alerts for critical issues
- Track performance metrics
- Generate operational reports

*Key Metrics:*
- Container status and uptime
- Resource utilization
- API response times
- Error rates and types
- Disk space usage

=== 5. Deployment & CI/CD

*Primary Tasks:*
- Build and deploy Docker images
- Run automated tests in CI pipeline
- Generate test coverage reports
- Deploy updates with zero downtime
- Rollback failed deployments

*Tools Used:*
- Concourse CI/CD (optional)
- Docker Compose for orchestration
- Ansible for configuration management (production)

== Prerequisites

=== Required Knowledge

#table(
  columns: (auto, 1fr, auto),
  align: (left, left, center),
  [*Area*], [*Required Skills*], [*Level*],

  [Linux], [Command-line proficiency, file system navigation, permissions], [Intermediate],
  [Docker], [Container concepts, Docker commands, Docker Compose], [Intermediate],
  [Networking], [TCP/IP, DNS, ports, HTTP/HTTPS], [Basic],
  [Security], [SSL/TLS concepts, secrets management], [Basic],
  [Scripting], [Bash scripting, environment variables], [Basic],
)

=== Required Software

Before you begin, ensure you have:

- *Docker Desktop* (Windows/Mac) or *Docker Engine* (Linux)
  - Version 20.10+ with Compose V2
  - Download: https://docs.docker.com/get-docker/
- *Git* for version control
  - Version 2.30+
  - Download: https://git-scm.com/
- *Text editor* or IDE (VS Code, vim, nano)
- *Terminal/Shell* access (bash, zsh)

=== System Requirements

#info_box(type: "warning")[
  **Minimum Requirements**

  - CPU: 2 cores
  - RAM: 4 GB (8 GB recommended)
  - Disk: 20 GB free space (SSD recommended)
  - Network: Stable internet connection
]

For production deployments:
- CPU: 4+ cores
- RAM: 16+ GB
- Disk: 100+ GB SSD
- Network: Low latency, high bandwidth

== Key Concepts

=== Docker Architecture

The FlutterGristAPI project uses Docker to containerize all services:

```
┌─────────────────────────────────────┐
│         Docker Host                 │
│                                     │
│  ┌─────────────┐  ┌──────────────┐ │
│  │   Grist     │  │   Flutter    │ │
│  │  Container  │  │   Container  │ │
│  │  :8484      │  │   Dev/Test   │ │
│  └──────┬──────┘  └──────────────┘ │
│         │                           │
│  ┌──────▼──────────────────┐       │
│  │   Docker Network        │       │
│  │   (grist-network)       │       │
│  └─────────────────────────┘       │
│                                     │
│  ┌─────────────────────────┐       │
│  │   Volumes               │       │
│  │   • grist-data/         │       │
│  │   • flutter_pub_cache   │       │
│  └─────────────────────────┘       │
└─────────────────────────────────────┘
```

*Key Components:*
- *Containers*: Isolated execution environments
- *Networks*: Enable inter-container communication
- *Volumes*: Persistent data storage

=== Service Architecture

```yaml
services:
  grist:
    - Database/spreadsheet server
    - Accessible at localhost:8484
    - Data persisted in ./grist-data

  flutter-test:
    - Runs Flutter unit tests
    - Temporary container

  flutter-analyze:
    - Runs Flutter static analysis
    - Temporary container

  flutter:
    - Interactive development shell
    - Access with: ./docker-test.sh shell
```

=== Data Persistence

#info_box(type: "danger")[
  **Critical Data Alert**

  The `grist-data/` directory contains all Grist documents and user data.

  - Always back up before major operations
  - Never delete without verification
  - Excluded from git via `.gitignore`
]

*Volume Mounts:*
- `./grist-module/grist-data:/persist` - Grist data persistence
- `./flutter-module:/app` - Live code synchronization
- `flutter_pub_cache` - Flutter dependency cache

=== Environment Configuration

Environment variables control service behavior:

```bash
# .env file
GRIST_SESSION_SECRET=<secure-random-key>
GRIST_APP_HOME_URL=http://localhost:8484
```

*Security Note:* The `.env` file is git-ignored and should never be committed to version control.

=== Helper Script

The `docker-test.sh` script provides convenient commands:

```bash
# Grist management
./docker-test.sh grist-start    # Start Grist server
./docker-test.sh grist-stop     # Stop Grist server
./docker-test.sh grist-logs     # View logs

# Testing
./docker-test.sh test           # Run tests
./docker-test.sh analyze        # Run analysis
./docker-test.sh all            # Run both

# System management
./docker-test.sh start-all      # Start all services
./docker-test.sh stop-all       # Stop all services
./docker-test.sh clean          # Clean up (deletes data!)
```

== Project Structure

```
flutterGristAPI/
├── docker-compose.yml          # Service orchestration
├── docker-test.sh              # Helper script
├── .env                        # Environment config (gitignored)
├── .env.example                # Environment template
│
├── grist-module/
│   └── grist-data/             # Grist persistent data (CRITICAL!)
│       └── README.md           # Data directory documentation
│
├── flutter-module/
│   ├── Dockerfile              # Flutter container definition
│   ├── lib/                    # Application source
│   └── test/                   # Unit tests
│
├── deployment-module/          # Production deployment
│   ├── playbooks/              # Ansible playbooks
│   ├── roles/                  # Ansible roles
│   │   ├── backup/             # Backup automation
│   │   ├── security/           # Security hardening
│   │   ├── ssl/                # SSL/TLS setup
│   │   └── monitoring/         # Monitoring setup
│   └── concourse/              # CI/CD pipeline
│
└── documentation-module/       # Documentation (you are here)
    └── devops/                 # DevOps documentation
```

== Common Workflows

=== Daily Operations

1. *Start Services:* `./docker-test.sh grist-start`
2. *Check Status:* `docker ps`
3. *View Logs:* `./docker-test.sh grist-logs`
4. *Run Tests:* `./docker-test.sh all`
5. *Stop Services:* `./docker-test.sh stop-all`

=== Deployment Workflow

1. *Build Images:* `./docker-test.sh build`
2. *Test Changes:* `./docker-test.sh all`
3. *Start Services:* `./docker-test.sh start-all`
4. *Verify Health:* Check Grist UI at http://localhost:8484
5. *Monitor Logs:* `docker-compose logs -f`

=== Troubleshooting Workflow

1. *Check Container Status:* `docker ps -a`
2. *Review Logs:* `docker-compose logs <service>`
3. *Inspect Container:* `docker inspect <container>`
4. *Test Network:* `docker network inspect grist-network`
5. *Restart Service:* `docker-compose restart <service>`

== Getting Help

=== Documentation

- *Quick Start:* `quickstart.typ` - First-time setup
- *Docker Setup:* `docker-setup.typ` - Comprehensive Docker guide
- *Security:* `security.typ` - Security best practices
- *Commands:* `commands.typ` - Command reference
- *Troubleshooting:* `troubleshooting.typ` - Common issues

=== Resources

- *Docker Documentation:* https://docs.docker.com/
- *Grist Documentation:* https://support.getgrist.com/
- *Project Repository:* Check README.md for contact info
- *CI/CD Pipeline:* See `deployment-module/CONCOURSE_ANALYSIS.md`

=== Support Channels

When reporting issues, include:
- Output of `docker ps -a`
- Relevant logs from `docker-compose logs`
- System information (`docker version`, OS version)
- Steps to reproduce the issue

#section_separator()

#info_box(type: "success")[
  **Ready to Get Started?**

  Continue to *quickstart.typ* for your first-time setup guide, or jump to *docker-setup.typ* for comprehensive Docker configuration details.
]
