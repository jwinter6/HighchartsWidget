# libs
library(highcharter)
library(shiny)


# Functions

# data generator
getData <- function(n) {
  data.frame(x = rpois(n, 100 * rbeta(n, .8, .4)), 
             y = rpois(n, 100 * rbeta(n, .8, .4)))
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



# CPU time
n <- 100000

# 1-dim JSON
system.time({
  d <- getData(n)
  d <- lapply(seq_len(nrow(d)), function(i) {
    as.numeric(d[i, ])
  })
  highchart() %>%
    hc_add_series(data = d, type = "scatter")
}) # 17s (lapply takes long)

# complex array JSON
system.time({
  d <- getData(n)
  highchart() %>%
    hc_add_series(data = d, type = "scatter")
}) # 2s




# in app

# Using Highchart Output, JSON as 1-dim array
# 45s to plot, responsive afterwards
ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    h3("Simulate Data"),
    numericInput("n", "number of points", 10),
    actionButton("go", "go")
  ),
  mainPanel(
    highchartOutput("plot")
  )
))

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  sim <- eventReactive(input$go, {
    getData(input$n)
  })
  output$plot <- renderHighchart({
    d <- lapply(seq_len(nrow(sim())), function(i) {
      as.numeric(sim()[i, ])
    })
    hc <- highchart() %>%
      hc_add_series(data = d, type = "scatter")
    hc
  })
}

runApp(list(ui = ui, server = server))


# Using Highchart Output, JSON as complex object
# 43s to plot, responsive afterwards
ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    h3("Simulate Data"),
    numericInput("n", "number of points", 10),
    actionButton("go", "go")
  ),
  mainPanel(
    highchartOutput("plot")
  )
))

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  sim <- eventReactive(input$go, {
    getData(input$n)
  })
  output$plot <- renderHighchart({
    hc <- highchart() %>%
      hc_add_series(data = sim(), type = "scatter")
    hc
  })
}

runApp(list(ui = ui, server = server))




# writing js

# write 1-dim JSON
d <- getData(n)
d <- lapply(seq_len(nrow(d)), function(i) {
  as.numeric(d[i, ])
})
hc <- highchart() %>%
  hc_add_series(data = d, type = "scatter")
export_hc(hc, "1d.json")

# write complex JSON
d <- getData(n)
hc <- highchart() %>%
  hc_add_series(data = d, type = "scatter")
export_hc(hc, "complex.json")








# app
ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    tags$head(highcharts()),
    radioButtons("src", "source", list("1d", "complex"))
  ),
  mainPanel(
    uiOutput("plot")
  )
))
server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  output$plot <- renderUI({
    src <- switch(
      input$src,
      "1d.js"
    )
    id <- "container"
    tagList(
      style(id),
      tags$script(src = src),
      tags$div(id = id) 
    )
  })
}
runApp(list(ui = ui, server = server))



