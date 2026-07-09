# ModOutputs R6 Class

Main content area with KPI value boxes and 5 demo tabs showcasing
different tooltip/hover-info approaches. Uses R6 for object-oriented
Shiny module design.

## Methods

### Public methods

- [`ModOutputs$new()`](#method-ModOutputs-initialize)

- [`ModOutputs$ui()`](#method-ModOutputs-ui)

- [`ModOutputs$server()`](#method-ModOutputs-server)

- [`ModOutputs$clone()`](#method-ModOutputs-clone)

------------------------------------------------------------------------

### `ModOutputs$new()`

Initialize a new ModOutputs instance

#### Usage

    ModOutputs$new(id = "outputs")

#### Arguments

- `id`:

  Character. Module namespace id.

------------------------------------------------------------------------

### `ModOutputs$ui()`

Build main content UI

#### Usage

    ModOutputs$ui()

#### Returns

A
[`shiny::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html)
with KPI boxes and demo tabs

------------------------------------------------------------------------

### `ModOutputs$server()`

Initialize server logic

#### Usage

    ModOutputs$server(inputs_r)

#### Arguments

- `inputs_r`:

  Reactive list returned by ModInputs\$server()

#### Returns

Reactive tibble with performance metrics

------------------------------------------------------------------------

### `ModOutputs$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ModOutputs$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# In app_ui():
outputs <- ModOutputs$new(id = "outputs")
outputs$ui()

# In app_server():
outputs <- ModOutputs$new(id = "outputs")
perf_r <- outputs$server(inputs_r)
} # }
```
