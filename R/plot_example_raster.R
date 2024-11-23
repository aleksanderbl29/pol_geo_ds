plot_example_raster <- function(raster, windmills) {

  raster <- raster |> terra::unwrap()

  raster |> terra::map_extent()

  plot(raster)

  bbox <- c(
    get_bbox("xmin"),
    get_bbox("xmax"),
    get_bbox("ymin"),
    get_bbox("ymax")
  )

  crop(raster, bbox)

}
