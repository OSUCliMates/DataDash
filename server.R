# Define server logic required to draw a histogram
server <- function(input, output) {
  output$sawtooth <- renderPlot({
    a <- input$lat[1]
    b <- input$lat[2]
    c <- input$lon[1]%%360
    d <- input$lon[2]%%360
    
    plot_sawtooths(a,b,c,d)
  })
  
  output$ref_map <- renderPlot({
    ggplot(us, aes(x = long, y = lat, group = group)) +
      geom_polygon(fill="lightgray", colour = "black")+
      geom_rect(aes(xmin=input$lon[1],
                    xmax=input$lon[2],
                    ymin=input$lat[1],
                    ymax=input$lat[2]),
                fill="darkorchid2",
                alpha=0.01
      )
    
  })
}

