#' InputCollector R6 Class
#'
#' Collects and stores user inputs for use in the app.
#'
#' @docType class
#' @format An [R6](https://r6.r-lib.org/index.html) object.
#'
#' @export
InputCollector <- R6::R6Class(
  "InputCollector",
  public = list(
    #' @field text Textual input
    text = NULL,
    #' @field numeric Numeric input
    numeric = NULL,
    #' @field file File path or name input
    file = NULL,

    #' @description
    #' Create a new `InputCollector` object.
    #' @param text Optional initial text value.
    #' @param numeric Optional initial numeric value.
    #' @param file Optional initial file value.
    initialize = function(text = NULL, numeric = NULL, file = NULL) {
      self$text <- text
      self$numeric <- numeric
      self$file <- file
    },

    #' @description
    #' Update stored inputs.
    #' @param text Optional text value.
    #' @param numeric Optional numeric value.
    #' @param file Optional file value.
    update = function(text = NULL, numeric = NULL, file = NULL) {
      if (!is.null(text)) self$text <- text
      if (!is.null(numeric)) self$numeric <- numeric
      if (!is.null(file)) self$file <- file
    },

    #' @description
    #' Retrieve all stored inputs.
    #' @return A list with elements `text`, `numeric`, and `file`.
    get = function() {
      list(
        text = self$text,
        numeric = self$numeric,
        file = self$file
      )
    }
  )
)
