# Flutter Grist Widgets

A Flutter library for building complete data-driven applications from Grist using YAML configuration.

## 🗂️ Project Structure

This project is organized into three modules with Docker configuration at the root:

```
flutterGristAPI/
├── docker-compose.yml          # Docker services configuration
├── docker-test.sh              # Helper script for Docker commands
├── .env.example                # Environment configuration template
├── grist-module/               # Grist data storage
│   └── grist-data/             # Persistent Grist documents
├── flutter-module/             # Flutter library source code
│   ├── lib/                    # Library source
│   ├── test/                   # Unit tests
│   ├── Dockerfile              # Flutter dev environment
│   └── pubspec.yaml            # Dependencies
└── documentation-module/       # Complete documentation
    ├── QUICKSTART.md
    ├── DAILY_USAGE.md
    └── README_DOCKER.md
```

### 📦 Modules

| Module | Description | Quick Start |
|--------|-------------|-------------|
| **[grist-module/](grist-module/)** | Grist persistent data storage | [grist-module/README.md](grist-module/README.md) |
| **[flutter-module/](flutter-module/)** | Flutter library source code, tests, Dockerfile | [flutter-module/README.md](flutter-module/README.md) |
| **[documentation-module/](documentation-module/)** | All documentation and guides | [documentation-module/README.md](documentation-module/README.md) |
| **Root** | Docker Compose, helper scripts, environment config | See above |

## 🚀 Quick Start

### First Time Setup

1. **Read the setup guide:**
   ```bash
   cd documentation-module
   cat QUICKSTART.md
   ```

2. **Set up environment:**
   ```bash
   cp .env.example .env
   # Edit .env and set GRIST_SESSION_SECRET to a random string
   ```

3. **Start Grist server:**
   ```bash
   ./docker-test.sh grist-start
   ```

4. **Access Grist:** http://localhost:8484

5. **Build and test Flutter:**
   ```bash
   ./docker-test.sh build
   ./docker-test.sh all
   ```

### Daily Development

```bash
# Start Grist
./docker-test.sh grist-start

# Make code changes in flutter-module/

# Run tests
./docker-test.sh all

# Stop when done
./docker-test.sh stop-all
```

## 📚 Documentation

Documentation is organized by **user role** in the **[documentation-module/](documentation-module/)** directory.

### 🎯 Find Your Role

| Role | Description | Documentation |
|------|-------------|---------------|
| 👤 **End User** | Using Flutter apps | [View Guide](documentation-module/end-user/) |
| 📝 **App Designer** | Configuring apps via YAML | [View Guide](documentation-module/app-designer/) |
| 🗄️ **Grist Manager** | Managing Grist databases | [View Guide](documentation-module/grist-manager/) |
| 💻 **Flutter Developer** | Extending the library | [View Guide](documentation-module/flutter-developer/) |
| ⚙️ **DevOps** | Infrastructure & operations | [View Guide](documentation-module/devops/) |
| 🚀 **Delivery Specialist** | CI/CD pipelines | [View Guide](documentation-module/delivery-specialist/) |
| 💾 **Data Admin** | Backups & data integrity | [View Guide](documentation-module/data-admin/) |

Each role has comprehensive documentation including:
- **Overview** - Role description & responsibilities
- **Quick Start** - First-time setup guide
- **Commands** - Common operations reference
- **Troubleshooting** - Solutions to common issues
- **Reference** - Complete detailed documentation

### 🌐 Building HTML Documentation

Generate a browsable website from the documentation using Docker (no Python/MkDocs installation needed):

```bash
cd documentation-module
./scripts/build-docs.sh       # Build static site with MkDocs
open site/index.html          # View the website

# OR: Live preview with auto-reload
./scripts/serve-docs.sh       # Opens http://localhost:8000
```

**Prerequisites:** Docker with Compose V2 - no local Python or MkDocs installation required!

### 📖 Complete Documentation

For full details, see **[documentation-module/README.md](documentation-module/README.md)**

## ✨ Features

- 📄 **YAML-Driven** - Define entire apps declaratively
- 🔐 **Built-in Authentication** - Bcrypt password hashing, role-based access
- 🗄️ **Auto-Schema Detection** - Discovers table structures from Grist
- 📊 **Multiple View Types** - Tables, forms, detail pages, admin dashboard
- 🔍 **Search & Filter** - Built-in data table search
- ✅ **Validation** - Rich field validators (required, email, regex, ranges)
- 📎 **File Upload** - Drag & drop file upload widget with image preview
- 📄 **Pagination** - Client-side pagination for large datasets
- 🔀 **Sorting** - Type-aware column sorting

## 🏗️ What's in Each Module?

### grist-module/

**Contains:** Grist data storage

