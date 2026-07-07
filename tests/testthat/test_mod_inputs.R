test_that("ModInputs instantiation creates valid R6 object", {
  inputs <- ModInputs$new(id = "test")
  expect_s3_class(inputs, "R6")
  expect_true(inherits(inputs, "ModInputs"))
})

test_that("ModInputs$ui() returns valid Shiny sidebar", {
  inputs <- ModInputs$new(id = "test")
  ui <- inputs$ui()

  expect_s3_class(ui, "shiny.tag")
  expect_equal(ui$name, "div")
  # Check for key input elements
  ui_str <- as.character(ui)
  expect_match(ui_str, "selectizeInput")
  expect_match(ui_str, "dateRangeInput")
  expect_match(ui_str, "sliderInput")
  expect_match(ui_str, "Fetch data")
})

test_that("ModInputs$ui() uses correct namespace IDs", {
  inputs <- ModInputs$new(id = "myinputs")
  ui <- inputs$ui()
  ui_str <- as.character(ui)

  expect_match(ui_str, "myinputs-tickers")
  expect_match(ui_str, "myinputs-dates")
  expect_match(ui_str, "myinputs-vol_window")
  expect_match(ui_str, "myinputs-fetch")
})

test_that("ModInputs$server() returns reactive list", {
  shiny::testServer(
    app = function(input, output, session) {
      inputs <- ModInputs$new(id = "test")
      inputs_r <- inputs$server()

      # Verify it returns a reactive
      expect_true(shiny::is.reactive(inputs_r))

      # Call the reactive and check structure
      inp_vals <- inputs_r()
      expect_type(inp_vals, "list")
      expect_true("tickers" %in% names(inp_vals))
      expect_true("from" %in% names(inp_vals))
      expect_true("to" %in% names(inp_vals))
      expect_true("vol_window" %in% names(inp_vals))
      expect_true("fetch" %in% names(inp_vals))
      expect_true("format" %in% names(inp_vals))
    },
    args = list()
  )
})

test_that("ModInputs reactive updates when inputs change", {
  shiny::testServer(
    app = function(input, output, session) {
      inputs <- ModInputs$new(id = "test")
      inputs_r <- inputs$server()

      # Initial state
      initial <- inputs_r()
      expect_equal(initial$tickers, c("AAPL", "MSFT", "GOOGL"))

      # Simulate input change
      session$setInputs(`test-tickers` = c("AMZN", "TSLA"))

      # Reactive should update
      updated <- inputs_r()
      expect_equal(updated$tickers, c("AMZN", "TSLA"))
    },
    args = list()
  )
})

test_that("ModInputs namespace isolation prevents ID conflicts", {
  inputs1 <- ModInputs$new(id = "inputs1")
  inputs2 <- ModInputs$new(id = "inputs2")

  ui1 <- as.character(inputs1$ui())
  ui2 <- as.character(inputs2$ui())

  expect_match(ui1, "inputs1-tickers")
  expect_match(ui2, "inputs2-tickers")
  expect_no_match(ui1, "inputs2")
  expect_no_match(ui2, "inputs1")
})
