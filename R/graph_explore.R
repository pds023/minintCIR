#' Graphique d'exploration (barplot ou treemap)
#'
#' Genere un graphique interactif Highcharts a partir de donnees agregees.
#'
#' @param data data.table avec colonnes var/N (simple) ou agreg/var/N (groupe).
#' @param input_type Type de graphique : "bar" ou "pie" (treemap).
#' @param input_pct Affichage : "nb" pour les effectifs, autre pour les pourcentages.
#' @param group Logique, TRUE si les donnees ont une colonne de regroupement.
#'
#' @return Un objet highchart.
#' @export
graph_explore <- function(data,
                          input_type,
                          input_pct,
                          group = FALSE) {
  if (!group) {
    colnames(data) <- c("var", "N")
    data[, pct := round(N / sum(N), 4)]
    if (input_type %in% "bar") {
      if (input_pct %in% "nb") {
        return(hchart(data, type = "bar", hcaes(x = var, y = N)))
      } else {
        return(hchart(data, type = "bar", hcaes(x = var, y = pct)))
      }
    } else {
      data_treemap <- data_to_hierarchical(data, c("var", "N"))
      return(hchart(data_treemap, type = "treemap"))
    }
  } else {
    colnames(data) <- c("agreg", "var", "N")
    data[, pct := round(N / sum(N), 4)]
    if (input_type %in% "bar") {
      if (input_pct %in% "nb") {
        return(hchart(data, type = "bar", hcaes(x = var, y = N, group = agreg)))
      } else {
        return(hchart(data, type = "bar", hcaes(x = var, y = pct, group = agreg)))
      }
    } else {
      data_treemap <- data_to_hierarchical(data, group_vars = c("agreg", "var"), size_var = "N")
      return(hchart(data_treemap, type = "treemap"))
    }
  }
}
