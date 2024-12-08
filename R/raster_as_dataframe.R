# raster_as_dataframe <- function(b02, b03, b04, b08, windmills, crs) {
raster_as_dataframe <- function(raster) {

  # rast <- import_images(b02, b03, b04, b08, crop = TRUE, windmills = windmills, crs)

  # rast <- read_stars(c(
  #   b02, b03, b04, b08
  # ))

  # sf <- st_as_sf(rast)

  #raster <-
  #   read_stars(c(
  #   b02, b03, b04, b08
  # ))

  # st_chunks <- lapply(1:100, function(i) {
  #
  # })
  #
  # |>
  #   st_as_sf() |>
  #   st_make_valid()


  # truth <- assign_windmills(rast, windmills, crs)
  #
  # raster <- unwrap(rast)
  #
  # add(raster) <- unwrap(truth)
  #
  # # dt <- as.data.table(raster, xy = TRUE) |>
  # dt <- duckplyr::as_duckplyr_df(raster, xy = TRUE) |>
  #   st_as_sf(coords = c("x", "y"), crs = st_crs(crs))

  # if (truth) {
  #   dt[, c("Vindmølle_b03", "Vindmølle_b04", "Vindmølle_b08") := list(Vindmølle_b02, Vindmølle_b02, Vindmølle_b02)]
  # }

  # return(dt)

  st_as_sf(raster) |>
    st_make_valid()

}
