library(sf)
library(readr)
library(dplyr)
library(mapview) # for basic visualization

# Read occurrences
occs_df <- readr::read_tsv(
  "data/20260126/20260126_occurrences_raccoon_be.txt",
  na = "",
  guess_max = 1000000
)

# Read species occurrence cube
cube <- readr::read_tsv(
  "data/20260126/20260126_species_cube_raccoon_be.csv",
  na = ""
)

# Unzip municipalities shapefile
zip_file <- "data/20260126/20260126_communesgemeente-belgium.zip"
municipalities_folder <- "data/20260126/20260126_municipalities_belgium"
unzip(zip_file, exdir = municipalities_folder)

# Unzip EEA grid shapefile
zip_file <- "data/20260126/20260126_eea_grid_be.zip"
eea_grid_folder <- "data/20260126/20260126_eea_grid_be"
unzip(zip_file, exdir = eea_grid_folder)

