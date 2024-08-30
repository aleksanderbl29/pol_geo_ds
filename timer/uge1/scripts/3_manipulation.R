library("tidyverse")
library("readxl")

# variable og observationer --------------------------------------

# indlæsning af .csv data 
polls <- read_csv("data/polls_2020.csv")

# vælg observationer med filter()
polls |>                          # vælg kun YouGov-målinger
  filter(institut == "YouGov")

polls_YouGov <- polls |>          # opret nyt objekt med kun YouGov-målinger
  filter(institut == "YouGov")

polls |>                          # vælg YouGov-målinger, hvor Parti A har 30 eller derover - Kode 1
  filter(institut == "YouGov" & parti_a >= 30)

polls |>                          # vælg YouGov-målinger, hvor Parti A har 30 eller derover - Kode 2
  filter(institut == "YouGov") |>
  filter(parti_a >= 30)

polls |>                          # vælg YouGov-målinger, hvor Parti A har 30 eller derover - Kode 3
  filter(institut == "YouGov", parti_a >= 30)

# Øvelse --------------------------------------
# Brug filter til at vise alle observationer med mere end 1200 respondenter
# Tildel observationerne til et nyt objekt kaldet r1200

# enten ... eller - betingelse  
polls |> 
  filter(parti_a > 30 | parti_d > 4)

# anvendelse af funktion inden for filter()
polls |> 
  filter(parti_b > mean(parti_b))

# anvendelse af funktion inden for filter()
polls |> 
  filter(parti_k > mean(parti_k))

# anvendelse af funktion inden for filter()
polls |> 
  filter(parti_k > mean(parti_k, na.rm = T))

# if_any() og if_all()
polls |> 
  filter(if_any(c(parti_a, parti_b), ~ .x < 5))

polls |> 
  filter(if_all(c(parti_a, parti_b), ~ .x > 10))

# vælg observationer med slice()

polls |> 
  slice(1,3,20)

polls |> 
  slice(1:15)


# vælg variabler med select()
polls |>                          # vælg instituttets navn og dato-variabler
  select(institut, dato)

polls |>                          # vælg alle variabler undtagen parti_o
  select(-parti_o)

# kombiner filter() og select()
polls |>                          # vælg variabler og filtrer efter dato
  select(institut, dato, parti_a, respondenter) |> 
  filter(dato >= "2020-12-01" )

# starts_with(), ends_with(), contains()
polls |> 
  select(starts_with("parti_"))

polls |> 
  select(contains("parti_"))

# opret en ny variabel med mutate()
roedblok <- polls |> 
  mutate(roedblok = parti_a + parti_b + parti_f + parti_oe + parti_aa) 

roedblok <- polls |>                                                                  # placer den nye variabel i dataframen med before
  mutate(roedblok = parti_a + parti_b + parti_f + parti_oe + parti_aa, .before = 5) 

roedblok <- polls |>                                                                  # placer den nye variabel i dataframen med after
  mutate(roedblok = parti_a + parti_b + parti_f + parti_oe + parti_aa, .after = "dato") 

polls |> 
  mutate(ugedag = wday(dato, label = T)) |>
  View()

polls |> 
  mutate(voxmeter = ifelse(institut == "Voxmeter", 1, 0)) |>
  select(institut, dato, parti_a, voxmeter) |> 
  head(10)

polls |> 
  mutate(id = row_number())  |> 
  select(id, institut, dato, parti_a)

# omdøb en eksisterende variabel med rename()
polls |> 
  rename(socdem = parti_a, radikale = parti_b, date = dato) |> 
  slice(1:5)


# hele datasættet --------------------------------------

# indlæsning af .csv data 
polls <- read_csv("data/polls_2020.csv")

institute_n <- polls |>           # aggreger og tæl observationer pr. institut
  group_by(institut) |> 
  summarise(n_obs = n())

institute_n <- polls |>           # + første og sidste dato
  group_by(institut) |> 
  summarise(n = n(),
            dato_min = min(dato),
            dato_max = max(dato))

institute_n <- polls |>           # + gennemsnit af Parti A
  group_by(institut) |> 
  summarise(n = n(),
            dato_min = min(dato),
            dato_max = max(dato),
            parti_a = mean(parti_a))

# aggreger observationer i henhold til to variabler med group_by()
institute_n <- polls |>           
  mutate(quarter = quarter(dato)) |> 
  group_by(institut, quarter) |> 
  summarise(parti_a = mean(parti_a))


polls |>                          # aggreger efter institut og vis gennemsnittet for hvert parti
  group_by(institut) |> 
  summarise(across(starts_with("parti_"), mean))


polls |>                          # samme men fjern først NAs
  group_by(institut) |> 
  summarise(across(starts_with("parti_"), ~mean(., na.rm = TRUE)))

