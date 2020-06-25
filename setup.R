#Attach Packages
library(shiny)
library(tidyverse)
library(tidync)
library(colorspace)
library(gridExtra)

#filenames
LENS_precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"

#setup for reference plot
us <- map_data("state")