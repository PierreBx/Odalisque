#!/bin/bash
# Deploy script - runs the main configuration playbook
# Usage: ./scripts/deploy.sh [options]

set -e

cd "$(dirname "$0")/.."

echo "==================================="
echo "Raspberry Pi Server Configuration"
echo "==================================="
echo ""

# Parse arguments
CHECK_MODE=""
VERBOSE=""
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --check|--dry-run)
            CHECK_MODE="--check"
            echo "Running in CHECK MODE (no changes will be made)"
            shift
            ;;
        -v|--verbose)
            VERBOSE="-vv"
            shift
            ;;
        -vv|--very-verbose)
            VERBOSE="-vvv"
            shift
            ;;
        --tags)
            TAGS="--tags $2"
            echo "Running only tags: $2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --check, --dry-run    Run in check mode (no changes)"
            echo "  -v, --verbose         Verbose output"
            echo "  -vv, --very-verbose   Very verbose output"
            echo "  --tags TAG1,TAG2      Run only specific tags"
            echo "  -h, --help            Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                           # Full deployment"
            echo "  $0 --check                   # Dry run"
            echo "  $0 --tags security,docker    # Run only security and docker roles"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run playbook
ansible-playbook playbooks/configure_server.yml $CHECK_MODE $VERBOSE $TAGS

echo ""
echo "==================================="
echo "Configuration Complete!"
echo "==================================="
