#' Title
#'
#' @return
#' @export
#'
#' @examples
sidebar_exploration <- function() {
  renderUI({
    accordion(id = "accordion_exploration",
              pickerInput(inputId = "exploration_filter_sexe",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'),
                          label = "Sexe",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_pays",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'),
                          label = "Pays",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_age",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Âge",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_region",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Région",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_departement",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Département",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_motif_agreg",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Motif (niv 1)",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_motif_det",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Motif (niv 2)",
                          choices = c("")),
              pickerInput(inputId = "exploration_filter_parcours",multiple = TRUE,
                          options = list(
                            `live-search` = TRUE,
                            `container` = 'body'), label = "Parcours",
                          choices = c("")),
              actionButton(inputId = "exploration_filters_apply",label = "Appliquer"),
              actionButton(inputId = "exploration_filters_reset",label = "Réinitialiser")
    )
  })
}
