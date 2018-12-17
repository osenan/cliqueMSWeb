library(shiny)
library(shinycssloaders)
library(ggplot2)
source("helpers.R")
source("server.R")
source("ui.R")

example.data <- readRDS("./data/standards.rds")
positive.adlist <- read.csv("data/positive.adinfo.csv",
                          header = T)
negative.adlist <- read.csv("data/negative.adinfo.csv",
                          header = T)
shinyApp(ui, server)

