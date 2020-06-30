#Attach Packages
library(shiny)
library(tidyverse)
library(tidync)
library(colorspace)
library(gridExtra)
library(sf)
library(viridis)
library(shinycssloaders)
library(shinythemes)
library(ggpubr)
library(shinyjs)


appCSS <- "
#loading-content {
  position: absolute;
  background: #000000;
  opacity: 0.9;
  z-index: 100;
  left: 0;
  right: 0;
  height: 100%;
  text-align: center;
  color: #FFFFFF;
}
"

#filenames
LENS_precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"

#setup for reference plot
us <- map_data("state")
BigDF <- readRDS("/home/ST505/precalculated_data/allUSShiny.rds")  #JRR
toMap <- distinct(BigDF, lat, lon2)  #JRR

#setup for range plot
range_dat <- readRDS(file="/home/ST505/precalculated_data/dec_mem_range.rds")

# PRECIPITATION DEVIATION FROM AVERAGE
# Code to calculate this dataset found in era_precip_deviation.R in Examples folder in CliMates
# if using Months:
#precip_deviation <- readRDS("/home/ST505/precalculated_data/era_precip_deviation.rds")
# if using Quarters:
precip_deviation <- readRDS("/home/ST505/precalculated_data/era_precip_quarter_deviation.rds")

# read in list of ERA and CESM unique loation lat/long pairs - used for locaiton selection
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

# theme
theme_dd <-  function () {theme(
  #plot.background = element_rect(fill = "transparent", color=NA),
                                plot.background = element_rect(fill = "darkgray"),
                                panel.grid.major.y = element_line(color = "grey90"),
                                panel.grid.major.x = element_line(color = "grey90"),
                                #plot.margin = unit(c(1, 1.5, 1, 1), "cm"),
                                plot.title = element_text(size = 20, face="bold", hjust = 0.5, vjust = 0.5),
                                axis.text = element_text(size = 12, face = "bold"),
                                #axis.title = element_text(size = 16),
                                panel.background= element_rect(fill = "white"),
                                #panel.background = element_rect(fill = "transparent",colour = NA),
                                panel.border = element_rect(colour = "black", fill=NA, size=2),
                                legend.background = element_rect(fill = "white"),
                                legend.text = element_text(size = 12),
                                legend.title = element_text(size=16)
                                )}
