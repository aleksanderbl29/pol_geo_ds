reshape <- function(input) {
  # Normaliser raster værdier
  rast <- unwrap(input)
  rast <- rast / max(rast)


  ## TO DO
  # TIlføj nyt lag hvis et lag hedder noget med vindmølle
  # add(new_layer) <- new_layer


  if (names(rast)[1] == "Vindmølle") {
    # Tilføj et lag mere
    add(rast) <- rast
    # Læg de to lag oveni to mere
    add(rast) <- rast
  }

  # Konverter til array
  data <- as.array(rast)

  # Reshape så Keras forstår formatet
  array_reshape(data, c(dim(data)[1], dim(data)[2], dim(data)[3], 1))

}
