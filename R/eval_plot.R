eval_score_plot_example_render <- function(
    point, cat_1_m, cat_2_m, cat_3_m, eval_cat_table
) {
  # Udregn buffer for hver kategori fra punkt
  buffer_1 <- st_buffer(point, cat_1_m)
  buffer_2 <- st_buffer(point, cat_2_m)
  buffer_3 <- st_buffer(point, cat_3_m)

  # Definer farver og navne til kategorier
  fills <- c(
    "Ringe" = "red",
    "Okay" = "orange",
    "God" = "lightgreen"
  )

  # Definer design til patchwork plot
  design <- "
    111#
    1112
    111#
  "

  # Lav skydeskive plot
  plot <- ggplot() +
    geom_sf(data = buffer_3, aes(fill = "Ringe"), color = "black", linewidth = 1) +
    geom_sf(data = buffer_2, aes(fill = "Okay"), color = "black", linewidth = 1) +
    geom_sf(data = buffer_1, aes(fill = "God"), color = "black", linewidth = 1) +
    geom_sf(data = point, fill = "black", size = 3) +
    scale_fill_manual(values = fills) +
    theme_classic() +
    theme(
      legend.position = "none",
      axis.line = element_blank(),
      axis.ticks = element_blank(),
      axis.text = element_blank()
    )

  # Sammensæt plot og tabel
  plot + wrap_table(eval_cat_table) +
    plot_layout(design = design)
}

eval_cat_table_render <- function(cat_1_m, cat_2_m, cat_3_m) {
  # Definer labels
  v1 <- god <- glue("< {cat_1_m}")
  v2 <- okay <- glue("{cat_1_m} - {cat_2_m}")
  v3 <- bad <- glue("{cat_2_m} - {cat_3_m}")
  v4 <- ringe <- glue("> {cat_3_m}")

  # Start med tibble og lav tabel
  tibble(
    "God" = 1,
    "Okay" = 2,
    "Dårlig" = 3,
    "Ringe" = 4
  ) |>
    pivot_longer(cols = everything()) |>
    mutate(value = factor(
      value,
      levels = c(1, 2, 3, 4),
      labels = c(
        god,
        okay,
        bad,
        ringe
      ))) |>
    gt() |>
    tab_style(
      style = list(cell_fill(color = "lightgreen")),
      locations = cells_body(rows = 1)) |>
    tab_style(
      style = list(cell_fill(color = "orange")),
      locations = cells_body(rows = 2)) |>
    tab_style(
      style = list(cell_fill(color = "red")),
      locations = cells_body(rows = 3)) |>
    # tab_style(
    #   style = list(cell_text(font = system_fonts("neo-grotesque")[2])),#c("Times New Roman", "Roboto", default_fonts()))),
    #   locations = cells_body(columns = c("name", "value"))) |>
    tab_options(column_labels.hidden = TRUE)
}

eval_score_plot_render <- function(data, point, cat_1_m, cat_2_m, cat_3_m) {
  buffer_1 <- st_buffer(point, cat_1_m)
  buffer_2 <- st_buffer(point, cat_2_m)
  buffer_3 <- st_buffer(point, cat_3_m)

  fills <- c(
    "Ringe" = "red",
    "Okay" = "orange",
    "God" = "lightgreen"
  )

  lim <- c(abs(data$long), abs(data$lat)) |>
    max() |>
    ceiling()

  ggplot() +
    geom_sf(data = buffer_3, aes(fill = "Ringe"), color = "black", linewidth = 1) +
    geom_sf(data = buffer_2, aes(fill = "Okay"), color = "black", linewidth = 1) +
    geom_sf(data = buffer_1, aes(fill = "God"), color = "black", linewidth = 1) +
    geom_sf(data = point, fill = "black", size = 3) +
    scale_fill_manual(values = fills) +
    geom_point(data = data, shape = 21, fill = NA,
               aes(x = long, y = lat), color = "black",
               size = 3) +
    lims(x = c(-lim, lim),
         y = c(-lim, lim)) +
    labs(x = "",
         y = "")
    # geom_sf(data = data,
    #         aes(fill = score),
    #         color = "black",
    #         linewidth = 2)
}

eval_raster_plot <- function(point, crs, eval_cat_table) {

  # Definer farver og navne til kategorier
  fills <- c(
    "Ringe" = "red",
    "Okay" = "orange",
    "Noget andet" = "yellow",
    "God" = "lightgreen"
  )

  # Definer design til patchwork plot
  design <- "
    111#
    1112
    111#
  "

  # Define resolution (side length of squares)
  resolution <- 10

  layers <- 3

  # Define relative offsets for squares (up to 3 layers)
  offsets <- expand.grid(dx = -layers:layers, dy = -layers:layers)
  offsets$manhattan <- abs(offsets$dx) + abs(offsets$dy) # Manhattan distance

  # Filter offsets to include only the required layers (direct adjacency logic)
  # offsets <- offsets[offsets$manhattan <= layers, ]

  # Create squares and assign values based on Manhattan distance
  squares <- lapply(1:nrow(offsets), function(i) {
    offset <- offsets[i, ]
    center <- st_coordinates(point) + c(offset$dx, offset$dy) * resolution
    polygon <- create_square(center, resolution)
    data.frame(
      value = 3 - offset$manhattan, # Green = 3, Yellow = 2, Orange = 1, Red = 0
      geometry = st_sfc(polygon, crs = st_crs(point))
    )
  })

  # Combine all squares into an sf object
  squares_sf <- do.call(rbind, squares) |>
    mutate(value = if_else(is.na(value), 99, value)) |>
    mutate(value = factor(value, levels = c(0:layers), labels = names(fills)))
  squares_sf <- st_as_sf(squares_sf) # Convert to sf object

  # Plot using ggplot2
  plot <- ggplot(squares_sf) +
    geom_sf(aes(fill = factor(value)), color = "black") +
    scale_fill_manual(
      values = fills,
      labels = c(names(fills), NULL),
      name = "Proximity",
      na.value = NA
    ) +
    theme_minimal() +
    theme(legend.position = "none")

  # Sammensæt plot og tabel
  plot + wrap_table(eval_cat_table) +
    plot_layout(design = design)
}

# Funktion der skaber firkantede sf polygoner omkring et centerpunkt
create_square <- function(center, res) {
  x <- center[1]
  y <- center[2]
  coords <- matrix(c(
    x - res / 2, y - res / 2,
    x + res / 2, y - res / 2,
    x + res / 2, y + res / 2,
    x - res / 2, y + res / 2,
    x - res / 2, y - res / 2
  ), ncol = 2, byrow = TRUE)
  st_polygon(list(coords))
}

ggridge_distance_render <- function(data) {

  data |>
    ggplot(aes(distance + 1, model, fill = model)) +
    geom_density_ridges2(show.legend = FALSE) +
    scale_fill_viridis_d(name = "Delta distance (m.)") +
    labs(x = "Distance (m)", y = NULL) +
    scale_x_log10() +
    theme_classic()
}
