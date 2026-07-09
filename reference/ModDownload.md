# ModDownload R6 Class

Handles report generation and download with format selection (HTML/PDF).
Uses R6 for object-oriented Shiny module design.

## Methods

### Public methods

- [`ModDownload$new()`](#method-ModDownload-initialize)

- [`ModDownload$server()`](#method-ModDownload-server)

- [`ModDownload$clone()`](#method-ModDownload-clone)

------------------------------------------------------------------------

### `ModDownload$new()`

Initialize a new ModDownload instance

#### Usage

    ModDownload$new(id = "download")

#### Arguments

- `id`:

  Character. Module namespace id.

------------------------------------------------------------------------

### `ModDownload$server()`

Initialize server logic

#### Usage

    ModDownload$server(inputs_r, perf_r)

#### Arguments

- `inputs_r`:

  Reactive list returned by ModInputs\$server()

- `perf_r`:

  Reactive tibble returned by ModOutputs\$server()

#### Returns

Called for side-effects; returns NULL invisibly

------------------------------------------------------------------------

### `ModDownload$clone()`

The objects of this class are cloneable with this method.

#### Usage

    ModDownload$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
if (FALSE) { # \dontrun{
# In app_server():
download <- ModDownload$new(id = "download")
download$server(inputs_r, perf_r)
} # }
```
