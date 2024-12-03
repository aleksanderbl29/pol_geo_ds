library(keras3)
library(terra)
library(reticulate)
library(ggplot2)

# Step 1: Load and Prepare Data ----------------------------------------

ground_truth_mask <- tar_read(t_rast_truth) |> unwrap()
raster_image <- tar_read(t_rast) |> unwrap()

# Normalize raster data to [0, 1]
raster_image <- raster_image / max(values(raster_image), na.rm = TRUE)

# Convert rasters to arrays
X_data <- as.array(raster_image)
y_data <- as.array(ground_truth_mask)

# Add channel dimension to arrays (required by Keras)
X_data <- array_reshape(X_data, c(dim(X_data)[1], dim(X_data)[2], dim(X_data)[3], 1))
y_data <- array_reshape(y_data, c(dim(y_data)[1], dim(y_data)[2], dim(y_data)[3], 1))

# Step 2: Split Data into Training and Validation --------------------

# Split into training and validation sets (80% train, 20% validation)
set.seed(42)
train_indices <- sample(1:dim(X_data)[1], size = 0.8 * dim(X_data)[1])
X_train <- X_data[train_indices,,,]
y_train <- y_data[train_indices,,,]
X_val <- X_data[-train_indices,,,]
y_val <- y_data[-train_indices,,,]

# Step 3: Define the Model -------------------------------------------

# U-Net-inspired architecture for semantic segmentation
input_shape <- c(dim(X_train)[2], dim(X_train)[3], 1)
input_layer <- layer_input(shape = input_shape)

output_layer <- input_layer %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu', padding = 'same') %>%
  layer_batch_normalization() %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = 'relu', padding = 'same') %>%
  layer_batch_normalization() %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3), strides = c(2, 2), activation = 'relu', padding = 'same') %>%
  layer_batch_normalization() %>%
  layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3), strides = c(2, 2), activation = 'relu', padding = 'same') %>%
  layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid')

model <- keras_model(inputs = input_layer, outputs = output_layer)

# Compile the model
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = 'binary_crossentropy',
  metrics = c('accuracy')
)

summary(model)

# Step 4: Train the Model --------------------------------------------
y_train <- array_reshape(y_train, c(dim(y_train)[1], dim(y_train)[2], 1))
y_val <- array_reshape(y_val, c(dim(y_val)[1], dim(y_val)[2], 1))

# Train the model
history <- model |> fit(
  X_train, y_train,
  epochs = 50,
  batch_size = 32,
  validation_data = list(X_val, y_val)
)


# Train the model
history <- model |> fit(
  X_train, y_train,
  epochs = 50,
  batch_size = 32,
  validation_data = list(X_val, y_val)
)

# Step 5: Predict and Visualize --------------------------------------

# Make predictions on validation data
predictions <- model |> predict(X_val)

# Convert predictions to raster for visualization
pred_raster <- rast(predictions[1,,,])
pred_raster <- clamp(pred_raster, lower = 0, upper = 1)  # Ensure valid range

# Visualize predictions using ggplot2
pred_df <- as.data.frame(values(pred_raster), xy = TRUE)
ggplot(pred_df, aes(x = x, y = y, fill = layer)) +
  geom_raster() +
  scale_fill_viridis_c() +
  coord_equal() +
  labs(title = "Predicted Segmentation", fill = "Probability")
