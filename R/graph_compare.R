#' Graphique de comparaison entre modalites
#'
#' Compare la distribution d'une variable selon des modalites selectionnees.
#'
#' @param data data.table source.
#' @param groupColumn Nom de la colonne de regroupement pour l'axe X.
#' @param input_var Nom de la variable de comparaison.
#' @param input_mod Vecteur des modalites selectionnees.
#' @param input_pct Affichage : "niv" pour les effectifs, autre pour les pourcentages.
#'
#' @return Un objet highchart ou NULL si aucune donnee.
#' @export
graph_compare <- function(data, groupColumn, input_var, input_mod, input_pct) {
  if (is.null(data)) return(NULL)

  data_list <- lapply(input_mod, function(mod) {
    data_subset <- data[get(input_var) %in% mod]
    if (nrow(data_subset) == 0) return(NULL)

    data_subset <- data_subset[, .N, by = groupColumn]
    colnames(data_subset) <- c("var", "N")
    data_subset[, var_compare := mod]
    data_subset[, pct := round(N / sum(N), 4)]
    data_subset
  })

  data_list <- Filter(Negate(is.null), data_list)

  if (length(data_list) > 0) {
    data_graph <- rbindlist(data_list)
    if (input_pct %in% "niv") {
      return(hchart(data_graph, type = "column", hcaes(x = var, y = "N", group = "var_compare")))
    } else {
      return(hchart(data_graph, type = "column", hcaes(x = var, y = "pct", group = "var_compare")))
    }
  }

  NULL
}
