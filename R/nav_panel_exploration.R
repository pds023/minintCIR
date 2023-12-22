
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
                               sidebar = uiOutput("sidebar_exploration"),
                               nav_panel("Vue d'ensemble",icon = bs_icon("clipboard2-data"),value = "panel_exploration_vue_densemble",
                                         navset_card_underline(height = "600px",title = "Éléments descriptifs",
                                                               nav_panel(title = "Pays de nationalité",
                                                                         highchartOutput("highchart_stats_pays"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_pays_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_pays_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )),
                                                               nav_panel(title = "Sexe",
                                                                         highchartOutput("highchart_stats_sexe"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_sexe_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_sexe_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )),
                                                               nav_panel(title = "Tranche d'âge",
                                                                         highchartOutput("highchart_stats_age"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_age_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_age_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )),
                                                               nav_panel(title = "Territoire",
                                                                         highchartOutput("highchart_stats_territoire"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_territoire_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_territoire_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )),
                                                               nav_panel(title = "Motif",
                                                                         highchartOutput("highchart_stats_motif"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_motif_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_motif_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )),
                                                               nav_panel(title = "Parcours",
                                                                         highchartOutput("highchart_stats_parcours"),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_parcours_switch",
                                                                           onLabel = "Bars",
                                                                           offLabel = "Treemap",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         ),
                                                                         switchInput(
                                                                           inputId = "highchart_stats_parcours_pct",
                                                                           onLabel = "N",
                                                                           offLabel = "%",
                                                                           value = TRUE,
                                                                           size = "mini"
                                                                         )))),
                               nav_panel("Comparaisons",icon = bs_icon("graph-up"),
                                         card(
                                           card_header("Comparaisons"),
                                           layout_sidebar(
                                             fillable = TRUE,
                                             sidebar = sidebar(
                                               pickerInput(inputId = "variables_compare",
                                                           label = "Variable à comparer",
                                                           choices = c(""),
                                                           options = list(
                                                             `live-search` = TRUE,
                                                             `container` = 'body')),
                                               pickerInput(inputId = "modalites_compare",
                                                           label = "Modalitées",
                                                           choices = c(),
                                                           options = list(
                                                             `live-search` = TRUE,
                                                             `dropupAuto` = FALSE,
                                                             `container` = 'body'),
                                                           multiple = TRUE)
                                             ),
                                             navset_card_underline(
                                                                   nav_panel(title = "Pays de nationalité",
                                                                             highchartOutput("highchart_compare_pays"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_pays_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )),
                                                                   nav_panel(title = "Sexe",
                                                                             highchartOutput("highchart_compare_sexe"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_sexe_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )),
                                                                   nav_panel(title = "Tranche d'âge",
                                                                             highchartOutput("highchart_compare_age"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_age_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )),
                                                                   nav_panel(title = "Territoire",
                                                                             highchartOutput("highchart_compare_territoire"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_territoire_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )),
                                                                   nav_panel(title = "Motif",
                                                                             highchartOutput("highchart_compare_motif"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_motif_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )),
                                                                   nav_panel(title = "Parcours",
                                                                             highchartOutput("highchart_compare_parcours"),
                                                                             switchInput(
                                                                               inputId = "highchart_compare_parcours_pct",
                                                                               onLabel = "N",
                                                                               offLabel = "%",
                                                                               value = TRUE,
                                                                               size = "mini"
                                                                             )))
                                           )
                                         )),
                               nav_panel("Données brutes",icon = bs_icon("database"),
                                         card(card_header("Données brutes"),
                                              card_body(DTOutput("exploration_donnees_brutes"),
                                                        downloadButton(
                                                          "downloadData", "Télécharger",
                                                          class = "btn-primary rounded-0"
                                                        )))),
                   )
  )
  )
}
