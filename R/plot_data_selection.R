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
    left_join(tiles, by = "mgrs_tile") |>
    mutate(count = if_else(is.na(count), 0, count))


  ggplot() +
    geom_sf(data = mgrs_crop, color = "black", aes(fill = count), alpha = 0.25) +
    geom_sf(data = dk, color = "black", fill = NA) +
    geom_sf(data = windmills_full, color = "black", size = 0.5,
            shape = 20) +
    annotate("text", x = 270000, y = 6207300, label = "32VMH", hjust = 0) +
    geom_curve(aes(x = 330000, xend = 430000, y = 6227300, yend = 6253469),
             curvature = -0.2,
             arrow = arrow(type = "open", length = unit(0.2, "cm"))) +
    scale_fill_viridis_c(alpha = 0.4) +
    labs(fill = NULL) +
    theme_map()

}

get_row_size <- function(raster, fmt = FALSE) {
  if (isTRUE(fmt)) {
    raster[1,1,1] |>
      lobstr::obj_size() |>
      as.numeric() |>
      gt::vec_fmt_bytes(decimals = 2)
  } else if (!fmt) {
    raster[1,1,1] |>
      lobstr::obj_size() |>
      as.numeric()
  }
}

get_import_x <- function(raster) {
  dim(raster)[[1]]
}

get_import_y <- function(raster) {
  dim(raster)[[2]]
}

get_import_z <- function(raster) {
  dim(raster)[[3]]
}
