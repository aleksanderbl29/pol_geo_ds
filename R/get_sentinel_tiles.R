get_sentinel_tiles <- function(tile_id) {
  connection <- connect(host = "https://openeo.dataspace.copernicus.eu")
  bands <- c("B02", "B03", "B04", "B08")
}
