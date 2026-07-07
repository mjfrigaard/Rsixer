#' ModDownload R6 Class
#'
#' Handles report generation and download with format selection (HTML/PDF).
#' Uses R6 for object-oriented Shiny module design.
#'
#' @examples
#' \dontrun{
#' # In app_server():
#' download <- ModDownload$new(id = "download")
#' download$server(inputs_r, perf_r)
#' }
#'
#' @export
ModDownload <- R6::R6Class(
  "ModDownload",

  public = list(
    #' @description Initialize a new ModDownload instance
    #' @param id Character. Module namespace id.
    initialize = function(id = "download") {
      private$id <- id
      private$ns <- shiny::NS(id)
    },

    #' @description Initialize server logic
    #' @param inputs_r Reactive list returned by ModInputs$server()
    #' @param perf_r Reactive tibble returned by ModOutputs$server()
    #' @return Called for side-effects; returns NULL invisibly
    server = function(inputs_r, perf_r) {
      shiny::moduleServer(private$id, function(input, output, session) {

        logger::log_debug(
          "ModDownload$server() initialised | id: {private$id}",
          namespace = "rsixer/download"
        )

        output$download <- shiny::downloadHandler(

          filename = function() {
            with_logging(
              context = "ModDownload / filename",
              ns = "rsixer/download",
              {
                ts <- format(Sys.time(), "%Y%m%d_%H%M%S")
                ext <- if (input$format == "html") "html" else "pdf"
                fname <- glue::glue("rsixer_report_{ts}.{ext}")
                logger::log_info(
                  "Download filename generated | file: {fname}",
                  namespace = "rsixer/download"
                )
                fname
              }
            )
          },

          content = function(file) {
            shiny::req(perf_r())
            inp <- inputs_r()

            logger::log_info(
              "Report render started | format: {input$format} | tickers: [{paste(inp$tickers, collapse = ', ')}]",
              namespace = "rsixer/download"
            )

            template <- system.file(
              "report_template.Rmd",
              package = "rsixer"
            )

            if (!nzchar(template)) {
              logger::log_error(
                "report_template.Rmd not found in package inst/",
                namespace = "rsixer/download"
              )
              stop("Report template not found. Is the package installed correctly?")
            }

            # Render into an isolated temp directory
            tmp_dir <- tempfile()
            dir.create(tmp_dir, recursive = TRUE)
            tmp_rmd <- file.path(tmp_dir, "report.Rmd")
            file.copy(template, tmp_rmd)

            logger::log_debug(
              "Rendering to temp dir | path: {tmp_dir}",
              namespace = "rsixer/download"
            )

            out_fmt <- if (input$format == "html") {
              rmarkdown::html_document(
                toc = TRUE,
                toc_float = TRUE,
                theme = "cosmo",
                highlight = "tango",
                self_contained = TRUE
              )
            } else {
              rmarkdown::pdf_document(toc = TRUE)
            }

            tryCatch(
              rmarkdown::render(
                input = tmp_rmd,
                output_format = out_fmt,
                output_file = file,
                params = list(
                  tickers = inp$tickers,
                  from = as.character(inp$from),
                  to = as.character(inp$to),
                  vol_window = inp$vol_window,
                  perf_data = perf_r()
                ),
                envir = new.env(parent = globalenv()),
                quiet = TRUE
              ),
              error = function(e) {
                logger::log_error(
                  "rmarkdown::render() failed | format: {input$format} | error: {conditionMessage(e)}",
                  namespace = "rsixer/download"
                )
                shiny::showNotification(
                  paste("Report generation failed:", conditionMessage(e)),
                  type = "error",
                  duration = 15
                )
                stop(e)
              }
            )

            logger::log_info(
              "Report render complete | format: {input$format} | file: {file}",
              namespace = "rsixer/download"
            )
          }
        )
      })
    }
  ),

  private = list(
    id = NULL,
    ns = NULL
  )
)
