FROM rocker/geospatial:latest

RUN R -e "pkgs = c('tidyverse', 'glue', 'quarto', 'ggthemes', 'cowplot', 'gt', 'patchwork', 'viridis', 'ggridges', 'keras3', 'tidymodels', 'ranger', 'crew.aws.batch', 'targets', 'tarchetypes');for (pkg in pkgs) {install.packages(pkg, quiet = TRUE)}"

RUN R -e "pkgs = c('sf', 'terra', 'spatialsample', 'stars');for (pkg in pkgs) {install.packages(pkg, repos = 'https://cloud.r-project.org', quiet = TRUE)}"

RUN R -e "keras3::install_keras(backend = 'tensorflow')"
