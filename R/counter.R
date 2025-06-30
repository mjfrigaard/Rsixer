#' Counter R6 Class
#'
#' A simple counter object with increment and reset functionality.
#'
#' @docType class
#' @format An [R6](https://r6.r-lib.org/index.html) object.
#'
#' @export
#' 
Counter <- R6::R6Class(
  "Counter",
  public = list(
    #' @field value Current value of the counter
    value = 0,

    #' @description
    #' Create a new `Counter`` object.
    #' @param start Initial value of the counter (default = 0).
    initialize = function(start = 0) {
      self$value <- start
    },

    #' @description Increment the counter by 1.
    increment = function() {
      self$value <- self$value + 1
    },

    #' @description Reset the counter to 0.
    reset = function() {
      self$value <- 0
    },

    #' @description Get the current counter value.
    #' @return The current value of the counter.
    get = function() {
      self$value
    }
  )
)
