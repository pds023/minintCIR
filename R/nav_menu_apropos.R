
#' Title
#'
#' @return
#' @export
#'
#' @examples
nav_menu_apropos <- function() {
  return(
    nav_menu("À propos",icon = bs_icon("info-circle-fill"),
             nav_panel("Méthodologie",icon = bs_icon("question-octagon")),
             nav_panel("Contact",icon = bs_icon("envelope"))))
}
