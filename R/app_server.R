#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  data <- read.fst("data/data.fst",as.data.table = TRUE)

  output$highchart_stats_pays <- renderHighchart(
    hchart(data[,.N,pays_de_nationalite][order(N,decreasing = TRUE)], type = "bar",hcaes(x = pays_de_nationalite, y = N))
  )
  output$highchart_stats_age <- renderHighchart(
    hchart(data[,.N,tranche_dage_signature_cir][order(N,decreasing = TRUE)], type = "bar",hcaes(x = tranche_dage_signature_cir, y = N))
  )
  output$highchart_stats_territoire <- renderHighchart(
    hchart(data[,.N,region_2016][order(N,decreasing = TRUE)], type = "bar",hcaes(x = region_2016, y = N))
  )
  output$highchart_stats_motif <- renderHighchart(
    hchart(data[,.N,motif_de_sejour_niveau_1][order(N,decreasing = TRUE)], type = "bar",hcaes(x = motif_de_sejour_niveau_1, y = N))
  )
  output$highchart_stats_parcours <- renderHighchart(
    hchart(data[,.N,type_de_parcours_fl][order(N,decreasing = TRUE)], type = "bar",hcaes(x = type_de_parcours_fl, y = N))
  )


}
