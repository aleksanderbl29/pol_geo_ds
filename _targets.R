library(targets)
library(tarchetypes)
library(crew.aws.batch)

job_queue_name <- "targets_fargate_queue"
#
# aws_definition <- crew.aws.batch::crew_definition_aws_batch(
#   job_definition = "targets_pol_geo_ds",
#   job_queue = job_queue_name
# )
#
# aws_definition$register(
#   image = "rocker/geospatial:dev-osgeo",
#   # platform_capabilities = "EC2",
#   platform_capabilities = "FARGATE",
#   cpus = 4,
#   memory_units = "mebibytes",
#   memory = 16000
# )

controller_aws <- crew.aws.batch::crew_controller_aws_batch(
  name = "pol_geo_ds",
  workers = 4,
  tasks_max = 2,
  # seconds_launch = 600, # to allow a 10-minute startup window
  seconds_idle = 60, # to release resources when they are not needed
  # processes = 4, # See the "Asynchronous worker management" section below.
  options_aws_batch = crew_options_aws_batch(
    # job_definition = aws_definition$job_definition,
    job_definition = "target_fargate_manual",
    job_queue = job_queue_name,
    cpus = 4,
    # gpus = NULL,
    # Launch workers with 4 GB memory, then 8 GB if the worker crashes,
    # then 16 GB on all subsequent launches. Go back to 4 GB if the worker
    # completes all its tasks before exiting.
    memory = c(8192, 16384, 32768),
    memory_units = "mebibytes"
  )
)



# controller_aws$start()

