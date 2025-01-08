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

define_recipe <- function(training) {

  training |>
    st_drop_geometry() |>
    recipe() |>
    update_role(everything(), new_role = "support") |>
    update_role(vindmll, new_role = "outcome") |>
    update_role(b02, b03, b04, b08, new_role = "predictor") |>
    step_normalize(all_numeric_predictors(), -all_outcomes())

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
    best_params <- params |>
      select_best(metric = "roc_auc")

    workflow |>
      finalize_workflow(best_params) |>
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
    select(.pred_class, geometry) |>
    unique()
}

merge_predictions <- function(raster, lr, rf, cnn) {
  raster |>
    st_join(
      lr |>
        rename(logistic = .pred_class) |>
        unique()
    ) |>
    st_join(
      rf |>
        rename(randomforest = .pred_class) |>
        unique()
    ) |>
    st_join(
      cnn |>
        rename(cnn = cnn_pred) |>
        unique()
    ) |>
    unique() |>
    na.omit() |>
    st_centroid()
}

get_predicted_points <- function(predictions) {
  predictions |>
    filter(logistic == 1 | randomforest == 1 | cnn == 1) |>
    unique() |>
    st_centroid()
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
    set_mode("classification")
}

define_rand_forest_grid <- function() {
  expand_grid(trees = seq(100, 1500, length.out = 5), mtry = 1:4)
}

select_params <- function(params) {
  out <- params |> select_best(metric = "roc_auc") |>
    select(-.config) |>
    as.list()

  out$roc_auc <- params |>
    collect_metrics() |>
    filter(.metric == "roc_auc") |>
    slice_max(mean) |>
    pull(mean) |>
    vec_fmt_number(decimals = 2, locale = "da")

  return(out)
}

evaluate_confusion <- function(predictions, model_name) {
  # Convert predictions to factors if they aren't already
  true_values <- as.factor(predictions$vindmll)
  pred_values <- as.factor(predictions[[model_name]])

  # Manually create confusion matrix
  true_neg <- sum(true_values == "0" & pred_values == "0")
  false_pos <- sum(true_values == "0" & pred_values == "1")
  false_neg <- sum(true_values == "1" & pred_values == "0")
  true_pos <- sum(true_values == "1" & pred_values == "1")

  # Create table with gt
  conf_mat_table <- tibble(
    faktisk = c("0", "1"),
    `0` = c(true_neg, false_neg),
    `1` = c(false_pos, true_pos)
  ) %>%
    gt() %>%
    tab_spanner(
      label = "Forudsagt",
      columns = c("0", "1")
    ) %>%
    cols_label(
      faktisk = "Faktisk"
    ) %>%
    fmt_number(
      columns = c("0", "1"),
      decimals = 0,
      dec_mark = ",",
      sep_mark = "."
    )

  return(conf_mat_table)
}

evaluate_metrics <- function(predictions) {
  # Define model name mapping
  model_names <- c(
    "logistic" = "Logistisk regression",
    "randomforest" = "Random forest",
    "cnn" = "Convolutional neural network"
  )

  # Calculate metrics for each model
  models <- c("logistic", "randomforest", "cnn")
  metrics_list <- lapply(models, function(model) {
    true_values <- as.factor(predictions$vindmll)
    pred_values <- as.factor(predictions[[model]])

    # Calculate basic metrics
    acc <- mean(true_values == pred_values)
    tp <- sum(true_values == "1" & pred_values == "1")
    fp <- sum(true_values == "0" & pred_values == "1")
    fn <- sum(true_values == "1" & pred_values == "0")
    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    f1 <- 2 * (precision * recall) / (precision + recall)

    # Calculate AUC
    # Note: roc() expects numeric probabilities for pred, so we need to ensure
    # the predictions are numeric probabilities if they aren't already
    roc_obj <- roc(as.numeric(true_values) - 1,
                   as.numeric(pred_values) - 1)
    auc_value <- auc(roc_obj)

    tibble(
      Model = model_names[model],
      Accuracy = acc,
      Precision = precision,
      Recall = recall,
      F1 = f1,
      AUC = as.numeric(auc_value)  # Convert from roc object to numeric
    )
  })

  # Combine all metrics into one table
  bind_rows(metrics_list) %>%
    gt() %>%
    fmt_number(columns = -Model,
               decimals = 3) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels()
    ) |>
    fmt_number(
      columns = c("Accuracy", "Precision", "Recall", "F1", "AUC"),
      decimals = 3,
      dec_mark = ",",
      sep_mark = "."
    )
}

get_metrics <- function(predictions, model_name) {
  true_values <- as.factor(predictions$vindmll)
  pred_values <- as.factor(predictions[[model_name]])

  acc <- mean(true_values == pred_values)
  tp <- sum(true_values == "1" & pred_values == "1")
  fp <- sum(true_values == "0" & pred_values == "1")
  fn <- sum(true_values == "1" & pred_values == "0")

  precision <- tp / (tp + fp)
  recall <- tp / (tp + fn)
  f1 <- 2 * (precision * recall) / (precision + recall)

  roc_obj <- roc(as.numeric(true_values) - 1,
                 as.numeric(pred_values) - 1)
  auc_value <- auc(roc_obj)

  list(
    ac = acc |> vec_fmt_number(decimals = 3, locale = "da"),
    p = precision |> vec_fmt_number(decimals = 3, locale = "da"),
    r = recall |> vec_fmt_number(decimals = 3, locale = "da"),
    f = f1 |> vec_fmt_number(decimals = 3, locale = "da"),
    auc = as.numeric(auc_value) |> vec_fmt_number(decimals = 3, locale = "da")
  )
}
