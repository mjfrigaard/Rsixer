# Null-Coalescing Operator

A lightweight null-coalescing operator that avoids a dependency on
rlang. Returns the left-hand side if not NULL, otherwise the right-hand
side.

## Usage

``` r
x %||% y
```

## Arguments

- x:

  Left-hand value.

- y:

  Right-hand value (returned if x is NULL).

## Value

`x` if not NULL, otherwise `y`.

## Examples

``` r
NULL %||% "default"
#> [1] "default"
"value" %||% "default"
#> [1] "value"
```
