# Compute Rolling Annualised Volatility

Computes a rolling standard deviation of daily log returns, annualised
by multiplying by `sqrt(252)`. Validates window and handles edge cases.

## Usage

``` r
compute_rolling_vol(returns, window = 30L)
```

## Arguments

- returns:

  A tibble returned by
  [`get_stock_returns()`](https://mjfrigaard.github.io/Rsixer/reference/get_stock_returns.md).

- window:

  Integer. Rolling window in trading days. Default 30.

## Value

The input tibble with an additional `rolling_vol` column.
