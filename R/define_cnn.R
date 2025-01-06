define_cnn <- function(input_shape) {
  cat("Creating CNN with input shape:", paste(input_shape, collapse=" x "), "\n")

  input_layer <- layer_input(shape = input_shape)

  output_layer <- input_layer |>
    # Feature extraction
    layer_conv_1d(filters = 32, kernel_size = 3, padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_max_pooling_1d(pool_size = 2) |>
    layer_dropout(0.2) |>

    layer_conv_1d(filters = 64, kernel_size = 3, padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_max_pooling_1d(pool_size = 2) |>
    layer_dropout(0.2) |>

    # Classification head
    layer_flatten() |>
    layer_dense(units = 32, activation = 'relu') |>
    layer_dropout(0.3) |>
    # Final binary classification layer
    layer_dense(units = 1, activation = 'sigmoid')  # Binary classification (0 or 1)

  model <- keras_model(inputs = input_layer, outputs = output_layer)

  model |>
    compile(
      optimizer = optimizer_adam(learning_rate = 0.001),
      loss = 'binary_crossentropy',  # Loss function for binary classification
      metrics = c('accuracy', 'AUC')  # Added AUC metric for binary classification
    ) |>
    save_model("data/model.keras", overwrite = TRUE)

  return(model)
}

get_cnn_path <- function(path, definition) {
  return(path)
}
