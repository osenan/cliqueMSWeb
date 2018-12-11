ui <- fluidPage(

  # App title ----
    titlePanel("CliqueMS Web"),
    
  # sidebar panels  
    sidebarPanel(
        fileInput("file", "Upload processed spectral data")
    ),
    mainPanel(    
        plotOutput('histCliques'),
        tableOutput('table')
    )
)
