# fit_cnn <- function(cnn_path, train_x, train_y, epochs, batch_size, validation_split = 0.2, cnn_definition) {
#   model <- load_model(cnn_path)
#
#   # Define callbacks
#   callbacks <- list(
#     callback_reduce_lr_on_plateau(
#       monitor = "val_loss",
#       factor = 0.5,
#       patience = 3,
#       min_lr = 1e-6
#     ),
#     callback_early_stopping(
#       monitor = "val_loss",
#       patience = 10,
#       restore_best_weights = TRUE
#     )
#   )
#
#   # Fit with callbacks
#   model |> fit(
#     x = train_x,
#     y = train_y,
#     epochs = epochs,
#     batch_size = batch_size,
#     validation_split = validation_split,
#     callbacks = callbacks#,
#     # verbose = 0
#   )
#
#   new_path <- "data/model_fitted.keras"
#
#   model |> save_model(new_path, overwrite = TRUE)
#
#   return(new_path)
# }

# fit_cnn <- function(cnn_path, train_x, train_y, epochs, batch_size, cnn_definition) {
#   # Load model
#   model <- load_model(cnn_path)
#
#   # Define callbacks
#   callbacks <- list(
#     callback_reduce_lr_on_plateau(
#       monitor = "loss",  # Changed from val_loss since we're not using validation
#       factor = 0.5,
#       patience = 3,
#       min_lr = 1e-6
#     ),
#     callback_early_stopping(
#       monitor = "loss",  # Changed from val_loss
#       patience = 10,
#       restore_best_weights = TRUE
#     )
#   )
#
#   # Fit without validation split
#   model |> fit(
#     x = train_x,
#     y = train_y,
#     epochs = epochs,
#     batch_size = batch_size,
#     callbacks = callbacks
#   )
#
#   new_path <- "data/model_fitted.keras"
#   model |> save_model(new_path, overwrite = TRUE)
#
#   return(new_path)
# }

fit_cnn <- function(cnn_path, train_x, train_y, epochs, batch_size, cnn_definition) {
  # Print shapes for debugging
  cat("train_x shape:", paste(dim(train_x), collapse = " x "), "\n")
  cat("train_y shape:", paste(dim(train_y), collapse = " x "), "\n")

  # Load model
  model <- load_model(cnn_path)

  # Define callbacks - removed validation monitoring
  callbacks <- list(
    callback_reduce_lr_on_plateau(
      monitor = "loss",  # Changed from val_loss
      factor = 0.5,
      patience = 3,
      min_lr = 1e-6
    ),
    callback_early_stopping(
      monitor = "loss",  # Changed from val_loss
      patience = 10,
      restore_best_weights = TRUE
    )
  )

  # Fit without validation split
  history <- model |> fit(
    x = train_x,
    y = train_y,
    epochs = epochs,
    batch_size = batch_size,
    callbacks = callbacks
  )

  new_path <- "data/model_fitted.keras"
  model |> save_model(new_path, overwrite = TRUE)

  return(list(
    path = new_path,
    history = history
  ))
}

# Helper function to check input shape compatibility
check_model_compatibility <- function(model_path, train_x, train_y) {
  model <- load_model(model_path)
  expected_shape <- model$input_shape
  actual_shape <- dim(train_x)

  cat("Expected shape:", paste(expected_shape, collapse = " x "), "\n")
  cat("Actual shape:", paste(actual_shape, collapse = " x "), "\n")

  return(all(expected_shape[-1] == actual_shape[-1]))
}

# Helper function to check and fix dimensions
check_dimensions <- function(x, y) {
  cat("Input shapes:\n")
  cat("train_x:", paste(dim(x), collapse = " x "), "\n")
  cat("train_y:", paste(dim(y), collapse = " x "), "\n")

  # Return TRUE if dimensions are correct, FALSE otherwise
  return(length(dim(x)) == 4 && length(dim(y)) == 4)
}

get_cnn_split <- function(data) {
  split <- split_cells(data)
  target_dim <- 2196

  # Prepare input (4 channels)
  train <- split$train[1:target_dim, 1:target_dim, 1:4, , drop = FALSE]
  test <- split$test[1:target_dim, 1:target_dim, 1:4, , drop = FALSE]

  # Prepare truth data (4 channels)
  train_truth <- split$train[1:target_dim, 1:target_dim, 1:4, , drop = FALSE]
  test_truth <- split$test[1:target_dim, 1:target_dim, 1:4, , drop = FALSE]

  # Ensure 4D tensors (height, width, channels, samples)
  if (length(dim(train)) == 3) {
    dim(train) <- c(dim(train), 1)
  }
  if (length(dim(test)) == 3) {
    dim(test) <- c(dim(test), 1)
  }
  if (length(dim(train_truth)) == 3) {
    dim(train_truth) <- c(dim(train_truth), 1)
  }
  if (length(dim(test_truth)) == 3) {
    dim(test_truth) <- c(dim(test_truth), 1)
  }

  list(
    train = list(
      x = train,      # Should be (2196, 2196, 4, 1)
      y = train_truth # Should be (2196, 2196, 4, 1)
    ),
    test = list(
      x = test,       # Should be (2196, 2196, 4, 1)
      y = test_truth  # Should be (2196, 2196, 4, 1)
    )
  )
}

