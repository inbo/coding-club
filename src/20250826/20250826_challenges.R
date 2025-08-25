library(tidyverse)
library(ggspatial)
library(ggrepel)
library(mapview)
library(leafpop)
library(leafem)
library(inbospatial)

# Read the Geopackage with number of Giant Hogweed occurrences per municipality
n_giant_hogweed <- sf::st_read(
  dsn = "data/20250826/20250826_giant_hogweed_per_municipality.gpkg",
  layer = "giant_hogweed_per_municipality"
)

# CHALLENGE 1 ####

## 1.1 ####


## 1.2 ####


## 1.3 ####


## 1.4 ####
giant_hogweed <- readr::read_tsv(
  "data/20250826/20250826_giant_hogweed_fl_bxl.tsv",
  na = ""
  ) %>%
  sf::st_as_sf(
    coords = c("decimalLongitude", "decimalLatitude"),
    crs = 4326
  )


## 1.5 ####



# CHALLENGE 2 ####

# Get n_giant_hogweed for Brussels only
n_giant_hogweed_bxl <- n_giant_hogweed %>%
  dplyr::filter(reg_name_nl == "['Brussels Hoofdstedelijk Gewest']")

## 2.1 ####


## 2.2 ####


## 2.3 ####


## 2.4 ####


## 2.5 ####



# CHALLENGE 3 ####

## 3.1 ####


## 3.2 ####


## 3.3 ####


## 3.4 ####



# BONUS CHALLENGE ####

## BC.1 ####


## BC.2 ####


