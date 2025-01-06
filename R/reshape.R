# reshape <- function(b02, b03, b04, b08, stars, df) {
#
#   # Importerer rasters
#   b2_rast <- rast(b02)
#   b3_rast <- rast(b03)
#   b4_rast <- rast(b04)
#   b8_rast <- rast(b08)
#
#   # Stack rasters
#   raster <- c(b2_rast, b3_rast, b4_rast, b8_rast)
#
#   # Crop rasteren så den passer med star
#   raster <- crop(raster, st_bbox(stars))
#
#   vect_fra_df <- df |>
#     vect()
#
#   points <- vect_fra_df["vindmll_w_buff"] |>
#     rasterize(raster)
#
#   raster <- c(raster, points)
#
#   # Konverter til array
#   data <- raster |>
#     as.array()
#
#   # Reshape så Keras forstår formatet
#   array_reshape(data, c(dim(data)[1], dim(data)[2], dim(data)[3], 1))
#
# }

# reshape <- function(data, type = "x", cropped_raster) {
#
#   pixels <- dim(cropped_raster)[1]
#
#   if (type == "x") {
#     reshaped <- data |>
#       st_drop_geometry() |>
#       select(starts_with("b0")) |>
#       as.matrix() |>
#       array_reshape(c(nrow(data), 4, 1))
#     reshaped |>
#       aperm(c(1, 2, 3)) |>
#       array_reshape(c(nrow(data), prod(dim(reshaped)[2:4])))
#   } else if (type == "y") {
#     data |>
#       st_drop_geometry() |>
#       select(vindmll) |>
#       as.matrix() |>
#       array_reshape(c(nrow(data), 1))
#   }
#
# }
reshape <- function(data, type = "x", expected_features = 4) {
  if (type == "x") {
    # Get the band columns - now more flexible
    raw_data <- data |>
      st_drop_geometry() |>
      select(starts_with("b0")) |>  # More flexible selection
      as.matrix() |>
      apply(2, as.numeric)

    # Get dimensions dynamically
    n_samples <- nrow(raw_data)
    n_features <- ncol(raw_data)

    if (n_features != expected_features) {
      warning(sprintf("Expected %d features but got %d", expected_features, n_features))
    }

    # Create array with shape (n_samples, n_features, 1)
    result <- array(
      raw_data,
      dim = c(n_samples, n_features, 1)
    )

    cat("X data shape:", paste(dim(result), collapse=" x "), "\n")
    return(result)

  } else if (type == "y") {
    # Get target variable - more flexible column selection
    target_col <- if("vindmll" %in% names(data)) "vindmll" else names(data)[1]

    raw_data <- data |>
      st_drop_geometry() |>
      select(all_of(target_col)) |>
      as.matrix() |>
      as.numeric()

    # Create array with shape (n_samples, 1, 1)
    n_samples <- length(raw_data)
    result <- array(
      raw_data,
      dim = c(n_samples, 1, 1)
    )

    cat("Final Y shape:", paste(dim(result), collapse=" x "), "\n")
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
