FROM rocker/geospatial:latest

RUN R -q -e "pkgs = c('tidyverse', 'glue', 'quarto', 'ggthemes', 'cowplot', 'gt', 'patchwork', 'viridis', 'ggridges', 'sf', 'terra', 'tidyterra', 'spatialsample', 'stars', 'keras3', 'tidymodels', 'ranger', 'crew.aws.batch', 'targets', 'tarchetypes');for (pkg in pkgs) {install.packages(pkg, repos = 'https://cloud.r-project.org', quiet = TRUE)}"

# RUN R -q -e "keras3::install_keras(backend = 'tensorflow')"
