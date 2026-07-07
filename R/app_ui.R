#' Application UI
#'
#' Top-level UI function that wires together all R6 module UIs inside a
#' [bslib::page_sidebar()] layout.
#'
#' @return A `shiny.tag` UI object suitable for passing to [shiny::shinyApp()].
#' @export
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
      theme = bslib::bs_theme(
        version = 5,
        bootswatch = "flatly",
        primary = "#2c7bb6",
        base_font = bslib::font_google("Inter")
      ),
      fillable = FALSE,

      # ── HEAD extras ─────────────────────────────────────────────────────
      shiny::tags$head(
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
