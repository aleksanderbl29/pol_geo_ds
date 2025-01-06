import_images <- function(b02, b03, b04, b08) {

  # Importerer rasters
  b2 <- read_stars(
    b02,
    along = "band"
  )
  b3 <- read_stars(
    b03,
    along = "band"
  )
  b4 <- read_stars(
    b04,
    along = "band"
  )
  b8 <- read_stars(
    b08,
    along = "band"
  )

  bands <- c(b2, b3, b4, b8, along = "band")

  return(bands)
}
