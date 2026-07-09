# Set the Application-wide Log Threshold

A thin wrapper around
[`logger::log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.html)
that applies the chosen level to every logger namespace used by
**rsixer**.

## Usage

``` r
app_set_log_threshold(level = logger::INFO)
```

## Arguments

- level:

  A `logger` log-level object, e.g.
  [logger::DEBUG](https://daroczig.github.io/logger/reference/log_levels.html),
  [logger::INFO](https://daroczig.github.io/logger/reference/log_levels.html)
  (default),
  [logger::WARN](https://daroczig.github.io/logger/reference/log_levels.html).

## Value

Invisibly returns `level`.

## Details

Log levels from lowest to highest verbosity: `TRACE`, `DEBUG`, `INFO`,
`SUCCESS`, `WARN`, `ERROR`, `FATAL`. The default threshold is `INFO` —
`TRACE` and `DEBUG` lines are silent in production.

Internally, [`lapply()`](https://rdrr.io/r/base/lapply.html) iterates
over the namespace vector and calls
[`logger::log_threshold()`](https://daroczig.github.io/logger/reference/log_threshold.html)
for each entry. The return value of
[`lapply()`](https://rdrr.io/r/base/lapply.html) is discarded; only
`level` is returned (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
# Verbose output during development
app_set_log_threshold(logger::DEBUG)

# Quiet production mode
app_set_log_threshold(logger::WARN)
} # }
```
