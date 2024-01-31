#' Title
#'
#' @return
#' @export
#'
#' @examples
sidebar_exploration <- function() {
  renderUI({
    accordion(accordion_panel(title = "Filtrer",icon = icon("filter"),
                              create_picker(id = "exploration_filter_sexe", label = "Sexe :"),
                              create_picker(id = "exploration_filter_pays", label = "Pays :"),
                              create_picker(id = "exploration_filter_age", label = "Age :"),
                              create_picker(id = "exploration_filter_region", label = "Région :"),
                              create_picker(id = "exploration_filter_departement", label = "Département :"),
                              create_picker(id = "exploration_filter_motif_agreg", label = "Motif (niv1) :"),
                              create_picker(id = "exploration_filter_motif_det", label = "Motif (niv2) :"),
                              create_picker(id = "exploration_filter_parcours", label = "Parcours :"),
                              actionButton(inputId = "exploration_filters_apply",label = "Appliquer"),
                              actionButton(inputId = "exploration_filters_reset",label = "Réinitialiser")
    ))
  })
}
