#' Cree un DataTable interactif avec configuration francaise
#'
#' Wrapper autour de DT::renderDT avec le pack de langue francais
#' et les options de pagination/filtrage.
#'
#' @param data Donnees a afficher.
#' @param length Nombre de lignes par page.
#' @param cols_names Noms de colonnes a afficher.
#' @param select_cols Activer la visibilite des colonnes avec bouton colvis.
#'
#' @return Un objet renderDT.
#' @export
create_dt <- function(data, length = 5, cols_names = NULL, select_cols = FALSE) {
  base_options <- list(
    pageLength = length,
    language = list(
      url = "//cdn.datatables.net/plug-ins/1.13.7/i18n/fr-FR.json"
    ),
    dom = "Bfrtip",
    buttons = "colvis"
  )

  if (select_cols) {
    base_options$scrollX <- TRUE
    base_options$columnDefs <- list(
      list(visible = TRUE, targets = c(0:5)),
      list(visible = FALSE, targets = c(6:(length(colnames(data)) - 1)))
    )
  }

  renderDT(
    data,
    filter = "top",
    selection = if (select_cols) "none" else "multiple",
    extensions = c("Buttons"),
    colnames = if (select_cols) colnames(data) else cols_names,
    rownames = FALSE,
    options = base_options
  )
}
