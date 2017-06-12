# libs
library(highcharter)
library(shiny)
library(BiocParallel)


# data generator
getData <- function(n) {
  data.frame(x = rnorm(n, 100 * rbeta(n, .4, .4)), 
             y = rnorm(n, 100 * rbeta(n, .4, .4)))
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


#' highcharts
#' 
#' use in tags$head, load libraries
#' 
highcharts <- function() {
  tagList(
    tags$script(src = "https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"),
    tags$script(src = "http://code.highcharts.com/highcharts.js"),
    tags$script(src = "https://code.highcharts.com/modules/boost.js")
  )
}


#' style
#' 
#' Define Style for highcharts container
#'
style <- function(id, minWidth = "400px", maxWidth = "1000px",
                  height = "800px", margin = "0 auto") {
  str <- sprintf("#%s { min-width: %s; max-width: %s; height: %s; margin: %s }",
                 id, minWidth, maxWidth, height, margin) 
  return(tags$style(str, type = "text/css"))
}








# Actual App --------------------------------------------------------------

nproc <- 4
bpparams <- SnowParam(workers = nproc, type = "SOCK")

ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    tags$head(highcharts()),
    h3("Simulate Data"),
    numericInput("n", "number of points", 10),
    actionButton("go", "go")
  ),
  mainPanel(
    uiOutput("plot")
  )
))

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  sim <- eventReactive(input$go, {
    getData(input$n)
  })
  
  output$plot <- renderUI({
    d <- sim()
    d <- bplapply(seq_len(nrow(d)), function(i) {
      as.numeric(d[i, ])
    }, BPPARAM=bpparams)
    opts <- list(
      chart = list(zoomType = "xy"),
      scatter = list(turboThreshold = 0),
      boost = list(useGPUTranslations = TRUE, usePreAllocated = TRUE)
    )
    hc <- highchart(opts) %>%
      hc_add_series(data = d, type = "scatter", marker = list(radius = .5))
    id <- sprintf("highchartsPlot_%s", paste(sample(letters, 6), collapse = ""))
    str <- str_hc(hc, id)
    tagList(
      style(id),
      div(id = id),
      tags$script(str)
    )
  })
}

runApp(list(ui = ui, server = server))


