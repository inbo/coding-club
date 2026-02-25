library(tidyverse)
library(sf)
library(terra)
library(leaflet)
library(leafem)
library(mapview)
library(viridis)
library(inbospatial)

# CHALLENGE 1 ####

# Load the data
visits <- readr::read_csv(
  file = "./data/20260225/20260225_butterflies_love_plants.csv",
  na = "") %>%
  # Convert to spatial data.frame
  sf::st_as_sf(coords = c("lng", "lat"), crs = 4326)

## 1.1 ####


## 1.2 ####


## 1.3 ####



## 1.4 ####



## 1.5 ####



## 1.6 (Extra) ####



# CHALLENGE 2 ####
# Load the temperature raster data
temperature <- terra::rast(x = "./data/20260225/20260225_tdiff_tmax_tmin_01.tif")
# Check the layers
names(temperature)

## 2.1 ####


## 2.2 ####
min_value_diff <- terra::minmax(temperature)[1,1]
max_value_diff <- terra::minmax(temperature)[2,1]


## 2.3 ####



# CHALLENGE 3 ####

# Load data
moth_captures <- readr::read_csv(
  file = "./data/20260225/20260225_moth_captures.csv",
  na = "")

## 3.1 ####


## 3.2 ####


## 3.3 ####


## 3.4 ####


## 3.5 ####

