#!/bin/bash
set -e

# FlutterGristAPI Documentation Builder
# Converts Markdown documentation to static HTML site using MkDocs and Docker

echo "🔨 Building FlutterGristAPI Documentation Website with MkDocs..."
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

# Build the documentation site
echo "📚 Building documentation site..."
docker compose run --rm mkdocs mkdocs build --clean

if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ Documentation website built successfully!"
    echo ""
    echo "📂 Output location: site/"
    echo "🌐 Open: site/index.html"
    echo ""
    echo "To view the website:"
    echo "  macOS:  open site/index.html"
    echo "  Linux:  xdg-open site/index.html"
    echo "  Windows: start site/index.html"
    echo ""
else
    echo ""
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi
