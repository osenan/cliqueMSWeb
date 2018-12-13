options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output, session) {
    
    # reactive function for cliques
    getcliques <- eventReactive(
        input$anspectr, {
            req(input$file)
            inFile <- isolate({input$file })
            filename <- inFile$datapath
            msSet <- readRDS(filename)
            validate(
                need(class(msSet) == "xcmsSet",
                     "Please, upload a xcmsSet object")
            )
            anC <- cliqueMS::getCliques(msSet, tol = input$tol)
            return(anC)
        }
    )
    
    # reactive function for isotopes
    getisotopes <- reactive({
        anC <- req(getcliques())
        anI <- cliqueMS::getIsotopes(
                             anC,
                             maxCharge = input$maxCharge,
                             maxGrade = input$maxGrade,
                             ppm = input$ppmI,
                             isom = input$isoM)
        return(anI)
    })
    
    # reactive function for annotation
    getannotation <- reactive({
        anI <- req(getisotopes())
        req(input$adinfo)
        if( input$adinfo == "custom adduct list" ) {
            # read custom adduct list
            req(input$adinfoFile)
            inFile <- isolate({input$adinfoFile })
            fadinfo <- read.csv(inFile$datapath, header = TRUE)
        } else {
            if( input$adinfo == "default positive" ) {
                fadinfo = positive.adlist
            } else {
                fadinfo = negative.adlist
            }
        }
        anA <- cliqueMS::getAnnotation(
                             anI,
                             adinfo = fadinfo,
                             polarity = input$polarity,
                             ppm = input$ppmA,
                             emptyS = input$emptyS)
        return(anA)
    })

    
    # histogram output for cliques 
    output$histCliques <- renderPlot({
        anC <-  req(getcliques())
        peaklist <- anC$peaklist
        tablePeaklist <- table(peaklist$cliqueGroup)
        updateSliderInput(session = session,
                          inputId =  "breaksH", 
                          max = max(tablePeaklist)
                          )
        hist( tablePeaklist, col = "blue",
             border = "white", breaks = input$breaksH,
             xlab = "Clique size", ylab = "Counts",
             main = "Clique group size histogram")
    })
    # table for cliques
    output$tableCliques <- renderTable({
        anC <- req(getcliques())
        peaklist <- anC$peaklist
        df <- data.frame("Features" = nrow(peaklist),
                         "cliqueGroups" = length(unique(
                             peaklist$cliqueGroup))
                         )
    })

    # table for isotopes
    output$tableIso <- renderTable({
        anI <- req(getisotopes())
        iso <- anI$isotopes
        peaklist <- anI$peaklist
        Iso <- nrow(iso)
        noIso <- nrow(peaklist) - Iso
        df <- data.frame("Isotopic features" = Iso,
                         "Non isotopic features" = noIso)
    })

    # annotation info
    output$tableAn <- renderTable({
        anA <- req(getannotation())
        peaklist <- anA$peaklist
        per1 <- sum(!is.na(peaklist$an1))/nrow(peaklist)
        per1 <- round(100*per1,2)
        mass1 <- length(unique(peaklist$mass1))
        pertot <- percentageA(peaklist)
        masstot <- mastot(peaklist)
        df <- data.frame(
            "% of annotated features in annotation1" = per1,
            "Number of unique masses in annotation1" = mass1,
            "Mean % of annotated features" = pertot,
            "Mean number of unique masses" = masstot )
    })
}
