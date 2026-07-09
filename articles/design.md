# Design

``` r

library(rsixer)
#> 
#> Attaching package: 'rsixer'
#> The following object is masked from 'package:base':
#> 
#>     %||%
```

## Design Patterns Implemented

### 1. R6 Module Pattern

**Problem**: Traditional Shiny modules use separate UI and server
functions, making reusability and composition awkward.

**Solution**: Encapsulate module logic in an R6 class with public
`$ui()` and `$server()` methods.

``` r

# Traditional approach (old)
inputs <- list(
  ui = mod_inputs_ui("inputs"),
  server = function() { mod_inputs_server("inputs") }
)

# R6 approach (new)
inputs <- ModInputs$new(id = "inputs")
# Use: inputs$ui() and inputs$server()
```

**Benefits**: - Single instantiation creates both UI and server
capabilities - Clear object model - Easy to extend with additional
methods - Natural support for multiple instances

### 2. Namespace Isolation via Private Fields

**Problem**: Managing
[`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) across UI and
server functions is error-prone.

**Solution**: Create
[`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) once in the
constructor and store in private field.

``` r
initialize = function(id = "inputs") {
  private$id <- id
  private$ns <- shiny::NS(id)  # Create once
},
ui = function() {
  shiny::selectizeInput(
    inputId = private$ns("tickers"),  # Reuse throughout
    ...
  )
},
server = function() {
  shiny::moduleServer(private$id, function(input, output, session) {
    input$tickers  # Automatically namespaced
  })
}
```

**Benefits**: - No risk of mismatched IDs between UI and server - Single
source of truth for namespace - Works seamlessly with
[`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html)

### 3. Reactive Dependency Injection

**Problem**: Passing dependencies between modules is implicit and
error-prone.

**Solution**: Pass reactives as method arguments.

``` r

# In app_server
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()

outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r = inputs_r)  # Clear dependency

download <- ModDownload$new(id = "download")
download$server(inputs_r = inputs_r, perf_r = perf_r)
```

**Benefits**: - Explicit declaration of dependencies - Easy to test in
isolation by passing mock reactives - Clear data flow through the
application

### 4. Encapsulation of Private Reactives

**Problem**: Complex reactive logic inside modules is hard to organize
and test.

**Solution**: Use private methods for reactive creation.

``` r

private = list(
  prices_reactive = function() {
    shiny::eventReactive(inputs_r()$fetch, {
      # Fetch prices
    })
  },
  returns_reactive = function() {
    shiny::reactive({
      # Compute returns
    })
  }
)
```

**Benefits**: - Separation of concerns - Easier to read and understand
module logic - Can be tested independently (with mocking)

### 5. Logging with Namespace Isolation

**Problem**: Debugging complex reactive applications is difficult.

**Solution**: Use structured logging with module-specific namespaces.

``` r

logger::log_info(
  "Fetch button pressed | tickers: [{paste(input$tickers, collapse = ', ')}]",
  namespace = "rsixer/inputs"
)

# Filter by namespace in development
app_set_log_threshold(logger::DEBUG)  # All namespaces
logger::log_threshold(logger::INFO, namespace = "rsixer/app")  # Specific namespace
```

**Benefits**: - Easy to trace execution flow - Can filter by module
during debugging - Production vs. development modes
