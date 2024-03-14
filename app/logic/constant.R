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

