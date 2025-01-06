fit_cnn <- function(cnn_path, train_x, train_y, epochs, batch_size, cnn_definition) {
  cat("Training CNN model...\n")

  # Load model
  model <- load_model(cnn_path)

  # Define callbacks
  callbacks <- list(
    callback_reduce_lr_on_plateau(
      monitor = "loss",
      factor = 0.5,
      patience = 3,
      min_lr = 1e-6
    ),
    callback_early_stopping(
      monitor = "loss",
      patience = 10,
      restore_best_weights = TRUE
    )
  )

  # Fit model
  history <- model |> fit(
    x = train_x,
    y = train_y,
    epochs = epochs,
    batch_size = batch_size,
    callbacks = callbacks,
    verbose = 0
  )

  # Save fitted model
  fitted_path <- "data/model_fitted.keras"
  model |> save_model(fitted_path, overwrite = TRUE)

  return(list(
    path = fitted_path,
    history = history
  ))
}

predict_cnn <- function(cnn_path, test_x, test_y, threshold = 0.5) {
  cat("Loading fitted CNN model...\n")
  model <- load_model(cnn_path$path)

  cat("Predicting on test data...\n")
  probabilities <- model |> predict(test_x, verbose = 0)

  # Convert to binary predictions and merge with test data
  ifelse(probabilities > threshold, 1, 0)
}

# Helper function to merge predictions
merge_cnn_predictions <- function(test_data, predictions) {
  # Ensure predictions vector matches test data length
  pred_vec <- as.vector(predictions)[1:nrow(test_data)]

  # Add predictions as new column
  test_data$cnn_pred <- pred_vec

  test_data |>
    st_centroid()
}

flatten_predictions <- function(predictions) {
  dims <- dim(predictions)
  n <- dims[1] * dims[2]

  flattened <- matrix(predictions, nrow = n, ncol = 1)
  return(flattened)
}


get_cnn_pred <- function(cnn_split, cnn_model) {
  # Get the test data (input and true labels)
  test_x <- cnn_split$test$x  # Input data (features)
  test_y <- cnn_split$test$y  # True labels (ground truth)

  # Get predictions from the CNN model
  predictions <- predict_cnn(cnn_model, test_x)  # Assuming predict_cnn gives binary predictions (0 or 1)

  # Flatten predictions and true labels for comparison
  flattened_predictions <- flatten_predictions(predictions)
  flattened_true_labels <- flatten_predictions(test_y)

  # Create a dataframe with two columns: 'prediction' and 'actual'
  result_df <- data.frame(
    prediction = flattened_predictions,
    actual = flattened_true_labels
  )

  return(result_df)
}




get_test_indices <- function(split_result) {
  # Get the test data array (should be 4D: height x width x channels x samples)
  test_data <- split_result$test$x

  # Ensure test data has 4 dimensions (height, width, channels, samples)
  if (length(dim(test_data)) != 4) {
    stop("Test data should have 4 dimensions: (height, width, channels, samples).")
  }

  # Extract the first sample (since we have only one sample in the 4th dimension)
  test_data_sample <- test_data[,,,1]

  # Create a binary mask where non-zero values indicate test points
  test_mask <- ifelse(test_data_sample[,,1] != 0, 1, 0)

  # Get indices where the mask is 1 (i.e., where the test data exists)
  test_indices <- which(as.vector(test_mask) == 1)

  return(test_indices)
}



split_cells <- function(data, train_fraction = 0.6) {
  # Get the spatial dimensions (rows and columns)
  n_rows <- dim(data)[1]
  n_cols <- dim(data)[2]

  # Flatten spatial dimensions to get total number of cells
  total_cells <- n_rows * n_cols
  cell_indices <- seq_len(total_cells)

  # Randomly sample cells for training and testing
  train_size <- floor(total_cells * train_fraction)
  train_indices <- sample(cell_indices, size = train_size)
  test_indices <- setdiff(cell_indices, train_indices)

  # Create masks for training and testing
  train_mask <- array(0, dim = c(n_rows, n_cols))
  train_mask[train_indices] <- 1

  test_mask <- array(0, dim = c(n_rows, n_cols))
  test_mask[test_indices] <- 1

  # Apply the masks to the data
  train_data <- data * array(train_mask, dim = dim(data))
  test_data <- data * array(test_mask, dim = dim(data))

  list(train = train_data, test = test_data)
}

fix_dimensions <- function(obj) {
  # Get the current dimensions of the data
  dims <- dim(obj)

  # Add 1 to the fourth dimension (if it exists, or set it to 1 if it's missing)
  if (length(dims) < 4) {
    # If the 4th dimension doesn't exist, add it as 1
    dims <- c(dims, 1)
  } else {
    # If the 4th dimension exists, just update it
    dims[4] <- 1
  }

  # Return the data with the new dimensions
  return(dims)
}

repeat_outcome_to_predictors <- function(outcome, n_rows, n_cols, n_predictors) {
  target_rows <- n_rows
  target_cols <- n_cols

  # Ensure the outcome has the right number of dimensions
  if (length(dim(outcome)) == 3) {
    dim(outcome) <- c(dim(outcome), 1)
  }

  # Create the resized outcome with 5 channels
  resized_outcome <- array(
    outcome[1:target_rows, 1:target_cols, , , drop = FALSE],
    dim = c(target_rows, target_cols, n_predictors, 1)
  )

  return(resized_outcome)
}
