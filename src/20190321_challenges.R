library(sf)
library(tidyverse)
library(BelgiumMaps.StatBel)
library(leaflet)
library(htmltools)

# Get Flemish provinces
data("BE_ADMIN_PROVINCE") # load spatial object at provincial level
provinces_be <- st_as_sf(BE_ADMIN_PROVINCE) # convert to sf-object
provinces <-
  provinces_be %>%
  filter(TX_RGN_DESCR_NL == 'Vlaams Gewest')

# Plot provinces
ggplot() +
  geom_sf(data = provinces)

## Get number of Chinese mitten crab occurrences per province in 2015 en 2016
n_crab_provinces <- read_csv("./data/20190321_n_crabs_provinces.csv")

# Challenge 1: ----
# Color provinces based on number of crab occurrences in 2016
# Hint: https://workshop.mhermans.net/thematic-maps-r/04_plot.html#ggplot_with_geom_sf()

# YOUR CODE...





# Challenge 2: ----
# create an interactive map by using `leaflet` package showing the same information
# as in challenge 1
# Get inspiration from:
# https://rstudio.github.io/leaflet/colors.html
# https://rstudio.github.io/leaflet/legends.html







