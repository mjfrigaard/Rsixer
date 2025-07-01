#' Launch the Shiny App
#'
#' Standalone app function.
#' 
#' @export
#' 
#' @import shiny
#' 
launch <- function() {
  shinyApp(
    ui = app_ui(),
    server = app_server
  )
}
