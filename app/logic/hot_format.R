box::use(
  rhandsontable[...],
  stringr[str_sort, str_pad],
  app/logic/constant[building, trade, employee],
)

hot_format <- function(.data) {
  .data |>
    rhandsontable(rowHeaders = NULL, height = 700) |>
    hot_cols(
      col = names(.data),
      manualColumnResize = TRUE,
      allowInvalid = TRUE,
      copyable = TRUE,
      strict = FALSE,
      colWidths = c(80, 60, 250, 70, 350, 80,
                    rep(150, 7), 130, 130),
      renderer = "
             function (instance, td, row, col, prop, value, cellProperties) {
               Handsontable.renderers.NumericRenderer.apply(this, arguments);
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
    hot_validate_character(
      "Time",
      choices = 0:2400 |> str_pad(width = 4, pad = "0")
      )
}
