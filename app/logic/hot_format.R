box::use(
  rhandsontable[...],
  dplyr[...],
  tidyr[...],
  glue[glue],
  stringr[str_sort, str_pad],
  app/logic/constant[building, trade, employee],
)

valid_times <- tibble(hour = 0:23) |>
  expand_grid(minute = 0:59) |>
  mutate(
    across(c(hour, minute), \(x) str_pad(x, 2, side = "left", pad = "0")),
    time = glue("{hour}{minute}")
  ) |>
  pull(time) |>
  as.character()

hot_format <- function(.data) {
  .data |>
    rhandsontable(rowHeaders = NULL, height = 2000) |>
    hot_cols(
      col = names(.data),
      manualColumnResize = TRUE,
      allowInvalid = TRUE,
      copyable = TRUE,
      strict = FALSE,
      colWidths = c(80, 70, 250, 70, 350, 80, rep(150, 7), 130, 130),
      renderer = "
             function (instance, td, row, col, prop, value, cellProperties) {
               Handsontable.renderers.TextRenderer.apply(this, arguments);
               if ([11, 12, 13, 14].includes(col)) {
                td.style.background = 'lightgrey';
               }
             }",
      halign = "htCenter"
    ) |>
    hot_col("Issue", halign = "htLeft") |>
    hot_col(
      col = c("Trade Responsible", "Trade Attended 1", "Trade Attended 2"),
      type = "dropdown", source = str_sort(trade$trade)
    ) |>
    hot_col(
      col = c("Staff Attended 1", "Staff Attended 2",
              "Staff Called 1", "Staff Called 2"),
      type = "dropdown", source = str_sort(employee$name)
    ) |>
    hot_col(
      "Building",
      type = "dropdown",
      source = str_sort(building$building)
      ) |>
    hot_table(highlightCol = TRUE, highlightRow = TRUE) |>
    hot_validate_numeric("Work Order #", min = 100000, max = 999999) |>
    ## Open issue; if column does not exist, not a good error
    ## Error in [[: attempt to select less than one element in get1index
    hot_validate_character("Time", choices = valid_times)
}
