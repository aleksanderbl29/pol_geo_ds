FROM rocker/geospatial:latest

RUN Rscript -e "pkgs = c('tidyverse', 'glue', 'quarto', 'data.table', 'duckplyr', 'ggthemes', 'cowplot', 'gt', 'patchwork', 'viridis', 'ggridges', 'sf', 'terra', 'tidyterra', 'spatialsample', 'stars', 'keras3', 'tidymodels', 'ranger', 'crew.aws.batch', 'targets', 'tarchetypes');for (pkg in pkgs) {install.packages(pkg, repos = 'https://cloud.r-project.org', quiet = TRUE)}"

RUN Rscript -e "keras3::install_keras(backend = 'tensorflow')"
