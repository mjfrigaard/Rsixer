#' App UI
#' 
#' Application UI for Rsixer.
#' 
#' @export
#' 
app_ui <- function() {
  fluidPage(
    actionButton("increment_btn", "Increment"),
    actionButton("reset_btn", "Reset"),
    textOutput("counter_text")
  )
}