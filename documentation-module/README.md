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

Install Typst (documentation compiler):

**macOS:**
```bash
brew install typst
```

**Linux:**
```bash
# Using cargo (Rust package manager)
cargo install --git https://github.com/typst/typst

# Or download binary from releases
# https://github.com/typst/typst/releases
```

**Verify installation:**
```bash
typst --version
```

### Build HTML Website

Generate the complete HTML documentation website:

```bash
cd documentation-module
./scripts/generate-html.sh
```

This creates:
- `build/index.html` - Landing page with role selector
- `build/end-user.html` - End User documentation
- `build/app-designer.html` - App Designer documentation
- `build/grist-manager.html` - Grist Manager documentation
- `build/flutter-developer.html` - Flutter Developer documentation
- `build/devops.html` - DevOps documentation
- `build/delivery-specialist.html` - Delivery Specialist documentation
- `build/data-admin.html` - Data Admin documentation
- `build/styles.css` - Website styling

**View the website:**

```bash
# macOS
open build/index.html

# Linux
xdg-open build/index.html

# Windows
start build/index.html
```

### Build Individual PDFs

Generate PDF for a specific role:

```bash
cd documentation-module

# End User
typst compile end-user/end-user.typ build/end-user.pdf

# App Designer
typst compile app-designer/app-designer.typ build/app-designer.pdf

# Grist Manager
typst compile grist-manager/grist-manager.typ build/grist-manager.pdf

# Flutter Developer
typst compile flutter-developer/flutter-developer.typ build/flutter-developer.pdf

# DevOps
typst compile devops/devops.typ build/devops.pdf

# Delivery Specialist
typst compile delivery-specialist/delivery-specialist.typ build/delivery-specialist.pdf

# Data Admin
typst compile data-admin/data-admin.typ build/data-admin.pdf
```

### Build All PDFs

```bash
cd documentation-module

for role in end-user app-designer grist-manager flutter-developer devops delivery-specialist data-admin; do
    typst compile $role/$role.typ build/$role.pdf
    echo "✅ Built $role.pdf"
done
```

## Documentation Format

All documentation is written in **Typst** format (`.typ` files), which provides:

- Professional typesetting
- Consistent formatting
- Table of contents generation
- Cross-referencing
- Code syntax highlighting
- PDF and HTML output

### Why Typst?

- **Modern**: Next-generation markup language for documents
- **Fast**: Compiles quickly, even for large documents
- **Readable**: Clean syntax, easy to edit
- **Version Control Friendly**: Text-based format works great with Git
- **Multi-format**: Generate HTML, PDF, PNG from same source

## Quick Start by Role

### I'm an End User
**Start here:** [end-user/quickstart.typ](end-user/quickstart.typ)
- Learn how to log in and navigate the app
- View and search data
- Understand your role and permissions

### I'm an App Designer
**Start here:** [app-designer/quickstart.typ](app-designer/quickstart.typ)
- Create your first YAML configuration
- Design pages and navigation
- Map Grist tables to app views

### I'm a Grist Manager
**Start here:** [grist-manager/quickstart.typ](grist-manager/quickstart.typ)
- Set up your first Grist document
- Create the Users table
- Generate API keys

### I'm a Flutter Developer
**Start here:** [flutter-developer/quickstart.typ](flutter-developer/quickstart.typ)
- Set up development environment
- Run tests
- Make your first contribution

### I'm DevOps
**Start here:** [devops/quickstart.typ](devops/quickstart.typ)
- Set up Docker environment
- Configure services
- Monitor infrastructure

### I'm a Delivery Specialist
**Start here:** [delivery-specialist/quickstart.typ](delivery-specialist/quickstart.typ)
- Set up Concourse CI/CD
- Deploy pipelines
- Automate releases

### I'm a Data Admin
**Start here:** [data-admin/quickstart.typ](data-admin/quickstart.typ)
- Set up backup system
- Configure disaster recovery
- Monitor data integrity

## Contributing to Documentation

### Editing Documentation

1. Edit `.typ` files in the appropriate role directory
2. Use Typst syntax for formatting
3. Import common modules when needed:
   ```typst
   #import "../common/styles.typ": *
   #import "../common/glossary.typ": glossary
   ```

4. Rebuild to see changes:
   ```bash
   ./scripts/generate-html.sh
   ```

### Adding New Sections

1. Create new `.typ` file in role directory
2. Include it in the master file (e.g., `app-designer/app-designer.typ`):
   ```typst
   #include "new-section.typ"
   ```

3. Rebuild documentation

### Documentation Standards

- **Clear headings**: Use hierarchical structure (=, ==, ===)
- **Code blocks**: Use ` ```language ` for code examples
- **Tables**: Use Typst table syntax for structured data
- **Info boxes**: Use `info_box()` for tips, warnings, errors
- **Commands**: Use `command_table()` for command references
- **Troubleshooting**: Use `troubleshooting_table()` for issues

## Resources

- **Typst Documentation**: https://typst.app/docs
- **Typst Tutorial**: https://typst.app/docs/tutorial/
- **Typst GitHub**: https://github.com/typst/typst
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

**Documentation Version**: 0.1.0
**Last Updated**: 2025-01-10
