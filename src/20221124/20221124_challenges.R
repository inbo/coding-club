library(tidyverse)
library(terra)
library(sf)
library(exactextractr)
library(geodata)


## CHALLENGE 1




# 4. Read `20221124_lu_nara_legend.txt` (code is provided!) so that you can set
# the color table associated with `lu_nara_2016`.
legend <- read_csv(
  "./data/20221124/20221124_lu_nara_legend.txt",
  col_types = cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend



#' 5. Calculate the most and least occurring land use category in each of the
#' Natura2000 protected areas (read these areas using the provided code). Tip: use exactextractr::exact_extract() and find
#' the right [summary operations](https://isciences.gitlab.io/exactextractr/#summary-operations)
natura2000 <- sf::st_read("./data/20221124/20221124_protected_areas_Lambert72.gpkg",
                      layer = "ps_hbtrl")



## CHALLENGE 2


# Load country boundaries as spatial polygons (sf package)
w <- sf::st_as_sf(geodata::world(resolution = 5, level = 0, path = tempdir()))
w
plot(w)



## BONUS CHALLENGE 1




# 2. Let's do something similar working with continuous rasters. Calculate a
# dataframe with min max and mean altitude for each Belgian province using
#`exact_extract()`. How to include the province name in the output? (code to get
#the data is provided in R script!). Tip:
#https://isciences.gitlab.io/exactextractr/#basic-usage

# Pull province boundaries for Belgium
belgium <- st_as_sf(raster::getData('GADM', country='BE', level=2))

# Pull gridded altitude world data
alt <- raster::getData('worldclim', var='alt', res=10)
