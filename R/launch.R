#' Launch the Rsixer Shiny App
#'
#' Convenience wrapper that calls [shiny::shinyApp()] with the package's
#' [app_ui()] and [app_server()] functions. Pass any additional arguments
#' through to `shinyApp()` (e.g. `options = list(port = 4321)`).
#'
#' @param ... Additional arguments forwarded to [shiny::shinyApp()].
#'
#' @return A Shiny app object (invisibly). When called interactively the app
#'   opens in the viewer / browser.
#'
#' @examples
#' \dontrun{
#' rsixer::launch()
#'
#' # Custom port
#' rsixer::launch(options = list(port = 4242, launch.browser = TRUE))
#' }
#'
#' @export
launch <- function(...) {
  # Apply Rsixer reactable theme
  options(reactable.theme = rsixer_reactable_theme())

  shiny::shinyApp(
    ui = app_ui(),
    server = app_server,
    ...
  )
}
