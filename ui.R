ui <- fluidPage(

  # App title ----
    titlePanel("CliqueMS Web"),
    
  # sidebar panels  
    sidebarPanel(
        fileInput("file", "Upload processed spectral data",
                  accept = c(".rds")),
        # Clique parameters
        numericInput("tol", label = "Tolerance",
                     value = 1e-5, min = 1e-7, max = 1e-3,
                     step = 5e-8),
        # Isotope parameters
        numericInput("ppmI", label = "ppm isotopes",
                     value = 10, min = 1, max = 100, step = 1),
        numericInput("isoM", label = "isotope mass value",
                    value = 1.003355, min = 1,0033, max = 1.004),
        numericInput("maxGrade", label = "maxGrade", value = 2,
                     min = 1, max = 6, step = 1),
        numericInput("maxCharge", label = "maxCharge", value = 3,
                     min = 1, max = 5),
        # Annotation parameters
        selectInput("polarity",
                    label =  "Select polarity:",
                    choices = c("positive","negative"),
                    selected = "positive"),
        checkboxGroupInput("adinfo",
                           label = "Choice adduct list:",
                           choices = c("default positive",
                                       "default negative",
                                       "custom adduct list")),
        fileInput("adinfoFile", "Upload custom adduct list",
                  accept = c(".csv")),
        numericInput("ppmA", label = "ppm adducts",
                     value = 10, min = 1, max = 100, step = 1),
        numericInput("emptyS", label = "empty annotation score",
                     value = 1e-6, min = 1e-12, max = 1e-3),

        # anotate spectra button
        actionButton("anspectr", "Annotate data")
    ),
    # main panel
    mainPanel(
        sliderInput(inputId = "breaksH",
                    label = "Clique size breaks:",
                    min = 1, max = 50, value = 10),
        withSpinner(plotOutput('histCliques'), type = 5),
        tableOutput('tableCliques'),
        tableOutput('tableIso'),
        tableOutput('tableAn')
    )
)
