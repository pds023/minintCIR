#' Title
#'
#' @param data_cir
#'
#' @return
#' @export
#' @import data.table openxlsx janitor fst
#' @examples
preprocess <- function(pathCIR = "data/data20-cir.xlsx") {
  data <- read.xlsx(pathCIR)
  data <- as.data.table(clean_names(data))
  write.fst(data,"data/data.fst")

}

