cir_chart_colors <- c("#147d73", "#6386aa", "#d6a35d", "#9882ac", "#80aaa0")

# Keep numeric values for plotting and French labels for precise tooltips.
cir_chart_points <- function(categories, counts, total, percent) {
  categories <- unname(categories)
  counts <- unname(counts)
  total <- unname(total)
  shares <- 100 * counts / total
  lapply(seq_along(categories), function(i) list(
    name = categories[i], y = if (percent) shares[i] else counts[i],
    custom = list(
      count = counts[i], share = shares[i],
      countLabel = formatC(counts[i], format = "f", digits = 0, big.mark = " "),
      shareLabel = paste0(formatC(shares[i], format = "f", digits = 1, decimal.mark = ","), " %")
    )
  ))
}

cir_chart_theme <- function(chart, percent = FALSE, subtitle = NULL,
                            legend = FALSE, within_group = FALSE) {
  chart <- highcharter::hc_chart(
    chart, backgroundColor = "transparent", spacing = c(12, 16, 8, 8), marginTop = 60,
    style = list(fontFamily = "Marianne, Arial, sans-serif", color = "#152d37")
  )
  chart <- highcharter::hc_colors(chart, cir_chart_colors)
  chart <- highcharter::hc_title(chart, text = NULL)
  chart <- highcharter::hc_subtitle(
    chart, text = subtitle, align = "left",
    style = list(color = "#60757e", fontSize = "11px"), margin = 18
  )
  chart <- highcharter::hc_xAxis(
    chart, lineWidth = 0, tickLength = 0, title = list(text = NULL),
    labels = list(style = list(color = "#435c67", fontSize = "12px"),
                  reserveSpace = TRUE)
  )
  chart <- highcharter::hc_yAxis(
    chart, min = 0, max = if (percent) 100 else NULL,
    title = list(text = if (percent) "Part des CIR (%)" else "Nombre de CIR",
                 style = list(color = "#60757e", fontSize = "11px")),
    gridLineColor = "#e8eef0", allowDecimals = percent,
    labels = list(style = list(color = "#60757e"), formatter = highcharter::JS(
      if (percent) "function(){return Highcharts.numberFormat(this.value, 0, ',', ' ') + ' %';}"
      else "function(){return Highcharts.numberFormat(this.value, 0, ',', ' ');}"
    ))
  )
  chart <- highcharter::hc_plotOptions(
    chart, series = list(borderWidth = 0, animation = list(duration = 300)),
    bar = list(borderRadius = 3, pointPadding = 0.12, groupPadding = 0.14),
    column = list(borderRadius = 3, maxPointWidth = 42, groupPadding = 0.18)
  )
  chart <- highcharter::hc_tooltip(
    chart, backgroundColor = "#ffffff", borderColor = "#e0e8e9", borderRadius = 8,
    shadow = FALSE, useHTML = FALSE,
    headerFormat = "<b>{point.key}</b><br/>",
    pointFormat = paste0(
      "{series.name} : <b>{point.custom.countLabel} CIR</b><br/>",
      "{point.custom.shareLabel}",
      if (within_group) " du groupe" else " de la sélection"
    ),
    style = list(color = "#152d37", fontSize = "12px")
  )
  chart <- highcharter::hc_legend(
    chart, enabled = legend, align = "left", symbolRadius = 3,
    itemStyle = list(color = "#435c67", fontWeight = "normal", fontSize = "12px")
  )
  highcharter::hc_credits(chart, enabled = FALSE)
}
