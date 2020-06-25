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
  
  # K8 I think
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
    # smither8
    output$shp_map <- renderPlot({ #shapefile 
      plot(shp_file_s8$geometry)
    })
    
    output$hov_info <- renderTable({ #table for hover
      if (is.null(input$hov)){NULL}
      else{
        hov_df[1] <- input$hov$x
        hov_df[2] <- input$hov$y
      }
      hov_df
    })
    
    output$brus_info <- renderTable({     # display rectangle
      if (is.null(input$brus)){
        NULL
      }
      else{
        extent_df[1,1] <<- input$brus$xmin
        extent_df[2,1] <<- input$brus$xmax
        extent_df[2,2] <<- input$brus$ymin
        extent_df[1,2] <<- input$brus$ymax
      }
      extent_df
    }, rownames = TRUE)
    
    output$insert_any_plot <- renderPlot({ #just a placeholder plot
      ggplot(data=extent_df)+
        geom_point(aes(x=Longitude, y=Latitude))
    }
    )

    
    
    # JessRoseRobbieJo
    VarPlotData <- reactive({
      brushedPoints(BigDF, input$selection1) %>%
        filter(between(Year, as.numeric(input$Year[1]), as.numeric(input$Year[2]))) %>%
        group_by(Year, Month) %>%
        summarise(TotMoPrecip=sum(PREC)) %>%      # Total precip for month, by station
        group_by(Year) %>%
        summarise(varTotPrecip = var(TotMoPrecip))})
    
    TotPlotsData <- reactive({
      brushedPoints(BigDF, input$selection1) %>%
        filter(between(Year, as.numeric(input$Year[1]), as.numeric(input$Year[2]))) %>%
        group_by(Year) %>%
        summarise(TotYrPrecip=sum(PREC)) %>%
        mutate(CumuPrecip = cumsum(TotYrPrecip))}) %>%
      debounce(2000)
    
    xAxisTicks <- reactive({
      
      # If number of years plotted is odd, the last label will occur before the last plotted point, so
      # add two to the final year displayed
      if ((input$Year[2] - input$Year[1]) %% 2 > 0) {
        max_year <- input$Year[2] + 2
      } 
      else {
        max_year <- input$Year[2]
      }
      
      # If over 10 years plotted, only label at every other break
      if ((input$Year[2]-input$Year[1]) > 10) {
        breaks <- seq(from = input$Year[1],
                      to = max_year,        
                      by = 2)
      } else {
        breaks <- seq(from = input$Year[1],
                      to = max_year,         
                      by = 1)
      }
    })
    
    output$mPlot <- renderPlot({
      ggplot(toMap)+
        geom_point(aes(x=lon2, y=lat), color="red", alpha=0.25)+
        borders("state", size=1)+
        xlab("Longitude")+
        ylab("Latitude")+
        theme(text = element_text(size=20))
    })
    
    output$VarPlot <- renderPlot({
      VarPlotData()
      xAxisTicks()
      ggplot(VarPlotData())+
        geom_line(aes(x=Year, y=varTotPrecip))+
        labs(y="Variance in Total Monthly Precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=19))
    })
    
    output$TotPlot <- renderPlot({
      TotPlotsData()
      ggplot(TotPlotsData())+
        geom_line(aes(x=Year, y=TotYrPrecip), group=1, size=0.8)+
        labs(y="Total yearly precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=20))
    })
    
    output$CumuPlot <- renderPlot({
      ggplot(TotPlotsData())+
        geom_line(aes(x=Year, y=CumuPrecip), size=0.8)+
        labs(y="Cumulative precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=20))
    })
    
}

