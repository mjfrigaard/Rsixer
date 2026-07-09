# Summarise Performance Metrics by Ticker

Computes annualised return, annualised volatility, and Sharpe ratio
(assuming zero risk-free rate) for each ticker. Validates input and
handles edge cases (zero volatility, missing returns).

## Usage

``` r
summarise_performance(returns)
```

## Arguments

- returns:

  A tibble returned by
  [`get_stock_returns()`](https://mjfrigaard.github.io/Rsixer/reference/get_stock_returns.md).

## Value

A tibble with columns: `symbol`, `ann_return`, `ann_vol`, `sharpe`.
