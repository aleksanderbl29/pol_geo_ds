get_windmill_plot <- function(mosaic) {
  image <- image_read(mosaic)

  ggplot() +
    annotation_raster(as.raster(image), xmin = -Inf, xmax = Inf,
                      ymin = -Inf, ymax = Inf)
}

extract_showing_raster <- function(windmills, t_b02, import_raster) {
  cells <- get_cells(windmills, t_b02, n = 145)
  crop_raster(import_raster, cells) |>
    st_rgb()
}

# Function to download a subset of the VHR mosaic
download_vhr_mosaic <- function(sf_object, width = 1024, height = 1024, crs = "EPSG:23032") {
  output_path <- "data/vhr_mosaic.png"

  # Extract bounding box
  bbox <- st_bbox(sf_object) |>
    as.numeric()

  # Format bounding box for WMS (xmin, ymin, xmax, ymax)
  bbox_str <- glue("{bbox[1]},{bbox[2]},{bbox[3]},{bbox[4]}")

  # Define the WMS service endpoint
  base_url <- "https://image.discomap.eea.europa.eu/arcgis/services/GioLand/VHR_2021_LAEA/ImageServer/WMSServer/"

  # Define WMS parameters
  params <- list(
    service = "WMS",
    version = "1.3.0",
    request = "GetMap",
    layers = "VHR_2021_LAEA", # Layer name from GetCapabilities
    bbox = bbox_str,
    crs = crs,               # Coordinate reference system (e.g., EPSG:3035 for LAEA)
    width = width,           # Width of the output image
    height = height,         # Height of the output image
    format = "image/png"     # Output format (e.g., PNG or GeoTIFF)
  )

  # Make the GET request to the WMS server
  response <- GET(base_url, query = params)

  # Check if the request was successful
  if (status_code(response) != 200) {
    stop("Failed to download data: ", content(response, "text"))
  }

  # Write the content to the specified output path
  writeBin(content(response, "raw"), output_path)

  message("Download complete: ", output_path)
}

# Example usage
# Assuming you have an sf object `my_sf` with CRS EPSG:3035
# download_vhr_mosaic(my_sf, "vhr_mosaic_subset.png")
