## 0.1.0

### Initial Release - YAML-Driven App Generator

#### Core Architecture
* Complete YAML configuration parser
* Configuration models for all YAML sections
* Main GristApp widget with multi-provider setup
* Theme utilities for YAML-to-Flutter theme conversion

#### Authentication & Security
* User authentication against Grist users table
* Login page with email/password
* Session management with SharedPreferences
* Role-based access control
* Logout with confirmation dialog

#### Navigation
* Permanent left drawer navigation
* Dynamic menu generation from YAML config
* User profile display in drawer footer
* Conditional visibility based on user roles

#### Page Types
* **Front Page**: Static content with text and images
* **Data Master**: List view of Grist table data with pull-to-refresh
* **Data Detail**: Read-only form view of individual records
* **Admin Dashboard**: System info and database statistics

#### Grist Integration
* Grist API service with authentication
* Fetch records, tables, and columns
* Read-only data display
* Auto-detection of table schemas

#### Expression Engine
* Conditional visibility evaluator
* Support for comparison operators (==, !=, <, >, etc.)
* Support for logical operators (AND, OR)
* User context evaluation (user.role, user.email, etc.)

#### Known Limitations
* Read-only data views (no editing yet)
* Basic table display using ListTiles (not full DataTable)
* Field validators defined but not yet enforced
* SHA256 password hashing (not production-ready)

#### What's Next (v0.2.0)
* Editable forms with validation
* Proper DataTable view with sortable columns
* Search and filter implementation
* Create/update/delete record operations
