#if subtitle != none {
      v(1em)
      text(size: 14pt)[#subtitle]
    }

    Version #version

      Generated on #datetime.today().display()
    ]

  v(3em)
}

    *#titles.at(type, default: titles.info)*

    #content

}

*Command*, [*Description*], [*Example*],
    ..commands.map(c => (
      raw(c.command),
      c.description,
      if "example" in c { raw(c.example) } else { [] }
    )).flatten()
  )
}

*Issue*, [*Solution*], [*Priority*],
    ..issues.map(i => (
      i.issue,
      i.solution,
      if i.priority == "high" { text(fill: red)[HIGH] }
      else if i.priority == "medium" { text(fill: orange)[MED] }
      else { text(fill: gray)[LOW] }
    )).flatten()
  )
}

  v(1em)
  line(length: 100%, stroke: 0.5pt + gray)
  v(1em)
}

  set align(center)
  set text(size: 9pt, fill: gray)
  counter(page).display("1 / 1", both: true)
}
