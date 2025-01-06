get_input_shape <- function(data) {
  # c(dim(data)[2], dim(data)[3] - 1, 1)
  c(round_down_to_nearest_four(dim(data)[1]), dim(data)[2], 1)
}

round_down_to_nearest_four <- function(x) {
  # Ensure x is a numeric value
  if (!is.numeric(x)) {
    stop("Input must be a numeric value")
  }

  # Subtract the remainder of x divided by 4
  result <- x - (x %% 4)

  return(result)
}
