assign_windmills <- function(raster, windmill, crs) {

  # Transformerer til givet CRS
  # Laver sf vector til terra vector
  points <- windmill |>
    st_transform(crs) |>
    vect()

  # Laver outputobjekt for ikke at overskrive input-rasteren
  output_raster <- raster |>
    terra::unwrap()

  # Rasterizer punkterne. Giver værdier fra "d_wind" i windmill. Giver kun
  # værdien fra det første punkt der er i en given raster
  new_layer <- rasterize(points,
                         output_raster,
                         field = "d_wind",
                         fun = "first")  # Takes first value if multiple points in cell

  names(new_layer) <- "Vindmølle"

  add(output_raster) <- new_layer

  # Returnerer raster
  terra::wrap(output_raster)

}
