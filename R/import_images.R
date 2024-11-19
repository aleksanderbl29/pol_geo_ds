import_images <- function() {
  url <- "https://image.discomap.eea.europa.eu/arcgis/rest/services/GioLand/VHR_2021_LAEA/ImageServer/exportImage"

  query_params <- list(bbox = c(938758.000000712,936655.9999994207,7350008.0000007115,5420981.999999421))
  bbox_param <- "938758.000000712,936655.9999994207,7350008.0000007115,5420981.999999421"

  paste0(url, query_params$bbox[1:4])
  paste0(url, param)

  request(url) |>
    req_url_query(
      bbox = bbox_param,
      format = "tiff",
      bandIds = "0,1,2"
    ) |>
    req_perform() |>
    resp_raw()
    req_dry_run()

  elaborate_url <- "https://image.discomap.eea.europa.eu/arcgis/rest/services/GioLand/VHR_2021_LAEA/ImageServer/exportImage?bbox=938758.000000712%2C936655.9999994207%2C7350008.0000007115%2C5420981.999999421&bboxSR=&size=&imageSR=&time=&format=tiff&pixelType=U8&noData=&noDataInterpretation=esriNoDataMatchAny&interpolation=RSP_BilinearInterpolation&compression=&compressionQuality=&bandIds=&sliceId=&mosaicRule=&renderingRule=&adjustAspectRatio=true&validateExtent=false&lercVersion=1&compressionTolerance=&f=image"
  request(elaborate_url) |>
    req_perform() |>
    resp_raw()

}


#
# library(terra)
#
# b1 <- raster('taycrop.tif', band=1)
# b2 <- raster('taycrop.tif', band=2)
# b3 <- raster('taycrop.tif', band=3)
# b4 <- raster('taycrop.tif', band=4)
# b5 <- raster('taycrop.tif', band=5)
# b6 <- raster('taycrop.tif', band=6)
# b7 <- raster('taycrop.tif', band=7)
# b8 <- raster('taycrop.tif', band=8)
# b9 <- raster('taycrop.tif', band=9)
# b10 <- raster('taycrop.tif', band=10)
# b11 <- raster('taycrop.tif', band=11)
# b12 <- raster('taycrop.tif', band=12)
#
# r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 5, ymin = 0, ymax = 5)  # Using rast() from terra
#
#
# test_import = terra::rast("GioLand VHR 2021 LAEA.tif")
# plot(test_import)
#
# dk = rast("_ags_5519d335_f334_4577_8a91_7bf9e531284e.tif")
# plot(dk)









get_laby <- function() {

  laby <- dst_meta("LABY06", lang = "da")
  laby$variables
  laby$values

  dst_get_data(
    table = "LABY06",
    KOMGRP = laby$values$KOMGRP$text,
    Tid = "*",
    ALDER = laby$values$ALDER$text,
    lang = "da"
  )
}

























