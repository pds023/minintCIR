
#' Title
#'
#' @param variables
#'
#' @return
#' @export
#'
#' @examples
nav_panel_exploration <- function() {
  return(nav_panel("Exploration",icon = bs_icon("search"),
                   page_navbar(id = "dataPanel_exploration",
                               nav_panel("Vue d'ensemble",icon = bs_icon("clipboard2-data"),value = "panel_exploration_vue_densemble",
                                         card(fluidRow(
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Nombre de CIR",
                                             value = textOutput("exploration_nb_cir"),
                                             max_height = "90px"
                                           )),
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Nationalité",
                                             value = textOutput("exploration_nb_pays"),
                                             max_height = "90px"
                                           )),
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Âge",
                                             value = textOutput("exploration_nb_age"),
                                             max_height = "90px"
                                           )),
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Région",
                                             value = textOutput("exploration_nb_region"),
                                             max_height = "90px"
                                           )),
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Département",
                                             value = textOutput("exploration_nb_departement"),
                                             max_height = "90px"
                                           )),
                                           column(width = 2, md = 4,
                                           value_box(
                                             title = "Motif",
                                             value = textOutput("exploration_nb_motif"),
                                             max_height = "90px"
                                           )))
                                         ),
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
                                                                         highchartOutput("highchart_stats_parcours")))),
                               nav_panel("Éléments détaillés",icon = bs_icon("table")),
                               nav_panel("Statistiques",icon = bs_icon("pie-chart")),
                               nav_panel("Données brutes",icon = bs_icon("database")),
                   )
  )
  )
}
