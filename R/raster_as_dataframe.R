raster_as_dataframe <- function(raster) {

  raster <- unwrap(raster)

  truth <- FALSE

  if (names(raster)[1] == "Vindmølle_b02") {
    truth <- TRUE
  }

  if (truth) {
    raster <- raster["Vindmølle_b02"]
  }

  dt <- as.data.table(raster, xy = TRUE)

  if (truth) {
    dt[, c("Vindmølle_b03", "Vindmølle_b04", "Vindmølle_b08") := list(Vindmølle_b02, Vindmølle_b02, Vindmølle_b02)]
  }

  return(dt)

}
