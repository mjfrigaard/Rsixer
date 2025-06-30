#' Logger R6 Class
#'
#' A simple logger that tracks messages and timestamps, optionally per Shiny session.
#'
#' @docType class
#' @format An [R6](https://r6.r-lib.org/index.html) object.
#'
#' @export
#' 
Logger <- R6::R6Class(
  "Logger",
  public = list(
    #' @field session_id Optional identifier for the session
    session_id = NULL,

    #' @field logs A character vector of logged messages
    logs = character(),

    #' @description
    #' Create a new `Logger`` object.
    #' @param session_id A string identifying the session or user (optional).
    initialize = function(session_id = NULL) {
      self$session_id <- session_id
    },

    #' @description Add a message to the log with a timestamp.
    #' @param message The message to log.
    log = function(message) {
      timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      entry <- paste0("[", self$session_id, " @ ", timestamp, "] ", message)
      self$logs <- c(self$logs, entry)
    },

    #' @description Retrieve all logged messages.
    #' @return A character vector of log entries.
    get_logs = function() {
      self$logs
    }
  )
)