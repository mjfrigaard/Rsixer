# Structure

``` r

library(rsixer)
#> 
#> Attaching package: 'rsixer'
#> The following object is masked from 'package:base':
#> 
#>     %||%
```

## Key Differences from `tooltipexplorer`

### What Changed

| Aspect | Before (`tooltipexplorer`) | After (`Rsixer`) |
|----|----|----|
| **Module Architecture** | Function-based (`mod_inputs_ui()` + `mod_inputs_server()`) | R6 classes (`ModInputs$new()` with `$ui()` and `$server()` methods) |
| **Namespace Management** | Traditional [`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) + [`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html) | R6-integrated namespace (stored in `private$ns`) |
| **Module Composition** | Separate UI and server function calls | Single R6 object instantiation |
| **Dependency Injection** | Reactive values passed as function arguments | R6 method arguments for clean dependency flow |
| **State Encapsulation** | Limited (function-level) | Strong (R6 private fields and methods) |
| **Code Organization** | 17+ R files with many small functions | 12 focused R files with R6 classes and utilities |
| **Testing** | Limited testing structure | Comprehensive `testthat` suite (7 test files) |

### 1. Module Composition

**Before**: Separate function calls in
[`app_ui()`](https://mjfrigaard.github.io/Rsixer/reference/app_ui.md)
and
[`app_server()`](https://mjfrigaard.github.io/Rsixer/reference/app_server.md)

``` r

# app_ui.R
mod_inputs_ui("inputs")
mod_outputs_ui("outputs")

# app_server.R
mod_inputs_server("inputs")
mod_outputs_server("outputs", inputs_r = inputs_r)
```

**After**: R6 object instantiation with clear method calls

``` r

# app_ui.R
inputs <- ModInputs$new(id = "inputs")
outputs <- ModOutputs$new(id = "outputs")

bslib::page_sidebar(
  sidebar = inputs$ui(),
  outputs$ui()
)

# app_server.R
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()

outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r = inputs_r)
```

### 2. Namespace Handling

**Before**: [`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html)
called separately in UI and server

``` r

mod_inputs_ui <- function(id) {
  ns <- shiny::NS(id)  # Called in UI
  ...
}

mod_inputs_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {  # Called in server
    ...
  })
}
```

**After**: [`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html)
created once, stored in private field

``` r

ModInputs <- R6::R6Class("ModInputs",
  public = list(
    initialize = function(id = "inputs") {
      private$id <- id
      private$ns <- shiny::NS(id)  # Created once
    },
    ui = function() { ... },
    server = function() { shiny::moduleServer(private$id, ...) }
  ),
  private = list(id = NULL, ns = NULL)
)
```

### 3. Testing

**Before**: Limited testing infrastructure (no test files in
`tooltipexplorer`)

**After**: Comprehensive `testthat` suite with 56 test cases covering:

- R6 class instantiation and methods

- UI generation and namespace isolation

- Server reactives and data pipelines

- Utility functions (data, logging, operators, helpers)

- Error handling and edge cases

------------------------------------------------------------------------

## File Structure

### R/ Directory (Core Implementation)

#### R6 Module Classes

1.  **`mod_inputs.R`** (ModInputs)
    - **Lines**: 112
    - **Public Methods**:
      - `initialize(id = "inputs")` - Constructor with namespace setup
      - `ui()` - Returns sidebar UI with all input controls
      - `server()` - Returns reactive list with tickers, dates,
        vol_window, fetch, format
    - **Private Fields**: `id`, `ns`
    - **Key Features**: Integrated tooltip helpers, namespace isolation,
      fetch button observer
2.  **`mod_outputs.R`** (ModOutputs)
    - **Lines**: 456
    - **Public Methods**:
      - `initialize(id = "outputs")` - Constructor with namespace setup
      - `ui()` - Returns main content UI with 5 demo tabs + KPI boxes
      - `server(inputs_r)` - Orchestrates data fetching, computation,
        rendering
    - **Private Fields**: `id`, `ns`
    - **Key Features**:
      - Five tooltip/hover demo tabs (bslib, shinyhelper, prompter,
        shinyalert, reactable)
      - Reactive data pipeline (prices → returns → performance)
      - KPI value boxes with color-coded Sharpe ratios
