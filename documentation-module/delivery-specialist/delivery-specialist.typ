// Delivery Specialist Documentation - FlutterGristAPI
// For CI/CD pipeline managers and deployment specialists

#import "../common/styles.typ": *
#import "../common/glossary.typ": glossary

// Apply standard document styling
#apply_standard_styles()

// Document header
#doc_header(
  "Delivery Specialist Guide",
  subtitle: "CI/CD Pipelines & Deployment",
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

#include "cicd-pipeline.typ"
#pagebreak()

#include "deployment.typ"
#pagebreak()

#include "testing.typ"
#pagebreak()

#include "commands.typ"
#pagebreak()

#include "troubleshooting.typ"
#pagebreak()

#include "reference.typ"
#pagebreak()

// Glossary
#glossary()
