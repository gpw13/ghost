.onLoad <- function(lib, pkg) {
  gho_api <<- memoise::memoise(gho_api)
}
