plot_wavelengths <- function() {
  bands <- data.frame(
    band = c("B2 (Blå)", "B3 (Grøn)", "B4 (Rød)", "B8 (NIR)"),
    wavelength_min = c(490, 560, 665, 842),  # i nm
    wavelength_max = c(520, 580, 675, 880)   # i nm
  )

  # Opret basisplot for det synlige spektrum
  spectrum <- data.frame(
    wavelength = seq(400, 700, 1),
    color = rgb(seq(0, 1, length.out = 301), seq(0, 1, length.out = 301), seq(0, 1, length.out = 301), maxColorValue = 1)
  )

  # Plot farvespektret
  ggplot() +
    geom_tile(data = spectrum, aes(x = wavelength, y = 1, fill = color), height = 1) +
    labs(x = "Bølgelængde (nm)", y = NULL, color = NULL, fill = NULL) +
    geom_rect(data = bands, aes(xmin = wavelength_min, xmax = wavelength_max, ymin = 0.5, ymax = 1.5, fill = band), alpha = 0.3) +
    scale_fill_manual(values = c("B2 (Blå)" = "blue", "B3 (Grøn)" = "green", "B4 (Rød)" = "red", "B8 (NIR)" = "purple")) +
    coord_cartesian(expand = FALSE) +
    theme_classic() +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "top"
    )
}

plot_wavelengths <- function() {
  bands <- data.frame(
    band = c("2", "3", "4", "8"),
    wavelength = c(490, 560, 665, 842),
    bandwidth = c(65, 35, 30, 115)
  ) |>
    mutate(
      wavelength_max = wavelength + (bandwidth / 2),
      wavelength_min = wavelength - (bandwidth / 2)
    )


  # Opret basisplot for det synlige spektrum
  spectrum <- data.frame(
    wavelength = seq(400, 700, 1),
    color = rgb(seq(0, 1, length.out = 301), seq(0, 1, length.out = 301), seq(0, 1, length.out = 301), maxColorValue = 1)
  )

  # Plot farvespektret
  ggplot() +
    geom_tile(data = spectrum, aes(x = wavelength, y = 1, color = color,
                                   alpha = 0.15), height = 1) +
    geom_rect(data = bands, aes(xmin = wavelength_min, xmax = wavelength_max,
                                ymin = 0.5, ymax = 1.5, fill = band),
              alpha = 0.5, color = "black") +
    geom_text(data = bands, aes(x = wavelength, y = 1, label = band), color = "white", size = 5) +  # Add text labels in the rectangles
    labs(x = "Bølgelængde (nm)", y = NULL, color = NULL, fill = NULL) +
    scale_fill_manual(values = c("2" = "blue", "3" = "green", "4" = "red", "8" = "purple")) +
    coord_cartesian(expand = FALSE) +
    theme_classic() +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.line.y = element_blank(),
      legend.position = "none"
    )
}

plot_band <- function(file_path) {
  # Læs båndet ind i stars
  band <- read_stars(file_path)

  # Definer farvepaletter baseret på filnavnet (udtrukket fra filstien)
  get_palette <- function(band_file) {
    n_colors <- 15
    if (grepl("B02", band_file)) {
      return(colorRampPalette(c("white", "blue"))(n_colors))  # Blå for Bånd 2
    } else if (grepl("B03", band_file)) {
      return(colorRampPalette(c("white", "green"))(n_colors))  # Grøn for Bånd 3
    } else if (grepl("B04", band_file)) {
      return(colorRampPalette(c("white", "red"))(n_colors))  # Rød for Bånd 4
    } else if (grepl("B08", band_file)) {
      return(colorRampPalette(c("white", "purple"))(n_colors))  # Lilla for Bånd 8
    }
  }

  # Få filnavnet fra filstien (kun filnavnet, ikke den fulde sti)
  band_file <- basename(file_path)

  # Få farvepaletten baseret på båndfilens navn
  palette <- get_palette(band_file)

  # Fjern margin og print minimalistisk plot
  par(mar = c(0,0,0,0))

  plot(
    band,
    col = palette,
    axes = FALSE,
    ann = FALSE,
    main = NULL,
    key.pos = NULL,
    reset = FALSE
  )
}
