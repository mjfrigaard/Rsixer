#' Setup Rsixer theme and styling
#'
#' Creates a custom bslib theme with a dark terminal aesthetic inspired by
#' financial trading platforms. Called internally by `app_ui()` to apply
#' global theming.
#'
#' @return A `bs_theme()` object with custom variables and CSS
#'
#' @details
#' The theme defines a dark, Bloomberg-terminal inspired aesthetic:
#' - **Palette:** near-black background, teal primary, green/red data accents
#' - **Typography:** IBM Plex Mono for fixed-width terminal feel
#' - **Surfaces:** flat panels with custom border colors
#'
#' @examples
#' \dontrun{
#' theme <- rsixer_theme()
#' }
#'
#' @export
rsixer_theme <- function() {
  mono <- '"IBM Plex Mono", "JetBrains Mono", "SFMono-Regular", "Courier New", monospace'
  bslib::bs_theme(
    version = 5,
    # Base surfaces
    bg = "#0b0e13",           # Terminal background (near-black)
    fg = "#d5dde5",           # Body text
    # Semantic palette
    primary = "#00d9ff",      # Teal/cyan (financial data accent)
    secondary = "#8b95a1",    # Muted grey
    success = "#2ecc71",      # Up / green
    info = "#4ea1ff",         # Bright cyan
    warning = "#ff9e1b",      # Bloomberg amber
    danger = "#ff4d4f",       # Down / red
    # Typography (mono everywhere)
    font_family_base = mono,
    font_family_monospace = mono,
    heading_font_family = mono,
    font_size_base = "0.9rem",
    line_height_base = 1.55,
    # Surfaces and borders
    body_bg = "#0b0e13",
    body_color = "#d5dde5",
    border_color = "#2a313b",
    "card-bg" = "#12161d",
    "card-cap-bg" = "#1a1f28",
    "card-border-color" = "#2a313b",
    # Links
    link_color = "#00d9ff",
    link_hover_color = "#00f0ff"
  )
}
