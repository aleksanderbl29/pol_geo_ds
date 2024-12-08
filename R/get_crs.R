get_crs <- function(raster) {
  # Find CRS for raster
  terra::rast(raster) |>
    terra::unwrap() |>
    terra::crs()
}
