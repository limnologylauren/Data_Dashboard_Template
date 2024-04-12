# This is the list of packages that are needed. Checks to see if they are 
#  installed. If any are missing, this installs them.
#list.of.packages <- c("shiny","tidyverse","readxl","bslib")
#new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
#if(length(new.packages)) install.packages(new.packages)
library(shiny)
source("ui.R")
source("server.R")
options(shiny.fullstacktrace=T)

shinyApp(ui=ui,server=server)