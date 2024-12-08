import_images <- function(b02, b03, b04, b08) {

  rasterio <- list(nBufXSize = 15, nBufYSize = 15)

  # Importerer rasters
  raster <- read_stars(c(
    b02, b03, b04, b08
  ), along = "band", RasterIO = rasterio, proxy = TRUE)

  return(raster)
}
