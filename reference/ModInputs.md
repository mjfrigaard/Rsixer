# ModInputs R6 Class

Encapsulates sidebar controls for ticker selection, date range,
rolling-vol window, and report download. Uses R6 for object-oriented
Shiny module design.

## Methods

### Public methods

- [`ModInputs$new()`](#method-ModInputs-initialize)

- [`ModInputs$ui()`](#method-ModInputs-ui)

- [`ModInputs$server()`](#method-ModInputs-server)

- [`ModInputs$clone()`](#method-ModInputs-clone)

------------------------------------------------------------------------

### `ModInputs$new()`

Initialize a new ModInputs instance

#### Usage

    ModInputs$new(id = "inputs")

#### Arguments

- `id`:

  Character. Module namespace id.

------------------------------------------------------------------------

### `ModInputs$ui()`

Build sidebar UI

#### Usage

    ModInputs$ui()

#### Returns

A
[`bslib::sidebar()`](https://rstudio.github.io/bslib/reference/sidebar.html)
tag object

------------------------------------------------------------------------

### `ModInputs$server()`

Initialize server logic

#### Usage

    ModInputs$server()

#### Returns

Reactive list with elements: tickers, from, to, vol_window, fetch

------------------------------------------------------------------------

### `ModInputs$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ModInputs$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# In app_ui():
inputs <- ModInputs$new(id = "inputs")
inputs$ui()

# In app_server():
inputs <- ModInputs$new(id = "inputs")
inputs_r <- inputs$server()
} # }
```
