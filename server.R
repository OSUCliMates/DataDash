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
    # # smither8
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
        geom_point(aes(x=Longitude, y=Latitude))+
        theme_dd()
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
    
    selected_points <- eventReactive(input$go,{
      brushedPoints(location_points,
                    input$plot_brush,
                    xvar = "lon",yvar = "lat") %>% 
        group_by(dataset) %>% 
        summarize(min_lon = min(lon),
                  max_lon = max(lon),
                  min_lat = min(lat),
                  max_lat = max(lat))
    })
    selected_points_compare <- eventReactive(input$go,{
      brushedPoints(location_points,
                    input$plot_brush2,
                    xvar = "lon",yvar = "lat") %>% 
        group_by(dataset) %>% 
        summarize(min_lon = min(lon),
                  max_lon = max(lon),
                  min_lat = min(lat),
                  max_lat = max(lat))
    })
    
    is_empty <- eventReactive(input$go,{
      nrows <- selected_points() %>%
        select(min_lat) %>% 
        summarize(n = n()) %>%
        as.numeric()
      ifelse(nrows == 0, TRUE, FALSE)
    })
    
    is_comparison_empty <- eventReactive(c(input$comparison_checkbox,input$go),{
      if(!input$comparison_checkbox){return(FALSE)}
      nrows <- selected_points_compare() %>%
        select(min_lat) %>% 
        summarize(n = n()) %>%
        as.numeric()
      ifelse(nrows == 0, TRUE, FALSE)
    })
    

    

    ####################################################
    ## MLE 
    ############ Data for plot 
    us_deviation <- get_us_precip_deviation()
    
    selection1 <- eventReactive(input$go,{
      #get_precip_deviation_data(selected_points(),data_choice="Selection 1")
      get_precip_deviation_data(selected_points(),
                                data_choice=input$state)
    })
    
    selection2 <- eventReactive(c(input$go,input$comparison_checkbox),{
      if(input$comparison_checkbox){
        get_precip_deviation_data(selected_points_compare(),
                                  data_choice=paste(input$comparison_state," - Bottom Map"))
      }
    })
    
    precip_deviation_data <- eventReactive(c(input$go,input$comparison_checkbox,input$baseline),{
      if(input$comparison_checkbox){
        data <- rbind(selection1(),selection2())
      }else{
        data <- selection1()
      }
      if(input$baseline){
        data <- rbind(data,us_deviation)
      }
      data
    })
    
    
    output$precip_deviation_plot <- renderPlot({
      if(is_empty()){return(err_plot)}
      
      precip_deviation_data() %>%
        #precip_deviation_test %>% mutate(month = lubridate::month(month_date),data_choice = "one") %>%# dataset for testing 
        ggplot() +
        geom_hline(yintercept = 0,linetype = "dashed") +
        geom_line(aes(x = as.Date(month_date), y = mean_deviation,
                      group = data_choice,
                      color = data_choice)) +
        scale_x_date() +
        scale_y_continuous(n.breaks = 3)+
        facet_wrap(~month) + 
        theme(panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              legend.title = element_blank())+
        labs(#title = "What months are most variable in rainfall?",
          x = "",
          y = expression(dryer %<->% wetter))+
        theme_dd()
      
    })


    
    
    output$precip_strips <- renderPlot({
      if(is_empty()){return(err_plot)}

      precip_deviation_data() %>% 
      #precip_deviation_test %>% # dataset for testing 
      #  mutate(date = as.Date(month_date)) %>%
      #  mutate(year = lubridate::year(date),
      #         month2 = lubridate::month(date)) %>%
      ggplot() +
        geom_tile(aes(x = as.Date(month_date), y = 1,fill = mean_deviation)) +
        #geom_tile(aes(x = year, y = month2,fill = mean_deviation)) + # tried to have it with month on y axis
        scale_fill_gradient2(low = "#3d2007",mid = "white",high = "#187327") +
        facet_wrap(~data_choice,ncol = 1,strip.position = "left")+
        #facet_grid(data_choice~month)+
        scale_x_date() + 
        labs(x = "",y = "") +
        guides(fill = guide_colorbar(title = expression(wetter %<->% dryer),
                                   title.position = "right",
                                   title.theme = element_text(angle = 270))) +
        theme(axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              legend.text = element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              panel.spacing = unit(-.5, "lines")) +
        theme_dd()

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
        theme(text = element_text(size=20))+
        theme_dd()
    })

    output$VarPlot <- renderPlot({
      VarPlotData()
      xAxisTicks()
      ggplot(VarPlotData())+
        geom_line(aes(x=Year, y=varTotPrecip))+
        labs(y="Variance in Total Monthly Precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=19))+
        theme_dd()
    })

    output$TotPlot <- renderPlot({
      TotPlotsData()
      ggplot(TotPlotsData())+
        geom_line(aes(x=Year, y=TotYrPrecip), group=1, size=0.8)+
        labs(y="Total yearly precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=20))+
        theme_dd()
    })

    output$CumuPlot <- renderPlot({
      ggplot(TotPlotsData())+
        geom_line(aes(x=Year, y=CumuPrecip), size=0.8)+
        labs(y="Cumulative precipitation (m)")+
        scale_x_continuous(breaks=xAxisTicks(), labels=xAxisTicks())+
        theme(text = element_text(size=20))+
        theme_dd()
    })
    
}

