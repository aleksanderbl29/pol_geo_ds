library(targets)
library(tarchetypes)

vis_pkgs <- c(
  "ggthemes", "cowplot", "gt", "patchwork", "viridis", "ggridges",
  "ggtext", "magick", "tmap", "modelsummary", "tinytable"
)

model_pkgs <- c(
  "keras3", "tidymodels", "ranger", "stats", "rsample", "broomstick",
  "randomForest", "pROC"
)

geospatial_pkgs <- c(
  "sf", "spatialsample", "stars", "dawaR", "terra"
)

tar_option_set(
  packages = c(vis_pkgs, model_pkgs, geospatial_pkgs,
    "tidyverse", "glue", "quarto"
  ),

  garbage_collection = TRUE,
  # error = "trim",

  # Definer seed til tilfældige taludtræk
  seed = 42
)

# Source funktioner fra R/
tar_source()

list(
  # Importer vindmøller fra onlinekilde
  tar_download(windmill_file,
               "https://ens.dk/sites/ens.dk/files/Statistik/anlaeg_2.xlsx",
               paths = "data/anlaeg_2.xlsx",
               error = "continue", deployment = "main"),
  tar_target(windmills_full, get_windmills(windmill_file, b02, crop = FALSE)),
  tar_target(windmills, get_windmills(windmill_file, b02, crop = TRUE)),

  # Importerer mgrs grids
  tar_target(mgrs32u_file, "data/mgrs/MGRS_1km_32U_unprojected/", format = "file"),
  tar_target(mgrs32v_file, "data/mgrs/MGRS_1km_32V_unprojected/", format = "file"),
  tar_target(mgrs33u_file, "data/mgrs/MGRS_1km_33U_unprojected/", format = "file"),
  tar_target(mgrs33v_file, "data/mgrs/MGRS_1km_33V_unprojected/", format = "file"),
  tar_target(mgrs, import_mgrs(mgrs32u_file, mgrs32v_file,
                               mgrs33u_file, mgrs33v_file, b02)),

  # Deklarer mappe med rasters
  tar_target(base_folder, "data/VESTJ/", deployment = "main"),
  # Importer træningsdata
  tar_target(b02, paste0(base_folder, "B02.jp2"), format = "file", deployment = "main"),
  tar_target(b03, paste0(base_folder, "B03.jp2"), format = "file", deployment = "main"),
  tar_target(b04, paste0(base_folder, "B04.jp2"), format = "file", deployment = "main"),
  tar_target(b08, paste0(base_folder, "B08.jp2"), format = "file", deployment = "main"),
  # Importer raster
  tar_target(import_raster, import_images(b02, b03, b04, b08), deployment = "main"),
  tar_target(n_crop, 8),
  tar_target(cells, get_cells(windmills, b02, n = n_crop)),
  tar_target(cropped_raster, crop_raster(import_raster, cells)),
  tar_target(no_proxy_raster, noproxy(cropped_raster)),
  tar_target(raster_sf, get_raster_sf(no_proxy_raster)),
  # Find memory størrelse på en celle
  tar_target(mem_size, get_row_size(no_proxy_raster, fmt = TRUE)),
  tar_target(v32_x, get_import_x(import_raster)),
  tar_target(v32_y, get_import_y(import_raster)),
  tar_target(v32_z, get_import_z(import_raster)),
  tar_target(pot_size, (get_row_size(no_proxy_raster) * v32_x * v32_y * v32_z) |>
               gt::vec_fmt_bytes()),
  tar_target(r_m_s, no_proxy_raster |> lobstr::obj_size() |> as.numeric() |>
               gt::vec_fmt_bytes()),
  tar_target(r_m_s_sf, raster_sf |> lobstr::obj_size() |> as.numeric() |>
               gt::vec_fmt_bytes()),
  # Find CRS for den importerede raster
  tar_target(crs, st_crs(import_raster)),
  # Tilføj lag med vindmøller
  tar_target(raster, assign_windmills(raster_sf, windmills, crs)),
  # Lav raster til dataframe
  tar_target(df, raster_as_dataframe(raster)),
  # Definer opskrift til modeller
  tar_target(split, initial_split(df, prop = 3/5)),
  tar_target(train, training(split)),
  tar_target(test, testing(split)),
  tar_target(recipe, define_recipe(train)),
  # Definer cross-validation folds til hyperparameter-tuning
  tar_target(tuning_set, get_tuning_set(train, windmills)),
  # tar_target(t_folds, cross_v(tuning_set)),
  tar_target(t_folds, spatial_block_cv(tuning_set, v = 5, buffer = 1)),
  tar_target(fold_plot, autoplot(t_folds) + coord_sf(expand = FALSE) +
               theme_classic() +
               theme(legend.position = "none")),
  # Single cells
  # Logistisk Regression
  tar_target(logistic_model, define_logistic_model()),
  tar_target(logistic_workflow, define_workflow(recipe, logistic_model)),
  tar_target(logistic, fit_model(logistic_workflow, test)),
  tar_target(logistic_prediction, model_pred(logistic, test)),
  tar_target(logistic_pred_df, get_predictions(logistic_prediction,
                                                   test, crs)),
  # Random Forest
  tar_target(rand_forest_model, define_rand_forest_model()),
  tar_target(rand_forest_grid, define_rand_forest_grid()),
  tar_target(rand_forest_workflow, define_workflow(recipe, rand_forest_model)),
  tar_target(rand_forest_params, hyp_par_tuning(rand_forest_workflow,
                                                t_folds, rand_forest_grid)),
  tar_target(rand_forest_params_specific, select_params(rand_forest_params)),
  tar_target(rand_forest_param_plot, autoplot(rand_forest_params) +
               labs(fill = "Udvalgte predictors",
                    color = "Udvalgte predictors") +
               theme_classic()),
  tar_target(rand_forest, fit_model(rand_forest_workflow, test, rand_forest_params)),
  tar_target(rand_forest_prediction, model_pred(rand_forest, test)),
  tar_target(rand_forest_pred_df, get_predictions(rand_forest_prediction,
                                                  test, crs)),

  # Reshape trænings og valideringsdata til array til keras3
  tar_target(cnn_train_x, reshape(train, "x")),
  tar_target(cnn_train_y, reshape(train, "y")),
  tar_target(cnn_test_x, reshape(test, "x")),
  tar_target(cnn_test_y, reshape(test, "y")),

  # Find input_layer fra data
  tar_target(input_shape, get_input_shape(cnn_train_x)),

  # # Definer og compile cnn
  tar_target(cnn_definition, define_cnn(input_shape, cnn_train_y)),

  # Definer path til cnn
  tar_target(cnn_path, get_cnn_path("data/model.keras", cnn_definition),
             format = "file"),
  # Fit cnn
  tar_target(cnn, fit_cnn(cnn_path,
                          train_x = cnn_train_x,
                          train_y = cnn_train_y,
                          epochs = 100,
                          batch_size = 256,
                          cnn_definition)),
  # Predict cnn
  tar_target(cnn_prediction, predict_cnn(cnn, cnn_test_x,
                                         cnn_test_y)),
  tar_target(cnn_pred_df, merge_cnn_predictions(test, cnn_prediction)),

  # Merge prediction data til endelige df
  tar_target(predictions, merge_predictions(
    raster, logistic_pred_df, rand_forest_pred_df, cnn_pred_df)),
  tar_target(pred_points, get_predicted_points(predictions)),
  tar_target(distances, calc_distances(raster, pred_points)),

  tar_target(bands_plot, plot_wavelengths()),

  tar_target(voting, get_voting_areas(raster)),

  ## Prediction plots
  tar_target(fig_eval_lr, plot_predictions(raster, pred_points, voting, test,
                                           "lr")),
  tar_target(fig_eval_rf, plot_predictions(raster, pred_points, voting, test,
                                           "rf")),
  tar_target(fig_eval_cnn, plot_predictions(raster, pred_points, voting, test,
                                            "cnn")),

  tar_target(lr, get_metrics(predictions, "logistic")),
  tar_target(rf, get_metrics(predictions, "randomforest")),
  tar_target(cn, get_metrics(predictions, "cnn")),


  tar_target(data_selection_plot, plot_all_data(windmills_full, import_raster, mgrs)),
  tar_target(n_vindm_cells, get_n_cells("vind", df)),
  tar_target(n_rast_cells, get_n_cells("non-vind", df)),

  tar_target(model_perf_tbl, evaluate_metrics(predictions)),

  tar_target(true_false_tbl_lr, evaluate_confusion(predictions, "logistic")),
  tar_target(true_false_tbl_rf, evaluate_confusion(predictions, "randomforest")),
  tar_target(true_false_tbl_cnn, evaluate_confusion(predictions, "cnn")),

  tar_target(showing_raster, extract_showing_raster(windmills, b02,
                                                    import_raster)),
  tar_target(vhr_mosaic_download, download_vhr_mosaic(showing_raster),
             error = "continue"),
  tar_target(vhr_mosaic, "data/vhr_mosaic.png", format = "file"),
  tar_target(windmill_vhr, get_windmill_plot(vhr_mosaic)),
  tar_target(ridgeplot, ggridge_distance_render(distances)),
  tar_quarto(render, "index.qmd")
)
