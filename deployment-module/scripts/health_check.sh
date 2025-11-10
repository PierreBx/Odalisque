#!/bin/bash
# Remote health check script
# Runs the health check on the remote Raspberry Pi

set -e

cd "$(dirname "$0")/.."

echo "Running health check on Raspberry Pi..."
echo ""

ansible all -m shell -a "/opt/monitoring/health_check.sh" -b

echo ""
echo "Health check complete!"
