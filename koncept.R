{
  source("_targets_packages.R")
  # targets::tar_load_everything()
  targets::tar_source()
}

library(openeo)

connection <- connect(host = "https://openeo.dataspace.copernicus.eu")

login()
capabilities()

tar_load(crs)

colls <- list_collections()

p <- processes()

graph <- p$load_collection(
  id = colls$SENTINEL2_L2A,
  spatial_extent = NULL,
  temporal_extent = c("2024-01-01", "2024-12-31"),  # Adjust temporal extent
  bands = c("B02", "B03", "B04", "B08")
) |>
  p$resample_spatial(projection = e)
  p$save_result(format = "GTIFF")

job <- create_job(graph, con = connection, title = "32VHM Export")
as(job, "Process")
start_job(job, log = TRUE)

result_obj <- list_results(job)

download_results(job, folder = "/Volumes/T7 Shield/Remote sensing/openeo")

