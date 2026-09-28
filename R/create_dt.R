#' Crée un DataTable interactif avec configuration française
#' @param data Données à afficher, ou fonction réactive retournant les données.
#' @param length Nombre de lignes par page.
#' @param cols_names Noms de colonnes à afficher.
#' @param select_cols Activer le choix des colonnes visibles.
#' @return Un objet renderDT.
#' @export
create_dt <- function(data, length = 15, cols_names = NULL, select_cols = FALSE) {
  renderDT({
    current <- if (is.function(data)) data() else data
    options <- list(
      pageLength = length, lengthMenu = c(15, 30, 50, 100), scrollX = TRUE,
      dom = if (select_cols) "Blfrtip" else "lfrtip",
      language = list(
        decimal = ",", thousands = " ",
        search = "Rechercher :", searchPlaceholder = "Un mot, un territoire…",
        lengthMenu = "Afficher _MENU_ lignes",
        info = "_START_ à _END_ sur _TOTAL_ observations",
        infoEmpty = "Aucune observation", infoFiltered = "(sur _MAX_ dans la sélection)",
        zeroRecords = "Aucune observation ne correspond à cette recherche.",
        emptyTable = "Aucun contrat dans ce périmètre. Modifiez les filtres.",
        paginate = list(first = "Première", previous = "Précédent", `next` = "Suivant", last = "Dernière"),
        processing = "Chargement…",
        aria = list(sortAscending = ": trier par ordre croissant", sortDescending = ": trier par ordre décroissant")
      )
    )
    if (select_cols) options$buttons <- list(list(extend = "colvis", text = "Colonnes"))
    DT::datatable(current, rownames = FALSE,
      colnames = cols_names, selection = "none", class = "stripe hover",
      extensions = if (select_cols) "Buttons" else character(),
      options = options
    )
  }, server = TRUE)
}
