# In R/logger.R
Logger <- R6::R6Class("Logger",
  public = list(
    session_id = NULL,
    logs = character(),

    initialize = function(session_id) {
      self$session_id <- session_id
    },

    log = function(message) {
      timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      entry <- paste0("[", self$session_id, " @ ", timestamp, "] ", message)
      self$logs <- c(self$logs, entry)
    },

    get_logs = function() {
      self$logs
    }
  )
)
