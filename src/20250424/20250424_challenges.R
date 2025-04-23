library(sf)
library(tidyverse)
library(mapview) # Optional


heracleum_df <- readr::read_tsv(
  "data/20250424/20250424_heracleum_BE.tsv"
)
