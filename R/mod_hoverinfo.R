#' Hover-info Module
#'
#' A server-side helper that formats hover/tooltip content for
#' `reactable` table cells.  Wraps the display value in an `htmltools`
#' `<span>` with a `title` attribute, which browsers render as a native
#' tooltip on hover.
#'
#' @param type     Back-end to target.  Currently only `"reactable"`.
#' @param contents A character string (or named character vector) used as the
#'   tooltip text in the `title` attribute.  Named vectors produce
#'   `"Name: value"` pairs joined by `" | "`.
#' @param display  The value to render visibly inside the cell.  Passed as the
#'   child node of the `<span>`.  Kept as an explicit parameter so it is
#'   never accidentally matched to `size` by positional argument order.
#' @param size     CSS font-size for the span wrapper, e.g. `"0.8rem"`.
#'   `NULL` (default) leaves it unchanged.
#' @param style    Inline CSS for the span wrapper, e.g. `"cursor:help"`.
#'   `NULL` (default) applies none.
#' @param ...      Additional HTML attributes passed to the `<span>` tag.
#'
#' @return An `htmltools` `<span>` tag with a `title` attribute set.
#'   Use inside a `reactable::colDef(cell = ..., html = TRUE)` renderer.
#'
#' @examples
#' \dontrun{
#' reactable::colDef(
#'   name = "Ann. Return (%)",
#'   html = TRUE,
#'   cell = function(value, index) {
#'     mod_hoverinfo(
#'       type     = "reactable",
#'       contents = paste0("Annualised log return: ", value, "%"),
#'       display  = paste0(value, "%"),
#'       style    = "color:#198754; cursor:help"
#'     )
#'   }
#' )
#' }
#'
#' @export
mod_hoverinfo <- function(
    type = "reactable",
    contents = character(0),
    display = NULL,
    size = NULL,
    style = NULL,
    ...) {
  type <- match.arg(type, choices = "reactable")

  logger::log_debug(
    "mod_hoverinfo() | type: {type} | contents length: {length(contents)}",
    namespace = "rsixer/hoverinfo"
  )

  tryCatch(
    {
      logger::log_debug(
        "mod_hoverinfo() building reactable span | named: {!is.null(names(contents))}",
        namespace = "rsixer/hoverinfo"
      )

      if (!is.null(names(contents)) && any(nzchar(names(contents)))) {
        tip_text <- paste(
          ifelse(
            nzchar(names(contents)),
            paste0(names(contents), ": ", contents),
            contents
          ),
          collapse = " | "
        )
      } else {
        tip_text <- paste(contents, collapse = " | ")
      }

      css_parts <- character(0)
      if (!is.null(size)) css_parts <- c(css_parts, paste0("font-size:", size))
      if (!is.null(style)) css_parts <- c(css_parts, style)
      inline_style <- if (length(css_parts)) paste(css_parts, collapse = "; ") else NULL

      span_args <- list(title = tip_text, ...)
      if (!is.null(inline_style)) span_args[["style"]] <- inline_style
      if (!is.null(display)) span_args <- c(span_args, list(display))

      do.call(htmltools::tags$span, span_args)
    },
    error = function(e) {
      logger::log_error(
        "mod_hoverinfo() failed | type: {type} | error: {conditionMessage(e)}",
        namespace = "rsixer/hoverinfo"
      )
      stop(e)
    }
  )
}
