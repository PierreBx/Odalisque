// Common Typst styles and formatting functions for FlutterGristAPI documentation

// Apply standard document settings
#let apply_standard_styles() = {
  set document(author: "FlutterGristAPI Team")
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm))
  set text(font: "Linux Libertine", size: 11pt)
  set heading(numbering: "1.1")

  // Style code blocks
  show raw.where(block: true): it => {
    set block(
      fill: rgb("#f6f8fa"),
      inset: 10pt,
      radius: 4pt,
      width: 100%
    )
    it
  }

  // Style inline code
  show raw.where(block: false): it => {
    box(
      fill: rgb("#f6f8fa"),
      inset: (x: 3pt, y: 0pt),
      outset: (y: 3pt),
      radius: 2pt,
      it
    )
  }
}

// Create a standard document header
#let doc_header(title, subtitle: none, version: "0.1.0") = {
  align(center)[
    #text(size: 24pt, weight: "bold")[#title]

    #if subtitle != none {
      v(1em)
      text(size: 14pt)[#subtitle]
    }

    #v(2em)
    Version #version

    #v(1em)
    #text(size: 10pt, fill: gray)[
      Generated on #datetime.today().display()
    ]
  ]
  v(3em)
}

// Info box styling
#let info_box(content, type: "info") = {
  let colors = (
    info: rgb("#d1ecf1"),
    warning: rgb("#fff3cd"),
    danger: rgb("#f8d7da"),
    success: rgb("#d4edda")
  )

  let titles = (
    info: "ℹ️ Information",
    warning: "⚠️ Warning",
    danger: "🚫 Danger",
    success: "✅ Success"
  )

  box(
    fill: colors.at(type, default: colors.info),
    inset: 1em,
    radius: 4pt,
    width: 100%
  )[
    *#titles.at(type, default: titles.info)*

    #content
  ]
}

// Command reference table
#let command_table(commands) = {
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, left),
    [*Command*], [*Description*], [*Example*],
    ..commands.map(c => (
      raw(c.command),
      c.description,
      if "example" in c { raw(c.example) } else { [] }
    )).flatten()
  )
}

// Troubleshooting table
#let troubleshooting_table(issues) = {
  table(
    columns: (1fr, 1.5fr, 0.5fr),
    align: (left, left, left),
    [*Issue*], [*Solution*], [*Priority*],
    ..issues.map(i => (
      i.issue,
      i.solution,
      if i.priority == "high" { text(fill: red)[HIGH] }
      else if i.priority == "medium" { text(fill: orange)[MED] }
      else { text(fill: gray)[LOW] }
    )).flatten()
  )
}

// Section separator
#let section_separator() = {
  v(1em)
  line(length: 100%, stroke: 0.5pt + gray)
  v(1em)
}

// Footer with page numbers
#let standard_footer() = {
  set align(center)
  set text(size: 9pt, fill: gray)
  counter(page).display("1 / 1", both: true)
}
