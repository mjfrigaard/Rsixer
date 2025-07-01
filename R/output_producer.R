#' OutputProducer R6 Class
#'
#' Generates tables, plots, and download handlers from an `InputCollector`.
#'
#' @docType class
#' @format An [R6](https://r6.r-lib.org/index.html) object.
#'
#' @export
OutputProducer <- R6::R6Class(
  "OutputProducer",
  public = list(
    #' @field collector The `InputCollector` instance containing inputs
    collector = NULL,

    #' @description
    #' Create a new `OutputProducer` object.
    #' @param collector An `InputCollector` object.
    initialize = function(collector) {
      self$collector <- collector
    },

    #' @description
    #' Produce a summary table of collected inputs.
    #' @return A `data.frame` with input names and values.
    get_table = function() {
      inputs <- self$collector$get()
      data.frame(
        name = names(inputs),
        value = unlist(lapply(inputs, as.character)),
        row.names = NULL,
        stringsAsFactors = FALSE
      )
    },

    #' @description
    #' Produce a ggplot based on numeric input values.
    #' @return A ggplot object.
    get_plot = function() {
      inputs <- self$collector$get()
      df <- data.frame(idx = seq_along(inputs$numeric), value = inputs$numeric)
      ggplot2::ggplot(df, ggplot2::aes(x = idx, y = value)) +
        ggplot2::geom_col() +
        ggplot2::labs(x = "Index", y = "Value")
    },

    #' @description
    #' Create a download handler for the input table.
    #' @param filename Name of the downloaded file.
    #' @return A `shiny::downloadHandler` object.
    download_data = function(filename = "data.csv") {
      shiny::downloadHandler(
        filename = filename,
        content = function(file) {
          utils::write.csv(self$get_table(), file, row.names = FALSE)
        }
      )
    }
  )
)
