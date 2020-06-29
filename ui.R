#source setup files
source("setup.R", local = FALSE)
source("setup_plot_sawtooth.R", local=FALSE)
source("setup_plot_maps.R", local=FALSE)
source("setup_plot_ranges.R", local=FALSE)

ui <- navbarPage("Data Dashboard for ASA ENVR Section Data Challenge", collapsible = TRUE, theme = shinytheme("darkly"),
                 tabPanel("Overview",
                          fluidPage(
                            mainPanel(
                              h3("just trying to start up an outline - plz add stuff"),
                              h3("About the datasets"),
                              p("We used two climate reanalysis datasets, ERA and CESM-LENS"),
                              h3("We chose precipitation data"),
                              p("Find our code and full report on our", a(href = 'https://github.com/OSUCliMates', 'github')," page"))
                            )
                          ),
                 tabPanel("The Data",
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
                                   selected = "United States"),
                       helpText("Click and drag to select location to explore"),
                  
      plotOutput(outputId = "point_selection_map", 
                 brush = "plot_brush",
                 height = "300px"),
      conditionalPanel(
        condition = "input.state != 'United States'",
      actionButton(inputId = "zoom_in",
                   label = "Zoom in",
                   class = "btn-sm"),
      actionButton(inputId = "zoom_out",
                   label = "Zoom out",
                   class = "btn-sm"),
      actionButton(inputId = "reset",
                   label = "Reset Zoom",
                   class = "btn-sm")),
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
                    selected = "United States"),
        plotOutput(outputId = "comparison_point_selection_map",
                   brush = "plot_brush2",
                   height = "300px")
        
      ),
      conditionalPanel(
        condition = "input.comparison_checkbox & input.comparison_state != 'United States'",
        actionButton(inputId = "zoom_in2",
                     label = "Zoom in", 
                     class = "btn-sm"),
        actionButton(inputId = "zoom_out2",
                     label = "Zoom out",
                     class = "btn-sm"),
        actionButton(inputId = "reset2",
                     label = "Reset Zoom",
                     class = "btn-sm")
      )
      
      ),
    mainPanel(
  tabsetPanel(type = "tabs", 
              tabPanel("CESM-LENS Variability", #smither8
                       h3("A look into the CESM-LENS Ensemble Members"),
                       withSpinner(
                         plotOutput("ranges_smooth")),
                       conditionalPanel(
                         h3("aaa"),
                         condition = "input.comparison_checkbox == true",
                         withSpinner(plotOutput("comp_ranges_smooth")),
                         p("blah blah etx etc")
                       ),
                       h3("bbbs"),
                       withSpinner(
                         plotOutput("ranges_box")),
                       conditionalPanel(
                         h3("ccc"),
                         condition = "input.comparison_checkbox == true",
                         withSpinner(plotOutput("comp_ranges_box")),
                         p("blah blah etx etc")
                       )
              ),
              
              #########
              
              # tabPanel("Seasonal Precipitation Deviation",
              #          h3("Deviation from average seasonal rainfall"),
              #          # Plot 1: 
              #          #plotOutput(outputId = "precip_deviation_plot"),
              #          withSpinner(plotOutput(outputId = "precip_deviation_plot")),
              #          checkboxInput(inputId = "baseline",
              #                        label = "Compare to United States baseline",
              #                        value = TRUE),
              #          withSpinner(plotOutput(outputId = "yearly_precip_deviation")),
              #          p("Description:"),
              #          h3("Precipitation Strips"),
              #          # Plot 2: 
              #          
              #          withSpinner(plotOutput(outputId = "precip_strips")),
              #          p("These cvide")
              #          
              # )
              ###############
             tabPanel("Decadal Cumulative Precipitation",#stay cool chief
                      #sliderInput("lat", label = h3("Latitude"), min = 24, 
                      #                 max = 50, value = c(41,47)),
                      #sliderInput("lon", label = h3("Longitude"), min = -125, 
                      #                 max = -66, value = c(-125,-116)),
                      br(),
                      plotOutput("sawtooth"),
                      hr(),
                      conditionalPanel(
                        condition = "input.comparison_checkbox == true",
                        plotOutput("comp_sawtooth")
                      )
                      #plotOutput("ref_map")
             ),

              tabPanel("Yearly - ",
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
              
              tabPanel("Seasonal Precipitation Deviation",
                       h3("Deviation from average seasonal rainfall"),
                       # Plot 1: 
                       #plotOutput(outputId = "precip_deviation_plot"),
                       withSpinner(plotOutput(outputId = "precip_deviation_plot")),
                       checkboxInput(inputId = "baseline",
                                     label = "Compare to United States baseline",
                                     value = TRUE),
                      withSpinner(plotOutput(outputId = "yearly_precip_deviation")),
                       p("Description: We see that for many locations that summer months have less deviation from averages
                       Positive values indicate that year was wetter than normal,
                         negative values indicate drier than normal."),
                       h3("Precipitation Strips"),
                       # Plot 2: 
                       
                       withSpinner(plotOutput(outputId = "precip_strips")),
                       p("These color strips show when the selected location is wetter (green) or dryer (brown) 
                         then average - Comparison to overall United States included. Often we see periods of drought that are evident in the entire US as well")
                       
              )
  )

    )
  )
)

)

)
