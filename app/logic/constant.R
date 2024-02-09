box::use(
  DBI[dbConnect, dbReadTable, dbDisconnect],
  pool[dbPool, poolClose],
  shiny[onStop],
  RPostgres[Postgres],
  glue[glue],
  dplyr[...],
  dm[...],
  lubridate[NA_Date_],
  stringr[...],
  app/logic/add_rows[add_rows],
)

#' @export
conn <- dbConnect(
  RPostgres::Postgres(),
  dbname = "postgres",
  user = Sys.getenv("POSTGRES_USER"),
  host = "data.pr.uoguelph.ca",
  port = "5432",
  password = Sys.getenv("POSTGRES_PASS")
)

#' @export
pool <- dbPool(
  RPostgres::Postgres(),
  dbname = "postgres",
  user = Sys.getenv("POSTGRES_USER"),
  host = "data.pr.uoguelph.ca",
  port = "5432",
  password = Sys.getenv("POSTGRES_PASS")
)

onStop(function() {
  poolClose(pool)
})

#' @export
employee <- dbReadTable(pool, "employee") |>
  mutate(name = glue("{given_names} {surname}")) |>
  as.data.frame()
#' @export
trade <- dbReadTable(pool, "trade") |>
  mutate(trade = glue("{trade} - {trade_desc}")) |>
  distinct(trade, .keep_all = T)

#' @export
building <- dbReadTable(pool, "workorder_building") |>
  mutate(building = glue("{building_number} - {building_name}"))

trade_factor <- factor(NA_character_, levels = str_sort(trade$trade))
staff_factor <- factor(NA_character_, levels = str_sort(unique(employee$name)))

#' @export
DFF <- tibble(
  hour = NA_integer_,
  minute = NA_integer_,
  am_pm = factor(NA_character_, levels = c("am", "pm")),
  date = NA_Date_,
  "Work Order #" = NA_integer_,
  building = NA_character_,
  # building = factor(NA_character_, levels = str_sort(building$building)),
  room = NA_integer_,
  issue = NA_character_,
  reporter = NA_character_,
  trade_responsible = NA_character_,
  trade_attended_1  = NA_character_,
  trade_attended_2  = NA_character_,
  staff_called_1    = NA_character_,
  staff_attended_1  = NA_character_,
  staff_called_2    = NA_character_,
  staff_attended_2  = NA_character_,
  contractor_1 = NA_character_,
  contractor_2 = NA_character_,
  id = 1
  ) |>
  relocate(trade_attended_2, .after = staff_attended_1) |>
  rename_with(\(x) x |> str_replace_all("_", " ") |> str_to_title()) |>
  rename("am/pm" = "Am Pm") |>
  add_rows(2)

#' @export
DF <- dbReadTable(pool, "police_maintenance") |>
  rename_with(
    \(x) str_replace_all(x, "\\.", " ") |> str_trim(),
    everything()
  ) |>
  rename("am/pm" = "am pm", "Work Order #" = "Work Order")


DF <- dbReadTable(conn, "police_maintenance") |>
  rename_with(
    \(x) str_replace_all(x, "\\.", " ") |> str_trim(),
    everything()
  ) |>
  rename("am/pm" = "am pm", "Work Order #" = "Work Order")

#' @export
current <- function() {
  dm <- dm_from_con(conn, "police_maintenance")
  # dbDisconnect(conn)
  return(dm)
}
