# Quickstart Guide

This guide will get your CI/CD environment up and running in approximately 30 minutes.

## Prerequisites Checklist

Before you begin, ensure you have:

- ☐ Docker installed and running on your laptop
- ☐ Git repository cloned to your machine
- ☐ SSH access to Raspberry Pi production server
- ☐ SSH key-based authentication configured (~/.ssh/)
- ☐ 8GB+ RAM available on your laptop
- ☐ 20GB+ free disk space

## Phase 1: Set Up Concourse CI (15 minutes)

### Step 1: Navigate to Concourse Directory

```bash
cd /home/user/flutterGristAPI/deployment-module/concourse/
```

### Step 2: Review Configuration

Check the `docker-compose.yml` file to understand the services:

```bash
cat docker-compose.yml
```

You should see three services:
- *concourse-db*: PostgreSQL database for Concourse metadata
- *concourse-web*: Web UI and API server (port 8080)
- *concourse-worker*: Executes pipeline tasks

### Step 3: Generate Concourse Keys

Concourse requires RSA keys for secure communication:

```bash
# Run the key generation script
./scripts/generate-keys.sh

# Verify keys were created
ls -la keys/
```

You should see:
- `session_signing_key` and `session_signing_key.pub`
- `tsa_host_key` and `tsa_host_key.pub`
- `worker_key` and `worker_key.pub`

### Step 4: Configure Credentials

```bash
# Copy the example credentials file
cp credentials.yml.example credentials.yml

# Edit with your actual values
vim credentials.yml
```

Required credentials:

```yaml
# GitHub repository access
github-private-key: |
  -----BEGIN RSA PRIVATE KEY-----
  (your SSH private key for GitHub)
  -----END RSA PRIVATE KEY-----

# Raspberry Pi access
raspberry-pi-host: "192.168.1.100"  # Your Pi's IP
raspberry-pi-user: "appuser"
ssh-private-key: |
  -----BEGIN RSA PRIVATE KEY-----
  (your SSH private key for Pi)
  -----END RSA PRIVATE KEY-----
```

> **Warning**: *Security Note*: Never commit `credentials.yml` to version control. It's already in `.gitignore`, but double-check that sensitive data stays local.

### Step 5: Start Concourse

```bash
# Start all services in detached mode
docker-compose up -d

# Verify services are running
docker-compose ps

# Check logs if needed
docker-compose logs -f
```

Expected output:
```
NAME                     STATUS    PORTS
concourse-db             Up        5432/tcp
concourse-web            Up        0.0.0.0:8080->8080/tcp
concourse-worker         Up
```

### Step 6: Access Web UI

Open your browser and navigate to:
```
http://localhost:8080
```

Default credentials:
- Username: `test`
- Password: `test`

> **Note**: *First Time?* The UI will be empty. That's normal! You'll deploy your pipeline in the next phase.

### Step 7: Install Fly CLI

The `fly` command-line tool is used to interact with Concourse:

```bash
# Download from Concourse web UI
# Navigate to http://localhost:8080 and click the appropriate OS icon

# Or download directly (Linux example)
wget http://localhost:8080/api/v1/cli?arch=amd64&platform=linux -O fly
chmod +x fly
sudo mv fly /usr/local/bin/

# Verify installation
fly --version
```

### Step 8: Login to Concourse

```bash
# Login to your local Concourse instance
fly -t local login -c http://localhost:8080

# When prompted:
# Username: test
# Password: test

# Verify connection
fly -t local targets
```

## Phase 2: Deploy Your First Pipeline (10 minutes)

### Step 1: Review the Pipeline

```bash
# View the main pipeline configuration
cat pipeline.yml
```

The pipeline includes:
- *quality-checks* job: Runs Flutter analyze, tests, and coverage
- *secrets-scan* job: Scans for hardcoded credentials
- *build* job: Builds Flutter application
- *deploy-production* job: Deploys to Raspberry Pi

### Step 2: Upload the Pipeline

```bash
# Set the pipeline
fly -t local set-pipeline \
  -p flutter-grist \
  -c pipeline.yml \
  -l credentials.yml

# Confirm when prompted (y)

# Unpause the pipeline
fly -t local unpause-pipeline -p flutter-grist
```

### Step 3: Verify in Web UI

Refresh http://localhost:8080 and you should see:
- Pipeline name: `flutter-grist`
- Jobs: quality-checks, secrets-scan, build, deploy-production
- Resources: source-code, flutter-image, ansible-image

### Step 4: Trigger Your First Build

```bash
# Manually trigger the quality-checks job
fly -t local trigger-job -j flutter-grist/quality-checks

# Watch the build in real-time
fly -t local watch -j flutter-grist/quality-checks
```

Or click the job in the Web UI and press the `+` button.

### Step 5: Monitor Build Progress

Watch for:
- ✅ Flutter analyze completing
- ✅ 77 tests passing
- ✅ Coverage threshold met (60%+)

