#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny bslib highcharter bsicons shinyWidgets arrow markdown DT shinyRatings aws.s3
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    page_fluid(
      theme =  bs_theme(),
      list(tags$head(HTML('<link rel="icon", href="www/logoapp.png",
                                   type="image/png" />')),
           tags$head(
             tags$style(HTML("
            @font-face {
                font-family: 'Marianne';
                src: url('www/Marianne-Regular.woff') format('woff');
            }
            body {
                font-family: 'Marianne', sans-serif;
            }
        "))
           ),
        tags$head(
          tags$style(HTML("hr {border-top: 1px solid #000000;}"))),
        tags$head(
          tags$style(HTML("

    #imports_save:hover, #exploration_filters_save:hover, #exploration_filters_confirm:hover, #exploration_atypiques_confirm:hover {
                background-color: #083c74;
                color: #FFFFFF;
    }
    #imports_mapping:hover, #exploration_profil_edit:hover {
                background-color: #a08b68;
                color: #FFFFFF;
    }


    #imports_data_delete:hover, #exploration_data_delete:hover, #exploration_filters_reset:hover, #exploration_profil_delete:hover, #exploration_atypiques_reset:hover {
                background-color: #9f0025;
                color: #FFFFFF;
    }


.navbar.navbar-default.navbar-static-top.navbar-inverse{
  border-radius:15px;margin-top:5px;
}
.nav-item {
  margin-top:auto;
  margin-bottom:auto;
  padding: 5px;
}
.accordion-flush .accordion-item{
  border-radius:15px;
  padding:3px;
  margin:10px;
}
  ")),
tags$head(
  tags$style(HTML("
      .rating__icon--star .fa {
        font-size: 24px; /* Change size as needed */
      }
    "))
)
        )),
      page_navbar(
        title=div(img(src="www/logopf.png", style="height:100px; width:100px;margin-bottom: -30px; border-radius: 50%"),
                  img(src="www/logoapp.png", style="height:100px; width:100px;margin-bottom: -30px; margin-right:30px; border-radius: 50%"),
                  ""),
        nav_panel_exploration(),
        nav_menu_apropos(),
        nav_spacer(),
        nav_item(actionBttn("suggestions",label = "Envoyez une suggestion",size = "xs")),
        nav_menu("Notez-moi",
                 nav_item(uiOutput("ratings"))),
        nav_item(input_dark_mode(mode = "light")),
        tags$style(".footer{position: fixed;bottom: 0;width: 100%;background-color: rgba(8, 60, 116, 1);color: white;text-align: center;padding: 5px;margin-left:-25px;}"),
        tags$style(".footer a{color: white;}"),
        footer = tags$div(
          class = "footer",
          "Développé par ",
          tags$a(href = "https://www.philippefontaine.eu", target = "_blank", "Philippe Fontaine"))
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
    favicon(ext = 'png'),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Analyse CIR"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
