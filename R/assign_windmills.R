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

  # Giver nyt lag navn
  names(new_layer) <- "Vindmølle"

  # Ændrer NaN (ingen vindmølle) til 0
  new_layer <- subst(new_layer, NaN, 0)

  # Returnerer raster
  terra::wrap(new_layer)

}
