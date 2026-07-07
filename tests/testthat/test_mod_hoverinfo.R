test_that("mod_hoverinfo returns an HTML span tag", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover content",
    display = "Value"
  )
  expect_s3_class(hoverinfo, "shiny.tag")
  expect_equal(hoverinfo$name, "span")
})

test_that("mod_hoverinfo sets title attribute", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Tooltip text",
    display = "Value"
  )
  expect_equal(hoverinfo$attribs$title, "Tooltip text")
})

test_that("mod_hoverinfo includes display content", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover",
    display = "Displayed"
  )
  hoverinfo_str <- as.character(hoverinfo)
  expect_match(hoverinfo_str, "Displayed")
  expect_match(hoverinfo_str, "Hover")
})

test_that("mod_hoverinfo joins multiple content lines", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = c("Line 1", "Line 2", "Line 3"),
    display = "Value"
  )
  expect_equal(hoverinfo$attribs$title, "Line 1 | Line 2 | Line 3")
})

test_that("mod_hoverinfo handles named character vectors", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = c(Metric = "Return", Value = "25%"),
    display = "Display"
  )
  expect_equal(hoverinfo$attribs$title, "Metric: Return | Value: 25%")
})

test_that("mod_hoverinfo accepts style parameter", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover",
    display = "Value",
    style = "cursor:help; color:blue"
  )
  expect_equal(hoverinfo$attribs$style, "cursor:help; color:blue")
})

test_that("mod_hoverinfo accepts size parameter", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover",
    display = "Value",
    size = "0.8rem"
  )
  expect_match(hoverinfo$attribs$style, "font-size:0.8rem")
})

test_that("mod_hoverinfo combines size and style", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover",
    display = "Value",
    size = "0.9rem",
    style = "color:green"
  )
  expect_match(hoverinfo$attribs$style, "font-size:0.9rem")
  expect_match(hoverinfo$attribs$style, "color:green")
})

test_that("mod_hoverinfo with empty contents", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = character(0),
    display = "Value"
  )
  expect_s3_class(hoverinfo, "shiny.tag")
})

test_that("mod_hoverinfo with NULL display", {
  hoverinfo <- mod_hoverinfo(
    type = "reactable",
    contents = "Hover text",
    display = NULL
  )
  expect_s3_class(hoverinfo, "shiny.tag")
  expect_equal(hoverinfo$attribs$title, "Hover text")
})
