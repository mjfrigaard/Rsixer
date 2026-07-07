test_that("with_logging executes expression successfully", {
  result <- with_logging(
    context = "test",
    ns = "rsixer/test",
    {
      2 + 2
    }
  )
  expect_equal(result, 4)
})

test_that("with_logging returns correct value", {
  result <- with_logging(
    context = "test",
    ns = "rsixer/test",
    {
      c(1, 2, 3)
    }
  )
  expect_equal(result, c(1, 2, 3))
})

test_that("with_logging re-throws errors", {
  expect_error(
    with_logging(
      context = "test",
      ns = "rsixer/test",
      {
        stop("Test error")
      }
    ),
    "Test error"
  )
})

test_that("with_logging suppresses and logs warnings", {
  # Expect no warning to propagate to caller
  expect_warning(
    with_logging(
      context = "test",
      ns = "rsixer/test",
      {
        warning("Test warning")
      }
    ),
    NA
  )
})

test_that("with_logging accepts default parameters", {
  result <- with_logging({
    5 * 5
  })
  expect_equal(result, 25)
})

test_that("app_set_log_threshold returns level invisibly", {
  result <- app_set_log_threshold(logger::INFO)
  expect_equal(result, logger::INFO)
})

test_that("app_set_log_threshold sets thresholds for all namespaces", {
  # Just verify it doesn't error and processes all namespaces
  expect_error(
    app_set_log_threshold(logger::DEBUG),
    NA
  )
  expect_error(
    app_set_log_threshold(logger::INFO),
    NA
  )
  expect_error(
    app_set_log_threshold(logger::WARN),
    NA
  )
})

test_that("null-coalescing operator %||% works correctly", {
  expect_equal(NULL %||% "default", "default")
  expect_equal("value" %||% "default", "value")
  expect_equal(0 %||% "default", 0)
  expect_equal(FALSE %||% "default", FALSE)
  expect_equal("" %||% "default", "")
})

test_that("null-coalescing operator %||% returns second arg only for NULL", {
  expect_true(is.null(NULL %||% NULL))
  expect_equal(NA %||% "default", NA)
  expect_equal(list() %||% "default", list())
})
