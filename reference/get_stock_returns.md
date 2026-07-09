# Compute Daily Log Returns from Price Data

Calculates daily log returns from the adjusted closing price column
produced by
[`get_stock_prices()`](https://mjfrigaard.github.io/Rsixer/reference/get_stock_prices.md).
Validates input and handles edge cases.

## Usage

``` r
get_stock_returns(prices)
```

## Arguments

- prices:

  A tibble returned by
  [`get_stock_prices()`](https://mjfrigaard.github.io/Rsixer/reference/get_stock_prices.md).

## Value

A tibble with columns `symbol`, `date`, `daily_return`.
