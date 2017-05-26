#!/usr/bin/env Rscript
# start R shiny app in browser


library(highcharter)
library(shiny)


getData <- function(n) {
  data.frame(x = rpois(n, 100 * rbeta(n, .8, .4)), 
             y = rpois(n, 100 * rbeta(n, .8, .4)))
}


# write hc as JQuery
sim <- getData(10)
hc <- highchart() %>%
      hc_add_series(data = sim, "point", hcaes(x = x, y = y))
export_hc(hc, filename = "test.js")


ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    h2("Simulate Data"),
    numericInput("n", "points", 1000),
    actionButton("go", "go"),
    helpText("100.000 geht ist aber schon ziemlich langsam.")
  ),
  mainPanel(
    
    highchartOutput("plot")
  )
))


server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  
  # simulation
  sim <- eventReactive(input$go, {
    getData(input$n)
  })
  
  # show stuff
  output$plot <- renderHighchart({
    highchart() %>%
      hc_add_series(data = sim(), "point", hcaes(x = x, y = y))
  })
}


runApp(list(ui = ui, server = server), launch.browser = TRUE)









