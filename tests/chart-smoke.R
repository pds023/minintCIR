# Run from the project root or against the installed package during R CMD check.
if (.Platform$OS.type == "windows") Sys.setlocale("LC_CTYPE", ".UTF-8")
if (dir.exists("R")) {
  source("R/chart_theme.R", encoding = "UTF-8")
  source("R/graph_explore.R", encoding = "UTF-8")
  source("R/graph_compare.R", encoding = "UTF-8")
} else {
  library(minintCIR)
  cir_chart_points <- getFromNamespace("cir_chart_points", "minintCIR")
}

data <- data.table::data.table(category = c("A", "B"), N = c(3L, 1L))
original <- data.table::copy(data)
effectifs <- graph_explore(data, "bar", "niv")$x$hc_opts
shares <- graph_explore(data, "bar", "percent")$x$hc_opts
stopifnot(
  identical(data, original),
  identical(vapply(effectifs$series[[1]]$data, `[[`, numeric(1), "y"), c(3, 1)),
  identical(vapply(shares$series[[1]]$data, `[[`, numeric(1), "y"), c(75, 25)),
  identical(shares$yAxis$max, 100),
  identical(shares$series[[1]]$data[[1]]$custom$shareLabel, "75,0 %"),
  is.null(graph_explore(data[0], "bar", "niv"))
)

# Named scalars must remain numbers when htmlwidgets serializes the points.
named_points <- cir_chart_points(c(first = "A", second = "B"), c(A = 3, B = 1), c(total = 4), TRUE)
serialized <- jsonlite::toJSON(named_points, auto_unbox = TRUE, keep_vec_names = TRUE)
decoded <- jsonlite::fromJSON(serialized, simplifyVector = FALSE)
stopifnot(identical(decoded[[1]]$name, "A"),
          identical(decoded[[1]]$y, 75L),
          identical(decoded[[1]]$custom$count, 3L),
          identical(decoded[[1]]$custom$share, 75L))

# Highcharts expects an array even after filtering down to one category.
single <- graph_explore(data.table::data.table(category = "Femmes", N = 3L), "bar", "niv")$x$hc_opts
category_json <- jsonlite::toJSON(single$xAxis$categories, auto_unbox = TRUE)
stopifnot(identical(single$xAxis$categories, list("Femmes")),
          identical(as.character(category_json), '["Femmes"]'),
          identical(single$series[[1]]$name, "CIR"))

many <- data.table::data.table(category = letters[1:20], N = 20:1)
top <- graph_explore(many, "bar", "percent")$x$hc_opts
stopifnot(length(top$xAxis$categories) == 12L,
          sum(vapply(top$series[[1]]$data, `[[`, numeric(1), "y")) < 100,
          grepl("12", top$subtitle$text))
tree <- graph_explore(data, "pie", "niv")$x$hc_opts
tree_percent <- graph_explore(data, "pie", "percent")$x$hc_opts
stopifnot(identical(tree$series[[1]]$type, "treemap"),
          sum(vapply(tree$series[[1]]$data, `[[`, numeric(1), "value")) == 4,
          identical(tree$series[[1]]$data, tree_percent$series[[1]]$data),
          grepl("shareLabel", tree_percent$series[[1]]$dataLabels$format),
          identical(tree_percent$series[[1]]$data[[1]]$custom$shareLabel, "75,0 %"))

records <- data.table::data.table(category = c("A", "A", "B", "B"),
                                 group = c("G1", "G1", "G1", "G2"))
original <- data.table::copy(records)
comparison <- graph_compare(records, "category", "group", c("G1", "G2"), "percent")$x$hc_opts
values <- lapply(comparison$series, function(series) vapply(series$data, `[[`, numeric(1), "y"))
stopifnot(identical(records, original),
          isTRUE(all.equal(values[[1]], c(200 / 3, 100 / 3))),
          identical(values[[2]], c(0, 100)),
          identical(comparison$xAxis$categories, list("A", "B")),
          is.null(graph_compare(records, "category", "group", "absent", "niv")))

single_comparison <- graph_compare(records[group == "G2"], "category", "group", "G2", "niv")$x$hc_opts
stopifnot(identical(single_comparison$xAxis$categories, list("B")),
          identical(single_comparison$series[[1]]$name, "G2"),
          identical(as.character(jsonlite::toJSON(single_comparison$xAxis$categories,
                                                  auto_unbox = TRUE)), '["B"]'))

many_records <- data.table::data.table(category = letters[1:20], group = "G1")
limited <- graph_compare(many_records, "category", "group", "G1", "percent")$x$hc_opts
stopifnot(length(limited$series[[1]]$data) == 12L,
          sum(vapply(limited$series[[1]]$data, `[[`, numeric(1), "y")) == 60,
          is.null(graph_compare(records[0], "category", "group", "G1", "niv")))

grouped <- records[, .N, by = .(group, category)]
original <- data.table::copy(grouped)
stopifnot(inherits(graph_explore(grouped, "bar", "percent", TRUE), "highchart"),
          inherits(graph_explore(grouped, "pie", "niv", TRUE), "highchart"),
          identical(grouped, original))
cat("Chart smoke checks passed.\n")
