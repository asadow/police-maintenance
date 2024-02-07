#' # app/view/table.R
#'
#' box::use(
#'   rhandsontable[...],
#'   DBI[...],
#'   shiny[h3, moduleServer, NS, tagList],
#' )
#'
#' con <- DBI::dbConnect(
#'   RPostgres::Postgres(),
#'   dbname = "postgres",
#'   user = Sys.getenv("POSTGRES_USER"),
#'   host = "data.pr.uoguelph.ca",
#'   port = "5432",
#'   password = Sys.getenv("POSTGRES_PASS"),
#' )
#'
#' #' @export
#' ui <- function(id) {
#'   ns <- NS(id)
#'   tagList(
#'     h3("Grey columns are optional. Work Order # must be 6 numbers long."),
#'     rHandsontableOutput(ns("hot"))
#'   )
#' }
#'
#' #' @export
#' server <- function(id) {
#'   moduleServer(id, function(input, output, session) {
#'     output$hot = renderRHandsontable({
#'       if (!is.null(input$hot)) {
#'         DF = hot_to_r(input$hot)
#'       } else {
#'         DF = DBI$dbReadTable(conn, "mtcars")
#'       }
#'
#'       rhandsontable(DF) |>
#'         hot_table(highlightCol = TRUE, highlightRow = TRUE)
#'     })
#'   })
#' }
