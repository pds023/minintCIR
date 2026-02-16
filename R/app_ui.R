#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib highcharter bsicons waiter sever shinyWidgets arrow markdown DT aws.s3
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    page_fluid(
      theme = bs_theme(),
      use_telemetry(),
      useSever(),
      useWaiter(),
      autoWaiter(html = spin_dots(), color = "#FFF"),
      waiterPreloader(
        color = "#000",
        html = tagList(
          spin_dots(),
          div(class = "my-custom-space", h4("Chargement, veuillez patienter..."))
        )
      ),
      includeCSS("inst/app/www/styles.css"),
      tags$head(
        HTML('<link rel="icon" href="www/logoapp.png" type="image/png" />')
      ),
      page_navbar(
        title = "ShinyCIR",
        nav_panel_exploration(),
        nav_menu_apropos(),
        nav_spacer(),
        nav_item(actionButton(inputId = "suggestions", label = "Une suggestion ?")),
        nav_item(tags$a(shiny::icon("github"), "minintCIR", href = "https://github.com/pds023/minintCIR", target = "_blank")),
        nav_item(tags$a(shiny::icon("linkedin"), "philippe-fontaine-ds", href = "https://www.linkedin.com/in/philippe-fontaine-ds/", target = "_blank")),
        nav_item(input_dark_mode(mode = "light")),
        footer = tags$div(
          class = "footer",
          "Developpe par ",
          tags$a(href = "https://www.philippefontaine.eu", target = "_blank", "Philippe Fontaine")
        )
      )
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
    favicon(ext = "png"),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Analyse CIR"
    )
  )
}
