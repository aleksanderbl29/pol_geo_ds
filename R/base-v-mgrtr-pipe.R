library(tidyverse)
library(dawaR)

## Tager starwars data
df <- starwars

tidy_df <- df %>%
  select(where(is.numeric)) %>%
  mutate(meter = height / 100)

base_df <- df[sapply(df, is.numeric)]
base_df[1] <- base_df[1] / 100

get_data("regioner") %>%
  select(dagi_id, kode, navn, nuts2, visueltcenter_x, visueltcenter_y) %>%
  tinytable::tt()
