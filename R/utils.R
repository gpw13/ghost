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
  if (!is.null(qry) && !is.na(qry)) {
    if (substr(qry, 0, 8) != "$filter=") {
      stop(sprintf("The query %s needs to start with $filter=", qry, call. = FALSE))
    }
  }
}

#' @noRd
assert_year_range <- function(x) {
  if (length(x) > 1 | !(x %in% c("numeric", "date"))) {
    stop(sprintf("year_range needs to be a single string, either 'numeric' or 'date'."), call. = FALSE)
  }
}

#' @noRd
convert_year_range <- function(df, year_range) {
  assert_year_range(year_range)
  if (year_range == "numeric") {
    fnct <- function(x) as.numeric(substr(x, 1, 4))
  } else {
    fnct <- as.Date
  }
  dplyr::mutate(df, dplyr::across(
    dplyr::any_of(c("TimeDimensionBegin", "TimeDimensionEnd")),
    fnct
  ))
}

#' @noRd
modify_query <- function(qry) {
  if (is.na(qry) || is.null(qry)) {
    NULL
  } else {
    gsub(" ", "%20", qry)
  }
}

#' @noRd
gho_api <- function(path = NULL, query = NULL) {
  assert_query(query)
  query <- modify_query(query)
  url <- httr::modify_url("https://ghoapi.azureedge.net", path = paste0("api/", path), query = query)

  resp <- httr::GET(url, httr::accept_json())


  if (httr::http_error(resp)) {
    stop(
      sprintf(
        strwrap("GHO API request failed with status %s
                and message: '%s'.", prefix = " ", initial = ""),
        httr::status_code(resp),
        httr::content(resp, as = "text")
      ),
      call. = FALSE
    )
  }

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
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
