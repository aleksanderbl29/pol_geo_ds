reshape <- function(raster) {
  # Normaliser raster værdier
  rast <- raster |> unwrap()
  rast <- rast / max(rast)

  # Konverter til array
  data <- as.array(rast)

  # Reshape så Keras forstår formatet
  data <- array_reshape(data, c(dim(data)[1], dim(data)[2], dim(data)[3], 1))

  return(data)

}
