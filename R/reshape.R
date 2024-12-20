reshape <- function(b02, b03, b04, b08, stars) {

  # Importerer rasters
  b2_rast <- rast(b02)
  b3_rast <- rast(b03)
  b4_rast <- rast(b04)
  b8_rast <- rast(b08)

  # Stack rasters
  raster <- c(b2_rast, b3_rast, b4_rast, b8_rast)

  # Crop rasteren så den passer med star
  raster <- crop(raster, st_bbox(stars))

  # Konverter til array
  data <- raster |>
    as.array()

  # Reshape så Keras forstår formatet
  array_reshape(data, c(dim(data)[1], dim(data)[2], dim(data)[3], 1))

}
