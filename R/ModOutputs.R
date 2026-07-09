#' ModOutputs R6 Class
#'
#' Main content area with KPI value boxes and 5 demo tabs showcasing different
#' tooltip/hover-info approaches. Uses R6 for object-oriented Shiny module design.
#'
#' @examples
#' \dontrun{
#' # In app_ui():
#' outputs <- ModOutputs$new(id = "outputs")
#' outputs$ui()
#'
#' # In app_server():
#' outputs <- ModOutputs$new(id = "outputs")
#' perf_r <- outputs$server(inputs_r)
#' }
#'
#' @export
ModOutputs <- R6::R6Class(
  "ModOutputs",

  public = list(
    #' @description Initialize a new ModOutputs instance
    #' @param id Character. Module namespace id.
    initialize = function(id = "outputs") {
      private$id <- id
      private$ns <- shiny::NS(id)
    },

    #' @description Build main content UI
    #' @return A [shiny::tagList()] with KPI boxes and demo tabs
    ui = function() {
      shiny::tagList(

        # -- KPI value boxes (always visible) --
        shiny::uiOutput(private$ns("value_boxes")),

        shiny::br(),

        # -- Main demo tabs --
        bslib::navset_card_tab(
          id = private$ns("tabs"),

          # 1. bslib
          bslib::nav_panel(
            title = shiny::tagList(bsicons::bs_icon("box"), " bslib"),
            value = "bslib",
            shiny::h6(
              "Click the info icon on each value box to open a bslib popover.",
              class = "text-muted mb-3"
            ),
            shiny::uiOutput(private$ns("bslib_boxes"))
          ),

          # 2. shinyhelper
          bslib::nav_panel(
            title = shiny::tagList(bsicons::bs_icon("question-circle"), " shinyhelper"),
            value = "shinyhelper",
            shiny::h6(
              "Click the circled-? icon on each card to open a shinyhelper modal.",
              class = "text-muted mb-3"
            ),
            shiny::uiOutput(private$ns("shinyhelper_cards"))
          ),

          # 3. prompter
          bslib::nav_panel(
            title = shiny::tagList(bsicons::bs_icon("chat-dots"), " prompter"),
            value = "prompter",
            shiny::h6(
              "Hover over each metric label to see a prompter attribute tooltip.",
              class = "text-muted mb-3"
            ),
            prompter::use_prompt(),
            shiny::uiOutput(private$ns("prompter_cards"))
          ),

          # 4. shinyalert
          bslib::nav_panel(
            title = shiny::tagList(bsicons::bs_icon("bell"), " shinyalert"),
            value = "shinyalert",
            shiny::h6(
              "Click a ticker card to open a shinyalert modal with full details.",
              class = "text-muted mb-3"
            ),
            shiny::uiOutput(private$ns("shinyalert_cards"))
          ),

          # 5. reactable
          bslib::nav_panel(
            title = shiny::tagList(bsicons::bs_icon("table"), " reactable"),
            value = "reactable",
            shiny::h6(
              "Hover over a cell to see the reactable tooltip.",
              class = "text-muted mb-3"
            ),
            reactable::reactableOutput(private$ns("reactable_perf"))
          )
        )
      )
    },

    #' @description Initialize server logic
    #' @param inputs_r Reactive list returned by ModInputs$server()
    #' @return Reactive tibble with performance metrics
    server = function(inputs_r) {
      shiny::moduleServer(private$id, function(input, output, session) {

        # shinyhelper requires observe_helpers() in the server
        shinyhelper::observe_helpers()

        logger::log_debug(
          glue::glue("ModOutputs$server() initialised | id: {private$id}"),
          namespace = "rsixer/outputs"
        )

        # -- Fetch prices on button click ------------------------------------------
        prices_r <- shiny::eventReactive(inputs_r()$fetch, {
          inp <- inputs_r()
          shiny::req(length(inp$tickers) > 0)

          logger::log_info(
            glue::glue("Fetching prices | tickers: [{paste(inp$tickers, collapse = ', ')}] | from: {inp$from} | to: {inp$to}"),
            namespace = "rsixer/outputs"
          )

          result <- tryCatch({
            shiny::withProgress(message = "Fetching prices...", value = 0.3, {
              p <- get_stock_prices(
                tickers = inp$tickers,
                from = inp$from,
                to = inp$to
              )
              shiny::incProgress(0.4)
              p
            })
          }, error = function(e) {
            err_msg <- conditionMessage(e)
            logger::log_error(
              glue::glue("Price fetch failed | tickers: [{paste(inp$tickers, collapse = ', ')}] | error: {err_msg}"),
              namespace = "rsixer/outputs"
            )
            shiny::showNotification(
              ui = shiny::tagList(
                shiny::tags$strong("Failed to fetch prices"),
                shiny::tags$br(),
                shiny::tags$small(err_msg),
                shiny::tags$br(),
                shiny::tags$small(class = "text-muted mt-2",
                  "Verify ticker symbols (e.g., AAPL, MSFT), check internet connection, and try again."
                )
              ),
              type = "error",
              duration = 20
            )
            NULL
          })

          if (is.null(result) || nrow(result) == 0) {
            return(NULL)
          }

          # Show notification if demo data was used
          if (isTRUE(attr(result, "is_demo"))) {
            shiny::showNotification(
              ui = shiny::tagList(
                shiny::tags$strong("Using demo data"),
                shiny::tags$br(),
                shiny::tags$small("Yahoo Finance is temporarily unavailable. Showing realistic demo prices.")
              ),
              type = "warning",
              duration = 15
            )
          }

          logger::log_info(
            glue::glue("Prices fetched | rows: {nrow(result)} | tickers: [{paste(unique(result$symbol), collapse = ', ')}]"),
            namespace = "rsixer/outputs"
          )
          result
        })

        # -- Returns ---------------------------------------------------------------
        returns_r <- shiny::reactive({
          shiny::req(prices_r())
          logger::log_debug(
            "Computing daily returns",
            namespace = "rsixer/outputs"
          )
          result <- tryCatch(
            get_stock_returns(prices_r()),
            error = function(e) {
              logger::log_error(
                glue::glue("get_stock_returns() failed | error: {conditionMessage(e)}"),
                namespace = "rsixer/outputs"
              )
              shiny::showNotification(
                "Failed to compute returns from price data",
                type = "error",
                duration = 10
              )
              NULL
            }
          )
          
          if (is.null(result)) {
            return(NULL)
          }
          
          logger::log_debug(
            glue::glue("Returns computed | rows: {nrow(result)}"),
            namespace = "rsixer/outputs"
          )
          result
        })

        # -- Performance summary ---------------------------------------------------
        perf_r <- shiny::reactive({
          shiny::req(returns_r())
          logger::log_debug(
            "Computing performance summary",
            namespace = "rsixer/outputs"
          )
          result <- tryCatch(
            summarise_performance(returns_r()),
            error = function(e) {
              logger::log_error(
                glue::glue("summarise_performance() failed | error: {conditionMessage(e)}"),
                namespace = "rsixer/outputs"
              )
              shiny::showNotification(
                "Failed to compute performance metrics",
                type = "error",
                duration = 10
              )
              NULL
            }
          )
          
          if (is.null(result)) {
            return(NULL)
          }
          
          logger::log_info(
            glue::glue("Performance summary ready | symbols: [{paste(result$symbol, collapse = ', ')}]"),
            namespace = "rsixer/outputs"
          )
          result
        })

        # -- KPI value boxes -------------------------------------------------------
        output$value_boxes <- shiny::renderUI({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / value_boxes",
            ns = "rsixer/outputs",
            {
              df <- perf_r()
              logger::log_debug(
                glue::glue("Rendering value boxes | n: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              boxes <- lapply(seq_len(nrow(df)), function(i) {
                row <- df[i, ]
                sharpe <- round(row$sharpe, 2)
                theme <- if (sharpe >= 1) "success" else if (sharpe >= 0) "warning" else "danger"

                bslib::value_box(
                  title = row$symbol,
                  value = scales::percent(row$ann_return, accuracy = 0.1),
                  showcase = bsicons::bs_icon("bar-chart-fill"),
                  theme = theme,
                  shiny::p(glue::glue(
                    "Vol: {scales::percent(row$ann_vol, accuracy = 0.1)}  |  Sharpe: {sharpe}"
                  ))
                )
              })

              n_cols <- min(nrow(df), 4L)
              bslib::layout_columns(!!!boxes, col_widths = rep(12L %/% n_cols, n_cols))
            }
          )
        })

        # -- 1. bslib popover boxes ------------------------------------------------
        output$bslib_boxes <- shiny::renderUI({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / bslib_boxes",
            ns = "rsixer/outputs",
            {
              df <- perf_r()
              logger::log_debug(
                glue::glue("Rendering bslib popover boxes | n: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              boxes <- lapply(seq_len(nrow(df)), function(i) {
                row <- df[i, ]

                popover_body <- shiny::tags$ul(
                  shiny::tags$li(glue::glue(
                    "Ann. Return: {scales::percent(row$ann_return, accuracy = 0.1)}"
                  )),
                  shiny::tags$li(glue::glue(
                    "Ann. Vol: {scales::percent(row$ann_vol, accuracy = 0.1)}"
                  )),
                  shiny::tags$li(glue::glue(
                    "Sharpe Ratio: {round(row$sharpe, 2)}"
                  ))
                )

                bslib::value_box(
                  title = shiny::tagList(
                    row$symbol,
                    mod_tooltip(
                      trigger = bsicons::bs_icon("info-circle-fill", class = "ms-1 text-info"),
                      type = "bslib",
                      contents = as.character(popover_body),
                      title = glue::glue("{row$symbol} - Performance Summary")
                    )
                  ),
                  value = scales::percent(row$ann_return, accuracy = 0.1),
                  showcase = bsicons::bs_icon("graph-up-arrow")
                )
              })

              n_cols <- min(nrow(df), 4L)
              bslib::layout_columns(!!!boxes, col_widths = rep(12L %/% n_cols, n_cols))
            }
          )
        })

        # -- 2. shinyhelper cards --------------------------------------------------
        output$shinyhelper_cards <- shiny::renderUI({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / shinyhelper_cards",
            ns = "rsixer/outputs",
            {
              df <- perf_r()
              logger::log_debug(
                glue::glue("Rendering shinyhelper cards | n: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              cards <- lapply(seq_len(nrow(df)), function(i) {
                row <- df[i, ]

                # Plain-text vector: helper(type = "inline") joins with <br>.
                help_content <- c(
                  row$symbol,
                  paste0("Ann. Return: ", scales::percent(row$ann_return, accuracy = 0.1)),
                  paste0("Ann. Vol: ", scales::percent(row$ann_vol, accuracy = 0.1)),
                  paste0("Sharpe: ", round(row$sharpe, 2))
                )

                bslib::card(
                  class = "text-center p-3",
                  mod_tooltip(
                    trigger = shiny::tags$span(class = "fs-4 fw-bold", row$symbol),
                    type = "shinyhelper",
                    contents = help_content,
                    helper_type = "inline",
                    helper_size = "m",
                    title = glue::glue("{row$symbol} - Performance Summary")
                  ),
                  shiny::tags$p(
                    class = "text-muted mb-0",
                    scales::percent(row$ann_return, accuracy = 0.1)
                  )
                )
              })

              n_cols <- min(nrow(df), 4L)
              bslib::layout_columns(!!!cards, col_widths = rep(12L %/% n_cols, n_cols))
            }
          )
        })

        # -- 3. prompter cards -----------------------------------------------------
        output$prompter_cards <- shiny::renderUI({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / prompter_cards",
            ns = "rsixer/outputs",
            {
              df <- perf_r()
              logger::log_debug(
                glue::glue("Rendering prompter cards | n: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              cards <- lapply(seq_len(nrow(df)), function(i) {
                row <- df[i, ]

                bslib::card(
                  class = "p-3",
                  bslib::card_header(shiny::tags$strong(row$symbol)),
                  bslib::card_body(
                    shiny::tags$dl(
                      shiny::tags$dt(
                        mod_tooltip(
                          trigger = shiny::tags$span("Ann. Return"),
                          type = "prompter",
                          contents = glue::glue(
                            "Annualised log return for {row$symbol}: ",
                            "{scales::percent(row$ann_return, accuracy = 0.1)}"
                          ),
                          position = "right"
                        )
                      ),
                      shiny::tags$dd(scales::percent(row$ann_return, accuracy = 0.1)),
                      shiny::tags$dt(
                        mod_tooltip(
                          trigger = shiny::tags$span("Ann. Vol"),
                          type = "prompter",
                          contents = glue::glue(
                            "Annualised volatility for {row$symbol}: ",
                            "{scales::percent(row$ann_vol, accuracy = 0.1)}"
                          ),
                          position = "right"
                        )
                      ),
                      shiny::tags$dd(scales::percent(row$ann_vol, accuracy = 0.1)),
                      shiny::tags$dt(
                        mod_tooltip(
                          trigger = shiny::tags$span("Sharpe"),
                          type = "prompter",
                          contents = glue::glue(
                            "Sharpe ratio (zero risk-free rate) for {row$symbol}: ",
                            "{round(row$sharpe, 2)}"
                          ),
                          position = "right"
                        )
                      ),
                      shiny::tags$dd(round(row$sharpe, 2))
                    )
                  )
                )
              })

              n_cols <- min(nrow(df), 4L)
              bslib::layout_columns(!!!cards, col_widths = rep(12L %/% n_cols, n_cols))
            }
          )
        })

        # -- 4. shinyalert cards ---------------------------------------------------
        output$shinyalert_cards <- shiny::renderUI({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / shinyalert_cards",
            ns = "rsixer/outputs",
            {
              df <- perf_r()
              logger::log_debug(
                glue::glue("Rendering shinyalert cards | n: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              cards <- lapply(seq_len(nrow(df)), function(i) {
                row <- df[i, ]

                alert_text <- paste0(
                  "Ann. Return: ", scales::percent(row$ann_return, accuracy = 0.1), "<br>",
                  "Ann. Vol: ", scales::percent(row$ann_vol, accuracy = 0.1), "<br>",
                  "Sharpe: ", round(row$sharpe, 2)
                )

                bslib::card(
                  class = "text-center p-3",
                  mod_tooltip(
                    trigger = shiny::tags$span(class = "fs-4 fw-bold", row$symbol),
                    type = "shinyalert",
                    alert_type = "info",
                    contents = alert_text,
                    title = glue::glue("{row$symbol} - Performance Summary"),
                    confirmButtonText = "Close"
                  ),
                  shiny::tags$p(
                    class = "text-muted mb-0",
                    "Click ticker to view details"
                  )
                )
              })

              n_cols <- min(nrow(df), 4L)
              bslib::layout_columns(!!!cards, col_widths = rep(12L %/% n_cols, n_cols))
            }
          )
        })

        # -- 5. reactable ----------------------------------------------------------
        output$reactable_perf <- reactable::renderReactable({
          shiny::req(perf_r())
          with_logging(
            context = "ModOutputs / reactable_perf",
            ns = "rsixer/outputs",
            {
              df <- perf_r() |>
                dplyr::mutate(
                  ann_return = round(ann_return * 100, 2),
                  ann_vol = round(ann_vol * 100, 2),
                  sharpe = round(sharpe, 2)
                )

              logger::log_debug(
                glue::glue("Rendering reactable | rows: {nrow(df)}"),
                namespace = "rsixer/outputs"
              )

              reactable::reactable(
                df,
                columns = list(
                  symbol = reactable::colDef(name = "Ticker"),

                  ann_return = reactable::colDef(
                    name = "Ann. Return (%)",
                    html = TRUE,
                    cell = function(value, index) {
                      mod_hoverinfo(
                        type = "reactable",
                        contents = glue::glue(
                          "Annualised log return for {df$symbol[index]}: {value}%"
                        ),
                        display = glue::glue("{value}%"),
                        style = paste0(
                          "color:", if (value >= 0) "#198754" else "#dc3545",
                          "; cursor:help"
                        )
                      )
                    }
                  ),

                  ann_vol = reactable::colDef(
                    name = "Ann. Vol (%)",
                    html = TRUE,
                    cell = function(value, index) {
                      mod_hoverinfo(
                        type = "reactable",
                        contents = glue::glue(
                          "Annualised volatility for {df$symbol[index]}: {value}%"
                        ),
                        display = glue::glue("{value}%"),
                        style = "cursor:help"
                      )
                    }
                  ),

                  sharpe = reactable::colDef(
                    name = "Sharpe",
                    html = TRUE,
                    cell = function(value, index) {
                      col <- if (value >= 1) "#198754" else if (value >= 0) "#fd7e14" else "#dc3545"
                      mod_hoverinfo(
                        type = "reactable",
                        contents = glue::glue(
                          "Sharpe ratio (zero risk-free) for {df$symbol[index]}: {value}"
                        ),
                        display = value,
                        style = paste0("color:", col, "; cursor:help")
                      )
                    }
                  )
                ),
                striped = TRUE,
                highlight = TRUE,
                bordered = TRUE,
                defaultPageSize = 10L
              )
            }
          )
        })

        # Return perf data for download module
        perf_r
      })
    }
  ),

  private = list(
    id = NULL,
    ns = NULL
  )
)
