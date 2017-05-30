# libs
library(shiny)

# chr generator
makeChr <- function(n) {
  paste(sample(letters, n, replace = TRUE), collapse = "")
}

# actual app
ui <- fluidPage(sidebarLayout(
  sidebarPanel(
    h3("Simulate Data"),
    numericInput("n", "number of points", 10),
    actionButton("go", "go")
  ),
  mainPanel(
    uiOutput("test")
  )
))

server <- function(input, output, session) {
  session$onSessionEnded(stopApp)
  
  # generate data
  sim <- eventReactive(input$go, {
    makeChr(input$n)
  })
  
  # make javascript
  output$test <- renderUI({
    id <- "test_str"
    str <- sprintf('var str = "%s"', sim())
    len <- sprintf('document.getElementById("%s").innerHTML = str.length', id)
    tagList(
      tags$div("blank", id = id) ,
      tags$script(str),
      tags$script(len)
    )
  })
}

runApp(list(ui = ui, server = server))








