#source setup files
source("setup.R", local = FALSE)
source("setup_plot_sawtooth.R", local=FALSE)
source("setup_plot_maps.R", local=FALSE)
source("setup_plot_ranges.R", local=FALSE)


# ui <- fluidPage(
#   titlePanel("Data Dashboard for ASA ENVR Section Data Challenge"),
#   
#   
#   sidebarLayout(
#     # Side bar for selection choices 
#     sidebarPanel(
#       # perhaps include a checkbox ERA/CESMLENS dataset here?
#       helpText("Drag a rectangle to select an area to examine, then click go"),
#       selectInput(inputId = "state",

ui <- navbarPage("CliMates Data Dashboard", collapsible = TRUE, theme = shinytheme("darkly"),
                 tabPanel("Overview",
                          fluidPage(
                            mainPanel(
                              h2("Welcome to the CliMates Data Dashboard!"),
                              p("This is a part of the ASA ENVR Section Data Challenge 2020."),
                              p("You can find our code and full report on our",
                                a(href = 'https://github.com/OSUCliMates', 'github')," page"),
                              br(),
                              h3("About Us"),
                              p("We are a team from Oregon State University, so it's no
                              surprise that we are interested
                                in precipitation. If that's not your thing, have no fear! 
                                This data dashboard is a proof 
                                of concept. There is a steep learning curve to examining large and 
                                complex data sets, and 
                                in the spirit of 2020, we'd like to flatten that curve."),
                              br(),
                              p("In the next tab you'll see an
                                interactive tool for investigating two large data sets. We hope it lets
                                you bypass some of the initial drudgery of data cleaning and wrangling,
                                and just get a good look 
                                at the data. Have some fun! Play around. See if you can find anything 
                                that surprises you."),
                              br(),
                              h3("About the datasets"),
                              h5(" CESM Large Ensemble Community Project (CESM-LENS)"),
                              p("We used two precipitation climate reanalysis datasets",
                        a(href = 'https://www.ecmwf.int/en/forecasts/datasets/reanalysis-datasets/era-interim',
                                  'ERA '), "and ",
                                a(href = 'http://www.cesm.ucar.edu/projects/community-projects/LENS/',
                                  'CESM-LENS'),
                                ". ERA has resolution of (fix this)km and CESM-LENS has resolution of ()km"),
                              
                              h5("ERA - Interim"),
                              p("describe here :) "),
                              br(),
                              h3("Acknowledgements"),
                              p("advisors + data set creators + contest creators?
                              do advisors go with About Us or are they not
                              technically the team?")
                              ),
                            
                            h3("App Overview - Insert a sort of simple 'How to' of using the app"),
                            p("For this project, we chose to make a Shiny App (located in the `Shiny App` tab. 
                            To use this app, select a state of interest, and then click and drag a box around 
                            your location of interest. Once you have selected an area, click go."),
                            p(" You can also click `Click here to make a comparison` to compare to a 
                            different selected
                            area.")
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
      # actionButton(inputId = "go", ##################################### moved so that it shows up below
      #              label = "Go - See your results!",#####################
      #              class="btn-primary btn-block"),####################### the conditional panel
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
      ),
      actionButton(inputId = "go", ###################################### New Location
                   label = "Go - See your results!",
                   class="btn-primary btn-block")
      
      ),
    mainPanel(

  tabsetPanel(type = "tabs", 
              tabPanel("Model Variability", #smither8
                       conditionalPanel(
                         condition  = "input.go == 0",
                         h3("Please select a location in the sidebar and click 'Go' ")
                       ),
                       conditionalPanel(
                         condition = "input.go != 0",
                       h3("A Look Into The CESM-LENS Ensemble Members"),
                       p("The CESM-LENS data set comes from a large ensemble model.
                       The goal is to be able to distinguish 
                       between climate change and internal climate variability."),
                       p("Here we attempt to highlight that distinction
                         by investigating how different the model members are from each other over time. The data were
                         first reduced by calculating average precipitation for each day of the year in groupings of decades.
                         Then, the range of those values was calculated and used as a proxy for
                         variability between members over time."),
                         p("As you choose areas of interest you can see how
                         those ranges increase and decrease during different parts of the year, and if they change in 
                         different ways throughout different decades."),
                       h4("Area #1"),
                       withSpinner(
                         plotOutput("ranges_smooth")),
                       conditionalPanel(
                         h4("Area #2"),
                         condition = "input.comparison_checkbox == true",
                         withSpinner(plotOutput("comp_ranges_smooth"))
                       ),
                       h4("Area #1 Boxplot"),
                       withSpinner(
                         plotOutput("ranges_box")),
                       conditionalPanel(
                         h4("Area #2 Boxplot"),
                         condition = "input.comparison_checkbox == true",
                         withSpinner(plotOutput("comp_ranges_box"))
                       )
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
              
              tabPanel("Decadal Cumulative Precipitation",
                       conditionalPanel(
                         condition  = "input.go == 0",
                         h3("Please select a location in the sidebar and click 'Go' ")
                       ),
                       conditionalPanel(
                         condition = "input.go != 0",
                         
                         h3("Annual cumulative precipitation by decade"),
                         p("Cumulative precipitation for each given calendar day, averaged across the selected pixels,  
                           and across all years in each given decade. The time axis begins on October 1st, which is the
                           beginning of a water year, as defined by the United States Geological Survey. Zooming in to
                           the end of the cumulative precipitation plot demonstrates trend in precipitation since 1920, 
                           which varies by location. For instance, in Oregon precipitatin has been decreasing, while in 
                           New Mexico it has been increasing."),
                         br(),
                         p("To zoom in, click and drag to select an area, then double click the selected area. 
                           To reset zoom, double click anywhere."),
                         plotOutput("sawtooth",
                                    dblclick = "sawtooth_dblclick",
                                    brush = brushOpts(
                                      id = "sawtooth_brush",
                                      resetOnNew = TRUE
                                    )
                         ),
                         h3("Decadal average precipitation"),
                         p("This plot is just the numeric derivative of the above plot.
                           It shows what times of year have the most and least precipitation. These time series
                           tend to be a bit noisy, but when looked at together, precipitation patterns emerge.
                           When is your area's \"rainy season\"?"),
                         p("(Plot does not zoom)"),
                         plotOutput("num_der"),
                         hr(),
                         conditionalPanel(
                           condition = "input.comparison_checkbox == true",
                           h3("Annual cumulative precipitation by decade"),
                           p("To zoom in, click and drag to select an area, then double click the selected area. 
                           To reset zoom, double click anywhere."),
                           plotOutput("comp_sawtooth",
                                      dblclick = "sawtooth_comp_dblclick",
                                      brush = brushOpts(
                                        id = "sawtooth_comp_brush",
                                        resetOnNew = TRUE
                                      )
                           ),
                           h3("Decadal average rainfall"),
                           p("(Plot does not zoom)"),
                           plotOutput("comp_num_der")
                         )
                       )
              ),
              
              #tabPanel("Yearly - ",

              #     tabPanel("Decadal Cumulative Precipitation",#stay cool chief
                      #sliderInput("lat", label = h3("Latitude"), min = 24, 
                      #                 max = 50, value = c(41,47)),
                      #sliderInput("lon", label = h3("Longitude"), min = -125, 
                      #                 max = -66, value = c(-125,-116)),
                      
        #              conditionalPanel(
        #                condition  = "input.go == 0",
        #                h3("Please select a location in the sidebar and click 'Go' ")
        #              ),
        #              conditionalPanel(
        #                condition = "input.go != 0",
                      
        #              br(),
        #              plotOutput("sawtooth"),
        #              hr(),
        #              conditionalPanel(
        #                condition = "input.comparison_checkbox == true",
        #                plotOutput("comp_sawtooth")
        #              )
        #              )
        #              #plotOutput("ref_map")
        #     ),

              tabPanel("Total, Accumulation, Variation Time Series",
                       conditionalPanel(
                         condition  = "input.go == 0",
                         h3("Please select a location in the sidebar and click 'Go' ")
                       ),
                       conditionalPanel(
                         condition = "input.go != 0",
                       titlePanel("Precipitation Time Series: Total, Accumulation, and Variation"),
                       


                       # sidebarLayout(
                       #   sidebarPanel(
                       #     # Slider for range of years
                       #     div(style="font-size:20px;",
                       #         sliderInput(inputId = "Year", label="Years of interest",
                       #                     min=1979, max=2017, value=c(1979, 1985), sep=""))
                       #   ),
                       #   mainPanel(
                       #     tags$h3("ERA Interim Station Locations"), 
                       #     plotOutput(outputId = "mPlot", brush="selection1", width="80%")
                       #   )),

                       # Slider for range of years
                       div(style="font-size:20px;",
                           sliderInput(inputId = "Year", label="Years of interest",
                                       min=1979, max=2017, value=c(1979, 1985), sep="")),
                       actionButton(inputId = "Ygo",
                                    label = "Set year",
                                    class="btn-primary btn-block"),
                  #     sidebarLayout(
                  #       sidebarPanel(
                  #         # Slider for range of years
                  #         div(style="font-size:20px;",
                  #             sliderInput(inputId = "Year", label="Years of interest",
                  #                         min=1979, max=2017, value=c(1979, 1985), sep=""))
                  #       ),
                  #       mainPanel(
                  #         tags$h3("ERA Interim Station Locations"),
                  #         plotOutput(outputId = "mPlot", brush="selection1", width="80%")
                  #       )),

                       tags$h3("Total yearly precipitation"),
                       plotOutput(outputId = "TotPlot"),
                       
                       tags$h3("Cumulative yearly precipitation"),
                       plotOutput(outputId = "CumuPlot"),
                       
                       tags$h3("Variability of total monthly precipitation by year"),
                       plotOutput(outputId = "VarPlot")
                       #Jess put the stuff you're working on in here
                       )
              ),
              
              tabPanel("Seasonal Precipitation Deviation",
                       conditionalPanel(
                         condition  = "input.go == 0",
                         h3("Please select a location in the sidebar and click 'Go' ")
                       ),
                       
                       
                       conditionalPanel(
                         condition = "input.go != 0",
                       h3("Percent deviation from average seasonal precipitation - Using ERA data"),
                       # Plot 1: 
                       #plotOutput(outputId = "precip_deviation_plot"),
                       p(" For the entire United States, recent years have been
                       drier than average across all seasons - many smaller selections show this trend too.
                      For many locations, summer months have a lower range in percent deviance."),
                       withSpinner(plotOutput(outputId = "precip_deviation_plot")),
                       checkboxInput(inputId = "baseline",
                                     label = "Compare to United States average",
                                     value = TRUE),
                       h3("Precipitation Strips"),
                       # Plot 2: 
                      p("Each strip shows the percent deviation from average seasonal values
                      (wetter = green,  drier = brown) . We often see drier periods lasting longer than a season -
                      and these can often be seen in different locations. Often we see periods of
                         drought that are evident in the entire US as well."),
                       withSpinner(plotOutput(outputId = "precip_strips"))),
                       
                       
              )
  )

    )
  )
)

)
)


