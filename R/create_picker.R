#' Cree un pickerInput avec configuration francaise
#'
#' Wrapper autour de shinyWidgets::pickerInput avec les textes en francais
#' et la recherche en direct activee.
#'
#' @param id Identifiant du widget.
#' @param label Label affiche.
#' @param choices Vecteur de choix.
#' @param multiple Autoriser la selection multiple.
#' @param selected Valeur(s) selectionnee(s) par defaut.
#' @param select_all Afficher les boutons "Tout selectionner / deselectionner".
#'
#' @return Un tag shiny pickerInput.
#' @export
create_picker <- function(id, label = NULL, choices = c(), multiple = TRUE,
                          selected = NULL, select_all = TRUE) {
  opts <- pickerOptions(
    noneSelectedText = "Aucune selection",
    liveSearch = TRUE,
    container = "body",
    actionsBox = select_all,
    size = 5,
    liveSearchNormalize = TRUE,
    noneResultsText = "Aucun resultat",
    deselectAllText = "Tout deselectionner",
    selectAllText = "Tout selectionner"
  )

  pickerInput(
    inputId = id,
    label = label,
    choices = choices,
    multiple = multiple,
    selected = selected,
    options = opts
  )
}
