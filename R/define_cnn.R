define_cnn <- function(input_shape) {
  input_layer <- layer_input(shape = input_shape)

  output_layer <- input_layer |>
    # Convolutional layers
    layer_conv_2d(filters = 64, kernel_size = c(3, 3), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_conv_2d(filters = 64, kernel_size = c(3, 3), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_dropout(0.25) |>

    layer_conv_2d(filters = 128, kernel_size = c(3, 3), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_conv_2d(filters = 128, kernel_size = c(3, 3), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_dropout(0.25) |>

    layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3),
                            strides = c(2, 2), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_dropout(0.25) |>

    layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3),
                            strides = c(2, 2), padding = 'same') |>
    layer_batch_normalization() |>
    layer_activation('relu') |>
    layer_dropout(0.25) |>

    # Final output layer with 1 filter and sigmoid activation for binary classification
    layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid') |>
    layer_reshape(target_shape = c(input_shape[1], 4, 1))

  model <- keras_model(inputs = input_layer, outputs = output_layer)

  # Compile the model for binary classification
  model |>
    compile(
      optimizer = optimizer_adam(learning_rate = 0.001),
      loss = 'binary_crossentropy',  # Loss for binary classification
      metrics = c('accuracy')        # Metric to monitor accuracy
    ) |>
    save_model("data/model.keras", overwrite = TRUE)
}


# define_cnn <- function(input_shape) {
#   # Now input_shape is dynamic, can be anything like (n_samples, n_features, 1)
#   cat("Creating CNN with input shape:", paste(input_shape, collapse=" x "), "\n")
#
#   input_layer <- layer_input(shape = input_shape)
#
#   output_layer <- input_layer |>
#     # Convolutional layers - padding='same' ensures output size matches input
#     layer_conv_2d(filters = 64, kernel_size = c(3, 3), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_conv_2d(filters = 64, kernel_size = c(3, 3), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_max_pooling_2d(pool_size = c(2, 2)) |>
#     layer_dropout(0.25) |>
#
#     layer_conv_2d(filters = 128, kernel_size = c(3, 3), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_conv_2d(filters = 128, kernel_size = c(3, 3), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_max_pooling_2d(pool_size = c(2, 2)) |>
#     layer_dropout(0.25) |>
#
#     layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3),
#                             strides = c(2, 2), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_dropout(0.25) |>
#
#     layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3),
#                             strides = c(2, 2), padding = 'same') |>
#     layer_batch_normalization() |>
#     layer_activation('relu') |>
#     layer_dropout(0.25) |>
#
#     # Final output layer with single channel
#     layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid')
#
#   model <- keras_model(inputs = input_layer, outputs = output_layer)
#
#   # Compile the model
#   model |>
#     compile(
#       optimizer = optimizer_adam(learning_rate = 0.001),
#       loss = 'binary_crossentropy',
#       metrics = c('accuracy')
#     ) |>
#     save_model("data/model.keras", overwrite = TRUE)
#
#   return(model)
# }

get_cnn_path <- function(path, definition) {
  return(path)
}
