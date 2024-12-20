assign_windmills <- function(raster_sf, windmills, crs) {

  points <- windmills |>
    st_transform(crs) |>
    select(d_wind, geometry)

  st_join(raster_sf, points) |>
    rename(b02 = attr.V1,
           b03 = attr.V2,
           b04 = attr.V3,
           b08 = attr.V4,
           vindmll = d_wind) |>
    mutate(vindmll = if_else(!is.na(vindmll), 1, 0))

}
