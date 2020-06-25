#This script is to create a data frame that has the decadal average cumulative
#precipitation waveform by decade, latitude and longitude. It will store the 
#resulting data frame as a .csv file. 

#store file name
precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"

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

#functions used in function sawtooth()
conv_to_water_year <- function(year,day){
  if(day<274){
    wateryear <- year
  }
  if(day>=274){
    wateryear <- year+1
  }
  return(wateryear)
} 
conv_to_water_day <- function(day){
  waterday <- ((day-274)%%365)+1
  return(waterday)
}
add_cumsum <- function(x){
  return(x%>%mutate(cumulative_precip = cumsum(PREC)))
}

#function that converts prec into the cumulative prec for that rain year, for a 
#single pixel:
sawtooth <- function(lat_val,lon_val){
  precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"
  
  
  
  tibble1 <-  tidync(precfile)%>%
    hyper_filter(
      lat = lat==lat_val,
      lon = lon==lon_val
    )%>%
    hyper_tibble()%>%
    group_by(time)%>%
    summarise(PREC = mean(PREC,na.rm = TRUE))%>%
    mutate(calendar_date = (time-min(time))%%365+1)%>%
    mutate(year = (time-min(time))%/%365+1920)%>%
    mutate(water_year = map2_dbl(.x=year, .y=calendar_date, .f=conv_to_water_year))%>%
    mutate(water_day = map_dbl(.x=calendar_date,.f=conv_to_water_day))
  
  tibble2 <- tibble1%>%
    group_by(water_year) %>%
    nest()
  
  tibble2$data%>%
    map(.f=add_cumsum)%>%
    enframe()%>%
    unnest()%>%
    select(-name)%>%
    mutate(water_year = tibble1$water_year)%>%
    mutate(time=tibble1$time)%>%
    select(water_year,water_day,cumulative_precip)
}

agg_sawtooth <- function(x){
  x%>%
    filter(water_year>1920)%>% #We need to remove this year since we don't have the first few months
    mutate(decade = (water_year%/%10)*10)%>%
    group_by(water_day,decade)%>%
    summarise(avg_cumulative_prec = mean(cumulative_precip,na.rm = TRUE))
}

sawtooth_combined <- function(lat_val,lon_val){
  sawtooth(lat_val,lon_val)%>%
    agg_sawtooth()
}

#define the grid of pixels to be used
grid <- expand.grid(latitude=latitudes,longitude=longitudes)

#nest the grid, mutate data column using above functions and purrr, unnest and 
#store in csv
#===
#WARNING: THIS PART TAKES A LOOOOONG TIME
#===
nest(grid,data=NULL)%>%
  mutate(data=map2(.x=latitude,.y=longitude,.f=sawtooth_combined))%>%
  unnest()%>%
  saveRDS(file="/home/ST505/precalculated_data/yearly_cumulative_prec.rds")

