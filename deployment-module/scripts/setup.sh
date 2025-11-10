#!/bin/bash
# Setup script for deployment module
# This script helps you get started with the deployment module

set -e

echo "==================================="
echo "Deployment Module Setup"
echo "==================================="
echo ""

# Check if Ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "Error: Ansible is not installed"
    echo "Please install Ansible first:"
    echo "  Ubuntu/Debian: sudo apt install ansible"
    echo "  macOS: brew install ansible"
    echo "  Other: pip install ansible"
    exit 1
fi

echo "✓ Ansible is installed: $(ansible --version | head -n 1)"
echo ""

# Check if inventory exists
if [ ! -f "inventory/hosts.yml" ]; then
    echo "Creating inventory file from example..."
    cp inventory/hosts.example inventory/hosts.yml
    echo "✓ Created inventory/hosts.yml"
    echo ""
    echo "⚠ IMPORTANT: Edit inventory/hosts.yml with your Raspberry Pi details:"
    echo "  - ansible_host: Your Raspberry Pi IP address"
    echo "  - ansible_user: Your SSH username"
    echo ""
    read -p "Press Enter to edit inventory file now, or Ctrl+C to exit..."
    ${EDITOR:-vim} inventory/hosts.yml
fi

# Check SSH connection
echo ""
echo "Testing SSH connection to Raspberry Pi..."
if ansible all -m ping; then
    echo "✓ SSH connection successful!"
else
    echo "✗ SSH connection failed"
    echo ""
    echo "Please ensure:"
    echo "  1. Your Raspberry Pi is powered on and connected to network"
    echo "  2. SSH is enabled on the Raspberry Pi"
    echo "  3. You have SSH key-based authentication set up"
    echo "  4. The IP address in inventory/hosts.yml is correct"
    echo ""
    echo "To set up SSH key authentication:"
    echo "  ssh-copy-id pi@your-raspberry-pi-ip"
    exit 1
fi

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "You can now configure your server with:"
echo "  ansible-playbook playbooks/configure_server.yml"
echo ""
echo "Or run a dry-run first:"
echo "  ansible-playbook playbooks/configure_server.yml --check"
echo ""
