# FlutterGristAPI Documentation

Comprehensive, role-based documentation for the FlutterGristAPI project.

## Overview

This documentation is organized by **user type**, providing targeted information for each role involved in the FlutterGristAPI ecosystem.

## Documentation Structure

### By Role

Each role has its own dedicated documentation with consistent sections:

#### 📚 **Documentation Roles**

| Role | Description | Documentation |
|------|-------------|---------------|
| 👤 **End User** | Uses the generated Flutter applications | [end-user/](end-user/) |
| 📝 **App Designer** | Configures apps via YAML | [app-designer/](app-designer/) |
| 🗄️ **Grist Manager** | Manages Grist databases and schemas | [grist-manager/](grist-manager/) |
| 💻 **Flutter Developer** | Develops and extends the library | [flutter-developer/](flutter-developer/) |
| ⚙️ **DevOps** | Manages infrastructure and operations | [devops/](devops/) |
| 🚀 **Delivery Specialist** | Manages CI/CD pipelines and deployment | [delivery-specialist/](delivery-specialist/) |
| 💾 **Data Admin** | Manages backups and data integrity | [data-admin/](data-admin/) |

### Standard Sections

Each role's documentation includes:

1. **Overview** - Role description, responsibilities, prerequisites
2. **Quick Start** - First-time setup guide (5-30 minutes)
3. **Commands/Actions** - Reference of common operations
4. **Troubleshooting** - Common issues and solutions
5. **Reference** - Complete detailed documentation

Some roles have additional specialized sections (e.g., YAML Schema for App Designer, Architecture for Flutter Developer).

## Building the Documentation

### Prerequisites

**Docker** is required to build the documentation. No local Python or MkDocs installation needed!

**Verify Docker is installed:**
```bash
docker --version
docker compose version
```

If you don't have Docker, install it from: https://docs.docker.com/get-docker/

### Build Static Website

Generate the complete HTML documentation website:

```bash
cd documentation-module
./scripts/build-docs.sh
```

**What happens:**
1. Docker pulls the Python image with MkDocs (first time only)
2. Builds a custom image with MkDocs Material theme
3. Compiles all Markdown files to a static website
4. Generates navigation, search index, and styling

**Output:**
- `site/` directory containing the complete static website
- `site/index.html` - Main landing page
- Full navigation with search functionality
- Role-based documentation sections
- Mobile-responsive design

**View the website:**

```bash
# macOS
open site/index.html

# Linux
xdg-open site/index.html

# Windows
start site/index.html
```

### Live Preview Server

For documentation development, use the live preview server with auto-reload:

```bash
cd documentation-module
./scripts/serve-docs.sh
```

**What happens:**
- Starts a local web server at http://localhost:8000
- Watches for file changes
- Automatically rebuilds and refreshes the browser
- Perfect for writing and editing documentation

**Stop the server:** Press `Ctrl+C`

## Documentation Format

All documentation is written in **Markdown** format (`.md` files), which provides:

- Universal format supported everywhere
- Easy to read and edit
- Great for version control
- Compatible with all static site generators
- Supports code blocks, tables, and rich formatting

### Why Markdown + MkDocs?

- **Mature Ecosystem**: Battle-tested with thousands of projects
- **Powerful Search**: Built-in search functionality
- **Beautiful Themes**: Material Design theme included
- **Fast**: Quick builds even for large documentation
- **Extensible**: Plugins for diagrams, code highlighting, etc.
- **Mobile Friendly**: Responsive design works on all devices

## Quick Start by Role

### I'm an End User
**Start here:** [end-user/quickstart.md](end-user/quickstart.md)
- Learn how to log in and navigate the app
- View and search data
- Understand your role and permissions

### I'm an App Designer
**Start here:** [app-designer/quickstart.md](app-designer/quickstart.md)
- Create your first YAML configuration
- Design pages and navigation
- Map Grist tables to app views

### I'm a Grist Manager
**Start here:** [grist-manager/quickstart.md](grist-manager/quickstart.md)
- Set up your first Grist document
- Create the Users table
- Generate API keys

### I'm a Flutter Developer
**Start here:** [flutter-developer/quickstart.md](flutter-developer/quickstart.md)
- Set up development environment
- Run tests
- Make your first contribution

### I'm DevOps
**Start here:** [devops/quickstart.md](devops/quickstart.md)
- Set up Docker environment
- Configure services
- Monitor infrastructure

### I'm a Delivery Specialist
**Start here:** [delivery-specialist/quickstart.md](delivery-specialist/quickstart.md)
- Set up Concourse CI/CD
- Deploy pipelines
- Automate releases

### I'm a Data Admin
**Start here:** [data-admin/quickstart.md](data-admin/quickstart.md)
- Set up backup system
- Configure disaster recovery
- Monitor data integrity

## Contributing to Documentation

### Editing Documentation

1. Edit `.md` files in the appropriate role directory
2. Use standard Markdown syntax for formatting
3. Preview changes using the live server:
   ```bash
   ./scripts/serve-docs.sh
   ```
4. View at http://localhost:8000

### Adding New Sections

1. Create new `.md` file in role directory
2. Add it to `mkdocs.yml` navigation:
   ```yaml
   nav:
     - Role Name:
       - New Section: role-name/new-section.md
   ```
3. Preview changes with `./scripts/serve-docs.sh`

### Documentation Standards

- **Clear headings**: Use hierarchical structure (`#`, `##`, `###`)
- **Code blocks**: Use triple backticks with language specifier
- **Tables**: Use Markdown pipe tables
- **Admonitions**: Use blockquotes with prefixes (> Note:, > Warning:)
- **Links**: Use relative paths for internal links

### Markdown Tips

```markdown
# H1 Heading
## H2 Heading
### H3 Heading

**bold text**
*italic text*

- Bullet list
- Item 2

1. Numbered list
2. Item 2

[Link text](path/to/file.md)

> Note: This is an informational callout

> Warning: This is a warning

`inline code`

```bash
# code block
command here
```
```

## MkDocs Configuration

The site is configured in `mkdocs.yml`:

- **Theme**: Material for MkDocs
- **Features**: Tabs, search, syntax highlighting
- **Navigation**: Role-based hierarchy
- **Extensions**: Admonitions, tables, code highlighting

To customize:
1. Edit `mkdocs.yml`
2. See [MkDocs documentation](https://www.mkdocs.org/)
3. See [Material theme docs](https://squidfunk.github.io/mkdocs-material/)

## Resources

- **MkDocs Documentation**: https://www.mkdocs.org/
- **Material for MkDocs**: https://squidfunk.github.io/mkdocs-material/
- **Markdown Guide**: https://www.markdownguide.org/
- **Material Icons** (for menu icons): https://fonts.google.com/icons
- **Grist API**: https://support.getgrist.com/api/

## License

This documentation is part of the FlutterGristAPI project and is licensed under the MIT License.

## Support

If you need help with the documentation:

1. Check the appropriate role's troubleshooting section
2. Review the reference documentation
3. Open an issue on GitHub
4. Contact the project maintainers

---

**Documentation Version**: 0.3.0
**Last Updated**: 2025-11-10
