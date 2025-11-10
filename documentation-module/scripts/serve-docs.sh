#!/bin/bash
set -e

# FlutterGristAPI Documentation Live Server
# Serves documentation with hot-reload for development

echo "🚀 Starting MkDocs Live Preview Server..."
echo ""

# Change to documentation module directory
cd "$(dirname "$0")/.."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed"
    echo ""
    echo "Please install Docker first:"
    echo "  - https://docs.docker.com/get-docker/"
    echo ""
    exit 1
fi

echo "✅ Docker found: $(docker --version)"
echo ""

# Build MkDocs Docker image if it doesn't exist
echo "🐳 Building MkDocs Docker image..."
docker compose build mkdocs
echo ""

echo "📚 Starting live preview server..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Server starting at http://localhost:8000"
echo ""
echo "💡 The server will automatically reload when you edit files"
echo "🛑 Press Ctrl+C to stop the server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Run MkDocs serve
docker compose run --rm --service-ports mkdocs mkdocs serve --dev-addr=0.0.0.0:8000
