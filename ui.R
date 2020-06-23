source("setup.R", local = TRUE)

ui <- fluidPage(
  
  titlePanel("Data Dashboard for ASA ENVR Section Data Challenge"),
  
  # Output: Tabset
  # Different tabs where we can put our stuff. 
  tabsetPanel(type = "tabs",
              
              tabPanel("what is this?",
                       p("The layout for the app right now is using tabsetPanel. Inside each tabPanel function is its own little page where you can put content")),
              
              tabPanel("smither8"
                       #Ericka put  the stuff you're working on in here
              ),
              
              tabPanel("Jeffica"
                       #Jess put  the stuff you're working on in here
              ),
              
              tabPanel("MLE"
                       #Emily put  the stuff you're working on in here
              ),
              
              tabPanel("K8",
                       #stay cool chief
                       sidebarLayout(
                         sidebarPanel(
                           sliderInput("lat", label = h3("Latitude"), min = 24, 
                                       max = 50, value = c(41,47)),
                           sliderInput("lon", label = h3("Longitude"), min = -125, 
                                       max = -66, value = c(-125,-116)),
                           
                         ),
                         mainPanel(
                           plotOutput("sawtooth"),
                           plotOutput("ref_map")
                         )
                       )
              )
              
  )
)