assign_windmills <- function(raster, windmills, crs) {

  # Transformerer til givet CRS
  # Laver sf vector til terra vector
  points <- windmills |>
    st_transform(crs) |>
    select(d_wind, geometry) |>
    vect()

  # Laver outputobjekt for ikke at overskrive input-rasteren
  output_raster <- raster |>
    terra::unwrap()

  # Rasterizer punkterne. Giver værdier fra "d_wind" i windmill. Giver kun
  # værdien fra det første punkt der er i en given raster
  new_layer <- rasterize(
    points,
    output_raster,
    field = "d_wind",
    fun = "first"
  )

  # Ændrer NaN (ingen vindmølle) til 0
  new_layer <- subst(new_layer, NaN, 0)

  # # Duplikerer lag til 2 lag
  # add(new_layer) <- new_layer
  # # Duplikerer de 2 lag til oveni 2 lag = 4 lag
  # add(new_layer) <- new_layer
  #
  # # Giver nye lag navn
  # names(new_layer) <- c(
  #   "Vindmølle_b02", "Vindmølle_b03", "Vindmølle_b04", "Vindmølle_b08"
  # )

  names(new_layer) <- "Vindmølle"

  return_raster <- resample(new_layer, output_raster)

  # Returnerer raster
  terra::wrap(return_raster)

}