3.  **`mod_download.R`** (ModDownload)
    - **Lines**: 97
    - **Public Methods**:
      - `initialize(id = "download")` - Constructor
      - `server(inputs_r, perf_r)` - Sets up download handler
    - **Private Fields**: `id`, `ns`
    - **Key Features**:
      - HTML/PDF report generation
      - Uses parameterized R Markdown template
      - Isolated temp directory rendering

#### App-Level Functions

4.  **`app_ui.R`** (app_ui)
    - **Lines**: 87
    - **Purpose**: Top-level UI composition
    - **Pattern**: Instantiates all R6 modules and composes their UIs
    - **Features**: bslib::page_sidebar layout, custom theme, delegated
      event handlers for shinyalert/shinyhelper
5.  **`app_server.R`** (app_server)
    - **Lines**: 54
    - **Purpose**: Top-level server orchestration
    - **Pattern**: Instantiates R6 modules, calls their servers, wires
      reactive dependencies
    - **Features**: Logging setup, shinyhelper initialization, session
      lifecycle management
6.  **`launch.R`** (launch)
    - **Lines**: 28
    - **Purpose**: Convenience wrapper for launching the Shiny app
    - **Features**: Supports passing custom options to
      [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html)

#### Helper/Utility Functions

7.  **`mod_tooltip.R`** (mod_tooltip)
    - **Lines**: 174 (unchanged from tooltipexplorer)
    - **Type**: Pure UI helper function (no paired server)
    - **Purpose**: Unified interface for 5 tooltip backends
    - **Backends Supported**: bslib, shinyhelper, prompter, shinyalert
8.  **`mod_hoverinfo.R`** (mod_hoverinfo)
    - **Lines**: 80 (unchanged)
    - **Type**: Server-side helper for reactable cells
    - **Purpose**: Wraps content with `title` attribute for native
      tooltips
9.  **`utils_logging.R`**
    - **Lines**: 71
    - **Functions**:
      - `with_logging(expr, context, ns)` - Wraps expressions with
        structured error/warning logging
      - `app_set_log_threshold(level)` - Sets logging threshold across
        all rsixer namespaces
    - **Purpose**: Structured logging with namespace-based filtering
10. **`utils_operators.R`**
    - **Lines**: 14
    - **Operators**: `%||%` (null-coalescing operator)
    - **Purpose**: Lightweight alternative to rlang’s `%||%`
11. **`utils_data.R`**
    - **Lines**: 115
    - **Functions**:
      - `default_tickers` - Character vector of stock ticker symbols
      - `get_stock_prices(tickers, from, to)` - Downloads adjusted
        prices via tidyquant
      - `get_stock_returns(prices)` - Computes daily log returns
      - `summarise_performance(returns)` - Calculates annualised metrics
        (return, volatility, Sharpe)
      - `compute_rolling_vol(returns, window)` - Rolling window
        volatility calculation
    - **Purpose**: Reusable data utilities for financial analysis

### `tests/testthat/` Directory (Test Suite)

Comprehensive test coverage across 7 test files:

1.  **`test_mod_inputs.R`** - 7 test cases
    - R6 instantiation, UI structure, namespace IDs, server reactives,
      isolation
2.  **`test_mod_outputs.R`** - 6 test cases
    - R6 instantiation, UI structure with 5 tabs, namespace IDs,
      reactive performance tibble
3.  **`test_mod_download.R`** - 4 test cases
    - R6 instantiation, server integration with reactives, namespace
      isolation
4.  **`test_utils_data.R`** - 11 test cases
    - Log return computation, NA handling, performance metrics, rolling
      volatility
5.  **`test_utils_logging.R`** - 7 test cases
    - Expression execution, error re-throwing, warning suppression,
      null-coalescing operator
6.  **`test_mod_tooltip.R`** - 10 test cases
    - Backend dispatching (bslib, shinyhelper, prompter, shinyalert),
      style/size parameters
7.  **`test_mod_hoverinfo.R`** - 11 test cases
    - Span tag generation, title attributes, named vectors, style/size
      handling

**Total Test Cases**: 56

### Supporting Files

- **`DESCRIPTION`** - Package metadata, dependencies, testing
  configuration

- **`LICENSE`** / **`LICENSE.md`** - MIT license

- **`README.md`** - Comprehensive documentation (updated)

- **`inst/report_template.Rmd`** - Parameterized R Markdown template for
  reports

- **`.Rbuildignore`** - Exclusions during package build

- **`.gitignore`** - Git exclusions
