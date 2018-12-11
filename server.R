options(shiny.maxRequestSize=30*1024^2)
library(cliqueMS)


server <- function(input, output) {
    getpeaklist <- reactive({
        if ( is.null(input$file)) return(NULL)
        inFile <- isolate({input$file })
        filename <- inFile$datapath 
        msSet <- readRDS(filename)
        anC <- cliqueMS::getCliques(msSet)
        peaklist <- anC$peaklist
        return(peaklist)
    })
    
    output$histCliques <- renderPlot({
        peaklist <-  req(getpeaklist())
        hist(table(peaklist$cliqueGroup), col = "blue", border = "white",
             xlab = "Clique size (number of features)", ylab = "Counts",
             main = "Clique group size histogram")
    }
    )
    output$table <- renderTable({
        peaklist <- req(getpeaklist())
        df <- data.frame("Features" = nrow(peaklist),
                         "cliqueGroups" = length(unique(peaklist$cliqueGroup))
                         )
    }
    )
}
