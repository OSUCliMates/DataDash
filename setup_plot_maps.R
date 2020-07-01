

# type is of -1 or 1 (-1 for zoom in, 1 for zoom out)
zoom_func <- function(current_zoom,state,type){
    newValue <- ifelse(current_zoom - 1 < 0,
           current_zoom + type *.2, # if zooming within state zoom less
           current_zoom+ type *1 )
    if(state == "United States"){
        newValue <- current_zoom + type * 7
    }
    return(newValue)
}

map_bounds <- function(state,current_zoom){
    ratio <- 1.3
    if(state == "United States"){
        bounds <- list(lon_range = c(max(-136.5, -136.5 - current_zoom),
                                     min(-58.5, -58.5 + current_zoom)),
                       lat_range = c(max(17.25, 17.25 - ratio*current_zoom),
                                     min(55.5, 55.5 + ratio*current_zoom)))
    }else{
        state_map <- map_data("state", region = state)
        bounds <- list(lon_range = c(max(-136.5,min(state_map$long)-current_zoom),
                                     min(-58.5,max(state_map$long) + current_zoom)),
                       lat_range = c(max(17.25,min(state_map$lat) - current_zoom),
                                     min(55.5,max(state_map$lat) + current_zoom)))
    }
    return(bounds)
}

# the location_points should already be read in I believe
#location_points <- read.csv("~/DataDash/Data/lat_lon_pairs.csv")
plot_brushed_map <- function(state, current_zoom, bounding_box){
    if(state == "Hawaii" | state == "Alaska"){
        return(ggplot()+
            annotate(geom="text",y=1,x=1,
                     label="Oops! This state is not included in our dataset. Please select another.")+
            theme_void()
        )
    }
    mapdata <- map_data("state")
    pointsize <- 2
    if(current_zoom < 0 & state != "United States"){
        mapdata <- map_data("county")
        pointsize <- 3
    }
    if(state == "United States"){
        pointsize = .1
    }
    ggplot() + 
        geom_polygon(data = mapdata,
                     aes(x=long,y=lat,group=group), fill = "light grey", color = "black")+
        geom_point(data = location_points, 
                   aes(x = lon, y = lat,shape = dataset),
                   size = pointsize) +
        coord_quickmap(xlim = bounding_box$lon_range,
                       ylim = bounding_box$lat_range) +
        scale_shape_discrete(labels=c("ERA", "CESM-LENS"))+
        labs(shape = "Data set",
             title = "Observation Locations") +
        theme_dd() +
        theme(axis.text = element_blank(),
              axis.title = element_blank(),
              axis.ticks = element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              legend.position = "bottom",
              legend.title = element_blank(),
              panel.grid = element_blank()
        )
}



get_precip_deviation_data <- function(selected_points, data_choice){
  points <- selected_points %>% filter(dataset == "era")
    precip_deviation %>% 
        filter(between(lon,
                       ifelse(identical(points$min_lon,numeric(0)),0,points$min_lon),
                       ifelse(identical(points$max_lon,numeric(0)),0,points$max_lon)),
               between(lat,
                       ifelse(identical(points$min_lat,numeric(0)),0,points$min_lat),
                       ifelse(identical(points$max_lat,numeric(0)),0,points$max_lat))) %>% 
        #group_by(month_date) %>% 
        #mutate(percent_deviation = diff_from_prec_mean/overall_prec_mean) %>%
        group_by(quarter_date,season) %>%
        
        summarize(avg_perc_dev = mean(percent_deviation)) %>%
        #summarize(mean_deviation = mean(diff_from_prec_mean)) %>%
        #summarize(mean_deviation = mean(diff_from_prec_mean),
        #          percent_deviation = mean(diff_from_prec_mean)/mean(overall_prec_mean)) %>% 
    
        #mutate(month = lubridate::month(month_date,label = T),
         #      data_choice = data_choice)
        mutate(data_choice = data_choice)
}


#era_precip_quarter_deviation %>% 
  

