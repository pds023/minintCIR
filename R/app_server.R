#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  data_error <- NULL
  data <- tryCatch(load_cir_data(), error = function(error) {
    data_error <<- conditionMessage(error)
    NULL
  })
  filter_map <- cir_filter_map()
  labels <- cir_variable_labels()
  applied_filters <- reactiveVal(list())

  active_data <- reactive({
    validate(need(!is.null(data), data_error))
    filter_cir_data(data, applied_filters())
  })

  selected_filters <- reactive({
    selected <- lapply(names(filter_map), function(id) input[[id]])
    names(selected) <- names(filter_map)
    selected <- Filter(length, selected)
    if (length(selected)) selected else list()
  })

  # Choices always come from the complete dataset, including after filtering.
  observeEvent(TRUE, {
    req(!is.null(data))
    for (id in names(filter_map)) {
      shinyWidgets::updatePickerInput(session, id,
        choices = cir_choices(data, filter_map[[id]]), selected = character(0))
    }
    compare_columns <- intersect(names(labels), names(data))
    shinyWidgets::updatePickerInput(session, "variables_compare",
      choices = stats::setNames(compare_columns, labels[compare_columns]), selected = "sexe")
  }, once = TRUE)

  observeEvent(input$exploration_filters_apply, {
    applied_filters(selected_filters())
  })

  observeEvent(input$exploration_filters_reset, {
    for (id in names(filter_map)) {
      shinyWidgets::updatePickerInput(session, id, selected = character(0))
    }
    applied_filters(list())
  })

  output$data_period <- renderText({
    validate(need(!is.null(data), data_error))
    paste(sort(unique(stats::na.omit(data$annee))), collapse = " · ")
  })

  output$summary_cards <- renderUI({
    d <- active_data()
    count <- nrow(d)
    female_labels <- c("femmes", "femme", "f", "féminin", "feminin")
    female_known <- any(tolower(data$sexe) %in% female_labels)
    female_share <- if (count && female_known) {
      paste0(cir_format_number(100 * sum(tolower(d$sexe) %in% female_labels) / count, 1), " %")
    } else "—"
    metric <- function(label, value, detail, icon) {
      div(class = "metric-card",
        div(class = "metric-icon", bsicons::bs_icon(icon)),
        div(class = "metric-label", label),
        div(class = "metric-value", value),
        div(class = "metric-detail", detail))
    }
    tagList(
      metric("Contrats signés", cir_format_number(count), "Dans le périmètre sélectionné", "file-earmark-text"),
      metric("Part des femmes", female_share,
        if (female_known) "Parmi les contrats sélectionnés" else "Modalité non disponible", "gender-female"),
      metric("Nationalités", cir_format_number(data.table::uniqueN(d$nationalite[d$nationalite != "Non renseigné"])),
        "Représentées dans la sélection", "globe2"),
      metric("Régions et D.O.M.", cir_format_number(data.table::uniqueN(d$region[d$region != "Non renseigné"])),
        "Territoires représentés", "geo-alt")
    )
  })

  output$filter_summary <- renderUI({
    active_data()
    count <- length(applied_filters())
    pending <- !identical(selected_filters(), applied_filters())
    div(class = "filter-summary", role = "status",
      strong(if (count) paste(count, if (count > 1L) "filtres appliqués" else "filtre appliqué") else "Tous les contrats"),
      span(if (pending) "Sélection modifiée · appliquez pour actualiser" else if (count) "Périmètre personnalisé" else "Aucun filtre appliqué"))
  })

  output$active_filters <- renderUI({
    filters <- applied_filters()
    if (!length(filters)) return(NULL)
    tagList(lapply(names(filters), function(id) {
      values <- filters[[id]]
      title <- paste0(labels[[filter_map[[id]]]], " : ", paste(values, collapse = ", "))
      text <- if (length(values) > 2L) paste0(labels[[filter_map[[id]]]], " · ", length(values), " choix") else title
      span(class = "active-filter", title = title, text)
    }))
  })

  output$selection_status <- renderUI({
    count <- nrow(active_data())
    percent <- 100 * count / nrow(data)
    div(class = "selection-status", role = "status",
      strong(paste(cir_format_number(count), "contrats")),
      span(paste0("sur ", cir_format_number(nrow(data)), " · ", cir_format_number(percent, 1), " % du total")))
  })

  output$data_caption <- renderText({
    paste(cir_format_number(nrow(active_data())), "lignes dans le périmètre sélectionné")
  })

  render_explore_graph <- function(output_id, columns) {
    output[[output_id]] <- highcharter::renderHighchart({
      d <- active_data()
      validate(need(nrow(d) > 0L, "Aucun contrat ne correspond à ces filtres. Modifiez-les ou réinitialisez la sélection."))
      grouped <- d[, .N, by = columns]
      data.table::setorderv(grouped, "N", -1L)
      graph_explore(grouped,
        if (is.null(input$highchart_stats_type)) "bar" else input$highchart_stats_type,
        if (is.null(input$highchart_stats_pct)) "niv" else input$highchart_stats_pct,
        group = length(columns) > 1L)
    })
  }
  render_explore_graph("highchart_stats_sexe", "sexe")
  render_explore_graph("highchart_stats_pays", "nationalite")
  render_explore_graph("highchart_stats_age", "age_cat")
  render_explore_graph("highchart_stats_parcours", "parcours")
  render_explore_graph("highchart_stats_territoire", c("region", "departement"))
  render_explore_graph("highchart_stats_motif", c("motif_agreg", "motif_det"))

  observeEvent(input$variables_compare, {
    req(!is.null(data), input$variables_compare %in% names(data))
    choices <- cir_choices(data, input$variables_compare)
    shinyWidgets::updatePickerInput(session, "modalites_compare",
      choices = choices, selected = utils::head(choices, 2L))
  })

  render_compare_graph <- function(output_id, column) {
    output[[output_id]] <- highcharter::renderHighchart({
      d <- active_data()
      variable <- input$variables_compare
      modalities <- input$modalites_compare
      validate(need(nrow(d) > 0L, "Aucun contrat ne correspond à ces filtres. Modifiez-les ou réinitialisez la sélection."))
      validate(need(length(variable) == 1L && variable %in% names(d), "Choisissez une variable à comparer."))
      validate(need(length(modalities) > 0L, "Sélectionnez au moins une modalité à comparer."))
      validate(need(any(d[[variable]] %in% modalities), "Les modalités choisies ne sont pas présentes dans ce périmètre."))
      graph_compare(d, column, variable, modalities,
        if (is.null(input$highchart_compare_pct)) "niv" else input$highchart_compare_pct)
    })
  }
  render_compare_graph("highchart_compare_pays", "nationalite")
  render_compare_graph("highchart_compare_sexe", "sexe")
  render_compare_graph("highchart_compare_age", "age_cat")
  render_compare_graph("highchart_compare_territoire", "departement")
  render_compare_graph("highchart_compare_motif", "motif_det")
  render_compare_graph("highchart_compare_parcours", "parcours")

  output$exploration_donnees_brutes <- create_dt(active_data, length = 15,
    cols_names = unname(labels[names(data)]), select_cols = FALSE)

  output$downloadData <- downloadHandler(
    filename = function() {
      years <- paste(sort(unique(stats::na.omit(active_data()$annee))), collapse = "-")
      paste0("cir_", if (nzchar(years)) years else "selection", if (length(applied_filters())) "_filtre", ".csv")
    },
    content = function(file) {
      data.table::fwrite(active_data(), file, sep = ";", bom = TRUE, na = "")
    },
    contentType = "text/csv; charset=utf-8"
  )
}
