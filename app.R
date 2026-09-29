# Launch the ShinyApp (Do not remove this comment)
# Prepare the Posit Connect manifest with source("dev/03_deploy.R").

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options(golem.app.prod = TRUE)
# Dynamic lookup keeps rsconnect from treating this source package as a dependency.
getExportedValue("minintCIR", "run_app")(options = list(launch.browser = FALSE))