predict_cnn <- function(cnn_path, test_x, test_y, threshold = 0.5, max_lag = 10, chunk_size = 10000) {

  cat("Loading CNN model...\n")
  # Load the CNN model from the provided path
  cnn_model <- load_model(cnn_path$path)

  cat("Predicting on test data...\n")
  # Predict probabilities on the test data
  probabilities <- cnn_model %>% predict(test_x, verbose = 0)

  # Remove batch dimension if present and flatten the prediction
  if (length(dim(probabilities)) == 4) {
    probabilities <- probabilities[,,1,]  # Removing the batch dimension if present
  }

  # Apply the threshold to convert probabilities to binary outcomes (0 or 1)
  binary_predictions <- ifelse(probabilities > threshold, 1, 0)

  # Collapse the 4 channels into one column (e.g., using the sum or max)
  collapsed_predictions <- apply(binary_predictions, c(1, 2), max)  # You can also use `sum()` instead of `max()`

  # Flatten predictions to 1D
  flattened_predictions <- as.vector(collapsed_predictions)

  # Convert actual labels (test_y) to binary as well and collapse the 4 channels
  binary_actual <- ifelse(test_y > threshold, 1, 0)
  collapsed_actual <- apply(binary_actual, c(1, 2), max)  # You can also use `sum()` instead of `max()`

  # Flatten the actual labels to 1D
  flattened_true_labels <- as.vector(collapsed_actual)

  # Create a dataframe with two columns: 'prediction' and 'actual'
  result_df <- data.frame(
    prediction = flattened_predictions,
    actual = flattened_true_labels
  )

  # Get indices of actual '1' values
  actual_indices <- which(flattened_true_labels == 1)

  # Get indices of predicted '1' values
  predicted_indices <- which(flattened_predictions == 1)

  # If there are no actual '1' values, return an empty dataframe (or handle as needed)
  if (length(actual_indices) == 0) {
    result_df$distance_rows <- NA
    cat("No actual '1' values found in test data.\n")
    return(result_df)
  }

  # Preallocate the distance column
  result_df$distance_rows <- NA

  # Print how many indices will need to be calculated
  total_indices_to_calculate <- length(predicted_indices) * length(actual_indices)
  cat("Total indices to calculate (predicted '1' vs actual '1'): ", total_indices_to_calculate, "\n")

  # Process the data in chunks
  cat("Processing in chunks...\n")
  total_length <- length(flattened_predictions)
  for (start_idx in seq(1, total_length, by = chunk_size)) {
    cat("Processing chunk starting at index ", start_idx, "...\n")

    # Get the end index for the chunk
    end_idx <- min(start_idx + chunk_size - 1, total_length)

    # Get the current chunk of predicted and actual indices
    chunk_predicted_indices <- predicted_indices[predicted_indices >= start_idx & predicted_indices <= end_idx]
    chunk_actual_indices <- actual_indices[actual_indices >= start_idx & actual_indices <= end_idx]

    # For each predicted '1' value in the chunk, check within a window of size `max_lag` for the nearest actual '1'
    for (pred_idx in chunk_predicted_indices) {
      if (pred_idx %% 100 == 0) {
        cat("Processing prediction at index ", pred_idx, "\n")
      }

      # Define the range of indices to check (lag from 1 to max_lag)
      possible_lags <- pred_idx + seq(-max_lag, max_lag)

      # Remove out-of-bounds indices
      possible_lags <- possible_lags[possible_lags > 0 & possible_lags <= length(flattened_true_labels)]

      # Check if any of the lagged positions contain an actual '1'
      nearby_actuals <- which(flattened_true_labels[possible_lags] == 1)

      # If there are any nearby actuals, calculate the minimum distance
      if (length(nearby_actuals) > 0) {
        # Find the closest actual index
        closest_actual <- possible_lags[nearby_actuals[which.min(abs(pred_idx - possible_lags[nearby_actuals]))]]

        # Compute the distance to the closest actual
        result_df$distance_rows[pred_idx] <- abs(pred_idx - closest_actual)
      }
    }
  }

  cat("Completed distance calculation.\n")
  return(result_df)
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
