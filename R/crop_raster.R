crop_raster <- function(raster, cells) {
  crop_area <- cells |>
    # Find cellen med højest antal vindmøller
    slice_max(point_count) |>
    # Slice igen for kun at tage den øverste
    slice(1)

  raster[crop_area]
}

get_cells <- function(windmills, file, n = 10) {
  # Read the raster and create grid
  grid <- st_make_grid(read_stars(file), n = n)

  # Convert grid to sf object with cell ID
  grid_sf <- st_sf(cell_id = 1:length(grid), geometry = grid)

  # Count points in each grid cell
  intersects <- st_intersects(grid_sf, windmills)
  grid_sf$point_count <- lengths(intersects)

  return(grid_sf)
}
