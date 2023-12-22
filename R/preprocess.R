#' Title
#'
#' @param data_cir
#'
#' @return
#' @export
#' @import data.table openxlsx janitor arrow
#' @examples
preprocess <- function(pathCIR = "data/data20-cir.xlsx") {
  data <- read.xlsx(pathCIR)
  data <- as.data.table(clean_names(data))
  colnames(data) <- c("annee","region","nom","departement","motif_agreg","motif_det","sexe","nationalite",
                      "age_cat","parcours","fl_prescrite")
  write_parquet(data,"data/data_2020.parquet")

}

