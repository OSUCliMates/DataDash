#source setup files
source("setup.R", local = FALSE)
source("setup_plot_sawtooth.R", local=FALSE)
source("setup_plot_maps.R", local=FALSE)
ui <- fluidPage(
  titlePanel("Data Dashboard for ASA ENVR Section Data Challenge"),
  
  
  sidebarLayout(
    # Side bar for selection choices 
    sidebarPanel(
      # perhaps include a checkbox ERA/CESMLENS dataset here?
      helpText("Drag a rectangle to select an area to examine, then click go"),
      selectInput(inputId = "state",
                  label = "Choose a state to zoom in",
                  choices = c("United States",state.name),
                  selected = "Oregon"),
      plotOutput(outputId = "point_selection_map", 
                 brush = "plot_brush",
                 height = "300px"),
      actionButton(inputId = "zoom_in",
                   label = "Zoom in",
                   class = "btn-sm"),
      actionButton(inputId = "zoom_out",
                   label = "Zoom out",
                   class = "btn-sm"),
      actionButton(inputId = "reset",
                   label = "Reset Zoom",
                   class = "btn-sm"),
      actionButton(inputId = "go",
                   label = "Go - See your results!",
                   class="btn-primary btn-block"),
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
        plotOutput(outputId = "comparison_point_selection_map",
                   brush = "plot_brush2",
                   height = "300px"),
        actionButton(inputId = "zoom_in2",
                     label = "Zoom in", 
                     class = "btn-sm"),
        actionButton(inputId = "zoom_out2",
                     label = "Zoom out",
                     class = "btn-sm"),
        actionButton(inputId = "reset2",
                     label = "Reset Zoom",
                     class = "btn-sm")
      ),


      
      
      ),
    mainPanel(
  # Output: Tabset
  # Different tabs where we can put our stuff. 
  tabsetPanel(type = "tabs",
              
              tabPanel("Overview",
                       h3("just trying to start up an outline - plz add stuff"),
                       h3("About the datasets"),
                       p("We used two climate reanalysis datasets, ERA and CESM-LENS"),
                       h3("We chose precipitation data"),
                       p("Find our code and report on our github page")),
              
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
              
              tabPanel("Monthly Precipitation Deviation",
                       h3("Deviation from average monthly rainfall"),
                       # Plot 1: 
                       #plotOutput(outputId = "precip_deviation_plot"),
                       withSpinner(plotOutput(outputId = "precip_deviation_plot")),
                       checkboxInput(inputId = "baseline",
                                     label = "Compare to United States baseline",
                                     value = TRUE),
                       p("Description: We see that Positive values indicate that year was wetter than normal,
                         negative values indicate drier than normal."),
                       h3("Precipitation Strips"),
                       # Plot 2: 
                       withSpinner(plotOutput(outputId = "precip_strips")),
                       p("These color strips show when the selected location is wetter (green) or dryer (brown) 
                         then average - Comparison to overall United States included")
                       
              ),
              
              tabPanel("K8",#stay cool chief
                       #sliderInput("lat", label = h3("Latitude"), min = 24, 
                       #                 max = 50, value = c(41,47)),
                       #sliderInput("lon", label = h3("Longitude"), min = -125, 
                      #                 max = -66, value = c(-125,-116)),
                      plotOutput("sawtooth"),
                      hr(),
                      plotOutput("comp_sawtooth")
                       #plotOutput("ref_map")
                       )
              )
    )
  )
)