tar_option_set(
  packages = c(
    "tidyverse", "glue", "quarto",
    "ggthemes", "cowplot", "gt", "patchwork", "viridis", "ggridges",
    "sf", "terra", "tidyterra", "spatialsample", "stars",
    "keras3", "tidymodels", "ranger",
    "crew.aws.batch", "targets", "tarchetypes"
  ),

  # Define controller to use distribute compute.
  # controller = crew::crew_controller_local(
  #   name = "my_controller",
  #   workers = 10,
  #   seconds_idle = 3
  # ),

  controller = controller_aws,

  # memory = "transient",
  garbage_collection = TRUE,
  # storage = "worker",
  # retrieval = "worker",

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
               error = "continue"),
  tar_target(windmills, get_windmills(windmill_file, t_b02)),

  # Deklarer mappe med rasters
  tar_target(base_folder, "/Volumes/T7 Shield/Remote sensing/"),
  # Importer træningsdata
  tar_target(t_b02, paste0(base_folder, "VESTJ/B02.jp2"), format = "file"),
  tar_target(t_b03, paste0(base_folder, "VESTJ/B03.jp2"), format = "file"),
  tar_target(t_b04, paste0(base_folder, "VESTJ/B04.jp2"), format = "file"),
  tar_target(t_b08, paste0(base_folder, "VESTJ/B08.jp2"), format = "file"),
  # Importer valideringsdata
  tar_target(v_b02, paste0(base_folder, "NRVST/B02.jp2"), format = "file"),
  tar_target(v_b03, paste0(base_folder, "NRVST/B03.jp2"), format = "file"),
  tar_target(v_b04, paste0(base_folder, "NRVST/B04.jp2"), format = "file"),
  tar_target(v_b08, paste0(base_folder, "NRVST/B08.jp2"), format = "file"),
  # Importer raster
  tar_target(import_raster, import_images(t_b02, t_b03, t_b04, t_b08)),
  tar_target(import_raster2, import_images(v_b02, v_b03, v_b04, v_b08)),
  # Find CRS for den importerede raster
  tar_target(crs, st_crs(import_raster)),
  # Tilføj lag med vindmøller
  tar_target(raster, assign_windmills(import_raster, windmills, crs)),
  # Sammensæt validation raster
  # tar_target(v_rast, import_images(v_b02, v_b03, v_b04, v_b08, crop = TRUE, windmills, crs)),
              # tar_target(v_rast_truth, assign_windmills(v_rast, windmills, crs)),
  # # Vær sikker på raster-par har samme dimensioner
  # tar_target(t_rast_check_dim, check_dims(t_rast, t_rast_truth)),
  # tar_target(v_rast_check_dim, check_dims(v_rast, v_rast_truth)),
  # Eksporter rasters til dataframes
  # tar_target(t_df, raster_as_dataframe(t_rast)),
  # tar_target(t_df_truth, raster_as_dataframe(t_rast_truth)),
  # tar_target(training_df, merge_data(t_df, t_df_truth)),

              # tar_target(training_df, raster_as_dataframe(t_b02, t_b03, t_b04, t_b08,
              #                                             windmills, crs)),
  tar_target(training_df, raster_as_dataframe(raster)),
  # tar_target(validation_df, raster_as_dataframe(v_rast)),
  # tar_target(v_df, raster_as_dataframe(v_rast)),
  # tar_target(v_df_truth, raster_as_dataframe(v_rast_truth)),
  # tar_target(validation_df, merge_data(v_df, v_df_truth)),


              # tar_target(validation_df, raster_as_dataframe(v_b02, v_b03, v_b04, v_b08,
              #                                               windmills, crs)),
  # Definer opskrift til modeller
  tar_target(recipe, define_recipe(training_df)),
  tar_target(init_split, initial_split(training_df)),
  # Definer cross-validation folds til hyperparameter-tuning
  # tar_target(t_folds, vfold_cv(training_df, v = 5)),
  # tar_target(t_folds, loo_cv(training_df)),
  # tar_target(t_folds, bootstraps(training_df, times = 1)),
  tar_target(t_folds, spatial_clustering_cv(training_df, v = 5)),
  tar_target(fold_plot, autoplot(t_folds)),
  # Random Forest
  tar_target(rand_forest_model, define_rand_forest_model()),
  tar_target(rand_forest_grid, define_rand_forest_grid()),
  tar_target(rand_forest_workflow, define_workflow(recipe, rand_forest_model)),
  tar_target(rand_forest_params, hyp_par_tuning(rand_forest_workflow,
                                                t_folds, rand_forest_grid)),
  tar_target(rand_forest_param_plot, autoplot(rand_forest_params)),
  ## Forbered rasters til CNN
  # tar_target(t_data, reshape(t_rast)),
  # tar_target(t_data_truth, reshape(t_rast_truth)),
  # tar_target(v_data, reshape(v_rast)),
  # tar_target(v_data_truth, reshape(v_rast_truth)),
  # # Find input_layer fra data
  # tar_target(input_shape, get_input_shape(t_data)),
  # # Definer og compile cnn
  # tar_target(cnn_definition, define_cnn(input_shape)), #, format = keras_fmt),
  # # Definer path til cnn - Kun hvis den findes
  # tar_skip(cnn_path, "data/cnn.keras",
  #          skip = !file.exists("data/cnn.keras"), format = "file"),
  # # Fit cnn
  # tar_target(cnn, fit_cnn(cnn_path, t_data, t_data_truth,
  #                         epochs = 15, batch_size = 128,
  #                         validation_data = list(v_data, v_data_truth))),


  tar_target(point, st_point(c(0, 0))),
  tar_target(cat_1_m, 4),
  tar_target(cat_2_m, cat_1_m * 2),
  tar_target(cat_3_m, cat_2_m * 1.5),
  tar_target(eval_table, eval_cat_table_render(cat_1_m, cat_2_m, cat_3_m)),
  tar_target(eval_raster_table, eval_cat_table_render(1, 2, 3)),
  tar_target(
    eval_score_plot_example,
    eval_score_plot_example_render(
      point,
      cat_1_m = cat_1_m,
      cat_2_m = cat_2_m,
      cat_3_m = cat_3_m,
      eval_table)),
  tar_target(simulated_data, sim_data(cat_1_m)),
  tar_target(eval_score_plot, eval_score_plot_render(simulated_data,
                                                     point,
                                                     cat_1_m = cat_1_m,
                                                     cat_2_m = cat_2_m,
                                                     cat_3_m = cat_3_m)),
  # tar_target(
  #   eval_cat_table,
  #   eval_cat_table_render(
  #     cat_1_m = cat_1_m,
  #     cat_2_m = cat_2_m,
  #     cat_3_m = cat_3_m)),
  tar_target(ridgeplot, ggridge_distance_render(simulated_data)),
  tar_quarto(render, "index.qmd")
)
