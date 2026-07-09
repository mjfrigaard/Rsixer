# Rsixer

The goal of `Rsixer` is to demonstrate using R6s in Shiny applications.

## Installation

You can install the development version of `Rsixer` like so:

``` r

install.packages("pak")
pak::pak("mjfrigaard/Rsixer")
```

## Overview

**Rsixer** is a complete, production-ready Shiny application that
demonstrates modern R6 design patterns for modular, maintainable Shiny
applications. It is functionally equivalent to `tooltipexplorer` but
uses object-oriented principles throughout.

## Deployment & Distribution

### Package Installation

``` r

# From GitHub
pak::pak("mjfrigaard/Rsixer")

# Or with devtools
devtools::install_github("mjfrigaard/Rsixer")
```

### Launching the App

``` r

library(rsixer)
rsixer::launch()
```

### Customization

Users can extend the package by: 1. Creating new R6 module classes
following the established patterns 2. Reusing data utility functions in
their own applications 3. Using the app as a template for similar
financial analysis dashboards

## Files Summary

| File | Type | Lines | Purpose |
|----|----|----|----|
| mod_inputs.R | R6 Class | 112 | Input sidebar module |
| mod_outputs.R | R6 Class | 456 | Main content with 5 demo tabs |
| mod_download.R | R6 Class | 97 | Report download module |
| app_ui.R | Function | 87 | Top-level UI composition |
| app_server.R | Function | 54 | Top-level server orchestration |
| launch.R | Function | 28 | App launcher |
| mod_tooltip.R | Function | 174 | Tooltip helper (5 backends) |
| mod_hoverinfo.R | Function | 80 | Hover-info helper |
| utils_logging.R | Functions | 71 | Logging utilities |
| utils_operators.R | Operator | 14 | %\|\|% null-coalescing |
| utils_data.R | Functions | 115 | Data utilities (5 functions) |
| DESCRIPTION | Config | 36 | Package metadata |
| README.md | Doc | 280+ | Comprehensive guide |
| IMPLEMENTATION_SUMMARY.md | Doc | This file | Implementation details |
| test\_\*.R | Tests | 56 cases | Comprehensive test suite |
| report_template.Rmd | Template | 153 | R Markdown report template |

**Total R Source Files**: 11  
**Total Test Files**: 7  
**Total Test Cases**: 56  
**Total Lines of Code**: ~1,400+ (R + tests)
