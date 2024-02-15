#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @import shiny.telemetry
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(launch.browser = TRUE),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  telemetry <<- Telemetry$new(app_name = "(minintCIR)",
                               data_storage = DataStorageSQLite$new(db_path = file.path("telemetry.sqlite")))
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}
