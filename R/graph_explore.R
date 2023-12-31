

#' Title
#'
#' @param data
#' @param input_switch
#' @param input_pct
#'
#' @return
#' @export
#'
#' @examples
graph_explore <- function(data,
                          input_switch,
                          input_pct,
                          group = FALSE) {
  if(!group){
    colnames(data) <- c("var","N")
    data[,pct := round(N/sum(N),4)]
    if(input_switch){
      if(input_pct) {
        return(hchart(data, type = "bar",hcaes(x = var, y = N)))
      } else {
        return(hchart(data, type = "bar",hcaes(x = var, y = pct)))
      }
    }else{
      data_treemap <- data_to_hierarchical(data, c("var", "N"))
      return(hchart(data_treemap, type = "treemap"))
    }
  } else {
    colnames(data) <- c("agreg","var","N")
    data[,pct := round(N/sum(N),4)]
    if(input_switch){
      if(input_pct) {
        return(hchart(data, type = "bar",hcaes(x = var, y = N, group = agreg)))
      } else {
        return(hchart(data, type = "bar",hcaes(x = var, y = pct, group = agreg)))
      }
    }else{
      data_treemap <- data_to_hierarchical(data,group_vars = c("agreg","var"), size_var = "N")
      return(hchart(data_treemap, type = "treemap"))
    }
  }
}
