#' The application User-Interface
#' @param request Internal parameter for shiny.
#' @import shiny bslib highcharter bsicons arrow markdown
#' @importFrom DT DTOutput renderDT
#' @importFrom shinyWidgets pickerOptions pickerInput radioGroupButtons
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    page_navbar(
      title = div(class = "app-brand",
        span(class = "brand-mark", bs_icon("bar-chart-line-fill")),
        span(class = "brand-name", "CIR", span("Observatoire de l’intégration"))
      ),
      id = "main_nav", selected = "explorer",
      nav_panel_exploration(), nav_panel_compare(), nav_panel_data(),
      nav_menu_apropos(), nav_spacer(),
      nav_item(tags$a(class = "source-link", href = "https://www.data.gouv.fr/datasets/contrat-dintegration-republicaine",
        target = "_blank", rel = "noopener noreferrer", "Source des données", bs_icon("arrow-up-right"))),
      sidebar = sidebar(
        sidebar_exploration(), width = 284,
        open = list(desktop = "open", mobile = "closed"),
        title = "Affiner l’analyse", id = "filters_sidebar",
        class = "filters-sidebar", resizable = FALSE
      ),
      fillable = FALSE,
      theme = bs_theme(version = 5, bg = "#f4f7f6", fg = "#152d37",
        primary = "#147d73", secondary = "#65777e",
        base_font = "Marianne, system-ui, sans-serif",
        heading_font = "Marianne, system-ui, sans-serif",
        "border-radius" = "0.65rem", "btn-font-weight" = "600"),
      window_title = "CIR · Observatoire de l’intégration", lang = "fr",
      footer = tags$footer(class = "app-footer",
        span("CIR · Données publiques, regards croisés"),
        span("Une application de ", tags$a(href = "https://www.philippefontaine.eu", target = "_blank",
          rel = "noopener noreferrer", "Philippe Fontaine"),
          tags$a(href = "https://github.com/pds023/minintCIR", target = "_blank",
            rel = "noopener noreferrer", "Code source", class = "footer-code"))
      )
    )
  )
}

#' Add external resources to the application
#' @importFrom golem add_resource_path bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path("www", app_sys("app/www"))
  tags$head(
    tags$link(rel = "icon", href = "www/favicon.png", type = "image/png"),
    bundle_resources(path = app_sys("app/www"), app_title = "CIR · Observatoire de l’intégration")
  )
}
