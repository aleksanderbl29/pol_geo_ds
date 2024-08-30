
x > 3 # simpel logisk test

# funktioner --------------------------------------
sum()     # Summen af elementer.
mean()    # Gennemsnittet af elementer.
median()  # Medianen af elementer.
min()     # Mindste værdi.
max()     # Største værdi.
c()       # Kombiner værdier til en vektor En vektor en grundlæggende datastruktur, der indeholder en sekvens af elementer af samme type. Vektorer er endimensionelle, hvilket betyder, at de har én dimension eller længde. Der findes flere typer af vektorer i R, baseret på den type data, de indeholder.

c(1,2,3,4,5) # opretter en vektor, der inkluderer værdierne 1,2,3,4,5.

mean(c(1,2,3,4,5)) # denne funktion beregner gennemsnittet af vektoren inkl. værdierne 1,2,3,4,5.
min(c(1,2,3,4,5))  # denne funktion identificerer minimumsværdien i vektoren inkl. værdierne 1,2,3,4,5.
max(c(1,2,3,4,5))  # denne funktion identificerer maksimumsværdien i vektoren inkl. værdierne 1,2,3,4,5.

mean(1,2,3,4,5) # ups! vi glemte at kombinere værdierne, og R tager kun højde for den første værdi.

?mean # kalder hjælp

# objekter  --------------------------------------
x <- 2

values <- c(1.5,2.5,3,4.2,5.9) # Numerisk: Bruges til kontinuerlige numeriske værdier som reelle tal eller hele tal.
is.numeric(values) # simpel logisk test

sum(values)
mean(values)
min(values)
max(values)

text <- c(
  "Dette er noget tekst." ,
  "Dette er noget andet tekst!",
  "kort tekst.",
  "Blaaaahhh28392eriadjai!!!!!!",
  "Dette er ny tekst."
) # Tekst eller string data.

?data.frame
myfirstdataframe <- data.frame(text, values)
View(myfirstdataframe)

?nchar
myfirstdataframe$nchar <-  nchar(myfirstdataframe$text) # adgang til en af variablerne og tæller antallet af tegn

nchar <- nchar(myfirstdataframe$text)

myfirstdataframe$gender <- factor(c("male", "female", "female", "male", "male")) # Kategoriske data med faste mulige værdier.

names(myfirstdataframe)

# pakker  --------------------------------------
install.packages("ggplot2") # installerer pakken
library("ggplot2") # indlæser pakken
?ggplot2 # lær mere om pakken

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy))

data()

# dplyr/pipe operator  --------------------------------------
install.packages("dplyr")
library(dplyr)
?dplyr # lær mere om pakken
browseVignettes(package = "dplyr")


# Hypotetisk data frame
data <- data.frame(
  x = sample(0:10, 50, replace = TRUE),
  y = rnorm(10)
)

# Uden pipe-operatoren
result1 <- summarise(group_by(filter(data, x > 5), x), mean_y = mean(y))

# Med pipe-operatoren
result2 <- data |> 
  filter(x > 5) |> 
  group_by(x) |> 
  summarise(mean_y = mean(y))

# Print resultatet
print(result)


