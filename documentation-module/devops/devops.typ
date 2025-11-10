// DevOps Documentation - FlutterGristAPI
// For infrastructure and operations specialists

#import "../common/styles.typ": *
#import "../common/glossary.typ": glossary
#import "../common/docker-basics.typ": docker_fundamentals

// Apply standard document styling
#apply_standard_styles()

// Document header
#doc_header(
  "DevOps Guide",
  subtitle: "Infrastructure & Operations",
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

#include "docker-setup.typ"
#pagebreak()

#include "monitoring.typ"
#pagebreak()

#include "security.typ"
#pagebreak()

#include "commands.typ"
#pagebreak()

#include "troubleshooting.typ"
#pagebreak()

#include "reference.typ"
#pagebreak()

// Glossary
#glossary()
