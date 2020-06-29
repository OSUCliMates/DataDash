#This function needs the following data frame to run:
range_dat <- readRDS(file="/home/ST505/precalculated_data/dec_mem_range.rds")

multiplot_colors <- scale_colour_manual(values = c("1" = "#440154FF",
                                                   "2" = "#453781FF",
                                                   "3" = "#2D708EFF",
                                                   "4" = "#1F968BFF",
                                                   "5" = "#3CBB75FF",
                                                   "6" = "#95D840FF",
                                                   "7" = "#FDE725FF",
                                                   "8" = "#000000"))
multiplot_fill <- scale_fill_manual(values = c("1" = "#440154FF",
                                               "2" = "#453781FF",
                                               "3" = "#2D708EFF",
                                               "4" = "#1F968BFF",
                                               "5" = "#3CBB75FF",
                                               "6" = "#95D840FF",
                                               "7" = "#FDE725FF",
                                               "8" = "#000000"))




#use ggplot to make an error message
err_plot <- ggplot()+
  annotate(geom="text",y=1,x=1,label="Oops! It looks like there weren't any raster pixels in your window. Please try a larger window.")+
  theme_void()

# lat_min <- latitudes[6]
# lat_max <- latitudes[8]
# lon_min <- longitudes[24]
# lon_max <- longitudes[26]

plot_ranges_box <- function(lat_min,lat_max,lon_min,lon_max){
  #first we check to see that there were raster points selected
  dat <- range_dat%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max) %>%
    group_by(day_of_yr, decade) %>%
    summarise(avg_prec_range = mean(precip_range))%>%
    ungroup()
  ndat <- dat%>%
    select(avg_prec_range)%>%
    summarise(n=as.numeric(n()))

  if(ndat==0){err_plot}else{
    ggplot(dat, aes(x= avg_prec_range, y=factor(decade), color=factor(decade)))+
      geom_boxplot()+
      theme_dd() +
      multiplot_colors +
      multiplot_fill
    
  }
}

plot_ranges_smooth <- function(lat_min,lat_max,lon_min,lon_max){
  #first we check to see that there were raster points selected
  dat <- range_dat%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max) %>%
    group_by(day_of_yr, decade) %>%
    summarise(avg_prec_range = mean(precip_range))%>%
    ungroup()
  ndat <- dat%>%
    select(avg_prec_range)%>%
    summarise(n=as.numeric(n()))
  
  if(ndat==0){err_plot}else{
    dat %>%
      #filter(decade %in% c(decades_picked)) %>%
      ggplot(aes(x = day_of_yr, y=avg_prec_range, color=factor(decade)))+
      geom_smooth(se=FALSE) + theme_dd() + multiplot_colors
    #ggarrange(p1,p2,nrow=2, common.legend = TRUE)
  }
}




