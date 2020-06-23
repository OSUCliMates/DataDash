source("setup.R", local = TRUE)

ui <- fluidPage(

    titlePanel("Data Dashboard for ASA ENVR Section Data Challenge"),

    # Output: Tabset
    # Different tabs where we can put our stuff. 
    tabsetPanel(type = "tabs",
                
                tabPanel("wtf is this?",
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
                
                tabPanel("K8"
                         #stay cool chief
                         )
                
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
}

# Run the application 
shinyApp(ui = ui, server = server)
