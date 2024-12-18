plot_all_data <- function(windmills_full, import_raster, mgrs) {
  dk <- dawaR::get_map_data("kommuner") |>
    st_transform(crs = st_crs(import_raster))

  bbox <- sf::st_bbox(dk)

  mgrs_crop <- sf::st_filter(mgrs, dk, .predicate = sf::st_intersects)

  tiles <- st_join(windmills_full, mgrs_crop, join = sf::st_within) |>
    group_by(mgrs_tile) |>
    summarize(count = n(), .groups = "drop") |>
    select(-geometry) |>
    as.data.frame()

  mgrs_crop <- mgrs_crop |>
    left_join(tiles, by = "mgrs_tile")


  ggplot() +
    geom_sf(data = mgrs_crop, color = "black", aes(fill = count), alpha = 0.5) +
    geom_sf(data = dk, color = "black", fill = NA) +
    geom_sf(data = windmills_full, color = "black", size = 0.5) +
    scale_fill_viridis_c() +
    theme_map()

}
