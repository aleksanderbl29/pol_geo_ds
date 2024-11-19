eval_score_plot_example_render <- function(
    point, cat_1_m, cat_2_m, cat_3_m, eval_cat_table
) {
  buffer_1 <- st_buffer(point, cat_1_m)
  buffer_2 <- st_buffer(point, cat_2_m)
  buffer_3 <- st_buffer(point, cat_3_m)

  fills <- c(
    "Ringe" = "red",
    "Okay" = "orange",
    "God" = "lightgreen"
  )

  design <- "
    111#
    1112
    111#
  "

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

  plot + wrap_table(eval_cat_table) +
    plot_layout(design = design)
}

eval_cat_table_render <- function(cat_1_m, cat_2_m, cat_3_m) {
  v1 <- god <- glue("< {cat_1_m}")
  v2 <- okay <- glue("{cat_1_m} - {cat_2_m}")
  v3 <- bad <- glue("{cat_2_m} - {cat_3_m}")
  v4 <- ringe <- glue("> {cat_3_m}")

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
