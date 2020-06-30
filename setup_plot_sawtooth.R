#find variable indeces 
times <- 25550:56939
gbg<-tidync("/home/ST505/CESM-LENS/historical/PREC.nc")%>%
  hyper_filter(lat = lat<18)%>%
  hyper_filter(lon = lon<224)%>%
  hyper_filter(time= time==25550)%>%
  hyper_tibble()
members <- gbg$mem
gbg<-tidync("/home/ST505/CESM-LENS/historical/PREC.nc")%>%
  hyper_filter(mem = mem==1)%>%
  hyper_filter(time= time==25550)%>%
  hyper_tibble()
latitudes <- unique(gbg$lat)
longitudes <- unique(gbg$lon)
remove(gbg)

#This function needs the following data frame to run:
decadal_average_cumulative_prec_waveforms <- readRDS("Data/yearly_cumulative_prec.rds")

#use ggplot to make an error message
err_plot <- ggplot()+
  annotate(geom="text",y=1,x=1,label="Oops! It looks like there weren't any raster pixels in your window. Please try a larger window.")+
  theme_void()

lat_min <- latitudes[6]
lat_max <- latitudes[8]
lon_min <- longitudes[24]
lon_max <- longitudes[26]

plot_sawtooths <- function(lat_min,lat_max,lon_min,lon_max){
  #first we check to see that there were raster points selected
  dat <- decadal_average_cumulative_prec_waveforms%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max)
  ndat <- dat%>%
    select(avg_cumulative_prec)%>%
    summarise(n=n())%>%
    as.numeric()
  

  
  #After checking to make sure that there were raster points selected, this code runs
  if(ndat==0){err_plot}else{
    #generate cumulative rainfall (sawtooth) aggregate plots
    dat%>%
      group_by(water_day,decade)%>%
      summarise(cum_prec = mean(avg_cumulative_prec))%>%
      ggplot()+
      geom_line(aes(x=water_day,y=cum_prec,color=as.factor(decade)))+
      scale_color_discrete_sequential(palette = "viridis")+
      theme_dd()+
      labs(x="Day",
           y="Mean Cumulative Precipitation (cm)",
           color="Decade")+
      scale_x_continuous(
        breaks=c(1,62,124,183,244,305),
        labels=c("Oct 1","Dec 1","Feb 1","Apr 1","Jun 1","Aug 1")
      )
  }
}

plot_num_der <- function(lat_min,lat_max,lon_min,lon_max){
  #first we check to see that there were raster points selected
  dat <- decadal_average_cumulative_prec_waveforms%>%
    filter(latitude>=lat_min&latitude<=lat_max)%>%
    filter(longitude>=lon_min&longitude<=lon_max)
  ndat <- dat%>%
    select(avg_cumulative_prec)%>%
    summarise(n=n())%>%
    as.numeric()
  
  
  
  #After checking to make sure that there were raster points selected, this code runs
  if(ndat==0){ggplot()}else{
    #generate cumulative rainfall (sawtooth) aggregate plots
    dat%>%
      group_by(water_day,decade)%>%
      summarise(cum_prec = mean(avg_cumulative_prec))%>%
      group_by(decade)%>%
      nest()%>%
      mutate(agg_prec=map(data,nderiv))%>%
      unnest()%>%
      ggplot()+
      geom_line(aes(x=water_day,y=agg_prec,color=as.factor(decade)))+
      scale_color_discrete_sequential(palette = "viridis")+
      theme_dd()+
      labs(x="Day",
           y="Average Precipitation (cm/day)",
           color="Decade")+
      scale_x_continuous(
        breaks=c(1,62,124,183,244,305),
        labels=c("Oct 1","Dec 1","Feb 1","Apr 1","Jun 1","Aug 1")
      )
  }
}
