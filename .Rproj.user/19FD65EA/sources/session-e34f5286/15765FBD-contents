box::use(
  shiny[...],
  app/view/table,
  rhandsontable[...],
  DBI[...],
  app/logic/constant[conn],
  app/logic/constant[DF],
  app/logic/hot_format[hot_format],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Grey columns are optional."),
    helpText("Grey columns are optional. Changes to the table will be automatically saved to the source file."),
    ## Uncomment line below to use action button to commit changes
    actionButton(ns("saveBtn"), "Submit"),
    rHandsontableOutput(ns("hot"))
  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observe({
      ## Remove button and isolate to update file automatically
      ## after each table change
      input$saveBtn
      hot = isolate(input$hot)
      if (!is.null(hot)) {
        dbWriteTable(conn, "mtcars", hot_to_r(input$hot), overwrite = TRUE)
        print("saved")
      }
    })

    output$hot = renderRHandsontable({
      if (!is.null(input$hot)) {
        DF = hot_to_r(input$hot)
      } else {
        DF = DF
      }

      DF |> hot_format()
    })
  })
}
