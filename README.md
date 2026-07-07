# Rsixer: R6 Shiny Demo App

A modern Shiny application demonstrating **R6 object-oriented design patterns** for building modular, maintainable applications. Rsixer is an improved version of [tooltipexplorer](https://github.com/mjfrigaard/tooltipexplorer) that showcases:

- **R6 Classes for Shiny Modules** - Replaces traditional function-based modules with R6 objects
- **Namespace Adaptation** - Uses `shiny::NS()` within R6 classes for proper module isolation
- **Reactive State Management** - Demonstrates dependency injection and reactive composition
- **Five Tooltip Backends** - Compares `bslib`, `shinyhelper`, `prompter`, `shinyalert`, and `reactable`
- **Financial Data Integration** - Uses real stock market data from `tidyquant`

## Key Features

### R6-Based Module Architecture

Each Shiny module is now an R6 class with:

- **`$new(id)` Constructor** - Creates module instance with unique namespace
- **`$ui()` Public Method** - Builds and returns the module's UI
- **`$server()` Public Method** - Initializes server logic and returns reactive values
- **Private Fields** - Manages internal state, namespace functions, and private reactives

**Example:**

```r
# In app_ui()
inputs <- ModInputs$new(id = "inputs")
outputs <- ModOutputs$new(id = "outputs")
download <- ModDownload$new(id = "download")

bslib::page_sidebar(
  sidebar = inputs$ui(),
  outputs$ui()
)

# In app_server()
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()

outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r = inputs_r)

download <- ModDownload$new(id = "download")
download$server(inputs_r = inputs_r, perf_r = perf_r)
```

### Module Classes

| Class | Purpose | Namespace ID |
|-------|---------|--------------|
| **ModInputs** | Sidebar controls (ticker, dates, vol window) | `"inputs"` |
| **ModOutputs** | Main content (KPI boxes + 5 demo tabs) | `"outputs"` |
| **ModDownload** | Report generation and download | `"download"` |

### Tooltip/Hover Backends Comparison

Five different approaches demonstrated across tabs:

| Backend | Interaction | Trigger | Component |
|---------|-------------|---------|-----------|
| **bslib** | Click | Popover | `bslib::popover()` |
| **shinyhelper** | Click | Modal | `shinyhelper::helper()` |
| **prompter** | Hover | Tooltip | `prompter::add_prompt()` |
| **shinyalert** | Click | Modal | `shinyalert()` |
| **reactable** | Hover | Native title | `reactable::colDef()` |

## Installation

```r
# Install from GitHub
pak::pak("mjfrigaard/Rsixer")

# Or via devtools
devtools::install_github("mjfrigaard/Rsixer")
```

## Usage

### Launch the App

```r
rsixer::launch()

# With custom options
rsixer::launch(options = list(port = 4242, launch.browser = TRUE))
```

### Use R6 Modules in Your Own Apps

```r
library(rsixer)

# Create module instances
inputs <- ModInputs$new(id = "my_inputs")
outputs <- ModOutputs$new(id = "my_outputs")

# Build UI
ui <- page_sidebar(
  sidebar = inputs$ui(),
  outputs$ui()
)

# Build server
server <- function(input, output, session) {
  inputs_r <- inputs$server()
  perf_r <- outputs$server(inputs_r = inputs_r)
}

shinyApp(ui, server)
```

### Use Data Utilities

```r
library(rsixer)

# Fetch stock prices
prices <- get_stock_prices(
  tickers = c("AAPL", "MSFT"),
  from = "2023-01-01"
)

# Compute returns
returns <- get_stock_returns(prices)

# Performance metrics
perf <- summarise_performance(returns)

# Rolling volatility
vol <- compute_rolling_vol(returns, window = 30)
```

## Project Structure

```
Rsixer/
├── R/
│   ├── mod_inputs.R           # ModInputs R6 class
│   ├── mod_outputs.R          # ModOutputs R6 class
│   ├── mod_download.R         # ModDownload R6 class
│   ├── app_ui.R               # Top-level app_ui() function
│   ├── app_server.R           # Top-level app_server() function
│   ├── launch.R               # launch() convenience wrapper
│   ├── mod_tooltip.R          # mod_tooltip() UI helper
│   ├── mod_hoverinfo.R        # mod_hoverinfo() server helper
│   ├── utils_data.R           # Data utility functions
│   ├── utils_logging.R        # Logging utilities
│   └── utils_operators.R      # %||% operator
├── tests/testthat/
│   ├── test_mod_inputs.R      # Unit tests for ModInputs
│   ├── test_mod_outputs.R     # Unit tests for ModOutputs
│   ├── test_mod_download.R    # Unit tests for ModDownload
│   ├── test_utils_data.R      # Tests for data utilities
│   ├── test_utils_logging.R   # Tests for logging utilities
│   ├── test_mod_tooltip.R     # Tests for tooltip helper
│   └── test_mod_hoverinfo.R   # Tests for hoverinfo helper
├── inst/
│   └── report_template.Rmd    # R Markdown report template
├── man/                       # roxygen2 documentation (auto-generated)
├── DESCRIPTION
├── README.md (this file)
└── LICENSE
```

## R6 Design Patterns

### 1. Namespace Isolation

Each module maintains its own namespace to prevent ID conflicts:

```r
ModInputs <- R6::R6Class("ModInputs",
  public = list(
    initialize = function(id = "inputs") {
      private$id <- id
      private$ns <- shiny::NS(id)  # Create once
    },
    ui = function() {
      # Use private$ns() throughout
      shiny::selectizeInput(
        inputId = private$ns("tickers"),
        ...
      )
    }
  ),
  private = list(
    id = NULL,
    ns = NULL
  )
)
```

### 2. Reactive Dependency Injection

Parent modules pass reactives to child modules via method arguments:

```r
# In app_server
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()

outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r = inputs_r)  # Pass dependency
```

### 3. Encapsulation of Reactive Logic

Private methods encapsulate reactive creation and transformation:

```r
ModOutputs <- R6::R6Class("ModOutputs",
  public = list(
    server = function(inputs_r) {
      shiny::moduleServer(private$id, function(input, output, session) {
        # Private reactive methods
        private$prices_reactive()
        private$returns_reactive()
        private$performance_reactive()
      })
    }
  ),
  private = list(
    prices_reactive = function() { shiny::eventReactive(...) },
    returns_reactive = function() { shiny::reactive(...) },
    performance_reactive = function() { shiny::reactive(...) }
  )
)
```

## Logging & Debugging

### Set Log Threshold

```r
# Verbose development mode
app_set_log_threshold(logger::DEBUG)

# Quiet production mode
app_set_log_threshold(logger::WARN)
```

### Logging Namespaces

- `"rsixer/app"` - App-level events
- `"rsixer/inputs"` - Input module events
- `"rsixer/outputs"` - Output module events
- `"rsixer/download"` - Download module events
- `"rsixer/tooltip"` - Tooltip dispatch
- `"rsixer/hoverinfo"` - Hover-info rendering

## Testing

Run the full test suite:

```r
devtools::test()

# Or with testthat directly
testthat::test_local()
```

### Test Coverage

- **R6 Classes**: Unit tests for instantiation, UI generation, namespace isolation
- **Data Utilities**: Tests for price/return calculations, performance metrics
- **Logging**: Tests for error handling and logging behavior
- **Helpers**: Tests for `mod_tooltip()` and `mod_hoverinfo()`

## Dependencies

**Core:**
- `shiny` ≥ 1.7.0 - Web framework
- `bslib` ≥ 0.5.0 - Bootstrap 5 layouts
- `R6` ≥ 2.5.0 - Object-oriented programming

**UI/Tooltips:**
- `bsicons` - Bootstrap icons
- `shinyhelper` - Help modals
- `prompter` - Hover tooltips
- `shinyalert` - Modal alerts
- `reactable` - Interactive tables

**Data:**
- `dplyr` - Data manipulation
- `tidyquant` - Stock data
- `slider` - Rolling window functions
- `scales` - Number formatting

**Infrastructure:**
- `logger` - Structured logging
- `glue` - String interpolation
- `htmltools` - HTML generation
- `rmarkdown` - Report generation

## Comparison to tooltipexplorer

| Aspect | tooltipexplorer | Rsixer |
|--------|-----------------|--------|
| **Module Pattern** | Traditional functions | R6 classes |
| **Namespace Handling** | `shiny::NS()` + `shiny::moduleServer()` | R6 methods + `private$ns()` |
| **Dependency Passing** | Reactive values as arguments | R6 method arguments |
| **Encapsulation** | Limited | Private methods & fields |
| **State Management** | Flat reactive list | Structured R6 objects |
| **Reusability** | Function-based | Class-based (instantiate multiple times) |

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

Martin Frigaard  
Email: mjfrigaard@pm.me  
GitHub: [@mjfrigaard](https://github.com/mjfrigaard)

## References

- [Shiny Modules](https://shiny.rstudio.com/articles/modules.html)
- [R6: Encapsulated Classes](https://r6.r-lib.org/)
- [bslib Bootstrap Layouts](https://rstudio.github.io/bslib/)
- [tidyquant: Financial Data](https://business-science.github.io/tidyquant/)
