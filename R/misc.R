get_base_map <- function(name = "rutsker") {

  # https://www.thewindpower.net/windfarm_map_en_6876_rutsker.php

  rutsker <- c(lon = 14.729802, lat = 55.208668)

  sat_map <- get_openstreetmap(location = rutsker, zoom = 18, maptype = "satellite")
  return(sat_map)
}

plot_sample_eval_map <- function(sat_map, sf_data) {
  ggmap(sat_map) +
    geom_sf(data = sf_data, inherit.aes = FALSE, fill = "transparent", color = "blue", size = 1) +
    labs(title = "Map with Satellite Background")

}

sim_data <- function(cat_1_m) {
  sim <- tibble::tibble(
    id = seq(1, 400, 1),
    score = rnorm(400, mean = 0, sd = cat_1_m),
    long = rnorm(400, mean = 0, sd = cat_1_m),
    lat = rnorm(400, mean = 0, sd = cat_1_m)
  )
}
