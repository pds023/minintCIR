#' Pretraitement des donnees CIR
#'
#' Charge un fichier Excel brut, nettoie les noms de colonnes
#' et sauvegarde en format Parquet.
#'
#' @param pathCIR Chemin vers le fichier Excel source.
#'
#' @return Invisible NULL. Le fichier Parquet est ecrit sur disque.
#' @export
#' @import data.table openxlsx janitor arrow
preprocess <- function(pathCIR = "data/data20-cir.xlsx") {
  data <- read.xlsx(pathCIR)
  data <- as.data.table(clean_names(data))
  colnames(data) <- c(
    "annee", "region", "nom", "departement", "motif_agreg", "motif_det",
    "sexe", "nationalite", "age_cat", "parcours", "fl_prescrite"
  )
  dir.create("inst/extdata", recursive = TRUE, showWarnings = FALSE)
  write_parquet(data, "inst/extdata/data_2020.parquet")
  invisible(NULL)
}
