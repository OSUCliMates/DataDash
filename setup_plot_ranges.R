# range_dat <- readRDS(file="/home/ST505/precalculated_data/dec_mem_range.rds")
range_dat <- readRDS(file="Data/dec_mem_range.rds")
# explain_range_dat <- readRDS(file="/home/ST505/precalculated_data/explain_mem_ranges.rds")
explain_range_dat <- readRDS(file="Data/explain_mem_ranges.rds")

# hard coded viriris colors
multiplot_colors <- scale_colour_manual(values = c("1" = "#042333ff",
                                                   "2" = "#13306dff",
                                                   "3" = "#593d9cff",
                                                   "4" = "#7e4e90ff",
                                                   "5" = "#b8627dff",
                                                   "6" = "#eb8055ff",
                                                   "7" = "#f9b641ff",
                                                   "8" = "#e8fa5bff"),
                                        labels = c("1920s",
                                                   "1930s",
                                                   "1940s",
                                                   "1950s",
                                                   "1960s",
                                                   "1970s",
                                                   "1980s",
                                                   "1990s"),
                                        name = "Decade")
multiplot_fill <- scale_fill_manual(values = c("1" = "#042333ff",
                                               "2" = "#13306dff",
                                               "3" = "#593d9cff",
                                               "4" = "#7e4e90ff",
                                               "5" = "#b8627dff",
                                               "6" = "#eb8055ff",
                                               "7" = "#f9b641ff",
                                               "8" = "#e8fa5bff"))

multiplot_size <- scale_size_manual(values = c("1" =0.5,
                                               "2" =0.5,
                                               "3" =0.5,
                                               "4" =0.5,
                                               "5"= 0.5,
                                               "6"=1,
                                               "7"=1,
                                               "8"=1.5))


# error message
err_plot <- ggplot()+
  annotate(geom="text",y=1,x=1,label=
             "Oops! Your selection doesn't have any Station Locations in it.
           Please drag and drop on the sidebar map again to make a selection that covers one or more of the points.", 
           size=4)+
  theme_void()

# function called to make box plot
plot_ranges_box <- function(lat_min,lat_max,lon_min,lon_max){
  #check if observation points were actually selected
  dat <- range_dat%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max) %>%
    group_by(day_of_yr, decade) %>%
    summarise(avg_prec_range = mean(precip_range))%>%
    ungroup()
  ndat <- dat%>%
    dplyr::select(avg_prec_range)%>%
    summarise(n=as.numeric(n()))
  # if statement to either plot or make error message
  if(ndat==0){err_plot}else{
    ggplot(dat, aes(x=factor(decade), y= avg_prec_range, fill=factor(decade)))+
      geom_boxplot(color = "black")+
      theme_dd() +
      theme(legend.position = "none",
            axis.text.x = element_text(angle=90, ),
            axis.title.y = element_text(size = 16),
            axis.title.x = element_text(size = 16))+
     multiplot_fill +
      labs(title="Distribution of Average Precipitation Ranges for this Area, by Decade",
           x = "\nDecade",
           y = "Average Precipitation Range (cm/day)\n")+
      scale_x_discrete(
        breaks=c(1, 2, 3, 4, 5, 6,7,8),
        labels=c("1920s",
                 "1930s",
                 "1940s",
                 "1950s",
                 "1960s",
                 "1970s",
                 "1980s",
                 "1990s"))
    
  }
}

# function called to make smoothed plot
plot_ranges_smooth <- function(lat_min,lat_max,lon_min,lon_max){
  #check if observation points were actually selected
  dat <- range_dat%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max) %>%
    group_by(day_of_yr, decade) %>%
    summarise(avg_prec_range = mean(precip_range))%>%
    ungroup()
  ndat <- dat%>%
    dplyr::select(avg_prec_range)%>%
    summarise(n=as.numeric(n()))
  # if statement to either plot or make error message
  if(ndat==0){err_plot}else{
    p3 <- dat %>%
      ggplot(aes(x = day_of_yr, y=avg_prec_range, color=factor(decade)))+
      geom_smooth(se=FALSE) + 
      geom_hline(yintercept = 0.6, size = 0.75)+
      geom_hline(yintercept = 0.3, size =0.75)+
      theme_dd() + 
      multiplot_colors+
      multiplot_size+
      guides(fill = FALSE)+
      scale_x_continuous(
        breaks=c(1, 32, 60, 91, 121, 152,182,213, 244,274,305, 335),
        labels=c("Jan 1st","Feb 1st","Mar 1st",
                 "Apr 1st", "May 1st", "June 1st",
                 "July 1st", "Aug 1st", "Sept 1st",
                 "Oct 1st", "Nov 1st", "Dec 1st"))+
      theme(axis.text.x = element_text(angle=90),
            axis.title.y = element_text(size = 16),
            axis.title.x = element_text(size = 16))+
      labs(title = "Average Precipitation Range Between Ensemble Members",
           x = "\nDay of the Year",
           y = "Avg. Range (cm precipitation/day)\n")
    p3 +annotate("text", x = 350, y = 0.55, label = "y=0.6")+
      annotate("text", x = 350, y = 0.35, label = "y=0.3")
  }
}

