# Run from the project root: source("dev/03_deploy.R")
# Install rsconnect first if needed: install.packages("rsconnect")
# This prepares the bundle manifest; it does not publish the application.

rsconnect::writeManifest(
  appDir = ".",
  appFiles = c(
    "app.R", "DESCRIPTION", "NAMESPACE", "LICENSE", ".Rbuildignore",
    list.files(c("R", "inst"), recursive = TRUE, full.names = TRUE)
  ),
  appMode = "shiny",
  quarto = FALSE
)
