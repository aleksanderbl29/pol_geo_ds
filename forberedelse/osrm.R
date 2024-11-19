# Indlæs pakker
library(tidyverse)
library(osrm)
library(sf)

sample_size <- 1e8

df <- tibble(
  x = sample(seq(from = 8, to = 12, by = 0.001), sample_size, replace = TRUE),
  y = sample(seq(from = 54, to = 58, by = 0.001), sample_size, replace = TRUE)
) |>
  st_as_sf(coords = c("x", "y"))

# Hent sognedata og udvælg navn og geometry
sogne <- dawaR::get_map_data("sogne") |>
  st_centroid() |>
  select(geometry, navn)

# Find CRS for sognedata
crs <- st_crs(sogne)

# Hent punkter for køreanlæg
koreanlag <- dawaR::get_map_data("steder", undertype = "køretekniskAnlæg") |>
  st_centroid() |>
  select(geometry, primærtnavn)

# Generer liste til at opbevare dataframes fra loop
datalist <- list()

# Bestem størrelsen på hver bid af kildedata der skal gives til `osrmTable()`
n_size <- 250

# Bestem sekvens til loop
sequen <- seq(1, nrow(sogne), by = n_size)

# Kør loop
for (i in sequen) {
  # Definer max-værdi ud fra index-værdi
  max_i <- i + n_size - 1
  # Print nr. til skærmen
  cat("Nr.:", i, "til", max_i , "\n")
  # Generer subset af sognedata til osrmTable
  source <- sogne[i:max_i,] |> na.omit()
  # Generer rejsetider
  table <- osrmTable(src = source, dst = koreanlag)
  # Gem rejsetider som df
  durations <- as.data.frame(table$durations)
  # Giv kolonner navne efter det køreanlæg den repræsenterer
  names(durations) <- koreanlag$primærtnavn
  # Gem sognedata i tabel
  tbl <- tibble(
    sogn_navn = sogne$navn[[i]],
    geometry_x = sogne$geometry[[i]][1],
    geometry_y = sogne$geometry[[i]][2]
  )
  # Gem rejsetid og sognedata i df i listen
  datalist[[i]] <- cbind(durations, tbl)
}

# Sammenlæg alle df i listen og omdan til sf med CRS fra sognedata
df <- do.call(rbind, datalist) |>
  st_as_sf(coords = c("geometry_x", "geometry_y"), crs = crs)

glimpse(df)
nrow(df)
head(df)
tail(df)

