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
