# # Function to calculate the input shape based on data dimensions
# get_input_shape <- function(data) {
#   c(dim(data)[2], dim(data)[3] - 1, 1)
# }
#
# # Function to define and compile a CNN model
# define_cnn <- function(input_shape) {
#   library(keras3)
#
#   model <- keras_model_sequential() %>%
#     layer_conv_2d(filters = 32, kernel_size = c(3, 3), activation = 'relu', input_shape = input_shape) %>%
#     layer_max_pooling_2d(pool_size = c(2, 2)) %>%
#     layer_flatten() %>%
#     layer_dense(units = 128, activation = 'relu') %>%
#     layer_dense(units = 1, activation = 'sigmoid')
#
#   model %>% compile(
#     optimizer = 'adam',
#     loss = 'binary_crossentropy',
#     metrics = c('accuracy')
#   )
#
#   return(model)
# }
#
# # Function to fit the CNN model with training data
# fit_cnn <- function(model_path, train_x, train_y, epochs = 15, batch_size = 128, validation_split = 0.2, model_definition) {
#   if (file.exists(model_path)) {
#     model <- load_model_tf(model_path)
#   } else {
#     model <- model_definition
#     history <- model %>% fit(
#       train_x, train_y,
#       epochs = epochs,
#       batch_size = batch_size,
#       validation_split = validation_split
#     )
#     model %>% save_model_tf(model_path)
#   }
#
#   return(model)
# }
#
# # Function to make predictions with the CNN model
# predict_cnn <- function(model, test_x, test_y = NULL) {
#   predictions <- model %>% predict(test_x)
#   if (!is.null(test_y)) {
#     evaluation <- model %>% evaluate(test_x, test_y)
#     return(list(predictions = predictions, evaluation = evaluation))
#   }
#   return(predictions)
# }
