get_crs <- function(raster) {
  # Find CRS for raster
  raster |>
    terra::unwrap() |>
    terra::crs()
}
