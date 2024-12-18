import_mgrs <- function(file1, file2, file3, file4, rasterimage) {
  f1 <- sf::read_sf(file1) |>
    sf::st_make_valid() |>
    select(kmSQ_ID, GZD, geometry)

  f2 <- sf::read_sf(file2) |>
    sf::st_make_valid() |>
    select(kmSQ_ID, GZD, geometry)

  f3 <- sf::read_sf(file3) |>
    sf::st_make_valid() |>
    select(kmSQ_ID, GZD, geometry)

  f4 <- sf::read_sf(file4) |>
    sf::st_make_valid() |>
    select(kmSQ_ID, GZD, geometry)

  f1_box <- get_grouped_bounding_box(f1)
  f2_box <- get_grouped_bounding_box(f2)
  f3_box <- get_grouped_bounding_box(f3)
  f4_box <- get_grouped_bounding_box(f4)

  df <- bind_rows(f1_box, f2_box, f3_box, f4_box) |>
    mutate(mgrs_tile = paste0(GZD, kmSQ_ID), .before = geometry) |>
    select(mgrs_tile, geometry) |>
    st_make_valid() |>
    st_transform(st_crs(read_stars(rasterimage)))
  return(df)
}

get_grouped_bounding_box <- function(df) {
  df %>%
    group_by(kmSQ_ID, GZD) %>%
    summarize(geometry = st_union(geometry)) %>%
    rowwise() %>%
    mutate(geometry = st_as_sfc(st_bbox(geometry))) %>%
    ungroup()
}
