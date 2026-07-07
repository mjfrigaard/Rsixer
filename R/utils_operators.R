#' Null-Coalescing Operator
#'
#' A lightweight null-coalescing operator that avoids a dependency on rlang.
#' Returns the left-hand side if not NULL, otherwise the right-hand side.
#'
#' @param x Left-hand value.
#' @param y Right-hand value (returned if x is NULL).
#'
#' @return `x` if not NULL, otherwise `y`.
#'
#' @examples
#' NULL %||% "default"
#' "value" %||% "default"
#'
#' @export
`%||%` <- function(x, y) if (!is.null(x)) x else y
