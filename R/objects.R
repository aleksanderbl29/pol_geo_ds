get_n_cells <- function(type, df) {
  sum <- df |>
    count(vindmll)

  if (type == "non-vind") {
    sum$n[[1]] |> vec_fmt_number(decimals = 0, locale = "da")
  } else if (type == "vind") {
    sum$n[[length(sum$n)]] |> vec_fmt_number(decimals = 0, locale = "da")
  }
}
