#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  options(warn = -1)

  # Params & load ----------------
  datarv <- reactiveValues()
  data <- reactiveVal()
  data_filtered <- reactiveVal()
  data_n <- reactiveVal()
  data_sexe <- reactiveVal()
  data_pays <- reactiveVal()
  data_age <- reactiveVal()
  data_territoire <- reactiveVal()
  data_motif <- reactiveVal()
  data_parcours <- reactiveVal()
  filters_applied <- reactiveVal(FALSE)
  nb_rating <- reactiveVal(0)
  # forbid_rating <- reactiveVal(FALSE)

  data(read_parquet("data/data_2020.parquet"))

  output$cirmeth <- renderText({
    includeMarkdown("inst/app/www/cirmeth.md") # Remplacez par le chemin de votre fichier Markdown
  })
  output$apropos <- renderText({
    includeMarkdown("inst/app/www/apropos.md") # Remplacez par le chemin de votre fichier Markdown
  })


 output$ratings <- renderUI(shinyRatings("ratings_click", no_of_stars = 5, default = 5, disabled = FALSE))


  observeEvent(input$ratings_click,{
    if(nb_rating() > 0){
    if(input$ratings_click >= 4){showModal(modalDialog("Merci pour cette bonne note ! N'hésitez pas à proposer des suggestions :)",
                                                 easyClose = TRUE,size = "s"))
    } else if(input$ratings_click >= 2.5){showModal(modalDialog("Merci pour ce retour ! N'hésitez pas à proposer des suggestions pour améliorer l'expérience utilisateur !",
                                                          easyClose = TRUE,size = "s"))
    } else{showModal(modalDialog("Merci pour ce retour, et toutes mes excuses pour l'expérience peu satisfaisante. N'hésitez pas à proposer des suggestions pour améliorer l'expérience utilisateur.",
                                                          easyClose = TRUE,size = "s"))
    }
      print(input$ratings_click)
      write_parquet(as.data.table(cbind(as.Date(Sys.time()),input$ratings_click)),paste0("data/rating_",
                                                                                gsub(
                                                                                  pattern = " ",
                                                                                  replacement = "-",
                                                                                  x = gsub(pattern = ":",x = Sys.time(),replacement = "-"))))
    }
    nb_rating(nb_rating() + 1)
  })

  observeEvent(input$suggestions,{
    showModal(modalDialog(
      title = "Soumettre une suggestion",
      textAreaInput(inputId = "suggestion_text",label = "Suggestion :",placeholder = "Merci de décrire votre suggestion"),
      h5("Merci de ne pas renseigner d'informations personnelles dans ce champ. Les informations soumises sont enregistrées."),
      footer = tagList(
        modalButton("Annuler"),
        actionButton("ok", "Envoyer")),
      easyClose = TRUE)
    )
  })
  observeEvent(input$ok,{
    removeModal()
    show_alert(title = "Merci pour votre suggestion !",type = "success")
    print(input$suggestion_text)
    write_parquet(as.data.table(cbind(as.Date(Sys.time()),input$suggestion_text)),paste0("data/suggestion_",
                                                                              gsub(
                                                                                pattern = " ",
                                                                                replacement = "-",
                                                                                x = gsub(pattern = ":",x = Sys.time(),replacement = "-"))))
    })

  # Compute group by ----------------

  observe({
    if(is.null(data)){return(NULL)
    } else{
      if(!filters_applied()){
        data_n(data()[,.N])
        data_sexe(data()[,.N,sexe][order(N,decreasing = TRUE)])
        data_pays(data()[,.N,nationalite][order(N,decreasing = TRUE)])
        data_age(data()[,.N,age_cat][order(N,decreasing = TRUE)])
        data_territoire(data()[,.N,.(region,departement)][order(N,decreasing = TRUE)])
        data_motif(data()[,.N,.(motif_agreg,motif_det)][order(N,decreasing = TRUE)])
        data_parcours(data()[,.N,parcours][order(N,decreasing = TRUE)])
      } else{
        data_n(data_filtered()[,.N])
        data_sexe(data_filtered()[,.N,sexe][order(N,decreasing = TRUE)])
        data_pays(data_filtered()[,.N,nationalite][order(N,decreasing = TRUE)])
        data_age(data_filtered()[,.N,age_cat][order(N,decreasing = TRUE)])
        data_territoire(data_filtered()[,.N,.(region,departement)][order(N,decreasing = TRUE)])
        data_motif(data_filtered()[,.N,.(motif_agreg,motif_det)][order(N,decreasing = TRUE)])
        data_parcours(data_filtered()[,.N,parcours][order(N,decreasing = TRUE)])
      }
    }
  })

  # Dynamic sidebar filters ----------------
  output$sidebar_exploration <- sidebar_exploration()

  ## Maj PickerInput ----------------
  observe({
    if(is.null(data_parcours)){return(NULL)
    } else{
      if(!filters_applied()){
        updatePickerInput(session = session,inputId = "exploration_filter_sexe",choices = data_sexe()[,sexe])
        updatePickerInput(session = session,inputId = "exploration_filter_pays",choices = data_pays()[,nationalite])
        updatePickerInput(session = session,inputId = "exploration_filter_age",choices = data_age()[,age_cat])
        updatePickerInput(session = session,inputId = "exploration_filter_region",choices = unique(data_territoire()[,region]))
        updatePickerInput(session = session,inputId = "exploration_filter_departement",choices = unique(data_territoire()[,departement]))
        updatePickerInput(session = session,inputId = "exploration_filter_motif_agreg",choices = unique(data_motif()[,motif_agreg]))
        updatePickerInput(session = session,inputId = "exploration_filter_motif_det",choices = unique(data_motif()[,motif_det]))
        updatePickerInput(session = session,inputId = "exploration_filter_parcours",choices = unique(data_parcours()[,parcours]))

        updatePickerInput(session = session,inputId = "variables_compare",choices = colnames(data()))

      }
    }
  })

  ## Apply filters ----------------

  observeEvent(input$exploration_filters_apply,{
    # Récupérer les données
    tmp <- data()

    # Réinitialiser l'état du filtre
    filters_applied(FALSE)

    # Appliquer les filtres si les inputs ne sont pas NULL ou vides
    if (!is.null(input$exploration_filter_sexe) && length(input$exploration_filter_sexe) > 0) {
      tmp <- tmp[sexe %in% input$exploration_filter_sexe]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_pays) && length(input$exploration_filter_pays) > 0) {
      tmp <- tmp[nationalite %in% input$exploration_filter_pays]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_age) && length(input$exploration_filter_age) > 0) {
      tmp <- tmp[age_cat %in% input$exploration_filter_age]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_region) && length(input$exploration_filter_region) > 0) {
      tmp <- tmp[region %in% input$exploration_filter_region]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_departement) && length(input$exploration_filter_departement) > 0) {
      tmp <- tmp[departement %in% input$exploration_filter_departement]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_motif_agreg) && length(input$exploration_filter_motif_agreg) > 0) {
      tmp <- tmp[motif_agreg %in% input$exploration_filter_motif_agreg]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_motif_det) && length(input$exploration_filter_motif_det) > 0) {
      tmp <- tmp[motif_det %in% input$exploration_filter_motif_det]
      filters_applied(TRUE)
    }
    if (!is.null(input$exploration_filter_parcours) && length(input$exploration_filter_parcours) > 0) {
      tmp <- tmp[parcours %in% input$exploration_filter_parcours]
      filters_applied(TRUE)
    }
    if (filters_applied()) {
      data_filtered(tmp)
    }
  })

  ## Reset filters ----------------
  observeEvent(input$exploration_filters_reset,{
    filters_applied(FALSE)
  })

  # Highcharts graphs tab1 ----------------
  observe({
    req(input$highchart_stats_sexe_switch)
    req(input$highchart_stats_sexe_pct)
    output$highchart_stats_sexe <- renderHighchart(graph_explore(data = data_sexe(),
                  input_switch = input$highchart_stats_sexe_switch,
                  input_pct = input$highchart_stats_sexe_pct))
  })

  observe({
    req(input$highchart_stats_pays_switch)
    req(input$highchart_stats_pays_pct)
    output$highchart_stats_pays <- renderHighchart(graph_explore(data = data_pays(),
                                                                 input_switch = input$highchart_stats_pays_switch,
                                                                 input_pct = input$highchart_stats_pays_pct))
  })
  observe({
    req(input$highchart_stats_age_switch)
    req(input$highchart_stats_age_pct)
    output$highchart_stats_age <- renderHighchart(graph_explore(data = data_age(),
                                                                 input_switch = input$highchart_stats_age_switch,
                                                                 input_pct = input$highchart_stats_age_pct))
  })
  observe({
    req(input$highchart_stats_parcours_switch)
    req(input$highchart_stats_parcours_pct)
    output$highchart_stats_parcours <- renderHighchart(graph_explore(data = data_parcours(),
                                                                input_switch = input$highchart_stats_parcours_switch,
                                                                input_pct = input$highchart_stats_parcours_pct))
  })

  observe({
    req(input$highchart_stats_territoire_switch)
    req(input$highchart_stats_territoire_pct)
    output$highchart_stats_territoire <- renderHighchart(graph_explore(data = data_territoire(),
                                                                     input_switch = input$highchart_stats_territoire_switch,
                                                                     input_pct = input$highchart_stats_territoire_pct,
                                                                     group = TRUE))
  })

  observe({
    req(input$highchart_stats_motif_switch)
    req(input$highchart_stats_motif_pct)
    output$highchart_stats_motif <- renderHighchart(graph_explore(data = data_motif(),
                                                                       input_switch = input$highchart_stats_motif_switch,
                                                                       input_pct = input$highchart_stats_motif_pct,
                                                                       group = TRUE))
  })



  # observe({
  #   if(input$highchart_stats_parcours_switch){
  #     output$highchart_stats_parcours <- renderHighchart(
  #       hchart(data_parcours(), type = "bar",hcaes(x = parcours, y = N))
  #     )
  #   } else{
  #     data_parcours_treemap <- data_to_hierarchical(data_parcours(), c("parcours", "N"))
  #     output$highchart_stats_parcours <- renderHighchart(
  #       hchart(data_parcours_treemap, type = "treemap"))
  #   }
  # })
  # observe({
  #   if(input$highchart_stats_pays_switch){
  #     output$highchart_stats_pays <- renderHighchart(
  #       hchart(data_pays(), type = "bar",hcaes(x = nationalite, y = N))
  #     )}else{
  #       data_pays_treemap <- data_to_hierarchical(data_pays(), c("nationalite", "N"))
  #       output$highchart_stats_pays <- renderHighchart(
  #         hchart(data_pays_treemap, type = "treemap")
  #       )
  #     }
  # })
  # observe({
  #   if(input$highchart_stats_age_switch){
  #     output$highchart_stats_age <- renderHighchart(
  #       hchart(data_age(), type = "bar",hcaes(x = age_cat, y = N))
  #     )
  #   } else{
  #     data_age_treemap <- data_to_hierarchical(data_age(), c("age_cat", "N"))
  #     output$highchart_stats_age <- renderHighchart(
  #       hchart(data_age_treemap, type = "treemap")
  #     )
  #   }
  # })



  # observe({
  #   if(input$highchart_stats_motif_switch){
  #     output$highchart_stats_motif <- renderHighchart(
  #       hchart(data_motif(), type = "bar",hcaes(x = motif_det, y = N, group = motif_agreg))
  #     )
  #   } else {
  #     data_motif_treemap <- data_to_hierarchical(data_motif(),group_vars =  c("motif_agreg", "motif_det"),
  #                                                size_var = "N")
  #     output$highchart_stats_motif <- renderHighchart(
  #       hchart(data_motif_treemap, type = "treemap"))
  #   }
  # })




  observeEvent(input$variables_compare,{
    req(input$variables_compare)
    if(length(input$variables_compare) > 0){
      updatePickerInput(session = session,inputId = "modalites_compare",choices = c(unique(data()[,get(input$variables_compare)])),
                        selected = NULL)
    }
  })

  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pays_pct)

    if(!filters_applied()){
    output$highchart_compare_pays <- renderHighchart(
      graph_compare(data(),"nationalite",input$variables_compare,input$modalites_compare,input$highchart_compare_pays_pct)
      )
    } else{
      output$highchart_compare_pays <- renderHighchart(
        graph_compare(data_filtered(),"nationalite",input$variables_compare,input$modalites_compare,input$highchart_compare_pays_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_sexe_pct)
    if(!filters_applied()){
    output$highchart_compare_sexe <- renderHighchart(
      graph_compare(data(),"sexe",input$variables_compare,input$modalites_compare,input$highchart_compare_sexe_pct)
    )
    } else {
      output$highchart_compare_sexe <- renderHighchart(
        graph_compare(data_filtered(),"sexe",input$variables_compare,input$modalites_compare,input$highchart_compare_sexe_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_age_pct)
    if(!filters_applied()){
    output$highchart_compare_age <- renderHighchart(
      graph_compare(data(),"age_cat",input$variables_compare,input$modalites_compare,input$highchart_compare_age_pct)
    )
    } else {
      output$highchart_compare_age <- renderHighchart(
        graph_compare(data_filtered(),"age_cat",input$variables_compare,input$modalites_compare,input$highchart_compare_age_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_territoire_pct)
    if(!filters_applied()){
    output$highchart_compare_territoire <- renderHighchart(
      graph_compare(data(),"departement",input$variables_compare,input$modalites_compare,input$highchart_compare_territoire_pct)
    )
    } else {
      output$highchart_compare_territoire <- renderHighchart(
        graph_compare(data_filtered(),"departement",input$variables_compare,input$modalites_compare,input$highchart_compare_territoire_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_motif_pct)
    if(!filters_applied()){
    output$highchart_compare_motif <- renderHighchart(
      graph_compare(data(),"motif_det",input$variables_compare,input$modalites_compare,input$highchart_compare_motif_pct)
    )
    } else {
      output$highchart_compare_motif <- renderHighchart(
        graph_compare(data_filtered(),"motif_det",input$variables_compare,input$modalites_compare,input$highchart_compare_motif_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_parcours_pct)
    if(!filters_applied()){
    output$highchart_compare_parcours <- renderHighchart(
      graph_compare(data(),"parcours",input$variables_compare,input$modalites_compare,input$highchart_compare_parcours_pct)
    )
    } else {
      output$highchart_compare_parcours <- renderHighchart(
        graph_compare(data_filtered(),"parcours",input$variables_compare,input$modalites_compare,input$highchart_compare_parcours_pct)
      )
    }
  })

  observe({
    if(!filters_applied()){
      output$exploration_donnees_brutes <- renderDT(
        data(),
        filter = 'top',
        fillContainer = TRUE,
        extensions = c('Responsive'),options = list(
          pageLength = 15, autoWidth = TRUE,
          language = list(
            info = 'Affichage de _START_ à _END_ résultats sur _TOTAL_',
            paginate = list(previous = 'Précédent', `next` = 'Suivant'),
            lengthMenu = "Afficher _MENU_ résultats",
            search = "Recherche"
          )
        ))
    } else{
      output$exploration_donnees_brutes <- renderDT(
        data_filtered(),
        filter = 'top',
        fillContainer = TRUE,
        extensions = c('Responsive'),options = list(
          pageLength = 15, autoWidth = TRUE,
          language = list(
            info = 'Affichage de _START_ à _END_ résultats sur _TOTAL_',
            paginate = list(previous = 'Précédent', `next` = 'Suivant'),
            lengthMenu = "Afficher _MENU_ résultats",
            search = "Recherche"
          )
        ))
    }
  })

  observe({
    if(!filters_applied()){
      output$downloadData <- downloadHandler(
        filename = function() {
          # Use the selected dataset as the suggested file name
          "data_2020.csv"
        },
        content = function(file) {
          # Write the dataset to the `file` that will be downloaded
          write.csv(data(), file)
        }
      )
    } else {
      output$downloadData <- downloadHandler(
        filename = function() {
          # Use the selected dataset as the suggested file name
          "data_filtered_2020.csv"
        },
        content = function(file) {
          # Write the dataset to the `file` that will be downloaded
          write.csv(data_filtered(), file)
        }
      )
    }
  })
}


