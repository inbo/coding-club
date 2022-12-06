library(tidyverse)
library(sf)
library(terra)
library(maptiles)
library(mapview)
library(leaflet)
library(htmltools)
library(leafem)
library(crosstalk)
library(DT)


## CHALLENGE 1 - Plots

# Plotting is still important. Let's warm-up by plotting some geospatial data.

# 1. GIS data (continuous variable)
natura2000 <- st_read("./data/20221206/20221206_protected_areas.gpkg")

# 2. Raster data (continuous variable)
nitrogen <- rast("./data/20221206/20221206_nitrogen.tif")


# 3. Raster data (categorical values)
lu_nara_2016 <- rast("./data/20221206/20221206_lu_nara_2016_100m.tif")
legend_land_use <- tibble( # a tibble is a "nicely printed" data.frame
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


## CHALLENGE 2 - static maps




## CHALLENGE 3 - dynamic maps

# read occurrences giant hogweed
occs_hogweed <- readr::read_tsv(
  file = "./data/20221206/20221206_gbif_occs_hogweed.txt",
  na = ""
)
# transform to sf spatial data.frame
occs_hogweed <- st_as_sf(occs_hogweed,
                         coords = c("decimalLongitude", "decimalLatitude"),
                         crs = 4326)
# count number of "points" in Natura2000 areas
occs_in_areas <- st_contains(natura2000, occs_hogweed)
# get number of points in each polygon as a vector
natura2000$n_occs <- purrr::map_dbl(occs_in_areas, function(x) length(x))



# 3. link to image

img <- "https://raw.githubusercontent.com/inbo/coding-club/master/docs/assets/images/coding_club_logo.svg"



