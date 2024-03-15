box::use(
  DBI[...],
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
  mutate(
    name = gsub("\\b(\\w)([\\w]+)", "\\1\\L\\2", name, perl = TRUE)
    ) |>
  filter(status == "ACTIVE") |>
  as.data.frame()

#' @export
trade <- dbReadTable(pool, "trade") |>
  mutate(trade = glue("{trade_desc}") |> str_to_title()) |>
  distinct(trade, .keep_all = T)

#' @export
building <- dbReadTable(pool, "building") |>
  mutate(building = glue("{building_id} - {building_name}"))

#' @export
cso_maintenance <- tibble(
  time = NA_character_,
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
  id = "1"
) |>
  relocate(trade_attended_2, .after = staff_attended_1) |>
  rename_with(\(x) x |> str_replace_all("_", " ") |> str_to_title())

if (!"cso_maintenance" %in% dbListTables(conn)) {
  dm_now <- dm(cso_maintenance = cso_maintenance) |>
    dm_add_pk(cso_maintenance, Id)
  copy_dm_to(conn, dm_now, temporary = FALSE)
}

