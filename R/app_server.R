#' Application Server
#'
#' Top-level server function that initialises all R6 module servers and wires
#' reactive values between them.
#'
#' @param input,output,session Standard Shiny server arguments.
#'
#' @return Nothing (called for side-effects).
#' @export
app_server <- function(input, output, session) {

  # ── Logging setup ────────────────────────────────────────────────────────
  app_set_log_threshold(logger::INFO)

  logger::log_info(
    "Session started | session_id: {session$token}",
    namespace = "rsixer/app"
  )

  # ── shinyhelper ──────────────────────────────────────────────────────────
  # Must be called once per session so shinyhelper registers its
  # observeEvent(input$shinyhelper_params, ...) listener.  Without this the
  # circled-? icons render correctly but clicks are silently ignored.
  shinyhelper::observe_helpers(help_dir = system.file("help", package = "shinyhelper"))

  # ── 1. Input module ──────────────────────────────────────────────────────
  inputs <- ModInputs$new(id = "inputs")
  inputs_r <- with_logging(
    inputs$server(),
    context = "app_server / ModInputs",
    ns = "rsixer/app"
  )
  logger::log_info("ModInputs$server() ready", namespace = "rsixer/app")

  # ── 2. Output module ─────────────────────────────────────────────────────
  outputs <- ModOutputs$new(id = "outputs")
  perf_r <- with_logging(
    outputs$server(inputs_r = inputs_r),
    context = "app_server / ModOutputs",
    ns = "rsixer/app"
  )
  logger::log_info("ModOutputs$server() ready", namespace = "rsixer/app")

  # ── 3. Download module ───────────────────────────────────────────────────
  download <- ModDownload$new(id = "download")
  with_logging(
    download$server(inputs_r = inputs_r, perf_r = perf_r),
    context = "app_server / ModDownload",
    ns = "rsixer/app"
  )
  logger::log_info("ModDownload$server() ready", namespace = "rsixer/app")

  # ── Session end ──────────────────────────────────────────────────────────
  session$onSessionEnded(function() {
    logger::log_info(
      "Session ended   | session_id: {session$token}",
      namespace = "rsixer/app"
    )
  })
}
