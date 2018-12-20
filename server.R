options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output, session) {
    values <- reactiveValues(
        welcome = 0,
        slider = 0,
        computing = 0,
        isotope = 0)
    
    # reactive function for xcms data
    getmsSet <- reactive({
        req(input$file)
        inFile <- isolate({input$file})
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
    getcliques <- eventReactive(
        input$anspectr,{
            msSet <- req(getmsSet())
            anC <- cliqueMS::getCliques(msSet, tol = input$tol)
            return(anC)
        }
    )

    # function to show slider input when there is annotation
    observeEvent(
        input$anspectr, {
            values$slider <- 1
        }
    )

    # function to activate welcome message
    observeEvent(
        input$anspectr, {
            values$welcome <- 1
        }
    )

    observeEvent(
        input$anspectr, {
            values$computing <- 1
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
        isolate({values$computing <- 0})
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

    # search in the table metabolites, given rt, molecular mass, ppm
    getmettable <- eventReactive(
        input$tablemm,
        {
            anA <- req(getannotation())
            peaklist <- anA$peaklist
            rtmin <- input$rtmin
            rtmax <- input$rtmax
            mm <- input$mm
            ppm <- input$mmppm
            validate(need(rtmin < rtmax,
                          "Minimal rt has to be smaller than maximum rt")
                     )
            validate(
                need((rtmin >= 0)&&(rtmax >= 0)&&(mm >= 0)&&(ppm >= 0),
                     "RT, molecular mass and ppm values have to be positive numbers")
            )
            rowsC <- searchmass(peaklist, rtmin, rtmax,
                                mm, ppm)
            tableMet <- peaklist[rowsC,]
            return(tableMet)
        }
    )
    
    # ouput for showing the action button
    output$fileUploaded <- reactive({
        getmsSet()
        if(is.null(input$file)) return(FALSE) else return(TRUE)
    })
    # use output fileUploaded even if it is not showed
    outputOptions(output, "fileUploaded", suspendWhenHidden = FALSE)
    
    # output for showing the slider
    output$sliderOK <- reactive({
        return(values$slider)
    })
    # use output sliderOK even if is is not showed
    outputOptions(output, "sliderOK", suspendWhenHidden = FALSE)

    # output for welcome message
    output$welcome <- reactive({
        return(values$welcome)
    })
    # use output welcome even if is is not showed
    outputOptions(output, "welcome", suspendWhenHidden = FALSE)

    # output for computing cliques message
    output$computing <- reactive({
        return(values$computing)
    })
    # use output computing even if is is not showed
    outputOptions(output, "computing", suspendWhenHidden = FALSE)

    # output for isotope messages
    output$isotope <- reactive({
        return(values$isotope)
    })
    # use output computing even if is is not showed
    outputOptions(output, "isotope", suspendWhenHidden = FALSE)

    
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

    output$metT <- renderTable({
        peaklist <- getmettable()
        res <- peaklist[,c("mz","rt","maxo","isotope","an1","mass1",
                           "an2", "mass2","an3","mass3","an4",
                           "mass4", "an5", "mass5")]
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
