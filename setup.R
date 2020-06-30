#Attach Packages
library(shiny)
library(tidyverse)
library(tidync)
library(colorspace)
library(gridExtra)
library(sf)

#filenames
LENS_precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"
OR_shpfile <- "oregon_boundary/or_state_boundary.shp"

#setup for reference plot
us <- map_data("state")
BigDF <- readRDS("/home/ST505/precalculated_data/allUSShiny.rds")  #JRR
toMap <- distinct(BigDF, lat, lon2)  #JRR

#initialize vars (probably should be elsewhere?)
shp_file_s8 <- st_read("oregon_boundary/or_state_boundary.shp") %>% 
  st_transform(4326)
hov_df <- data.frame(x=0, y=0)
hov_df <- c("Cursor Longitude", "Cursor Latitude")
extent_df <- data.frame(Longitude=c(0,0), Latitude=c(0,0))


# MLE precip deviation 
precip_deviation <- readRDS("/home/ST505/precalculated_data/era_precip_deviation.rds")
# read in list of ERA and CESM unique loation lat/long pairs
location_points <- read.csv("~/DataDash/Data/lat_lon_pairs.csv")

#function for finding numeric derivative
nderiv <- function(x){
  y<-numeric(length=length(x$cum_prec))
  y[1] <- 0
  for(i in 2:length(x$cum_prec)){
    y[i]<- x$cum_prec[i]-x$cum_prec[i-1]
  }
  y[1] <- y[2] #makes it look nicer
  y
}

