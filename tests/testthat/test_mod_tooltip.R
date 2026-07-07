test_that("mod_tooltip returns a Shiny tag", {
  tooltip <- mod_tooltip(
    type = "bslib",
    contents = "Test content"
  )
  expect_s3_class(tooltip, "shiny.tag")
})

test_that("mod_tooltip with bslib type works", {
  tooltip <- mod_tooltip(
    trigger = shiny::tags$span("Info"),
    type = "bslib",
    contents = "A test tooltip"
  )
  expect_s3_class(tooltip, "shiny.tag")
  tooltip_str <- as.character(tooltip)
  expect_match(tooltip_str, "popover")
})

test_that("mod_tooltip with shinyhelper type works", {
  tooltip <- mod_tooltip(
    trigger = shiny::tags$span("Help"),
    type = "shinyhelper",
    contents = c("Line 1", "Line 2"),
    helper_type = "inline",
    helper_size = "m"
  )
  expect_s3_class(tooltip, "shiny.tag")
})

test_that("mod_tooltip with prompter type works", {
  tooltip <- mod_tooltip(
    trigger = shiny::tags$span("Hover me"),
    type = "prompter",
    contents = "Prompter tooltip",
    position = "right"
  )
  expect_s3_class(tooltip, "shiny.tag")
  tooltip_str <- as.character(tooltip)
  expect_match(tooltip_str, "prompt")
})

test_that("mod_tooltip with shinyalert type works", {
  tooltip <- mod_tooltip(
    trigger = shiny::tags$span("Click me"),
    type = "shinyalert",
    contents = "Alert content",
    title = "Alert Title",
    alert_type = "info"
  )
  expect_s3_class(tooltip, "shiny.tag")
  tooltip_str <- as.character(tooltip)
  expect_match(tooltip_str, "sa-trigger")
  expect_match(tooltip_str, "data-sa-")
})

test_that("mod_tooltip accepts custom size parameter", {
  tooltip <- mod_tooltip(
    type = "bslib",
    contents = "Test",
    size = "0.85rem"
  )
  tooltip_str <- as.character(tooltip)
  expect_match(tooltip_str, "0.85rem")
})

test_that("mod_tooltip accepts custom style parameter", {
  tooltip <- mod_tooltip(
    type = "bslib",
    contents = "Test",
    style = "color:red"
  )
  tooltip_str <- as.character(tooltip)
  expect_match(tooltip_str, "color:red")
})

test_that("mod_tooltip with invalid type argument errors", {
  expect_error(
    mod_tooltip(
      type = "invalid",
      contents = "Test"
    ),
    "invalid"
  )
})

test_that("mod_tooltip default trigger is info icon", {
  tooltip <- mod_tooltip(contents = "Test")
  expect_s3_class(tooltip, "shiny.tag")
})
