library(terra)
library(keras3)
library(reticulate)

# Step 1: Prepare your ground truth data
# Create a raster mask where 1 indicates the feature you're looking for, 0 indicates background
# This is crucial for supervised learning

# Method 1: Manual creation of ground truth mask
# You'll need to create a raster with the same extent and resolution as your original raster
# Where your target features are located, set the value to 1, elsewhere 0
ground_truth_mask <- tar_read(t_rast_truth) |> unwrap()

raster_image <- tar_read(t_rast) |> unwrap()

# Step 2: Prepare data for CNN
# Normalize your original raster
normalized_raster <- raster_image / max(raster_image) #4095         #https://sentiwiki.copernicus.eu/web/s2-mission#S2Mission-RadiometricS-2-Mission-Radiometrictrue

# Convert to arrays
X_data <- as.array(normalized_raster)
y_data <- as.array(ground_truth_mask)

# Reshape for Keras (add batch and channel dimensions if needed)
X_data <- array_reshape(X_data, c(dim(X_data)[1], dim(X_data)[2], dim(X_data)[3], 1))
y_data <- array_reshape(y_data, c(dim(y_data)[1], dim(y_data)[2], dim(y_data)[3], 1))

# Step 3: Create a segmentation model (U-Net is often good for this)


# # Explicitly create a Keras model using functional API
# input_layer <- layer_input(shape = input_shape)
#
# output_layer <- input_layer %>%
#   layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu',
#                 padding = 'same') %>%
#   layer_max_pooling_2d(pool_size = c(2, 2)) %>%
#   layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = 'relu',
#                 padding = 'same') %>%
#   layer_max_pooling_2d(pool_size = c(2, 2)) %>%
#   layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3), strides = c(2, 2),
#                           padding = 'same', activation = 'relu') %>%
#   layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3), strides = c(2, 2),
#                           padding = 'same', activation = 'relu') %>%
#   layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid')
#
# model <- keras_model(inputs = input_layer, outputs = output_layer)

# Ensure y_data has the same shape as the model output

# Adjust input_shape to match your data
input_shape <- c(dim(X_data)[2], dim(X_data)[3], 1)

# Recreate the model with explicit input shape
input_layer <- layer_input(shape = input_shape)
output_layer <- input_layer %>%
  layer_conv_2d(filters = 64, kernel_size = c(3, 3), activation = 'relu',
                padding = 'same') %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d(filters = 128, kernel_size = c(3, 3), activation = 'relu',
                padding = 'same') %>%
  layer_max_pooling_2d(pool_size = c(2, 2)) %>%
  layer_conv_2d_transpose(filters = 128, kernel_size = c(3, 3), strides = c(2, 2),
                          padding = 'same', activation = 'relu') %>%
  layer_conv_2d_transpose(filters = 64, kernel_size = c(3, 3), strides = c(2, 2),
                          padding = 'same', activation = 'relu') %>%
  layer_conv_2d(filters = 1, kernel_size = c(1, 1), activation = 'sigmoid')

model <- keras_model(inputs = input_layer, outputs = output_layer)

summary(model)

# Compile the model
model |> compile(
  optimizer = optimizer_adam(learning_rate = 0.001),
  loss = 'binary_crossentropy',
  metrics = c('accuracy')
)

# Step 4: Train the model
# Split into training and validation sets
set.seed(291001)
train_indices <- sample(1:dim(X_data)[1], 0.8 * dim(X_data)[1])
X_train <- X_data[train_indices,,,]
y_train <- y_data[train_indices,,,]
X_val <- X_data[-train_indices,,,]
y_val <- y_data[-train_indices,,,]

print(dim(X_train))
print(dim(y_train))

if (length(dim(X_train)) != length(dim(y_train))) {
  y_train <- array_reshape(y_train, c(dim(y_train)[1], dim(y_train)[2], dim(y_train)[3]))
}

# Fit the model
history <- model |> fit(
  X_train, y_train,
  epochs = 15,
  # epochs = 50,
  # batch_size = 128,
  batch_size = 32,
  validation_data = list(X_val, y_val)
)

# Step 5: Predict and visualize results
predictions <- model |> predict(X_val)

# Visualize predictions
# This is a basic example, you might want more sophisticated visualization
plot(rast(predictions[1,,,]))
