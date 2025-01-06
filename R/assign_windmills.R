assign_windmills <- function(raster_sf, windmills, crs) {
  # Transform windmill points to the specified CRS
  points <- windmills |>
    st_transform(crs) |>
    select(d_wind, geometry) |>
    rename(vindmll = d_wind)

  # Initial join with windmills (to identify cells with windmills)
  raster_sf <- raster_sf |>
    st_join(points) |>
    rename(b02 = attr.V1,
           b03 = attr.V2,
           b04 = attr.V3,
           b08 = attr.V4) |>
    mutate(vindmll = if_else(!is.na(vindmll), 1, 0))

  # Identify the raster cells that intersect with the windmills
  raster_sf_intersect <- raster_sf |>
    filter(vindmll == 1)  # Keep only cells that intersect with windmills

  # Calculate centroids of the intersecting raster cells
  raster_centroids <- st_centroid(raster_sf_intersect) |>
    select(vindmll) |>
    rename(vindmll_w_buff = vindmll)

  # Calculate the size of a raster cell (assuming square cells)
  cell_bbox <- st_bbox(raster_sf[1, ])  # Get bounding box of one raster cell centroid
  cell_width <- cell_bbox$xmax - cell_bbox$xmin  # width of one raster cell
  cell_height <- cell_bbox$ymax - cell_bbox$ymin  # height of one raster cell

  # Assuming square cells, cell size will be the same for width and height
  cell_size <- mean(c(cell_width, cell_height))  # average size of the cell

  # Create buffers for proximity zones based on cell size
  buffer_1 <- st_buffer(raster_centroids, dist = cell_size)  # Closest cells
  buffer_2 <- st_buffer(raster_centroids, dist = 2 * cell_size)  # Second nearest cells
  buffer_3 <- st_buffer(raster_centroids, dist = 3 * cell_size)  # Third nearest cells

  # Combine buffers into a single object with weights
  buffer_1 <- buffer_1 |> mutate(vindmll_w_buff = 1)
  # buffer_1 <- buffer_1 |> mutate(vindmll = 0.75)
  # buffer_2 <- buffer_2 |> mutate(vindmll = 0.5)
  # buffer_3 <- buffer_3 |> mutate(vindmll = 0.25)
  buffers <- bind_rows(buffer_1, buffer_2, buffer_3)

  buffers$vindmll_w_buff[is.na(buffers$vindmll_w_buff)] <- 0

  # Use spatial indexing with st_join to assign weights based on proximity
  raster_sf <- st_join(raster_sf, buffers, join = st_intersects) |>
    mutate(vindmll_w_buff = case_when(
      vindmll == 0 & vindmll_w_buff == 0.25 ~ 0.25,
      vindmll == 0 & vindmll_w_buff == 0.5 ~ 0.5,
      vindmll == 0 & vindmll_w_buff == 0.75 ~ 1,
      vindmll == 1 & vindmll_w_buff == 1 ~ 1,
      .default = 0
    ))

  return(raster_sf)
}
