box::use(
  shiny[...],
  rhandsontable[...],
  DBI[...],
  dm[...],
  dplyr[...],
  lubridate[...],
  shinylogs[track_usage, store_json],
  tibble[column_to_rownames, rownames_to_column],
  app/logic/add_rows[add_rows],
  app/logic/constant[pool, conn],
  app/logic/hot_format[hot_format],
  app/logic/read_table[read_table],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Grey columns are optional."),
    helpText("Right click to undo. Grey columns are optional. Changes to the table will be automatically saved to the source file."),
    dateInput(ns("date"), "Date", value = Sys.Date()),
    # numericInput(ns("minute"), "Minute", value = 2),
    rHandsontableOutput(ns("hot")),
  )
}

#' @export
server <- function(id) {
  track_usage(storage_mode = store_json(path = "logs/"))

  moduleServer(id, function(input, output, session) {

    observe({
      if (!is.null(input$hot)) {
        x <- input$hot |> hot_to_r()
        x <- x |>
          mutate(
            Date = input$date,
            Id = paste0(row_number(), " - ", Date)
          )
        dm <- dm(police_maintenance = x)
        dm <- copy_dm_to(conn, dm, temporary = TRUE)
        dm_db <- dm_from_con(conn, "police_maintenance")
        final <- dm_rows_upsert(dm_db, dm, in_place = TRUE)
        print("saved")
      }
    })

    df_init <- reactive({
        x <- read_table(pool) |>
          filter(Date == input$date |> as.character())
        if (nrow(x) == 0) {
          x <- x |>add_rows(3)
        }
        return(x |> select(- c(Date, Id)))
    }) |>
      bindEvent(input$date)

    output$hot = renderRHandsontable({
      df_init() |> hot_format()
    })
  })
}
