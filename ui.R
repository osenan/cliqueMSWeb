ui <- fluidPage(
  # Change color of all hyperlinks                
                    
                    
  # App title ----
    titlePanel("CliqueMS Web"),

    
    
  # sidebar
    sidebarPanel(
#        tags$head(tags$style(HTML("
#    .skin-aqua .sidebar a { color: #432; }")
                                        #    )),
    br(),
#    column(10,align = "left",
           downloadLink("rawE",
                        "Example raw data"),
    fileInput("raw", "Raw spectral data",
                  accept = c(".mzXML,mzML")),
    #column(10, align = "left",
               downloadLink("rds",
                            "Example processed data"),
#               ),
        fileInput("file",
                  "XCMS processed spectral data",
                  accept = c(".rds")),
            #Clique parameters
            numericInput("tol", label = "Tolerance",
                         value = 1e-5, min = 1e-7, max = 1e-3,
                         step = 5e-8),
            # Isotope parameters
            numericInput("ppmI", label = "ppm isotopes",
                         value = 10, min = 1, max = 100, step = 1),
            numericInput("isoM", label = "isotope mass value",
                         value = 1.003355, min = 1,0033,
                         max = 1.004),
            numericInput("maxGrade", label = "maxGrade", value = 2,
                         min = 1, max = 6, step = 1),
            numericInput("maxCharge", label = "maxCharge", value = 3,
                         min = 1, max = 5),
        # Annotation parameters
        selectInput("polarity",
                    label =  "Select polarity:",
                    choices = c("positive","negative"),
                    selected = "positive"),
        radioButtons("adinfo",
                           label = "Choice adduct list:",
                           choices = c("default positive",
                                       "default negative",
                                       "custom adduct list")),
        conditionalPanel(
            condition = "input.adinfo == 'custom adduct list'",
            fileInput("adinfoFile", "Upload custom adduct list",
                      accept = c(".csv"))
        ),
        numericInput("ppmA", label = "ppm adducts",
                     value = 10, min = 1, max = 100, step = 1),
        numericInput("emptyS", label = "empty annotation score",
                     value = 1e-6, min = 1e-12, max = 1e-3),

        # anotate spectra button
        conditionalPanel(
            condition = "output.fileUploaded == true",
            actionButton("anspectr", "Annotate data")
        )
    ),
    # main panel
    mainPanel(
        conditionalPanel(
            condition = 'output.welcome == 0',
            withTags({
                div(class = "header", checked = NA,
                    p("Welcome to cliqueMS Web, please upload spectral data, set parameters and start annotation")
                    )
            })
        ),
        # sliderOK conditional
        column(10, align = "center",
               conditionalPanel(
                   condition = "output.sliderOK == 1",
                   withTags({
                       div(class = "header", checked = NA,
                           h4("Clique groups have been computed")
                           )
                   }),
                   tableOutput('tableCliques'),
                   withTags({
                       div(class = "header", checked = NA,
                           p("In the following histogram you can see the distribution of the clique group size")
                           )
                   }),
                   sliderInput(inputId = "breaksH",
                               label = "Clique size breaks:",
                               min = 1, max = 50, value = 10),
                   shinycssloaders::withSpinner(plotOutput('histCliques'), type = 5),
                   withTags({
                       div(class = "header", checked = NA,
                           h4("Annotation of isotopes is done")
                           )
                   })
               ),
               shinycssloaders::withSpinner(plotOutput('plotIso'), type = 5),
               conditionalPanel(
                   condition = 'output.plotIso',
                   withTags({
                       div(class = "header", checked = NA,
                           h4("Annotation of adducts is done")
                           )
                   })
               ),
               shinycssloaders::withSpinner(plotOutput('plotAn1'), type = 5)
               ),
        conditionalPanel(
            condition = 'output.plotAn1',
            numericInput(inputId = "rtmin", label = "Minimal rt",
                         value = 1, min = 0, max = 99.75,
                         step = 0.25),
            numericInput(inputId = "rtmax", label = "Maximum rt",
                         value = 50, min = 0.25, max = 100,
                         step = 0.25),
            numericInput(inputId = "mm", label = "Molecular mass",
                         value = 90, min = 0, max = 1000),
            numericInput(inputId = "mmppm", label = "ppm mass range",
                         value = 20, min = 1, max = 200),
            actionButton("tablemm", label = "Search metabolites"),
            div(tableOutput('metT'),style = "font-size:85%"),
            withTags({
                div(class = "header", checked = NA,
                    p("Thanks for using CliqueMS Web, in the following link you can download the complete annotation")
                    )
                   }),
            column(10, align = "center",
                   downloadButton("dpeaklist",
                                  "Download Annotation"),
                               br())
        )
        
    )
)

