# Created by use_targets().
# Link to the manual:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  # Define packages to use in pipeline.
  packages = c(
    "tidyverse", "glue", "quarto",
    "ggthemes", "cowplot", "ggmap", "gt", "patchwork",
    "sf", "terra",
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
