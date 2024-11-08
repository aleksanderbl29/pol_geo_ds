# Kør kun denne fil ved opsætning på ny maskine

config <- reticulate::py_config()
if (config$pythonhome |> basename() == "r-keras") {
  print("Env setup")
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
