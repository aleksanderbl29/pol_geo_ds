# Created by use_targets().
# Link to the manual:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)
library(geotargets)

# Set target options:
tar_option_set(
  # Define packages to use in pipeline.
  packages = c(
    "tidyverse", "glue", "quarto",
    "ggthemes", "cowplot", "ggmap", "gt", "patchwork",
    "sf", "terra", "tidyterra",
    "keras3", "httr2"
  ),

  # Define controller to use distribute compute.
  controller = crew::crew_controller_local(
    name = "my_controller",
    workers = 10,
    seconds_idle = 3
  )
)

# Source functions from R/ folder:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
  # Importer vindmøller - Skal hentes manuelt med instruktioner i
  # `download_windmills`
  tar_target(windmill_file, "data/anlaeg_2.xlsx", format = "file"),
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
  tar_target(t_rast_import, import_images(t_b02, t_b03, t_b04, t_b08)),
  tar_target(t_rast, assign_windmills(t_rast_import, windmills, crs)),
  # Sammensæt validation raster
  tar_target(v_rast, import_images(v_b02, v_b03, v_b04, v_b08)),
  # Find CRS for valideringsdata
  tar_target(crs, get_crs(v_rast)),
  # tar_target(crs, get_crs(v_rast)),
  tar_target(point, st_point(c(0, 0))),
  tar_target(cat_1_m, 4),
  tar_target(cat_2_m, cat_1_m * 2),
  tar_target(cat_3_m, cat_2_m * 1.5),
  tar_target(eval_table, eval_cat_table_render(cat_1_m, cat_2_m, cat_3_m)),
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
