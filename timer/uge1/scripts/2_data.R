library("readr")  
library("readxl")
library("writexl")
library("haven")
library("foreign")

# indlæsning af .csv data --------------------------------------
polls <- read_csv("data/polls_2020.csv")

# Funktionen spec() bruges til at hente kolonnespecifikationen for en data frame, der er læst ind
spec(polls) # col_double() betyder at en bestemt kolonne behandles som numerisk data

# summary() giver et kortfattet statistisk resumé af de objekter, der er givet til funktionen
summary(polls)

# indlæsning af .xlsx data - Øvelse --------------------------------------
# Indlæs folketingsvalg.xlsx datasættet ved at bruge read_xlsx() funktionen.
# Tildel navnet fv til datasættet
fv <- read_xlsx("data/folketingsvalg.xlsx")

# Hvis du åbner datasættet i Excel, vil du bemærke, at det har et andet ark kaldet seats. 
# For at indlæse dette andet ark kan du bruge

fv_seats <- read_xlsx("data/folketingsvalg.xlsx", sheet = "seats")

# indlæsning af polls data som .txt fil  --------------------------------------
polls_txt <- read.table("data/polls_2020.txt")
polls_txt <- read.table("data/polls_2020.txt", sep = ",", header = TRUE)

# indlæsning af .sav (dvs. SPSS) data --------------------------------------
ess1 <- read_spss("data/ess_9.sav") # med haven()
ess2 <- read.spss("data/ess_9.sav") # med foreign
ess2 <- read.spss("data/ess_9.sav", to.data.frame = TRUE) # Når du læser en SPSS-fil ved hjælp af read.spss-funktionen fra foreign-pakken i R, læses dataene ind i en liste-struktur som standard. For at konvertere denne liste til en data frame, kan du bruge as.data.frame() funktionen.

# gemmer EES data som .csv fil  --------------------------------------
write_csv(ess1, "data/ess.csv")
ess_csv <- read_csv("data/ess.csv") # indlæs den nygemte datafil

# gemmer EES data som .xlsx fil  --------------------------------------
write_csv(ess1, "data/ess.xlsx")

# gemmer seats data som .dta fil  --------------------------------------
write_dta(fv_seats, "data/polls.dta")
