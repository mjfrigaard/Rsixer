#' App Server
#' 
#' Application server for Rsixer.
#'
#' In addition to the counter example, this server instantiates an
#' `InputCollector` and `OutputProducer` to record the user's text,
#' numeric, and file inputs. The collected values are displayed in a
#' table and plot and can be downloaded as a CSV file.
#' 
#' @export
#' 
app_server <- function(input, output, session) {

  counter <- Counter$new()
  trigger <- reactiveVal(0)

  collector <- InputCollector$new()
  producer <- OutputProducer$new(collector)

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

  observe({
    collector$update(
      text = input$text,
      numeric = input$number,
      file = if (!is.null(input$file)) input$file$name else NULL
    )
  })

  output$input_table <- renderTable({
    input$text
    input$number
    input$file
    producer$get_table()
  })

  output$input_plot <- renderPlot({
    input$text
    input$number
    input$file
    producer$get_plot()
  })

  output$download_data <- producer$download_data()
}
