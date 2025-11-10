#!/bin/bash
set -e

# FlutterGristAPI Documentation HTML Generator
# Converts Typst documentation to HTML for all roles

echo "🔨 Building FlutterGristAPI Documentation Website..."
echo ""

# Check if Typst is installed
if ! command -v typst &> /dev/null; then
    echo "❌ Error: Typst is not installed"
    echo ""
    echo "Please install Typst first:"
    echo "  - macOS: brew install typst"
    echo "  - Linux: cargo install --git https://github.com/typst/typst"
    echo "  - Or download from: https://github.com/typst/typst/releases"
    echo ""
    exit 1
fi

echo "✅ Typst found: $(typst --version)"
echo ""

# Define roles
ROLES=(
  "end-user"
  "app-designer"
  "grist-manager"
  "flutter-developer"
  "devops"
  "delivery-specialist"
  "data-admin"
)

# Role display names
declare -A ROLE_NAMES
ROLE_NAMES[end-user]="End User"
ROLE_NAMES[app-designer]="App Designer"
ROLE_NAMES[grist-manager]="Grist Manager"
ROLE_NAMES[flutter-developer]="Flutter Developer"
ROLE_NAMES[devops]="DevOps"
ROLE_NAMES[delivery-specialist]="Delivery Specialist"
ROLE_NAMES[data-admin]="Data Admin"

# Create build directory
BUILD_DIR="../build"
mkdir -p "$BUILD_DIR"

# Change to documentation module directory
cd "$(dirname "$0")/.."

echo "📁 Working directory: $(pwd)"
echo "📁 Build directory: $BUILD_DIR"
echo ""

# Generate HTML for each role
SUCCESS_COUNT=0
TOTAL_COUNT=${#ROLES[@]}

for role in "${ROLES[@]}"; do
    ROLE_NAME="${ROLE_NAMES[$role]}"
    TYPST_FILE="$role/$role.typ"
    HTML_FILE="$BUILD_DIR/$role.html"

    echo "📄 Building $ROLE_NAME..."

    if [ ! -f "$TYPST_FILE" ]; then
        echo "   ⚠️  Warning: $TYPST_FILE not found, skipping"
        continue
    fi

    # Compile Typst to HTML
    if typst compile "$TYPST_FILE" "$HTML_FILE" 2>&1 | grep -v "warning:"; then
        echo "   ✅ $ROLE_NAME → $role.html"
        ((SUCCESS_COUNT++))
    else
        echo "   ❌ Failed to build $ROLE_NAME"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Built $SUCCESS_COUNT/$TOTAL_COUNT role documentations"
echo ""

# Generate index page
echo "🏠 Generating index.html..."
./scripts/generate-index.sh

# Copy CSS file if it doesn't exist
if [ ! -f "$BUILD_DIR/styles.css" ]; then
    echo "🎨 Creating styles.css..."
    cat > "$BUILD_DIR/styles.css" << 'CSS'
/* FlutterGristAPI Documentation Styles */

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 20px;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
}

header {
    text-align: center;
    color: white;
    padding: 40px 20px;
    margin-bottom: 40px;
}

header h1 {
    font-size: 3em;
    margin-bottom: 10px;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

header p {
    font-size: 1.3em;
    opacity: 0.9;
}

.role-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 25px;
    padding: 20px;
}

.role-card {
    background: white;
    border-radius: 12px;
    padding: 30px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    cursor: pointer;
}

.role-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 40px rgba(0,0,0,0.3);
}

.role-card h2 {
    font-size: 1.8em;
    margin-bottom: 15px;
    color: #667eea;
    display: flex;
    align-items: center;
    gap: 10px;
}

.role-card p {
    color: #666;
    margin-bottom: 20px;
    line-height: 1.6;
}

.role-card a {
    display: inline-block;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 12px 24px;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 600;
    transition: opacity 0.3s ease;
}

.role-card a:hover {
    opacity: 0.9;
}

footer {
    text-align: center;
    color: white;
    padding: 40px 20px;
    margin-top: 40px;
    opacity: 0.8;
}

@media (max-width: 768px) {
    header h1 {
        font-size: 2em;
    }

    header p {
        font-size: 1em;
    }

    .role-grid {
        grid-template-columns: 1fr;
    }
}
CSS
    echo "   ✅ styles.css created"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Documentation website built successfully!"
echo ""
echo "📂 Output location: $BUILD_DIR"
echo "🌐 Open: $BUILD_DIR/index.html"
echo ""
echo "To view the website:"
echo "  macOS:  open $BUILD_DIR/index.html"
echo "  Linux:  xdg-open $BUILD_DIR/index.html"
echo "  Windows: start $BUILD_DIR/index.html"
echo ""
