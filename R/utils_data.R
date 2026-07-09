#' Default Stock Tickers
#'
#' A character vector of stock tickers used as app defaults.
#'
#' @export
default_tickers <- c("LLY", "MRK", "JNJ", "PFE", "ABBV", "BMY", "AMGN")

#' Generate Demo Stock Prices
#'
#' Creates realistic demo data for testing when Yahoo Finance is unavailable.
#' Used internally by [get_stock_prices()] as fallback.
#'
#' @param tickers Character vector of ticker symbols
#' @param from Start date
#' @param to End date
#'
#' @return Tibble with price data
#'
#' @keywords internal
.get_demo_prices <- function(tickers, from, to) {
  set.seed(4821)
  days <- as.integer(to - from) + 1
  
  tidyr::expand_grid(
    symbol = tickers,
    date = seq(from, to, by = "day")
  ) |>
    dplyr::mutate(
      base_price = dplyr::case_when(
        symbol == "LLY" ~ 580,
        symbol == "MRK" ~ 75,
        symbol == "JNJ" ~ 158,
        symbol == "PFE" ~ 38,
        symbol == "ABBV" ~ 180,
        symbol == "BMY" ~ 85,
        symbol == "AMGN" ~ 335,
        .default = 100
      ),
      noise = rnorm(dplyr::n(), 0, 1),
      adjusted = base_price + cumsum(noise) / 100
    ) |>
    dplyr::mutate(
      open = adjusted + rnorm(dplyr::n(), 0, 1),
      high = pmax(open, adjusted) + abs(rnorm(dplyr::n(), 0, 1)),
      low = pmin(open, adjusted) - abs(rnorm(dplyr::n(), 0, 1)),
      close = adjusted,
      volume = rpois(dplyr::n(), lambda = 5000000)
    ) |>
    dplyr::select(symbol, date, open, high, low, close, volume, adjusted)
}

#' Retrieve Historical Adjusted Prices via tidyquant
#'
#' Downloads daily adjusted closing prices from Yahoo Finance for one or
#' more ticker symbols over a given date range. Includes validation and
#' robust error handling.
#'
#' @param tickers A character vector of ticker symbols.
#' @param from    A `Date` or date string (`"YYYY-MM-DD"`). Start of range.
#' @param to      A `Date` or date string. End of range. Defaults to today.
#'
#' @return A tibble with columns:
#'   `symbol`, `date`, `open`, `high`, `low`, `close`, `volume`, `adjusted`.
#'   On error, throws with details. Use tryCatch() in calling code.
#'
#' @examples
#' \dontrun{
#' get_stock_prices(c("AAPL", "MSFT"), from = "2023-01-01")
#' }
#'
#' @export
get_stock_prices <- function(tickers, from, to = Sys.Date()) {
  # Input validation
  if (!is.character(tickers) || length(tickers) == 0) {
    stop("tickers must be a non-empty character vector", call. = FALSE)
  }
  
  from <- as.Date(from)
  to <- as.Date(to)
  
  if (is.na(from) || is.na(to)) {
    stop("from and to must be valid dates", call. = FALSE)
  }
  
  if (from >= to) {
    stop("from must be before to", call. = FALSE)
  }
  
  # Fetch each ticker individually to isolate failures
  all_results <- list()
  failed_tickers <- character()
  
  for (ticker in tickers) {
    result <- tryCatch(
      {
        suppressWarnings({
          tidyquant::tq_get(
            x = ticker,
            get = "stock.prices",
            from = from,
            to = to,
            complete_cases = FALSE,
            warnings = FALSE
          )
        })
      },
      error = function(e) {
        NULL
      }
    )
    
    # Check if result is valid (not NULL and has rows)
    if (is.null(result) || nrow(result) == 0) {
      failed_tickers <- c(failed_tickers, ticker)
    } else {
      all_results[[ticker]] <- result
    }
  }
  
  # If some tickers succeeded, combine and use them
  if (length(all_results) > 0) {
    combined <- do.call(dplyr::bind_rows, all_results)
    if (nrow(combined) > 0) {
      # Log which tickers failed
      if (length(failed_tickers) > 0) {
        logger::log_warn(
          paste0("Partial fetch: failed tickers [", paste(failed_tickers, collapse = ", "), "] using fallback demo data instead"),
          namespace = "rsixer/data"
        )
      }
      return(combined)
    }
  }
  
  # All tickers failed; fall back to demo data
  logger::log_warn(
    paste0("Yahoo Finance unavailable for all tickers [", paste(failed_tickers, collapse = ", "), "]. Using demo data."),
    namespace = "rsixer/data"
  )
  
  demo_data <- .get_demo_prices(tickers, from, to)
  
  # Add attribute to flag that this is demo data
  attr(demo_data, "is_demo") <- TRUE
  demo_data
}

