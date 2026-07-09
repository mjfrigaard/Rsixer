# Tooltip Module

A lightweight UI helper that wraps several tooltip/popover/modal
back-ends behind a single, consistent interface. Drop it anywhere inside
a UI or another module — no paired server function is required.

## Usage

``` r
mod_tooltip(
  trigger = bsicons::bs_icon("info-circle"),
  type = c("bslib", "shinyhelper", "prompter", "shinyalert"),
  contents = "",
  size = NULL,
  style = NULL,
  helper_type = c("inline", "markdown"),
  helper_size = c("m", "s", "l"),
  alert_type = c("info", "success", "warning", "error"),
  ...
)
```

## Arguments

- trigger:

  A `shiny.tag` (or plain text) that the tooltip attaches to. Defaults
  to a small `bsicons::bs_icon("info-circle")`.

- type:

  Back-end to use. One of `"bslib"` (default), `"shinyhelper"`,
  `"prompter"`, or `"shinyalert"`.

- contents:

  Character string or vector — the tooltip/popover/modal body. HTML is
  accepted for `"bslib"`. For `"shinyhelper"` a plain-text character
  vector is preferred — elements are joined with `<br>` by
  `helper(type = "inline")`, so embedding HTML tags causes
  double-escaping. Ignored as plain text by `"prompter"`. For
  `"shinyalert"` HTML is supported (rendered via `html: true`).

- size:

  CSS font-size for the trigger wrapper span, e.g. `"0.85rem"`. `NULL`
  (default) leaves the font size unchanged. Note: this is purely a CSS
  property on the wrapper — it is distinct from `helper_size` (the
  shinyhelper modal size).

- style:

  Additional inline CSS for the trigger wrapper, e.g. `"color:#6c757d"`.
  `NULL` (default) applies none.

- helper_type:

  Content type forwarded to
  [`shinyhelper::helper()`](https://rdrr.io/pkg/shinyhelper/man/helper.html)
  as its `type` argument. One of `"inline"` (default) or `"markdown"`.
  Ignored by all other back-ends.

- helper_size:

  Modal size forwarded to
  [`shinyhelper::helper()`](https://rdrr.io/pkg/shinyhelper/man/helper.html)
  as its `size` argument. One of `"s"`, `"m"` (default), or `"l"`.
  Ignored by all other back-ends. Kept separate from `size` to avoid the
  two params colliding.

- alert_type:

  Alert style forwarded to `shinyalert()` as its `type` argument. One of
  `"info"` (default), `"success"`, `"warning"`, or `"error"`. Ignored by
  all other back-ends.

- ...:

  Extra arguments forwarded directly to the underlying back-end
  function:

  - `"bslib"` →
    [`bslib::popover()`](https://rstudio.github.io/bslib/reference/popover.html)
    (e.g. `title`, `placement`)

  - `"shinyhelper"` →
    [`shinyhelper::helper()`](https://rdrr.io/pkg/shinyhelper/man/helper.html)
    (e.g. `title`, `colour`, `icon`, `buttonLabel`, `easyClose`, `fade`)

  - `"prompter"` →
    [`prompter::add_prompt()`](https://rdrr.io/pkg/prompter/man/add_prompt.html)
    (e.g. `position`, `rounded`, `bounce`, `arrow`, `animate`)

  - `"shinyalert"` → stored as `data-sa-*` attributes; recognised keys
    are `title` and `confirmButtonText`

## Value

A `shiny.tag` (or `shiny.tagList`) ready to embed in any UI.

## `shinyalert` usage in UI

`type = "shinyalert"` requires a delegated `jQuery` click handler
injected into the page. See
[`app_ui()`](https://mjfrigaard.github.io/Rsixer/reference/app_ui.md)
for an example.

## Examples

``` r
if (FALSE) { # \dontrun{
# bslib popover (click to open)
mod_tooltip(
  type     = "bslib",
  contents = "A <b>bslib</b> popover with HTML.",
  title    = "More info"
)

# shinyhelper inline help modal
mod_tooltip(
  trigger     = shiny::tags$span("Sharpe Ratio"),
  type        = "shinyhelper",
  contents    = c("Sharpe Ratio", "Assumes a zero risk-free rate."),
  helper_type = "inline",
  helper_size = "m",
  title       = "Sharpe Ratio"
)

# prompter attribute-driven tooltip
mod_tooltip(
  trigger  = bsicons::bs_icon("info-circle"),
  type     = "prompter",
  contents = "Number of trading days in the rolling window.",
  position = "right"
)

# shinyalert modal on click (requires sa-handler in app_ui)
mod_tooltip(
  trigger    = shiny::tags$span("What is ann. vol?"),
  type       = "shinyalert",
  contents   = "Annualised volatility = SD of daily log returns x sqrt(252).",
  title      = "Annualised Volatility",
  alert_type = "info"
)
} # }
```
