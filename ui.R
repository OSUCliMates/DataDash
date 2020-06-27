#source setup files
source("setup.R", local = FALSE)
source("setup_plot_sawtooth.R", local=FALSE)
source("setup_plot_maps.R", local=FALSE)
ui <- navbarPage("Data Dashboard for ASA ENVR Section Data Challenge", collapsible = TRUE, inverse = TRUE, theme = shinytheme("darkly"),
                 fluidPage(
                   sidebarLayout(
                     # Side bar for selection choices 
                     sidebarPanel(
                     #   tags$style(type="text/css", ".span8 .well { background-color: #00FFFF; }"),
                       # tags$head(tags$style(
                       #   HTML('#sidebar {background-color: #dec4de;}'))),
                       # perhaps include a checkbox ERA/CESMLENS dataset here?
                       selectInput(inputId = "state",
                  label = "Choose a state to zoom in",
                  choices = c("United States",state.name),
                  selected = "Oregon"),
      actionButton(inputId = "zoom_in",
                   label = "Zoom in"),
      actionButton(inputId = "zoom_out",
                   label = "Zoom out"),
      actionButton(inputId = "reset",
                   label = "Reset Zoom"),
      plotOutput(outputId = "point_selection_map", 
                 brush = "plot_brush"),
      
      # following is for the comparison map
      checkboxInput(inputId = "comparison_checkbox",
                    label = "Compare to a different location"),
      # Wow conditional panels are handy 
      conditionalPanel(
        condition = "input.comparison_checkbox == true",
        selectInput(inputId = "comparison_state",
                    label = "Choose a state to zoom in",
                    choices = c("United States",state.name),
                    selected = "Oregon"),
        actionButton(inputId = "zoom_in2",
                     label = "Zoom in"),
                        actionButton(inputId = "zoom_out2",
                                     label = "Zoom out"),
                        actionButton(inputId = "reset2",
                                     label = "Reset Zoom"),
        plotOutput(outputId = "comparison_point_selection_map",
                   brush = "plot_brush2")
      ),


      
      
      ),
    mainPanel(
  # Output: Tabset
  # Different tabs where we can put our stuff. 
  tabsetPanel(type = "tabs",
              
              tabPanel("what is this?",
                       p("The layout for the app right now is using tabsetPanel. Inside each tabPanel function is its own little page where you can put content")),
              
              tabPanel("smither8",
                       titlePanel("Choose an Area of Interest"),
                       sidebarLayout(
                         sidebarPanel(
                           helpText("Use your cursor to select a rectangle on the map. \n "),
                           plotOutput("shp_map", hover = "hov", brush= "brus"),
                           tableOutput("hov_info")),
                         mainPanel(
                           tableOutput("brus_info"),
                           plotOutput("insert_any_plot")))
              ),
              
              tabPanel("Jeffica",
                       titlePanel("Precipitation in Oregon - Quadrant/Year Comparison Tool"),
                       
                       sidebarLayout(
                         sidebarPanel(
                           # Slider for range of years
                           div(style="font-size:20px;",
                               sliderInput(inputId = "Year", label="Years of interest", min=1979, max=2017, value=c(1979, 1985), sep=""))
                         ),
                         mainPanel(
                           tags$h3("ERA Interim Station Locations"),
                           plotOutput(outputId = "mPlot", brush="selection1", width="80%")
                         )),
                       
                       tags$h3("Total yearly precipitation"),
                       plotOutput(outputId = "TotPlot"),
                       
                       tags$h3("Cumulative yearly precipitation"),
                       plotOutput(outputId = "CumuPlot"),
                       
                       tags$h3("Variability of total monthly precipitation by year"),
                       plotOutput(outputId = "VarPlot")
                       #Jess put  the stuff you're working on in here
              ),
              
              tabPanel("MLE",
                       #Emily put  the stuff you're working on in here
                       plotOutput(outputId = "precip_deviation_plot"),
                       plotOutput(outputId = "precip_strips")
              ),
              
              tabPanel("K8",#stay cool chief
                       #sliderInput("lat", label = h3("Latitude"), min = 24, 
                       #                 max = 50, value = c(41,47)),
                       #sliderInput("lon", label = h3("Longitude"), min = -125, 
                      #                 max = -66, value = c(-125,-116)),
                       plotOutput("sawtooth"),
                       #plotOutput("ref_map")
                       )
              )
    )
  )
)

)


