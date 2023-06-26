library(sf)
library(tidyverse)
library(mapview) # optional: only needed to quickly visualize spatial data on a map

## CHALLENGE 1

# 1
lepidoptera_df <- read_tsv("./data/20230627/20230627_lepidoptera_iNaturalist_2023.csv")



# 6
provinces_be <- readRDS(file = "./data/20230627/20230627_provinces_be.rds")

