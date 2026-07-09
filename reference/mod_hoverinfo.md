# Hover-info Module

A server-side helper that formats hover/tooltip content for `reactable`
table cells. Wraps the display value in an `htmltools` `<span>` with a
`title` attribute, which browsers render as a native tooltip on hover.

## Usage

``` r
mod_hoverinfo(
  type = "reactable",
  contents = character(0),
  display = NULL,
  size = NULL,
  style = NULL,
  ...
)
```

## Arguments

- type:

  Back-end to target. Currently only `"reactable"`.

- contents:

  A character string (or named character vector) used as the tooltip
  text in the `title` attribute. Named vectors produce `"Name: value"`
  pairs joined by `" | "`.

- display:

  The value to render visibly inside the cell. Passed as the child node
  of the `<span>`. Kept as an explicit parameter so it is never
  accidentally matched to `size` by positional argument order.

- size:

  CSS font-size for the span wrapper, e.g. `"0.8rem"`. `NULL` (default)
  leaves it unchanged.

- style:

  Inline CSS for the span wrapper, e.g. `"cursor:help"`. `NULL`
  (default) applies none.

- ...:

  Additional HTML attributes passed to the `<span>` tag.

## Value

An `htmltools` `<span>` tag with a `title` attribute set. Use inside a
`reactable::colDef(cell = ..., html = TRUE)` renderer.

## Examples

``` r
if (FALSE) { # \dontrun{
reactable::colDef(
  name = "Ann. Return (%)",
  html = TRUE,
  cell = function(value, index) {
    mod_hoverinfo(
      type     = "reactable",
      contents = paste0("Annualised log return: ", value, "%"),
      display  = paste0(value, "%"),
      style    = "color:#198754; cursor:help"
    )
  }
)
} # }
```
