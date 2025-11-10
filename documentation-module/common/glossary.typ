// Common terminology and glossary for FlutterGristAPI

#let glossary() = [
  = Glossary

  == General Terms

  / FlutterGristAPI: A YAML-driven Flutter application generator that creates complete data-driven applications from Grist databases.

  / YAML: YAML Ain't Markup Language - a human-readable data serialization format used to configure applications.

  / Grist: An open-source spreadsheet-database hybrid that provides structured data storage with a spreadsheet-like interface.

  == Roles

  / End User: A person who uses the Flutter application generated from the YAML configuration. They interact with the app's UI to view and manage data.

  / App Designer: The person responsible for creating and maintaining the YAML configuration file that describes the application structure and behavior. Also known as YAML Configuration Manager.

  / Grist Manager: The administrator responsible for managing Grist databases, including schema design, user management, and data operations.

  / Flutter Developer: A software developer who extends or modifies the FlutterGristAPI library itself, adding new features or fixing bugs.

  / DevOps: The technical specialist responsible for infrastructure, Docker containers, monitoring, and security operations.

  / Delivery Specialist: The CI/CD pipeline manager responsible for automated testing, deployment, and release processes.

  / Data Admin: The specialist responsible for backup strategies, data integrity checks, and disaster recovery procedures.

  == Technical Terms

  / API Key: A secret token used to authenticate with the Grist API. Generated in Grist settings.

  / Document ID: The unique identifier for a Grist document, found in the document's URL.

  / Table: A structured collection of records in Grist, similar to a database table or spreadsheet.

  / Record: A single row in a Grist table, representing one data item.

  / Column: A field in a Grist table that defines a data attribute (e.g., name, email, price).

  / Schema: The structure definition of a Grist table, including column names, types, and constraints.

  / Master-Detail: A UI pattern where a list view (master) navigates to a detailed view (detail) when an item is selected.

  / Data Master Page: A page type that displays tabular data from a Grist table with search, sort, and pagination features.

  / Data Detail Page: A page type that displays a single record as a form, allowing users to view detailed information.

  / Front Page: A static content page with text and images, used for welcome screens or informational content.

  / Admin Dashboard: A special page type that displays system statistics, active users, and database metrics.

  / Conditional Visibility: A feature that shows or hides UI elements based on user roles or data values using expression rules.

  / Field Validation: Rules that ensure data entered into forms meets specific requirements (e.g., required, email format, numeric range).

  / Record Number: An auto-generated sequential number assigned to each record, independent of Grist's internal ID.

  / Drawer Navigation: A sliding menu panel that appears from the left side of the screen, containing navigation links.

  == Docker Terms

  / Container: A lightweight, standalone package that includes application code and all its dependencies.

  / Docker Compose: A tool for defining and running multi-container Docker applications using a YAML file.

  / Volume: Persistent storage for Docker containers that survives container restarts.

  / Image: A template used to create Docker containers, containing the application and its environment.

  == CI/CD Terms

  / Pipeline: An automated workflow that builds, tests, and deploys code changes.

  / Concourse: An open-source CI/CD system that runs tasks in containers.

  / Deployment: The process of releasing application code to a production or staging environment.

  / Artifact: A file produced by the build process, such as a compiled binary or package.

  == Data Management Terms

  / Backup: A copy of data stored separately to enable recovery in case of data loss.

  / Disaster Recovery: Procedures and plans for restoring systems and data after a catastrophic failure.

  / Data Integrity: The accuracy, consistency, and reliability of data throughout its lifecycle.

  / Snapshot: A point-in-time copy of data that can be used for backup or recovery purposes.
]
