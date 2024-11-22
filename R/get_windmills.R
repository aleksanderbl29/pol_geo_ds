get_windmills <- function(windmill_file) {

  # Indlæser XLSX
  import <- readxl::read_xlsx(windmill_file)

  # Skærer ind til kun kolonner med data. Fjerner også de første par rækker der
  # er overskrifter
  data <- import[13:nrow(import),1:15]

  # Laver øverste række til overskrifter
  names(data) <- data[1,]
  data <- data[-1,]

  # Behandler data
    # Laver datoer til datoformat
    # Laver koordinater til double
    # Omdanner til sf
  data |>
    janitor::clean_names() |>
    mutate(
      dato_for_oprindelig_nettilslutning = as.Date(
        as.numeric(dato_for_oprindelig_nettilslutning),
        origin = "1899-12-30"),
      dato_for_afmeldning = as.Date(
        as.numeric(dato_for_afmeldning),
                   origin = "1899-12-30"),
      x_koord = as.double(x_ost_koordinat_utm_32_euref89),
      y_koord = as.double(y_nord_koordinat_utm_32_euref89),
      d_wind = 1) |>
    select(ends_with("koord"), starts_with("dato"), d_wind) |>
    filter(!is.na(x_koord) & !is.na(y_koord)) |>
    st_as_sf(coords = c("x_koord", "y_koord"), crs = "EPSG:25832")

}

download_windmills <- function() {
  # Definerer url til download
  url <- "https://ens.dk/sites/ens.dk/files/Statistik/anlaeg_2.xlsx"

  # Downloader fil til filsti
  file <- "data/anlaeg_2.xlsx"
  # !!!!! Download denne fil manuelt
  download.file(url, destfile = file)
  unzip(file)
}
