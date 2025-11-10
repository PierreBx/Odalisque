# Quick Start Guide - First Time Setup

This guide will help you set up the complete Flutter Grist Widgets development environment for the first time.

## Prerequisites

- ✅ Docker installed and running ([Get Docker](https://docs.docker.com/get-docker/))
  - Docker Compose V2 is built into Docker Desktop and modern Docker installations
  - We use `docker compose` (not the old `docker-compose`)
- ✅ Git installed (for cloning the repository)

## Step-by-Step Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/flutterGristAPI.git
cd flutterGristAPI
```

### Step 2: Set Up Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env file and set a secure random secret
# Change GRIST_SESSION_SECRET to a random string (e.g., use a password generator)
```

**Example `.env` file:**
```bash
GRIST_SESSION_SECRET=your-random-secret-key-here-change-this
GRIST_APP_HOME_URL=http://localhost:8484
```

💡 **Tip:** Generate a secure random secret with:
```bash
# Linux/macOS
openssl rand -hex 32

# Or any random string works
# Example: K8mN2pQ5rS9vX3zA6bC1dE4fG7hJ0iL
```

### Step 3: Start Grist Server

```bash
./docker-test.sh grist-start
```

You should see:
```
✓ Grist started at http://localhost:8484
```

### Step 4: Configure Grist (First Time)

1. **Open Grist in your browser:**
   - Navigate to http://localhost:8484

2. **Create a new document:**
   - Click "Add New" → "Create Empty Document"
   - Name it (e.g., "MyApp Database")

3. **Set up your Users table:**

   Create a table named "Users" with these columns:

   | Column Name   | Type   | Description                          |
   |---------------|--------|--------------------------------------|
   | email         | Text   | User email address                   |
   | password_hash | Text   | Bcrypt hashed password              |
   | role          | Text   | User role (admin, user, etc.)       |
   | active        | Toggle | Whether user account is active      |

4. **Add a test user:**

   In the Users table, add a row with:
   - **email:** `test@example.com`
   - **password_hash:** Use the pre-hashed password for "password123":
     ```
     $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
     ```
   - **role:** `admin`
   - **active:** ✓ (checked)

   💡 This test user credentials: `test@example.com` / `password123`

5. **Generate API Key:**

   - Click your profile icon (top right) → "Profile Settings"
   - Go to "API" section
   - Click "Create" to generate a new API key
   - **Copy and save this key** - you'll need it later!

6. **Get your Document ID:**

   Look at the URL in your browser:
   ```
   http://localhost:8484/doc/ABC123xyz456
                              ^^^^^^^^^^^^
                              This is your Document ID
   ```

### Step 5: Create App Configuration (Optional - for testing with real app)

If you want to test the Flutter widgets with your Grist instance, create a YAML configuration file:

**Example: `example/config.yaml`**
```yaml
grist:
  base_url: "http://localhost:8484"
  document_id: "YOUR_DOCUMENT_ID_HERE"
  api_key: "YOUR_API_KEY_HERE"
  users_table: "Users"

auth:
  enabled: true
  login_page:
    title: "Login"
    email_field:
      label: "Email"
      validators:
        - type: "required"
          message: "Email is required"
        - type: "email"
          message: "Invalid email format"
    password_field:
      label: "Password"
      validators:
        - type: "required"
          message: "Password is required"
        - type: "min_length"
          min: 6
          message: "Password must be at least 6 characters"
  users_table: "Users"
  users_table_schema:
    email_field: "email"
    password_field: "password_hash"
    role_field: "role"
    active_field: "active"
  session:
    timeout_minutes: 30
    auto_logout_on_timeout: true

pages:
  - id: "home"
    type: "data_master"
    title: "Home"
    config:
      grist:
        table: "Users"
        columns:
          - name: "email"
            label: "Email"
            type: "Text"
          - name: "role"
            label: "Role"
            type: "Text"
          - name: "active"
            label: "Active"
            type: "Bool"
```

### Step 6: Build Flutter Docker Image

```bash
./docker-test.sh build
```

This will:
- Download Flutter SDK 3.16.0
- Install all dependencies
- Pre-cache Flutter packages

**This may take 5-10 minutes the first time.**

### Step 7: Run Tests

```bash
./docker-test.sh all
```

You should see:
```
✓ Code Analysis passed
✓ Unit Tests passed
✓ All tests passed!
```

**Expected test results:**
- 77 unit tests should pass
- 0 analysis errors

### Step 8: Verify Setup

Check that everything is running:

```bash
# Check Grist is running
docker ps | grep grist
# Should show: grist_server running on port 8484

# Check Grist logs
./docker-test.sh grist-logs
# Press Ctrl+C to exit logs
```

## ✅ Setup Complete!

You now have:
- ✅ Grist server running at http://localhost:8484
- ✅ Flutter development environment ready
- ✅ Test user configured (test@example.com / password123)
- ✅ API key generated
- ✅ All tests passing

## What's Next?

See **DAILY_USAGE.md** for your daily development workflow.

## Project Structure Overview

```
flutterGristAPI/
├── lib/                    # Flutter library source code
│   ├── src/
│   │   ├── config/        # Configuration models
│   │   ├── models/        # Data models
│   │   ├── pages/         # Page widgets
│   │   ├── providers/     # State management
│   │   ├── services/      # Grist API service
│   │   ├── utils/         # Validators, helpers
│   │   └── widgets/       # Reusable widgets
│   └── flutter_grist_widgets.dart
├── test/                  # Unit tests (77 tests)
├── example/              # Example app configurations
├── grist-data/           # Grist persistent data (DO NOT DELETE)
├── docker-compose.yml    # Docker services configuration
├── docker-test.sh        # Helper script for Docker commands
├── .env                  # Environment variables (gitignored)
└── README_DOCKER.md      # Detailed Docker documentation
```

## Important Files and Locations

| Item | Location | Description |
|------|----------|-------------|
| **Grist Data** | `./grist-data/` | All Grist documents and data (backed up automatically) |
| **Grist Web UI** | http://localhost:8484 | Access Grist interface in browser |
| **Environment** | `.env` | Secret keys and configuration (never commit!) |
| **Tests** | `./test/` | 77 unit tests for validators, services, etc. |
| **API Service** | `lib/src/services/grist_service.dart` | Main Grist API integration |

## Troubleshooting

### Problem: Port 8484 already in use

**Solution:**
```bash
# Find what's using the port (macOS/Linux)
lsof -i :8484

# Find what's using the port (Windows)
netstat -ano | findstr :8484

# Either stop that service, or change the port in docker-compose.yml
```

### Problem: Docker build fails

**Solution:**
```bash
# Clean Docker cache and rebuild
docker-compose down -v
docker system prune -f
./docker-test.sh build
```

### Problem: Cannot access Grist UI

**Solution:**
```bash
# Restart Grist
./docker-test.sh grist-restart

# Check logs for errors
./docker-test.sh grist-logs
```

### Problem: Tests fail

**Solution:**
```bash
# Ensure dependencies are installed
docker-compose run --rm flutter-shell flutter pub get

# Run tests with verbose output
docker-compose run --rm flutter-test --verbose
```

## Need Help?

- 📖 See **README_DOCKER.md** for detailed Docker documentation
- 📖 See **DAILY_USAGE.md** for daily workflow guide
- 🐛 Report issues at: https://github.com/yourusername/flutterGristAPI/issues
