fit_cnn <- function(cnn_path, t_data, t_data_truth,
                      epochs, batch_size,
                      validation_data = list(v_data, v_data_truth)) {
  load_model(cnn_path) |>
    fit(
      x = t_data,
      y = t_data_truth,
      epochs = epochs,
      batch_size = batch_size,
      validation_data = validation_data
    )
}