get_us_precip_deviation <- function(){
    precip_deviation %>% 
     # mutate(percent_deviation = diff_from_prec_mean/overall_prec_mean) %>%
     #era_precip_quarter_deviation %>%   
        #group_by(quarter_date) %>%
        group_by(quarter_date,season) %>%
        summarize(avg_perc_dev = mean(percent_deviation)) %>%
        #group_by(month_date) %>% 
        #summarize(mean_deviation = mean(diff_from_prec_mean)) %>%
        #summarize(mean_deviation = mean(diff_from_prec_mean),
        #          percent_deviation = mean(diff_from_prec_mean)/mean(overall_prec_mean)) %>% 
        #mutate(month = lubridate::month(month_date,label = T),
        #       data_choice = "United States")
        mutate(data_choice = "United States Average")
        
}


seasonal_precip_deviation <- function(data, compare = FALSE, empty = FALSE){
  if(compare){
    pal <- c("#440154FF","#1F968BFF","grey")
  }else{
    pal <- c("#440154FF","grey")
  }
  if(empty){
    pal <- c("grey")
  }
    data %>%
      mutate(season = factor(season, levels = c("Winter", "Spring", "Summer", "Fall"))) %>% 
        ggplot() +
        geom_hline(yintercept = 0,linetype = "dashed") +
        geom_line(aes(x = as.Date(quarter_date), y = avg_perc_dev,#y = mean_deviation,
                      group = data_choice,
                      color = data_choice),size = 1.5)+
        scale_x_date() +
        scale_y_continuous(labels = scales::percent, n.breaks = 3) +
        scale_color_manual(values = pal)+
        facet_wrap(~season,ncol = 1)+
        theme_dd() +
        theme(panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              legend.title = element_blank()) +
        labs(x = "Year",y = expression(paste("Percent deviation from seasonal precip average (", drier %<->% wetter ,")")))
}


monthly_precip_deviation <- function(data){
    data %>%
        #precip_deviation_test %>% mutate(month = lubridate::month(month_date),data_choice = "one") %>%# dataset for testing 
        ggplot() +
        geom_hline(yintercept = 0,linetype = "dashed") +
        geom_line(aes(x = as.Date(month_date), y = mean_deviation,
        #geom_ribbon(aes(x = as.Date(quarter_date),ymin = mean_deviation, ymax = 0,
                        group = data_choice,
                                      color = data_choice)) +
                        #fill = data_choice))+
        scale_x_date() +
        scale_y_continuous(labels = scales::percent()) +
        facet_wrap(~month) + 
        theme_dd() +
        theme(panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              legend.title = element_blank()) +
        labs(x = "Year", y = expression(drier %<->% wetter))
}


seasonal_strips <- function(data){
    data %>%
        ggplot() +
        geom_tile(aes(x = as.Date(quarter_date), y = 1,fill= avg_perc_dev)) +#fill = mean_deviation)) +
        facet_wrap(~data_choice,ncol = 1,strip.position = "left") +
        scale_fill_gradient2(low = "#3d2007",mid = "white",high = "#187327") +
        scale_x_date() + 
        labs(x = "",y = "") +
        guides(fill = guide_colorbar(title = expression(wetter %<->% drier),
                                     title.position = "right",
                                     title.theme = element_text(angle = 270))) +
        theme_dd() +
        theme(axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              legend.text = element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              panel.spacing = unit(-.5, "lines"),
              panel.grid.major.x = element_blank(),
              panel.grid.major.y = element_blank()) 
}


monthly_strips <- function(data){
    data %>% 
        ggplot() +
        geom_tile(aes(x = as.Date(month_date), y = 1,fill = mean_deviation)) +
        scale_fill_gradient2(low = "#3d2007",mid = "white",high = "#187327") +
        facet_wrap(~data_choice,ncol = 1,strip.position = "left") +
        scale_x_date() + 
        labs(x = "",y = "") +
        guides(fill = guide_colorbar(title = expression(wetter %<->% drier),
                                     title.position = "right",
                                     title.theme = element_text(angle = 270))) +
        theme_dd() +
        theme(axis.text.y = element_blank(),
              axis.ticks.y = element_blank(),
              legend.text = element_blank(),
              panel.background = element_rect(fill = "transparent",colour = NA),
              plot.background = element_rect(fill = "transparent",colour = NA),
              panel.spacing = unit(-.5, "lines"),
              panel.grid = element_blank()) 
}
