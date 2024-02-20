box::use(
  bslib[...],
  shiny[...],
  glue[...],
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
  # fluidPage(
    # titlePanel("Police Maintenance Sheet"),
    # helpText("Changes automatically save. Grey columns are optional."),
    # dateInput(ns("date"), "Date", value = Sys.Date()),
    # numericInput(ns("minute"), "Minute", value = 2),
    # rHandsontableOutput(ns("hot")),
  # )
  img <- img(src = "static/images/CSO Colour Logo.jpg", style = "width: 100px")
  # img2 <- img(src = "static/images/Special constable logo colour.jpg", style = "width: 100px")

  page(
    theme = bs_theme(primary = "orange"),
    tags$head(
      ## Roboto font (UG Brand)
      HTML('<link rel="preconnect" href="https://fonts.googleapis.com">
            <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
            <link href="https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap" rel="stylesheet">'),
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
      #result {
        display: grid;
        grid-template-columns: repeat(5, 50px);
        gap: 5px;
        padding: 15px;
        justify-content: center;
      }

                      "
      )
      )
    ),
    div(
      class = "bg-light my-5 py-3",
      div(
        div(class = "container",
            div(class = "row",
                div(class = "col-12",
                    img)),
            div(class = "row",
                div(class = "col-12",
                    dateInput(ns("date"), "Date", value = Sys.Date()))
                ),
            div(class = "row",
                div(class = "col-12",
                    uiOutput(ns("text")))
                ),
            div(class = "row",
                div(class = "col-12",
                    rHandsontableOutput(ns("hot"))
                ),
            ),
          ),
        )
      )
    )
    #   div(
    #     class = "container",
    #     h4("Police Maintenance Sheet"),
    #     helpText("Changes automatically save. Grey columns are optional."),
    #     dateInput(ns("date"), "Date", value = Sys.Date())
    #   )
    # ),
    # div(
    #   rHandsontableOutput(ns("hot")),
    #   style = "padding: 10px"
    #   ),
    # br(),
    # tags$style("#grid {
    #                   display: grid;
    #                   grid-template-columns: 100px 1fr;
    #                   grid-gap: 300px;
    #                   }"),
    # tags$style("#grid1 {
    #                   display: grid;
    #                   grid-template-columns: 1fr;
    #                   }"),
    # tags$style(".container {
    #   display: flex;
    #   flex-direction: row;
    #   text-align: center;
    #   padding: 50px
    # }"),
    # tags$style(".container1 {
    #   display: flex;
    #   flex-direction: row;
    #   text-align: center;
    #   padding: 50px
    # }"),
  # )

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

    output$text = renderUI({
      # Refresh the date every X hours in case app is left on?
      if (input$date == Sys.Date()) {
        value <- "Date is today."
        value_style <- "today"
      } else {
        value <- "Date is not today."
        value_style <- "not-today"
      }
      HTML(glue("<h4><span class = '{value_style}'>{value}</span></h4>"))
    })

  })
}
