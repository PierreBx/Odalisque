// Grist Manager Documentation - FlutterGristAPI
// For Grist database administrators and schema managers

#import "../common/styles.typ": *
#import "../common/glossary.typ": glossary
#import "../common/grist-fundamentals.typ": grist_basics

// Apply standard document styling
#apply_standard_styles()

// Document header
#doc_header(
  "Grist Manager Guide",
  subtitle: "Database Administration & Schema Management",
  version: "0.1.0"
)

// Table of contents
#outline(indent: true, depth: 3)

#pagebreak()

// Include all sections
#include "overview.typ"
#pagebreak()

#include "quickstart.typ"
#pagebreak()

#include "schema-management.typ"
#pagebreak()

#include "user-management.typ"
#pagebreak()

#include "data-operations.typ"
#pagebreak()

#include "commands.typ"
#pagebreak()

#include "troubleshooting.typ"
#pagebreak()

#include "reference.typ"
#pagebreak()

// Glossary
#glossary()
