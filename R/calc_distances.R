calc_distances <- function(import_raster, pred_points) {
  raster <- import_raster |>
    filter(vindmll == 1) |>
    st_centroid()

  log_points <- pred_points |>
    filter(logistic == 1) |>
    select(logistic)

  rf_points <- pred_points |>
    filter(randomforest == 1) |>
    select(randomforest)

  cnn_points <- pred_points |>
    filter(cnn == 1) |>
    select(cnn)

  log_distances <- st_distance(log_points, raster) |>
    apply(1, min)

  rf_distances <- st_distance(rf_points, raster) |>
    apply(1, min)

  cnn_distances <- st_distance(cnn_points, raster) |>
    apply(1, min)

  tibble(
    model = c(
      rep("Logistisk regression", length(log_distances)),
      rep("Random forest", length(rf_distances)),
      rep("Convolutional neural network", length(cnn_distances))
    ),
    distance = c(
      log_distances,
      rf_distances,
      cnn_distances
    )
  ) |>
    mutate(
      model = factor(model, levels = c("Convolutional neural network",
                                       "Random forest", "Logistisk regression"))
    )

}

plot_predictions <- function(import_raster, pred_points, voting, test, type) {
  raster <- test |>
    select(geometry) |>
    st_join(import_raster |> st_centroid()) |>
    filter(vindmll == 1) |>
    st_centroid()

  if (type == "lr") {
    points <- pred_points |>
      filter(logistic == 1) |>
      select(logistic)
    color <-  viridis(3)[3]
    size <- 2
  } else if (type == "rf") {
    points <- pred_points |>
      filter(randomforest == 1) |>
      select(randomforest)
    color <-  viridis(3)[2]
    size <- 1
  } else if (type == "cnn") {
    points <- pred_points |>
      filter(cnn == 1) |>
      select(cnn)
    color <-  viridis(3)[1]
    size <- 1
  }

  ggplot() +
    geom_sf(data = points, color = color, size = size, shape = 20) +
    geom_sf(data = raster["vindmll" == 1], shape = 21, size = 2) +
    geom_sf(data = voting, color = "black", aes(fill = kommunenavn),
            alpha = 0.05, show.legend = FALSE) +
    theme_map()
}



