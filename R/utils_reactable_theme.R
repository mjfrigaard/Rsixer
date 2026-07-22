#' Custom reactable theme for Rsixer
#'
#' Creates a dark theme for reactable tables matching the Rsixer terminal aesthetic.
#'
#' @return A `reactable::reactableTheme()` object
#'
#' @export
rsixer_reactable_theme <- function() {
  reactable::reactableTheme(
    # Colors
    backgroundColor = "#0b0e13",
    borderColor = "#2a313b",
    stripedColor = "#12161d",
    highlightColor = "#1a1f28",
    cellPadding = "10px 12px",
    # Header
    headerStyle = list(
      borderColor = "#2a313b",
      backgroundColor = "#1a1f28",
      fontWeight = 600,
      color = "#d5dde5"
    ),
    # Rows
    rowStyle = list(
      color = "#d5dde5",
      ".rt-td" = list(
        borderRightColor = "#2a313b"
      )
    ),
    # Search/pagination
    inputStyle = list(
      backgroundColor = "#12161d",
      borderColor = "#2a313b",
      color = "#d5dde5"
    ),
    selectStyle = list(
      backgroundColor = "#12161d",
      borderColor = "#2a313b",
      color = "#d5dde5"
    )
  )
}
