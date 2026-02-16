#' Menu "A propos" avec credits, methodologie et contact
#'
#' @return Un objet nav_menu pour la barre de navigation.
#' @export
nav_menu_apropos <- function() {
  nav_menu(
    "A propos", icon = bs_icon("info-circle-fill"),
    nav_panel(
      "Credits", icon = bs_icon("c-circle"),
      card(
        card_header("Packages utilises"),
        card_body(htmlOutput("apropos"))
      )
    ),
    nav_panel(
      "Methodologie", icon = bs_icon("question-octagon"),
      card(
        card_header("Methodologie"),
        card_body(htmlOutput("cirmeth"))
      )
    ),
    nav_item(
      tags$a(
        href = "mailto:philippe.fontaine.ds@proton.me",
        class = "nav-link",
        tags$i(class = "fa fa-envelope"), " Contact"
      )
    )
  )
}
