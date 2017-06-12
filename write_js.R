# libs
library(highcharter)


# data generator
getData <- function(n) {
  data.frame(x = rpois(n, 100 * rbeta(n, .8, .4)), 
             y = rpois(n, 100 * rbeta(n, .8, .4)))
}

#' str_hc
#' 
#' Convert the \code{highcharter} object to a \code{chr} string.
#'  
str_hc <- function (hc, id) {
  . <- NULL
  jslns <- hc$x$hc_opts %>% 
    jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, force = TRUE, null = "null") %>% 
    stringr::str_split("\n") %>% 
    head(1) %>% 
    unlist() %>% 
    stringr::str_replace("\"", "") %>% 
    stringr::str_replace("\":", ":")
  fflag <- stringr::str_detect(jslns, "function()")
  if (any(fflag)) {
    jslns <- ifelse(fflag, stringr::str_replace(jslns, "\"function", "function"), jslns)
    jslns <- ifelse(fflag, stringr::str_replace(jslns, "\",$", ","), jslns)
    jslns <- ifelse(fflag, stringr::str_replace(jslns, "\"$", ""), jslns)
    jslns <- ifelse(
      fflag, 
      stringr::str_replace_all(jslns, "\\\\n", str_c("\\\\n", stringr::str_extract(jslns, "^\\s+"))), 
      jslns
    )
  }
  jslns <- jslns %>% 
    unlist() %>% 
    tail(-1) %>% 
    stringr::str_c("    ",., collapse = " ") %>% 
    stringr::str_replace_all("\\s\\]\\,\\s\\[\\s", "],[") %>% 
    stringr::str_replace_all("\\s{2,}", " ") %>% 
    sprintf("$(function () { $('#%s').highcharts({ %s ); });", id, .)
  return(jslns)
}






# write js für 100 k points
sim <- getData(100)
id <- "highchartsPlot"

hc <- highchart() %>%
  hc_add_series(data = sim, "point", hcaes(x = x, y = y))
str <- str_hc(hc, id)
writeLines(str, "www/plot.js")








