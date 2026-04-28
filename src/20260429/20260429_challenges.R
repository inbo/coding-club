library(tidyverse)

cube <- readr::read_tsv(
  "data/20260429/20260429_cube_marchantiophyta_flanders.tsv",
  na = ""
)

# CHALLENGE 1 ####



# CHALLENGE 2 ####



# CHALLENGE 3 ####

vernacular_names <- readr::read_tsv("data/20260429/20260429_vernacular_names_marchantiophyta_flanders.tsv", na = "")



## BONUS CHALLENGE ####

# Function to use in the second bonus challenge
library(rgbif)
vernacular_name <- function(key) {
  rgbif::name_usage(key = key, data = "vernacularNames") %>%
    purrr::pluck("data")
}
