box::use(
  bslib[...],
  shiny[...],
  glue[...],
  rhandsontable[...],
  DBI[...],
  dm[...],
  dplyr[...],
  lubridate[...],
  shiny.fluent[...],
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
  img <- img(src = "static/images/CSO Colour Logo.jpg",
             style = "width: 200px")
  pr <- img(src = "static/images/pr-logo-words_no-line.jpg",
            style = "width: 400px; padding = 15px")
  # img2 <- img(src = "static/images/Special constable logo colour.jpg",
  #             style = "width: 100px")

  page(
    theme = bs_theme(primary = "orange"),
    tags$head(
      ## CSO favicon
      ## from www.realfavicongenerator.net
      HTML('<link rel="apple-touch-icon" sizes="180x180" href="apple-touch-icon.png">
            <link rel="icon" type="image/png" sizes="32x32" href="favicon-32x32.png">
            <link rel="icon" type="image/png" sizes="16x16" href="favicon-16x16.png">
            <link rel="manifest" href="site.webmanifest">
            <link rel="mask-icon" href="safari-pinned-tab.svg" color="#5bbad5">
            <meta name="msapplication-TileColor" content="#da532c">
            <meta name="theme-color" content="#ffffff">'),

      tags$style(HTML("
      .container {
        max-width: 2600px;
        display: grid;
        justify-items: center;
        justify-content: center;
      }

      .container > .handsontable {
        padding: 10px;
      }

      .container > .datepicker {
        padding: 15px;
        width: 175px;
      }

      .ms-TextField-wrapper {
        border-radius: 3px;
        box-shadow: 0px 0px 5px grey;
      }
                      ")
      )
    ),
    div(
      class = "container",
      img,
      pr,
      div(
        class = "datepicker",
        DatePicker.shinyInput(ns("date"), isMonthPickerVisible = FALSE)
        # dateInput(ns("date"), NULL, value = Sys.Date()),
        ),

      # div(class = "date",
      #     uiOutput(ns("text")),
      #     ),
      div(
        rHandsontableOutput(ns("hot")),
        class = "handsontable"
      ),
      # img2
    )
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
            Date = as.Date(input$date),
            Id = paste0(row_number(), " - ", Date)
          )
        ## Set current table for upserting
        dm_now <- dm(cso_maintenance = x)
        dm_now <- copy_dm_to(conn, dm_now, temporary = TRUE)
        ## Pull existing table
        dm_db <- dm_from_con(conn, "cso_maintenance")
        ## Upsert
        final <- dm_rows_upsert(dm_db, dm_now, in_place = TRUE)
        print("saved")
      }
    })

    df_init <- reactive({
        x <- read_table(pool) |>
          filter(Date == as.Date(input$date) |> as.character())
        if (nrow(x) == 0) {
          x <- x |>add_rows(3)
        }
        return(x |> select(- c(Date)))
    }) |>
      bindEvent(input$date)

    output$hot = renderRHandsontable({
      df_init() |> hot_format()
    })

    # output$text = renderUI({
    #   # Refresh the date every X hours in case app is left on?
    #   if (input$date == Sys.Date()) {
    #     value <- "Sheet is today's."
    #     value_style <- "date today"
    #   } else {
    #     value <- "Sheet is not today's."
    #     value_style <- "date not-today"
    #   }
    #   HTML(glue("<h4><span class = '{value_style}'>{value}</span></h4>"))
    # }) |>
    #   bindEvent(input$date)

  })
}
