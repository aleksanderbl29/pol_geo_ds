raster_as_dataframe <- function(raster) {
  raster |>
    st_as_sf() |>
    st_make_valid() |>
    mutate(vindmll = as_factor(vindmll),
           vindmll_w_buff = as_factor(vindmll_w_buff))
}

get_raster_sf <- function(raster) {
  raster |>
    st_as_stars() |>
    st_as_sf()
}

noproxy <- function(raster) {
  st_as_stars(raster)
}

# Define the functions
split_raster_stars <- function(raster, n) {
  # raser <- st_as_stars(raster)
  dims <- st_dimensions(raster)
  x_splits <- seq(dims$x$offset, dims$x$offset + dims$x$delta * (dims$x$to - dims$x$from),
                  length.out = sqrt(n) + 1)
  y_splits <- seq(dims$y$offset, dims$y$offset + dims$y$delta * (dims$y$to - dims$y$from),
                  length.out = sqrt(n) + 1)

  parts <- list()
  for (i in seq_along(x_splits[-1])) {
    for (j in seq_along(y_splits[-1])) {
      parts[[length(parts) + 1]] <- raster[
        x_splits[i]:(x_splits[i + 1] - 1),
        y_splits[j]:(y_splits[j + 1] - 1),
        drop = FALSE
      ]
    }
  }
  return(parts)
}

# Main function to process stars raster in parallel
process_raster_in_parts_stars <- function(parts, n = 16) {

  # Set up parallel processing
  # windows
  # plan(multisession, workers = parallel::detectCores()) # Adjust workers as needed
  plan(multicore, workers = parallel::detectCores() / 2)

  # Process each part in parallel
  sf_parts <- future_map(parts, get_raster_sf)

  # Cleanup parallel plan
  plan(sequential)

  return(sf_parts)
}

raster_join_parts <- function(sf_parts) {
  # Combine results
  combined_sf <- bind_rows(sf_parts)
  return(combined_sf)
}
