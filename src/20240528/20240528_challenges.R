library(sf)         # To work with vector spatial data
library(tidyverse)  # To do datascience
library(mapview)    # Optional: for fast visualization purposes
library(terra)      # To work with rasters (only needed in BONUS CHALLENGE)



# File paths
lepidoptera_filepath <- "./data/20240528/20240528_lepidoptera_2024.tsv"
pa_filepath <- "./data/20240528/20240528_protected_areas_BE.gpkg"
utm_10_filepath <- "./data/20240528/20240528_utm10_belgium.geojson"

# Read GBIF occurrences of Lepidoptera as a data.frame
lepidoptera_df <- readr::read_tsv(lepidoptera_filepath)


## CHALLENGE 1



