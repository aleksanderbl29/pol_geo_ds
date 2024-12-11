define_recipe <- function(training) {
  recipe(training) |>
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

define_rand_forest_model <- function() {
  rand_forest(trees = tune(), mtry = tune()) |>
    set_engine("ranger") |>
    set_mode("classification")
}

define_rand_forest_grid <- function() {
  expand_grid(trees = seq(100, 1500, by = 100), mtry = 1:4)
}
