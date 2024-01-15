
#' Title
#'
#' @param id
#' @param type
#'
#' @return
#' @export
#'
#' @examples
create_radio <- function(id,
                         type) {
  if(type %in% "type"){
  radioGroupButtons(
    inputId = id,
    label = NULL,
    choices = c(`<i class='fa fa-bar-chart'></i>` = "bar",
                `<i class='fa fa-pie-chart'></i>` = "pie")
  )
  } else if(type %in% "pct"){
    radioGroupButtons(
      inputId = id,
      label = NULL,
      choices = c(`<i class="fa-solid fa-hashtag"></i>` = "nb",
                  `<i class="fa-solid fa-percent"></i>` = "pct")
    )
  }


}
