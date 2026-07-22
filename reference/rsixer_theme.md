# Setup Rsixer theme and styling

Creates a custom bslib theme with a dark terminal aesthetic inspired by
financial trading platforms. Called internally by
[`app_ui()`](https://mjfrigaard.github.io/Rsixer/reference/app_ui.md) to
apply global theming.

## Usage

``` r
rsixer_theme()
```

## Value

A `bs_theme()` object with custom variables and CSS

## Details

The theme defines a dark, Bloomberg-terminal inspired aesthetic:

- **Palette:** near-black background, teal primary, green/red data
  accents

- **Typography:** IBM Plex Mono for fixed-width terminal feel

- **Surfaces:** flat panels with custom border colors

## Examples

``` r
if (FALSE) { # \dontrun{
theme <- rsixer_theme()
} # }
```
