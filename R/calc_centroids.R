calc_centroids <- function(raster) {
  raster |>
    sf::st_sf() |>
    sf::st_centroid(raster)

  # inside = true garanterer at punktet er inde i polygonet, men hvis rasteren
  # ikke er pænt kvadratisk vil punktet ikke være polygonets "sande" centroide.
  raster |>
    terra::centroids(inside = TRUE)
}
