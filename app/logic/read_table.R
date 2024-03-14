box::use(
  DBI[dbConnect, dbReadTable, dbDisconnect],
  app/logic/constant[pool, conn],
  dplyr[...],
  lubridate[NA_Date_],
  stringr[...]
)

read_table <- function(pool) {
  dbReadTable(pool, "cso_maintenance") |>
    rename_with(
      \(x) str_replace_all(x, "\\.", " ") |> str_trim(),
      everything()
    ) |>
    rename("Work Order #" = "Work Order")
}
