{
  source("_targets_packages.R")
  # targets::tar_load_everything()
  targets::tar_source()
}


# rasterio <- list(nBufXSize = 15, nBufYSize = 15)
rasterio <- list(nBufXSize = 150, nBufYSize = 150)

# Importerer rasters
b2 <- read_stars(
  t_b02,
  along = "band",
  RasterIO = rasterio,
  proxy = TRUE
)
b3 <- read_stars(
  t_b03,
  along = "band",
  RasterIO = rasterio,
  proxy = TRUE
)
b4 <- read_stars(
  t_b04,
  along = "band",
  RasterIO = rasterio,
  proxy = TRUE
)
b8 <- read_stars(
  t_b08,
  along = "band",
  RasterIO = rasterio,
  proxy = TRUE
)

bands <- c(b2, b3, b4, b8, along = "band")

windmills <- st_transform(windmills, crs = st_crs(bands))

points <- windmills |>
  st_transform(crs) |>
  select(d_wind, geometry)

raster_sf <- bands |>
  st_as_sf()

st_join(raster_sf, points) |>
  rename(b02 = attr.V1,
         b03 = attr.V2,
         b04 = attr.V3,
         b08 = attr.V4,
         vindmll = d_wind) |>
  mutate(vindmll = if_else(!is.na(vindmll), 1, 0))



binary_windmills <- st_rasterize(
  windmills,
  template = bands
)

w <- windmills |>
  st_as_stars()

# Transformerer til givet CRS
points <- windmills |>
  st_transform(crs) |>
  select(d_wind, geometry) |>
  st_rasterize()

raster_sf <- raster |>
  st_as_sf()

sf <- st_join(raster_sf, points) |>
  mutate(d_wind = if_else(!is.na(d_wind), d_wind, 0))

st_as_stars(sf) #|>
st_redimension()

sf |>
  st_rasterize(dims = list(band = c("2", "3", "4", "8"), wind = c("d_wind"))) |>
  plot()

c(raster, points, along = wind)

r <- st_join(raster, st_transform(windmills, crs)) |> st_rasterize()

st_join(raster, points,
        as_points = FALSE,
        what = "inner")

points

x <- st_join(raster, points) |>
  st_rasterize()


st_redimension(x) |>
  plot()

# Rasterizer punkterne og tildeler TRUE
wind_rast <- st_rasterize(
  st_as_stars(st_bbox(points)),
  template = raster
)

st_bbox(points)  # Bounding box of the points
st_bbox(raster)  # Bounding box of the template
st_dimension(raster)

read_stars(wind_rast) |> plot()

c(raster, points)

st_join(raster, points) |> plot()

# st_rasterize(
#   st_sf(data.frame(value = 1), geometry = st_geometry(points)),
#   template = raster
# )


# Merger tilbage i original raster
raster$vindmll <- if_else(!is.na(wind_rast$d_wind), wind_rast$d_wind, 0)

return(wind_rast)








tar_read(import_raster) |>
  ggplot() +
  geom_sf()

ggplot() +
  geom_stars(data = tar_read(import_raster)) +
  geom_sf(data = tar_read(windmills), aes(color = "Vindmølle")) +
  facet_wrap(~band) +
  theme_minimal()






















