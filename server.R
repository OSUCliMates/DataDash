# Define server logic required to draw a histogram
server <- function(input, output) {

  
  # K8 I think
    
    #first plot
    output$sawtooth <- renderPlot({
      plot_sawtooths(selected_points()$min_lat[2], # second entry is for lens
                     selected_points()$max_lat[2],
                     selected_points()$min_lon[2] %% 360,
                     selected_points()$max_lon[2] %% 360)

    })
    
    #second plot
    output$comp_sawtooth <- renderPlot({
      plot_sawtooths(
        selected_points_compare()$min_lat[2], # second entry is for lens
        selected_points_compare()$max_lat[2],
        selected_points_compare()$min_lon[2] %% 360,
        selected_points_compare()$max_lon[2] %% 360)
    
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
      
      #})
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
    
    
    
    ####################################################
    ## MLE 

    ############ Stuff for filtering map
    #initialize zoom 
    zoom_val <- reactiveVal(0)  
    observeEvent(input$zoom_in,{
      new_value <- zoom_func(current_zoom = zoom_val(),
                             state = input$state,
                             type = -1)
      zoom_val(new_value)
    })
    observeEvent(input$zoom_out,{
      new_value <- zoom_func(current_zoom = zoom_val(),
                             state = input$state,
                             type = 1)
      zoom_val(new_value)
    })
    #reset the zoom button if state is changed or called to reset 
    observeEvent(c(input$state,input$reset),{
      zoom_val(0)
    })

    # reactive bounding values to use for filtering 
    zoom_map_bounds <- reactive({
      map_bounds(state = input$state, 
                 current_zoom = zoom_val())
    })
    
    output$point_selection_map <- renderPlot({
      plot_brushed_map(state = input$state,
                       current_zoom = zoom_val(),
                       bounding_box = zoom_map_bounds())
    })
    
    
    
    # For second comparision map - 
    zoom_val_compare <- reactiveVal(0)  
    observeEvent(input$zoom_in2,{
      new_value <- zoom_func(current_zoom = zoom_val_compare(),
                             state = input$comparison_state,
                             type = -1)
      zoom_val_compare(new_value)
    })
    observeEvent(input$zoom_out2,{
      new_value <- zoom_func(current_zoom = zoom_val_compare(),
                             state = input$comparison_state,
                             type = 1)
      zoom_val_compare(new_value)
    })
    #reset the zoom button if state is changed or called to reset 
    observeEvent(c(input$comparison_state,input$reset2),{
      zoom_val_compare(0)
    })
    zoom_map_comparison_bounds <- reactive({
      map_bounds(state = input$comparison_state, 
                 current_zoom = zoom_val_compare())
    })
    output$comparison_point_selection_map <- renderPlot({
      plot_brushed_map(state = input$comparison_state,
                       current_zoom = zoom_val_compare(),
                       bounding_box = zoom_map_comparison_bounds())
      })
    
    
    ############
    # Set up of filtered datasets: 
    
    selected_points <- reactive({
      brushedPoints(location_points,
                    input$plot_brush,
                    xvar = "lon",yvar = "lat") %>% 
        group_by(dataset) %>% 
        summarize(min_lon = min(lon),
                  max_lon = max(lon),
                  min_lat = min(lat),
                  max_lat = max(lat))
    })
    selected_points_compare <- reactive({
      brushedPoints(location_points,
                    input$plot_brush2,
                    xvar = "lon",yvar = "lat") %>% 
        group_by(dataset) %>% 
        summarize(min_lon = min(lon),
                  max_lon = max(lon),
                  min_lat = min(lat),
                  max_lat = max(lat))
    })
    

    ####################################################
    ## MLE 
    ############ Stuff for plot 
    
    mles_data <- reactive({
      era_points <- selected_points() %>%
        filter(dataset == "era") 
      precip_deviation %>% 
        filter(between(lon,
                       era_points$min_lon,
                       era_points$max_lon),
               between(lat,
                       era_points$min_lat,
                       era_points$max_lat)) %>% 
        group_by(month_date) %>% 
        summarize(mean_deviation = mean(diff_from_prec_mean)) %>% 
        mutate(month = lubridate::month(month_date,label = T))
    })
    
    output$precip_deviation_plot <- renderPlot({
      
      n_rows <- mles_data() %>%
        select(month) %>% 
          summarize(n = n()) %>% as.numeric()
      if(n_rows ==0){return(err_plot)}
      
      mles_data() %>%
        ggplot() +
        geom_line(aes(x = as.Date(month_date), y = mean_deviation,
                      group = month,
                      color = month))+
        geom_hline(yintercept = 0) +
        scale_x_date() +
        scale_y_continuous(breaks = c(-.005,0,.005))+
        facet_wrap(~month) + 
        theme(legend.position = "none")+
        labs(title = "What months are most variable in rainfall?",
             x = "",
             y = "Difference from Average Monthly Rainfall")
      
    })
    
    output$precip_strips <- renderPlot({
      n_rows <- mles_data() %>%
        select(month) %>% 
        summarize(n = n()) %>% as.numeric()
      
      
      if(n_rows ==0){return(err_plot)}
      
      
      mles_data() %>%
      ggplot() +
        geom_tile(aes(x = as.Date(month_date), y = 1,fill = mean_deviation))+
        scale_fill_continuous_diverging(palette = "Green-Brown")+
        scale_x_date() + 
        labs(x = "",y = "")+
        theme(legend.position = "none",
              axis.text.y = element_blank(),
              axis.ticks.y = element_blank())
    })
    
    
    
    
    
    
    #### End MLE's stuff
    ####################################################

    
    
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