- grist-data/ - Persistent data storage for Grist documents

**Purpose:** Provides persistent storage for Grist documents and data.

### flutter-module/

**Contains:** Flutter library source code and Docker build configuration

- lib/ - Library source code
  - src/config/ - Configuration parsers
  - src/services/ - Grist API client
  - src/widgets/ - Reusable widgets
  - src/pages/ - Page types
  - src/providers/ - State management
  - src/utils/ - Validators, helpers
- test/ - Unit tests (77 tests)
- example/ - Example configurations
- pubspec.yaml - Dependencies
- Dockerfile - Flutter development environment with proper user management

**Purpose:** The actual Flutter library that developers import to build Grist-powered apps.

### documentation-module/

**Contains:** All project documentation

- QUICKSTART.md - Getting started guide
- DAILY_USAGE.md - Daily workflow
- README_DOCKER.md - Docker details
- YAML_SCHEMA.md - Configuration reference
- IMPLEMENTATION_STATUS.md - Feature tracking
- documentation.typ - Comprehensive docs

**Purpose:** Complete documentation for users, developers, and contributors.

## 🔧 Common Tasks

| Task | Command | Location |
|------|---------|----------|
| Start Grist | `./docker-test.sh grist-start` | Root |
| Run tests | `./docker-test.sh all` | Root |
| View logs | `./docker-test.sh grist-logs` | Root |
| Edit code | Use your IDE | flutter-module/ |
| Read docs | Open markdown files | documentation-module/ |

## 📊 Version

Current version: **v0.3.0**

### Recent Updates

- **v0.3.0** - File uploads, pagination, sorting
- **v0.2.0** - CRUD operations, enhanced features
- **v0.1.1** - Security fixes, validation, tests
- **v0.1.0** - Initial release

## 🐛 Troubleshooting

**Grist won't start:**
```bash
cd grist-module
./docker-test.sh grist-logs
```

**Tests fail:**
```bash
cd grist-module
./docker-test.sh build
./docker-test.sh all
```

**Need detailed help:**
- See [documentation-module/README_DOCKER.md](documentation-module/README_DOCKER.md)
- See [documentation-module/QUICKSTART.md](documentation-module/QUICKSTART.md)

## 📖 Learning Path

1. **New to the project?**
   - Find your role in the [Documentation](#-documentation) section above
   - Start with your role's Quick Start guide

2. **Using the app** (End User):
   - [End User Quick Start](documentation-module/end-user/quickstart.md)
   - Learn login, navigation, and data viewing

3. **Designing apps** (App Designer):
   - [App Designer Quick Start](documentation-module/app-designer/quickstart.md)
   - Create YAML configurations and design pages

4. **Managing Grist** (Grist Manager):
   - [Grist Manager Quick Start](documentation-module/grist-manager/quickstart.md)
   - Set up tables, users, and schemas

5. **Developing the library** (Flutter Developer):
   - [Flutter Developer Quick Start](documentation-module/flutter-developer/quickstart.md)
   - Set up dev environment and contribute code

6. **Operating infrastructure** (DevOps):
   - [DevOps Quick Start](documentation-module/devops/quickstart.md)
   - Configure Docker, monitoring, and security

7. **Managing CI/CD** (Delivery Specialist):
   - [Delivery Specialist Quick Start](documentation-module/delivery-specialist/quickstart.md)
   - Set up pipelines and deployment

8. **Managing data** (Data Admin):
   - [Data Admin Quick Start](documentation-module/data-admin/quickstart.md)
   - Configure backups and disaster recovery

## 🤝 Contributing

1. Fork the repository
2. Make changes in the appropriate module
3. Run tests: `cd grist-module && ./docker-test.sh all`
4. Update documentation if needed
5. Submit a pull request

## 📝 License

See [flutter-module/LICENSE](flutter-module/LICENSE) for details.

## 🔗 Links

- **Grist API Docs:** https://support.getgrist.com/api/
- **Flutter Docs:** https://flutter.dev/docs
- **Docker Docs:** https://docs.docker.com/

## 💡 Example

```yaml
# example/config.yaml
app:
  name: "My Business App"

grist:
  base_url: "http://localhost:8484"
  document_id: "YOUR_DOC_ID"
  api_key: "YOUR_API_KEY"

pages:
  - id: "home"
    type: "data_master"
    title: "Products"
    config:
      grist:
        table: "Products"
```

```dart
// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_grist_widgets/flutter_grist_widgets.dart';

void main() async {
  final config = await AppConfig.loadFromYaml('assets/config.yaml');
  runApp(GristApp(config: config));
}
```

---

**Get started now:** [documentation-module/QUICKSTART.md](documentation-module/QUICKSTART.md) 🚀
