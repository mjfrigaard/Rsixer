#' App UI
#' 
#' Application UI for Rsixer.
#'
#' The UI provides buttons for the `Counter` demo as well as inputs for
#' collecting text, numeric, and file values. A table, plot, and download
#' button display the outputs generated from these inputs.
#' 
#' @export
#' 
app_ui <- function() {
  fluidPage(
    actionButton("increment_btn", "Increment"),
    actionButton("reset_btn", "Reset"),
    textInput("text", "Text"),
    numericInput("number", "Number", value = 0),
    fileInput("file", "Upload File"),
    tableOutput("input_table"),
    plotOutput("input_plot"),
    downloadButton("download_data", "Download Data"),
    textOutput("counter_text")
  )
}
