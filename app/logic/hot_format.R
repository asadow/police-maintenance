box::use(
  rhandsontable[...],
  stringr[str_sort],
  app/logic/constant[building, trade, employee],
)

hot_format <- function(.data) {
  .data |>
    rhandsontable(rowHeaders = NULL, width = 3000, height = 700) |>
    hot_cols(
      col = names(.data),
      manualColumnResize = TRUE,
      allowInvalid = TRUE,
      copyable = TRUE,
      strict = FALSE,
      colWidths = c(50, 70, 75, 100, 75, 250, 70, 200, 100,
                    rep(200, 7), 130, 130),
      renderer = "
             function (instance, td, row, col, prop, value, cellProperties) {
               Handsontable.renderers.NumericRenderer.apply(this, arguments);
               if ([4, 7, 8, 9, 16, 17].includes(col)) {
                td.style.background = 'lightgrey';
               }
             }",
      halign = "htCenter"
    ) |>
    hot_col("Issue", halign = "htLeft") |>
    hot_col(
      col = c(
        "Trade Responsible",
        "Trade Attended 1", "Trade Attended 2",
        "Staff Attended 1", "Staff Attended 2"),
      type = "dropdown", source = str_sort(trade$trade)
    ) |>
  #   ,
  # "Staff Called 1", "Staff Called 2"
    hot_col("Building", type = "dropdown", source = str_sort(building$building)) |>
    hot_table(highlightCol = TRUE, highlightRow = TRUE) |>
    hot_validate_numeric(cols = "Work Order #", min = 100000, max = 999999) |>
    hot_validate_numeric(cols = "Hour", min = 0, max = 12) |>
    hot_validate_numeric(cols = "Minute", min = 0, max = 60)
}
