check_dims <- function(rast, truth) {
  if (ext(unwrap(rast)) != ext(unwrap(truth))) {
    stop("Rasters har ikke samme dimensioner")
  }
}
