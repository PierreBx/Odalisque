// Data Admin Documentation - FlutterGristAPI
// For data integrity and backup managers

#import "../common/styles.typ": *
#import "../common/glossary.typ": glossary

// Apply standard document styling
#apply_standard_styles()

// Document header
#doc_header(
  "Data Admin Guide",
  subtitle: "Data Integrity & Backup Management",
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

#include "backup-strategies.typ"
#pagebreak()

#include "data-integrity.typ"
#pagebreak()

#include "disaster-recovery.typ"
#pagebreak()

#include "commands.typ"
#pagebreak()

#include "troubleshooting.typ"
#pagebreak()

#include "reference.typ"
#pagebreak()

// Glossary
#glossary()
