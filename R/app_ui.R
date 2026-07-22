#' Application UI
#'
#' Top-level UI function that wires together all R6 module UIs inside a
#' [bslib::page_sidebar()] layout.
#'
#' @return A `shiny.tag` UI object suitable for passing to [shiny::shinyApp()].
#' 
#' @export
#' 
app_ui <- function() {

  logger::log_info(
    "Building app UI",
    namespace = "rsixer/app"
  )

  # Instantiate R6 module UI objects
  inputs <- ModInputs$new(id = "inputs")
  outputs <- ModOutputs$new(id = "outputs")

  with_logging(
    context = "app_ui",
    ns = "rsixer/app",
    bslib::page_sidebar(
      title = shiny::tagList(
        bsicons::bs_icon("bar-chart-steps"),
        " Rsixer: R6 Shiny Demo"
      ),
      theme = rsixer_theme(),
      fillable = FALSE,

      # ── HEAD extras ─────────────────────────────────────────────────────
      shiny::tags$head(
        # Dark theme CSS overrides
        shiny::tags$style(htmltools::HTML(
          "
          .navbar, .sidebar {
            background-color: #0b0e13 !important;
            color: #d5dde5 !important;
            border-color: #2a313b !important;
          }
          .sidebar-content {
            background-color: #0b0e13 !important;
          }
          .form-control, .form-select {
            background-color: #12161d !important;
            border-color: #2a313b !important;
            color: #d5dde5 !important;
          }
          .form-control:focus, .form-select:focus {
            background-color: #1a1f28 !important;
            border-color: #ff9e1b !important;
            color: #d5dde5 !important;
            box-shadow: 0 0 0 0.25rem rgba(255, 158, 27, 0.25) !important;
          }
          .btn-primary {
            background-color: #ff9e1b !important;
            border-color: #ff9e1b !important;
            color: #0b0e13 !important;
          }
          .btn-primary:hover {
            background-color: #00d9ff !important;
            border-color: #00d9ff !important;
            color: #0b0e13 !important;
          }
          .btn-secondary {
            background-color: #00d9ff !important;
            border-color: #00d9ff !important;
            color: #0b0e13 !important;
          }
          .btn-secondary:hover {
            background-color: #00f0ff !important;
            border-color: #00f0ff !important;
          }
          h1, h2, h3, h4, h5, h6 {
            color: #ff9e1b !important;
          }
          .card-header {
            background-color: #1a1f28 !important;
            border-color: #2a313b !important;
            color: #00d9ff !important;
          }
          .card {
            background-color: #12161d !important;
            border-color: #2a313b !important;
            color: #d5dde5 !important;
          }
          label {
            color: #d5dde5 !important;
          }
          .selectize-input, .selectize-dropdown {
            background-color: #12161d !important;
            border-color: #2a313b !important;
            color: #d5dde5 !important;
          }
          a {
            color: #ff9e1b !important;
          }
          a:hover {
            color: #00d9ff !important;
          }
          .vb-yellow-black {
            background-color: #ff9e1b !important;
            border-color: #ff9e1b !important;
          }
          .vb-yellow-black .value-box-title,
          .vb-yellow-black .value-box-value,
          .vb-yellow-black .value-box-subtitle {
            color: #0b0e13 !important;
          }
          .bslib-value-box.bslib-bs5.bg-warning {
            background-color: #ff9e1b !important;
            color: #0b0e13 !important;
          }
          .bslib-value-box.bslib-bs5.bg-warning .value-box-title,
          .bslib-value-box.bslib-bs5.bg-warning .value-box-value {
            color: #0b0e13 !important;
          }
          "
        )),

        # shinyalert JS — required for the delegated .sa-trigger handler.
        shinyalert::useShinyalert(force = TRUE),

        # Delegated shinyalert handler — reads content from data-sa-* attrs.
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.sa-trigger', function () {",
          "  var d = $(this).data();",
          "  swal({",
          "    title:             d.saTitle || '',",
          "    text:              d.saText  || '',",
          "    type:              d.saType  || 'info',",
          "    html:              true,",
          "    confirmButtonText: d.saBtn   || 'OK'",
          "  });",
          "});"
        )),

        # delegated shinyhelper handler ----
        shiny::tags$script(htmltools::HTML(
          "$(document).on('click', '.shinyhelper-icon', function(e) {",
          "  e.stopImmediatePropagation();",
          "  var d = $(this).data();",
          "  Shiny.setInputValue('shinyhelper_params', {",
          "    size:      d.modalSize,",
          "    type:      d.modalType,",
          "    title:     d.modalTitle,",
          "    content:   d.modalContent,",
          "    label:     d.modalLabel,",
          "    easyClose: d.modalEasyclose,",
          "    fade:      d.modalFade",
          "  }, {priority: 'event'});",
          "});"
        ))
      ),

      # ── Sidebar (inputs + download) ──────────────────────────────────────
      sidebar = inputs$ui(),

      # ── Main content — full width ────────────────────────────────────────
      outputs$ui(),

      # ── Footer ──────────────────────────────────────────────────────────
      shiny::tags$footer(
        class = "mt-4 pt-3 pb-2 border-top text-muted small",
        shiny::tags$div(
          class = "d-flex flex-wrap gap-4 align-items-start",
          shiny::tags$div(
            shiny::tags$strong("Rsixer: R6 Shiny Demo"),
            shiny::tags$span(
              " \u2014 demonstrates R6 object-oriented design patterns for modular",
              " Shiny apps using financial data from ",
              shiny::tags$a(
                href = "https://www.tidy-finance.org/r/",
                target = "_blank",
                "Tidy Finance"
              ),
              " and ",
              shiny::tags$a(
                href = "https://business-science.github.io/tidyquant/",
                target = "_blank",
                "tidyquant"
              ),
              "."
            )
          ),
          shiny::tags$div(
            shiny::tags$strong("R6 Modules: "),
            shiny::tags$span(
              shiny::tags$b("ModInputs"),
              ", ",
              shiny::tags$b("ModOutputs"),
              ", ",
              shiny::tags$b("ModDownload")
            )
          )
        )
      )
    )
  )
}
