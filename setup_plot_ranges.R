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
  annotate(geom="text",y=1,x=1,label=
             "Oops! Your selection doesn't have any Station Locations in it.
           Please drag and drop on the sidebar map again to make a selection that covers one or more of the points.", 
           size=4)+
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
      geom_smooth(se=FALSE) + theme_dd() + multiplot_colors+
      guides(fill = guide_legend(title = "Decade",
                                   title.position = "right",
                                   title.theme = element_text(angle = 270)))+
      scale_x_continuous(
        breaks=c(1, 32, 60, 91, 121, 152,182,213, 244,274,305, 335),
        labels=c("\nJan 1st","\nFeb 1st","\nMar 1st",
                 "\nApr 1st", "\nMay 1st", "\nJune 1st",
                 "\nJuly 1st", "\nAug 1st", "\nSept 1st",
                 "\nOct 1st", "\nNov 1st", "\nDec 1st"))+
      scale_y_continuous(limits = c(0, 8))+
      # scale_y_continuous(
      #   breaks=c(1, 32, 60, 91, 121, 152,182,213, 244,274,305, 335),
      #   labels=c("\nJan 1st","\nFeb 1st","\nMar 1st",
      #            "\nApr 1st", "\nMay 1st", "\nJune 1st",
      #            "\nJuly 1st", "\nAug 1st", "\nSept 1st",
      #            "\nOct 1st", "\nNov 1st", "\nDec 1st"))+
      theme(axis.text.x = element_text(angle=45))+
      labs(title = "Average Precipitation Range Between Ensemble Members",
           x = "Day of the Year",
           y = "Average Range in Precipitation (mm)")
    #ggarrange(p1,p2,nrow=2, common.legend = TRUE)
  }
}
#summary((range_dat$precip_range*10))


#plot_ranges_smooth(lat_min,lat_max,lon_min,lon_max)

