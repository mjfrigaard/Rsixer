# Design

``` r

library(rsixer)
#> 
#> Attaching package: 'rsixer'
#> The following object is masked from 'package:base':
#> 
#>     %||%
```

## Design Patterns

This vignette covers the design patterns used to implement the modules
from the `tooltipexplorer` application.

### 1. R6 Module Pattern

With traditional Shiny modules, we create separate UI and server
functions. This makes reusability and composition a little awkward. In
`R6` class objects, we can encapsulate the module logic with public
`$ui()` and `$server()` methods.

``` r

# tooltipexplorer approach 
inputs <- list(
  ui = mod_inputs_ui("inputs"),
  server = function() { mod_inputs_server("inputs") }
)

# R6 approach 
inputs <- ModInputs$new(id = "inputs")
# Use: inputs$ui() and inputs$server()
```

The R6 class is a single instantiation, which creates both UI and server
capabilities in a clear object model. This makes it easy to extend with
additional methods and provides a natural support for multiple
instances.

### 2. Namespace Isolation via Private Fields

Modules can help avoid namespace collisions, but managing
[`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) across UI and
server functions can still be error-prone. With `R6` class objects, we
just create [`shiny::NS()`](https://rdrr.io/pkg/shiny/man/NS.html) once
in the constructor and store in private field.

``` r
initialize = function(id = "inputs") {
  private$id <- id
  private$ns <- shiny::NS(id)  # create once
},
ui = function() {
  shiny::selectizeInput(
    inputId = private$ns("tickers"),  # resue throughout
    ...
  )
},
server = function() {
  shiny::moduleServer(private$id, function(input, output, session) {
    input$tickers  # automatically namespaced
  })
}
```

This means we have no risk of mismatched IDs between the UI and server
(i.e., a single source of truth for namespace that works seamlessly with
[`shiny::moduleServer()`](https://rdrr.io/pkg/shiny/man/moduleServer.html)
).

### 3. Reactive Dependency Injection

In standard modules, passing dependencies and values is implicit and can
lead to errors. With `R6` objects, we can pass reactives as method
arguments.

``` r

# in app_server
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()

outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r = inputs_r)  # clear dependency

download <- ModDownload$new(id = "download")
download$server(inputs_r = inputs_r, perf_r = perf_r)
```

This makes the declaration of dependencies explicit so we can have a
clear data flow through the application. It’s also easier to test in
isolation by passing mock reactives.

### 4. Encapsulation of Private Reactives

As apps get more complex, the reactive logic inside modules gets hard to
organize (and test). `R6` class objects have private methods for
creating/testing reactives.

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

This separation of concerns makes it easier to read and understand
module logic (and it can be tested independently with mocking).

### 5. Logging with Namespace Isolation

Even with [`browser()`](https://rdrr.io/r/base/browser.html) and
`observe()`, debugging complex reactive applications is difficult.
`logger` allows us to structure the logging behaviors with
module-specific namespaces.

``` r

logger::log_info(
  "Fetch button pressed | tickers: [{paste(input$tickers, collapse = ', ')}]",
  namespace = "rsixer/inputs"
)

# Filter by namespace in development
app_set_log_threshold(logger::DEBUG)  # All namespaces
logger::log_threshold(logger::INFO, namespace = "rsixer/app")  # Specific namespace
```

This simplifies the trace execution flow so we can filter by the module
during debugging (or production vs. development modes).
