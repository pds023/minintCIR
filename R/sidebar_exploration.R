#' Barre latérale de filtres pour l'exploration
#' @return Les contrôles de filtre de l'application.
#' @export
sidebar_exploration <- function() {
  tagList(
    div(class = "sidebar-intro", "Définissez votre population pour explorer les données."),
    uiOutput("filter_summary"),
    tags$details(class = "filter-group", open = "open",
      tags$summary(bs_icon("person"), "Profil des signataires"),
      create_picker("exploration_filter_sexe", "Sexe"),
      create_picker("exploration_filter_pays", "Nationalité"),
      create_picker("exploration_filter_age", "Tranche d’âge")
    ),
    tags$details(class = "filter-group",
      tags$summary(bs_icon("geo-alt"), "Territoire"),
      create_picker("exploration_filter_region", "Région"),
      create_picker("exploration_filter_departement", "Département")
    ),
    tags$details(class = "filter-group",
      tags$summary(bs_icon("signpost-split"), "Motif et parcours"),
      create_picker("exploration_filter_motif_agreg", "Motif de séjour"),
      create_picker("exploration_filter_motif_det", "Motif détaillé"),
      create_picker("exploration_filter_parcours", "Parcours linguistique")
    ),
    div(class = "filter-actions",
      actionButton("exploration_filters_apply", "Appliquer les filtres", icon = icon("check"), class = "btn-primary", width = "100%"),
      actionButton("exploration_filters_reset", "Tout réinitialiser", icon = icon("arrow-rotate-left"), class = "btn-reset", width = "100%")
    ),
    div(class = "sidebar-note", bs_icon("info-circle"),
      p("Sans sélection, toutes les valeurs sont incluses. Les filtres s’appliquent aux graphiques, aux comparaisons et à l’export.")),
    div(class = "sidebar-source", span(class = "status-dot"), "Jeu de données embarqué", tags$small("Source : ministère de l’Intérieur · 2020"))
  )
}
