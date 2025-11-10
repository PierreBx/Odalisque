# Quick Start Guide

Get your Raspberry Pi configured in 5 minutes!

## Prerequisites

✅ Raspberry Pi with Raspberry Pi OS installed
✅ SSH enabled on the Raspberry Pi
✅ Network connection to Raspberry Pi
✅ SSH key-based authentication set up

## Step 1: Install Ansible

```bash
# Ubuntu/Debian
sudo apt install ansible

# macOS
brew install ansible

# Using pip
pip install ansible
```

## Step 2: Configure Inventory

Set your Raspberry Pi IP address:

```bash
export RASPI_HOST=192.168.1.100  # Replace with your Pi's IP
export RASPI_USER=pi              # Replace with your SSH user
```

Or edit the inventory file:

```bash
cp inventory/hosts.example inventory/hosts.yml
vim inventory/hosts.yml
```

## Step 3: Test Connection

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

## Step 4: Deploy!

```bash
# Option 1: Use the deploy script
./scripts/deploy.sh

# Option 2: Use make
make deploy

# Option 3: Use ansible-playbook directly
ansible-playbook playbooks/configure_server.yml
```

## What Gets Configured?

✅ System packages updated
✅ Security hardening (SSH, firewall, fail2ban)
✅ Docker and Docker Compose installed
✅ Nginx reverse proxy configured
✅ Monitoring tools installed
✅ Application environment prepared

## Next Steps

1. **Configure your application:**
   ```bash
   ssh pi@your-pi-ip
   sudo su - appuser
   cd /opt/flutter_grist_app/config
   cp .env.example .env
   vim .env
   ```

2. **Deploy your app:**
   - Upload your Flutter app to `/opt/flutter_grist_app/`
   - Create a `docker-compose.yml`
   - Start your services

3. **Set up SSL (optional):**
   ```bash
   sudo certbot --nginx -d yourdomain.com
   ```

## Useful Commands

```bash
# Check server health
make health

# Test without making changes
make check

# Run specific roles only
ansible-playbook playbooks/configure_server.yml --tags security

# Verbose output
./scripts/deploy.sh -vv
```

## Troubleshooting

**Connection failed?**
- Check if SSH is enabled: `ssh pi@your-pi-ip`
- Verify IP address in inventory
- Ensure SSH keys are set up: `ssh-copy-id pi@your-pi-ip`

**Permission denied?**
- Make sure your user has sudo access on the Pi
- Check that you're using the correct username

**Need help?**
- See full documentation: [README.md](README.md)
- Check Ansible logs: `cat ansible.log`

---

That's it! Your Raspberry Pi is now production-ready. 🎉
