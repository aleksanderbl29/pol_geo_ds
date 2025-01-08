
c <- list()

c["text"] <- 31512
c["bands_plot"] <- (
  4 #bånd-id
    + (3 * 5) #Bølgelængde på x akse
    + nchar("Bølgelængde (nm)")
)
c["data_selection_plot"] <- (
  nchar("32VMH") + # Pil
    (3 * 3) + # 200-600
    1 # 0
)
c["ridgeplot"] <- (
  nchar("Logistisk regression") +
    nchar("Random forest") +
    nchar("Convolutional neural network") +
    nchar("Distance (m)") +
    nchar("0110100100010000")
)

sum(unlist(c))

cat("Du har", sum(unlist(c)) - c$text, "tegn i figurer\nOg", sum(unlist(c)), "tegn i alt")
