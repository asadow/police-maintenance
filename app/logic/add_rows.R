box::use(
  tibble[add_row]
)

add_rows <- function(df, n) {
  for (i in 1:n) {
    df <- df |> add_row()
  }
  df
}
