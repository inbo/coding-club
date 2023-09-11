library(tidyverse)
library(sf)
library(terra)
library(maptiles)
library(mapview)
library(leaflet)
library(htmltools)
library(htmlwidgets)
library(leafem)
library(crosstalk)
library(DT)


## CHALLENGE 1 - Plots

# 1 Vector data (continuous variable)
natura2000 <- sf::st_read("./data/20230831/20230831_protected_areas.gpkg")


pajottenland_municipalities <- st_read("./data/20230831/20230831_Pajottenland_municipalities.gpkg")


# 2. Raster data (continous variable)
nitrogen <- terra::rast("./data/20230831/20230831_nitrogen.tif")
nitrogen



# 3. Raster data (categorical values)
lu_nara_2016 <- terra::rast("./data/20230831/20230831_lu_nara_2016_100m.tif")
legend_land_use <- dplyr::tibble( # a tibble is a "nicely printed" data.frame
  id = c(1:9),
  land_use = c(
    "Open natuur",
    "Bos",
    "Grasland",
    "Akker",
    "Urbaan",
    "Laag groen",
    "Hoog groen",
    "Water",
    "Overig"
  ),
  color = c(
    rgb(red = 223, green = 115, blue = 255, maxColorValue = 255),
    rgb(38, 115, 0, maxColorValue = 255),
    rgb(152, 230, 0, maxColorValue = 255),
    rgb(255, 255, 0, maxColorValue = 255),
    rgb(168, 0, 0, maxColorValue = 255),
    rgb(137, 205, 102, maxColorValue = 255),
    rgb(92, 137, 68, maxColorValue = 255),
    rgb(0, 197, 255, maxColorValue = 255),
    rgb(204, 204, 204, maxColorValue = 255)
  )
)
legend_land_use





## Challenge 2 - static maps





## CHALLENGE 3 - dynamic maps

# read data.frame with number of moths species for each UTM1km cell (`TAG`
# identifier)
n_moths <- readr::read_csv("./data/20230831/20230831_n_moths.txt")
n_moths

# read the geospatial file containing the UTM1km cells of Pajottenland
utm1_pajottenland <- sf::st_read(
  "./data/20230831/20230831_utm1km_Pajottenland.gpkg"
)

# Join data
n_moths <- utm1_pajottenland %>%
  dplyr::left_join(n_moths, by = "TAG")

n_moths

# 1


# 2


# 3


# 4


# 5
img <- "https://raw.githubusercontent.com/inbo/coding-club/master/docs/assets/images/coding_club_logo.svg"



## BONUS CHALLENGE 1 - leaflet


# 1


# 2
n_moths_centroids <- sf::st_centroid(n_moths)


# 3



