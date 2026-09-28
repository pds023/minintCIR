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
#' @param placeholder Texte affiché en l'absence de sélection.
#'
#' @return Un tag shiny pickerInput.
#' @export
create_picker <- function(id, label = NULL, choices = c(), multiple = TRUE,
                          selected = NULL, select_all = TRUE,
                          placeholder = if (multiple) "Toutes les valeurs" else "Choisir une dimension") {
  opts <- pickerOptions(
    noneSelectedText = placeholder,
    liveSearch = TRUE,
    actionsBox = select_all && multiple,
    size = 7,
    liveSearchNormalize = TRUE,
    noneResultsText = "Aucun résultat",
    liveSearchPlaceholder = "Rechercher…",
    countSelectedText = "{0} valeurs sélectionnées",
    selectedTextFormat = "count > 2",
    deselectAllText = "Tout effacer",
    selectAllText = "Tout sélectionner"
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
