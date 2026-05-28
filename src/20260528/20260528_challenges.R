library(inbospatial)
library(terra)
library(sf)
library(exactextractr)
library(tidyverse)

## CHALLENGE 1 ####


legend <- readr::read_csv(
  "./data/20260528/20260528_lu_nara_legend.txt",
  col_types = readr::cols(
    id = col_double(),
    land_use = col_character(),
    color = col_character()
  ))
legend


# CHALLENGE 2 ####

municipalities_fl <- sf::st_read(
  dsn = "./data/20260528/20260528_municipalities_flanders.gpkg",
  crs = 31370
)
# Get the bounding box of the municipalities, and add a buffer of 1000 meters to it.
bbox <- sf::st_bbox(municipalities_fl)
bbox[c("xmax", "ymax")] <- bbox[c("xmax", "ymax")] + 1000

# Light emission in 2024
light_2024 <- inbospatial::get_coverage_wcs(
  "mercatornet",
  bbox = bbox,
  layername = "hh:hh_licht_2024_v3",
  resolution = 100,
  wcs_crs = "EPSG:31370"
)

# You can use terra::plot() function for visualizing both rasters (light emission) and polygons (municipalities)
terra::plot(light_2024)
terra::plot(sf::st_geometry(municipalities_fl)) # To visualize only the borders






# CHALLENGE 3 ####

