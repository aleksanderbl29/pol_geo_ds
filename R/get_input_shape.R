get_input_shape <- function(data) {
  # Return shape for 1D convolution (features, channels)
  dim(data)[2:3]
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
