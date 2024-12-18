raster_as_dataframe <- function(raster) {

  raster |>
    st_as_sf() |>
    st_make_valid() |>
    mutate(vindmll = as_factor(vindmll))

}
