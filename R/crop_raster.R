crop_raster <- function(raster) {
  raster <- unwrap(raster)

  raster |> plot()

  raster |>
    ext()

  bbox <- dawaR::get_map_data("regioner") |>
    st_bbox() |>
    st_transform(3035)

  bbox <- c(
    get_bbox("xmin"),
    get_bbox("xmax"),
    get_bbox("ymin"),
    get_bbox("ymax")
  ) |>
    st_as_sf()
    st_transform(crs = st_crs(raster))


    terra::project("EPSG:3035") |>
    terra::ext()

  cropped <- crop(raster, bbox)
  cropped <- crop(raster, data)
  plot(cropped)
}

get_bbox <- function(type) {
  type <- match.arg(type, choices = c("ymin", "ymax", "xmin", "xmax"))

  # Henter data og trækker bbox var ud.
  # CRS = WGS84
  # EPSG:4326
  data <- dawaR::get_data("kommuner") |>
    filter(navn == "Ringkøbing-Skjern") |>
    pull(paste0("bbox_", type))

  if (substr(type, 2, 5) == "max") {
    data |> max()
  } else if (substr(type, 2, 5) == "min") {
    data |> min()
  }
}



