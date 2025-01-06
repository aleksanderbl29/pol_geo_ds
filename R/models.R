# Delte funktioner

get_tuning_set <- function(train, windmills) {
  # Read the raster and create grid
  grid <- st_make_grid(train, n = 10)

  # Convert grid to sf object with cell ID
  cells <- st_sf(cell_id = 1:length(grid), geometry = grid)

  # Count points in each grid cell
  intersects <- st_intersects(cells, windmills)
  cells$point_count <- lengths(intersects)

  crop_area <- cells |>
    # Find cellen med højest antal vindmøller
    slice_max(point_count) |>
    slice(1)

  train |>
    st_crop(crop_area)
}

define_recipe <- function(training, type = "single") {

  training <- training |>
    st_drop_geometry()

  if (type == "single") {
    recipe(training) |>
      update_role(everything(), new_role = "support") |>
      # Outcome variabel med enkelt celle
      update_role(vindmll, new_role = "outcome") |>
      update_role(b02, b03, b04, b08, new_role = "predictor") |>
      step_normalize(all_numeric_predictors(), -all_outcomes())
  } else if (type == "buffer") {
    recipe(training) |>
      update_role(everything(), new_role = "support") |>
      # Outcome variabel med buffer
      update_role(vindmll_w_buff, new_role = "outcome") |>
      update_role(b02, b03, b04, b08, new_role = "predictor") |>
      step_normalize(all_numeric_predictors(), -all_outcomes())
  }
}

define_workflow <- function(recipe, model) {
  workflow() |>
    add_recipe(recipe) |>
    add_model(model)
}

hyp_par_tuning <- function(workflow, folds, grid) {
  workflow %>%
    tune_grid(resamples = folds, grid = grid)
}

fit_model <- function(workflow, split, params = NULL) {

  split <- split |>
    st_drop_geometry()

  if (!is.null(params)) {
  workflow |>
    finalize_workflow(
      select_by_pct_loss(params, metrix = "rmse", limit = 5)
    ) |>
    fit(split)
  } else if (is.null(params)) {
    workflow |>
      fit(split)
  }
}

model_pred <- function(model, test) {
  model |>
    predict(test)
}

get_predictions <- function(pred, test, crs) {
  left_join(
    test |> mutate(RowNum = row_number()),
    pred |> mutate(RowNum = row_number()),
    by = join_by(RowNum)
  ) |>
    st_make_valid() |>
    st_set_crs(crs) |>
    st_centroid() |>
    select(.pred_class, geometry)
}

merge_predictions <- function(raster, lr, rf) {
  raster |>
    st_join(
      lr |> rename(logistic = .pred_class)
    ) |>
    st_join(
      rf |> rename(randomforest = .pred_class)
    ) |>
    na.omit() |>
    st_centroid()
}

get_predicted_points <- function(predictions) {
  predictions |>
    filter(logistic == 1 | randomforest == 1) |>
    unique() |>
    st_centroid()
}

get_modelsummary <- function(logistic, rand_forest) {
  modelsummary(
    list(
      "Logistisk regression" = logistic,
      "Random Forest" = rand_forest
    )
  )
}

# Logistisk regression
define_logistic_model <- function() {
  logistic_reg() |>
    set_engine("glm") |>
    set_mode("classification")
}

# Random forest
define_rand_forest_model <- function() {
  rand_forest(trees = tune(), mtry = tune()) |>
    set_engine("randomForest") |>
    # set_engine("ranger") |>
    set_mode("classification")
}

define_rand_forest_grid <- function() {
  expand_grid(trees = seq(100, 1500, length.out = 5), mtry = 1:4)
}

