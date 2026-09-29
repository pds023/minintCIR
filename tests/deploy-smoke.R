# Run from the project root: Rscript tests/deploy-smoke.R
# Deployment files are deliberately excluded from the installed R package.
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
if (dir.exists("R")) stopifnot(file.exists("manifest.json"))

if (file.exists("manifest.json")) local({
  manifest <- jsonlite::read_json("manifest.json")
  files <- names(manifest$files)
  packages <- names(manifest$packages)
  stopifnot(
    identical(manifest$metadata$appmode, "shiny"),
    !"minintCIR" %in% packages,
    all(c("pkgload", "golem", "shiny", "arrow") %in% packages),
    all(c("app.R", "DESCRIPTION", "NAMESPACE", "LICENSE",
          "inst/extdata/data_2020.parquet", "inst/app/www/styles.css") %in% files),
    all(file.exists(files)),
    identical(unname(tools::md5sum(files)),
              unname(vapply(manifest$files, `[[`, character(1), "checksum")))
  )

  # Start from exactly the files Connect receives, without an installed minintCIR.
  bundle <- tempfile("cir-connect-bundle-")
  dir.create(bundle)
  for (file in files) {
    destination <- file.path(bundle, file)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file, destination))
  }
  previous <- setwd(bundle)
  on.exit(setwd(previous))
  app <- source("app.R", local = new.env())$value
  stopifnot(
    inherits(app, "shiny.appobj"),
    isTRUE(getOption("golem.app.prod")),
    identical(app$options$launch.browser, FALSE),
    nrow(getFromNamespace("load_cir_data", "minintCIR")()) == 78764L,
    inherits(getFromNamespace("app_ui", "minintCIR")(NULL), "shiny.tag.list")
  )
  cat("Deployment checks passed: manifest, checksums and golem source bundle startup.\n")
})
