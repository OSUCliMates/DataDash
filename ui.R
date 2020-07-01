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

ui <- navbarPage("CliMates Precipitation Data Dashboard", collapsible = TRUE, theme = shinytheme("darkly"),
                 tabPanel("Overview",
                          fluidPage(
                            mainPanel(
                              h2("Welcome to the CliMates Precipitation Data Dashboard!"),
                              p("This Shiny web application has been created as a submission to the American Statistical
                                Association Environmental Section 2020 Data Challenge."),
                              p("You can find our code on our",
                                a(href = 'https://github.com/OSUCliMates', 'Github')," page and our full report ", 
                                a(href = 'https://github.com/OSUCliMates', 'here'), "."),
                              p("This tab gives a brief overview of the application, it's creators, and the materials used to make it."),
                              p("In the next tab, you'll see an
                                interactive and explorative tool for investigating precipitation in the United States using two large climate data sets. We hope it lets
                                you bypass some of the initial drudgery of data cleaning and wrangling,
                                and get a good look at the behaviors, trends, and patterns that are occurring. Have some fun! Play around. See if you can find anything 
                                that surprises you."),
                              br(),
                              h3("About Us"),
                              p("We are four Statistics M.S. students at Oregon State University with a mutual interest in climate data and statistics. By this friendship, the CliMates were formed."),
                              p(strong("The CliMates: "), "Emily M. M. Palmer, Katherine R. Pulham, Jessica R. Robinson, Ericka B. Smith"),
                              p("Our team consists of four students residing in the rainy state of Oregon, so it's no
                              surprise that we are interested
                                in precipitation data. If that's not your thing, have no fear! 
                                This data dashboard is a proof 
                                of concept. There is a steep learning curve to examining large and 
                                complex data sets, and 
                                in the spirit of 2020, we'd like to flatten that curve."),
                              br(),

                              h3("The Datasets"),
                              p("We used two precipitation climate reanalysis datasets provided by the ENVR section: "),
                                a(href = 'https://www.ecmwf.int/en/forecasts/datasets/reanalysis-datasets/era-interim',
                                  'ERA '), "and ",
                                a(href = 'http://www.cesm.ucar.edu/projects/community-projects/LENS/',
                                  'CESM-LENS'),
                              h4("CESM Large Ensemble Community Project (CESM-LENS)"),
                              p("The CESM-LENS dataset consists of climate model simulations created by the Community Earth System Model Large Ensemble Community Project and supercomputing 
                                resources provided by NSF/CISL/Yellowstone, and led by Dr. Clara Deser and Dr. Jennifer Kay. (Kay et al. 2005). The data are an ensemble model with 40 members. 
                                Each member has a slightly different initial atmospheric state, but uses the same model and undergoes the same radiative forcing scenario."),
                              
                              h4("ERA-Interim"),
                              p("The ERA-Interim dataset comes from a climate data reanalysis from the European Centre for Medium‐Range Weather Forecasts (ECMWF). 
                                ERA-Interim is a global atmospheric reanalysis that tracks a large number of variables, including maximum temperature, minimum temperature, and precipitation from 1979 to 2017."),
                              br(),
                        
                              h3("Get Started"),
                              p("To use this web application, you'll start by choosing a location of interest. You can do this by choosing a state from the dropdown menu and then toggling the zoom buttons to narrow your selection.
                            You can then click and drag a box to select the location you'd like to explore. There is an option to repeat this process to compare two different locations as well."),
                              p("Once this is chosen, you have four tabs to choose from, all hosting distinct exploratory tools."),
                        
                              br(),
                              
                              h3("Acknowledgements"),
                              p("We'd like to thank our faculty advisors for their support in this endeavor: Lisa Ganio, James Molyneux, and Charlotte Wickham."),
                              p("Additionally, thank you to the CESM Large Ensemble Community Project and the European Centre for Medium‐Range Weather Forecasts as well as the ASA ENVR Section for aggregating the
                                data resources used in this effort."),
                              p("And, thank you to CJ Keist at OSU CoSINe IT Services for setting up and overseeing the RStudio server. "),
                              p("Thank you to the ASA Environmental Section for hosting this competition. The combination of R, Shiny, GitHub and large climate datasets used in this competition provided fun and 
                                challenging means for us to learn important tools in our field.")
                              ),
                          )),
                 tabPanel("Explore the Data",
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
                         h4("Area #1"),
                         p("To zoom in, click and drag to select an area, then double click the selected area. To reset zoom, double click anywhere."),
                         #withSpinner(
                         plotOutput("ranges_smooth",
                                    dblclick = "rs_dblclick",
                                    brush = brushOpts(
                                      id = "rs_brush",
                                      resetOnNew = TRUE
                                      )),
                       conditionalPanel(condition =
                                          "input.comparison_checkbox == true",
                                        h4("Area #2"),
                                        p("To zoom in, click and drag to select an area, then double click the selected area. To reset zoom, double click anywhere."),
                                        #withSpinner(
                                        plotOutput("comp_ranges_smooth",
                                                   dblclick = "rs_comp_dblclick",
                                                   brush = brushOpts(
                                                     id = "rs_comp_brush",
                                                     resetOnNew = TRUE))),#),
                       h4("Area #1 Boxplot"),
                       withSpinner(
                         plotOutput("ranges_box")),
                       conditionalPanel(
                         condition = "input.comparison_checkbox == true",
                         h4("Area #2 Boxplot"),
                         withSpinner(plotOutput("comp_ranges_box"))),
                       br(),
                       p("Note: The following section is not interactive and is merely an explanation and example of the previous plots"),
                       h3("What does \"Model Variability\" and \"Ensemble Member\" mean here?"),
                       p("See the following plot. It contains average precipitaion values for all 42 members at one specific observation station (122°50'W, 44°76.440'N), for the month of January in the 1980s. The exact values are plotted as points, with darker points indicating overlapping values. The lines connecting points  follow each individual member across the entire plot."),
                       br(),
                       plotOutput("plot_range_explain_a"),
                       br(),
                       p("Here we attempt to highlight that distinction by investigating how different  the model members are from each other over time. The data were first reduced by calculating average precipitation for each day of the year in groupings of decades. Then, the range of those values was calculated and used as a proxy for variability between members over time."),
                       p("As you choose areas of interest you can see how those ranges increase and decrease during different parts of the year, and if they change in different ways throughout different decades."),
                       p("Notice how messy the lines and black points are! When you consider the sheer size of this data (42 members, 31025 days, 41 latitudes, and 63 longitudes), it's no wonder that it looks so noisy."),
                       p("To reduce the data to something manageable for plotting (and more importantly, understanding), the range will act as a proxy for variability. Note that the maximum and minimum values are denoted with red points. In the next plot, the  range itself is on the y-axis. You can see that the values for each day match up with the vertical space between the red points above."),
                       br(),
                       plotOutput("plot_range_explain_b"),
                       br(),
                       p("In the interactive plots above you're looking at summaries of these ranges."),
                       p("The boxplot combines these values for range for each day of each entire decade. The idea here is to get some intuition as to the distribution of ranges for each decade.")
                       )),

              
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

              tabPanel("Yearly Total, Cumulative, and By-Month Variability",
                       conditionalPanel(
                         condition  = "input.go == 0",
                         h3("Please select a location in the sidebar and click 'Go' ")
                       ),
                       conditionalPanel(
                         condition = "input.go != 0",
                       titlePanel("Total, Cumulative, and By-Month Variability of Precipitation"),
                       tags$h4("The plots in this tab were created using the ERA-Interim dataset to display the behavior of precipitation in your area of
                               interest in with three measurements."),

                       div(style="font-size:15px;",
                           sliderInput(inputId = "Year", label="Select a range of years to explore",
                                       min=1979, max=2017, value=c(1979, 1985), sep="")),

                       
                       tags$h3("Total yearly precipitation"),
                       p("For a given year and location boundary (or boundaries) of your choice, the total yearly precipitation is calculated for all 
                       ERA map locations and then averaged. Note that the measurement of rainfall in the ERA dataset is a volume flux of precipitation rather than
                       a volume of fallen precipitation."),
                       p("Do you remember a significantly rainy or snowy year where you've lived?"),
                       withSpinner(plotOutput(outputId = "TotPlot")),
                       
                       tags$h3("Cumulative yearly precipitation"),
                       p("In this plot, you'll see the cumulative precipitation for your location(s) of interest. Similarly to the plot above, the cumulative precipitation
                         for all of the ERA location points in the boundary are averaged for each depicted year."),
                       p("Are sharp increases in total precipitation in the above plot detectable in the slope of the cumulative precipitation?"),
                       withSpinner(plotOutput(outputId = "CumuPlot")),
                       
                       tags$h3("Variability of monthly total precipitation by year"),
                       p("This final plot allows you to explore the variability of precipitation by year. The monthly totals are taken similarly to the above plots and then the variance
                         amongst the month totals for a given year are plotted."),
                       p("Are wetter or drier years more variable?"),
                       withSpinner(plotOutput(outputId = "VarPlot"))
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
                       withSpinner(plotOutput(outputId = "precip_strips")))
                       
                       
              )
  )
    )
                   )
                 )
                 )
)




