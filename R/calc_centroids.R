calc_centroids <- function(raster) {
  # inside = true garanterer at punktet er inde i polygonet, men hvis rasteren
  # ikke er pænt kvadratisk vil punktet ikke være polygonets "sande" centroide.
  raster |>
    terra::centroids(inside = TRUE)
}
