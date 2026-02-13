// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)

#set page(
  paper: "us-letter",
  margin: (x: 1in,y: 1in,),
  numbering: "1",
)

#show: doc => article(
  title: [Example: Poisson Regression],
  font: ("IBM Plex Sans",),
  fontsize: 10pt,
  toc: true,
  toc_title: [Contents],
  toc_depth: 2,
  cols: 1,
  doc,
)

#block[
```julia
using DataFrames
using CSV
using Statistics
using Distributions
using Optim
using Plots
using StatsPlots
```

]
This is an example of setting up, fitting, checking, and modifying a generalized linear model (GLM). We'll use a dataset of fish caught by visitors at a National Park:

```julia
fish = CSV.File("data/Fish.csv") |> DataFrame
fish[1:3, :]
```

```
3×6 DataFrame
 Row │ fish_caught  livebait  camper  persons  child  hours   
     │ Int64        Int64     Int64   Int64    Int64  Float64 
─────┼────────────────────────────────────────────────────────
   1 │           0         0       0        1      0   21.124
   2 │           0         1       1        1      0    5.732
   3 │           0         1       0        1      0    1.323
```

The data includes the number of fish caught by visitors, whether they used live bait, whether they brought a camper van, the number of children and persons in the party, and how many hours they spent in the park.

= Exploratory Analysis
<exploratory-analysis>
Let's plot a histogram of the number of caught fish (our response variable), as well as explore the relationship between the potential predictors and the response.

```julia
histogram(fish.fish_caught, xlabel="Number of Fish Caught", ylabel="Count", legend=false)
```

#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-hist-output-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Histogram of the number of fish caught.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-hist>


We can see from #strong[?\@fig-fish-count] that there are quite a large number of zeros, and the data is quite dispersed: it has a mean of 3.3 and a variance of 135.4.

```julia
p1 = boxplot(fish.livebait, fish.fish_caught, xlabel="Live Bait Use", ylabel="Fish Caught", legend=false)
p2 = boxplot(fish.camper, fish.fish_caught, xlabel="Camper Van Use", ylabel="Fish Caught", legend=false)
p3 = boxplot(fish.child, fish.fish_caught, xlabel="Number of Children", ylabel="Fish Caught", legend=false)
p4 = boxplot(fish.persons, fish.fish_caught, xlabel="Number of Persons", ylabel="Fish Caught", legend=false)
p5 = scatter(fish.hours, fish.fish_caught, xlabel="Hours in Park", ylabel="Fish Caught", legend=false)
display(p1)
display(p2)
display(p3)
display(p4)
display(p5)
```

#quarto_super(
kind: 
"quarto-float-fig"
, 
caption: 
[
]
, 
label: 
<fig-fish-scatter>
, 
position: 
bottom
, 
supplement: 
"Figure"
, 
subrefnumbering: 
"1a"
, 
subcapnumbering: 
"(a)"
, 
[
#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-scatter-output-1.svg"))
], caption: figure.caption(
position: bottom, 
[
Exploratory analysis of predictor variable relationship with the number of fish caught.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-scatter-1>


#block[
#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-scatter-output-2.svg"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-scatter-2>


]
#block[
#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-scatter-output-3.svg"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-scatter-3>


]
#block[
#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-scatter-output-4.svg"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-scatter-4>


]
#block[
#figure([
#box(image("poisson-regression_files/figure-typst/fig-fish-scatter-output-5.svg"))
], caption: figure.caption(
separator: "", 
position: bottom, 
[
#block[
]
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fish-scatter-5>


]
]
)
= Poisson Regression
<poisson-regression>
== Model Specification
<model-specification>
A GLM requires us to specify three things:

+ The distribution of the response variable $y$;
+ Link function(s) for the parameters which are modeled;
+ A linear model for the transformed parameters (through the reverse link).

From #ref(<fig-fish-scatter>, supplement: [Figure]), it appears as though there are relationships between the number of fish caught and the live bait, camper, child, and person variables, but not the number of hours (as groups might be doing something other than fishing for a while). The strongest impact are live bait and camper use, so let's see how correlated these are to decide if we ought to include them as separate predictors.

#block[
```julia
@show sum(fish.camper[fish.livebait .== 0]) / nrow(fish);
@show sum(fish.camper[fish.livebait .== 1]) / nrow(fish);
@show sum(fish.livebait[fish.camper .== 0]) / nrow(fish);
```

#block[
```
sum(fish.camper[fish.livebait .== 0]) / nrow(fish) = 0.064
sum(fish.camper[fish.livebait .== 1]) / nrow(fish) = 0.524
sum(fish.livebait[fish.camper .== 0]) / nrow(fish) = 0.34
```

]
]
So only 6.4% of the groups that did not use live bait used a camper, while 52% of the groups that did use live bait used a camper, and 34% of groups which did not use a camper used live bait. That suggests there is a relationship between the two that we could capture with the camper variable, but there could be extra information from the live bait variable.

As a result, we might hypothesize that the number of fish caught is influenced by the number of children (noisy, distracting, impatient) and whether the party brought a camper. We'll hold off on including the live bait variable for now. As we're modeling counts of caught fish, a Poisson distribution is the typical starting point#footnote[As noted earlier, the variance of the caught fish distribution is much larger than the mean, which would normally suggest that a Poisson distribution is not a good choice. However, that is the distribution #emph[after the influence of covariates];, which would produce different Poissons for different predictors and could result in that level of overdispersion. We can't know without fitting the model and testing it if the distribution predicted by the GLM will have these properties! It's important not to over-interpret the raw histogram.];, and the most flexible link for the Poisson rate $lambda$ is the log. This would give us the following GLM:

$ y_i & tilde.op upright("Poisson") (lambda_i)\
f (lambda_i) & = beta_0 + beta_1 upright("child")_i + beta_2 upright("camper")_i $

== Fitting The Poisson Model
<fitting-the-poisson-model>
We'll use numerical optimization to fit the model, using the basic optimization routine `Optim.optimize()`. We won't tweak the settings and will give the optimizer a pretty broad range of parameters to work with.

#block[
```julia
function fish_model(params, child, camper, fish_caught)
    β₀, β₁, β₂ = params
    λ = exp.(β₀ .+ β₁ * child + β₂ * camper)
    ll = sum(logpdf.(Poisson.(λ), fish_caught))
    return ll
end

lb = [-100.0, -100.0, -100.0] # lower bounds
ub = [100.0, 100.0, 100.0] # upper bounds
init = [0.0, 0.0, 0.0] # initial guesses

optim_out = optimize(θ -> -fish_model(θ, fish.child, fish.camper, fish.fish_caught), lb, ub, init)
θ_mle = optim_out.minimizer
@show round.(θ_mle; digits=2);
@show round.(exp.(θ_mle); digits=2);
```

#block[
```
round.(θ_mle; digits = 2) = [0.91, -1.23, 1.05]
round.(exp.(θ_mle); digits = 2) = [2.48, 0.29, 2.87]
```

]
]
So, #strong[under this model specification];, the base odds of catching a fish are 2.5, which are decreased by a factor of 0.29 for every additional child in the group, and increased by a factor of almost 3 if a camper is used. How do we know if this model works well?
