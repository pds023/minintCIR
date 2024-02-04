
#' Title
#'
#' @param variables
#'
#' @return
#' @export
#' @import  shinycssloaders
#' @examples
nav_panel_exploration <- function() {
  return(nav_panel("Exploration",icon = bs_icon("search"),
                   page_navbar(sidebar = uiOutput("sidebar_exploration"),
                               nav_panel("Vue d'ensemble",icon = bs_icon("clipboard2-data"),value = "panel_exploration_vue_densemble",
                                         card(full_screen = TRUE,fill = F,
                                           card_title(div(class = "card-title-container",
                                                          div(class = "title-tooltip","Éléments descriptif",
                                                              tooltip(
                                                                bs_icon("info-circle"),
                                                                "Nombre de CIR en niveau (#) et en part du total (%). Les filtres réalisés s'appliquent aux graphiques."
                                                              )),
                                                          div(class = "radio-group-buttons",
                                                              create_radio("highchart_stats_pct","pct")))),
                                           card_body(navset_card_underline(
                                                               nav_panel(title = "Pays de nationalité",
                                                                         withSpinner(highchartOutput("highchart_stats_pays"))),
                                                               nav_panel(title = "Sexe",
                                                                         withSpinner(highchartOutput("highchart_stats_sexe"))),
                                                               nav_panel(title = "Tranche d'âge",
                                                                         withSpinner(highchartOutput("highchart_stats_age"))),
                                                               nav_panel(title = "Territoire",
                                                                         withSpinner(highchartOutput("highchart_stats_territoire"))),
                                                               nav_panel(title = "Motif",
                                                                         withSpinner(highchartOutput("highchart_stats_motif"))),
                                                               nav_panel(title = "Parcours",
                                                                         withSpinner(highchartOutput("highchart_stats_parcours")))
                                           )),
                                           card_footer(create_radio("highchart_stats_type","graph")))
                               ),
                               nav_panel("Comparaisons",icon = bs_icon("graph-up"),
                                         card(full_screen = TRUE,fill = FALSE,
                                              card_title(div(class = "card-title-container",
                                                             div(class = "title-tooltip","Comparaisons",
                                                                 tooltip(
                                                                   bs_icon("info-circle"),
                                                                   "Comparaison d'un sous-ensemble de CIR en niveau (#) ou en part du total (%). Les filtres réalisés s'appliquent aux comparaisons."
                                                                 )),
                                                             div(class = "radio-group-buttons",
                                                                 create_radio("highchart_compare_pct","pct")))),
                                           card_body(
                                             layout_sidebar(
                                               fillable = TRUE,
                                               sidebar = sidebar(
                                                 create_picker(id = "variables_compare", label = "Variable à comparer",multiple = FALSE),
                                                 create_picker(id = "modalites_compare", label = "Modalitées")
                                               ),
                                               navset_card_underline(
                                                 nav_panel(title = "Pays de nationalité",
                                                           withSpinner(highchartOutput("highchart_compare_pays"))),
                                                 nav_panel(title = "Sexe",
                                                           withSpinner(highchartOutput("highchart_compare_sexe"))),
                                                 nav_panel(title = "Tranche d'âge",
                                                           withSpinner(highchartOutput("highchart_compare_age"))),
                                                 nav_panel(title = "Territoire",
                                                           withSpinner(highchartOutput("highchart_compare_territoire"))),
                                                 nav_panel(title = "Motif",
                                                           withSpinner(highchartOutput("highchart_compare_motif"))),
                                                 nav_panel(title = "Parcours",
                                                           withSpinner(highchartOutput("highchart_compare_parcours")))))
                                           )
                                         )),
                               nav_panel("Données brutes",icon = bs_icon("database"),
                                         card(full_screen = TRUE,fill = FALSE,min_height = "850px",
                                              card_title("Données brutes"),
                                              card_body(DTOutput("exploration_donnees_brutes")),
                                              card_footer(
                                                downloadButton(
                                                  "downloadData", "Télécharger",
                                                  class = "btn-primary rounded-0"
                                                ))))
                   )
  )
  )
}
