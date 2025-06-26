# In R/counter.R
Counter <- R6::R6Class(
  "Counter",
  public = list(
    value = 0,
    initialize = function(start = 0) {
      self$value <- start
    },
    increment = function() {
      self$value <- self$value + 1
    },
    reset = function() {
      self$value <- 0
    },
    get = function() {
      self$value
    }
  )
)
