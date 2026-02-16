#' Handler de telechargement CSV
#'
#' Retourne un downloadHandler pour exporter des donnees en CSV.
#'
#' @param data Donnees a exporter.
#' @param label Nom du fichier (sans extension).
#'
#' @return Un objet downloadHandler.
#' @export
dl_button_serv <- function(data, label) {
  downloadHandler(
    filename = function() paste0(label, ".csv"),
    content = function(file) write.csv(data, file, row.names = FALSE)
  )
}
