# Run from the project root with: Rscript tests/server-smoke.R
# These checks also run against the installed package during R CMD check.
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
library(shiny)
library(data.table)
library(DT)
library(highcharter)

if (dir.exists("R")) {
  for (file in list.files("R", pattern = "[.]R$", full.names = TRUE)) {
    source(file, encoding = "UTF-8")
  }
} else {
  for (name in c("app_server", "load_cir_data", "filter_cir_data", "cir_filter_map", "cir_choices")) {
    assign(name, getFromNamespace(name, "minintCIR"))
  }
}

data <- load_cir_data()
stopifnot(nrow(data) == 78764L, sum(data$sexe == "Femmes") == 36392L,
          sum(data$parcours == "Sans prescription") == 42617L,
          sum(data$age_cat == "Non renseigné") == 14L,
          all(data$motif_agreg == trimws(data$motif_agreg)))
stopifnot(nrow(filter_cir_data(data, list(exploration_filter_sexe = "Femmes"))) == 36392L,
          nrow(filter_cir_data(data, list(exploration_filter_sexe = "Absent"))) == 0L,
          identical(cir_choices(data, "parcours")[[1L]], "Sans prescription"))

old_path <- getOption("minintCIR.data_path")
options(minintCIR.data_path = "__missing_cir_file__.parquet")
missing_error <- tryCatch(load_cir_data(), error = identity)
options(minintCIR.data_path = old_path)
stopifnot(inherits(missing_error, "error"))

testServer(app_server, {
  sent <- list()
  table_rows <- NULL
  session$sendInputMessage <- function(inputId, message) {
    sent[[inputId]] <<- message
  }
  session$registerDataObj <- function(name, data, filterFunc) {
    table_rows <<- nrow(data)
    "/session/test/data"
  }
  session$setInputs(highchart_stats_type = "bar", highchart_stats_pct = "niv",
    variables_compare = "sexe", modalites_compare = c("Femmes", "Hommes"),
    highchart_compare_pct = "niv")
  stopifnot(nrow(active_data()) == 78764L, output$data_period == "2020",
            grepl("46,2", output$summary_cards$html, fixed = TRUE),
            !grepl("Sélection modifiée", output$filter_summary$html, fixed = TRUE))
  table <- output$exploration_donnees_brutes
  stopifnot(identical(table_rows, 78764L))
  for (kind in c("stats", "compare")) {
    for (dimension in c("sexe", "pays", "age", "territoire", "motif", "parcours")) {
      chart <- output[[paste("highchart", kind, dimension, sep = "_")]]
      stopifnot(is.character(chart), nzchar(chart))
    }
  }
  original_chart <- output$highchart_stats_sexe

  # Editing a selection has no effect until Apply is pressed.
  session$setInputs(exploration_filter_sexe = "Femmes")
  stopifnot(nrow(active_data()) == 78764L,
            grepl("Sélection modifiée", output$filter_summary$html, fixed = TRUE))
  session$setInputs(exploration_filters_apply = 1)
  stopifnot(nrow(active_data()) == 36392L,
            !identical(output$highchart_stats_sexe, original_chart),
            grepl("Femmes", output$active_filters$html, fixed = TRUE),
            !grepl("Sélection modifiée", output$filter_summary$html, fixed = TRUE))
  table <- output$exploration_donnees_brutes
  stopifnot(identical(table_rows, 36392L))
  downloaded <- data.table::fread(output$downloadData)
  stopifnot(nrow(downloaded) == 36392L, all(downloaded$sexe == "Femmes"))

  # A valid but incompatible combination clears every chart with a message.
  session$setInputs(exploration_filter_region = "Bourgogne-Franche-Comté",
    exploration_filter_departement = "Val-de-Marne", exploration_filters_apply = 2)
  stopifnot(nrow(active_data()) == 0L,
            grepl("0 lignes", output$data_caption, fixed = TRUE))
  table <- output$exploration_donnees_brutes
  stopifnot(identical(table_rows, 0L))
  for (kind in c("stats", "compare")) {
    for (dimension in c("sexe", "pays", "age", "territoire", "motif", "parcours")) {
      empty_chart <- tryCatch(output[[paste("highchart", kind, dimension, sep = "_")]], error = identity)
      stopifnot(inherits(empty_chart, "shiny.silent.error"),
                grepl("Aucun contrat", conditionMessage(empty_chart), fixed = TRUE))
    }
  }
  stopifnot(nrow(data.table::fread(output$downloadData)) == 0L)

  sent <- list()
  session$setInputs(exploration_filters_reset = 1)
  table <- output$exploration_donnees_brutes
  stopifnot(nrow(active_data()) == 78764L, length(applied_filters()) == 0L,
            identical(table_rows, 78764L),
            all(names(cir_filter_map()) %in% names(sent)),
            all(vapply(sent[names(cir_filter_map())], function(message) length(message$value) == 0L, logical(1))))
  # Browser inputs acknowledge reset; a fresh Apply keeps the full dataset.
  cleared <- stats::setNames(rep(list(character(0)), length(cir_filter_map())), names(cir_filter_map()))
  do.call(session$setInputs, cleared)
  stopifnot(!grepl("Sélection modifiée", output$filter_summary$html, fixed = TRUE))
  session$setInputs(exploration_filters_apply = 3)
  stopifnot(nrow(active_data()) == 78764L)

  session$setInputs(modalites_compare = character(0))
  no_modalities <- tryCatch(output$highchart_compare_pays, error = identity)
  stopifnot(inherits(no_modalities, "shiny.silent.error"),
            grepl("modalité", conditionMessage(no_modalities), fixed = TRUE))
})

options(minintCIR.data_path = "__missing_cir_file__.parquet")
testServer(app_server, {
  session$flushReact()
  for (id in c("summary_cards", "data_caption", "highchart_stats_pays", "exploration_donnees_brutes")) {
    load_error <- tryCatch(output[[id]], error = identity)
    stopifnot(inherits(load_error, "shiny.silent.error"),
              grepl("introuvable", conditionMessage(load_error), fixed = TRUE))
  }
})
options(minintCIR.data_path = old_path)

cat("Server smoke checks passed: local data, filters, reset, charts, table, CSV export and missing data.\n")
