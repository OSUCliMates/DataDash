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

#source function for plotting sawtooth waveforms
source("setup_plot_sawtooth.R",local=TRUE)

#setup for reference plot
us <- map_data("state")

#initialize vars (probably should be elsewhere?)
shp_file_s8 <- st_read("oregon_boundary/or_state_boundary.shp") %>% 
  st_transform(4326)
hov_df <- data.frame(x=0, y=0)
hov_df <- c("Cursor Longitude", "Cursor Latitude")
extent_df <- data.frame(Longitude=c(0,0), Latitude=c(0,0))