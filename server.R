options(shiny.maxRequestSize=30*1024^2)
library(cliqueMS)


server <- function(input, output) {
    output$table <- renderTable({
        if ( is.null(input$file)) return(NULL)
        inFile <- isolate({input$file })
        file <- inFile$datapath
        load(file = file, envir = .GlobalEnv)
        anC <- cliqueMS::getCliques(standard)
        return(anC$peaklist)
    }
    )
}
