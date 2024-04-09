library(shiny)
source("ui.R")
source("server.R")
options(shiny.fullstacktrace=T)


shinyApp(ui=ui,server=server)