ui <- fluidPage(

  # App title ----
    titlePanel("CliqueMS Web"),
    
  # sidebar panels  
    sidebarPanel(
        fileInput("file", "Choose xcms RData file")
    ),
    mainPanel(    
        uiOutput('table')
    )
)
