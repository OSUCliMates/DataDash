

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
                     aes(x=long,y=lat,group=group), fill = NA, color = "black")+
        geom_point(data = location_points, 
                   aes(x = lon, y = lat,color = dataset),
                   size = pointsize) +
        coord_quickmap(xlim = bounding_box$lon_range,
                       ylim = bounding_box$lat_range) +
        labs(color = "Dataset",
             title = "Station/Observation Locations") +
        theme(#axis.text = element_blank(),
              axis.title = element_blank(),
              axis.ticks = element_blank()
        )
}