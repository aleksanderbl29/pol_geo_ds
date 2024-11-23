{
  source("_targets_packages.R")
  targets::tar_load_everything()
  targets::tar_source()
}

raster <- t_rast_import |> unwrap()

# Transformerer til givet CRS
# Laver sf vector til terra vector
points <- windmills |>
  st_transform(crs) |>
  select(d_wind, geometry) |>
  vect()

# Laver outputobjekt for ikke at overskrive input-rasteren
output_raster <- raster

# Rasterizer punkterne. Giver værdier fra "d_wind" i windmill. Giver kun
# værdien fra det første punkt der er i en given raster
new_layer <- rasterize(points,
                       output_raster,
                       field = "d_wind",
                       fun = "first")

names(new_layer) <- "Vindmølle"

add(output_raster) <- new_layer

output_raster <- output_raster |>
  mutate(Vindmølle = if_else(Vindmølle == 1, 1, 0))

values(output_raster, dataframe = TRUE) |> pull(Vindmølle) |> unique()

terra::plot(output_raster)
# Returnerer raster
terra::wrap(output_raster)
