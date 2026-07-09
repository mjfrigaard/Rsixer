# Execute an Expression with Structured Error and Warning Logging

Wraps `expr` in a [`tryCatch()`](https://rdrr.io/r/base/conditions.html)
that:

- logs warnings via
  [`logger::log_warn()`](https://daroczig.github.io/logger/reference/log_level.html)
  and re-issues them so Shiny can also handle them

- logs errors via
  [`logger::log_error()`](https://daroczig.github.io/logger/reference/log_level.html)
  and re-throws so the caller / Shiny sees the error normally

## Usage

``` r
with_logging(expr, context = "", ns = "rsixer/app")
```

## Arguments

- expr:

  Expression to evaluate (passed unevaluated via `...`).

- context:

  Short string identifying the call site, e.g.
  `"mod_outputs / prices_r"`. Prepended to every log message.

- ns:

  Logger namespace string. Defaults to `"rsixer/app"`.

## Value

The value of `expr` on success; re-throws on error.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- with_logging(
  context = "my_module / compute",
  ns = "rsixer/app",
  sqrt(4)
)
} # }
```
