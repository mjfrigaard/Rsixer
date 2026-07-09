# Application UI

Top-level UI function that wires together all R6 module UIs inside a
[`bslib::page_sidebar()`](https://rstudio.github.io/bslib/reference/page_sidebar.html)
layout.

## Usage

``` r
app_ui()
```

## Value

A `shiny.tag` UI object suitable for passing to
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).
