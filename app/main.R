box::use(
  shiny[...],
  app/view/table,
  rhandsontable[...],
  DBI[...],
  dm[...],
  dplyr[...],
  lubridate[...],
  stringr[...],
  app/logic/add_rows[add_rows],
  app/logic/constant[pool, conn, current],
  # app/logic/constant[DF],
  app/logic/hot_format[hot_format],
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    titlePanel("Grey columns are optional."),
    helpText("Right click to undo. Grey columns are optional. Changes to the table will be automatically saved to the source file."),
    ## Uncomment line below to use action button to commit changes
    actionButton(ns("saveBtn"), "Save"),
    dateInput(ns("date"), "Date"),
    numericInput(ns("minute"), "Minute", value = 2),
    rHandsontableOutput(ns("hot")),
  )
}

DF_read <- function() {
  dbReadTable(conn, "police_maintenance") |>
    rename_with(
      \(x) str_replace_all(x, "\\.", " ") |> str_trim(),
      everything()
    ) |>
    rename("am/pm" = "am pm", "Work Order #" = "Work Order")

  # dbDisconnect(conn)
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observe({
      ## Remove button and isolate to update file automatically
      ## after each table change
      # input$saveBtn
      # hot = isolate(input$hot)
      if (!is.null(input$hot)) {
      # if (!is.null(hot)) {

        updated <- dm(police_maintenance = hot_to_r(input$hot))
        updated <- copy_dm_to(conn, updated, temporary = TRUE)
        final <- dm_rows_upsert(current(), updated, in_place = TRUE)
        print("saved")
        # dbDisconnect(conn)

      }
    })

    hott <- reactive({
      # if (!is.null(input$hot)) {
      #   x <- hot_to_r(input$hot) |>
      #     filter(Minute == input$minute)
      #   if (nrow(x) == 0) {
      #     x <- x |>
      #       add_rows(3) |>
      #       mutate(Minute = input$minute)
      #   }
      #   return(x |> mutate(Id = today() |> as.integer() + row_number()+ Minute))
      #
      # } else {
        ## INITIATLIZE
        x <- DF_read() |>
          filter(Minute == input$minute)
        if (nrow(x) == 0) {
          x <- x |>
            add_rows(3) |>
            mutate(Minute = input$minute,
                   Id = today() |> as.integer() + row_number()+ Minute)
        }
        return(x)
      # }
      # return(x)
    }) |>
      bindEvent(input$minute)

    output$hot = renderRHandsontable({
      # if (!is.null(hott())) {
        hott() |> hot_format()
      # }
    })
  })
}
