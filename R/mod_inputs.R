#' ModInputs R6 Class
#'
#' Encapsulates sidebar controls for ticker selection, date range, rolling-vol
#' window, and report download. Uses R6 for object-oriented Shiny module design.
#'
#' @examples
#' \dontrun{
#' # In app_ui():
#' inputs <- ModInputs$new(id = "inputs")
#' inputs$ui()
#'
#' # In app_server():
#' inputs <- ModInputs$new(id = "inputs")
#' inputs_r <- inputs$server()
#' }
#'
#' @export
ModInputs <- R6::R6Class(
  "ModInputs",

  public = list(
    #' @description Initialize a new ModInputs instance
    #' @param id Character. Module namespace id.
    initialize = function(id = "inputs") {
      private$id <- id
      private$ns <- shiny::NS(id)
    },

    #' @description Build sidebar UI
    #' @return A [bslib::sidebar()] tag object
    ui = function() {
      bslib::sidebar(
        width = 280,
        bg = "#f8f9fa",

        # ── Ticker picker ──────────────────────────────────────────────────────
        shiny::selectizeInput(
          inputId = private$ns("tickers"),
          label = shiny::tags$span(
            "Tickers",
            mod_tooltip(
              trigger = bsicons::bs_icon("info-circle"),
              type = "bslib",
              contents = "Enter one or more stock ticker symbols (e.g. AAPL, MSFT).",
              size = "0.85rem",
              style = "color:#6c757d"
            )
          ),
          choices = default_tickers,
          selected = c("AAPL", "MSFT", "GOOGL"),
          multiple = TRUE,
          options = list(
            plugins = list("remove_button"),
            placeholder = "Add a ticker\u2026",
            create = TRUE
          )
        ),

        # ── Date range ────────────────────────────────────────────────────────
        shiny::dateRangeInput(
          inputId = private$ns("dates"),
          label = "Date range",
          start = Sys.Date() - 365,
          end = Sys.Date(),
          min = "2000-01-01",
          max = Sys.Date()
        ),

        # ── Rolling-vol window ────────────────────────────────────────────────
        shiny::sliderInput(
          inputId = private$ns("vol_window"),
          label = shiny::tags$span(
            "Rolling vol window (days)",
            mod_tooltip(
              trigger = bsicons::bs_icon("info-circle"),
              type = "bslib",
              contents = "Number of trading days used for the rolling volatility calculation.",
              size = "0.85rem",
              style = "color:#6c757d"
            )
          ),
          min = 5L,
          max = 120L,
          value = 30L,
          step = 5L
        ),

        shiny::hr(),

        shiny::actionButton(
          inputId = private$ns("fetch"),
          label = "Fetch data",
          icon = shiny::icon("download"),
          class = "btn-primary w-100"
        ),

        shiny::hr(),

        # ── Report download (placeholder) ─────────────────────────────────────
        bslib::card(
          bslib::card_header(
            bsicons::bs_icon("file-earmark-arrow-down"), " Download Report"
          ),
          bslib::card_body(
            shiny::selectInput(
              inputId = private$ns("format"),
              label = "Report format",
              choices = c("HTML" = "html", "PDF" = "pdf"),
              selected = "html"
            ),
            shiny::downloadButton(
              outputId = private$ns("download"),
              label = "Download",
              icon = shiny::icon("download"),
              class = "btn-outline-primary w-100"
            )
          )
        )
      )
    },

    #' @description Initialize server logic
    #' @return Reactive list with elements: tickers, from, to, vol_window, fetch
    server = function() {
      shiny::moduleServer(private$id, function(input, output, session) {
        logger::log_debug(
          "ModInputs$server() initialised | id: {private$id}",
          namespace = "rsixer/inputs"
        )

        # ── Fetch button observer ───────────────────────────────────────────────
        shiny::observe({
          shiny::req(input$fetch)

          logger::log_info(
            "Fetch button pressed | tickers: [{paste(input$tickers, collapse = ', ')}] | from: {input$dates[1]} | to: {input$dates[2]} | vol_window: {input$vol_window}",
            namespace = "rsixer/inputs"
          )

          if (length(input$tickers) == 0) {
            logger::log_warn(
              "Fetch pressed with no tickers selected",
              namespace = "rsixer/inputs"
            )
            shiny::showNotification(
              "Please select at least one ticker.",
              type = "warning"
            )
          }
        })

        # ── Reactive inputs list ────────────────────────────────────────────────
        shiny::reactive({
          with_logging(
            context = "ModInputs / reactive list",
            ns = "rsixer/inputs",
            {
              inp <- list(
                tickers = input$tickers,
                from = input$dates[1],
                to = input$dates[2],
                vol_window = input$vol_window,
                fetch = input$fetch,
                format = input$format
              )

              logger::log_debug(
                "Inputs reactive evaluated | tickers: [{paste(inp$tickers, collapse = ', ')}]",
                namespace = "rsixer/inputs"
              )

              inp
            }
          )
        })
      })
    }
  ),

  private = list(
    id = NULL,
    ns = NULL
  )
)
