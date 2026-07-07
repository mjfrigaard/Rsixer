#' Tooltip Module
#'
#' A lightweight UI helper that wraps several tooltip/popover/modal back-ends
#' behind a single, consistent interface.  Drop it anywhere inside a UI or
#' another module — no paired server function is required.
#'
#' @section `shinyalert` usage in UI:
#' `type = "shinyalert"` requires a delegated `jQuery` click handler injected
#' into the page. See [app_ui()] for an example.
#'
#' @param trigger     A `shiny.tag` (or plain text) that the tooltip attaches
#'   to.  Defaults to a small `bsicons::bs_icon("info-circle")`.
#' @param type        Back-end to use.  One of `"bslib"` (default),
#'   `"shinyhelper"`, `"prompter"`, or `"shinyalert"`.
#' @param contents    Character string or vector — the tooltip/popover/modal
#'   body.  HTML is accepted for `"bslib"`.  For `"shinyhelper"` a
#'   plain-text character vector is preferred — elements are joined with
#'   `<br>` by `helper(type = "inline")`, so embedding HTML tags causes
#'   double-escaping.  Ignored as plain text by `"prompter"`.  For
#'   `"shinyalert"` HTML is supported (rendered via `html: true`).
#' @param size        CSS font-size for the trigger wrapper span, e.g.
#'   `"0.85rem"`.  `NULL` (default) leaves the font size unchanged.  Note:
#'   this is purely a CSS property on the wrapper — it is distinct from
#'   `helper_size` (the shinyhelper modal size).
#' @param style       Additional inline CSS for the trigger wrapper, e.g.
#'   `"color:#6c757d"`.  `NULL` (default) applies none.
#' @param helper_type Content type forwarded to `shinyhelper::helper()` as
#'   its `type` argument.  One of `"inline"` (default) or `"markdown"`.
#'   Ignored by all other back-ends.
#' @param helper_size Modal size forwarded to `shinyhelper::helper()` as its
#'   `size` argument.  One of `"s"`, `"m"` (default), or `"l"`.  Ignored by
#'   all other back-ends.  Kept separate from `size` to avoid the two params
#'   colliding.
#' @param alert_type  Alert style forwarded to `shinyalert()` as its `type`
#'   argument.  One of `"info"` (default), `"success"`, `"warning"`, or
#'   `"error"`.  Ignored by all other back-ends.
#' @param ...         Extra arguments forwarded directly to the underlying
#'   back-end function:
#'   * `"bslib"`       → [bslib::popover()]  (e.g. `title`, `placement`)
#'   * `"shinyhelper"` → `shinyhelper::helper()`  (e.g. `title`, `colour`,
#'     `icon`, `buttonLabel`, `easyClose`, `fade`)
#'   * `"prompter"`    → `prompter::add_prompt()`  (e.g. `position`,
#'     `rounded`, `bounce`, `arrow`, `animate`)
#'   * `"shinyalert"`  → stored as `data-sa-*` attributes; recognised keys
#'     are `title` and `confirmButtonText`
#'
#' @return A `shiny.tag` (or `shiny.tagList`) ready to embed in any UI.
#'
#' @examples
#' \dontrun{
#' # bslib popover (click to open)
#' mod_tooltip(
#'   type     = "bslib",
#'   contents = "A <b>bslib</b> popover with HTML.",
#'   title    = "More info"
#' )
#'
#' # shinyhelper inline help modal
#' mod_tooltip(
#'   trigger     = shiny::tags$span("Sharpe Ratio"),
#'   type        = "shinyhelper",
#'   contents    = c("Sharpe Ratio", "Assumes a zero risk-free rate."),
#'   helper_type = "inline",
#'   helper_size = "m",
#'   title       = "Sharpe Ratio"
#' )
#'
#' # prompter attribute-driven tooltip
#' mod_tooltip(
#'   trigger  = bsicons::bs_icon("info-circle"),
#'   type     = "prompter",
#'   contents = "Number of trading days in the rolling window.",
#'   position = "right"
#' )
#'
#' # shinyalert modal on click (requires sa-handler in app_ui)
#' mod_tooltip(
#'   trigger    = shiny::tags$span("What is ann. vol?"),
#'   type       = "shinyalert",
#'   contents   = "Annualised volatility = SD of daily log returns x sqrt(252).",
#'   title      = "Annualised Volatility",
#'   alert_type = "info"
#' )
#' }
#'
#' @export
mod_tooltip <- function(
    trigger = bsicons::bs_icon("info-circle"),
    type = c("bslib", "shinyhelper", "prompter", "shinyalert"),
    contents = "",
    size = NULL,
    style = NULL,
    helper_type = c("inline", "markdown"),
    helper_size = c("m", "s", "l"),
    alert_type = c("info", "success", "warning", "error"),
    ...) {
  type <- match.arg(type)
  helper_type <- match.arg(helper_type)
  helper_size <- match.arg(helper_size)
  alert_type <- match.arg(alert_type)

  logger::log_debug(
    "mod_tooltip() | type: {type} | contents length: {nchar(paste(contents, collapse = ''))}",
    namespace = "rsixer/tooltip"
  )

  # Build inline CSS from the wrapper size + style args
  css_parts <- character(0)
  if (!is.null(size)) css_parts <- c(css_parts, paste0("font-size:", size))
  if (!is.null(style)) css_parts <- c(css_parts, style)
  inline_style <- if (length(css_parts)) paste(css_parts, collapse = "; ") else NULL

  wrapped_trigger <- if (!is.null(inline_style)) {
    shiny::tags$span(style = inline_style, trigger)
  } else {
    trigger
  }

  tryCatch(
    switch(
      type,

      # ── bslib ──────────────────────────────────────────────────────────────
      bslib = {
        logger::log_debug(
          "mod_tooltip() dispatching to bslib::popover()",
          namespace = "rsixer/tooltip"
        )
        bslib::popover(
          wrapped_trigger,
          shiny::HTML(contents),
          ...
        )
      },

      # ── shinyhelper ────────────────────────────────────────────────────────
      shinyhelper = {
        logger::log_debug(
          "mod_tooltip() dispatching to shinyhelper::helper() | helper_type: {helper_type} | helper_size: {helper_size}",
          namespace = "rsixer/tooltip"
        )
        shinyhelper::helper(
          wrapped_trigger,
          type = helper_type,
          size = helper_size,
          content = contents,
          ...
        )
      },

      # ── prompter ───────────────────────────────────────────────────────────
      prompter = {
        logger::log_debug(
          "mod_tooltip() dispatching to prompter::add_prompt()",
          namespace = "rsixer/tooltip"
        )
        prompter::add_prompt(
          wrapped_trigger,
          message = contents,
          ...
        )
      },

      # ── shinyalert ─────────────────────────────────────────────────────────
      shinyalert = {
        logger::log_debug(
          "mod_tooltip() dispatching to shinyalert (data-* attrs) | alert_type: {alert_type}",
          namespace = "rsixer/tooltip"
        )
        dots <- list(...)
        al_title <- dots[["title"]] %||% ""
        al_btn <- dots[["confirmButtonText"]] %||% "OK"

        shiny::tags$span(
          class = "sa-trigger",
          style = paste(c("cursor:pointer", inline_style), collapse = "; "),
          `data-sa-title` = al_title,
          `data-sa-text` = contents,
          `data-sa-type` = alert_type,
          `data-sa-btn` = al_btn,
          trigger
        )
      }
    ),
    error = function(e) {
      logger::log_error(
        "mod_tooltip() failed | type: {type} | error: {conditionMessage(e)}",
        namespace = "rsixer/tooltip"
      )
      stop(e)
    }
  )
}
