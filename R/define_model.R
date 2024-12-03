define_model <- function(input_shape) {
  input_layer <- layer_input(shape = input_shape)

  output_layer <- input_layer |>
    layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu',
                  padding = 'same') |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = 'relu',
                  padding = 'same') |>
    layer_max_pooling_2d(pool_size = c(2, 2)) |>
    layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3), strides = c(2, 2),
                            padding = 'same', activation = 'relu') |>
    layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3), strides = c(2, 2),
                            padding = 'same', activation = 'relu') |>
    layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid')

  model <- keras_model(inputs = input_layer, outputs = output_layer)

  model |>
    compile(
      optimizer = optimizer_adam(learning_rate = 0.001),
      loss = 'binary_crossentropy',
      metrics = c('accuracy')
    ) |>
    save_model("data/model.keras", overwrite = TRUE)
}
