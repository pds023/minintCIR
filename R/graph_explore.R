#' Graphique d'exploration : barres ou carte proportionnelle
#'
#' @param data Tableau agrégé avec colonnes var/N ou agreg/var/N.
#' @param input_type "bar" ou "pie" (carte proportionnelle historique).
#' @param input_pct "niv" ou "nb" pour les effectifs, "percent" pour les parts.
#' @param group TRUE pour afficher un regroupement.
#' @return Un objet highchart ou NULL en l'absence de données.
#' @export
graph_explore <- function(data, input_type, input_pct, group = FALSE) {
  if (is.null(data) || !nrow(data)) return(NULL)
  d <- as.data.frame(data)
  if (ncol(d) != if (group) 3L else 2L) return(NULL)
  names(d) <- if (group) c("agreg", "var", "N") else c("var", "N")
  d <- d[is.finite(d$N) & d$N > 0, , drop = FALSE]
  if (!nrow(d)) return(NULL)
  d$var <- as.character(d$var)
  d$var[is.na(d$var) | !nzchar(d$var)] <- "Non renseigné"
  if (group) {
    d$agreg <- as.character(d$agreg)
    d$agreg[is.na(d$agreg) | !nzchar(d$agreg)] <- "Non renseigné"
  }

  total <- sum(d$N)
  totals <- stats::aggregate(N ~ var, d, sum)
  totals <- totals[order(-totals$N, totals$var), ]
  categories <- utils::head(totals$var, 12L)
  subtitle <- if (nrow(totals) > 12L) {
    "12 premières catégories · parts calculées sur l’ensemble · détail dans Données"
  } else {
    "Parts calculées sur l’ensemble des CIR sélectionnés"
  }
  d <- d[d$var %in% categories, , drop = FALSE]
  percent <- identical(input_pct, "percent")
  groups <- if (group) unique(d$agreg) else "CIR"
  chart <- highcharter::highchart()

  if (identical(input_type, "pie")) {
    points <- list()
    for (i in seq_along(groups)) {
      subset <- if (group) d[d$agreg == groups[i], , drop = FALSE] else d
      leaves <- cir_chart_points(subset$var, subset$N, total, FALSE)
      for (j in seq_along(leaves)) {
        leaves[[j]]$value <- subset$N[j]
        if (group) leaves[[j]]$parent <- paste0("group-", i)
      }
      if (group) {
        parent <- cir_chart_points(groups[i], sum(subset$N), total, FALSE)[[1]]
        parent$id <- paste0("group-", i)
        parent$color <- cir_chart_colors[(i - 1L) %% length(cir_chart_colors) + 1L]
        points <- c(points, list(parent))
      }
      points <- c(points, leaves)
    }
    chart <- highcharter::hc_add_series(
      chart, data = points, type = "treemap", name = "CIR",
      layoutAlgorithm = "squarified", colorByPoint = !group,
      borderWidth = 3, borderColor = "#ffffff",
      dataLabels = list(enabled = TRUE,
                        format = if (percent) "{point.name}<br/>{point.custom.shareLabel}"
                                 else "{point.name}<br/>{point.custom.countLabel}",
                        style = list(fontSize = "12px", textOutline = "none"))
    )
    return(cir_chart_theme(chart, subtitle = subtitle))
  }

  for (i in seq_along(groups)) {
    subset <- if (group) d[d$agreg == groups[i], , drop = FALSE] else d
    counts <- vapply(categories, function(category) sum(subset$N[subset$var == category]), numeric(1))
    chart <- highcharter::hc_add_series(
      chart, data = cir_chart_points(categories, counts, total, percent),
      type = "bar", name = groups[i], stacking = "normal",
      color = if (length(groups) > 5L) cir_chart_colors[1] else cir_chart_colors[i]
    )
  }
  chart <- highcharter::hc_xAxis(chart, categories = as.list(categories))
  cir_chart_theme(chart, percent, subtitle, legend = group && length(groups) <= 5L)
}
