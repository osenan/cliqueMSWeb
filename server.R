options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output, session) {

    # reactive function for uploading xcms data
    getxcms <- reactive({
        req(input$file)
        inFile <- isolate({input$file })
        filename <- inFile$datapath
        msSet <- readRDS(filename)
        validate(
            need(class(msSet) == "xcmsSet",
                 "Please, upload a xcmsSet object")
        )
        return(msSet)
    }
    )

    
    # reactive function for cliques
    getcliques <- eventReactive({
        input$anspectr
        req(getxcms())
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
            fadinfo <- read.csv(inFile$datapath, header = FALSE)
            # less errors without header
            validate(need(ncol(fadinfo) == 5,
                          "Custom adduct list does not contain five comma-separated columns")
                     )
            colnames(fadinfo) <- colnames(positive.adlist)
            
        } else {
            if( input$adinfo == "default positive" ) {
                fadinfo <- positive.adlist
            } else {
                fadinfo <- negative.adlist
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
        hist( tablePeaklist, col = "#ef8a62",
             border = "white", breaks = input$breaksH,
             xlab = "Clique size (N. of features)", ylab = "Counts",
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
    output$plotIso <- renderPlot({
        anI <- req(getisotopes())
        iso <- anI$isotopes
        peaklist <- anI$peaklist
        Iso <- nrow(iso)
        noIso <- nrow(peaklist) - Iso
        isoper <- round(100*(Iso/nrow(peaklist)),2)
        noisoper <- round(100*(noIso/nrow(peaklist)),2)
        df = data.frame( nfeat = c(Iso, noIso),
                        per = c(isoper, noisoper),
                        type = c("Isotopes", "Non-isotopes"),
                        total = c("total Features","total Features"))
        barplot(df$per, col = c("#ef8a62", "#67a9cf"), horiz = T,
                border = "white", main = "Isotopic Features",
                names.arg = c("Isotopes","Non-isotopes"),
                xlab = "% of features")
    })

    # annotation info
    output$plotAn1 <- renderPlot({
        anA <- req(getannotation())
        peaklist <- anA$peaklist
        pertot <- round(100*percentageA(peaklist),2)
        pernonAtot <- round(100 - pertot,2)
        df <- data.frame(per = c(pertot, pernonAtot))
        barplot(df$per, col = c("#ef8a62", "#67a9cf"), horiz = T,
                border = "white", main = "Total annotation",
                names.arg = c("Annotated features",
                              "Non-annotated features"),
                xlab = "% of features")
    })

    # download peaklist
    output$dpeaklist <- downloadHandler(
        filename <- function() {
            "peaklist.csv"
        },
        content <- function(file) {
            anA <- req(getannotation())
            peaklist <- anA$peaklist
            write.table(peaklist, file, sep = ",",
                        row.names = FALSE)
        }
    )
}
