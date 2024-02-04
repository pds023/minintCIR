#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  options(warn = -1)

  source("set_cfg.R")

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


  data(as.data.table(s3read_using(
    read_parquet,
    object = "data_2020.parquet",
    bucket = "awsbucketpf/shinycir"
  )))

  suggestions <- s3read_using(
    read_parquet,
    object = "suggestions.parquet",
    bucket = "awsbucketpf/shinycir"
  )


  output$cirmeth <- renderText({
    includeMarkdown("inst/app/www/cirmeth.md") # Remplacez par le chemin de votre fichier Markdown
  })
  output$apropos <- renderText({
    includeMarkdown("inst/app/www/apropos.md") # Remplacez par le chemin de votre fichier Markdown
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
    suggestions <- as.data.table(rbind(suggestions,cbind(as.character(Sys.Date()),input$suggestion_text)))
    s3write_using(
      x = suggestions,
      FUN = write_parquet,
      object = "suggestions.parquet",
      bucket = "awsbucketpf/shinycir"
    )
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
    output$highchart_stats_sexe <- renderHighchart(graph_explore(data = data_sexe(),
                  input_type = input$highchart_stats_type,
                  input_pct = input$highchart_stats_pct))
  })
  observe({
    output$highchart_stats_pays <- renderHighchart(graph_explore(data = data_pays(),
                                                                 input_type = input$highchart_stats_type,
                                                                 input_pct = input$highchart_stats_pct))
  })
  observe({
    output$highchart_stats_age <- renderHighchart(graph_explore(data = data_age(),
                                                                 input_type = input$highchart_stats_type,
                                                                 input_pct = input$highchart_stats_pct))
  })
  observe({
    output$highchart_stats_parcours <- renderHighchart(graph_explore(data = data_parcours(),
                                                                input_type = input$highchart_stats_type,
                                                                input_pct = input$highchart_stats_pct))
  })
  observe({
    output$highchart_stats_territoire <- renderHighchart(graph_explore(data = data_territoire(),
                                                                     input_type = input$highchart_stats_type,
                                                                     input_pct = input$highchart_stats_pct,
                                                                     group = TRUE))
  })
  observe({
    output$highchart_stats_motif <- renderHighchart(graph_explore(data = data_motif(),
                                                                       input_type = input$highchart_stats_type,
                                                                       input_pct = input$highchart_stats_pct,
                                                                       group = TRUE))
  })


  observeEvent(input$variables_compare,{
    req(input$variables_compare)
    if(length(input$variables_compare) > 0){
      updatePickerInput(session = session,inputId = "modalites_compare",choices = unique(data()[,get(input$variables_compare)]),
                        selected = NULL)
    }
  })

  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)

    if(!filters_applied()){
    output$highchart_compare_pays <- renderHighchart(
      graph_compare(data(),"nationalite",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    } else{
      output$highchart_compare_pays <- renderHighchart(
        graph_compare(data_filtered(),"nationalite",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)
    if(!filters_applied()){
    output$highchart_compare_sexe <- renderHighchart(
      graph_compare(data(),"sexe",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
    )
    } else {
      output$highchart_compare_sexe <- renderHighchart(
        graph_compare(data_filtered(),"sexe",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)
    if(!filters_applied()){
    output$highchart_compare_age <- renderHighchart(
      graph_compare(data(),"age_cat",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
    )
    } else {
      output$highchart_compare_age <- renderHighchart(
        graph_compare(data_filtered(),"age_cat",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)
    if(!filters_applied()){
    output$highchart_compare_territoire <- renderHighchart(
      graph_compare(data(),"departement",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
    )
    } else {
      output$highchart_compare_territoire <- renderHighchart(
        graph_compare(data_filtered(),"departement",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)
    if(!filters_applied()){
    output$highchart_compare_motif <- renderHighchart(
      graph_compare(data(),"motif_det",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
    )
    } else {
      output$highchart_compare_motif <- renderHighchart(
        graph_compare(data_filtered(),"motif_det",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })
  observe({
    req(input$variables_compare)
    req(input$modalites_compare)
    req(input$highchart_compare_pct)
    if(!filters_applied()){
    output$highchart_compare_parcours <- renderHighchart(
      graph_compare(data(),"parcours",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
    )
    } else {
      output$highchart_compare_parcours <- renderHighchart(
        graph_compare(data_filtered(),"parcours",input$variables_compare,input$modalites_compare,input$highchart_compare_pct)
      )
    }
  })

  observe({
    if(!filters_applied()){
      output$exploration_donnees_brutes <- create_dt(data(),length = 15,cols_names = NULL,select_cols = FALSE)
    } else{
      output$exploration_donnees_brutes <- create_dt(data_filtered(),length = 15,cols_names = NULL,select_cols = FALSE)
    }
  })

  observe({
    if(!filters_applied()){
      output$downloadData <- dl_button_serv(data = data(),label = "data_2020")
    } else {
      output$downloadData <- dl_button_serv(data = data_filtered(),label = "data_filtered_2020")
    }
  })



  observe({
    req(input$highchart_stats_type)
    if(input$highchart_stats_type %in% "pie"){
      updateRadioGroupButtons(session = session,inputId = "highchart_stats_pct", selected = "niv",disabled = TRUE)
    } else{
      updateRadioGroupButtons(session = session,inputId = "highchart_stats_pct",disabled = FALSE)
    }
  })

  observe({
    print(input$modalites_compare)
    if(is.null(input$modalites_compare)){
      updateRadioGroupButtons(session = session,inputId = "highchart_compare_pct",disabled = TRUE)
    } else{
      updateRadioGroupButtons(session = session,inputId = "highchart_compare_pct",disabled = FALSE)
    }

  })



  }




