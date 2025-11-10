// System architecture overview for FlutterGristAPI

#import "styles.typ": *

#let architecture_overview() = [
  = System Architecture

  == High-Level Overview

  FlutterGristAPI is a declarative application generator that transforms YAML configuration into fully functional Flutter applications. The system consists of several interconnected modules:

  #figure(
    ```
    ┌─────────────────────────────────────────────────────┐
    │               YAML Configuration                     │
    │            (app_config.yaml)                        │
    └────────────────┬────────────────────────────────────┘
                     │
                     ↓
    ┌────────────────────────────────────────────────────┐
    │          FlutterGristAPI Library                   │
    │  ┌──────────────────────────────────────────────┐  │
    │  │  Config Parser & Validator                   │  │
    │  └──────────────────────────────────────────────┘  │
    │  ┌──────────────────────────────────────────────┐  │
    │  │  App Generator (Pages, Navigation, Auth)     │  │
    │  └──────────────────────────────────────────────┘  │
    │  ┌──────────────────────────────────────────────┐  │
    │  │  Grist API Client                            │  │
    │  └──────────────────────────────────────────────┘  │
    └────────────────┬────────────────────────────────────┘
                     │
                     ↓
    ┌────────────────────────────────────────────────────┐
    │          Generated Flutter App                     │
    │  ┌────────────┐  ┌────────────┐  ┌─────────────┐  │
    │  │   Login    │  │ Navigation │  │   Pages     │  │
    │  │   Screen   │  │   Drawer   │  │ (Master/    │  │
    │  │            │  │            │  │  Detail)    │  │
    │  └────────────┘  └────────────┘  └─────────────┘  │
    └────────────────┬────────────────────────────────────┘
                     │
                     ↓ HTTP/REST
    ┌────────────────────────────────────────────────────┐
    │              Grist Database                        │
    │  ┌────────────┐  ┌────────────┐  ┌─────────────┐  │
    │  │   Users    │  │  Products  │  │   Orders    │  │
    │  │   Table    │  │   Table    │  │   Table     │  │
    │  └────────────┘  └────────────┘  └─────────────┘  │
    └────────────────────────────────────────────────────┘
    ```
  )

  == Component Layers

  === Configuration Layer
  - YAML files define application structure, pages, navigation, and data connections
  - Schema validation ensures configuration correctness
  - Environment-specific configurations (dev, staging, prod)

  === Application Layer
  - *Config Parser*: Reads and validates YAML configuration
  - *App Generator*: Creates Flutter widgets dynamically based on config
  - *Authentication*: Manages user login, sessions, and role-based access
  - *Navigation*: Handles routing between pages and parameter passing
  - *Page Renderer*: Generates appropriate UI for each page type

  === Data Layer
  - *Grist API Client*: Communicates with Grist REST API
  - *Schema Discovery*: Automatically detects table structures
  - *Data Caching*: Improves performance with local caching
  - *Record Management*: Handles CRUD operations on Grist data

  === Presentation Layer
  - *Widgets*: Reusable UI components (tables, forms, cards)
  - *Themes*: Customizable colors and styling
  - *Validation*: Client-side field validation
  - *Error Handling*: User-friendly error messages

  == Data Flow

  === Authentication Flow
  ```
  User enters credentials → App validates against Grist Users table
  → Session created → User role determined → Navigation configured
  ```

  === Page Navigation Flow
  ```
  User selects menu item → Router navigates to page → Page config loaded
  → Grist data fetched → UI rendered with data
  ```

  === Data Fetch Flow
  ```
  Page loads → Check cache → If miss, call Grist API
  → Transform response → Update cache → Render UI
  ```

  == Module Structure

  The project is organized into distinct modules:

  / grist-module: Grist database and API configuration
  / flutter-module: Flutter application code and widgets library
  / documentation-module: Comprehensive documentation for all roles
  / deployment-module: Docker, CI/CD, and deployment configurations

  == Technology Stack

  === Frontend
  - *Flutter*: Cross-platform UI framework (Dart)
  - *Material Design*: UI component library
  - *Provider/Riverpod*: State management

  === Backend
  - *Grist*: Database and API server
  - *REST API*: HTTP-based communication

  === Infrastructure
  - *Docker*: Containerization
  - *Docker Compose*: Multi-container orchestration
  - *Concourse CI*: Continuous integration and deployment
  - *Nginx*: Reverse proxy and SSL termination

  == Security Architecture

  === Authentication
  - Password hashing (bcrypt or Argon2)
  - Session token management
  - Role-based access control (RBAC)

  === API Security
  - API key authentication for Grist
  - HTTPS/TLS encryption
  - Rate limiting and throttling

  === Data Security
  - Encrypted data transmission
  - Secure credential storage
  - Regular security audits

  == Deployment Architecture

  === Development Environment
  ```
  Local machine → Docker Compose → Grist container + App container
  ```

  === Production Environment
  ```
  Load Balancer → Nginx (SSL) → App containers (scaled)
                              → Grist container (with persistent volumes)
  ```

  === CI/CD Pipeline
  ```
  Git push → Concourse detects change → Run tests
  → Build Docker image → Push to registry → Deploy to environment
  ```
]
