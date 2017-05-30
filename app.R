# libs
library(highcharter)
library(shiny)


# Functions

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

#' highcharts
#' 
#' Load all the latest highcharts modules. 
#' 
highcharts <- function() {
  tagList(
    tags$script(src = "https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"),
    tags$script(src = "http://code.highcharts.com/highcharts.js"),
    tags$script(src = "http://code.highcharts.com/highcharts-more.js"),
    tags$script(src = "http://code.highcharts.com/highcharts-3d.js"),
    tags$script(src = "http://code.highcharts.com/modules/accessibility.js"),
    tags$script(src = "http://code.highcharts.com/modules/annotations.js"),
    tags$script(src = "http://code.highcharts.com/modules/boost.js"),
    tags$script(src = "http://code.highcharts.com/modules/broken-axis.js"),
    tags$script(src = "http://code.highcharts.com/modules/canvas-tools.js"),
    tags$script(src = "http://code.highcharts.com/modules/data.js"),
    tags$script(src = "http://code.highcharts.com/modules/exporting.js"),
    tags$script(src = "http://code.highcharts.com/modules/drilldown.js"),
    tags$script(src = "http://code.highcharts.com/modules/funnel.js"),
    tags$script(src = "http://code.highcharts.com/modules/heatmap.js"),
    tags$script(src = "http://code.highcharts.com/modules/no-data-to-display.js"),
    tags$script(src = "http://code.highcharts.com/modules/offline-exporting.js"),
    tags$script(src = "http://code.highcharts.com/modules/solid-gauge.js"),
    tags$script(src = "http://code.highcharts.com/modules/treemap.js")
  )
}

#' style
#' 
#' Define Style for highchart scontainer
#'
style <- function(id, minWidth = "310px", maxWidth = "1000px",
                  height = "800px", margin = "0 auto") {
 str <- sprintf("#%s { min-width: %s; max-width: %s; height: %s; margin: %s }",
                id, minWidth, maxWidth, height, margin) 
 return(tags$style(str, type = "text/css"))
}



# actual app
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
  
  # generate data
  sim <- eventReactive(input$go, {
    getData(input$n)
  })
  
  # make plot
  output$plot <- renderUI({
    hc <- highchart() %>%
      hc_add_series(data = sim(), "point", hcaes(x = x, y = y))

    # return taglist w/ style definition, jquery chr str, div
    id <- "highcharter_plot"
    tagList(
      style(id),
      tags$script(str_hc(hc, id)),
      tags$div(id = id) 
    )
  })
}

runApp(list(ui = ui, server = server))








