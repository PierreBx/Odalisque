#!/bin/bash
# Helper script to run Typst commands via Docker
# Usage: ./typst.sh compile file.typ output.pdf

set -e

# Change to documentation module directory
cd "$(dirname "$0")"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    exit 1
fi

# Build image if needed
if ! docker images | grep -q "fluttergristapi-typst"; then
    echo "🐳 Building Typst Docker image..."
    docker-compose build typst
    echo ""
fi

# Run Typst command in Docker
docker-compose run --rm typst typst "$@"
