box::use(
  DBI[dbReadTable],
  tidyverse[...]
)

library(tidyverse)
library(tibble)
library(rhandsontable)
library(stringr)
library(glue)

employee <- dbReadTable(conn, "employee") |>
  mutate(name = glue("{given_names} {surname}")) |>
  as.data.frame()

trade <- dbReadTable(conn, "trade") |>
  mutate(trade = glue("{trade_code} - {trade_description}")) |>
  distinct(trade, .keep_all = T)

building <- dbReadTable(conn, "workorder_building") |>
  mutate(building = glue("{building_number} - {building_name}"))

trade_factor <- factor(NA_character_, levels = str_sort(trade$trade))
staff_factor <- factor(NA_character_, levels = str_sort(unique(employee$name)))

DF <- tibble(
  hour = NA_integer_,
  minute = NA_integer_,
  am_pm = factor(NA_character_, levels = c("am", "pm")),
  date = NA_Date_,
  "Work Order #" = NA_integer_,
  building = factor(NA_character_, levels = str_sort(building$building)),
  room = NA_integer_,
  issue = NA_character_,
  reporter = NA_character_,
  trade_responsible = trade_factor,
  trade_attended_1  = trade_factor,
  trade_attended_2  = trade_factor,
  staff_called_1    = staff_factor,
  staff_attended_1  = staff_factor,
  staff_called_2    = staff_factor,
  staff_attended_2  = staff_factor,
  contractor_1 = NA_character_,
  contractor_2 = NA_character_
  ) |>
  relocate(trade_attended_2, .after = staff_attended_1) |>
  rename_with(\(x) x |> str_replace_all("_", " ") |> str_to_title()) |>
  rename("am/pm" = "Am Pm") |>
  add_rows(3)