# Explanation Plots
plot_range_explain_1 <- function(){
  get_ranges <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(precip_range = (max(PREC, na.rm=TRUE)-min(PREC,na.rm = TRUE)))
  get_max <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(maxmax = max(PREC, na.rm=TRUE))
  get_min <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(minmin = min(PREC,na.rm = TRUE))
  p1 <- ggplot()+
    geom_point(data=explain_range_dat, aes(x=day_of_yr, y=PREC, group=factor(mem)), alpha=0.5)+
    geom_point(data=get_max, aes(x=day_of_yr, y=maxmax), color="red", size=3)+
    geom_point(data=get_min, aes(x=day_of_yr, y=minmin), color="red", size=3)+
    geom_line(data=explain_range_dat, aes(x=day_of_yr, y=PREC, group=factor(mem)), alpha=0.1)+
    theme_dd()+
    labs(title="Average Precipitation \n122°50'W, 44°76.440'N, January of the 1980's",
         subtitle="Each black dot and it's connecting line represents an individual member of the ensemble model, with the minimum and maximum precipitation values for each day highlighted in red",
         x = "\nDay of the Year",
         y = "Average Precipitation (cm/day)\n")
  p1}

plot_range_explain_2 <- function(){
  get_ranges <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(precip_range = (max(PREC, na.rm=TRUE)-min(PREC,na.rm = TRUE)))
  get_max <- explain_range_dat %>%
  group_by(day_of_yr) %>%
    summarise(precip_range = (max(PREC, na.rm=TRUE)-min(PREC,na.rm = TRUE)))
  get_max <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(maxmax = max(PREC, na.rm=TRUE))
  get_min <- explain_range_dat %>%
    group_by(day_of_yr) %>%
    summarise(minmin = min(PREC,na.rm = TRUE))
  p2 <- ggplot(data=get_ranges,aes(x = day_of_yr, y=precip_range))+
    geom_line(color="red")+
    theme_dd()+
    labs(title="Range of Member Average Precipitation Values\n122°50'W, 44°76.440'N, January of the 1980's",
         subtitle = "Note how the y-coordinates here match the coresponding magnitudes of the space between the red points above, for each day",
         x = "\nDay of the Year",
         y = "Range (cm precipitation/day)\n")
  p2}


# #for testing

# latitudes <- c(17.43455, 18.37696, 19.31937, 20.26178, 21.20419, 22.14660, 23.08901, 24.03141, 24.97382, 25.91623, 26.85864, 27.80105, 28.74346, 29.68586,
#                30.62827, 31.57068, 32.51309, 33.45550, 34.39791, 35.34031, 36.28272, 37.22513, 38.16754, 39.10995, 40.05236, 40.99476, 41.93717, 42.87958,
#                43.82199, 44.76440, 45.70681, 46.64921, 47.59162,48.53403, 49.47644, 50.41885, 51.36126, 52.30366, 53.24607, 54.18848, 55.13089)
# longitudes <- c(223.75, 225.00, 226.25, 227.50, 228.75, 230.00, 231.25, 232.50, 233.75, 235.00, 236.25, 237.50, 238.75, 240.00, 241.25, 242.50, 243.75, 245.00,
#                 246.25, 247.50, 248.75, 250.00, 251.25, 252.50, 253.75, 255.00, 256.25, 257.50, 258.75, 260.00, 261.25, 262.50, 263.75, 265.00, 266.25, 267.50,
#                 268.75, 270.00, 271.25, 272.50, 273.75, 275.00, 276.25, 277.50, 278.75, 280.00, 281.25, 282.50, 283.75, 285.00, 286.25, 287.50, 288.75, 290.00,
#                 291.25, 292.50, 293.75, 295.00, 296.25, 297.50, 298.75, 300.00, 301.25)
# members <- seq(1:42)
# lat_min <- latitudes[6]
# lat_max <- latitudes[8]
# lon_min <- longitudes[24]
# lon_max <- longitudes[26]
# plot_ranges_box(lat_min,lat_max,lon_min,lon_max)
# plot_ranges_smooth(lat_min,lat_max,lon_min,lon_max)
# summary(range_dat$precip_range)
