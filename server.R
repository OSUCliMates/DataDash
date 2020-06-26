# Define server logic required to draw a histogram
server <- function(input, output) {

  
  # K8 I think
    output$sawtooth <- renderPlot({
      #a <- input$lat[1]
      #b <- input$lat[2]
      #c <- input$lon[1]%%360
      #d <- input$lon[2]%%360
      # figure out what to do if inf 
      
      max_mins <- brushedPoints(location_points,
                                input$plot_brush,
                                xvar = "lon",yvar = "lat") %>% 
        filter(dataset == "lens") %>% 
        summarize(min_lon = min(lon),
                  max_lon = max(lon),
                  min_lat = min(lat),
                  max_lat = max(lat)) %>% 
        as_vector()
      min_lat <- max_mins[3]
      max_lat <- max_mins[4]
      min_lon <- max_mins[1]%%360
      max_lon <- max_mins[2]%%360
      plot_sawtooths(min_lat,max_lat,min_lon,max_lon)

    })
    
    #I'M COMMENTING THIS OUT SINCE IT'S REDUNDANT AT THIS POINT 
    #output$ref_map <- renderPlot({
    #   
    #   max_mins <- brushedPoints(location_points,
    #                             input$plot_brush,
    #                             xvar = "lon",yvar = "lat") %>% 
    #     filter(dataset == "lens") %>% 
    #     summarize(min_lon = min(lon),
    #               max_lon = max(lon),
    #               min_lat = min(lat),
    #               max_lat = max(lat))
    #   a <- max_mins[1,3]
    #   b <- max_mins[1,4]
    #   c <- max_mins[1,1]
    #   d <- max_mins[1,2]
    #   
    #   ggplot(us, aes(x = long, y = lat, group = group)) +
    #     geom_polygon(fill="lightgray", colour = "black")+
    #     geom_rect(aes(xmin=c,
    #                   xmax=d,
    #                   ymin=a,
    #                   ymax=b),
    #               fill="darkorchid2",
    #               alpha=0.01
    #     )
      
      
      #ggplot(us, aes(x = long, y = lat, group = group)) +
      #  geom_polygon(fill="lightgray", colour = "black")+
      #  geom_rect(aes(xmin=input$lon[1],
      #                xmax=input$lon[2],
      #                ymin=input$lat[1],
      #                ymax=input$lat[2]),
      #            fill="darkorchid2",
      #            alpha=0.01
      #            )
      
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
    
    
    
    
    ## MLE 
    
    
    location_points <- read.csv("~/DataDash/Data/lat_lon_pairs.csv")
    
    zoom_val <- reactiveVal(0)       # rv <- reactiveValues(value = 0)
    
    observeEvent(input$zoom_in, {
      if(zoom_val() -1 < 0){
        newValue <- zoom_val() - .1
      }
      else{
        newValue <- zoom_val()-1
      }
      zoom_val(newValue)
    })
    
    observeEvent(input$zoom_out, {
      if(zoom_val() < 0){
        newValue <- zoom_val()+.1
      }
      else{
        newValue <- zoom_val() + 1
      } 
      zoom_val(newValue) 
    })
    observeEvent(input$state,{
      zoom_val(0)
    })
    observeEvent(input$reset,{
      zoom_val(0)
    })
    bounding <- reactive({
      state_map <- map_data("state",region = input$state)
      list(lon_range = c(max(-136.5,min(state_map$long)-zoom_val()),
                         min(-58.5,max(state_map$long)+zoom_val())),
           lat_range = c(max(17.25,min(state_map$lat)-zoom_val()),
                         min(55.5,max(state_map$lat)+zoom_val())))
    })
    
    output$point_selection_map <- renderPlot({
      mapdata <- map_data("state")
      if(zoom_val()<0){
        mapdata <- map_data("county")
      }
      ggplot() + 
        geom_polygon(data = mapdata,
                     aes(x=long,y=lat,group=group), fill = NA, color = "black")+
        geom_point(data = location_points, 
                   aes(x = lon, y = lat,color = dataset)) +
        coord_cartesian(xlim = bounding()$lon_range,
                        ylim = bounding()$lat_range)
    })
    

    # need to figure out good error message if nothing selected? 
    max_min_locations <- reactiveValues(min_lat = 41, 
                                        max_lat = 47,
                                        min_lon = -125,
                                        max_lon = -116)
    

    
    
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

