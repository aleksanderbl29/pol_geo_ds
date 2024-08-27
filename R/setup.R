prepare_classes <- function(classes) {
  if (!exists("classes")) {
    cli::cli_abort("Please provide classes")
  }
  classes <- paste(seq_along(classes), "-", classes)

  classes <- stringr::str_replace_all(classes, ": ", " - ")
  classes <- stringr::str_replace_all(classes, ":", "-")
  classes <- stringr::str_replace_all(classes, " :", " -")

  for (i in seq_along(classes)) {
    dir.create(paste0("../", classes[i]))
  }
}

classes <- c(
  "Introduktion til kurset og R",
  "Datahåndtering og manipulation i R",
  "Geo-data",
  "Geo-data visualisering og kortlægning",
  "Geo-dataanalyse I - Geokodning, afstande, mønstre og klynger",
  "Geo-dataanalyse II - Måling, Måling, Måling",
  "Geo-dataanalyse III - Statistisk læring og web scraping",
  "Naturlige eksperimenter og geografiske RDD I",
  "Naturlige eksperimenter og geografiske RDD II",
  "Projekt-feedback",
  "Analyse: Ulighed, kriminalitet, race",
  "Analyse: Klima",
  "Projekt-præsentationer",
  "Projekt-præsentationer"
)

prepare_classes(c(
  "Introduktion til kurset og R",
  "Datahåndtering og manipulation i R",
  "Geo-data",
  "Geo-data visualisering og kortlægning",
  "Geo-dataanalyse I - Geokodning, afstande, mønstre og klynger",
  "Geo-dataanalyse II - Måling, Måling, Måling",
  "Geo-dataanalyse III - Statistisk læring og web scraping",
  "Naturlige eksperimenter og geografiske RDD I",
  "Naturlige eksperimenter og geografiske RDD II",
  "Projekt-feedback",
  "Analyse: Ulighed, kriminalitet, race",
  "Analyse: Klima",
  "Projekt-præsentationer",
  "Projekt-præsentationer"
))
