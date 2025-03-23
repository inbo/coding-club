library(tidyverse)
library(colorblindr)
library(paletteer)

occs_benelux <- readr::read_tsv("data/20250325/20250325_occs_benelux.tsv")
species_be <- readr::read_tsv("data/20250325/species_in_BE.tsv")

occs_benelux_animals <- occs_benelux %>%
  dplyr::filter(kingdom == "Animalia")

# Challenge 1 ####





# Challenge 2 ####





# CHALLENGE 3A ####





# Challenge 3B ####

n_species_per_order_iucn <- species_be %>%
  group_by(phylum, order, iucnRedListCategory) %>%
  summarise(n_species = n_distinct(species)) %>%
  arrange(desc(n_species))
n_species_per_order_iucn




# BONUS CHALLENGE ####

n_species_region <- species_be %>%
  group_by(inFlanders, inWallonia, inBrussels) %>%
  summarise(n_species = n_distinct(species)) %>%
  arrange(desc(n_species))
n_species_region
