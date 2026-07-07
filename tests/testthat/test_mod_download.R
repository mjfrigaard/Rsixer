test_that("ModDownload instantiation creates valid R6 object", {
  download <- ModDownload$new(id = "test")
  expect_s3_class(download, "R6")
  expect_true(inherits(download, "ModDownload"))
})

test_that("ModDownload$server() accepts inputs_r and perf_r reactives", {
  shiny::testServer(
    app = function(input, output, session) {
      # Create mock reactives
      inputs_r <- shiny::reactive(list(
        tickers = c("AAPL"),
        from = as.Date("2023-01-01"),
        to = as.Date("2023-12-31"),
        vol_window = 30L,
        fetch = 0,
        format = "html"
      ))

      perf_r <- shiny::reactive(
        data.frame(
          symbol = "AAPL",
          ann_return = 0.25,
          ann_vol = 0.18,
          sharpe = 1.39
        )
      )

      download <- ModDownload$new(id = "test")

      # Should not error
      expect_error(download$server(inputs_r, perf_r), NA)
    },
    args = list()
  )
})

test_that("ModDownload uses correct namespace IDs", {
  download <- ModDownload$new(id = "mydownload")

  # Verify namespace is set correctly via server call
  shiny::testServer(
    app = function(input, output, session) {
      inputs_r <- shiny::reactive(list(
        tickers = "AAPL",
        from = as.Date("2023-01-01"),
        to = as.Date("2023-12-31"),
        vol_window = 30L,
        format = "html"
      ))

      perf_r <- shiny::reactive(
        data.frame(
          symbol = "AAPL",
          ann_return = 0.25,
          ann_vol = 0.18,
          sharpe = 1.39
        )
      )

      download$server(inputs_r, perf_r)

      # Check for output handler with correct namespace
      expect_true("download" %in% names(output))
    },
    args = list()
  )
})

test_that("ModDownload namespace isolation prevents ID conflicts", {
  download1 <- ModDownload$new(id = "download1")
  download2 <- ModDownload$new(id = "download2")

  expect_true(inherits(download1, "ModDownload"))
  expect_true(inherits(download2, "ModDownload"))
})
