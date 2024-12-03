library(targets)
library(tarchetypes)
# library(qs2)

keras_fmt <- tar_format(
  read = function(path) {
    keras3::load_model(model = path)
  },
  write = function(object, path) {
    path <- paste0(path, ".keras")
    keras3::save_model(model = object, filepath = path)
  },
  marshal = function(object) {
    keras3::serialize_keras_object(object)
  },
  unmarshal = function(object) {
    keras3::deserialize_keras_object(object)
  }
)

terra_fmt <- tar_format(
  read = function(path) {
    terra::ras
  }
)

tar_option_set(
  packages = c(
    "tidyverse", "glue", "quarto", "data.table",
    "ggthemes", "cowplot", "ggmap", "gt", "patchwork",
    "sf", "terra", "tidyterra", "openeo",
    "keras3", "httr2"
  ),

  # Define controller to use distribute compute.
  # controller = crew::crew_controller_local(
  #   name = "my_controller",
  #   workers = 10,
  #   seconds_idle = 3
  # ),
  format = "qs",

  # memory = "transient",
  # garbage_collection = TRUE,
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
               paths = "data/anlaeg_2.xlsx"),
  tar_target(windmills, get_windmills(windmill_file)),

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
  # Sammensæt træning raster
  tar_target(t_rast, import_images(t_b02, t_b03, t_b04, t_b08)),
  tar_target(t_rast_truth, assign_windmills(t_rast, windmills, crs)),
  # Sammensæt validation raster
  tar_target(v_rast, import_images(v_b02, v_b03, v_b04, v_b08)),
  tar_target(v_rast_truth, assign_windmills(v_rast, windmills, crs)),
  # Find CRS for valideringsdata
  tar_target(crs, get_crs(v_rast)),
  # Eksporter rasters til dataframes
  tar_target(t_df, raster_as_dataframe(t_rast)),
  tar_target(t_df_truth, raster_as_dataframe(t_rast_truth)),
  tar_target(training_df, merge(t_df, t_df_truth,
                                by = c("x", "y"), all = TRUE)),
  tar_target(v_df, raster_as_dataframe(v_rast)),
  tar_target(v_df_truth, raster_as_dataframe(v_rast_truth)),
  tar_target(validation_df, merge(v_df, v_df_truth,
                                  by = c("x", "y"), all = TRUE)),
  # Forbered rasters til CNN
  tar_target(t_data, reshape(t_rast)),
  tar_target(t_data_truth, reshape(t_rast_truth)),
  tar_target(v_data, reshape(v_rast)),
  tar_target(v_data_truth, reshape(v_rast_truth)),
  # Find input_layer fra data
  tar_target(input_shape, get_input_shape(t_data)),
  # Definer og compile model
  tar_target(model_definition, define_model(input_shape)), #, format = keras_fmt),
  # Definer path til model - Kun hvis den findes
  tar_skip(model_path, "data/model.keras",
           skip = !file.exists("data/model.keras"), format = "file"),
  # Fit modellen
  tar_target(model, fit_model(model_path, t_data, t_data_truth,
                              epochs = 15, batch_size = 128,
                              validation_data = list(v_data, v_data_truth))),
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
  tar_quarto(render, "index.qmd")
)