#' Compute Daily Log Returns from Price Data
#'
#' Calculates daily log returns from the adjusted closing price column
#' produced by [get_stock_prices()]. Validates input and handles edge cases.
#'
#' @param prices A tibble returned by [get_stock_prices()].
#'
#' @return A tibble with columns `symbol`, `date`, `daily_return`.
#'
#' @export
get_stock_returns <- function(prices) {
  if (!inherits(prices, "data.frame") || nrow(prices) == 0) {
    stop("prices must be a non-empty data frame", call. = FALSE)
  }
  
  if (!all(c("symbol", "date", "adjusted") %in% names(prices))) {
    stop("prices must contain symbol, date, and adjusted columns", call. = FALSE)
  }
  
  if (any(is.na(prices$adjusted))) {
    warning("Removing NA values from adjusted prices", call. = FALSE)
  }
  
  result <- prices |>
    dplyr::arrange(.data$symbol, .data$date) |>
    dplyr::group_by(.data$symbol) |>
    dplyr::mutate(
      daily_return = log(.data$adjusted / dplyr::lag(.data$adjusted))
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(!is.na(.data$daily_return)) |>
    dplyr::select("symbol", "date", "daily_return")
  
  if (nrow(result) == 0) {
    stop("No valid returns computed from input data", call. = FALSE)
  }
  
  result
}

#' Summarise Performance Metrics by Ticker
#'
#' Computes annualised return, annualised volatility, and Sharpe ratio
#' (assuming zero risk-free rate) for each ticker. Validates input and
#' handles edge cases (zero volatility, missing returns).
#'
#' @param returns A tibble returned by [get_stock_returns()].
#'
#' @return A tibble with columns:
#'   `symbol`, `ann_return`, `ann_vol`, `sharpe`.
#'
#' @export
summarise_performance <- function(returns) {
  if (!inherits(returns, "data.frame") || nrow(returns) == 0) {
    stop("returns must be a non-empty data frame", call. = FALSE)
  }
  
  if (!all(c("symbol", "daily_return") %in% names(returns))) {
    stop("returns must contain symbol and daily_return columns", call. = FALSE)
  }
  
  result <- returns |>
    dplyr::summarise(
      ann_return = mean(.data$daily_return, na.rm = TRUE) * 252,
      ann_vol = sd(.data$daily_return, na.rm = TRUE) * sqrt(252),
      .by = symbol
    ) |>
    dplyr::mutate(
      sharpe = dplyr::if_else(
        .data$ann_vol > 0,
        .data$ann_return / .data$ann_vol,
        0  # Zero volatility edge case
      )
    )
  
  if (nrow(result) == 0) {
    stop("No performance metrics computed from input data", call. = FALSE)
  }
  
  result
}

#' Compute Rolling Annualised Volatility
#'
#' Computes a rolling standard deviation of daily log returns, annualised
#' by multiplying by `sqrt(252)`. Validates window and handles edge cases.
#'
#' @param returns A tibble returned by [get_stock_returns()].
#' @param window  Integer. Rolling window in trading days. Default 30.
#'
#' @return The input tibble with an additional `rolling_vol` column.
#'
#' @export
compute_rolling_vol <- function(returns, window = 30L) {
  if (!inherits(returns, "data.frame") || nrow(returns) == 0) {
    stop("returns must be a non-empty data frame", call. = FALSE)
  }
  
  if (!all(c("symbol", "daily_return") %in% names(returns))) {
    stop("returns must contain symbol and daily_return columns", call. = FALSE)
  }
  
  window <- as.integer(window)
  if (window < 1) {
    stop("window must be a positive integer", call. = FALSE)
  }
  
  result <- returns |>
    dplyr::group_by(.data$symbol) |>
    dplyr::mutate(
      rolling_vol = slider::slide_dbl(
        .x = .data$daily_return,
        .f = sd,
        .before = window - 1L,
        .complete = TRUE
      ) * sqrt(252)
    ) |>
    dplyr::ungroup()
  
  result
}
