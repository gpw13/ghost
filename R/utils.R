#' @noRd
assert_dimension <- function(dim) {
  if (!(dim %in% gho_dimensions()[["Code"]])) {
    stop(sprintf("%s is not a valid dimension in the GHO", dim), call. = FALSE)
  }
}

#' @noRd
assert_indicator <- function(inds) {
  valid_inds <- inds %in% gho_indicators()[["IndicatorCode"]]
  if (!all(valid_inds)) {
    stop(sprintf("%s are not indicator(s) in the GHO", paste(inds[!valid_inds], collapse = ", ")), call. = FALSE)
  }
}

#' @noRd
assert_query <- function(qry) {
  if (!is.null(qry)) {
    if (substr(qry, 0, 8) != "$filter=") {
      stop(sprintf("The query %s needs to start with $filter=", qry, call. = FALSE))
    }
  }
}

#' @noRd
.gho_api <- function(path = NULL, query = NULL) {
  assert_query(query)
  url <- httr::modify_url("https://ghoapi.azureedge.net", path = paste0("api/", path), query = query)

  resp <- httr::GET(url)
  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  if (httr::http_error(resp)) {
    stop(
      sprintf(
        "GitHub API request failed [%s]\n%s\n<%s>",
        httr::status_code(resp),
      ),
      call. = FALSE
    )
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"))

  structure(
    list(
      content = tibble::as_tibble(parsed[[2]]),
      path = path,
      response = resp
    ),
    class = "gho_api"
  )
}

#' @noRd
gho_api <- memoise::memoise(.gho_api)

#' @export
print.gho_api <- function(x, ...) {
  cat("<GHO ", x$path, ">\n", sep = "")
  x$content
}
