# Deployment Module

This module provides Ansible automation for deploying and configuring the Flutter Grist Widgets application on a Raspberry Pi production server.

## Overview

The deployment module uses Ansible to automate server configuration, ensuring your Raspberry Pi production environment is properly set up with:

- **Base system configuration** (packages, timezone, locale, swap)
- **Security hardening** (SSH, firewall, fail2ban, automatic updates)
- **Docker environment** (Docker CE, Docker Compose)
- **Monitoring tools** (system health checks, log rotation)
- **Application environment** (user, directories, nginx reverse proxy)

## Prerequisites

### Local Machine Requirements
- Ansible 2.9 or higher installed
- SSH access to the Raspberry Pi
- SSH key-based authentication configured

### Raspberry Pi Requirements
- Raspberry Pi 3/4/5 with Raspberry Pi OS (Debian-based)
- SSH enabled and accessible
- User with sudo privileges
- Network connectivity

## Quick Start

### 1. Install Ansible (if not already installed)

```bash
# On Ubuntu/Debian
sudo apt install ansible

# On macOS
brew install ansible

# On other systems, use pip
pip install ansible
```

### 2. Configure Your Inventory

Edit the inventory file to match your Raspberry Pi configuration:

```bash
cd deployment-module
cp inventory/hosts.example inventory/hosts.yml
vim inventory/hosts.yml
```

Update the following values:
- `ansible_host`: Your Raspberry Pi's IP address
- `ansible_user`: Your SSH username (usually `pi`)

**Or** set environment variables:

```bash
export RASPI_HOST=192.168.1.100
export RASPI_USER=pi
```

### 3. Test Connection

```bash
ansible all -m ping
```

Expected output:
```
raspberry_pi | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### 4. Run the Configuration Playbook

```bash
# Full configuration
ansible-playbook playbooks/configure_server.yml

# Dry run (check mode)
ansible-playbook playbooks/configure_server.yml --check

# Verbose output
ansible-playbook playbooks/configure_server.yml -vv

# Run specific roles only
ansible-playbook playbooks/configure_server.yml --tags "common,security"
```

## Directory Structure

```
deployment-module/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   ├── hosts.yml           # Server inventory (customize this)
│   └── hosts.example       # Example inventory file
├── playbooks/
│   └── configure_server.yml # Main configuration playbook
├── roles/
│   ├── common/             # Base system configuration
│   ├── security/           # Security hardening
│   ├── docker/             # Docker installation
│   ├── monitoring/         # Monitoring tools
│   └── app_environment/    # Application setup
├── group_vars/             # Group variables
└── README.md              # This file
```

## Roles

### Common Role
**Tags:** `common`, `base`

Configures base system settings:
- Updates and upgrades packages
- Installs essential tools
- Sets timezone and locale
- Creates swap file
- Optimizes system parameters

### Security Role
**Tags:** `security`

Hardens server security:
- Configures SSH (disables root login, password auth)
- Sets up UFW firewall
- Installs and configures fail2ban
- Enables automatic security updates

### Docker Role
**Tags:** `docker`, `containers`

Installs Docker environment:
- Removes old Docker versions
- Installs Docker CE and Docker Compose
- Configures Docker daemon
- Adds application user to docker group

### Monitoring Role
**Tags:** `monitoring`

Sets up monitoring tools:
- Installs system monitoring utilities
- Creates health check scripts
- Configures log rotation

### App Environment Role
**Tags:** `app`, `environment`

Prepares application environment:
- Creates application user and directories
- Installs nginx reverse proxy
- Creates environment file template
- Sets up application structure

## Configuration Variables

Key variables you can customize in `inventory/hosts.yml`:

```yaml
# Server settings
server_timezone: "Europe/Paris"
server_locale: "en_US.UTF-8"

# SSH settings
ssh_port: 22
ssh_permit_root_login: "no"
ssh_password_authentication: "no"

# Application settings
app_name: "flutter_grist_app"
app_user: "appuser"
app_home: "/opt/flutter_grist_app"
deployment_env: "production"
```

## Usage Examples

### Run specific tasks

```bash
# Only update packages
ansible-playbook playbooks/configure_server.yml --tags "packages"

# Only configure security
ansible-playbook playbooks/configure_server.yml --tags "security"

# Configure Docker and app environment
ansible-playbook playbooks/configure_server.yml --tags "docker,app"
```

### Check what would change

```bash
ansible-playbook playbooks/configure_server.yml --check --diff
```

### Run with elevated verbosity

```bash
ansible-playbook playbooks/configure_server.yml -vvv
```

## Post-Configuration Steps

After running the playbook:

1. **Configure application environment:**
   ```bash
   ssh pi@your-raspberry-pi-ip
   sudo su - appuser
   cd /opt/flutter_grist_app/config
   cp .env.example .env
   vim .env  # Update with your Grist API credentials
   ```

2. **Deploy your application:**
   - Upload your Flutter application build to `/opt/flutter_grist_app/`
   - Create a docker-compose.yml for your app
   - Start your application

3. **Verify services:**
   ```bash
   # Check Docker
   docker --version
   docker ps

   # Check nginx
   sudo systemctl status nginx

   # Check firewall
   sudo ufw status

   # Run health check
   sudo /opt/monitoring/health_check.sh
   ```

## Troubleshooting

### Connection Issues

```bash
# Test SSH connection
ssh pi@your-raspberry-pi-ip

# Test Ansible connection
ansible all -m ping -vvv
```

### Permission Issues

Ensure your user has sudo privileges:
```bash
# On Raspberry Pi
sudo visudo
# Add: pi ALL=(ALL) NOPASSWD:ALL
```

### Docker Issues

```bash
# On Raspberry Pi, check Docker status
sudo systemctl status docker

# Test Docker
docker run --rm hello-world
```

### View Ansible Logs

```bash
cat ansible.log
```

## Security Notes

- SSH password authentication is disabled by default
- Root login is disabled
- UFW firewall is enabled (only SSH, HTTP, HTTPS allowed)
- fail2ban protects against brute force attacks
- Automatic security updates are enabled

## Next Steps

1. Configure SSL/TLS certificates with Let's Encrypt:
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

2. Set up application deployment automation
3. Configure backup scripts
4. Set up monitoring alerts

## Contributing

When adding new roles or playbooks:
1. Follow Ansible best practices
2. Use tags for granular control
3. Document all variables
4. Test thoroughly on a test Raspberry Pi first

## License

This deployment module is part of the Flutter Grist Widgets project and follows the same MIT license.
