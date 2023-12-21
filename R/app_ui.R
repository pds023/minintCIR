#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib highcharter
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_fluid(
      h1("minintCIR"),
      navset_card_underline(height = "600px",title = "Éléments descriptifs",
                            nav_panel(title = "Pays de nationalité",
                                      highchartOutput("highchart_stats_pays")),
                            nav_panel(title = "Tranche d'âge",
                                      highchartOutput("highchart_stats_age")),
                            nav_panel(title = "Territoire",
                                      highchartOutput("highchart_stats_territoire")),
                            nav_panel(title = "Motif",
                                      highchartOutput("highchart_stats_motif")),
                            nav_panel(title = "Parcours",
                                      highchartOutput("highchart_stats_parcours")))
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "minintCIR"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
