get_crs <- function(raster) {
  raster |>
    terra::unwrap() |>
    terra::crs()
}
