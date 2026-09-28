#' Comparer la distribution de plusieurs groupes
#'
#' @param data Tableau source.
#' @param groupColumn Colonne à répartir sur l'axe X.
#' @param input_var Variable qui définit les groupes comparés.
#' @param input_mod Modalités sélectionnées.
#' @param input_pct "niv" ou "nb" pour les effectifs, "percent" pour les parts.
#' @return Un objet highchart ou NULL en l'absence de données.
#' @export
graph_compare <- function(data, groupColumn, input_var, input_mod, input_pct) {
  if (is.null(data) || !nrow(data) || !length(input_mod) ||
      length(groupColumn) != 1L || length(input_var) != 1L ||
      !all(c(groupColumn, input_var) %in% names(data))) return(NULL)

  categories <- as.character(data[[groupColumn]])
  groups <- as.character(data[[input_var]])
  categories[is.na(categories) | !nzchar(categories)] <- "Non renseigné"
  groups[is.na(groups) | !nzchar(groups)] <- "Non renseigné"
  selected <- unique(as.character(input_mod))
  selected <- selected[selected %in% groups]
  if (!length(selected)) return(NULL)
  keep <- groups %in% selected
  counts <- table(categories[keep], factor(groups[keep], levels = selected))
  totals <- colSums(counts)
  order_categories <- order(-rowSums(counts), rownames(counts))
  shown <- utils::head(order_categories, 12L)
  subtitle <- if (nrow(counts) > 12L) {
    "12 premières catégories · parts sur chaque groupe complet · détail dans Données"
  } else {
    "Les parts sont calculées au sein de chaque groupe comparé"
  }
  percent <- identical(input_pct, "percent")
  chart <- highcharter::highchart()
  for (i in seq_along(selected)) {
    chart <- highcharter::hc_add_series(
      chart, type = "column", name = selected[i],
      data = cir_chart_points(rownames(counts)[shown], as.numeric(counts[shown, i]), totals[i], percent)
    )
  }
  chart <- highcharter::hc_xAxis(
    chart, categories = as.list(rownames(counts)[shown]),
    labels = list(autoRotation = c(-35, -60), style = list(fontSize = "11px"))
  )
  cir_chart_theme(chart, percent, subtitle, legend = TRUE, within_group = TRUE)
}
