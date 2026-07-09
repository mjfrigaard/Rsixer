# Generate Demo Stock Prices

Creates realistic demo data for testing when Yahoo Finance is
unavailable. Used internally by
[`get_stock_prices()`](https://mjfrigaard.github.io/Rsixer/reference/get_stock_prices.md)
as fallback.

## Usage

``` r
.get_demo_prices(tickers, from, to)
```

## Arguments

- tickers:

  Character vector of ticker symbols

- from:

  Start date

- to:

  End date

## Value

Tibble with price data
