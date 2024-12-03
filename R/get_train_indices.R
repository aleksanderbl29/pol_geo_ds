get_train_indices <- function(data) {
  sample(1:dim(data)[1], 0.8 * dim(data)[1])
}
