#' App Server
#' 
#' Application server for Rsixer.
#' 
#' @export
#' 
app_server <- function(input, output, session) {
  
  counter <- Counter$new()
  trigger <- reactiveVal(0)

  observe({
    counter$increment()
    trigger(trigger() + 1)
  }) |> 
    bindEvent(input$increment_btn)

  observe({
    counter$reset()
  }) |> 
    bindEvent(input$reset_btn)

  output$counter_text <- renderText({
    trigger()
    paste("Current count:", counter$get())
  })
}