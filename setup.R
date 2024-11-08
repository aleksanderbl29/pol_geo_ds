# Kør kun denne fil ved opsætning på ny maskine

config <- reticulate::py_config()
if (config$pythonhome |> basename() == "r-keras") {
  print("Env er setup")
} else {
  keras3::install_keras(
    backend = "tensorflow"
  )
  reticulate::py_install("keras")
  print("TILFØJ TIL RSTUDIO PROJEKT PYTHON PATH")
}

library(keras3)
mnist <- keras3::dataset_mnist()
x_train <- mnist$train$x
y_train <- mnist$train$y
x_test <- mnist$test$x
y_test <- mnist$test$y

# reshape
x_train <- array_reshape(x_train, c(nrow(x_train), 784))
x_test <- array_reshape(x_test, c(nrow(x_test), 784))
# rescale
x_train <- x_train / 255
x_test <- x_test / 255

y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)

model <- keras_model_sequential(input_shape = c(784))

model |>
  layer_dense(units = 256, activation = "relu") |>
  layer_dropout(rate = 0.4) |>
  layer_dense(units = 128, activation = "relu") |>
  layer_dropout(rate = 0.3) |>
  layer_dense(units = 10, activation = "softmax")

summary(model)
plot(model)

model |>
  compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_rmsprop(),
    metrics = c("accuracy")
  )

history <- model |> fit(
  x_train, y_train,
  epochs = 30, batch_size = 128,
  validation_split = 0.2
)

plot(history)

model |>
  evaluate(x_test, y_test)

probs <- model |>
  predict(x_test)
max.col(probs) - 1L




