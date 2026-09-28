#' Panneau de méthode, sources et crédits
#' @return Un panneau de navigation.
#' @export
nav_menu_apropos <- function() {
  nav_panel("Comprendre", value = "comprendre", icon = bs_icon("book"),
    div(class = "page-heading compact-heading", div(
      p(class = "eyebrow", "REPÈRES & MÉTHODE"), h1("Bien lire les données"),
      p(class = "page-description", "Le contexte, les définitions et les clés pour interpréter vos résultats.")
    )),
    div(class = "method-layout",
      card(class = "prose-card", card_body(includeMarkdown(app_sys("app/www/cirmeth.md")))),
      div(
        card(class = "about-card", card_body(h2("Un projet ouvert"),
          p("Une application conçue par Philippe Fontaine pour faciliter l’exploration des données publiques de l’intégration."),
          tags$a(href = "https://github.com/pds023/minintCIR", target = "_blank", rel = "noopener noreferrer", class = "about-link", bs_icon("github"), " Consulter le code source"),
          tags$a(href = "mailto:philippe.fontaine.ds@proton.me", class = "about-link", bs_icon("envelope"), " Une question, une suggestion ?")
        )),
        card(class = "prose-card credits-card", card_body(tags$details(tags$summary("Outils et remerciements"), includeMarkdown(app_sys("app/www/apropos.md")))))
      )
    )
  )
}
