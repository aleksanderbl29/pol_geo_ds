import_images <- function(b02, b03, b04, b08) {

  rasterio <- NULL
  # rasterio <- list(nBufXSize = 15, nBufYSize = 15)
  # rasterio <- list(nBufXSize = 15, nBufYSize = 15)
  rasterio <- list(nBufXSize = 150, nBufYSize = 150)

  # Importerer rasters
  b2 <- read_stars(
    b02,
    along = "band",
    RasterIO = rasterio,
    proxy = TRUE
  )
  b3 <- read_stars(
    b03,
    along = "band",
    RasterIO = rasterio,
    proxy = TRUE
  )
  b4 <- read_stars(
    b04,
    along = "band",
    RasterIO = rasterio,
    proxy = TRUE
  )
  b8 <- read_stars(
    b08,
    along = "band",
    RasterIO = rasterio,
    proxy = TRUE
  )

  bands <- c(b2, b3, b4, b8, along = "band")

  return(bands)
}
