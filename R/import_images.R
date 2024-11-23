import_images <- function(b02, b03, b04, b08) {
  # Importerer rasters
  b2_rast <- rast(b02)
  b3_rast <- rast(b03)
  b4_rast <- rast(b04)
  b8_rast <- rast(b08)

  # Assigner første raster til objekt
  raster <- b2_rast

  # Lægger rasters oveni
  add(raster) <- b3_rast
  add(raster) <- b4_rast
  add(raster) <- b8_rast

  # Wrap raster til return
  raster |>
    wrap()
}
