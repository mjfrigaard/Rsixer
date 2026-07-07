test_that("ModOutputs instantiation creates valid R6 object", {
  outputs <- ModOutputs$new(id = "test")
  expect_s3_class(outputs, "R6")
  expect_true(inherits(outputs, "ModOutputs"))
})

test_that("ModOutputs$ui() returns valid tag structure", {
  outputs <- ModOutputs$new(id = "test")
  ui <- outputs$ui()

  expect_s3_class(ui, "shiny.tagList")
  ui_str <- as.character(ui)

  # Check for key components
  expect_match(ui_str, "uiOutput")
  expect_match(ui_str, "navset_card_tab")
  expect_match(ui_str, "bslib")
  expect_match(ui_str, "shinyhelper")
  expect_match(ui_str, "prompter")
  expect_match(ui_str, "shinyalert")
  expect_match(ui_str, "reactable")
})

test_that("ModOutputs$ui() uses correct namespace IDs", {
  outputs <- ModOutputs$new(id = "myoutputs")
  ui <- outputs$ui()
  ui_str <- as.character(ui)

  expect_match(ui_str, "myoutputs-value_boxes")
  expect_match(ui_str, "myoutputs-tabs")
  expect_match(ui_str, "myoutputs-bslib_boxes")
  expect_match(ui_str, "myoutputs-reactable_perf")
})

test_that("ModOutputs$server() returns reactive performance tibble", {
  # Create mock inputs_r reactive
  shiny::testServer(
    app = function(input, output, session) {
      # Mock inputs_r
      inputs_r <- shiny::reactive(list(
        tickers = c("AAPL"),
        from = as.Date("2023-01-01"),
        to = as.Date("2023-12-31"),
        vol_window = 30L,
        fetch = 0,
        format = "html"
      ))

      outputs <- ModOutputs$new(id = "test")
      perf_r <- outputs$server(inputs_r = inputs_r)

      # Verify it returns a reactive
      expect_true(shiny::is.reactive(perf_r))
    },
    args = list()
  )
})

test_that("ModOutputs namespace isolation prevents ID conflicts", {
  outputs1 <- ModOutputs$new(id = "outputs1")
  outputs2 <- ModOutputs$new(id = "outputs2")

  ui1 <- as.character(outputs1$ui())
  ui2 <- as.character(outputs2$ui())

  expect_match(ui1, "outputs1-value_boxes")
  expect_match(ui2, "outputs2-value_boxes")
  expect_no_match(ui1, "outputs2")
  expect_no_match(ui2, "outputs1")
})

test_that("ModOutputs contains all five demo tabs", {
  outputs <- ModOutputs$new(id = "test")
  ui <- outputs$ui()
  ui_str <- as.character(ui)

  # Check for all five tab titles
  expect_match(ui_str, "bslib", ignore.case = TRUE)
  expect_match(ui_str, "shinyhelper", ignore.case = TRUE)
  expect_match(ui_str, "prompter", ignore.case = TRUE)
  expect_match(ui_str, "shinyalert", ignore.case = TRUE)
  expect_match(ui_str, "reactable", ignore.case = TRUE)
})
