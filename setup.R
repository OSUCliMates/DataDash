#Attach Packages
library(shiny)
library(tidyverse)
library(tidync)
library(colorspace)
library(gridExtra)

#filenames
LENS_precfile <- "/home/ST505/CESM-LENS/historical/PREC.nc"

#source function for plotting sawtooth waveforms
source("setup_plot_sawtooth.R",local=TRUE)

#setup for reference plot
us <- map_data("state")