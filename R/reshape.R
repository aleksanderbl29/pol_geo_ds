reshape <- function(data, type = "x", expected_features = 4) {
  if (type == "x") {
    # Get the band columns and convert to matrix
    raw_data <- data |>
      st_drop_geometry() |>
      select(starts_with("b0")) |>
      as.matrix() |>
      apply(2, as.numeric)

    # Calculate dimensions for reshaping
    n_rows <- nrow(raw_data)
    n_features <- ncol(raw_data)

    # Reshape to 3D array (samples, features, channels)
    result <- array(
      raw_data,
      dim = c(n_rows, n_features, 1)
    )

    return(result)

  } else if (type == "y") {
    # Get binary outcome (0 or 1)
    result <- data |>
      st_drop_geometry() |>
      select(vindmll) |>
      pull() |>
      as.integer() - 1

    # Verify binary values
    if (!all(result %in% c(0, 1))) {
      stop("Target variable must be binary (0 or 1)")
    }

    return(result)
  }
}

verify_dims <- function(x_data, y_data, expected_features = 4) {
  cat("\nDimension verification:\n")
  cat("X shape:", paste(dim(x_data), collapse=" x "), "\n")
  cat("Y shape:", paste(dim(y_data), collapse=" x "), "\n")

  # Verify X and Y have same number of samples
  if (dim(x_data)[1] != dim(y_data)[1]) {
    warning("X and Y have different numbers of samples")
    return(FALSE)
  }

  # Verify X has correct number of features
  if (dim(x_data)[2] != expected_features) {
    warning(sprintf("X data should have %d features", expected_features))
    return(FALSE)
  }

  # Verify Y has correct shape
  if (!all(dim(y_data)[2:3] == c(1, 1))) {
    warning("Y data should have shape (n_samples, 1, 1)")
    return(FALSE)
  }

  # Verify Y is binary
  if (!all(unique(y_data) %in% c(0, 1))) {
    warning("Y data should be binary (0 or 1)")
    return(FALSE)
  }

  return(TRUE)
}

check_data_shapes <- function(x_data, y_data) {
  cat("\nShape verification:\n")
  cat("Input X shape:", paste(dim(x_data), collapse=" x "), "\n")
  cat("Input Y shape:", paste(dim(y_data), collapse=" x "), "\n")

  if (dim(x_data)[1] != dim(y_data)[1]) {
    stop("X and Y data have different numbers of samples")
  }

  list(
    n_samples = dim(x_data)[1],
    n_features = dim(x_data)[2]
  )
}
