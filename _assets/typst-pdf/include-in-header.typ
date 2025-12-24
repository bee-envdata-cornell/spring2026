// Get these values from the YAML and make them typst variables because writing
// out shortcodes all the time is messy
#let header-left = [{{< meta pdf-header-left >}}]
#let header-right = [{{< meta pdf-header-right >}}]
#let footer-left = [{{< meta pdf-footer-left >}}]


// H1
#show heading.where(level: 1): it => {
  block(
    width: 100%,
    above: 1.5em,
    below: 0.8em,
    stroke: (bottom: 1pt + luma(170)),
    inset: (bottom: 0.4em),
    [
      #set text(size: 1em)
      #it
    ]
  )
}

// H2
#show heading.where(level: 2): it => {
  set text(size: 0.95em)
  set block(above: 1.5em, below: 0.8em)
  it
}

// H6 - headings in the course details section
#show heading.where(level: 6): it => {
  set text(size: 1.1em)
  set block(below: 0.8em)
  it
}


// Center tables in the .centered-table div
#let centered-table(body) = {
  align(center, body)
}

// ...aaaand center tables in the .schedule-table div too
#let schedule-table(body) = {
  // set text(size: 0.85em)
  align(center, body)
}


// 3-column course details section that replicates the Bootstrap grid divs ----
#let grid-col(body) = body

#let course-details(body) = {
  block(
    fill: luma(240),
    inset: 1em,
    above: 2em,
    below: 2em,
    width: 100%,
    {
      set text(size: 0.9em)
      // Get rid of empty elements
      let cols = body.children.filter(c => c != [ ] and c != [
])
      grid(
        columns: 3,
        gutter: 2em,
        ..cols
      )
    }
  )
}


// Restyle Quarto callout boxes since they're a little too spacy
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    stroke: (
      left: 3pt + icon_color,
      top: 0.5pt + icon_color,
      right: 0.5pt + icon_color,
      bottom: 0.5pt + icon_color
    ),
    radius: 2pt,
    width: 100%,
    [
      #set text(size: 0.9em)
      #set par(leading: 0.65em)
      #block(
        fill: background_color,
        inset: 0.5em,
        width: 100%,
        below: 0pt,
        text(icon_color, weight: "bold")[#icon #title]
      )
      #block(
        fill: body_background_color,
        inset: 0.5em,
        width: 100%,
        body
      )
    ]
  )
}


// Restyle and reformat the title area
#let original-article = article

#let article(
  title: none,
  subtitle: none,
  ..args,
  doc
) = {
  let remaining = args.named()

  set align(left)

  // Title and logo side by side
  if title != none {
    grid(
      columns: (1fr, auto),
      column-gutter: 1em,
      align: (left, right),

      // Left column: title and subtitle
      block(inset: (bottom: 1.5em))[
        #block(
          below: 2em,
          text(font: "IBM Plex Sans", size: 2em, weight: "bold")[#title]
        )
        #if subtitle != none {
          block(
            above: 0em,
            text(font: "IBM Plex Sans", size: 1.2em, weight: "regular")[#subtitle]
          )
        }
      ],

      // Right column: logo
      align(horizon)[
        #image("_assets/logos/envdata_logo.png", width: 1in)
      ]
    )
  }

  original-article(
    title: none,
    subtitle: none,
    ..remaining,
    doc
  )
}

// Running header and footer
#set page(
  header: context {
    if counter(page).get().first() > 1 {
      set text(font: "IBM Plex Sans", size: 0.8em)
      grid(
        columns: (1fr, 1fr),
        align: (left, right),
        header-left,
        header-right
      )
    }
  },
  footer: context [
    #set text(font: "IBM Plex Sans", size: 0.8em)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      footer-left,
      counter(page).display("1")
    )
  ]
)

// General global styling stuff
#show par: set par(justify: false)  // This has to come at the end of this file
#set text(hyphenate: false)
#show link: set text(fill: rgb("#9f2d55"))