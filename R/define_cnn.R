# define_cnn <- function(input_shape, train_y) {
#   input_layer <- layer_input(shape = input_shape)
#
#   output_layer <- input_layer |>
#     # Feature extraction with more filters
#     layer_conv_1d(filters = 64, kernel_size = 3, padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_max_pooling_1d(pool_size = 2) |>
#     layer_dropout(0.2) |>
#
#     layer_conv_1d(filters = 128, kernel_size = 3, padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_max_pooling_1d(pool_size = 2) |>
#     layer_dropout(0.2) |>
#
#     # Classification head with more capacity
#     layer_flatten() |>
#     layer_dense(units = 64, activation = 'relu') |>
#     layer_dropout(0.3) |>
#     layer_dense(units = 32, activation = 'relu') |>
#     # Final binary classification layer
#     layer_dense(units = 1, activation = 'sigmoid')
#
#   model <- keras_model(inputs = input_layer, outputs = output_layer)
#
#   # Calculate class weights
#   n_positive <- sum(train_y == 1)
#   n_negative <- sum(train_y == 0)
#   total <- n_positive + n_negative
#
#   class_weight <- list(
#     "0" = 1,
#     "1" = (total / (2 * n_positive))  # Give more weight to minority class
#   )
#
#   model |>
#     compile(
#       optimizer = optimizer_adam(learning_rate = 0.001),
#       loss = 'binary_crossentropy',
#       metrics = c('accuracy', 'AUC')
#     ) |>
#     save_model("data/model.keras", overwrite = TRUE)
#
#   return(list(model = model, class_weight = class_weight))
# }

define_cnn <- function(input_shape, train_y) {
  # Input layer
  input_layer <- layer_input(shape = input_shape)

  # Feature extraction layers with residual connections
  conv1 <- input_layer |>
    layer_conv_1d(filters = 32, kernel_size = 3, padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation_leaky_relu(alpha = 0.1) |>
    layer_spatial_dropout_1d(0.1)  # Use spatial dropout for CNN

  conv2 <- conv1 |>
    layer_conv_1d(filters = 64, kernel_size = 3, padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation_leaky_relu(alpha = 0.1) |>
    layer_spatial_dropout_1d(0.1)

  # Add residual connection
  res1 <- layer_add(list(
    conv2,
    layer_conv_1d(filters = 64, kernel_size = 1, padding = 'same')(conv1)
  ))

  pool1 <- res1 |> layer_max_pooling_1d(pool_size = 2)

  conv3 <- pool1 |>
    layer_conv_1d(filters = 128, kernel_size = 3, padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation_leaky_relu(alpha = 0.1) |>
    layer_spatial_dropout_1d(0.15)

  # Global pooling instead of flatten for better generalization
  pooled <- conv3 |>
    layer_global_average_pooling_1d()

  # Dense layers with stronger regularization
  dense1 <- pooled |>
    layer_dense(units = 64) |>
    layer_batch_normalization() |>
    layer_activation_leaky_relu(alpha = 0.1) |>
    layer_dropout(0.3)

  dense2 <- dense1 |>
    layer_dense(units = 32) |>
    layer_batch_normalization() |>
    layer_activation_leaky_relu(alpha = 0.1) |>
    layer_dropout(0.2)

  # Output layer
  output_layer <- dense2 |>
    layer_dense(units = 1, activation = 'sigmoid')

  model <- keras_model(inputs = input_layer, outputs = output_layer)

  # Enhanced class weights calculation
  n_positive <- sum(train_y == 1)
  n_negative <- sum(train_y == 0)
  total <- n_positive + n_negative

  # Adjusted class weights using balanced heuristic
  class_weight <- list(
    "0" = 1,
    "1" = min(total / (2 * n_positive), 10)  # Cap weight at 10 to prevent instability
  )

  # Compile model with additional metrics
  model |>
    compile(
      optimizer = optimizer_adam(
        learning_rate = 0.001,
        beta_1 = 0.9,
        beta_2 = 0.999,
        epsilon = 1e-07,
        decay = 1e-6
      ),
      loss = 'binary_crossentropy',
      metrics = c(
        'accuracy',
        'AUC',
        metric_precision(),
        metric_recall(),
        metric_false_negatives(),
        metric_false_positives()
      )
    )

  # Save model
  save_model_weights_only <- FALSE
  save_model(model, "data/model.keras", overwrite = TRUE,
             include_optimizer = TRUE, save_format = "tf")

  return(list(model = model, class_weight = class_weight))
}

get_cnn_path <- function(path, definition) {
  return(path)
}
