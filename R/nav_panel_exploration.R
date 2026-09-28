#' Panneau principal d'exploration
#' @return Le panneau de vue d'ensemble.
#' @export
nav_panel_exploration <- function() {
  nav_panel("Explorer", value = "explorer", icon = bs_icon("grid-1x2"),
    div(class = "page-heading",
      div(
        p(class = "eyebrow", "LE CONTRAT D’INTÉGRATION RÉPUBLICAINE"),
        h1("Les parcours d’intégration,", tags$br(), span("en perspective.")),
        p(class = "page-description", "Explorez les profils des signataires et la diversité de leurs parcours en France.")
      ),
      div(class = "edition-badge", bs_icon("calendar3"), "Millésime ", textOutput("data_period", inline = TRUE))
    ),
    uiOutput("summary_cards", class = "metrics-grid"),
    div(class = "selection-row", uiOutput("selection_status"), uiOutput("active_filters")),
    card(class = "analysis-card", full_screen = TRUE,
      card_header(div(class = "section-heading",
        div(h2("Portrait des signataires"), p("Une lecture par profil, territoire et parcours.")),
        div(class = "chart-unit", span(class = "control-caption", "AFFICHAGE"), create_radio("highchart_stats_pct", "pct"))
      )),
      card_body(navset_tab(id = "explore_dimension",
        nav_panel("Nationalité", highchartOutput("highchart_stats_pays", height = "430px")),
        nav_panel("Sexe", highchartOutput("highchart_stats_sexe", height = "430px")),
        nav_panel("Âge", highchartOutput("highchart_stats_age", height = "430px")),
        nav_panel("Territoire", highchartOutput("highchart_stats_territoire", height = "430px")),
        nav_panel("Motif de séjour", highchartOutput("highchart_stats_motif", height = "430px")),
        nav_panel("Parcours", highchartOutput("highchart_stats_parcours", height = "430px"))
      )),
      card_footer(div(class = "chart-toolbar",
        div(class = "chart-kind", span("Visualisation"), create_radio("highchart_stats_type", "graph")),
        span(class = "chart-hint", bs_icon("cursor"), "Survolez le graphique pour voir le détail.")
      ))
    ),
    div(class = "reading-note",
      span(class = "note-icon", bs_icon("book")),
      div(h3("Des données pour comprendre"),
        p("Chaque observation correspond à une ligne du fichier source. Les pourcentages portent sur la population sélectionnée. Retrouvez les définitions et les limites de lecture dans l’onglet Comprendre.")),
      span(class = "note-year", "ÉDITION 2020")
    )
  )
}

nav_panel_compare <- function() {
  nav_panel("Comparer", value = "comparer", icon = bs_icon("bar-chart"),
    div(class = "page-heading compact-heading", div(
      p(class = "eyebrow", "CROISER LES REGARDS"), h1("Comparer les profils"),
      p(class = "page-description", "Choisissez des groupes et observez ce qui distingue leurs parcours.")
    )),
    card(class = "comparison-setup",
      card_body(div(class = "compare-controls",
        create_picker("variables_compare", "1. Choisir une dimension", multiple = FALSE, select_all = FALSE),
        create_picker("modalites_compare", "2. Sélectionner les groupes", placeholder = "Choisir des groupes"),
        div(class = "compare-unit", span(class = "control-caption", "3. AFFICHER"), create_radio("highchart_compare_pct", "pct"))
      )),
      card_footer(bs_icon("info-circle"), " En pourcentage, chaque groupe est ramené à 100 % pour comparer les profils indépendamment de leur taille.")
    ),
    card(class = "analysis-card", full_screen = TRUE,
      card_header(div(class = "section-heading", div(h2("Les groupes en regard"), p("Les filtres de la barre latérale restent appliqués.")))),
      card_body(navset_tab(id = "compare_dimension",
        nav_panel("Nationalité", highchartOutput("highchart_compare_pays", height = "480px")),
        nav_panel("Sexe", highchartOutput("highchart_compare_sexe", height = "480px")),
        nav_panel("Âge", highchartOutput("highchart_compare_age", height = "480px")),
        nav_panel("Territoire", highchartOutput("highchart_compare_territoire", height = "480px")),
        nav_panel("Motif de séjour", highchartOutput("highchart_compare_motif", height = "480px")),
        nav_panel("Parcours", highchartOutput("highchart_compare_parcours", height = "480px"))
      ))
    )
  )
}

nav_panel_data <- function() {
  nav_panel("Données", value = "donnees", icon = bs_icon("table"),
    div(class = "page-heading compact-heading",
      div(p(class = "eyebrow", "ALLER PLUS LOIN"), h1("Les données à la source"),
        p(class = "page-description", "Consultez les observations et téléchargez votre sélection pour prolonger l’analyse.")),
      downloadButton("downloadData", "Exporter en CSV", class = "btn-primary")
    ),
    card(class = "data-card", full_screen = TRUE,
      card_header(div(class = "section-heading", div(h2("Table des observations"), textOutput("data_caption")), span(class = "format-badge", "CSV · UTF-8"))),
      card_body(DTOutput("exploration_donnees_brutes")),
      card_footer("L’export contient toutes les lignes retenues par les filtres latéraux. La recherche dans le tableau affine uniquement l’affichage.")
    )
  )
}
