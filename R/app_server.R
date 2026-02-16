#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  telemetry$start_session(track_values = TRUE)

  source("set_cfg.R")

  session$onSessionEnded(function() {
    tryCatch(
      put_object(
        file = "telemetry.sqlite",
        bucket = "awsbucketpf/shinycir",
        object = "telemetry.sqlite"
      ),
      error = function(e) message("[minintCIR] Erreur upload telemetry: ", e$message)
    )
  })


  # Params & load ----------------
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

  # Chargement des donnees depuis S3 avec gestion d'erreur
  tryCatch({
    data(as.data.table(s3read_using(
      read_parquet,
      object = "data_2020.parquet",
      bucket = "awsbucketpf/shinycir"
    )))
  }, error = function(e) {
    message("[minintCIR] Erreur chargement donnees: ", e$message)
    showNotification("Erreur lors du chargement des donnees.", type = "error", duration = NULL)
  })

  suggestions <- tryCatch(
    s3read_using(
      read_parquet,
      object = "suggestions.parquet",
      bucket = "awsbucketpf/shinycir"
    ),
    error = function(e) {
      message("[minintCIR] Erreur chargement suggestions: ", e$message)
      data.table::data.table(V1 = character(), V2 = character())
    }
  )

  # Helper: retourne les donnees actives (filtrees ou non)
  active_data <- reactive({
    if (filters_applied()) data_filtered() else data()
  })

  output$cirmeth <- renderText({
    includeMarkdown("inst/app/www/cirmeth.md")
  })
  output$apropos <- renderText({
    includeMarkdown("inst/app/www/apropos.md")
  })


  # Suggestions ----------------
  observeEvent(input$suggestions, {
    showModal(modalDialog(
      title = "Soumettre une suggestion",
      textAreaInput(
        inputId = "suggestion_text",
        label = "Suggestion :",
        placeholder = "Merci de decrire votre suggestion"
      ),
      h5("Merci de ne pas renseigner d'informations personnelles dans ce champ. Les informations soumises sont enregistrees."),
      footer = tagList(
        modalButton("Annuler"),
        actionButton("ok", "Envoyer")
      ),
      easyClose = TRUE
    ))
  })

  observeEvent(input$ok, {
    removeModal()

    # Validation de l'input
    suggestion_text <- trimws(input$suggestion_text)
    if (nchar(suggestion_text) == 0) {
      show_alert(title = "Veuillez saisir une suggestion.", type = "warning")
      return()
    }

    show_alert(title = "Merci pour votre suggestion !", type = "success")
    suggestions <- as.data.table(rbind(
      suggestions,
      cbind(as.character(Sys.Date()), suggestion_text)
    ))
    tryCatch(
      s3write_using(
        x = suggestions,
        FUN = write_parquet,
        object = "suggestions.parquet",
        bucket = "awsbucketpf/shinycir"
      ),
      error = function(e) message("[minintCIR] Erreur sauvegarde suggestion: ", e$message)
    )
  })

  # Compute group by ----------------
  observe({
    req(data())
    d <- active_data()
    data_n(d[, .N])
    data_sexe(d[, .N, sexe][order(N, decreasing = TRUE)])
    data_pays(d[, .N, nationalite][order(N, decreasing = TRUE)])
    data_age(d[, .N, age_cat][order(N, decreasing = TRUE)])
    data_territoire(d[, .N, .(region, departement)][order(N, decreasing = TRUE)])
    data_motif(d[, .N, .(motif_agreg, motif_det)][order(N, decreasing = TRUE)])
    data_parcours(d[, .N, parcours][order(N, decreasing = TRUE)])
  })

  # Dynamic sidebar filters ----------------
  output$sidebar_exploration <- sidebar_exploration()

  ## Maj PickerInput ----------------
  observe({
    req(data_parcours())
    if (!filters_applied()) {
      updatePickerInput(session = session, inputId = "exploration_filter_sexe", choices = data_sexe()[, sexe])
      updatePickerInput(session = session, inputId = "exploration_filter_pays", choices = data_pays()[, nationalite])
      updatePickerInput(session = session, inputId = "exploration_filter_age", choices = data_age()[, age_cat])
      updatePickerInput(session = session, inputId = "exploration_filter_region", choices = unique(data_territoire()[, region]))
      updatePickerInput(session = session, inputId = "exploration_filter_departement", choices = unique(data_territoire()[, departement]))
      updatePickerInput(session = session, inputId = "exploration_filter_motif_agreg", choices = unique(data_motif()[, motif_agreg]))
      updatePickerInput(session = session, inputId = "exploration_filter_motif_det", choices = unique(data_motif()[, motif_det]))
      updatePickerInput(session = session, inputId = "exploration_filter_parcours", choices = unique(data_parcours()[, parcours]))
      updatePickerInput(session = session, inputId = "variables_compare", choices = colnames(data()))
    }
  })

  ## Apply filters ----------------
  observeEvent(input$exploration_filters_apply, {
    tmp <- data()
    filters_applied(FALSE)

    # Definition des filtres: input_id -> colonne data.table
    filter_map <- list(
      exploration_filter_sexe = "sexe",
      exploration_filter_pays = "nationalite",
      exploration_filter_age = "age_cat",
      exploration_filter_region = "region",
      exploration_filter_departement = "departement",
      exploration_filter_motif_agreg = "motif_agreg",
      exploration_filter_motif_det = "motif_det",
      exploration_filter_parcours = "parcours"
    )

    for (input_id in names(filter_map)) {
      vals <- input[[input_id]]
      if (!is.null(vals) && length(vals) > 0) {
        col <- filter_map[[input_id]]
        tmp <- tmp[get(col) %in% vals]
        filters_applied(TRUE)
      }
    }

    if (filters_applied()) {
      data_filtered(tmp)
    }
  })

  ## Reset filters ----------------
  observeEvent(input$exploration_filters_reset, {
    filters_applied(FALSE)
  })

  # Highcharts graphs tab1 ----------------
  # Helper pour rendre un graphique d'exploration
  render_explore_graph <- function(output_id, data_reactive, group = FALSE) {
    observe({
      output[[output_id]] <- renderHighchart(graph_explore(
        data = data_reactive(),
        input_type = input$highchart_stats_type,
        input_pct = input$highchart_stats_pct,
        group = group
      ))
    })
  }

  render_explore_graph("highchart_stats_sexe", data_sexe)
  render_explore_graph("highchart_stats_pays", data_pays)
  render_explore_graph("highchart_stats_age", data_age)
  render_explore_graph("highchart_stats_parcours", data_parcours)
  render_explore_graph("highchart_stats_territoire", data_territoire, group = TRUE)
  render_explore_graph("highchart_stats_motif", data_motif, group = TRUE)

  # Comparisons ----------------
  observeEvent(input$variables_compare, {
    req(input$variables_compare)
    if (length(input$variables_compare) > 0) {
      updatePickerInput(
        session = session,
        inputId = "modalites_compare",
        choices = unique(data()[, get(input$variables_compare)]),
        selected = NULL
      )
    }
  })

  # Helper pour rendre un graphique de comparaison
  render_compare_graph <- function(output_id, group_col) {
    observe({
      req(input$variables_compare)
      req(input$modalites_compare)
      req(input$highchart_compare_pct)
      d <- active_data()
      output[[output_id]] <- renderHighchart(
        graph_compare(d, group_col, input$variables_compare, input$modalites_compare, input$highchart_compare_pct)
      )
    })
  }

  render_compare_graph("highchart_compare_pays", "nationalite")
  render_compare_graph("highchart_compare_sexe", "sexe")
  render_compare_graph("highchart_compare_age", "age_cat")
  render_compare_graph("highchart_compare_territoire", "departement")
  render_compare_graph("highchart_compare_motif", "motif_det")
  render_compare_graph("highchart_compare_parcours", "parcours")

  # Raw data & export ----------------
  observe({
    d <- active_data()
    output$exploration_donnees_brutes <- create_dt(d, length = 15, cols_names = colnames(d), select_cols = FALSE)
  })

  observe({
    d <- active_data()
    label <- if (filters_applied()) "data_filtered_2020" else "data_2020"
    output$downloadData <- dl_button_serv(data = d, label = label)
  })

  # Radio buttons state ----------------
  observe({
    req(input$highchart_stats_type)
    if (input$highchart_stats_type %in% "pie") {
      updateRadioGroupButtons(session = session, inputId = "highchart_stats_pct", selected = "niv", disabled = TRUE)
    } else {
      updateRadioGroupButtons(session = session, inputId = "highchart_stats_pct", disabled = FALSE)
    }
  })

  observe({
    if (is.null(input$modalites_compare)) {
      updateRadioGroupButtons(session = session, inputId = "highchart_compare_pct", disabled = TRUE)
    } else {
      updateRadioGroupButtons(session = session, inputId = "highchart_compare_pct", disabled = FALSE)
    }
  })

  # Sever (deconnexion) ----------------
  disconnected <- tagList(
    h1("Oups, quelque chose s'est mal passe !"),
    p("Il semble que vous ayez ete deconnecte. Veuillez rafraichir la page ou revenir plus tard."),
    reload_button("Rafraichir", class = "warning")
  )
  sever(html = disconnected, bg_color = "#000")
}
