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

# YOUR CODE...



# Challenge 3
# 1. Add occurrences from 2015 as markers/circles on the map
# 2. Provide popup
# 3. make sure the plot focuses on region around coordinate 51.1373384, 4.2813167
# 4. Add WMS services on rivers in Flanders as optional layers to the map

# Hints:
# - popups https://stackoverflow.com/questions/36887384/advanced-popups-in-r-shiny-leaflet
# - layercontrol https://rstudio.github.io/leaflet/showhide.html
# - wmstiles https://inbo.github.io/tutorials/tutorials/spatial_wms_services/#as-background-of-interactive-maps
# - look for layer names on https://geoservices.informatievlaanderen.be/raadpleegdiensten/VMM/wms?service=WMS&version=1.3.0&request=GetCapabilities

# read data
crab_df_2015 <- read_csv("./data/20190321_crab_occurrences_2015.csv")

# define URL WMS service VMM
wms_vmm <- "https://geoservices.informatievlaanderen.be/raadpleegdiensten/VMM/wms"

# YOUR CODE...




