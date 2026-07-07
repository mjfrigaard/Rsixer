#' Execute an Expression with Structured Error and Warning Logging
#'
#' Wraps `expr` in a `tryCatch()` that:
#' * logs warnings via [logger::log_warn()] and re-issues them so Shiny can
#'   also handle them
#' * logs errors via [logger::log_error()] and re-throws so the caller /
#'   Shiny sees the error normally
#'
#' @param expr    Expression to evaluate (passed unevaluated via `...`).
#' @param context Short string identifying the call site, e.g.
#'   `"mod_outputs / prices_r"`.  Prepended to every log message.
#' @param ns      Logger namespace string.
#'   Defaults to `"rsixer/app"`.
#'
#' @return The value of `expr` on success; re-throws on error.
#'
#' @examples
#' \dontrun{
#' result <- with_logging(
#'   context = "my_module / compute",
#'   ns = "rsixer/app",
#'   sqrt(4)
#' )
#' }
#'
#' @export
with_logging <- function(expr, context = "", ns = "rsixer/app") {
  tryCatch(
    withCallingHandlers(
      expr,
      warning = function(w) {
        logger::log_warn(
          "[{context}] Warning: {conditionMessage(w)}",
          namespace = ns
        )
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      logger::log_error(
        "[{context}] Error: {conditionMessage(e)}",
        namespace = ns
      )
      stop(e)
    }
  )
}

#' Set the Application-wide Log Threshold
#'
#' A thin wrapper around [logger::log_threshold()] that applies the chosen
#' level to every logger namespace used by **rsixer**.
#'
#' Log levels from lowest to highest verbosity:
#' `TRACE`, `DEBUG`, `INFO`, `SUCCESS`, `WARN`, `ERROR`, `FATAL`.
#' The default threshold is `INFO` — `TRACE` and `DEBUG` lines are silent
#' in production.
#'
#' Internally, `lapply()` iterates over the namespace vector and calls
#' [logger::log_threshold()] for each entry.  The return value of `lapply()`
#' is discarded; only `level` is returned (invisibly).
#'
#' @param level A `logger` log-level object, e.g. [logger::DEBUG],
#'   [logger::INFO] (default), [logger::WARN].
#'
#' @return Invisibly returns `level`.
#'
#' @examples
#' \dontrun{
#' # Verbose output during development
#' app_set_log_threshold(logger::DEBUG)
#'
#' # Quiet production mode
#' app_set_log_threshold(logger::WARN)
#' }
#'
#' @export
app_set_log_threshold <- function(level = logger::INFO) {
  namespaces <- c(
    "global",
    "rsixer/app",
    "rsixer/inputs",
    "rsixer/outputs",
    "rsixer/download",
    "rsixer/tooltip",
    "rsixer/hoverinfo"
  )
  lapply(namespaces, \(ns) logger::log_threshold(level, namespace = ns))
  invisible(level)
}
