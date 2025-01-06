calc_distances <- function(import_raster, pred_points, cnn) {
  raster <- import_raster |>
    filter(vindmll == 1) |>
    st_centroid()

  log_points <- pred_points |>
    filter(logistic == 1) |>
    select(logistic)

  rf_points <- pred_points |>
    filter(randomforest == 1) |>
    select(randomforest)

  log_distances <- st_distance(log_points, raster) |>
    apply(1, min)

  rf_distances <- st_distance(rf_points, raster) |>
    apply(1, min)

  cnn_distances <- cnn |> pull(distance_rows) * 10 # antal rækker fra ganget med pixelstørrelse

  tibble(
    model = c(
      rep("Logistisk Regression", length(log_distances)),
      rep("Random Forest", length(rf_distances)),
      rep("Convolutional Neural Network", length(cnn_distances))
    ),
    distance = c(
      log_distances,
      rf_distances,
      cnn_distances
    )
  )

}

plot_predictions <- function(import_raster, pred_points) {
  raster <- import_raster |>
    filter(vindmll == 1) |>
    st_centroid()

  log_points <- pred_points |>
    filter(!buffer & logistic == 1) |>
    select(logistic)

  rf_points <- pred_points |>
    filter(!buffer & randomforest == 1) |>
    select(randomforest)

  ggplot() +
    geom_sf(data = log_points, color = "red") +
    geom_sf(data = rf_points, color = "green") +
    geom_sf(data = raster["vindmll" == 1], shape = 21) +
    theme_void()
}



