#' Cree un groupe de boutons radio
#'
#' Wrapper autour de shinyWidgets::radioGroupButtons avec des presets
#' pour differents types de boutons (unite, pourcentage, type de graphique).
#'
#' @param id Identifiant du widget.
#' @param type Type de radio : "unite", "pct" ou "graph".
#' @param disabled_state Etat desactive initial.
#'
#' @return Un tag shiny radioGroupButtons.
#' @export
create_radio <- function(id, type, disabled_state = FALSE) {
  radio_configs <- list(
    unite = list(
      choices = c(`<i class="fa-solid fa-cube"></i>` = "nb",
                  `<i class="fa-solid fa-euro-sign"></i>` = "val"),
      selected = "val"
    ),
    pct = list(
      choices = c("Effectifs" = "niv", "Pourcentage" = "percent"),
      selected = "niv"
    ),
    graph = list(
      choices = c("Barres" = "bar", "Mosaïque" = "pie"),
      selected = "bar"
    )
  )

  cfg <- radio_configs[[type]]
  if (is.null(cfg)) return(NULL)

  radioGroupButtons(
    inputId = id,
    label = NULL,
    choices = cfg$choices,
    selected = if (length(cfg$selected) > 0) cfg$selected else character(0),
    justified = FALSE,
    disabled = disabled_state
  )
}
