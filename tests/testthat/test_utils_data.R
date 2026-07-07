test_that("default_tickers is a character vector", {
  expect_type(default_tickers, "character")
  expect_true(length(default_tickers) > 0)
})

test_that("default_tickers contains expected pharma tickers", {
  expect_true("LLY" %in% default_tickers)
  expect_true("MRK" %in% default_tickers)
  expect_true("JNJ" %in% default_tickers)
  expect_true("PFE" %in% default_tickers)
})

test_that("get_stock_returns computes log returns correctly", {
  # Create mock price data
  prices <- data.frame(
    symbol = c("AAPL", "AAPL", "AAPL"),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")),
    adjusted = c(100, 105, 110),
    stringsAsFactors = FALSE
  )

  returns <- get_stock_returns(prices)

  expect_equal(nrow(returns), 2) # One less than prices due to lag
  expect_true("symbol" %in% names(returns))
  expect_true("date" %in% names(returns))
  expect_true("daily_return" %in% names(returns))

  # Verify log return calculation
  expected_return <- log(105 / 100)
  expect_approximately_equal(returns$daily_return[1], expected_return, tolerance = 1e-10)
})

test_that("get_stock_returns removes NAs from lag", {
  prices <- data.frame(
    symbol = c("AAPL", "AAPL", "AAPL", "MSFT", "MSFT", "MSFT"),
    date = rep(as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")), 2),
    adjusted = c(100, 105, 110, 200, 210, 220),
    stringsAsFactors = FALSE
  )

  returns <- get_stock_returns(prices)

  # Should have 4 rows (2 groups × 2 returns per group, after removing NA lags)
  expect_equal(nrow(returns), 4)
  expect_false(any(is.na(returns$daily_return)))
})

test_that("summarise_performance calculates metrics correctly", {
  returns <- data.frame(
    symbol = c("AAPL", "AAPL", "AAPL"),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03")),
    daily_return = c(0.01, 0.02, -0.01),
    stringsAsFactors = FALSE
  )

  perf <- summarise_performance(returns)

  expect_equal(nrow(perf), 1)
  expect_equal(perf$symbol, "AAPL")

  # Verify annualised return: mean(0.01, 0.02, -0.01) * 252
  expected_return <- mean(c(0.01, 0.02, -0.01)) * 252
  expect_approximately_equal(perf$ann_return, expected_return, tolerance = 1e-10)

  # Verify annualised vol: sd(0.01, 0.02, -0.01) * sqrt(252)
  expected_vol <- sd(c(0.01, 0.02, -0.01)) * sqrt(252)
  expect_approximately_equal(perf$ann_vol, expected_vol, tolerance = 1e-10)

  # Verify Sharpe: return / vol
  expected_sharpe <- expected_return / expected_vol
  expect_approximately_equal(perf$sharpe, expected_sharpe, tolerance = 1e-10)
})

test_that("summarise_performance handles multiple tickers", {
  returns <- data.frame(
    symbol = c("AAPL", "AAPL", "MSFT", "MSFT"),
    date = rep(as.Date(c("2023-01-01", "2023-01-02")), 2),
    daily_return = c(0.01, 0.02, 0.015, 0.025),
    stringsAsFactors = FALSE
  )

  perf <- summarise_performance(returns)

  expect_equal(nrow(perf), 2)
  expect_true("AAPL" %in% perf$symbol)
  expect_true("MSFT" %in% perf$symbol)
})

test_that("compute_rolling_vol calculates rolling volatility", {
  returns <- data.frame(
    symbol = c("AAPL", "AAPL", "AAPL", "AAPL", "AAPL"),
    date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-03", "2023-01-04", "2023-01-05")),
    daily_return = c(0.01, 0.02, -0.01, 0.015, 0.02),
    stringsAsFactors = FALSE
  )

  vol <- compute_rolling_vol(returns, window = 3)

  expect_true("rolling_vol" %in% names(vol))
  expect_equal(nrow(vol), nrow(returns))

  # First 2 rows should be NA (window = 3)
  expect_true(is.na(vol$rolling_vol[1]))
  expect_true(is.na(vol$rolling_vol[2]))

  # Row 3 onward should have values
  expect_false(is.na(vol$rolling_vol[3]))
  expect_false(is.na(vol$rolling_vol[4]))
})

test_that("compute_rolling_vol respects window parameter", {
  returns <- data.frame(
    symbol = rep("AAPL", 10),
    date = as.Date(seq.Date(from = as.Date("2023-01-01"), by = "day", length.out = 10)),
    daily_return = rnorm(10, mean = 0.001, sd = 0.02),
    stringsAsFactors = FALSE
  )

  vol_5 <- compute_rolling_vol(returns, window = 5)
  vol_10 <- compute_rolling_vol(returns, window = 10)

  # vol_5 should have fewer NAs than vol_10
  expect_true(sum(is.na(vol_5$rolling_vol)) < sum(is.na(vol_10$rolling_vol)))
})
