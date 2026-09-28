# Shared labels keep filters, comparisons and exports readable.
cir_variable_labels <- function() {
  c(
    annee = "Année", region = "Région / D.O.M.", nom = "Direction territoriale",
    departement = "Département", motif_agreg = "Motif de séjour",
    motif_det = "Motif détaillé", sexe = "Sexe", nationalite = "Nationalité",
    age_cat = "Tranche d’âge", parcours = "Parcours linguistique",
    fl_prescrite = "Formation linguistique prescrite"
  )
}

cir_filter_map <- function() {
  c(
    exploration_filter_sexe = "sexe", exploration_filter_pays = "nationalite",
    exploration_filter_age = "age_cat", exploration_filter_region = "region",
    exploration_filter_departement = "departement",
    exploration_filter_motif_agreg = "motif_agreg",
    exploration_filter_motif_det = "motif_det",
    exploration_filter_parcours = "parcours"
  )
}

load_cir_data <- function() {
  configured <- getOption("minintCIR.data_path", Sys.getenv("CIR_DATA_PATH", ""))
  if (length(configured) != 1L || is.na(configured)) {
    stop("Le chemin des données CIR doit désigner un seul fichier Parquet.")
  }
  candidates <- if (nzchar(configured)) {
    configured
  } else {
    c(app_sys("extdata", "data_2020.parquet"),
      file.path("inst", "extdata", "data_2020.parquet"),
      file.path("data", "data_2020.parquet"))
  }
  candidates <- candidates[nzchar(candidates) & file.exists(candidates)]
  if (!length(candidates)) {
    stop("Fichier CIR introuvable. Vérifiez le fichier fourni ou le chemin CIR_DATA_PATH.")
  }
  data <- data.table::as.data.table(arrow::read_parquet(candidates[[1L]]))
  required <- c("annee", unname(cir_filter_map()))
  missing <- setdiff(required, names(data))
  if (length(missing)) {
    stop("Colonnes manquantes dans les données CIR : ", paste(missing, collapse = ", "), ".")
  }
  if (!nrow(data) || all(is.na(data$annee))) {
    stop("Le fichier CIR ne contient aucune observation datée.")
  }
  for (column in names(data)) {
    if (is.character(data[[column]]) || is.factor(data[[column]])) {
      data.table::set(data, j = column, value = trimws(as.character(data[[column]])))
    }
  }
  if ("fl_prescrite" %in% names(data)) {
    no_prescription <- (is.na(data$parcours) | data$parcours == "") &
      !is.na(data$fl_prescrite) & tolower(data$fl_prescrite) == "non"
    data.table::set(data, i = which(no_prescription), j = "parcours", value = "Sans prescription")
  }
  for (column in unname(cir_filter_map())) {
    values <- as.character(data[[column]])
    values[is.na(values) | values == ""] <- "Non renseigné"
    data.table::set(data, j = column, value = values)
  }
  data
}

filter_cir_data <- function(data, filters) {
  for (input_id in intersect(names(filters), names(cir_filter_map()))) {
    selected <- filters[[input_id]]
    if (length(selected)) {
      column <- cir_filter_map()[[input_id]]
      data <- data[data[[column]] %in% selected]
    }
  }
  data
}

cir_choices <- function(data, column) {
  values <- sort(unique(as.character(data[[column]])), na.last = TRUE)
  ordered <- switch(column,
    age_cat = c("16-18 ans", "19-25 ans", "26-45 ans", "46-65 ans", "Plus 65 ans"),
    parcours = c("Sans prescription", "100 heures", "200 heures", "400 heures", "600 heures"),
    character()
  )
  c(intersect(ordered, values), setdiff(values, ordered))
}

cir_format_number <- function(value, digits = 0L) {
  format(round(value, digits), big.mark = " ", decimal.mark = ",",
         nsmall = digits, scientific = FALSE, trim = TRUE)
}
