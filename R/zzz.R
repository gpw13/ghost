.onLoad <- function(pkgname, libname) {
  gho_api <<- memoise::memoise(gho_api)
}
