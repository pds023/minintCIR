#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

  data <- read.fst("data/data.fst",as.data.table = TRUE)


  data_n <- data[,.N]
  data_pays <- data[,.N,pays_de_nationalite][order(N,decreasing = TRUE)]
  data_age <- data[,.N,tranche_dage_signature_cir][order(N,decreasing = TRUE)]
  data_region <- data[,.N,region_2016][order(N,decreasing = TRUE)]
  data_dep <- data[,.N,libelle_de_departement][order(N,decreasing = TRUE)]
  data_dep <- data[,.N,libelle_de_departement][order(N,decreasing = TRUE)]
  data_motif1 <- data[,.N,motif_de_sejour_niveau_1][order(N,decreasing = TRUE)]
  data_motif2 <- data[,.N,motif_de_sejour_niveau_2][order(N,decreasing = TRUE)]
  data_parcours <- data[,.N,type_de_parcours_fl][order(N,decreasing = TRUE)]


  output$exploration_nb_cir <- renderText(data_n)
  output$exploration_nb_pays <- renderText(data_pays[1])
  # output$exploration_nb_age <- renderText(data_age[1])
  # output$exploration_nb_age <- renderText(data_age[1])

  output$highchart_stats_pays <- renderHighchart(
    hchart(data_pays, type = "bar",hcaes(x = pays_de_nationalite, y = N))
  )
  output$highchart_stats_age <- renderHighchart(
    hchart(data_age, type = "bar",hcaes(x = tranche_dage_signature_cir, y = N))
  )
  output$highchart_stats_territoire <- renderHighchart(
    hchart(data_region, type = "bar",hcaes(x = region_2016, y = N))
  )
  output$highchart_stats_motif <- renderHighchart(
    hchart(data_motif1, type = "bar",hcaes(x = motif_de_sejour_niveau_1, y = N))
  )
  output$highchart_stats_parcours <- renderHighchart(
    hchart(data_parcours, type = "bar",hcaes(x = type_de_parcours_fl, y = N))
  )


}
