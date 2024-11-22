import_images <- function(b02, b03, b04, b08) {
  # Importerer rasters
  b2_rast <- rast(b02)
  b3_rast <- rast(b03)
  b4_rast <- rast(b04)
  b8_rast <- rast(b08)


  raster <- b2_rast

  add(raster) <- b3_rast
  add(raster) <- b4_rast
  add(raster) <- b8_rast
    # Projicer til WGS 84 - EPSG:4326
    # project("EPSG:4326")

  raster |>
    wrap()
}
#
# r <- rast(nrows = 10, ncols = 10, xmin = 0, xmax = 5, ymin = 0, ymax = 5)  # Using rast() from terra
#
#
# test_import = terra::rast("GioLand VHR 2021 LAEA.tif")
# plot(test_import)
#
# dk = rast("_ags_5519d335_f334_4577_8a91_7bf9e531284e.tif")
# plot(dk)

# dk <- rast("data/import.tif")
# plot(dk)
#
# dk <- rast("data/_ags_8dc53064_bbda_4fac_99e7_f0756daf6011.tif")
# plot(dk)

# vest <- rast("/Volumes/T7 Shield/Remote sensing/S2A_MSIL2A_20241003T103901_N0511_R008_T32VMH_20241003T151806.SAFE/GRANULE/L2A_T32VMH_A048482_20241003T104015/IMG_DATA/R10m/T32VMH_20241003T103901_B02_10m.jp2")
# plot(vest)



