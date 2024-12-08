merge_data <- function(df, truth) {
  df$vindmll <- truth$Vindmølle_b02
  return(df)
}
