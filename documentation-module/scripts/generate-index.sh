#!/bin/bash

# Generate index.html for FlutterGristAPI documentation

BUILD_DIR="../build"
INDEX_FILE="$BUILD_DIR/index.html"

# Change to documentation module directory
cd "$(dirname "$0")/.."

# Create index.html
cat > "$INDEX_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlutterGristAPI Documentation</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📚 FlutterGristAPI Documentation</h1>
            <p>Comprehensive guides for all user roles</p>
            <p style="font-size: 0.9em; margin-top: 10px;">Version 0.1.0</p>
        </header>

        <main class="role-grid">
            <div class="role-card">
                <h2>👤 End User</h2>
                <p>Using the Flutter application - Login, navigation, viewing data, and troubleshooting.</p>
                <a href="end-user.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>📝 App Designer</h2>
                <p>Configure apps via YAML - Design application structure, pages, and data connections.</p>
                <a href="app-designer.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>🗄️ Grist Manager</h2>
                <p>Manage Grist databases & schemas - Tables, users, data operations, and API management.</p>
                <a href="grist-manager.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>💻 Flutter Developer</h2>
                <p>Develop and extend the library - Code architecture, widgets, testing, and contributions.</p>
                <a href="flutter-developer.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>⚙️ DevOps</h2>
                <p>Infrastructure & operations - Docker, containers, monitoring, security, and SSL.</p>
                <a href="devops.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>🚀 Delivery Specialist</h2>
                <p>CI/CD pipelines & deployment - Concourse, automated testing, and release management.</p>
                <a href="delivery-specialist.html">View Guide →</a>
            </div>

            <div class="role-card">
                <h2>💾 Data Admin</h2>
                <p>Backup & data integrity - Backup strategies, disaster recovery, and data validation.</p>
                <a href="data-admin.html">View Guide →</a>
            </div>
        </main>

        <footer>
            <p>FlutterGristAPI - A YAML-Driven Flutter Application Generator</p>
            <p style="font-size: 0.9em; margin-top: 10px;">
                <a href="https://github.com/PierreBx/flutterGristAPI" style="color: white;">GitHub Repository</a>
            </p>
        </footer>
    </div>
</body>
</html>
EOF

echo "   ✅ index.html generated"