Build time: approximately 2-3 minutes

## Phase 3: Configure Deployment (5 minutes)

### Step 1: Configure Inventory

```bash
cd /home/user/flutterGristAPI/deployment-module/

# Copy example inventory
cp inventory/hosts.example inventory/hosts.yml

# Edit with your Pi details
vim inventory/hosts.yml
```

Update the inventory:

```yaml
all:
  children:
    production:
      hosts:
        raspberry_pi:
          ansible_host: 192.168.1.100  # Your Pi's IP
          ansible_user: pi
          ansible_port: 22
      vars:
        app_name: flutter_grist_app
        app_user: appuser
        domain_name: your-domain.com  # Optional
        admin_email: admin@example.com  # Optional
```

### Step 2: Test Ansible Connection

Using Docker-based Ansible (recommended):

```bash
# Build the Ansible Docker image
./docker-ansible.sh build

# Test connection to Pi
./docker-ansible.sh ping
```

Expected output:
```
raspberry_pi | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 3: Run Initial Deployment

```bash
# Full server configuration (takes 5-10 minutes)
./docker-ansible.sh playbooks/configure_server.yml

# Or run a dry-run first to see what would change
./docker-ansible.sh playbooks/configure_server.yml --check --diff
```

This will configure:
- System packages and settings
- Security hardening (SSH, firewall, fail2ban)
- Docker environment
- Monitoring tools
- Backup automation
- SSL/TLS (if domain configured)
- Application directories

## Phase 4: Verify Everything Works

### Test the Full Pipeline

```bash
# Trigger the complete pipeline
fly -t local trigger-job -j flutter-grist/deploy-production

# Watch deployment
fly -t local watch -j flutter-grist/deploy-production
```

The pipeline will:
1. Run quality checks (analyze + test)
2. Build application
3. Deploy to Raspberry Pi via Ansible
4. Run health checks

### Verify on Raspberry Pi

```bash
# SSH to your Pi
ssh pi@192.168.1.100

# Check Docker is running
docker --version
docker ps

# Check nginx
sudo systemctl status nginx

# Check firewall
sudo ufw status

# Run health check
sudo /opt/monitoring/health_check.sh
```

### Test Auto-Deployment

```bash
# Make a small change
cd /home/user/flutterGristAPI/
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "Test auto-deployment"
git push

# Pipeline should automatically trigger!
# Watch it in the Web UI: http://localhost:8080
```

## Common First-Time Issues

### Issue: Docker permissions error

```bash
# Solution: Add your user to docker group
sudo usermod -aG docker $USER

# Logout and login again for changes to take effect
```

### Issue: Concourse worker not starting

```bash
# Check logs
docker-compose logs concourse-worker

# Common fix: Restart with clean state
docker-compose down -v
docker-compose up -d
```

### Issue: Cannot connect to Raspberry Pi

```bash
# Verify SSH access manually
ssh pi@192.168.1.100

# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa

# Test with verbose output
ssh -v pi@192.168.1.100
```

### Issue: Pipeline fails with "permission denied"

Check that:
- SSH private key is correctly formatted in `credentials.yml`
- Key has no passphrase (or use ssh-agent)
- Raspberry Pi user has sudo NOPASSWD configured

## Next Steps

Now that your CI/CD environment is running:

1. *Explore the Web UI*: http://localhost:8080
2. *Review Pipeline Configuration*: Understand each job and task
3. *Read CI/CD Pipeline Documentation*: Learn advanced features
4. *Set Up Monitoring*: Configure alerts and notifications
5. *Plan Deployment Strategy*: Define your release process

> **Success**: *Congratulations!* You now have a fully automated CI/CD pipeline. Every commit will be tested, and merges to main will automatically deploy to production.

## Quick Reference

### Essential Commands

```bash
# Concourse Management
fly -t local login -c http://localhost:8080
fly -t local pipelines
fly -t local trigger-job -j PIPELINE/JOB
fly -t local watch -j PIPELINE/JOB
fly -t local set-pipeline -p NAME -c pipeline.yml

# Docker Compose
docker-compose up -d
docker-compose down
docker-compose logs -f [SERVICE]
docker-compose ps

# Ansible
./docker-ansible.sh ping
./docker-ansible.sh playbooks/configure_server.yml
./docker-ansible.sh playbooks/configure_server.yml --tags "docker,app"
```

### Important Locations

```
deployment-module/concourse/     # Concourse configuration
deployment-module/ansible.cfg    # Ansible settings
deployment-module/inventory/     # Server inventory
deployment-module/playbooks/     # Deployment playbooks
deployment-module/roles/         # Ansible roles
```

### Resources

- Concourse Documentation: https://concourse-ci.org/docs.html
- Ansible Documentation: https://docs.ansible.com/
- Project Docs: `/home/user/flutterGristAPI/documentation-module/`
